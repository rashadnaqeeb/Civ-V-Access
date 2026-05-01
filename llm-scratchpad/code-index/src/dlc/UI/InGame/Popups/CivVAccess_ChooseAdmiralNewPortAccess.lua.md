# `src/dlc/UI/InGame/Popups/CivVAccess_ChooseAdmiralNewPortAccess.lua`

121 lines · Accessibility wrapper for BUTTONPOPUP_CHOOSE_ADMIRAL_PORT, letting the Great Admiral pick a new home port with a ChooseConfirm sub-overlay.

## Header comment

```
-- ChooseAdmiralNewPort accessibility. Own-Context popup opened via
-- Events.SerialEventGameMessagePopup with BUTTONPOPUP_CHOOSE_ADMIRAL_PORT.
-- Offers the Great Admiral a choice of home cities to re-base at (the
-- engine resolves movement range and owner rules; we read the filtered
-- list via pPlayer:GetPotentialAdmiralNewPort(pUnit)).
--
-- Flow: pick a city -> base SelectNewHome(x, y) stashes the plot coords
-- and shows the ChooseConfirm overlay -> we push ChooseConfirmSub. Yes
-- fires Game.SelectionListGameNetMessage(MISSION_CHANGE_ADMIRAL_PORT)
-- via base's OnConfirmYes. A trailing Close item bypasses to the base's
-- CloseButton (also mapped to Esc via priorInput).
```

## Outline

- L36: `local priorInput = InputHandler`
- L37: `local priorShowHide = ShowHideHandler`
- L39: `local function preambleText()`
- L55: `local mainHandler = BaseMenu.install(ContextPtr, { ... })`
- L65: `local function buildItems(popupInfo)`
- L110: `Events.SerialEventGameMessagePopup.Add(...)`
