# `src/dlc/UI/FrontEnd/CivVAccess_ModsMultiplayerAccess.lua`

68 lines · Accessibility wiring for the ModsMultiplayer screen, including dynamic tooltip for the Internet button based on live Steam connectivity.

## Header comment

```
-- ModsMultiplayer accessibility wiring. ShowHide / InputHandler are named.
-- Internet button is SetDisabled when Steam is offline; Reconnect is
-- SetHide+SetDisabled when no reconnect cache exists — both states are
-- handled by BaseMenu's hidden-skip and disabled-walk paths.
-- Internet's "why disabled" tooltip mirrors MultiplayerSelect's wiring:
-- the screen sets it via LocalizeAndSetToolTip, and we re-check
-- Network.IsConnectedToSteam at announce time.
```

## Outline

- L12: `local priorShowHide = ShowHideHandler`
- L13: `local priorInput = InputHandler`
- L15: `local function internetTooltipFn()`
- L22: `BaseMenu.install(ContextPtr, { ... })`
