# `src/dlc/UI/InGame/CivVAccess_UnitControl.lua`

1368 lines · Coordinator for unit-control key bindings and engine-event listeners: unit cycling, direct Alt+direction moves with two-tap combat confirm, quick-action Alt+letter hotkeys, pending-move tracking, combat-result announcements via engine-fork hooks, and nuclear-strike accumulation.

## Header comment

```
-- Coordinator for unit-control bindings and event-driven announcements.
-- getBindings() is concat'd by BaselineHandler; installListeners() wires
-- the per-frame and per-engine-event hooks that speak result feedback.
--
-- Speech policy follows the design's "user-initiated INTERRUPT vs engine-
-- event QUEUE" split [...].
--
-- Pending-move tracking bridges "commit" to "announce actual outcome".
-- On commit [...] we stash target coords + the active player's expected
-- unit id. Two listeners drive resolution: SerialEventUnitMove fires
-- per-hex while the unit traverses [...], and the engine fork's
-- CivVAccessMissionDispatched hook fires once after the engine processes
-- the net message [...]. No cross-turn state -- pending is cleared on
-- every resolution.
--
-- Quick Movement support: with the option enabled the engine routes per-
-- hex moves through CvUnit::SetPosition (gDLL->GameplayUnitTeleported)
-- instead of QueueMoveForVisualization [...]. We register the same
-- handler against SerialEventUnitTeleportedToHex.
--
-- Combat moves don't register a pending. The engine fork's
-- CivVAccessCombatResolved GameEvent fires synchronously from
-- CvUnitCombat::ResolveCombat [...].
--
-- War-confirm moves freeze pending into a deferred slot. [...] The
-- popup-shown listener moves _pending to _deferred; DeclareWarPopupAccess
-- re-arms via notifyDeferredCommit on Yes or drops via notifyCommitCanceled
-- on No / Esc.
```

## Outline

- L59: `UnitControl = {}`
- L61: `local MOD_NONE = 0`
- L62: `local MOD_CTRL = 2`
- L63: `local MOD_ALT = 4`
- L66: `local VK_OEM_COMMA = 188`
- L67: `local VK_OEM_PERIOD = 190`
- L68: `local VK_OEM_2 = 191`
- L72: `local COMBAT_CONFIRM_WINDOW_SECONDS = 1.0`
- L86: `local USER_SELECTION_WINDOW_SECONDS = 0.1`
- L87: `local _userSelectionAt = -math.huge`
- L88: `function UnitControl.markUserInitiatedSelection()`
- L92: `local function consumeUserInitiatedSelection()`
- L101: `local _combatConfirm = { dir = nil, clock = 0 }`
- L103: `local function clearCombatConfirm()`
- L113: `local _pending = nil`
- L114: `local _deferred = nil`
- L116: `local function clearPending()`
- L120: `function UnitControl.registerPending(unit, targetX, targetY)`
- L135: `local function speakInterrupt(text)`
- L142: `local function speakQueued(text)`
- L149: `local function selectedUnit()`
- L153: `local function plotAt(x, y)`
- L167: `function UnitControl.enemyAt(plot)`
- L180: `function UnitControl.cycleAll(forward)`
- L191: `function UnitControl.cycleAllUnits(forward)`
- L257: `local function enemyCityAt(plot)`
- L288: `local function commitDirectMove(unit, target, targetX, targetY, defender)`
- L314: `function UnitControl.preflightAttack(unit)`
- L358: `function UnitControl.preflightAttackTarget(unit, target)`
- L385: `function UnitControl.preflightMove(unit, target)`
- L395: `local function directMove(dir)`
- L462: `local function speakInfo()`
- L483: `local function recenterOnUnit()`
- L500: `local function renameUnit()`
- L519: `local function openActionMenu()`
- L550: `local ALT_ACTION_TYPES = { ... }`
- L561: `local function quickAction(types)`
- L581: `local bind = HandlerStack.bind`
- L583: `function UnitControl.getBindings()`
- L698: `local function onUnitSelectionChanged(playerID, unitID, _hexI, _hexJ, _hexK, isSelected)`
- L779: `local function onCombatResolved(...)`
- L888: `local function onAirSweepNoTarget(attackerPlayer, _attackerUnit)`
- L908: `local _nukeBuffer = nil`
- L916: `local function nukeCityDisplayName(playerId, cityId)`
- L928: `local function onNukeStart(...)`
- L963: `local function onNukeUnitAffected(defenderPlayer, defenderUnit, damageDelta, finalDamage, maxHP)`
- L979: `local function onNukeCityAffected(...)`
- L1004: `local function nukeBufferInvolvesActivePlayer(buf, activePlayer)`
- L1021: `local function onNukeEnd(_attackerPlayer)`
- L1040: `local function onCityCaptured(hexPos, oldOwner, cityId, newOwner)`
- L1066: `local function resolvePendingUnit()`
- L1082: `local function speakMoveResult(unit, cx, cy)`
- L1110: `local function onUnitMoveCompleted()`
- L1166: `local function onMissionDispatched(playerID, unitID, _missionType, _iData1, _iData2)`
- L1203: `UnitControl._onMissionDispatched = onMissionDispatched`
- L1208: `local function onPopupShown(popupInfo)`
- L1230: `function UnitControl.notifyDeferredCommit()`
- L1263: `function UnitControl.notifyCommitCanceled()`
- L1272: `function UnitControl.installListeners()`

## Notes

- L1203 `UnitControl._onMissionDispatched`: test seam; production registers via GameEvents.CivVAccessMissionDispatched in installListeners.
- L395 `directMove`: implements two-tap melee-confirm by comparing `_combatConfirm.dir` and a wall-clock window; first tap speaks the preview, second tap within 1 second commits.
- L779 `onCombatResolved`: sole speech path for all combat results; intentionally does not use Events.EndCombatSim or SerialEventCitySetDamage.
