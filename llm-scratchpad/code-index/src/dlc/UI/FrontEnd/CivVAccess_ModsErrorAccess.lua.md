# `src/dlc/UI/FrontEnd/CivVAccess_ModsErrorAccess.lua`

31 lines · Accessibility wiring for the ModsError popup, with a dynamic preamble that reads the live ErrorText label so the spoken body reflects whatever error the engine just set.

## Header comment

```
-- ModsError accessibility wiring. Dynamic preamble reads the live
-- ErrorText label so the spoken body matches whatever the engine just
-- populated (error text is set by the caller before the popup shows).
```

## Outline

- L7: `local priorShowHide = ShowHideHandler`
- L8: `local priorInput = InputHandler`
- L10: `BaseMenu.install(ContextPtr, { ... })`
