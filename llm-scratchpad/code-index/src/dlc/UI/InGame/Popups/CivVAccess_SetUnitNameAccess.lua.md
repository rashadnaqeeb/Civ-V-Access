# `src/dlc/UI/InGame/Popups/CivVAccess_SetUnitNameAccess.lua`

52 lines · Accessibility wrapper for the rename-unit dialog, wiring a Textfield with the base Validate callback plus Accept and Cancel buttons.

## Header comment

```
-- SetUnitName (rename-unit dialog) accessibility. Textfield plus Accept /
-- Cancel, identical shape to SetCityName.
```

## Outline

- L27: `local priorInput = InputHandler`
- L28: `local priorShowHide = ShowHideHandler`
- L30: `BaseMenu.install(ContextPtr, { ... })`
