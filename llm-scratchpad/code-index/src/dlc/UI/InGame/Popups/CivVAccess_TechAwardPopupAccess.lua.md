# `src/dlc/UI/InGame/Popups/CivVAccess_TechAwardPopupAccess.lua`

84 lines · Accessibility wrapper for the technology-completed popup, using silentFirstOpen to avoid interrupting the engine's narrated voice clip while still announcing the tech name via displayName.

## Header comment

```
-- TechAwardPopup accessibility. TechName / TechQuote / TechHelp are the
-- three content labels populated by OnPopup from the awarded Technology.
-- Dismiss button is ContinueButton in BNW (CloseButton is hidden); we
-- wire both and visibility drops the hidden one from navigation.
--
-- Speech model: silentFirstOpen so the engine's narrated tech quote (a
-- voice clip the game plays as the popup appears) is not stepped on by
-- Tolk. The TechName is rolled into displayName via onShow so the first-
-- open announce still tells the user what finished researching. Quote
-- and help stay in the preamble and are reachable on demand via F1.
```

## Outline

- L34: `local priorInput = InputHandler`
- L35: `local priorShowHide = ShowHideHandler`
- L37: `local function labelOf(name)`
- L46: `local function preamble()`
- L55: `local handler = BaseMenu.install(ContextPtr, { ... })`
