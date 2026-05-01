# `src/dlc/UI/Shared/CivVAccess_InputRouter.lua`

188 lines · Stateless keyboard dispatcher that walks the `HandlerStack` top-first, with pre-walk hooks for hotseat mute (Ctrl+Shift+F12), help (?), settings (F12), and type-ahead search.

## Header comment

```
-- Dispatches keyboard events down the HandlerStack, top-first. Stateless.
-- Called from each screen's SetInputHandler (via BaseMenu.install for
-- front-end screens, directly from in-game handlers).
--
-- Pre-walk hooks (run before the binding walk):
--   1. Ctrl+Shift+F12 toggles the hotseat hard-mute. Runs first so the
--      toggle works in both states; on enter-mute it cuts in-flight speech
--      and short-circuits all subsequent dispatch (no Help, no Settings,
--      no search, no bindings) so the sighted player's keys reach the
--      engine. HandlerStack push/pop continue normally so the stack stays
--      consistent for unmute.
--   2. Shift+? opens the Help overlay built from HandlerStack.collectHelpEntries.
--      Gated so pressing ? while Help is on top doesn't re-enter.
--   3. F12 opens the Settings overlay. Gated so the in-menu close binding
--      can fire when Settings is already on top.
--   4. Type-ahead search: if the top handler exposes handleSearchInput, route
--      printable / Backspace / Space through it so every BaseMenu-backed
--      handler (installed or pushed directly) gets search without needing 40+
--      per-letter bindings.
```

## Outline

- L21: `InputRouter = {}`
- L23: `civvaccess_shared = civvaccess_shared or {}`
- L27: `InputRouter._timeSource = os.clock`
- L29: `local _lastMuteToggleTime = -math.huge`
- L35: `local MUTE_TOGGLE_DEBOUNCE_SECONDS = 0.2`
- L37: `local WM_KEYDOWN = 256`
- L38: `local WM_SYSKEYDOWN = 260`
- L40: `local MOD_SHIFT = 1`
- L41: `local MOD_CTRL = 2`
- L42: `local MOD_ALT = 4`
- L47: `local VK_OEM_2 = 191`
- L48: `local VK_F12 = 123`
- L50: `function InputRouter.currentModifierMask()`
- L69: `function InputRouter.dispatch(keyCode, modMask, msg)`

## Notes

- L69 `InputRouter.dispatch`: the mute toggle (Ctrl+Shift+F12) fires even when muted; entering mute short-circuits all further dispatch so unbound keys fall through to the engine for sighted players.
- L69 `InputRouter.dispatch`: only `WM_KEYDOWN` routes through the type-ahead hook; `WM_SYSKEYDOWN` (Alt-chorded) skips it.
- L69 `InputRouter.dispatch`: a `capturesAllInput` handler stops the walk but may declare `passthroughKeys` (keyed by keycode) to let specific keys (F-row, Escape) still fall through to the engine.
