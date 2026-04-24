-- Target-mode handler. Pushed above the baseline stack when the action
-- menu commits a targeted action (attack, range strike, move-to, etc.).
-- The actor is the selected unit; the cursor is the target. Space speaks
-- a per-mode trial preview; Enter commits; Esc cancels; Tab reopens the
-- action menu to switch verb.
--
-- capturesAllInput = false: cursor movement (QAZEDC), cursor info queries
-- (S/W/X/1/2/3 and the Shift-letter surveyor cluster), and scanner cycling
-- fall through to Baseline / Scanner unchanged. Only keys whose target-
-- mode behavior must differ from Baseline are bound here. Alt+QAZEDC is
-- bound as a no-op: Baseline's Alt+QAZEDC direct-move would move the
-- actor while the engine is in an attack / move interface mode, so we
-- swallow it.
--
-- Unit cycling (. / ,) is not bound here either -- `,` falls through to
-- Baseline's UnitControl.cycleAll and `.` falls through to the engine's
-- native next-unit binding. Either path fires UnitSelectionChanged on
-- the new unit; UnitControl's listener pops this handler when the
-- selection moves to a different unit, which also covers mouse reselect
-- and actor death.
--
-- Preview math clones base-game EnemyUnitPanel.lua:655-707 (bidirectional
-- GetCombatDamage for melee, GetRangeCombatDamage for ranged). The move-
-- to preview runs Pathfinder.findPath and speaks MP cost + turn count.

UnitTargetMode = {}

local MOD_NONE = 0
local MOD_ALT = 4

-- Tracks the actor's unit ID while this handler is on the stack.
-- Exposed via UnitTargetMode.currentActorID so UnitControl's selection-
-- changed listener can tell whether a selection event reflects a cycle
-- away from the actor (pop target mode) vs. a re-select of the same unit.
local _currentActorID = nil

function UnitTargetMode.currentActorID()
    return _currentActorID
end

local function restoreSelection()
    UI.SetInterfaceMode(InterfaceModeTypes.INTERFACEMODE_SELECTION)
end

local function speakInterrupt(text)
    if text == nil or text == "" then
        return
    end
    SpeechPipeline.speakInterrupt(text)
end

local function cursorPlot()
    local cx, cy = Cursor.position()
    if cx == nil then
        return nil
    end
    return Map.GetPlot(cx, cy), cx, cy
end

-- Format a 60ths MP value as the engine does: integer when whole,
-- one decimal when fractional. Road/railroad costs (e.g. 20/60 MP)
-- need the decimal; plain terrain (60/60, 120/60) reads cleaner as
-- "1" / "2" than "1.0" / "2.0".
local function formatMP(mp60ths)
    local whole = mp60ths / 60
    local rounded = math.floor(whole * 10 + 0.5) / 10
    if rounded == math.floor(rounded) then
        return tostring(math.floor(rounded))
    end
    return string.format("%.1f", rounded)
end

local function movePathPreview(actor, targetPlot)
    local result, reason = Pathfinder.findPath(actor, targetPlot)
    if result == nil then
        if reason == "same_plot" then
            return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY")
        end
        if reason == "unexplored" then
            return Text.key("TXT_KEY_CIVVACCESS_UNEXPLORED")
        end
        if reason == "too_far" then
            return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_TOO_FAR")
        end
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_UNREACHABLE")
    end
    local mpText = formatMP(result.mpCost)
    local leftText = formatMP(result.mpRemaining or 0)
    if result.turns <= 1 then
        return Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_THIS_TURN", mpText, leftText)
    end
    return Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOVE_PATH_MULTI_TURN", mpText, result.turns, leftText)
end

local function rangedPreview(actor, defender, targetPlot, targetX, targetY)
    if not actor:CanRangeStrikeAt(targetX, targetY, true, true) then
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_OUT_OF_RANGE")
    end
    return UnitSpeech.rangedPreview(actor, defender, targetPlot)
end

local function firstEnemyUnit(plot)
    if plot == nil then
        return nil
    end
    local team = Game.GetActiveTeam()
    local isDebug = Game.IsDebugMode()
    for i = 0, plot:GetNumUnits() - 1 do
        local u = plot:GetUnit(i)
        if u ~= nil and not u:IsInvisible(team, isDebug) and u:GetOwner() ~= Game.GetActivePlayer() then
            return u
        end
    end
    return nil
end

local function isRangeAttackMode(mode)
    return mode == InterfaceModeTypes.INTERFACEMODE_RANGE_ATTACK or mode == InterfaceModeTypes.INTERFACEMODE_AIRSTRIKE
end

local function isMeleeAttackMode(mode)
    return mode == InterfaceModeTypes.INTERFACEMODE_ATTACK
end

local function isMoveMode(mode)
    return mode == InterfaceModeTypes.INTERFACEMODE_MOVE_TO
        or mode == InterfaceModeTypes.INTERFACEMODE_MOVE_TO_TYPE
        or mode == InterfaceModeTypes.INTERFACEMODE_MOVE_TO_ALL
end

