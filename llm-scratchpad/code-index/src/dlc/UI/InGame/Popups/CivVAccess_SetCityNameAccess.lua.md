# `src/dlc/UI/InGame/Popups/CivVAccess_SetCityNameAccess.lua`

55 lines · Accessibility wrapper for the rename-city dialog, wiring a Textfield with the base Validate callback plus Accept and Cancel buttons.

## Header comment

```
-- SetCityName (rename-city dialog) accessibility. Textfield plus Accept /
-- Cancel. Shape matches AdvancedSetup's MaxTurnsEdit: the edit box's
-- CallOnChar=1 drives the base's Validate on every keystroke, which
-- toggles AcceptButton disabled state; Textfield edit mode routes keys
-- straight through so validation keeps firing.
```

## Outline

- L29: `local priorInput = InputHandler`
- L30: `local priorShowHide = ShowHideHandler`
- L32: `BaseMenu.install(ContextPtr, { ... })`
