# `src/dlc/UI/FrontEnd/CivVAccess_SelectCivilizationAccess.lua`

153 lines · Accessibility wiring for the SelectCivilization popup, with separate item-builders for regular and scenario modes and a rebuild on every show to stay current with DLC/scenario state changes.

## Header comment

```
-- Select Civilization accessibility wiring.
-- Modal popup, opened via UIManager:QueuePopup from the parent screen.
-- Items rebuild on every show because DLC activation and scenario toggle
-- both reshape the playable-civ set; the base file gates its InstanceManager
-- rebuild on g_bRefreshCivs / WB map, but rebuilding our items every show
-- is cheap and removes the dependency on those flags.
```

## Outline

- L13: `local civIds = {}`
- L18: `local function currentIndex()`
- L27: `local function buildRegularItems()`
- L75: `local function buildScenarioItems()`
- L129: `local function rebuildItems(h)`
- L142: `BaseMenu.install(ContextPtr, { ... })`

## Notes

- L13 `civIds`: module-level table rebuilt on every show alongside items so `currentIndex` can map `PreGame.GetCivilization(0)` back to a list position; not a persistent cache.
