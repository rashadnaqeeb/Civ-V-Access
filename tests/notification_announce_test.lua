-- NotificationAnnounce tests. Seams substituted: SpeechPipeline._speakAction
-- (capturing sink), Events.NotificationAdded.Add (captures the listener so
-- tests can fire synthetic adds), Players[0] (controls existing notifications
-- visible to the install-time snapshot). TickPump and the module itself are
-- loaded for real.

local T = require("support")
local M = {}

local spoken
local addedListeners
local existingIds

local function setup(existing)
    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TickPump.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_NotificationAnnounce.lua")

    HandlerStack._reset()
    TickPump._reset()
    SpeechPipeline._reset()
    NotificationAnnounce._reset()

    spoken = {}
    SpeechPipeline._speakAction = function(text, interrupt)
        spoken[#spoken + 1] = { text = text, interrupt = interrupt }
    end

    addedListeners = {}
    Events.NotificationAdded = {
        Add = function(fn)
            addedListeners[#addedListeners + 1] = fn
        end,
    }

    existingIds = existing or {}
    Players[0] = {
        GetNumNotifications = function()
            return #existingIds
        end,
        GetNotificationIndex = function(_, i)
            return existingIds[i + 1]
        end,
    }
    Game.GetActivePlayer = function()
        return 0
    end

    NotificationAnnounce.install()
end

-- Fire a synthetic NotificationAdded through every registered listener.
-- Defaults: toolTip/summary distinguishable by id, active player (0).
local function fireAdd(id, opts)
    opts = opts or {}
    local summary = opts.summary
    if summary == nil then
        summary = "note " .. tostring(id)
    end
    local toolTip = opts.toolTip or ("tip " .. tostring(id))
    local ePlayer = opts.ePlayer
    if ePlayer == nil then
        ePlayer = 0
    end
    for _, fn in ipairs(addedListeners) do
        fn(id, 0, toolTip, summary, -1, -1, ePlayer)
    end
end

local function advance(n)
    for _ = 1, n do
        TickPump.tick()
    end
end

-- Rebroadcast suppression -------------------------------------------------

function M.test_existing_ids_filtered_at_install()
    setup({ 10, 11, 12 })
    -- Rebroadcast: engine re-fires NotificationAdded for each existing Id.
    fireAdd(10)
    fireAdd(11)
    fireAdd(12)
    advance(20)
    T.eq(#spoken, 0, "rebroadcast of snapshot Ids must not speak")
end

function M.test_id_above_snapshot_still_processes()
    setup({ 10, 11, 12 })
    fireAdd(13)
    advance(10)
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, "note 13")
end

function M.test_duplicate_id_speaks_once()
    setup()
    fireAdd(1)
    fireAdd(1)
    advance(10)
    T.eq(#spoken, 1, "same Id firing twice must only speak once")
end

-- Single notification path ------------------------------------------------

function M.test_single_add_queues_after_window()
    setup()
    fireAdd(1)
    -- Inside the burst window, nothing flushes (it might still tip into a burst).
    advance(5)
    T.eq(#spoken, 0, "entry still inside the burst window is held")
    advance(3)
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, "note 1")
    T.eq(spoken[1].interrupt, false, "notifications queue so they don't clobber a turn-end dialogue")
end

-- Burst detection ---------------------------------------------------------

function M.test_three_in_six_frames_collapses_to_burst()
    -- Burst check is synchronous at add time; the third add fires the
    -- collapse before any tick runs.
    setup()
    fireAdd(1)
    T.eq(#spoken, 0, "first add alone is not a burst")
    fireAdd(2)
    T.eq(#spoken, 0, "second add alone is not a burst")
    fireAdd(3)
    T.eq(#spoken, 1, "third add within window triggers burst immediately")
    T.truthy(spoken[1].text:find("3", 1, true), "burst text carries the count")
    T.eq(spoken[1].interrupt, false, "burst announcement queues to avoid clobbering a turn-end dialogue")
end

function M.test_two_in_six_frames_not_a_burst()
    setup()
    fireAdd(1)
    fireAdd(2)
    advance(10)
    T.eq(#spoken, 2, "two adds must flush individually, no burst collapse")
    T.eq(spoken[1].text, "note 1")
    T.eq(spoken[2].text, "note 2")
end

function M.test_late_third_arrival_tips_into_burst()
    -- Two at frame 0, third at frame 5. At frame 5 the window is [0,5]
    -- inclusive; all three are recent, so the burst triggers on the
    -- third add without needing another tick.
    setup()
    fireAdd(1)
    fireAdd(2)
    advance(5)
    fireAdd(3)
    T.eq(#spoken, 1)
    T.truthy(spoken[1].text:find("3", 1, true), "burst text carries the count")
end

function M.test_fourth_add_does_not_retroactively_join_prior_burst()
    -- The third add already collapsed entries 1..3 into a burst, clearing
    -- pending. A fourth add arriving shortly after starts a fresh count
    -- and flushes individually after aging.
    setup()
    fireAdd(1)
    fireAdd(2)
    fireAdd(3)
    T.eq(#spoken, 1)
    T.truthy(spoken[1].text:find("3", 1, true), "burst text carries the count")
    fireAdd(4)
    T.eq(#spoken, 1, "fourth add alone does not re-burst")
    advance(10)
    T.eq(#spoken, 2, "fourth add ages out and flushes individually")
    T.eq(spoken[2].text, "note 4")
end

function M.test_adds_outside_window_not_a_burst()
    -- 2 adds at frame 0, then one at frame 8: the first two have already
    -- aged out and been flushed; the third stands alone.
    setup()
    fireAdd(1)
    fireAdd(2)
    advance(8)
    T.eq(#spoken, 2, "first two aged out before the third arrived")
    fireAdd(3)
    advance(8)
    T.eq(#spoken, 3)
    T.eq(spoken[3].text, "note 3")
end

-- All-queued on individual flush -----------------------------------------

function M.test_two_simultaneous_aged_flush_all_queued()
    -- Two adds in the same frame; neither tips the burst threshold. When
    -- they age out together both must queue (no interrupt) so a concurrent
    -- turn-end dialogue isn't clobbered.
    setup()
    fireAdd(1)
    fireAdd(2)
    advance(10)
    T.eq(#spoken, 2)
    T.eq(spoken[1].interrupt, false, "first of a multi-flush queues")
    T.eq(spoken[2].interrupt, false, "subsequent flushes in the same drain queue")
end

-- Empty-summary fallback --------------------------------------------------

function M.test_empty_summary_falls_back_to_tooltip()
    setup()
    fireAdd(1, { summary = "", toolTip = "fallback text" })
    advance(10)
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, "fallback text")
end

function M.test_both_empty_skipped()
    setup()
    fireAdd(1, { summary = "", toolTip = "" })
    advance(10)
    T.eq(#spoken, 0, "nothing to say means say nothing, not speak a blank")
end

-- Reset -------------------------------------------------------------------

function M.test_reset_clears_seen_ids()
    setup()
    fireAdd(1)
    advance(10)
    T.eq(#spoken, 1)
    NotificationAnnounce._reset()
    -- After reset, seenIds is empty so re-firing Id 1 speaks again.
    setup() -- fresh install without preloading existing ids
    fireAdd(1)
    advance(10)
    T.eq(#spoken, 1, "reset empties seenIds so a previously-seen Id is new again")
end

return M
