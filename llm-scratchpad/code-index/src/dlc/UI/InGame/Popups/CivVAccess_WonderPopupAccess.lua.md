# `src/dlc/UI/InGame/Popups/CivVAccess_WonderPopupAccess.lua`

78 lines · Accessibility wrapper for the wonder-completed popup, using silentFirstOpen to avoid interrupting the engine's narrated voice clip while still announcing the wonder name via displayName.

## Header comment

```
-- WonderPopup accessibility. Title holds the wonder name, Quote the
-- flavor quote, Stats the help/bonus text (all populated by OnPopup from
-- the selected Building row). Single Close button dismisses via OnClose.
--
-- Speech model: silentFirstOpen so the engine's narrated wonder quote (a
-- voice clip the game plays as the popup appears) is not stepped on by
-- Tolk. The wonder name is rolled into displayName via onShow so the
-- first-open announce still tells the user which wonder was built. Quote
-- and stats stay in the preamble and are reachable on demand via F1.
```

## Outline

- L34: `local priorInput = InputHandler`
- L35: `local priorShowHide = ShowHideHandler`
- L37: `local function labelOf(name)`
- L45: `local function preamble()`
- L54: `BaseMenu.install(ContextPtr, { ... })`
