# `src/dlc/UI/InGame/CivVAccess_WorldViewKeys.lua`

57 lines · WorldView-Context input hook that wraps the base WorldView InputHandler to dispatch through HandlerStack first, enabling scanner PageUp/PageDown bindings to fire before WorldView's DefaultMessageHandler swallows them.

## Header comment

```
-- WorldView-Context input hook. Runs in WorldView.lua's sandbox (appended
-- at the bottom of our WorldView.lua override). The base WorldView
-- registers its own InputHandler via ContextPtr:SetInputHandler; we
-- re-register a wrapper that dispatches through our HandlerStack first
-- and, on a miss, falls through to the base handler so camera pan /
-- zoom / strategic-view toggle continue to work for sighted testers.
--
-- Why here in addition to InGame: WorldView is a child LuaContext under
-- InGame and sits earlier in the input dispatch chain. Its
-- DefaultMessageHandler returns true for VK_PRIOR / VK_NEXT (plus arrows
-- and OEM_PLUS/MINUS), so without this hook the scanner's PageUp/PageDown
-- cycle bindings with any modifier layer are swallowed before InGame's
-- InputHandler ever runs. Cursor keys (Q/A/D/Z/C) are not bound in
-- WorldView and bubble to InGame today -- those still work fine; this
-- hook is specifically for the keys WorldView would otherwise eat.
--
-- On dispatch hit, we return true and InGame never runs, so bindings
-- fire exactly once. On miss, we return false and InGame's own
-- InputRouter wrapper walks the same stack a second time; that is a
-- deterministic no-op (same bindings, same event) and costs one extra
-- small-loop pass per unbound keypress.
--
-- Dependencies are re-included in this sandbox because Civ V Contexts
-- are fenv-sandboxed (per-Context globals); HandlerStack state is still
-- shared via civvaccess_shared.stack, so both Contexts read and write
-- the same LIFO of handlers.
```

## Outline

- L28: `include("CivVAccess_Polyfill")`
- L29: `include("CivVAccess_Log")`
- L30: `include("CivVAccess_HandlerStack")`
- L31: `include("CivVAccess_InputRouter")`
- L32: `include("CivVAccess_TickPump")`
- L34: `local WM_KEYDOWN = 256`
- L35: `local WM_SYSKEYDOWN = 260`
- L36: `local basePriorInput = InputHandler`
- L38: `ContextPtr:SetInputHandler(...)`
- L54: `TickPump.install(ContextPtr)`
- L56: `Log.info(...)`

## Notes

- L36 `basePriorInput`: captures the base WorldView's `InputHandler` global before overwriting it so the wrapper can fall through to base camera/zoom behavior on a HandlerStack miss.
- L54 `TickPump.install`: redundant with the call in Boot.lua (included above this file in WorldView.lua); `SetUpdate` is replace-semantics so this is effectively a no-op, but kept to make WorldViewKeys' TickPump dependency explicit.
