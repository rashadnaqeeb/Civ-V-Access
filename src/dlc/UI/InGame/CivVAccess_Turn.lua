-- Turn lifecycle announcements and the player's end-turn keybindings.
--
-- ActivePlayerTurnStart → "Turn N, year". Fires on every turn start and on
-- the first turn after LoadScreenClose; no special-casing needed because
-- the first-turn announcement reads correctly as "game started at turn 0,
-- 4000 BC" on its own.
--
-- ActivePlayerTurnEnd → "Turn ended". Covers our Ctrl+Space path plus any
-- engine-internal auto-end (the "Auto End Turn" option, force-end via
-- CONTROL_FORCEENDTURN, the engine's own safety paths).
--
-- Ctrl+Space dispatches the same branches the base EndTurn button callback
-- runs (`ActionInfoPanel.lua:OnEndTurnClicked`): read
-- GetEndTurnBlockingType; on a blocker, announce the matching TXT_KEY and
-- delegate to the engine's "take me to the blocker" action (ActivateNotif-
-- ication for screen blockers, SelectUnit+LookAt for unit blockers); on no
-- blocker, DoControl(CONTROL_ENDTURN) and let the ActivePlayerTurnEnd
-- listener say "Turn ended" when the engine confirms.
--
-- Ctrl+Shift+Space mirrors the engine's Shift+Return. The engine's own
-- CONTROL_FORCEENDTURN handler (CvGame.cpp:3712 in Community-Patch-DLL)
-- only ends the turn when the blocker is NO_ENDTURN_BLOCKING_TYPE or
-- ENDTURN_BLOCKING_UNITS; any other blocker makes DoControl a silent
-- no-op. We read the blocker in Lua first and, for the bypassable cases,
-- call DoControl; otherwise we fall through to the same announce-and-open
-- path as Ctrl+Space so the user hears what's in the way and gets taken
-- to it, instead of getting silence.
--
-- Multiplayer feedback: in networked MP, Events.ActivePlayerTurnEnd does
-- not fire on submit -- it fires when the wave actually completes -- so
-- the submit-time speech has to come from the dispatcher itself, right
-- after a successful DoControl(CONTROL_ENDTURN/FORCEENDTURN). The line is
-- "Waiting for players", matching the engine's own button relabel.
--
-- Multiplayer un-ready: if the player already submitted (HasSentNetTurn-
-- Complete) pressing Ctrl+Space un-readies them, matching base behavior --
-- otherwise a player who submitted early would be stuck spectating with no
-- keyboard escape. Announces "End turn canceled" because the post-state
-- after a successful un-ready is "back in active play"; the prior
-- "Waiting for players" line described the state the user just left,
-- which read as the inverse of what just happened.

Turn = {}

local MOD_SHIFT = 1
local MOD_CTRL = 2
local MOD_CTRL_SHIFT = MOD_CTRL + MOD_SHIFT

