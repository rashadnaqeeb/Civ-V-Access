# `src/dlc/UI/FrontEnd/CivVAccess_EULAAccess.lua`

29 lines · Accessibility wiring for the EULA screen, reading the license body as the preamble and exposing Decline/Accept buttons.

## Header comment

```
-- EULA accessibility wiring. The game file's ShowHide body is commented out
-- and its InputHandler is anonymous, so we cannot capture a prior symbol;
-- we re-register a minimal Esc handler here that routes to the game's
-- NavigateBack global.
```

## Outline

- L8: `BaseMenu.install(ContextPtr, { ... })`
