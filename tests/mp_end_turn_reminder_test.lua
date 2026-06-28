-- MPEndTurnReminder tests. Real SpeechPipeline / Text / TextFilter /
-- MessageBuffer dofiled (with the _speakAction capture seam); engine globals
-- stubbed so the poll's state machine can be driven directly. The clock is
-- injected through MPEndTurnReminder._now so the 60s cadence is deterministic.
--
-- Each test exercises a distinct branch: arm-and-fire on cancellation, the
-- sole-holdout gate, the repeat cadence, disarm on re-submit, the turn-
-- rollover guard against false positives, and the SP / sequential / toggle-off
-- / inactive-turn no-ops. The speech path feeds Tolk, so the announce shape
-- (interrupt + sound + buffer append) is guarded too.

local T = require("support")
local M = {}

local spoken
local dings
local isMP, gameTurn, sent
local meOpts, others
local connected
local clock

local function makePlayer(opts)
    return {
        IsHuman = function()
            return opts.human ~= false
        end,
        IsAlive = function()
            return opts.alive ~= false
        end,
        IsObserver = function()
            return opts.observer == true
        end,
        IsTurnActive = function()
            return opts.turnActive ~= false
        end,
        IsSimultaneousTurns = function()
            return opts.simul ~= false
        end,
        HasReceivedNetTurnComplete = function()
            return opts.received == true
        end,
    }
end

local function poll()
    MPEndTurnReminder._poll()
end

-- Drive the engine into "submitted" then back to "active" within one turn --
-- the cancellation the module watches for.
local function submit()
    sent = true
    poll()
end

local function cancel()
    sent = false
    poll()
end

