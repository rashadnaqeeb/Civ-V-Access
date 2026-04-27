-- NotificationAnnounce tests. Seams substituted: SpeechPipeline._speakAction
-- (capturing sink), NotificationAnnounce._timeSource (controllable clock),
-- the three Events tables NotificationAdded / GameplaySetActivePlayer /
-- ActivePlayerTurnStart (capture listeners so tests can fire synthetic
-- events), Players[0] (controls existing notifications visible to the
-- install-time snapshot). TickPump and the module itself are loaded for
-- real.

local T = require("support")
local M = {}

local spoken
local addedListeners
local activePlayerListeners
local turnStartListeners
local existingIds
local clockNow

local function advanceClock(dt)
    clockNow = clockNow + dt
end

-- Run one TickPump tick. The drain reads the current clock to decide
-- whether to flush or reschedule.
local function tick()
    TickPump.tick()
end

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

    clockNow = 1000.0
    NotificationAnnounce._timeSource = function()
        return clockNow
    end

    addedListeners = {}
    activePlayerListeners = {}
    turnStartListeners = {}
    Events.NotificationAdded = {
        Add = function(fn)
            addedListeners[#addedListeners + 1] = fn
        end,
    }
    Events.GameplaySetActivePlayer = {
        Add = function(fn)
            activePlayerListeners[#activePlayerListeners + 1] = fn
        end,
    }
    Events.ActivePlayerTurnStart = {
        Add = function(fn)
            turnStartListeners[#turnStartListeners + 1] = fn
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

local function fireActivePlayerChanged(iActive, iPrev)
    for _, fn in ipairs(activePlayerListeners) do
        fn(iActive, iPrev)
    end
end

local function fireTurnStart()
    for _, fn in ipairs(turnStartListeners) do
        fn()
    end
end

-- Rebroadcast suppression -------------------------------------------------

function M.test_existing_ids_filtered_at_install()
    setup({ 10, 11, 12 })
    -- Rebroadcast: engine re-fires NotificationAdded for each existing Id.
    fireAdd(10)
    fireAdd(11)
    fireAdd(12)
    advanceClock(1.0)
    tick()
    T.eq(#spoken, 0, "rebroadcast of snapshot Ids must not speak")
end

function M.test_id_above_snapshot_still_processes()
    setup({ 10, 11, 12 })
    fireAdd(13)
    advanceClock(1.0)
    tick()
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, "note 13")
end

function M.test_duplicate_id_speaks_once()
    setup()
    fireAdd(1)
    fireAdd(1)
    advanceClock(1.0)
    tick()
    T.eq(#spoken, 1, "same Id firing twice must only speak once")
end

-- Hotseat / MP active-player change --------------------------------------

function M.test_active_player_change_discards_rebroadcast_wave()
    -- The new active player has standing notifications 20/21/22. The
    -- engine's RebroadcastNotifications fires NotificationAdded for each
    -- synchronously inside NotificationPanel's GameplaySetActivePlayer
    -- handler -- they land in pending. Our handler runs after and must
    -- sweep them.
    setup({ 10 })
    -- Simulate the rebroadcast: new player's IDs flood _onAdded just
    -- before our handler fires. Update Players[0] to the new player so
    -- snapshotExisting in our handler reads the right standing list.
    fireAdd(20)
    fireAdd(21)
    fireAdd(22)
    existingIds = { 20, 21, 22 }
    fireActivePlayerChanged(1, 0)
    advanceClock(1.0)
    tick()
    T.eq(#spoken, 0, "rebroadcast wave must not speak after handoff")
end

function M.test_genuine_add_after_active_player_change_speaks()
    setup({ 10 })
    -- Handoff with no rebroadcast wave for simplicity.
    existingIds = {}
    fireActivePlayerChanged(1, 0)
    -- A genuine new add for the new active player.
    fireAdd(50)
    advanceClock(1.0)
    tick()
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, "note 50")
end

function M.test_active_player_change_resets_seen_ids_for_id_collisions()
    -- If notification IDs are per-player, the previous player's ID 10
    -- being in seenIds would false-suppress the new player's ID 10.
    -- After handoff, seenIds is reseated from the new active player's
    -- standing list, so an unseen Id 10 from the new player speaks.
    setup({ 10 })
    existingIds = {}
    fireActivePlayerChanged(1, 0)
    fireAdd(10)
    advanceClock(1.0)
    tick()
    T.eq(#spoken, 1, "post-handoff Id collision must not be suppressed")
end

-- Debounce ----------------------------------------------------------------

function M.test_single_add_flushes_after_debounce()
    setup()
    fireAdd(1)
    advanceClock(0.1)
    tick()
    T.eq(#spoken, 0, "still inside debounce window")
    advanceClock(0.15)
    tick()
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, "note 1")
    T.eq(spoken[1].interrupt, false)
end

function M.test_streaming_adds_collapse_into_one_drain()
    -- Adds keep landing inside the debounce window; each one extends it.
    -- The whole queue flushes together when the stream stops.
    setup()
    fireAdd(1)
    advanceClock(0.1)
    fireAdd(2)
    advanceClock(0.1)
    fireAdd(3)
    advanceClock(0.1)
    tick()
    T.eq(#spoken, 0, "stream is still extending the debounce")
    advanceClock(0.15)
    tick()
    T.eq(#spoken, 3, "all three flush together once the stream stops")
    T.eq(spoken[1].text, "note 1")
    T.eq(spoken[2].text, "note 2")
    T.eq(spoken[3].text, "note 3")
    for i = 1, 3 do
        T.eq(spoken[i].interrupt, false, "all queued, none interrupts")
    end
end

function M.test_separate_adds_outside_debounce_flush_separately()
    setup()
    fireAdd(1)
    advanceClock(0.5)
    tick()
    T.eq(#spoken, 1)
    fireAdd(2)
    advanceClock(0.5)
    tick()
    T.eq(#spoken, 2)
    T.eq(spoken[2].text, "note 2")
end

-- Turn-start hold ---------------------------------------------------------

function M.test_turn_start_holds_pending_until_deadline()
    setup()
    fireAdd(1)
    -- Notification arrived; debounce alone would flush after 0.2s.
    advanceClock(0.05)
    fireTurnStart() -- holdUntil = now + 0.5
    advanceClock(0.25)
    tick()
    T.eq(#spoken, 0, "debounce satisfied but still inside the turn-start hold")
    advanceClock(0.30)
    tick()
    T.eq(#spoken, 1, "flushes once the hold deadline passes")
end

function M.test_turn_start_with_no_pending_is_inert()
    setup()
    fireTurnStart()
    advanceClock(1.0)
    tick()
    T.eq(#spoken, 0, "turn start with empty queue is a no-op")
end

function M.test_add_after_turn_start_still_holds()
    setup()
    fireTurnStart()
    advanceClock(0.1)
    fireAdd(1)
    advanceClock(0.25) -- past debounce, but not past turn-start hold
    tick()
    T.eq(#spoken, 0, "adds after turn start still wait for the hold")
    advanceClock(0.20) -- past hold now
    tick()
    T.eq(#spoken, 1)
end

-- Empty-summary fallback --------------------------------------------------

function M.test_empty_summary_falls_back_to_tooltip()
    setup()
    fireAdd(1, { summary = "", toolTip = "fallback text" })
    advanceClock(1.0)
    tick()
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, "fallback text")
end

function M.test_both_empty_skipped()
    setup()
    fireAdd(1, { summary = "", toolTip = "" })
    advanceClock(1.0)
    tick()
    T.eq(#spoken, 0, "nothing to say means say nothing, not speak a blank")
end

-- Reset -------------------------------------------------------------------

function M.test_reset_clears_seen_ids()
    setup()
    fireAdd(1)
    advanceClock(1.0)
    tick()
    T.eq(#spoken, 1)
    NotificationAnnounce._reset()
    setup()
    fireAdd(1)
    advanceClock(1.0)
    tick()
    T.eq(#spoken, 1, "reset empties seenIds so a previously-seen Id is new again")
end

return M