-- Blocker → base-game TXT_KEY lookup. Keys are the strings the end-turn
-- button displays for each blocker in ActionInfoPanel.lua:OnEndTurnDirty;
-- reusing them keeps the spoken label identical to what a sighted player
-- reads off the button. FREE_ITEMS has no fixed key -- the label is the
-- notification's own summary string, resolved dynamically. MINOR_QUEST
-- is intentionally absent: BNW's ActionInfoPanel.lua (the sole skin we
-- ship against) doesn't handle it either, which suggests the BNW engine
-- doesn't emit it as a blocker. A nil lookup here falls through to the
-- notification-activate path, matching base behavior for any unexpected
-- blocker the table doesn't cover.
local BLOCKER_TXT_KEY = {
    [EndTurnBlockingTypes.ENDTURN_BLOCKING_POLICY] = "TXT_KEY_CHOOSE_POLICY",
    [EndTurnBlockingTypes.ENDTURN_BLOCKING_FREE_POLICY] = "TXT_KEY_CHOOSE_POLICY",
    [EndTurnBlockingTypes.ENDTURN_BLOCKING_RESEARCH] = "TXT_KEY_CHOOSE_RESEARCH",
    [EndTurnBlockingTypes.ENDTURN_BLOCKING_FREE_TECH] = "TXT_KEY_CHOOSE_FREE_TECH",
    [EndTurnBlockingTypes.ENDTURN_BLOCKING_PRODUCTION] = "TXT_KEY_CHOOSE_PRODUCTION",
    [EndTurnBlockingTypes.ENDTURN_BLOCKING_UNITS] = "TXT_KEY_UNIT_NEEDS_ORDERS",
    [EndTurnBlockingTypes.ENDTURN_BLOCKING_STACKED_UNITS] = "TXT_KEY_MOVE_STACKED_UNIT",
    [EndTurnBlockingTypes.ENDTURN_BLOCKING_UNIT_NEEDS_ORDERS] = "TXT_KEY_UNIT_NEEDS_ORDERS",
    [EndTurnBlockingTypes.ENDTURN_BLOCKING_UNIT_PROMOTION] = "TXT_KEY_UNIT_PROMOTION",
    [EndTurnBlockingTypes.ENDTURN_BLOCKING_CITY_RANGE_ATTACK] = "TXT_KEY_CITY_RANGE_ATTACK",
    [EndTurnBlockingTypes.ENDTURN_BLOCKING_DIPLO_VOTE] = "TXT_KEY_DIPLO_VOTE",
    [EndTurnBlockingTypes.ENDTURN_BLOCKING_FOUND_PANTHEON] = "TXT_KEY_NOTIFICATION_SUMMARY_ENOUGH_FAITH_FOR_PANTHEON",
    [EndTurnBlockingTypes.ENDTURN_BLOCKING_FOUND_RELIGION] = "TXT_KEY_NOTIFICATION_SUMMARY_FOUND_RELIGION",
    [EndTurnBlockingTypes.ENDTURN_BLOCKING_ENHANCE_RELIGION] = "TXT_KEY_NOTIFICATION_SUMMARY_ENHANCE_RELIGION",
    [EndTurnBlockingTypes.ENDTURN_BLOCKING_ADD_REFORMATION_BELIEF] = "TXT_KEY_NOTIFICATION_SUMMARY_ADD_REFORMATION_BELIEF",
    [EndTurnBlockingTypes.ENDTURN_BLOCKING_CHOOSE_ARCHAEOLOGY] = "TXT_KEY_NOTIFICATION_SUMMARY_CHOOSE_ARCHAEOLOGY",
    [EndTurnBlockingTypes.ENDTURN_BLOCKING_STEAL_TECH] = "TXT_KEY_NOTIFICATION_SPY_STEAL_BLOCKING",
    [EndTurnBlockingTypes.ENDTURN_BLOCKING_MAYA_LONG_COUNT] = "TXT_KEY_NOTIFICATION_MAYA_LONG_COUNT",
    [EndTurnBlockingTypes.ENDTURN_BLOCKING_FAITH_GREAT_PERSON] = "TXT_KEY_NOTIFICATION_FAITH_GREAT_PERSON",
    [EndTurnBlockingTypes.ENDTURN_BLOCKING_LEAGUE_CALL_FOR_PROPOSALS] = "TXT_KEY_NOTIFICATION_LEAGUE_PROPOSALS_NEEDED",
    [EndTurnBlockingTypes.ENDTURN_BLOCKING_LEAGUE_CALL_FOR_VOTES] = "TXT_KEY_NOTIFICATION_LEAGUE_VOTES_NEEDED",
    [EndTurnBlockingTypes.ENDTURN_BLOCKING_CHOOSE_IDEOLOGY] = "TXT_KEY_NOTIFICATION_SUMMARY_CHOOSE_IDEOLOGY",
}

