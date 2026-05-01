# `src/dlc/UI/InGame/CivVAccess_UnitActionMenu.lua`

481 lines · Tab-triggered action menu for the selected unit, enumerating available GameInfoActions and routing each commit through self-plot or target-mode dispatch with full availability gating and rich build/promotion tooltips.

## Header comment

```
-- Tab action menu for the selected unit. Enumerates GameInfoActions,
-- keeps the ones the engine will accept, splits them into "commit at the
-- unit's plot" vs "pick a target", and routes each commit through the
-- right path (immediate Game.HandleAction for self-plot, HandleAction
-- + UnitTargetMode.enter for targeted).
--
-- The action set is pulled live from GameInfoActions on every open so a
-- newly-available build / promotion shows up without a stale cache.
-- Promotions and worker builds nest into a sub-Group so the top level
-- stays short [...].
--
-- Availability pattern mirrors base UnitPanel.lua:230-302:
--   Game.CanHandleAction(iAction, 0, 1) -> "could, if active unit"
--   Game.CanHandleAction(iAction)       -> "can, right now"
-- We show the action only when both return true. Partially-available
-- actions (visible-but-disabled in the engine UI) are omitted from
-- speech because activating one would silently no-op.
```

## Outline

- L20: `UnitActionMenu = {}`
- L26: `local SELF_PLOT_TOKENS_BY_TYPE = { ... }`
- L45: `local function isTargetedAction(actionType)`
- L49: `local function isPromotionAction(action)`
- L54: `local function isBuildAction(action)`
- L59: `local function actionLabel(action)`
- L73: `local function staticHelpText(action)`
- L83: `local function buildPediaName(action)`
- L106: `local BUILD_YIELD_KEYS = { ... }`
- L120: `local function buildActionTooltip(unit, action)`
- L242: `local QUEUEABLE_AT_ZERO_MP = { ... }`
- L243: `local function isAvailable(unit, iAction, action)`
- L264: `local function commitSelfPlot(action, payload)`
- L284: `local function commitTargeted(unit, action, iAction)`
- L289: `local function buildPromotionItems(unit, rows)`
- L311: `local function buildBuildItems(unit, rows)`
- L333: `local function buildTopLevelItems(unit, buckets)`
- L380: `local function collectActions(unit)`
- L410: `function UnitActionMenu.findActionRow(types)`
- L428: `function UnitActionMenu.actionLabel(action)`
- L437: `function UnitActionMenu.commitByType(unit, types)`
- L461: `function UnitActionMenu.open(unit)`

## Notes

- L428 `UnitActionMenu.actionLabel`: thin public wrapper around the private `actionLabel` local so UnitControl can speak the failure label without re-implementing the lookup.
- L242 `QUEUEABLE_AT_ZERO_MP`: lists INTERFACEMODE_* types that the engine accepts as queued PUSH_MISSIONs at 0 MP so 0-move units can still stage multi-turn orders from the menu.
