# `src/dlc/UI/FrontEnd/CivVAccess_SetCivNamesAccess.lua`

91 lines · Accessibility wiring for the SetCivNames modal (custom leader/civ/nickname/password fields), with `Validate` as `priorCallback` on each text field so `AcceptButton`'s disabled state updates on every keystroke.

## Header comment

```
-- SetCivNames accessibility wiring. Modal opened from GameSetupScreen via
-- UIManager:PushModal when the user activates the Edit button on the civ
-- tile. Contains four text fields (leader / civ name / short name /
-- adjective) plus an Accept and Cancel button; in hot-seat mode, a nick-
-- name field and a "use password" checkbox with two password fields also
-- appear, gated by PasswordStack visibility.
--
-- Each textfield's priorCallback is the base file's Validate function,
-- which enables / disables AcceptButton based on live field contents;
-- live isActivatable reads IsDisabled and announces "disabled" on Accept
-- until every required field has legal content.
--
-- UsePasswordCheck is wired via RegisterCallback(Mouse.eLClick, Validate)
-- in the base, so PullDownProbe cannot capture the handler -- we pass
-- Validate explicitly as activateCallback.
```

## Outline

- L19: `local priorShowHide = ShowHideHandler`
- L20: `local priorInput = InputHandler`
- L22: `BaseMenu.install(ContextPtr, { ... })`
