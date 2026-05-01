# `src/dlc/UI/InGame/Popups/CivVAccess_ChooseProductionLogic.lua`

376 lines · Pure helpers for production-popup entry construction, eligibility checks, cost/turn calculation, advisor compositing, sorting, and label assembly; no ContextPtr or Events surface.

## Header comment

```
-- Pure helpers for ChooseProductionPopupAccess. Own module so offline tests
-- can exercise entry construction, sorting, disabled / cost / advisor
-- compositing, and label composition without dofiling the install-side
-- access file (which touches ContextPtr / InputHandler / Events at load).
```

## Outline

- L6: `ChooseProductionLogic = {}`
- L12: `ChooseProductionLogic.ADVISORS = { ... }`
- L23: `function ChooseProductionLogic.isWonderBuilding(building)`
- L36: `function ChooseProductionLogic.buildSortContext()`
- L48: `function ChooseProductionLogic.unitSortKey(unit, erasByTech)`
- L65: `function ChooseProductionLogic.buildingSortKey(building, erasByTech)`
- L76: `function ChooseProductionLogic.isEntryDisabled(city, entry)`
- L99: `function ChooseProductionLogic.disabledReason(city, entry)`
- L123: `local function produceCost(city, entry)`
- L138: `local function purchaseCost(city, entry)`
- L167: `function ChooseProductionLogic.costClause(city, entry)`
- L180: `function ChooseProductionLogic.advisorSuffix(entry)`
- L204: `function ChooseProductionLogic.sortEntries(entries, sortKeyFn)`
- L226: `local function mkUnitEntry(id, unit, yieldType, isProduce)`
- L229: `local function mkBuildingEntry(id, building, yieldType, isProduce)`
- L232: `local function mkProjectEntry(id, project, yieldType, isProduce)`
- L235: `local function mkProcessEntry(id, process)`
- L239: `ChooseProductionLogic._mkUnitEntry = mkUnitEntry`
- L240: `ChooseProductionLogic._mkBuildingEntry = mkBuildingEntry`
- L241: `ChooseProductionLogic._mkProjectEntry = mkProjectEntry`
- L242: `ChooseProductionLogic._mkProcessEntry = mkProcessEntry`
- L244: `function ChooseProductionLogic.buildUnitEntries(city, isProduce)`
- L271: `function ChooseProductionLogic.buildBuildingAndWonderEntries(city, isProduce)`
- L304: `function ChooseProductionLogic.buildOtherEntries(city, isProduce)`
- L336: `function ChooseProductionLogic.buildLabel(entry, city)`
- L375: `return ChooseProductionLogic`

## Notes

- L76 `isEntryDisabled`: uses the strict can-build-right-now variant (`CanTrain(id, 0)` not `CanTrain(id, 0, 1)`); the loose variant used in `buildUnitEntries` etc. controls visibility, the strict variant controls the "disabled" narration.
- L180 `advisorSuffix`: requires `Game.SetAdvisorRecommenderCity(city)` to have been called by the caller before invoking; does not set it itself.
- L239-242: private mk* constructors exposed on the module with underscore prefix for test access only.
