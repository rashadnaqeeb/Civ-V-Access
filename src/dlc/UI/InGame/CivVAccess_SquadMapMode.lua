-- Always-live map bindings for the squad layer, appended onto Baseline (so
-- they share Baseline's capturesAllInput barrier) and registered only when
-- squadsAvailable() -- the layer is wholly absent on vanilla and LekMod.
--
-- The bindings drive the mod-side focus (SquadFocusCore), never the engine
-- selection or the cursor:
--   Up / Down      cycle the focused squad, plus a trailing "create new" slot;
--                  speak the squad name (and movement status when mid-move),
--                  or the create-new label on that slot.
--   Left / Right   cycle the focused member; speak its row.
--   Alt+/          select the focused member as the engine head selection so
--                  the player can command it; speak the selection.
--   Alt+Left       remove the focused member from its squad, or delete the
--                  squad outright once it is empty.
--   Alt+Right      add the head-selected unit to the focused squad and move
--                  focus onto it; on the create-new slot (the only position
--                  when no squads exist yet), create one, add the unit, and
--                  open the new squad's editor.
--   Alt+Up         open the move sub-mode for the focused squad; on a squad
--                  that is mid-move, read the move, then press again to
--                  cancel it and reopen the sub-mode to reissue.
--   Alt+Down       open the focused squad's editor (rename, delete, settings).
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
local VK_OEM_2 = 191 -- the "/" key; rides the unit-info key slot on every layout

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

-- Armed-reissue state for the Alt+Up two-press over a moving squad. Holds the
-- squad number a prior Alt+Up read; a second Alt+Up on that same still-moving
-- squad cancels the move and reopens the picker to reissue. Any other squad
-- binding clears it (see the clearArm() calls), so navigating away disarms the
-- reissue and the player can't cancel a squad they've moved focus off of. No
-- timer: like the combat-confirm latch, the squad identity is the guard.
local _pendingReissue = nil

local function clearArm()
    _pendingReissue = nil
end

-- ===== Squad cycling (Up / Down) =====

local function cycleSquad(stepFn)
    return function()
        clearArm()
        local num = stepFn()
        if num == nil then
            -- Landed on the trailing create-new slot, where Alt+Right makes a
            -- fresh squad. The slot is always present, so this is also the
            -- no-squads case.
            speak(Text.key("TXT_KEY_CIVVACCESS_SQUAD_ADD_NEW"))
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

-- ===== Select focused member (Alt+/) =====

-- Bridge the mod-side focus to the engine selection: make the focused member
-- (the unit Left/Right lands on, and Alt+Left would remove) the head selection
-- so the player can issue normal unit commands to it. Mirrors the bookmark /
-- Military Advisor jump: markUserInitiatedSelection lets the selection
-- announcement interrupt, and selectAndReveal speaks via the selection
-- listener; an already-selected unit only re-centers (no listener fire), so we
-- speak its info to confirm the keystroke.
local function selectFocusedUnit()
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
    UnitControl.markUserInitiatedSelection()
    if not UnitControl.selectAndReveal(unit) then
        speak(UnitSpeech.info(unit))
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
        -- An empty squad has no member to remove, so the per-unit Alt+Left
        -- becomes the structural delete (the mirror of Alt+Right creating a
        -- squad when none exist). Name first, the entry is gone after delete.
        local name = SquadRoster.getName(num)
        SquadRoster.delete(num)
        speak(Text.format("TXT_KEY_CIVVACCESS_SQUAD_DELETED", name))
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
    -- On the create-new slot (nil squad): create one to add into, then drop the
    -- player into its editor below to set escort / wake mode / name on it. This
    -- is the no-squads case and, with squads present, the trailing slot the
    -- Up/Down cycle reaches past the last squad.
    local created = num == nil
    if created then
        num = SquadRoster.allocate()
    end
    local prior = EngineData.squadNumber(unit)
    -- Already a member of the focused squad: reassigning is a no-op, but the
    -- wake-mode re-push below applies to the whole squad, so skip it too rather
    -- than flip the rest of the group's state on a do-nothing key.
    if not created and prior == num then
        speak(Text.format("TXT_KEY_CIVVACCESS_SQUAD_ALREADY_IN", SquadRoster.getName(num)))
        return
    end
    EngineData.assignToSquad(unit, num)
    -- The new member inherits the squad's intended wake mode, which lives in
    -- the roster (the engine can't store a per-squad default). setSquadEnd
    -- MovementMode applies to all members, so pushing it through the just-
    -- added unit re-asserts the squad's mode across the whole group.
    EngineData.setSquadEndMovementMode(unit, SquadRoster.getWakeMode(num))
    -- Move focus onto the added unit so an immediate Alt+Left removes it.
    SquadFocusCore.focusOnUnit(unit)
    if created then
        -- A brand-new squad has settings worth tuning right away; drop the
        -- player into its editor, which announces the squad and its new member.
        SquadMenuCore.openSquad(num)
        return
    end
    if prior >= 0 and prior ~= num then
        speak(Text.format("TXT_KEY_CIVVACCESS_SQUAD_MOVED_TO", SquadRoster.getName(num)))
    else
        speak(Text.format("TXT_KEY_CIVVACCESS_SQUAD_ADDED_TO", SquadRoster.getName(num)))
    end
end

-- ===== Move / read / reissue (Alt+Up) =====

-- Alt+Up is the move key with a built-in two-press over an in-progress move.
-- Idle squad: open the destination picker straight away (the common case).
-- Moving squad: the first press reads the move; a second press on the same
-- still-moving squad cancels the move and reopens the picker so the
-- player can reissue. The arm keys on the squad number and clears on any other
-- squad action, so a focus change can't leave a stray reissue primed; a move
-- that finishes between presses falls back to the idle path (straight picker).
local function moveAction()
    local num = SquadFocusCore.currentSquad()
    if num == nil then
        clearArm()
        speak(Text.key("TXT_KEY_CIVVACCESS_SQUAD_NONE"))
        return
    end
    if not squadIsMoving(num) then
        clearArm()
        SquadMoveMode.enter(num)
        return
    end
    if _pendingReissue == num then
        clearArm()
        EngineData.cancelSquadMove(repMember(num))
        SquadMoveMode.enter(num)
        return
    end
    speak(SquadSpeech.movementStatus(num))
    _pendingReissue = num
end

-- ===== Editor (Alt+Down) =====

-- Open the focused squad's editor (rename, delete, escort, wake mode, member
-- removal) straight from the map, skipping the F11 orchestrator list.
local function openEditor()
    clearArm()
    local num = SquadFocusCore.currentSquad()
    if num == nil then
        speak(Text.key("TXT_KEY_CIVVACCESS_SQUAD_NONE"))
        return
    end
    SquadMenuCore.openSquad(num)
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
        bind(VK_OEM_2, MOD_ALT, selectFocusedUnit, "Select focused squad unit"),
        bind(Keys.VK_LEFT, MOD_ALT, removeFocusedUnit, "Remove unit from squad"),
        bind(Keys.VK_RIGHT, MOD_ALT, addSelectedUnit, "Add unit to squad"),
        bind(Keys.VK_UP, MOD_ALT, moveAction, "Move squad, or read and reissue a move in progress"),
        bind(Keys.VK_DOWN, MOD_ALT, openEditor, "Open squad editor"),
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
            keyLabel = "TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_SELECT",
            description = "TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_SELECT",
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
            keyLabel = "TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_EDITOR",
            description = "TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_EDITOR",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_SQUAD_HELP_KEY_MENU",
            description = "TXT_KEY_CIVVACCESS_SQUAD_HELP_DESC_MENU",
        },
    }
    return { bindings = bindings, helpEntries = helpEntries }
end
