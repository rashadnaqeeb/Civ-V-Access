# `src/dlc/UI/FrontEnd/CivVAccess_SelectMapSizeAccess.lua`

71 lines · Accessibility wiring for the SelectMapSize popup, gating each size entry's navigability on the base file's `g_WorldSizeControls` visibility so only sizes legal for the current map type appear.

## Header comment

```
-- Select Map Size accessibility wiring.
-- Items gate on the base file's g_WorldSizeControls[type].Root visibility;
-- the base ShowHideHandler toggles those based on current MapType (via
-- Map_Sizes filtering), so isNavigable picks up only sizes legal for the
-- current script.
```

## Outline

- L9: `local function currentIndex()`
- L25: `local function buildItems()`
- L61: `BaseMenu.install(ContextPtr, { ... })`