-- Unit-class blockers. These drive the engine's "find a ready unit, select,
-- center camera" branch rather than the ActivateNotification screen-opener.
-- UNIT_PROMOTION isn't in this set because it uses a different readiness
-- predicate (IsPromotionReady) and is checked separately.
local UNIT_BLOCKERS = {
    [EndTurnBlockingTypes.ENDTURN_BLOCKING_UNITS] = true,
    [EndTurnBlockingTypes.ENDTURN_BLOCKING_STACKED_UNITS] = true,
    [EndTurnBlockingTypes.ENDTURN_BLOCKING_UNIT_NEEDS_ORDERS] = true,
}

local function speak(text)
    if text == nil or text == "" then
        return
    end
    SpeechPipeline.speakInterrupt(text)
end

local function blockerText(player, blockerType)
    if blockerType == EndTurnBlockingTypes.ENDTURN_BLOCKING_FREE_ITEMS then
        local idx = player:GetEndTurnBlockingNotificationIndex()
        local num = player:GetNumNotifications()
        for i = 0, num - 1 do
            if player:GetNotificationIndex(i) == idx then
                return player:GetNotificationSummaryStr(i)
            end
        end
        return nil
    end
    local key = BLOCKER_TXT_KEY[blockerType]
    if key == nil then
        return nil
    end
    return Text.key(key)
end

-- Mirrors ActionInfoPanel.lua:141-161. UNIT_PROMOTION iterates looking for
-- an IsPromotionReady unit; the other unit blockers use the player-level
-- GetFirstReadyUnit helper.
local function focusBlockerUnit(player, blockerType)
    if blockerType == EndTurnBlockingTypes.ENDTURN_BLOCKING_UNIT_PROMOTION then
        for v in player:Units() do
            if v:IsPromotionReady() then
                local plot = v:GetPlot()
                UI.LookAt(plot, 0)
                UI.SelectUnit(v)
                return
            end
        end
        return
    end
    local unit = player:GetFirstReadyUnit()
    if unit ~= nil then
        local plot = unit:GetPlot()
        UI.LookAt(plot, 0)
        UI.SelectUnit(unit)
    end
end

