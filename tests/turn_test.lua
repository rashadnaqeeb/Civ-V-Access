-- Turn-module tests. Covers the Ctrl+Space / Ctrl+Shift+Space dispatch
-- branches (no-blocker end, per-blocker announce-and-activate, unit-blocker
-- select-and-center, promotion-blocker iterate-for-ready, multiplayer
-- already-submitted un-ready) and the turn-lifecycle listeners
-- (turn-start "Turn: N, year" formatting for both BC and AD, turn-end
-- "Turn ended"). Engine seams that get capturing stubs: DoControl,
-- ActivateNotification, SelectUnit, LookAt, SendTurnUnready, and the
-- Events.ActivePlayerTurn{Start,End} .Add hooks.

local T = require("support")
local M = {}

-- Game text keys the production code pulls in (blocker labels, turn
-- counter, AD/BC formats). Bare CivVAccess_Strings only covers our own
-- keys; the production Locale.ConvertTextKey resolves game keys from the
-- engine's XML. We mirror the exact XML templates here so the final
-- assertion reads as what a sighted player would see.
local GAME_TEXT = {
    ["TXT_KEY_TP_TURN_COUNTER"] = "Turn: {1_Nim}",
    ["TXT_KEY_TIME_AD"] = "{1_Date} AD",
    ["TXT_KEY_TIME_BC"] = "{1_Date} BC",
    ["TXT_KEY_CHOOSE_POLICY"] = "Choose Policy",
    ["TXT_KEY_CHOOSE_RESEARCH"] = "Choose Research",
    ["TXT_KEY_CHOOSE_FREE_TECH"] = "Choose Free Tech",
    ["TXT_KEY_CHOOSE_PRODUCTION"] = "Choose Production",
    ["TXT_KEY_UNIT_NEEDS_ORDERS"] = "Unit Needs Orders",
    ["TXT_KEY_MOVE_STACKED_UNIT"] = "Move Stacked Unit",
    ["TXT_KEY_UNIT_PROMOTION"] = "Unit Promotion Available",
    ["TXT_KEY_WAITING_FOR_PLAYERS"] = "Waiting for players",
}

local spoken
local doControlCalls
local activateNotificationCalls
local selectedUnits
local lookAtPlots
local sendUnreadyCalls
local sendUnreadyResult
local loggedWarnings
local startListeners
local endListeners
local activePlayer

