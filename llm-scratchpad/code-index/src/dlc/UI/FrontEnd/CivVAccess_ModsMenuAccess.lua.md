# `src/dlc/UI/FrontEnd/CivVAccess_ModsMenuAccess.lua`

39 lines · Accessibility wiring for the ModsMenu screen (SinglePlayer / MultiPlayer / Back), with an enabled-mods preamble and Esc-only input forwarding.

## Header comment

```
-- ModsMenu accessibility wiring. SinglePlayer / MultiPlayer buttons get
-- SetDisabled based on mod-property gating, so we want the handler to walk
-- disabled items and announce them as "disabled" without firing activate.
-- ShowHide and InputHandler in the game file are anonymous; priorInput
-- reproduces the original Esc -> NavigateBack routing.
```

## Outline

- L10: `BaseMenu.install(ContextPtr, { ... })`
