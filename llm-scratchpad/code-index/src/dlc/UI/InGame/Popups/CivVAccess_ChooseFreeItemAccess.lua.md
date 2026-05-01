# `src/dlc/UI/InGame/Popups/CivVAccess_ChooseFreeItemAccess.lua`

121 lines · Accessibility wrapper for BUTTONPOPUP_CHOOSE_FREE_GREAT_PERSON (Liberty-tree free Great Person) mirroring the base selection scaffold.

## Header comment

```
-- ChooseFreeItem accessibility (Liberty-tree free Great Person). Own-Context
-- popup opened via Events.SerialEventGameMessagePopup with
-- BUTTONPOPUP_CHOOSE_FREE_GREAT_PERSON. Shares the PopulateItems /
-- CommitItems / SelectedItems scaffold with ChooseGoodyHutReward; see the
-- header of CivVAccess_ChooseGoodyHutRewardAccess.lua for the selection
-- mirror rationale.
--
-- Row eligibility matches base's PopulateItems["GreatPeople"]:
-- player:CanTrain(info.ID, true, true, true, false) and (pantheon or not
-- FoundReligion) -- Liberty's prophet reward is gated behind having a
-- pantheon, same as the sighted screen. Close uses UIManager:DequeuePopup
-- via OnClose (this popup was opened via UIManager:QueuePopup in
-- DisplayPopup, unlike GoodyHut which uses ContextPtr:SetHide).
```

## Outline

- L37: `local priorInput = InputHandler`
- L38: `local priorShowHide = ShowHideHandler`
- L40: `local function selectionStub()`
- L44: `local function preambleText()`
- L57: `local mainHandler = BaseMenu.install(ContextPtr, { ... })`
- L67: `local function buildItems(popupInfo)`
- L110: `Events.SerialEventGameMessagePopup.Add(...)`

## Notes

- L40 `selectionStub`: same fake-control pattern as ChooseFaithGreatPersonAccess; prevents a nil error if base's click handler indexes `SelectionAnim` on a row while our sub is active.
