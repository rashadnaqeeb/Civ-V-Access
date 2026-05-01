# `src/dlc/UI/FrontEnd/CivVAccess_PremiumContentMenuAccess.lua`

103 lines · Accessibility wiring for the PremiumContentMenu (DLC toggle screen), with a custom toggle item type that mutates `g_DLCState` in place and a `RefreshDLC` wrap that rebuilds items after each engine refresh.

## Header comment

```
-- PremiumContentMenu accessibility wiring. Reached from MainMenu's "DLC"
-- button (ExpansionRulesSwitch). The base screen lists every installed
-- package (the two named expansions plus any individual DLC) and lets
-- the user toggle each row's enabled state; OK commits the diff via
-- ContentManager.SetActive, Back cancels.
--
-- Toggle shape: each row's "checked" state lives in g_DLCState[i].Active
-- as a Lua flag, pending until OK -- it isn't bound to any Controls
-- widget, so the existing BaseMenuItems.Checkbox (which reads
-- IsChecked() / writes SetCheck()) can't model it. The toggleItem helper
-- below builds items in the shape BaseMenu duck-types on. Local to this
-- screen on purpose; promote to a shared factory only when a second
-- screen needs the same shape. We don't mirror the base's SetHide on
-- the Enable/Disable buttons -- visuals are irrelevant to the user, and
-- OnOK reads g_DLCState rather than the controls.
--
-- Dynamic rows: non-expansion DLC rows are rebuilt via InstanceManager
-- on every RefreshDLC. The base ShowHide calls RefreshDLC on each open,
-- so we wrap RefreshDLC to follow the base body with a setItems against
-- the fresh g_DLCState. ShowHideHandler resolves RefreshDLC at call
-- time, so reassigning the global takes effect on subsequent invocations.
```

## Outline

- L25: `local priorShowHide = ShowHideHandler`
- L26: `local priorInput = InputHandler`
- L28: `local function toggleItem(spec)`
- L53: `local function buildItems()`
- L85: `local mainHandler`
- L87: `local baseRefreshDLC = RefreshDLC`
- L88: `RefreshDLC = function(...)`
- L96: `mainHandler = BaseMenu.install(ContextPtr, { ... })`

## Notes

- L88 `RefreshDLC`: reassigns the global so the base ShowHide's call to `RefreshDLC` picks up the wrapper; guards on `mainHandler == nil` to skip the first call that fires before `BaseMenu.install` returns.
