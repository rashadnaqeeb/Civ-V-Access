# `src/dlc/UI/InGame/CivVAccess_ChangePasswordAccess.lua`

84 lines · Accessibility wrapper for the hotseat change/add password modal, wiring three EditBox Textfields and OK/Cancel buttons into a BaseMenu.

## Header comment

```
-- ChangePassword (hotseat add / change password modal) accessibility.
--
-- Pushed modally from PlayerChange when the user activates Change /
-- Add Password. Three EditBoxes (Old / New / Retype) plus OK / Cancel.
-- The OldPassword Textfield is gated on OldPasswordStack visibility,
-- which the base ShowHideHandler hides when the active player has no
-- existing password (Add mode); arrow nav skips it automatically.
--
-- OK is disabled by base Validate until: new + retype are non-empty,
-- character-legal, and identical, and (when shown) the old password
-- matches. Button items announce the disabled state so the user hears
-- why activation isn't doing anything if they hit OK early.
```

## Outline

- L36: `local priorShowHide = ShowHideHandler`
- L37: `local priorInput = InputHandler`
- L39: `BaseMenu.install(ContextPtr, {...})`
