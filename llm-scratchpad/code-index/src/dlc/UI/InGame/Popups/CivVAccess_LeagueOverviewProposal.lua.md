# `src/dlc/UI/InGame/Popups/CivVAccess_LeagueOverviewProposal.lua`

351 lines · Mod-side proposal controller replacing the engine's ProposalController, managing per-slot state and providing slot picker and sub-decision picker sub-handlers.

## Header comment

```
-- Mod-side replacement for the engine's ProposalController (LeagueOverview.lua
-- line 1180+). One slot per available proposal -- a slot is either empty
-- ("Empty proposal slot N" Text) or filled ({Direction, Type, ResolutionId,
-- ChoiceId} which renders as "Slot N: Enact: <name>"). Activating a slot
-- pushes a picker (BaseMenu sub-handler) showing the resolution catalog in
-- three drillable sections; picking a candidate fills the slot and pops back.
-- Reset returns every slot to empty (no Network call); Commit fires
-- Network.SendLeagueProposeEnact / SendLeagueProposeRepeal for each filled
-- slot then closes the popup.
--
-- Sub-decision picker (which civ to embargo, which religion to designate)
-- is a second push: opening the candidate's GetResolutionDetails plus a
-- Choice per ProposerChoice. Engine handles this in a separate
-- ResolutionChoicePopup overlay (line 855); we replicate the same shape
-- as a stack-based handler.
```

## Outline

- L17: `LeagueOverviewProposal = {}`
- L19: `local kChoiceNone = -1`
- L20: `local kNoPlayer = -1`
- L21: `local PICKER_NAME = "LeagueOverviewSlotPicker"`
- L22: `local SUB_DECISION_NAME = "LeagueOverviewSlotSubDecision"`
- L24: `local Controller = {}`
- L25: `Controller.__index = Controller`
- L27: `local function snapshotInactiveCandidate(pLeague, raw, activePlayer)`
- L62: `local function snapshotActiveCandidate(pLeague, raw, activePlayer)`
- L79: `function LeagueOverviewProposal.collectCandidates(pLeague, activePlayer)`
- L100: `function LeagueOverviewProposal.create(pLeague, activePlayer, leagueId)`
- L111: `function Controller:reset()`
- L115: `function Controller:isSlotEmpty(idx)`
- L119: `function Controller:fillSlot(idx, candidate, choiceId)`
- L128: `function Controller:filledCount()`
- L142: `function Controller:commit(closeFn)`
- L168: `local function fillSlotAndPopAll(controller, slotIdx, candidate, choiceId)`
- L176: `local function pushSubDecisionPicker(controller, slotIdx, candidate, pLeague)`
- L218: `local function buildCandidateItem(controller, slotIdx, candidate, pLeague, activePlayer, allowCommit)`
- L252: `local function buildSection(headerKey, candidates, controller, slotIdx, pLeague, activePlayer, allowCommit)`
- L269: `function LeagueOverviewProposal.pushSlotPicker(controller, slotIdx, pLeague)`
- L325: `function LeagueOverviewProposal.slotItem(controller, slotIdx, pLeague, activePlayer)`
- L351: `return LeagueOverviewProposal`

## Notes

- L168 `fillSlotAndPopAll`: Pops both `SUB_DECISION_NAME` (if present) and `PICKER_NAME` so the user lands back on the proposals tab regardless of how many layers deep the selection went.
- L115 `Controller:isSlotEmpty`: Returns `true` when `self.slots[idx]` is nil; the slots table is sparse (filled slots only), so unset indices are empty by definition.