local function setup()
    Locale.ConvertTextKey = function(key, ...)
        local template = GAME_TEXT[key] or key
        local args = { ... }
        if #args == 0 then
            return template
        end
        return (
            template:gsub("{(%d+)_[^}]*}", function(n)
                local v = args[tonumber(n)]
                if v == nil then
                    return ""
                end
                return tostring(v)
            end)
        )
    end

    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_Turn.lua")

    HandlerStack._reset()
    SpeechPipeline._reset()

    spoken = {}
    SpeechPipeline._speakAction = function(text, interrupt)
        spoken[#spoken + 1] = { text = text, interrupt = interrupt }
    end

    loggedWarnings = {}
    Log.warn = function(msg)
        loggedWarnings[#loggedWarnings + 1] = msg
    end

    doControlCalls = {}
    activateNotificationCalls = {}
    selectedUnits = {}
    lookAtPlots = {}
    sendUnreadyCalls = 0
    sendUnreadyResult = true
    startListeners = {}
    endListeners = {}

    Game.DoControl = function(id)
        doControlCalls[#doControlCalls + 1] = id
    end
    Game.GetActivePlayer = function()
        return 0
    end
    Game.IsProcessingMessages = function()
        return false
    end
    Game.GetGameTurn = function()
        return 0
    end
    Game.GetGameTurnYear = function()
        return 0
    end

    UI.ActivateNotification = function(idx)
        activateNotificationCalls[#activateNotificationCalls + 1] = idx
    end
    UI.SelectUnit = function(u)
        selectedUnits[#selectedUnits + 1] = u
    end
    UI.LookAt = function(plot, _flag)
        lookAtPlots[#lookAtPlots + 1] = plot
    end

    GameInfoTypes.CONTROL_ENDTURN = 101
    GameInfoTypes.CONTROL_FORCEENDTURN = 102

    PreGame = PreGame or {}
    PreGame.IsMultiplayerGame = function()
        return false
    end

    Network = Network or {}
    Network.HasSentNetTurnComplete = function()
        return false
    end
    Network.SendTurnUnready = function()
        sendUnreadyCalls = sendUnreadyCalls + 1
        return sendUnreadyResult
    end

    Events.ActivePlayerTurnStart = {
        Add = function(fn)
            startListeners[#startListeners + 1] = fn
        end,
    }
    Events.ActivePlayerTurnEnd = {
        Add = function(fn)
            endListeners[#endListeners + 1] = fn
        end,
    }

    activePlayer = {
        _turnActive = true,
        IsTurnActive = function(self)
            return self._turnActive
        end,
        GetEndTurnBlockingType = function()
            return EndTurnBlockingTypes.NO_ENDTURN_BLOCKING_TYPE
        end,
        GetEndTurnBlockingNotificationIndex = function()
            return 7
        end,
        GetNumNotifications = function()
            return 0
        end,
        GetNotificationIndex = function(_, _)
            return -1
        end,
        GetNotificationSummaryStr = function(_, _)
            return ""
        end,
        GetFirstReadyUnit = function()
            return nil
        end,
        Units = function()
            return function()
                return nil
            end
        end,
    }
    Players[0] = activePlayer
end

-- Turn-start listener --------------------------------------------------

function M.test_turn_start_announces_turn_and_ad_year()
    -- Queued (not interrupt) so any burst-collapsed notification that
    -- NotificationAnnounce fired synchronously just before the engine
    -- dispatched ActivePlayerTurnStart finishes before the turn line.
    setup()
    Turn.installListeners()
    Game.GetGameTurn = function()
        return 42
    end
    Game.GetGameTurnYear = function()
        return 1950
    end
    startListeners[1]()
    T.eq(#spoken, 1)
    T.eq(spoken[1].text, "Turn: 42, 1950 AD")
    T.eq(spoken[1].interrupt, false)
end

function M.test_turn_start_announces_bc_year_with_absolute_value()
    -- Engine returns negative years for BC; the listener flips sign before
    -- substituting into TXT_KEY_TIME_BC so the user hears "4000 BC" not
    -- "-4000 BC".
    setup()
    Turn.installListeners()
    Game.GetGameTurn = function()
        return 0
    end
    Game.GetGameTurnYear = function()
        return -4000
    end
    startListeners[1]()
    T.eq(spoken[1].text, "Turn: 0, 4000 BC")
end

function M.test_turn_end_announces_turn_ended()
    -- Interrupt is correct here: end-turn is user-initiated (or engine
    -- auto-end), no pending notification speech to protect.
    setup()
    Turn.installListeners()
    endListeners[1]()
    T.eq(spoken[1].text, "Turn ended")
    T.eq(spoken[1].interrupt, true)
end

-- endTurnDispatch -------------------------------------------------------

function M.test_dispatch_no_blocker_calls_do_control_end_turn()
    setup()
    Turn._endTurnDispatch()
    T.eq(#doControlCalls, 1)
    T.eq(doControlCalls[1], GameInfoTypes.CONTROL_ENDTURN)
    -- No announcement from the dispatcher; ActivePlayerTurnEnd listener
    -- says "Turn ended" when the engine confirms.
    T.eq(#spoken, 0)
end

function M.test_dispatch_early_returns_when_turn_not_active()
    setup()
    activePlayer._turnActive = false
    Turn._endTurnDispatch()
    T.eq(#doControlCalls, 0)
    T.eq(#spoken, 0)
end

function M.test_dispatch_early_returns_when_processing_messages()
    -- IsProcessingMessages guards against firing mid-burst. Matches the
    -- base game's OnEndTurnClicked to avoid desync.
    setup()
    Game.IsProcessingMessages = function()
        return true
    end
    Turn._endTurnDispatch()
    T.eq(#doControlCalls, 0)
end

function M.test_dispatch_screen_blocker_announces_and_activates_notification()
    setup()
    activePlayer.GetEndTurnBlockingType = function()
        return EndTurnBlockingTypes.ENDTURN_BLOCKING_RESEARCH
    end
    Turn._endTurnDispatch()
    T.eq(spoken[1].text, "Choose Research")
    T.eq(#activateNotificationCalls, 1)
    T.eq(activateNotificationCalls[1], 7)
    T.eq(#doControlCalls, 0)
end

function M.test_dispatch_free_items_blocker_reads_dynamic_notification_summary()
    -- FREE_ITEMS has no fixed TXT_KEY; the label is the active notification's
    -- summary string, located by matching the blocking index against the
    -- player's notification list.
    setup()
    activePlayer.GetEndTurnBlockingType = function()
        return EndTurnBlockingTypes.ENDTURN_BLOCKING_FREE_ITEMS
    end
    activePlayer.GetEndTurnBlockingNotificationIndex = function()
        return 42
    end
    activePlayer.GetNumNotifications = function()
        return 2
    end
    activePlayer.GetNotificationIndex = function(_, i)
        if i == 0 then
            return 7
        end
        return 42
    end
    activePlayer.GetNotificationSummaryStr = function(_, i)
        if i == 0 then
            return "unrelated"
        end
        return "Free Great Prophet!"
    end
    Turn._endTurnDispatch()
    T.eq(spoken[1].text, "Free Great Prophet!")
    T.eq(#activateNotificationCalls, 1)
end

function M.test_dispatch_unit_blocker_selects_first_ready_unit_and_centers()
    setup()
    activePlayer.GetEndTurnBlockingType = function()
        return EndTurnBlockingTypes.ENDTURN_BLOCKING_UNITS
    end
    local plot = { id = "p1" }
    local unit = {
        GetPlot = function()
            return plot
        end,
    }
    activePlayer.GetFirstReadyUnit = function()
        return unit
    end
    Turn._endTurnDispatch()
    T.eq(spoken[1].text, "Unit Needs Orders")
    T.eq(#selectedUnits, 1)
    T.eq(selectedUnits[1], unit)
    T.eq(#lookAtPlots, 1)
    T.eq(lookAtPlots[1], plot)
    T.eq(#activateNotificationCalls, 0)
end

function M.test_dispatch_promotion_blocker_iterates_for_ready_unit()
    -- UNIT_PROMOTION uses its own predicate (IsPromotionReady) rather than
    -- GetFirstReadyUnit; iterates the player's units to find the first
    -- one that's actually eligible for promotion.
    setup()
    activePlayer.GetEndTurnBlockingType = function()
        return EndTurnBlockingTypes.ENDTURN_BLOCKING_UNIT_PROMOTION
    end
    local plot = { id = "plotPromo" }
    local notReady = {
        IsPromotionReady = function()
            return false
        end,
        GetPlot = function()
            return plot
        end,
    }
    local ready = {
        IsPromotionReady = function()
            return true
        end,
        GetPlot = function()
            return plot
        end,
    }
    local seq = { notReady, ready }
    activePlayer.Units = function()
        local i = 0
        return function()
            i = i + 1
            return seq[i]
        end
    end
    Turn._endTurnDispatch()
    T.eq(spoken[1].text, "Unit Promotion Available")
    T.eq(selectedUnits[1], ready)
end

function M.test_dispatch_mp_already_submitted_unreadies_and_announces_waiting()
    -- After the player has already sent the network turn-complete message,
    -- pressing Ctrl+Space un-readies them so they aren't stuck spectating.
    -- Announcement is gated on SendTurnUnready success so a rejection
    -- doesn't mislead the user.
    setup()
    PreGame.IsMultiplayerGame = function()
        return true
    end
    Network.HasSentNetTurnComplete = function()
        return true
    end
    Turn._endTurnDispatch()
    T.eq(spoken[1].text, "Waiting for players")
    T.eq(sendUnreadyCalls, 1)
    T.eq(#doControlCalls, 0)
end

function M.test_dispatch_mp_unready_refused_logs_warning_and_stays_silent()
    -- SendTurnUnready can be rejected server-side (turn already committed,
    -- grace period expired). Matching the "no silent failures" rule: log
    -- the refusal instead of announcing a state transition that didn't
    -- happen.
    setup()
    PreGame.IsMultiplayerGame = function()
        return true
    end
    Network.HasSentNetTurnComplete = function()
        return true
    end
    sendUnreadyResult = false
    Turn._endTurnDispatch()
    T.eq(#spoken, 0)
    T.eq(sendUnreadyCalls, 1)
    T.truthy(#loggedWarnings > 0, "expected warn on refused un-ready")
end

-- forceEndTurn ----------------------------------------------------------

function M.test_force_end_turn_with_no_blocker_calls_do_control_force()
    setup()
    Turn._forceEndTurn()
    T.eq(#doControlCalls, 1)
    T.eq(doControlCalls[1], GameInfoTypes.CONTROL_FORCEENDTURN)
    T.eq(#spoken, 0)
end

function M.test_force_end_turn_with_units_blocker_calls_do_control_force()
    -- ENDTURN_BLOCKING_UNITS is the one blocker the engine will force past
    -- (CvGame.cpp:3712 gates on NONE or UNITS). Ctrl+Shift+Space here
    -- skips the announce-and-select-unit path Ctrl+Space would run, and
    -- actually ends the turn.
    setup()
    activePlayer.GetEndTurnBlockingType = function()
        return EndTurnBlockingTypes.ENDTURN_BLOCKING_UNITS
    end
    Turn._forceEndTurn()
    T.eq(doControlCalls[1], GameInfoTypes.CONTROL_FORCEENDTURN)
    T.eq(#activateNotificationCalls, 0)
    T.eq(#selectedUnits, 0)
    T.eq(#spoken, 0)
end

function M.test_force_end_turn_with_screen_blocker_falls_through_to_announce()
    -- The engine's CONTROL_FORCEENDTURN is a silent no-op for any blocker
    -- other than NONE or UNITS, so we match its semantics: read the
    -- blocker, announce it, open the notification screen, skip DoControl.
    setup()
    activePlayer.GetEndTurnBlockingType = function()
        return EndTurnBlockingTypes.ENDTURN_BLOCKING_RESEARCH
    end
    Turn._forceEndTurn()
    T.eq(spoken[1].text, "Choose Research")
    T.eq(activateNotificationCalls[1], 7)
    T.eq(#doControlCalls, 0)
end

function M.test_force_end_turn_with_stacked_units_blocker_selects_unit()
    -- STACKED_UNITS is a unit-type blocker the engine refuses to force
    -- past (only UNITS is bypassable), so force falls through to the
    -- same select-first-ready path Ctrl+Space runs.
    setup()
    activePlayer.GetEndTurnBlockingType = function()
        return EndTurnBlockingTypes.ENDTURN_BLOCKING_STACKED_UNITS
    end
    local plot = { id = "pStack" }
    local unit = {
        GetPlot = function()
            return plot
        end,
    }
    activePlayer.GetFirstReadyUnit = function()
        return unit
    end
    Turn._forceEndTurn()
    T.eq(spoken[1].text, "Move Stacked Unit")
    T.eq(selectedUnits[1], unit)
    T.eq(#doControlCalls, 0)
end

function M.test_force_end_turn_mp_already_submitted_unreadies()
    -- Same un-ready path as Ctrl+Space. A player who force-submitted early
    -- still needs a way out, and the engine's CONTROL_FORCEENDTURN doesn't
    -- touch network state anyway.
    setup()
    PreGame.IsMultiplayerGame = function()
        return true
    end
    Network.HasSentNetTurnComplete = function()
        return true
    end
    Turn._forceEndTurn()
    T.eq(spoken[1].text, "Waiting for players")
    T.eq(sendUnreadyCalls, 1)
    T.eq(#doControlCalls, 0)
end

function M.test_force_end_turn_respects_is_processing_messages()
    setup()
    Game.IsProcessingMessages = function()
        return true
    end
    Turn._forceEndTurn()
    T.eq(#doControlCalls, 0)
end

-- Bindings surface ------------------------------------------------------

local function findBinding(bindings, key, mods)
    for _, b in ipairs(bindings) do
        if b.key == key and (b.mods or 0) == mods then
            return b
        end
    end
end

function M.test_bindings_expose_ctrl_space_and_ctrl_shift_space()
    setup()
    local MOD_CTRL = 2
    local MOD_CTRL_SHIFT = 3
    local b = Turn.getBindings()
    T.truthy(findBinding(b.bindings, Keys.VK_SPACE, MOD_CTRL), "Ctrl+Space registered")
    T.truthy(findBinding(b.bindings, Keys.VK_SPACE, MOD_CTRL_SHIFT), "Ctrl+Shift+Space registered")
    T.eq(#b.helpEntries, 2)
end

return M
