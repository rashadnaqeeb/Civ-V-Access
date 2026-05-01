# `src/dlc/UI/InGame/CivVAccess_InGameKeys.lua`

43 lines · Installs a HandlerStack-dispatching InputHandler wrapper over the base InGame Context's input handler, so keys that reach the root InGame seat can be suppressed (return true) by mod handlers.

## Header comment

```
-- InGame-Context input hook. Runs in InGame.lua's sandbox (appended at
-- the bottom of our InGame.lua override). The base InGame.lua registers
-- its own InputHandler via ContextPtr:SetInputHandler; we re-register a
-- wrapper that dispatches through our HandlerStack first and, on a miss,
-- falls through to the base handler so engine behaviors (Esc opens the
-- game menu, interface-mode handlers, etc.) continue to work.
--
-- Why here and not on WorldView's ContextPtr alone: WorldView sits earlier
-- in the dispatch chain and catches keys the engine's own WorldView
-- DefaultMessageHandler would otherwise swallow (PageUp/PageDown, arrows,
-- OEM +/-), but it's not the root input seat. InGame is the root in-game
-- Context and its InputHandler receives every global key (that's how base
-- Esc opens the game menu). Suppression via "return true" is only
-- reachable from a Context that sits on that chain, so keys that reach
-- InGame need their own hook here.
--
-- Dependencies are re-included in this sandbox because Civ V Contexts
-- are fenv-sandboxed (per-Context globals); modules defined in WorldView's
-- Boot sandbox are not directly visible here. The HandlerStack state is
-- still shared via civvaccess_shared.stack, so both Contexts read and
-- write the same LIFO of handlers.
```

## Outline

- L23: `include("CivVAccess_Polyfill")`
- L24: `include("CivVAccess_Log")`
- L25: `include("CivVAccess_HandlerStack")`
- L26: `include("CivVAccess_InputRouter")`
- L28: `local WM_KEYDOWN = 256`
- L29: `local WM_SYSKEYDOWN = 260`
- L30: `local basePriorInput = InputHandler`
- L32: `ContextPtr:SetInputHandler(...)`