local function buildPreview(self)
    local plot, tx, ty = cursorPlot()
    if plot == nil then
        return ""
    end
    local mode = self._mode
    local actor = self._actor
    local parts = {}
    if isRangeAttackMode(mode) then
        local defender = firstEnemyUnit(plot)
        if defender == nil then
            parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY")
        else
            parts[#parts + 1] = rangedPreview(actor, defender, plot, tx, ty)
        end
        local rivalTeam = actor:GetDeclareWarRangeStrike(plot)
        if rivalTeam ~= -1 then
            parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_UNIT_WILL_DECLARE_WAR")
        end
    elseif isMeleeAttackMode(mode) then
        local defender = firstEnemyUnit(plot)
        if defender == nil then
            parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY")
        else
            local text = UnitSpeech.meleePreview(actor, defender, plot)
            if text == "" then
                parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY")
            else
                parts[#parts + 1] = text
            end
        end
    elseif isMoveMode(mode) then
        -- War-declaration on move is surfaced by the engine's popup at
        -- commit time (routed through GenericPopupAccess), so no pre-
        -- commit detection here. Pathfinder reports MP cost and turn
        -- count; same-plot cursor falls through to EMPTY as before.
        parts[#parts + 1] = movePathPreview(actor, plot)
    else
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_EMPTY")
    end
    return table.concat(parts, ", ")
end

-- Generic "commit current interface mode at cursor plot" path. Mirrors
-- base WorldView.lua:364-382 (missionTypeLButtonUpHandler): look up the
-- mode's backing mission id, check CanDoInterfaceMode, fire the network
-- message, and drop back to selection mode. Range-attack war-declare
-- popups come through the engine's own ButtonPopupTypes.BUTTONPOPUP_*
-- dispatch and are handled by GenericPopupAccess, not here.
local function commitAtCursor(self)
    local plot, tx, ty = cursorPlot()
    if plot == nil then
        SpeechPipeline.speakQueued(Text.key("TXT_KEY_CIVVACCESS_UNIT_ACTION_FAILED"))
        return
    end
    local mode = UI.GetInterfaceMode()
    local modeRow = GameInfo.InterfaceModes[mode]
    if modeRow == nil then
        Log.error("UnitTargetMode.commit: no InterfaceModes row for mode " .. tostring(mode))
        return
    end
    local mission = GameInfoTypes[modeRow.Mission]
    if mission == nil or mission == MissionTypes.NO_MISSION then
        Log.warn("UnitTargetMode.commit: interface mode has no backing mission; popping without commit")
        HandlerStack.removeByName("UnitTargetMode", false)
        restoreSelection()
        return
    end
    if not UI.CanDoInterfaceMode(mode) then
        SpeechPipeline.speakQueued(Text.key("TXT_KEY_CIVVACCESS_UNIT_ACTION_FAILED"))
        HandlerStack.removeByName("UnitTargetMode", false)
        restoreSelection()
        return
    end
    UnitControl.registerPending(self._actor, tx, ty)
    Game.SelectionListGameNetMessage(GameMessageTypes.GAMEMESSAGE_PUSH_MISSION, mission, tx, ty, 0, false, false)
    HandlerStack.removeByName("UnitTargetMode", false)
    restoreSelection()
end

local bind = HandlerStack.bind

-- Push target-mode handler. `actor` is the unit the action is being
-- committed against; `iAction` is the hash that entered this mode (kept
-- for logging / future verb-display use); `mode` is the engine interface
-- mode the menu commit just set (so we don't re-read UI.GetInterfaceMode
-- and race the engine's own transitions).
function UnitTargetMode.enter(actor, iAction, mode)
    if actor == nil then
        Log.warn("UnitTargetMode.enter: nil actor; aborting")
        return
    end
    local self = {
        name = "UnitTargetMode",
        capturesAllInput = false,
        _actor = actor,
        _iAction = iAction,
        _mode = mode,
    }
    local noop = function() end
    self.bindings = {
        bind(Keys.VK_SPACE, MOD_NONE, function()
            speakInterrupt(buildPreview(self))
        end, "Target preview"),
        bind(Keys.VK_RETURN, MOD_NONE, function()
            commitAtCursor(self)
        end, "Commit target"),
        bind(Keys.VK_ESCAPE, MOD_NONE, function()
            HandlerStack.removeByName("UnitTargetMode", false)
            restoreSelection()
            speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_CANCELED"))
        end, "Cancel target mode"),
        bind(Keys.VK_TAB, MOD_NONE, function()
            HandlerStack.removeByName("UnitTargetMode", false)
            restoreSelection()
            UnitActionMenu.open(actor)
        end, "Switch verb"),
        -- Alt+QAZEDC no-ops: Baseline binds these to direct-move, which
        -- would move the actor while an attack / move interface mode is
        -- live. Bind here so InputRouter matches and returns before the
        -- key falls through.
        bind(Keys.Q, MOD_ALT, noop, "Block direct-move NW"),
        bind(Keys.E, MOD_ALT, noop, "Block direct-move NE"),
        bind(Keys.A, MOD_ALT, noop, "Block direct-move W"),
        bind(Keys.D, MOD_ALT, noop, "Block direct-move E"),
        bind(Keys.Z, MOD_ALT, noop, "Block direct-move SW"),
        bind(Keys.C, MOD_ALT, noop, "Block direct-move SE"),
    }
    self.helpEntries = {}
    -- onDeactivate always restores the selection mode. Belt-and-
    -- suspenders: every binding that pops also calls restoreSelection,
    -- but an external popAbove / popByName could still unwind us.
    self.onDeactivate = function()
        _currentActorID = nil
        restoreSelection()
    end
    self.onActivate = function()
        speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_UNIT_TARGET_MODE"))
    end
    if HandlerStack.push(self) then
        _currentActorID = actor:GetID()
    end
end
