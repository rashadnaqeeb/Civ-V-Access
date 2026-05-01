# `src/dlc/UI/InGame/Popups/CivVAccess_ChooseArchaeologyPopupAccess.lua`

187 lines · Accessibility wrapper for BUTTONPOPUP_CHOOSE_ARCHAEOLOGY that offers artifact, writing, landmark, or cultural renaissance choices depending on dig context.

## Header comment

```
-- ChooseArchaeologyPopup accessibility. Own-Context popup opened via
-- Events.SerialEventGameMessagePopup with BUTTONPOPUP_CHOOSE_ARCHAEOLOGY.
-- Offers up to three options on a completed dig, driven by the plot's
-- artifact type and the player's free Great Work slots:
--
-- Not a written artifact (bWrittenArtifact false):
--   - Player 1 artifact (if an artifact slot is open), choice value 2
--   - Player 2 artifact (if applicable and artifact slot is open),
--     choice value 3
--   - Landmark, choice value 1
-- Written artifact (bWrittenArtifact true):
--   - Create Great Work of Writing (if a literature slot is open),
--     choice value 5
--   - Cultural Renaissance (culture burst), choice value 4
--
-- bShow2ndPlayer is false for barbarian-camp and ancient-ruin artifacts;
-- those have only one participant. Flow: pick option -> base
-- SelectArchaeologyChoice stashes g_iChoice and shows the ChooseConfirm
-- overlay -> we push ChooseConfirmSub. Yes fires Network.SendArchaeologyChoice
-- via base's OnConfirmYes (and, for choice 5, also re-fires
-- BUTTONPOPUP_GREAT_WORK_COMPLETED_ACTIVE_PLAYER to show the splash).
```

## Outline

- L45: `local priorInput = InputHandler`
- L46: `local priorShowHide = ShowHideHandler`
- L48: `local function preambleText()`
- L73: `local mainHandler = BaseMenu.install(ContextPtr, { ... })`
- L83: `local function confirmActivate(choice)`
- L96: `local TWO_PLAYER_CLASSES = { ... }`
- L103: `local function buildItems()`
- L176: `Events.SerialEventGameMessagePopup.Add(...)`

## Notes

- L96 `TWO_PLAYER_CLASSES`: lookup table used to replicate base's `bShow2ndPlayer` flag; determines whether a second artifact participant is shown.
- L83 `confirmActivate`: factory returning a closure that calls `SelectArchaeologyChoice` then pushes `ChooseConfirmSub`; the integer argument maps to the base-popup's `g_iChoice` constants.
