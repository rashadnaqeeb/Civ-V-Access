# `src/dlc/UI/InGame/CivVAccess_UnitControlCore.lua`

85 lines · Orchestrator that declares the `UnitControl` global, includes the three sub-modules, re-exports their public methods, and aggregates getBindings / installListeners into a single unified interface.

## Header comment

```
-- Unit-control orchestrator. The implementation is split across three
-- sibling files:
--   CivVAccess_UnitControlSelection.lua -- cycle / info / recenter
--                                          bindings, UnitSelectionChanged
--                                          listener, user-vs-engine
--                                          selection origin discriminator.
--   CivVAccess_UnitControlCombat.lua    -- preflightAttack /
--                                          preflightAttackTarget,
--                                          combat-confirm two-tap state,
--                                          CombatResolved / AirSweep /
--                                          Nuke* / CityCaptured listeners.
--   CivVAccess_UnitControlMovement.lua  -- Alt+QAZEDC direct-move,
--                                          Tab action menu, Alt-letter
--                                          quick actions, pending-move
--                                          tracking, war-confirm hand-off
--                                          for DeclareWarPopupAccess.
--
-- This file declares the `UnitControl` global that external callers
-- (Boot, BaselineHandler, UnitTargetMode, DeclareWarPopupAccess, the
-- offline test harness) reach for. It re-exports the public methods of
-- the three sub-modules so those callers do not need to know about the
-- split, and it aggregates the per-module getBindings / installListeners
-- so BaselineHandler still gets one unified bindings list and Boot still
-- makes one installListeners call.
--
-- Speech policy (lives at the orchestrator level because both Selection
-- and Combat / Movement participate): user-initiated actions interrupt;
-- engine-event listeners queue. See the headers of each sub-module for
-- the per-area details.
```

## Outline

- L31: `include("CivVAccess_UnitControlSelection")`
- L32: `include("CivVAccess_UnitControlCombat")`
- L33: `include("CivVAccess_UnitControlMovement")`
- L35: `UnitControl = {}`
- L41: `UnitControl.markUserInitiatedSelection = UnitControlSelection.markUserInitiatedSelection`
- L42: `UnitControl.cycleAll = UnitControlSelection.cycleAll`
- L43: `UnitControl.cycleAllUnits = UnitControlSelection.cycleAllUnits`
- L44: `UnitControl.preflightAttack = UnitControlCombat.preflightAttack`
- L45: `UnitControl.preflightAttackTarget = UnitControlCombat.preflightAttackTarget`
- L46: `UnitControl.preflightMove = UnitControlMovement.preflightMove`
- L47: `UnitControl.enemyAt = UnitControlMovement.enemyAt`
- L48: `UnitControl.registerPending = UnitControlMovement.registerPending`
- L49: `UnitControl.notifyDeferredCommit = UnitControlMovement.notifyDeferredCommit`
- L50: `UnitControl.notifyCommitCanceled = UnitControlMovement.notifyCommitCanceled`
- L51: `UnitControl._onMissionDispatched = UnitControlMovement._onMissionDispatched`
- L53: `local function appendAll(target, source)`
- L65: `function UnitControl.getBindings()`
- L80: `function UnitControl.installListeners()`
