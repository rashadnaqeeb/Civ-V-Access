# `src/dlc/UI/InGame/Popups/CivVAccess_ChoosePantheonPopupAccess.lua`

116 lines · Accessibility wrapper for BUTTONPOPUP_FOUND_PANTHEON serving both pantheon founding and Reformation belief picking, with locale-sorted belief lists and a ChooseConfirm sub.

## Header comment

```
-- ChoosePantheonPopup accessibility. Own-Context popup opened via
-- Events.SerialEventGameMessagePopup with BUTTONPOPUP_FOUND_PANTHEON.
-- Serves two related screens: the original pantheon founder (Data2 > 0)
-- and the Reformation bonus belief picker (Data2 == 0). Both walk a list
-- of beliefs sorted by short-description locale order.
--
-- Flow: pick a belief -> SelectPantheon(beliefID) shows the ChooseConfirm
-- overlay with the formatted "found {Belief}?" prompt -> we push
-- ChooseConfirmSub which navigates the overlay's Yes / No buttons.
-- Unusually, Pantheon's overlay buttons are named "Yes" / "No" rather
-- than "ConfirmYes" / "ConfirmNo" (the pattern the other Choose* popups
-- use), so we pass the control names through. On Yes, OnYes fires
-- Network.SendFoundPantheon and OnClose dismisses.
```

## Outline

- L37: `local priorInput = InputHandler`
- L38: `local priorShowHide = ShowHideHandler`
- L40: `local function preambleText()`
- L55: `local mainHandler = BaseMenu.install(ContextPtr, { ... })`
- L65: `local function buildItems(popupInfo)`
- L105: `Events.SerialEventGameMessagePopup.Add(...)`

## Notes

- L66 `bPantheons`: `Data2 > 0` selects pantheon founding mode; `Data2 == 0` selects Reformation belief mode -- this popup type serves both phases via the same Context.
