# `src/dlc/UI/Shared/CivVAccess_BaseMenuInstall.lua`

209 lines · ContextPtr wiring layer for BaseMenu handlers; chains ShowHide and InputHandler so a handler pushes/pops on screen show/hide.

## Header comment

```
-- ContextPtr wiring for BaseMenu handlers. Wraps a screen's existing
-- ShowHide / Input handlers so the menu pushes/pops on show/hide, the type-
-- ahead and Esc-back semantics fire, and any prior wiring keeps working.
--
-- Distinct from BaseMenu.create (which produces just the handler object).
-- Help, Pulldown sub-menus, and Options popups push handlers directly onto
-- HandlerStack without an installed Context, so they need create() but not
-- install().
-- [... spec fields documented ...]
```

## Outline

- L36: `function BaseMenu.install(ContextPtr, spec)`
- L197: `function BaseMenu.escOnlyInput(backFn)`
- L209: `return BaseMenu`

## Notes

- L36 `BaseMenu.install`: the `suppressReactivateOnHide` spec fn prevents the freshly-exposed handler from announcing when a sibling Context will push within the same event chain (DiploOverview tab swap).
- L197 `BaseMenu.escOnlyInput`: returns a closure that returns `true` for all input (modal barrier), routing only Esc to `backFn`.
