# `src/dlc/UI/InGame/Popups/CivVAccess_DiploCommon.lua`

73 lines · Shared helpers for the three DiploOverview tab panels: activation guard, comma-join utility, and the open-trade routing function.

## Header comment

```
-- Shared helpers for the Diplomatic Overview tab wrappers. Both the
-- Relations panel (Your Relations) and the Global panel (Global Politics)
-- compose per-civ speech lines from the same list-join primitive and
-- share the "open trade with this civ" activation path.
```

## Outline

- L6: `DiploCommon = {}`
- L21: `function DiploCommon.shouldActivate()`
- L29: `function DiploCommon.joinParts(parts)`
- L59: `function DiploCommon.openTradeWith(iOther)`
- L73: `return DiploCommon`

## Notes

- L21 `shouldActivate`: Guards against the engine's popup-priming pass at game start, where the initially-visible sub-panel receives `ShowHide(bIsInit=true, bIsHide=false)` and would otherwise push its BaseMenu on top of the LoadScreen handler.
- L59 `openTradeWith`: Closes DiploOverview before opening the PvP trade screen for human targets (to avoid stacked input capture), but leaves it open for AI targets (LeaderHead queues above DiploOverview correctly).
