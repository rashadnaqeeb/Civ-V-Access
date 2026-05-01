# `src/dlc/UI/Shared/CivVAccess_TickPump.lua`

74 lines · Per-frame pump wired to `ContextPtr:SetUpdate` that maintains a shared frame counter, drains a one-shot callback queue, and forwards `tick()` to the active `HandlerStack` handler.

## Header comment

```
-- Per-frame pump wired to ContextPtr:SetUpdate. Owns the monotonic frame
-- counter, drains the one-shot queue, and forwards tick() to the active
-- handler if it defines one.
--
-- State lives on civvaccess_shared because Civ V Contexts are fenv-sandboxed:
-- each Context that include()s this file gets its own _frame / _oneShots
-- locals otherwise, and a runOnce() queued from one Context would never
-- drain when another Context's SetUpdate fires tick(). Keeping the frame
-- counter and queue shared means any pumping Context drains callbacks
-- scheduled from any other Context.
--
-- TickPump must be the sole owner of SetUpdate on any Context where it is
-- installed (SetUpdate is replace-semantics; a second caller silently
-- unhooks the first). Installing on multiple Contexts is safe: each
-- Context's SetUpdate calls tick(), the shared queue drains on whichever
-- fires first, and the drain clears the queue so later ticks no-op.
```

## Outline

- L18: `TickPump = {}`
- L20: `civvaccess_shared = civvaccess_shared or {}`
- L21: `civvaccess_shared.tickFrame = civvaccess_shared.tickFrame or 0`
- L22: `civvaccess_shared.tickOneShots = civvaccess_shared.tickOneShots or {}`
- L24: `function TickPump._reset()`
- L29: `function TickPump.frame()`
- L36: `function TickPump.runOnce(fn)`
- L41: `function TickPump.tick()`
- L72: `function TickPump.install(ctx)`

## Notes

- L41 `TickPump.tick`: snapshots and clears `tickOneShots` before iterating so a callback that itself calls `runOnce` schedules for the next tick rather than the current one.
- L72 `TickPump.install`: has no idempotency guard; re-calling it rewires `SetUpdate` cleanly after a Context rebuild, which is intentional.
