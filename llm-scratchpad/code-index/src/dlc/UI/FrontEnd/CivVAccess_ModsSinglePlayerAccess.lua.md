# `src/dlc/UI/FrontEnd/CivVAccess_ModsSinglePlayerAccess.lua`

45 lines · Accessibility wiring for the ModsSinglePlayer screen, with inline button-activate bodies copied from the base file's anonymous callbacks.

## Header comment

```
-- ModsSinglePlayer accessibility wiring. Button clicks in the game file
-- are anonymous callbacks so we inline the one-line bodies into activate.
-- PlayMap / CustomGame may SetHide at runtime (already handled by the
-- hidden-walking path in BaseMenu).
```

## Outline

- L9: `BaseMenu.install(ContextPtr, { ... })`
