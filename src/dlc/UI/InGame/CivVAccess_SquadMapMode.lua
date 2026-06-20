-- Always-live map bindings for the squad layer, appended onto Baseline (so
-- they share Baseline's capturesAllInput barrier) and registered only when
-- squadsAvailable() -- the layer is wholly absent on vanilla and LekMod.
--
-- The bindings drive the mod-side focus (SquadFocusCore), never the engine
-- selection or the cursor:
--   Up / Down      cycle the focused squad; speak its name, plus the
--                  movement status when it is mid-move.
--   Left / Right   cycle the focused member; speak its row.
--   Alt+Left       remove the focused member from its squad.
--   Alt+Right      add the head-selected unit to the focused squad and move
--                  focus onto it.
--   Alt+Up         enter the move sub-mode for the focused squad.
--   Alt+Down       report the focused squad's full status; a second Alt+Down
--                  while a move is pending cancels it (armed two-press).
--   F11            open the squad menu.
--
-- Arrow keys reach here through the WorldView input hook, which dispatches
-- the HandlerStack before the engine's camera pan; Alt-chorded arrows arrive
-- as WM_SYSKEYDOWN, which the InputRouter already folds in. The squad
-- bindings on a CP-DLL deploy simply give those otherwise-swallowed keys a
-- purpose.

SquadMapMode = {}

local MOD_NONE = 0
local MOD_ALT = 4

local speak = SpeechPipeline.speakInterrupt
local bind = HandlerStack.bind

local function activePlayer()
    return Players[Game.GetActivePlayer()]
end

-- A live member of the squad to use as the engine command handle, or nil.
local function repMember(num)
    local m = EngineData.squadMembers(activePlayer(), num)
    return m[1]
end

local function squadIsMoving(num)
    local rep = repMember(num)
    return rep ~= nil and EngineData.squadIsMoving(rep)
end

-- Armed-cancel state for the Alt+Down two-press. Holds the squad number a
-- prior Alt+Down armed; a second Alt+Down on the same still-moving squad
-- consumes it and cancels the move. Any other squad binding clears it, so a
-- focus change or a different action disarms the cancel (the player can't
-- accidentally cancel a squad they've navigated away from). No timer: like
-- the combat-confirm latch, the identity key is the guard.
local _pendingCancel = nil

local function clearArm()
    _pendingCancel = nil
end

-- ===== Squad cycling (Up / Down) =====

local function cycleSquad(stepFn)
    return function()
        clearArm()
        local num = stepFn()
        if num == nil then
            speak(Text.key("TXT_KEY_CIVVACCESS_SQUAD_NONE"))
            return
        end
        -- Announce the squad name so the player knows which squad they landed
        -- on, then append the movement status when it is mid-move (silent on
        -- the status when idle, but the name always speaks).
        local parts = { SquadRoster.getName(num) }
        local status = SquadSpeech.movementStatus(num)
        if status ~= nil then
            parts[#parts + 1] = status
        end
        speak(table.concat(parts, ", "))
    end
end

-- ===== Member cycling (Left / Right) =====

local function cycleUnit(stepFn)
    return function()
        clearArm()
        local num = SquadFocusCore.currentSquad()
        if num == nil then
            speak(Text.key("TXT_KEY_CIVVACCESS_SQUAD_NONE"))
            return
        end
        local unit = stepFn()
        if unit == nil then
            speak(Text.key("TXT_KEY_CIVVACCESS_SQUAD_NO_UNITS"))
            return
        end
        speak(SquadSpeech.unitRow(unit))
    end
end

-- ===== Membership edits (Alt+Left / Alt+Right) =====

local function removeFocusedUnit()
    clearArm()
    local num = SquadFocusCore.currentSquad()
    if num == nil then
        speak(Text.key("TXT_KEY_CIVVACCESS_SQUAD_NONE"))
        return
    end
    local unit = SquadFocusCore.currentUnit()
    if unit == nil then
        speak(Text.key("TXT_KEY_CIVVACCESS_SQUAD_NO_UNITS"))
        return
    end
    EngineData.removeFromSquad(unit)
    speak(Text.format("TXT_KEY_CIVVACCESS_SQUAD_REMOVED", SquadRoster.getName(num)))
end

local function addSelectedUnit()
    clearArm()
    local unit = UI.GetHeadSelectedUnit()
    if unit == nil then
        speak(Text.key("TXT_KEY_CIVVACCESS_SQUAD_NO_UNIT_SELECTED"))
        return
    end
    local num = SquadFocusCore.currentSquad()
    if num == nil then
        speak(Text.key("TXT_KEY_CIVVACCESS_SQUAD_NONE"))
        return
    end
    local prior = EngineData.squadNumber(unit)
    EngineData.assignToSquad(unit, num)
    -- The new member inherits the squad's intended wake mode, which lives in
    -- the roster (the engine can't store a per-squad default). setSquadEnd
    -- MovementMode applies to all members, so pushing it through the just-
    -- added unit re-asserts the squad's mode across the whole group.
    EngineData.setSquadEndMovementMode(unit, SquadRoster.getWakeMode(num))
    -- Move focus onto the added unit so an immediate Alt+Left removes it.
    SquadFocusCore.focusOnUnit(unit)
    if prior >= 0 and prior ~= num then
        speak(Text.format("TXT_KEY_CIVVACCESS_SQUAD_MOVED_TO", SquadRoster.getName(num)))
    else
        speak(Text.format("TXT_KEY_CIVVACCESS_SQUAD_ADDED_TO", SquadRoster.getName(num)))
    end
end

-- ===== Move sub-mode (Alt+Up) =====

local function enterMoveMode()
    clearArm()
    local num = SquadFocusCore.currentSquad()
    if num == nil then
        speak(Text.key("TXT_KEY_CIVVACCESS_SQUAD_NONE"))
        return
    end
    SquadMoveMode.enter(num)
end

-- ===== Status + armed cancel (Alt+Down) =====

local function reportOrCancel()
    local num = SquadFocusCore.currentSquad()
    if num == nil then
        clearArm()
        speak(Text.key("TXT_KEY_CIVVACCESS_SQUAD_NONE"))
        return
    end
    -- Second press on the armed, still-moving squad cancels the move.
    if _pendingCancel == num and squadIsMoving(num) then
        clearArm()
        EngineData.cancelSquadMove(repMember(num))
        speak(Text.format("TXT_KEY_CIVVACCESS_SQUAD_MOVE_CANCELED", SquadRoster.getName(num)))
        return
    end
    speak(SquadSpeech.fullStatus(num))
    -- Arm the cancel only when there is actually a move to cancel.
    if squadIsMoving(num) then
        _pendingCancel = num
    else
        clearArm()
    end
end

-- ===== Menu (F11) =====

local function openMenu()
    clearArm()
    SquadMenuCore.open()
end

function SquadMapMode.getBindings()
    local bindings = {
        bind(Keys.VK_UP, MOD_NONE, cycleSquad(SquadFocusCore.nextSquad), "Next squad"),
        bind(Keys.VK_DOWN, MOD_NONE, cycleSquad(SquadFocusCore.prevSquad), "Previous squad"),
        bind(Keys.VK_RIGHT, MOD_NONE, cycleUnit(SquadFocusCore.nextUnit), "Next squad unit"),
        bind(Keys.VK_LEFT, MOD_NONE, cycleUnit(SquadFocusCore.prevUnit), "Previous squad unit"),
        bind(Keys.VK_LEFT, MOD_ALT, removeFocusedUnit, "Remove unit from squad"),
        bind(Keys.VK_RIGHT, MOD_ALT, addSelectedUnit, "Add unit to squad"),
        bind(Keys.VK_UP, MOD_ALT, enterMoveMode, "Move squad"),
        bind(Keys.VK_DOWN, MOD_ALT, reportOrCancel, "Squad status, twice to cancel move"),
        bind(Keys.VK_F11, MOD_NONE, openMenu, "Open squad menu"),
    }
    local helpEntries = {
        {
            keyLabel = "TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_CYCLE_SQUAD",
            description = "TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_CYCLE_SQUAD",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_CYCLE_UNIT",
            description = "TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_CYCLE_UNIT",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_REMOVE",
            description = "TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_REMOVE",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_ADD",
            description = "TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_ADD",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_MOVE",
            description = "TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_MOVE",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_STATUS",
            description = "TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_STATUS",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_MENU",
            description = "TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_MENU",
        },
    }
    return { bindings = bindings, helpEntries = helpEntries }
end
