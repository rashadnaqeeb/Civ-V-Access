-- MessageBuffer tests. Covers append (with cap eviction and the position
-- shift that follows it), single-step navigation, end-jumps, edge re-
-- speak when running off either end, filter cycling that skips empty
-- categories and the reset-to-newest contract that follows a filter
-- change, the empty-buffer announcement on every input, and reset-on-
-- boot. Speech goes through SpeechPipeline's _speakAction seam so each
-- test asserts on the exact text + interrupt the user would hear.

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

    spoken = T.captureSpeech()
    -- Edge re-speaks fire the same string twice in a row, and the
    -- pipeline's 50ms interrupt-dedupe would silently swallow the second
    -- call when both happen within the same os.clock() tick. Drive the
    -- pipeline's clock from a counter so every speakInterrupt sees a
    -- fresh timestamp well past the dedupe window.
    local tick = 0
    SpeechPipeline._timeSource = function()
        tick = tick + 1
        return tick
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

function M.test_prev_at_oldest_repeats_current_entry()
    setup()
    MessageBuffer.append("a", "notification")
    MessageBuffer.prev()
    T.eq(lastSpoken().text, "a")
    MessageBuffer.prev()
    -- Walking off the back re-speaks the current entry rather than
    -- announcing an "oldest" marker. Same string as the previous press,
    -- which the user reads as "you tried to go further but couldn't."
    T.eq(lastSpoken().text, "a", "edge re-speaks the current entry")
    local s = MessageBuffer._snapshot()
    T.eq(s.position, 1, "position pinned at oldest after edge")
end

function M.test_next_from_uninitialized_enters_at_newest()
    setup()
    MessageBuffer.append("a", "notification")
    MessageBuffer.append("b", "notification")
    -- Position 0 is uninitialized. Both bracket keys enter the buffer at
    -- the newest matching entry from there; ] is symmetric to [.
    MessageBuffer.next()
    T.eq(lastSpoken().text, "b")
    local s = MessageBuffer._snapshot()
    T.eq(s.position, 2, "position lands on newest after entry")
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
    T.eq(lastSpoken().text, "c", "stopped at newest, current entry re-spoken")
    local s = MessageBuffer._snapshot()
    T.eq(s.position, 3, "position pinned at newest after edge")
end

function M.test_prev_on_empty_buffer_speaks_empty_marker()
    setup()
    MessageBuffer.prev()
    T.eq(lastSpoken().text, "no messages")
end

function M.test_next_on_empty_buffer_speaks_empty_marker()
    setup()
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

function M.test_filter_forward_skips_empty_categories()
    setup()
    MessageBuffer.append("clash", "combat")
    -- All -> notifications (empty, skip) -> reveals (empty, skip) -> combat.
    MessageBuffer.cycleFilterForward()
    T.eq(lastSpoken().text, "Combat, clash")
    local s = MessageBuffer._snapshot()
    T.eq(s.filter, "combat", "filter landed on the only non-empty category")
    -- Combat -> all (still has the same one entry).
    MessageBuffer.cycleFilterForward()
    T.eq(lastSpoken().text, "All messages, clash")
end

function M.test_filter_backward_skips_empty_categories()
    setup()
    MessageBuffer.append("a", "notification")
    -- All going backward: combat (empty, skip) -> reveals (empty, skip)
    -- -> notifications (has a). Wraps past the empty tail of the cycle
    -- in one announcement.
    MessageBuffer.cycleFilterBackward()
    T.eq(lastSpoken().text, "Notifications, a")
    -- Notifications backward: hops back to all (only other non-empty).
    MessageBuffer.cycleFilterBackward()
    T.eq(lastSpoken().text, "All messages, a")
end

function M.test_filter_cycle_on_empty_buffer_speaks_only_empty_marker()
    setup()
    -- Buffer fully empty. Cycling shouldn't announce a filter name (no
    -- filter view has anything in it) and shouldn't change the active
    -- filter -- there's nothing to switch to.
    MessageBuffer.cycleFilterForward()
    T.eq(lastSpoken().text, "no messages")
    local s = MessageBuffer._snapshot()
    T.eq(s.filter, "all", "filter unchanged on empty buffer")
    MessageBuffer.cycleFilterBackward()
    T.eq(lastSpoken().text, "no messages")
    s = MessageBuffer._snapshot()
    T.eq(s.filter, "all", "filter unchanged on empty buffer (backward)")
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
    -- We're at c1 (position 2). Cycling forward visits notifications
    -- (has n1/n2) then skips reveals (empty) and lands on combat. Each
    -- landing position is the newest matching entry, not the absolute
    -- index the user was at.
    MessageBuffer.cycleFilterForward() -- All -> Notifications
    T.eq(lastSpoken().text, "Notifications, n2")
    MessageBuffer.cycleFilterForward() -- skip Reveals (empty), land on Combat
    T.eq(lastSpoken().text, "Combat, c2", "newest combat entry after filter change")
end

function M.test_navigation_within_filter_skips_non_matching()
    setup()
    MessageBuffer.append("n1", "notification")
    MessageBuffer.append("c1", "combat")
    MessageBuffer.append("n2", "notification")
    MessageBuffer.append("c2", "combat")
    MessageBuffer.cycleFilterForward() -- All -> Notifications -> n2
    T.eq(lastSpoken().text, "Notifications, n2")
    MessageBuffer.prev()
    T.eq(lastSpoken().text, "n1", "skips combat entries when filter is notification")
    MessageBuffer.prev()
    T.eq(lastSpoken().text, "n1", "edge re-speaks current entry after walking through both notifications")
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
