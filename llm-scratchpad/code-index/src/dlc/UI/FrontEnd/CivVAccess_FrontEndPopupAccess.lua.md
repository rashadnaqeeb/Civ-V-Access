# `src/dlc/UI/FrontEnd/CivVAccess_FrontEndPopupAccess.lua`

49 lines · Accessibility wiring for the generic FrontEndPopup dialog, handling the push-then-set race by also refreshing on subsequent `Events.FrontEndPopup` events.

## Header comment

```
-- FrontEndPopup accessibility wiring. The game pushes the popup and then
-- sets Controls.PopupText via Events.FrontEndPopup; a Push-then-set race
-- means our onActivate may run before the text is updated, so we also
-- refresh() on subsequent FrontEndPopup events. The Context can be
-- re-instantiated by the engine, so we stash the latest handler in
-- civvaccess_shared and keep a single listener that resolves it at fire
-- time.
```

## Outline

- L11: `local priorInput = InputHandler`
- L13: `civvaccess_shared._frontEndPopupHandler = BaseMenu.install(ContextPtr, { ... })`
- L34: `if not civvaccess_shared._frontEndPopupRefreshInstalled then`
- L36: `Events.FrontEndPopup.Add(...)`
