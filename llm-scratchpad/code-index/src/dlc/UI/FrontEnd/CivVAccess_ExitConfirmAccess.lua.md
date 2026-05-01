# `src/dlc/UI/FrontEnd/CivVAccess_ExitConfirmAccess.lua`

50 lines · Accessibility wiring for the Exit Confirmation dialog, reading the live `Controls.Message` text as the preamble to surface the correct in-game vs. out-of-game warning variant.

## Header comment

```
-- ExitConfirm accessibility wiring. The game file names its handler
-- OnShowHide (not ShowHideHandler), so we capture that symbol explicitly.
-- PushModal / PopModal still fire the ShowHide handler per the game source.
--
-- Preamble reads Controls.Message after the base OnShowHide has written it:
-- the base picks TXT_KEY_MENU_RETURN_EXIT_WARN in-game (warns that progress
-- won't be saved) vs TXT_KEY_MENU_EXIT_WARN out-of-game, via a LookUpControl
-- check. priorShowHide runs before our push, so GetText returns the
-- context-correct localized message by the time onActivate resolves.
```

## Outline

- L13: `local priorShowHide = OnShowHide`
- L14: `local priorInput = InputHandler`
- L16: `BaseMenu.install(ContextPtr, { ... })`

## Notes

- L13 `priorShowHide`: Captures `OnShowHide`, not `ShowHideHandler` — the base file uses a non-standard name for its show/hide handler.
