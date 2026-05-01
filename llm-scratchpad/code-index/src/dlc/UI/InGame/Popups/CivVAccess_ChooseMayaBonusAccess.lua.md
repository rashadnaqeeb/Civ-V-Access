# `src/dlc/UI/InGame/Popups/CivVAccess_ChooseMayaBonusAccess.lua`

128 lines · Accessibility wrapper for BUTTONPOPUP_CHOOSE_MAYA_BONUS that filters great-person choices by baktun history and free-choice flag.

## Header comment

```
-- ChooseMayaBonus accessibility. Own-Context popup opened via
-- Events.SerialEventGameMessagePopup with BUTTONPOPUP_CHOOSE_MAYA_BONUS.
-- Fires at the end of each Maya long-count baktun. Shares the
-- PopulateItems / CommitItems / SelectedItems scaffold with
-- ChooseGoodyHutReward; see that file's header for the selection mirror
-- rationale.
--
-- Row eligibility: player:CanTrain(info.ID, ...) AND (either this is a
-- free Maya great-person choice OR the unit hasn't already been taken in
-- an earlier baktun). player:GetUnitBaktun(info.ID) > 0 signals a
-- prior pick; player:IsFreeMayaGreatPersonChoice() waives that gate (the
-- one-off "free choice" every civ gets on their first baktun roll).
```

## Outline

- L36: `local priorInput = InputHandler`
- L37: `local priorShowHide = ShowHideHandler`
- L39: `local function selectionStub()`
- L43: `local function isEnabled(player, info)`
- L54: `local function preambleText()`
- L67: `local mainHandler = BaseMenu.install(ContextPtr, { ... })`
- L77: `local function buildItems(popupInfo)`
- L117: `Events.SerialEventGameMessagePopup.Add(...)`