local function setup()
    spoken = {}
    dings = {}
    isMP = true
    gameTurn = 5
    sent = false
    clock = 1000
    -- Me: player 0, a human in a simultaneous turn that is currently active.
    meOpts = { human = true, simul = true, turnActive = true }
    -- Player 1 is the other human; players 2/3 are AI (never hold the wave).
    -- Default: player 1 has ended, so we are the sole holdout.
    others = {
        [1] = { human = true, received = true },
        [2] = { human = false },
        [3] = { human = false },
    }
    connected = {}

    Game = {
        IsNetworkMultiPlayer = function()
            return isMP
        end,
        GetActivePlayer = function()
            return 0
        end,
        GetGameTurn = function()
            return gameTurn
        end,
    }
    Players = {
        [0] = makePlayer(meOpts),
        [1] = makePlayer(others[1]),
        [2] = makePlayer(others[2]),
        [3] = makePlayer(others[3]),
    }
    Network = {
        HasSentNetTurnComplete = function()
            return sent
        end,
        IsPlayerConnected = function(i)
            return connected[i] ~= false
        end,
    }
    GameDefines = { MAX_MAJOR_CIVS = 4 }
    Events = Events or {}
    Events.AudioPlay2DSound = function(id)
        dings[#dings + 1] = id
    end

    civvaccess_shared = {}
    civvaccess_shared.mpTurnReminder = true

    SpeechPipeline = nil
    Text = nil
    TextFilter = nil
    MessageBuffer = nil
    MPEndTurnReminder = nil
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_MessageBuffer.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_MPEndTurnReminder.lua")
    SpeechPipeline._reset()
    SpeechPipeline._speakAction = function(text, interrupt)
        spoken[#spoken + 1] = { text = text, mode = interrupt and "interrupt" or "queued" }
    end
    -- Drive SpeechPipeline's identical-text dedup off the same injected clock
    -- as the reminder cadence. In game the reminders are a minute apart, far
    -- outside the 0.05s dedup window; the test fires them microseconds apart in
    -- real time, so without this the repeats would be swallowed as duplicates.
    SpeechPipeline._timeSource = function()
        return clock
    end

    MPEndTurnReminder._now = function()
        return clock
    end
end

-- arm + immediate alert ----------------------------------------------------

function M.test_cancellation_alerts_when_sole_holdout()
    setup()
    submit()
    T.eq(#spoken, 0, "submitting is silent")
    cancel()
    T.eq(#spoken, 1, "the pull-back fires one immediate alert")
    T.eq(spoken[1].mode, "interrupt")
    local snap = MessageBuffer._snapshot()
    T.eq(#snap.entries, 1)
    T.eq(snap.entries[1].category, "notification")
    T.eq(#dings, 1, "the MP chat ding plays alongside the speech")
    T.eq(dings[1], "AS2D_IF_MP_CHAT_DING")
end

function M.test_silent_until_sole_holdout_then_fires()
    setup()
    others[1].received = false -- the other human is still acting
    submit()
    cancel()
    T.eq(#spoken, 0, "armed but not the sole holdout: stay silent")
    others[1].received = true -- now everyone else has ended
    poll()
    T.eq(#spoken, 1, "fires the instant we become the sole holdout")
end

-- repeat cadence -----------------------------------------------------------

function M.test_repeats_every_interval()
    setup()
    submit()
    cancel()
    T.eq(#spoken, 1)
    clock = 1059
    poll()
    T.eq(#spoken, 1, "no repeat before the interval elapses")
    clock = 1060
    poll()
    T.eq(#spoken, 2, "repeats once a full interval has passed")
end

-- disarm -------------------------------------------------------------------

function M.test_resubmit_disarms()
    setup()
    submit()
    cancel()
    T.eq(#spoken, 1)
    submit() -- re-readied
    T.eq(civvaccess_shared.mpReminderArmed, false)
    clock = 2000
    cancel() -- a fresh cancellation re-arms and fires again
    T.eq(#spoken, 2, "re-submitting clears the alert; a new cancellation re-arms")
end

-- turn-rollover guard ------------------------------------------------------

function M.test_new_turn_is_not_a_cancellation()
    setup()
    submit() -- submitted on turn 5
    gameTurn = 6 -- the wave completes, a new turn begins...
    sent = false -- ...and the engine clears the submitted flag naturally
    poll()
    T.eq(#spoken, 0, "a genuine new turn must never read as a pull-back")
end

-- no-op gates --------------------------------------------------------------

function M.test_single_player_is_noop()
    setup()
    isMP = false
    submit()
    cancel()
    T.eq(#spoken, 0)
end

function M.test_sequential_turns_clears_and_is_silent()
    setup()
    submit()
    cancel()
    T.eq(#spoken, 1, "armed during the simultaneous phase")
    meOpts.simul = false -- dynamic turns flips to sequential
    poll()
    T.eq(civvaccess_shared.mpReminderArmed, false, "armed state dropped in sequential mode")
    clock = 5000
    poll()
    T.eq(#spoken, 1, "no nagging during a sequential turn")
end

function M.test_toggle_off_is_silent()
    setup()
    civvaccess_shared.mpTurnReminder = false
    submit()
    cancel()
    T.eq(#spoken, 0)
    T.eq(civvaccess_shared.mpReminderArmed, true, "still armed, just muted by the setting")
end

function M.test_inactive_turn_is_silent()
    setup()
    meOpts.turnActive = false
    submit()
    cancel()
    T.eq(#spoken, 0, "nothing to act on when our turn is not active")
end

-- install ------------------------------------------------------------------

function M.test_install_seeds_state_and_subscribes()
    setup()
    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TickPump.lua")
    TickPump._reset()
    civvaccess_shared.mpTurnReminder = nil
    civvaccess_shared.mpReminderArmed = true -- stale state from a prior game
    MPEndTurnReminder.installListeners()
    T.eq(civvaccess_shared.mpTurnReminder, true, "setting seeded to its default")
    T.eq(civvaccess_shared.mpReminderArmed, false, "prior-game armed state reset")
    T.eq(
        civvaccess_shared.tickSubscribers["MPEndTurnReminder"],
        MPEndTurnReminder._poll,
        "the poll is registered as a TickPump subscriber"
    )
end

return M
