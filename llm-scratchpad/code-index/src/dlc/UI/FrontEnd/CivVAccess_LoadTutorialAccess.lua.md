# `src/dlc/UI/FrontEnd/CivVAccess_LoadTutorialAccess.lua`

106 lines · Accessibility wiring for the Load Tutorial screen, building a Choice list over the six tutorial slots (Intro + 1-5) with completion state read from live widget visibility.

## Header comment

```
-- LoadTutorial accessibility wiring. Base declares ShowHideHandler and
-- InputHandler as globals so both priors forward normally. SetSelected
-- and OnStart / OnBack are globals too; the sentinel index -1 picks the
-- Intro, 1..5 pick tutorial slots. The base's Tutorials metadata table
-- is a file-local that our sandbox can't reach, so tutorial labels are
-- composed from the well-known TXT_KEY_TUTORIAL{N}_TITLE / _DESC keys
-- (stable since Civ V shipped; Intro uses TXT_KEY_TUTORIAL_INSTRUCT).
-- Completion state is surfaced by reading g_TutorialEntries[i].
-- CompletedIcon:IsHidden(), which the base's ShowHide refreshes from
-- modUserData on every open.
```

## Outline

- L14: `local priorShowHide = ShowHideHandler`
- L15: `local priorInput = InputHandler`
- L17: `local TUTORIAL_ROWS = { ... }`
- L26: `local function completionSuffix(slot)`
- L47: `local function isSelected(slot)`
- L59: `local function buildItems()`
- L96: `BaseMenu.install(ContextPtr, { ... })`

## Notes

- L17 `TUTORIAL_ROWS`: Static table of `{ slot, nameKey, descKey }` records; slot `-1` is the Intro entry which uses a sentinel recognized by `completionSuffix` and `isSelected`.
- L47 `isSelected`: Infers selection state from `SelectHighlight` widget visibility because the base file's `g_iSelected` is a file-local inaccessible from this sandbox.
