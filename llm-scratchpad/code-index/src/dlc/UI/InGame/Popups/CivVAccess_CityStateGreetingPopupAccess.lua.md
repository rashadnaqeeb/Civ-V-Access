# `src/dlc/UI/InGame/Popups/CivVAccess_CityStateGreetingPopupAccess.lua`

64 lines · Minimal accessibility wrapper for the BNW city-state first-meeting popup, announcing the city-state name and gift text with Close and Find On Map buttons.

## Header comment

```
-- CityStateGreetingPopup (BNW) accessibility. Fires the first time the
-- active player meets a city-state; carries the name (TitleLabel), the
-- flavor meeting text + any gold / faith gift (DescriptionLabel), and two
-- action buttons: Close and Find On Map.
--
-- Preamble concatenates TitleLabel and DescriptionLabel so the user hears
-- both the city-state identity and the full gift / "speak again" line on
-- activation.
```

## Outline

- L33: `local priorInput = InputHandler`
- L34: `local priorShowHide = ShowHideHandler`
- L36: `local function preamble()`
- L45: `BaseMenu.install(ContextPtr, { ... })`