-- Announce the blocker label and run the engine's take-me-to-the-blocker
-- action. Shared between Ctrl+Space (always on a blocker) and Ctrl+Shift+
-- Space (when the blocker isn't one the engine will force past).
local function announceAndOpenBlocker(player, blockerType)
    speak(blockerText(player, blockerType))
    if UNIT_BLOCKERS[blockerType] or blockerType == EndTurnBlockingTypes.ENDTURN_BLOCKING_UNIT_PROMOTION then
        focusBlockerUnit(player, blockerType)
    else
        UI.ActivateNotification(player:GetEndTurnBlockingNotificationIndex())
    end
end

-- Early-return gates shared by both key paths. Returns true when the
-- dispatcher should proceed, false when something upstream (turn inactive,
-- message burst, MP already-submitted) handled it.
local function passEndTurnGates(player)
    if not player:IsTurnActive() then
        return false
    end
    if Game.IsProcessingMessages() then
        return false
    end
    if PreGame.IsMultiplayerGame() and Network.HasSentNetTurnComplete() then
        if Network.SendTurnUnready() then
            speak(Text.key("TXT_KEY_CIVVACCESS_END_TURN_CANCELED"))
        else
            -- Server rejected the un-ready (e.g. turn already committed,
            -- host ended the grace period). Silent success would have the
            -- user thinking they pulled back when they didn't.
            Log.warn("Turn: SendTurnUnready refused; player remains submitted")
        end
        return false
    end
    return true
end

-- Networked-MP submit-time speech. ActivePlayerTurnEnd fires only at
-- wave completion in network MP, so without this the user gets silence
-- between pressing end-turn and the wave finishing (could be minutes).
-- Skips hotseat: there's no waiting -- hotseat hands off via PlayerChange.
local function announceSubmitted()
    if Game:IsNetworkMultiPlayer() then
        speak(Text.key("TXT_KEY_WAITING_FOR_PLAYERS"))
    end
end

local function endTurnDispatch()
    local player = Players[Game.GetActivePlayer()]
    if not passEndTurnGates(player) then
        return
    end
    local blockerType = player:GetEndTurnBlockingType()
    if blockerType == EndTurnBlockingTypes.NO_ENDTURN_BLOCKING_TYPE then
        Game.DoControl(GameInfoTypes.CONTROL_ENDTURN)
        announceSubmitted()
        return
    end
    announceAndOpenBlocker(player, blockerType)
end

local function forceEndTurn()
    local player = Players[Game.GetActivePlayer()]
    if not passEndTurnGates(player) then
        return
    end
    local blockerType = player:GetEndTurnBlockingType()
    -- Engine's CONTROL_FORCEENDTURN (CvGame.cpp:3712) only ends the turn
    -- when the blocker is NONE or UNITS. Calling DoControl on any other
    -- blocker is a silent no-op, so we read first and fall back to the
    -- regular announce-and-open path when we know force wouldn't help.
    if
        blockerType == EndTurnBlockingTypes.NO_ENDTURN_BLOCKING_TYPE
        or blockerType == EndTurnBlockingTypes.ENDTURN_BLOCKING_UNITS
    then
        Game.DoControl(GameInfoTypes.CONTROL_FORCEENDTURN)
        announceSubmitted()
        return
    end
    announceAndOpenBlocker(player, blockerType)
end

local function onActivePlayerTurnStart()
    local turn = Text.format("TXT_KEY_TP_TURN_COUNTER", Game.GetGameTurn())
    local year = Game.GetGameTurnYear()
    local dateKey
    if year < 0 then
        dateKey = "TXT_KEY_TIME_BC"
    else
        dateKey = "TXT_KEY_TIME_AD"
    end
    local date = Text.format(dateKey, math.abs(year))
    -- Queued so the turn line lands behind any popup speech that fires at
    -- turn-start (production blocker, tech choice, etc). NotificationAnnounce
    -- holds its own queue for ~0.5s past ActivePlayerTurnStart, so any
    -- inter-turn notifications come in after the turn line.
    SpeechPipeline.speakQueued(Text.format("TXT_KEY_CIVVACCESS_TURN_START", turn, date))
end

local function onActivePlayerTurnEnd()
    SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_TURN_ENDED"))
end

local bind = HandlerStack.bind

function Turn.getBindings()
    local bindings = {
        bind(Keys.VK_SPACE, MOD_CTRL, endTurnDispatch, "End turn"),
        bind(Keys.VK_SPACE, MOD_CTRL_SHIFT, forceEndTurn, "Force end turn"),
    }
    local helpEntries = {
        {
            keyLabel = "TXT_KEY_CIVVACCESS_TURN_HELP_KEY_END",
            description = "TXT_KEY_CIVVACCESS_TURN_HELP_DESC_END",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_TURN_HELP_KEY_FORCE",
            description = "TXT_KEY_CIVVACCESS_TURN_HELP_DESC_FORCE",
        },
    }
    return { bindings = bindings, helpEntries = helpEntries }
end

-- Registers a fresh pair of turn listeners on every call (onInGameBoot
-- invokes this once per game load). See CivVAccess_Boot.lua's
-- LoadScreenClose registration for the rationale: load-game-from-game
-- kills the prior Context's env, stranding listeners that referenced its
-- globals.
function Turn.installListeners()
    if Events == nil then
        Log.error("Turn.installListeners: Events table missing")
        return
    end
    if Events.ActivePlayerTurnStart ~= nil then
        Events.ActivePlayerTurnStart.Add(onActivePlayerTurnStart)
    else
        Log.warn("Turn: Events.ActivePlayerTurnStart missing")
    end
    if Events.ActivePlayerTurnEnd ~= nil then
        Events.ActivePlayerTurnEnd.Add(onActivePlayerTurnEnd)
    else
        Log.warn("Turn: Events.ActivePlayerTurnEnd missing")
    end
end

-- Test seams. Listener tests reach the handlers through the Events.Add
-- capture pattern installed by installListeners, so the listener
-- functions don't need to be exposed here; dispatch seams do.
Turn._endTurnDispatch = endTurnDispatch
Turn._forceEndTurn = forceEndTurn
