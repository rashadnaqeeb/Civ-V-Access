# `src/dlc/UI/FrontEnd/CivVAccess_MultiplayerSelectAccess.lua`

90 lines · Accessibility wiring for the MultiplayerSelect screen, with dynamic Internet tooltip based on Steam connection state and post-activate revalidation to handle Standard/Pitboss toggle-visibility behavior.

## Header comment

```
-- MultiplayerSelect accessibility wiring. Standard and Pitboss don't
-- navigate; they toggle visibility so Internet/LAN replace
-- Standard/HotSeat/Pitboss in place. BaseMenu's post-activate revalidation
-- catches the flipped-hidden item and announces the next valid one so the
-- user hears that something changed.
--
-- ReconnectButton is shown only when Network.HasReconnectCache() is true;
-- InternetButton is disabled when not connected to Steam but not hidden
-- (users can still hit Enter on it and the game's own handler no-ops). The
-- screen sets a "not connected to Steam" tooltip in that state via
-- LocalizeAndSetToolTip; we re-check the same network flag at announce
-- time since there is no Lua API to read the stored tooltip back, falling
-- back to the static button tooltip when connected.
```

## Outline

- L17: `local priorShowHide = ShowHideHandler`
- L18: `local priorInput = InputHandler`
- L20: `local function internetTooltipFn()`
- L27: `BaseMenu.install(ContextPtr, { ... })`
