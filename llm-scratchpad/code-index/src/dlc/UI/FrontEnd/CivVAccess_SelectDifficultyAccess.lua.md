# `src/dlc/UI/FrontEnd/CivVAccess_SelectDifficultyAccess.lua`

51 lines · Accessibility wiring for the SelectDifficulty popup, presenting a flat list of handicaps (excluding the AI-only default) with the current selection pre-focused on show.

## Header comment

```
-- Select Difficulty accessibility wiring. Flat list of handicaps.
-- DifficultySelected is the base-file global; it commits to PreGame and
-- calls OnBack, which SetHide(true)s the child Context and pops our
-- handler via ShowHide.
```

## Outline

- L8: `local function currentIndex()`
- L21: `local function buildItems()`
- L41: `BaseMenu.install(ContextPtr, { ... })`
