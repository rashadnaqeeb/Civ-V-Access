# `src/dlc/UI/FrontEnd/CivVAccess_ScenariosMenuAccess.lua`

96 lines · Accessibility wiring for the ScenariosMenu screen, with replicated anonymous ShowHide and StartButton callback bodies and a dynamic item list rebuilt on each show from `g_ScenarioList`.

## Header comment

```
-- ScenariosMenu accessibility wiring. Base registers both its ShowHide
-- and its InputHandler as anonymous callbacks (ScenariosMenu.lua lines
-- 58 and 67), so there are no priorShowHide / priorInput globals to
-- forward; the base's side effects (ActivateDLC, LoadPreGameSettings,
-- SetupFileButtonList, Esc -> OnBack) are replicated below. The
-- StartButton click callback is anonymous too (line 29) so we replicate
-- that body in startScenario.
--
-- Selection is two-step: activating a scenario entry calls SetSelected(i)
-- (which updates base's details pane, gates StartButton's disabled
-- state, and lights the SelectHighlight); the user then navigates to
-- Start to launch. Keeping Start as a separate item mirrors the sighted
-- flow of browse-then-commit.
```

## Outline

- L20: `local function startScenario()`
- L43: `local function runPriorShow()`
- L54: `local function buildItems()`
- L86: `BaseMenu.install(ContextPtr, { ... })`
