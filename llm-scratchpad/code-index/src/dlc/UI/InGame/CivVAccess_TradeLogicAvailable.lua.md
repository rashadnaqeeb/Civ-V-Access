# `src/dlc/UI/InGame/CivVAccess_TradeLogicAvailable.lua`

512 lines · Available-tab item builder for the diplomacy trade screen: `buildAvailableItems` composes the legal placement options for one side; per-item leaf builders cover Gold, GPT, Resources, boolean diplo items, Cities, Other Players, and Votes; `disabledPocketLeaf` surfaces unavailable items with the engine's live tooltip.

## Header comment

```
-- Available-tab item builder for the diplomacy trade screen, peeled out
-- of CivVAccess_TradeLogicAccess.lua. Composes the legal placement
-- options for one side at a time: Gold, Gold-per-turn, Resources
-- (luxury / strategic sub-groups), boolean diplo items, Cities,
-- Other Players (Make Peace / Declare War), and Votes. Each leaf
-- queries g_Deal:IsPossibleToTradeItem live; illegal items either
-- surface as "<label>, disabled" with the engine's stated reason
-- (boolean / gold path) or are dropped (Other Players, Votes).
--
-- Shared helpers live on the TradeLogicAccess module (`prefix`,
-- `sidePlayer`, `sideIsUs`, `pocketTooltipFn`, `turnsSuffix`,
-- `dealDuration`, `peaceDuration`, `afterLocalDealChange`,
-- `emptyPlaceholder`). This file only needs them at call time, not at
-- load time, so the orchestrator's include order does not create a
-- circular-load problem.
```

## Outline

- L17: `TradeLogicAvailable = {}`
- L28: `local function disabledPocketLeaf(label, controlName)`
- L39: `local function availableGoldLeaf(side)`
- L71: `local function availableGoldPerTurnLeaf(side)`
- L104: `local function availableResourceLeaf(side, resType, resInfo)`
- L163: `local function availableBooleanLeaf(side, labelKey, itemConstant, controlSuffix, addFn, bothSides)`
- L201: `local function availableResourceGroups(side)`
- L247: `local function availableVotesGroup(side)`
- L321: `local function availableCitiesGroup(side)`
- L369: `local function availableOtherPlayersGroup(side)`
- L438: `function TradeLogicAvailable.buildAvailableItems(side)`
- L511: `return TradeLogicAvailable`

## Notes

- L28 `disabledPocketLeaf`: despite the name it is used for any item that fails `IsPossibleToTradeItem`, not only items the engine has visually greyed out.
- L369 `availableOtherPlayersGroup`: drops illegal targets outright rather than surfacing them as disabled, to avoid forcing the user past a long list of "disabled, not at war" entries.
