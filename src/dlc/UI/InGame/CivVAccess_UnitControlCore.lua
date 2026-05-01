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

include("CivVAccess_UnitControlSelection")
include("CivVAccess_UnitControlCombat")
include("CivVAccess_UnitControlMovement")

UnitControl = {}

-- Re-exports: every public method previously on UnitControl, surfaced
-- through the orchestrator so existing callers (UnitTargetMode,
-- DeclareWarPopupAccess via civvaccess_shared.modules.UnitControl, the
-- unit_control_test suite) keep working without touching them.
UnitControl.markUserInitiatedSelection = UnitControlSelection.markUserInitiatedSelection
UnitControl.cycleAll = UnitControlSelection.cycleAll
UnitControl.cycleAllUnits = UnitControlSelection.cycleAllUnits
UnitControl.preflightAttack = UnitControlCombat.preflightAttack
UnitControl.preflightAttackTarget = UnitControlCombat.preflightAttackTarget
UnitControl.preflightMove = UnitControlMovement.preflightMove
UnitControl.enemyAt = UnitControlMovement.enemyAt
UnitControl.registerPending = UnitControlMovement.registerPending
UnitControl.notifyDeferredCommit = UnitControlMovement.notifyDeferredCommit
UnitControl.notifyCommitCanceled = UnitControlMovement.notifyCommitCanceled
UnitControl._onMissionDispatched = UnitControlMovement._onMissionDispatched

local function appendAll(target, source)
    if source == nil then
        return
    end
    for _, v in ipairs(source) do
        target[#target + 1] = v
    end
end

-- Composed bindings list, in the same order BaselineHandler used to see
-- before the split: Selection (cycle / info / recenter) first, then
-- Movement+Actions (action menu, Alt+QAZEDC, Alt-letter, Alt+N).
function UnitControl.getBindings()
    local sel = UnitControlSelection.getBindings()
    local mov = UnitControlMovement.getBindings()
    local bindings = {}
    appendAll(bindings, sel.bindings)
    appendAll(bindings, mov.bindings)
    local helpEntries = {}
    appendAll(helpEntries, sel.helpEntries)
    appendAll(helpEntries, mov.helpEntries)
    return { bindings = bindings, helpEntries = helpEntries }
end

-- Boot calls this once per game load (LoadScreenClose). Each sub-module
-- registers its own fresh listeners on every call -- see CLAUDE.md's
-- no-install-once-guards rule for the load-game-from-game rationale.
function UnitControl.installListeners()
    UnitControlSelection.installListeners()
    UnitControlCombat.installListeners()
    UnitControlMovement.installListeners()
end
