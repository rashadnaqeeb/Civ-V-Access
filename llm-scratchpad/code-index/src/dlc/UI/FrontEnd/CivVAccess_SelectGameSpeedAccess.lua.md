# `src/dlc/UI/FrontEnd/CivVAccess_SelectGameSpeedAccess.lua`

57 lines · Accessibility wiring for the SelectGameSpeed popup, presenting game speeds sorted by GrowthPercent to match the base file's order.

## Header comment

```
-- Select Game Speed accessibility wiring. Flat list of game speeds, sorted
-- by GrowthPercent to match the base-file order.
```

## Outline

- L6: `local function sortedSpeeds()`
- L20: `local function currentIndex()`
- L29: `local function buildItems()`
- L47: `BaseMenu.install(ContextPtr, { ... })`
