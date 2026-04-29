-- MessageBuffer tests. Covers append (with cap eviction and the position
-- shift that follows it), single-step navigation, end-jumps, edge markers
-- when running off either end, filter cycling and the reset-to-newest
-- contract that follows a filter change, and reset-on-boot. Speech goes
-- through SpeechPipeline's _speakAction seam so each test asserts on the
-- exact text + interrupt the user would hear.

local T = require("support")
local M = {}

local spoken

local function setup()
    civvaccess_shared = {}
    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_MessageBuffer.lua")

    HandlerStack._reset()
    SpeechPipeline._reset()
    MessageBuffer._reset()
    MessageBuffer._setCap(5000)

    spoken = {}
    SpeechPipeline._speakAction = function(text, interrupt)
        spoken[#spoken + 1] = { text = text, interrupt = interrupt }
    end
end

local function lastSpoken()
    return spoken[#spoken]
end

-- Append + state ----------------------------------------------------------

function M.test_append_records_text_and_category()
    setup()
    MessageBuffer.append("first", "notification")
    MessageBuffer.append("second", "combat")
    local s = MessageBuffer._snapshot()
    T.eq(#s.entries, 2)
    T.eq(s.entries[1].text, "first")
    T.eq(s.entries[1].category, "notification")
    T.eq(s.entries[2].text, "second")
    T.eq(s.entries[2].category, "combat")
end

function M.test_append_rejects_unknown_category()
    setup()
    MessageBuffer.append("oops", "garbage")
    local s = MessageBuffer._snapshot()
    -- state() lazy-creates the table on first append, but the unknown
    -- category branch returns before that, so no entry lands. The shared
    -- slot may still be nil here since nothing else touched it.
    T.truthy(s == nil or #s.entries == 0, "unknown-category append must be a no-op")
end

function M.test_append_skips_empty_text()
    setup()
    MessageBuffer.append("", "combat")
    MessageBuffer.append(nil, "combat")
    local s = MessageBuffer._snapshot()
    T.truthy(s == nil or #s.entries == 0, "empty / nil text must be a no-op")
end

-- Forward / backward navigation ------------------------------------------

function M.test_prev_from_uninitialized_jumps_to_newest()
    setup()
    MessageBuffer.append("a", "notification")
    MessageBuffer.append("b", "notification")
    MessageBuffer.append("c", "notification")
    MessageBuffer.prev()
    T.eq(lastSpoken().text, "c", "first prev lands on the newest entry")
    T.eq(lastSpoken().interrupt, true, "navigation interrupts in-flight speech")
end

function M.test_prev_walks_backward_through_entries()
    setup()
    MessageBuffer.append("a", "notification")
    MessageBuffer.append("b", "notification")
    MessageBuffer.append("c", "notification")
    MessageBuffer.prev()
    MessageBuffer.prev()
    MessageBuffer.prev()
    T.eq(spoken[1].text, "c")
    T.eq(spoken[2].text, "b")
    T.eq(spoken[3].text, "a")
end

function M.test_prev_at_oldest_speaks_edge_marker()
    setup()
    MessageBuffer.append("a", "notification")
    MessageBuffer.prev()
    T.eq(lastSpoken().text, "a")
    MessageBuffer.prev()
    T.eq(lastSpoken().text, "oldest", "edge marker fires when running off the back")
    -- Position must not have moved into invalid territory.
    local s = MessageBuffer._snapshot()
    T.eq(s.position, 1, "position pinned at oldest after edge")
end

function M.test_next_from_uninitialized_speaks_edge_marker()
    setup()
    MessageBuffer.append("a", "notification")
    -- Position 0 is conceptually past-the-newest. Pressing ] from there
    -- is already at the forward edge -- the user enters the buffer with
    -- [ and walks back, then can use ] to come forward again.
    MessageBuffer.next()
    T.eq(lastSpoken().text, "newest")
end

function M.test_next_walks_forward_after_prev()
    setup()
    MessageBuffer.append("a", "notification")
    MessageBuffer.append("b", "notification")
    MessageBuffer.append("c", "notification")
    MessageBuffer.prev() -- newest = c
    MessageBuffer.prev() -- b
    MessageBuffer.prev() -- a
    MessageBuffer.next() -- forward to b
    T.eq(lastSpoken().text, "b")
    MessageBuffer.next()
    T.eq(lastSpoken().text, "c")
    MessageBuffer.next()
    T.eq(lastSpoken().text, "newest", "stopped at newest with edge marker")
end

function M.test_prev_on_empty_buffer_speaks_empty_marker()
    setup()
    MessageBuffer.prev()
    T.eq(lastSpoken().text, "no messages")
end

function M.test_next_on_empty_buffer_speaks_empty_marker()
    -- ] from position 0 means "already at the forward edge", but with no
    -- entries at all "newest" is misleading -- there is no newest. Mirror
    -- prev's empty-buffer branch and speak the empty marker instead.
    setup()
    MessageBuffer.next()
    T.eq(lastSpoken().text, "no messages")
end

function M.test_next_on_empty_filter_speaks_empty_marker()
    -- Same logic for an empty filter category: position 0, no entries
    -- match the active filter, so ] should speak EMPTY rather than
    -- claim the user is at the "newest" of nothing.
    setup()
    MessageBuffer.append("a", "combat")
    MessageBuffer.cycleFilterForward() -- All -> Notifications, empty
    -- cycleFilter spoke "Notifications, no messages"; reset spoken so
    -- the next() assertion sees only its own output.
    spoken = {}
    MessageBuffer.next()
    T.eq(lastSpoken().text, "no messages")
end

-- End jumps ---------------------------------------------------------------

function M.test_jumpFirst_lands_on_oldest_matching()
    setup()
    MessageBuffer.append("a", "notification")
    MessageBuffer.append("b", "combat")
    MessageBuffer.append("c", "notification")
    MessageBuffer.jumpFirst()
    T.eq(lastSpoken().text, "a")
    local s = MessageBuffer._snapshot()
    T.eq(s.position, 1)
end

function M.test_jumpLast_lands_on_newest_matching()
    setup()
    MessageBuffer.append("a", "notification")
    MessageBuffer.append("b", "combat")
    MessageBuffer.jumpLast()
    T.eq(lastSpoken().text, "b")
end

function M.test_end_jumps_on_empty_speak_empty_marker()
    setup()
    MessageBuffer.jumpFirst()
    T.eq(lastSpoken().text, "no messages")
    MessageBuffer.jumpLast()
    T.eq(lastSpoken().text, "no messages")
end

-- Filter cycling ----------------------------------------------------------

function M.test_filter_forward_cycles_and_announces_with_newest()
    setup()
    MessageBuffer.append("note 1", "notification")
    MessageBuffer.append("clash", "combat")
    MessageBuffer.cycleFilterForward()
    -- All -> Notifications. Speaks filter name + newest matching entry.
    T.eq(lastSpoken().text, "Notifications, note 1")
    local s = MessageBuffer._snapshot()
    T.eq(s.filter, "notification")
    T.eq(s.position, 1, "position resets to newest matching after filter change")
end

function M.test_filter_forward_skips_to_next_when_current_filter_empty()
    setup()
    MessageBuffer.append("clash", "combat")
    MessageBuffer.cycleFilterForward() -- All -> Notifications, empty
    T.eq(lastSpoken().text, "Notifications, no messages")
    MessageBuffer.cycleFilterForward() -- Notifications -> Reveals, empty
    T.eq(lastSpoken().text, "Reveals, no messages")
    MessageBuffer.cycleFilterForward() -- Reveals -> Combat, has clash
    T.eq(lastSpoken().text, "Combat, clash")
end

function M.test_filter_backward_cycles_in_reverse()
    setup()
    MessageBuffer.append("a", "notification")
    -- Backward from "all" should wrap to the last filter in the cycle.
    MessageBuffer.cycleFilterBackward()
    T.eq(lastSpoken().text, "Combat, no messages")
    MessageBuffer.cycleFilterBackward()
    T.eq(lastSpoken().text, "Reveals, no messages")
    MessageBuffer.cycleFilterBackward()
    T.eq(lastSpoken().text, "Notifications, a")
end

function M.test_filter_change_resets_position_to_newest()
    setup()
    MessageBuffer.append("n1", "notification")
    MessageBuffer.append("c1", "combat")
    MessageBuffer.append("n2", "notification")
    MessageBuffer.append("c2", "combat")
    MessageBuffer.prev() -- newest in all -> c2
    MessageBuffer.prev() -- n2
    MessageBuffer.prev() -- c1
    -- We're at c1 (position 2). Switching to combat filter should jump to
    -- the newest combat entry (c2), not stay at the absolute index.
    MessageBuffer.cycleFilterForward() -- All -> Notifications
    T.eq(lastSpoken().text, "Notifications, n2")
    MessageBuffer.cycleFilterForward() -- Notifications -> Reveals
    T.eq(lastSpoken().text, "Reveals, no messages")
    MessageBuffer.cycleFilterForward() -- Reveals -> Combat
    T.eq(lastSpoken().text, "Combat, c2", "newest combat entry after filter change")
end

function M.test_navigation_within_filter_skips_non_matching()
    setup()
    MessageBuffer.append("n1", "notification")
    MessageBuffer.append("c1", "combat")
    MessageBuffer.append("n2", "notification")
    MessageBuffer.append("c2", "combat")
    MessageBuffer.cycleFilterForward() -- Notifications -> n2
    T.eq(lastSpoken().text, "Notifications, n2")
    MessageBuffer.prev()
    T.eq(lastSpoken().text, "n1", "skips combat entries when filter is notification")
    MessageBuffer.prev()
    T.eq(lastSpoken().text, "oldest", "edge after walking through both notifications")
end

-- Cap eviction ------------------------------------------------------------

function M.test_cap_eviction_drops_oldest()
    setup()
    MessageBuffer._setCap(3)
    MessageBuffer.append("a", "combat")
    MessageBuffer.append("b", "combat")
    MessageBuffer.append("c", "combat")
    MessageBuffer.append("d", "combat") -- triggers eviction of "a"
    local s = MessageBuffer._snapshot()
    T.eq(#s.entries, 3)
    T.eq(s.entries[1].text, "b")
    T.eq(s.entries[3].text, "d")
end

function M.test_cap_eviction_shifts_position_to_track_same_entry()
    setup()
    MessageBuffer._setCap(3)
    MessageBuffer.append("a", "combat")
    MessageBuffer.append("b", "combat")
    MessageBuffer.append("c", "combat")
    MessageBuffer.prev() -- newest = c, position 3
    MessageBuffer.prev() -- b, position 2
    MessageBuffer.append("d", "combat") -- evicts a, b moves to index 1
    local s = MessageBuffer._snapshot()
    T.eq(s.position, 1, "position decremented so it still points at b")
    T.eq(s.entries[s.position].text, "b", "still anchored on the same logical entry")
end

function M.test_cap_eviction_clamps_when_user_was_on_evicted_entry()
    setup()
    MessageBuffer._setCap(3)
    MessageBuffer.append("a", "combat")
    MessageBuffer.append("b", "combat")
    MessageBuffer.append("c", "combat")
    MessageBuffer.jumpFirst() -- position 1, on "a"
    MessageBuffer.append("d", "combat") -- evicts a
    local s = MessageBuffer._snapshot()
    T.eq(s.position, 1, "clamped to oldest available rather than going to 0")
    T.eq(s.entries[s.position].text, "b", "now anchored on the new oldest")
end

-- Reset -------------------------------------------------------------------

function M.test_install_listeners_clears_buffer()
    setup()
    MessageBuffer.append("a", "combat")
    MessageBuffer.append("b", "combat")
    MessageBuffer.installListeners()
    local s = MessageBuffer._snapshot()
    T.truthy(s == nil, "messageBuffer table cleared on reset")
    -- A subsequent prev on the empty buffer must not crash.
    MessageBuffer.prev()
    T.eq(lastSpoken().text, "no messages")
end

-- Bindings ----------------------------------------------------------------

function M.test_bindings_cover_all_six_chords()
    setup()
    local b = MessageBuffer.getBindings()
    -- 6 chords: bare [/], Ctrl+[/], Shift+[/]
    T.eq(#b.bindings, 6)
    -- Help entries documented for each chord pair.
    T.eq(#b.helpEntries, 3)
end

return M
