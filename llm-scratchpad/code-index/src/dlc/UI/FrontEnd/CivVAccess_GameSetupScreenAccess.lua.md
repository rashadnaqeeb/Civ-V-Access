# `src/dlc/UI/FrontEnd/CivVAccess_GameSetupScreenAccess.lua`

141 lines · Accessibility wiring for the Game Setup Screen (top-level single-player setup), exposing property buttons (civ, map type/size, difficulty, speed) and the scenario checkbox as a flat BaseMenu.

## Header comment

```
-- GameSetup Screen accessibility wiring. Flat parent menu over the
-- property buttons, checkbox, and action row. Property buttons delegate
-- to the base-file OnXxx callbacks, which toggle their inline <LuaContext>
-- child panels; those children install their own BaseMenus on top of this
-- one via their own ShowHide. Current values come from the live label
-- controls (TypeName, SizeName, etc.) so the game's existing setter
-- functions (SetMapTypeForScript, etc.) remain the single source of truth.
-- The Scenario checkbox uses an explicit activateCallback: the base
-- registers OnSenarioCheck via Controls.ScenarioCheck:RegisterCallback
-- rather than RegisterCheckHandler, so PullDownProbe cannot capture it.
```

## Outline

- L14: `local priorShowHide = ShowHideHandler`
- L15: `local priorInput = InputHandler`
- L17: `local function labelFromControl(controlName)`
- L34: `local function civilizationLabel()`
- L43: `BaseMenu.install(ContextPtr, { ... })`

## Notes

- L17 `labelFromControl`: Returns a closure (not a string), used directly as a `labelFn` argument; calling it returns the current text of the named control.
