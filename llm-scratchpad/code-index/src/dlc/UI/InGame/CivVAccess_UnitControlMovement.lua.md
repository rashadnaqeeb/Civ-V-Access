# `src/dlc/UI/InGame/CivVAccess_UnitControlMovement.lua`

666 lines · Alt+QAZEDC direct-move bindings, Tab action menu, Alt-letter quick actions, pending-move tracker, and war-confirm hand-off for DeclareWarPopupAccess.

## Header comment

```
-- Movement / actions / pending-tracking half of the unit-control split.
-- Owns the Alt+QAZEDC direct-move bindings, the Tab action menu, the
-- Alt-letter quick-action bindings (Alt+F/S/W/X/H/R/P/U/N), the pending-
-- move tracker, the SerialEventUnitMove / MissionDispatched / war-confirm
-- listeners, and the DeclareWarPopupAccess hand-off methods.
--
-- Pending-move tracking bridges "commit" to "announce actual outcome".
-- On commit (Alt+QAZEDC or target-mode move-to) we stash target coords +
-- the active player's expected unit id. Two listeners drive resolution:
-- SerialEventUnitMove fires per-hex while the unit traverses (announce
-- on stop conditions: at target OR 0 MP), and the engine fork's
-- CivVAccessMissionDispatched hook fires once after the engine processes
-- the net message (announce moved / stopped-short / queued / failed
-- depending on the unit's post-dispatch state). The hook is the
-- authoritative resolver for MP, where the lockstep round-trip can stretch
-- the move's resolution out by seconds; SerialEventUnitMove still races
-- ahead in SP, and both paths early-return on _pending == nil so whichever
-- arrives first wins and the other no-ops. No cross-turn state -- pending
-- is cleared on every resolution.
--
-- Quick Movement support: with the option enabled the engine routes per-
-- hex moves through CvUnit::SetPosition (gDLL->GameplayUnitTeleported)
-- instead of QueueMoveForVisualization (gDLL->GameplayUnitMoved), so the
-- SerialEventUnitMove(ToHexes) events the pending resolver listens to
-- don't fire; SerialEventUnitTeleportedToHex does. We register the same
-- handler against that event so the resolution path runs identically.
--
-- War-confirm moves freeze pending into a deferred slot. Moving onto a
-- peaceful rival's tile (or attacking a peaceful rival's unit) does not
-- execute the move; the engine queues BUTTONPOPUP_DECLAREWARMOVE for
-- confirmation locally before any net message goes out, so neither
-- SerialEventUnitMove nor MissionDispatched will fire for the original
-- commit. The popup-shown listener moves _pending to _deferred to keep it
-- out of the resolver paths; DeclareWarPopupAccess re-arms via
-- notifyDeferredCommit on Yes (the engine re-issues the move via
-- Game.SelectionListMove, which sends a fresh PUSH_MISSION and resolves
-- through the normal path) or drops via notifyCommitCanceled on No / Esc
-- (the popup itself was the user's answer, no further speech needed).
```

## Outline

- L40: `include("CivVAccess_UnitControlCombat")`
- L42: `UnitControlMovement = {}`
- L44: `local MOD_NONE = 0`
- L45: `local MOD_ALT = 4`
- L52: `local _pending = nil`
- L53: `local _deferred = nil`
- L55: `local function clearPending()`
- L59: `function UnitControlMovement.registerPending(unit, targetX, targetY)`
- L74: `local function speakInterrupt(text)`
- L81: `local function speakQueued(text)`
- L88: `local function selectedUnit()`
- L92: `local function plotAt(x, y)`
- L106: `function UnitControlMovement.enemyAt(plot)`
- L116: `local function enemyCityAt(plot)`
- L147: `local function commitDirectMove(unit, target, targetX, targetY, defender)`
- L178: `function UnitControlMovement.preflightMove(unit, target)`
- L188: `local function directMove(dir)`
- L259: `local function renameUnit()`
- L275: `local function openActionMenu()`
- L305: `local ALT_ACTION_TYPES = { ... }`
- L316: `local function quickAction(types)`
- L336: `local bind = HandlerStack.bind`
- L338: `function UnitControlMovement.getBindings()`
- L419: `local function resolvePendingUnit()`
- L435: `local function speakMoveResult(unit, cx, cy)`
- L463: `local function onUnitMoveCompleted()`
- L519: `local function onMissionDispatched(playerID, unitID, _missionType, _iData1, _iData2)`
- L556: `UnitControlMovement._onMissionDispatched = onMissionDispatched`
- L562: `local function onPopupShown(popupInfo)`
- L584: `function UnitControlMovement.notifyDeferredCommit()`
- L617: `function UnitControlMovement.notifyCommitCanceled()`
- L623: `function UnitControlMovement.installListeners()`

## Notes

- L52 `_pending` / `_deferred`: module-local so a Context re-entry drops in-flight state; whichever of `onUnitMoveCompleted` or `onMissionDispatched` arrives first resolves pending, and the second is a no-op via the `_pending == nil` early-return.
- L106 `UnitControlMovement.enemyAt`: passes `bTestAtWar=1, bTestPotentialEnemy=0` so peaceful rivals don't trigger the attack path; the war-confirm popup handles that case via the deferred-pending mechanism.
- L147 `commitDirectMove`: combat commits go through `Game.SelectionListMove` (no pending registered) because `CivVAccessCombatResolved` already announces the result; move commits use `GAMEMESSAGE_PUSH_MISSION` with a pending registration.
- L316 `quickAction`: returns a closure; `ALT_ACTION_TYPES` lists are walked by `UnitActionMenu.commitByType` in caller order so the first currently-available type wins.
- L435 `speakMoveResult`: shared by both resolution paths; uses `unit:GeneratePath` (engine-fork binding) to compute turns-to-arrival when the unit stopped short.
- L519 `onMissionDispatched`: distinguishes queued-for-next-turn from hard-refused by checking `unit:GetMissionQueue()` length after the unit fails to move.
- L584 `UnitControlMovement.notifyDeferredCommit`: skips re-arming pending when the target plot has an adjacent defender and `bTestPotentialEnemy=true` (pre-war-declaration check), because the combat path will handle announcement instead.
