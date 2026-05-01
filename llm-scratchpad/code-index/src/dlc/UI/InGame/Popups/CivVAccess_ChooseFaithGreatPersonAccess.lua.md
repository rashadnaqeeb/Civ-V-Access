# `src/dlc/UI/InGame/Popups/CivVAccess_ChooseFaithGreatPersonAccess.lua`

158 lines · Accessibility wrapper for BUTTONPOPUP_CHOOSE_FAITH_GREAT_PERSON that lists faith-purchasable great people filtered by policy-branch eligibility.

## Header comment

```
-- ChooseFaithGreatPerson accessibility. Own-Context popup opened via
-- Events.SerialEventGameMessagePopup with
-- BUTTONPOPUP_CHOOSE_FAITH_GREAT_PERSON. Shares the PopulateItems /
-- CommitItems / SelectedItems scaffold with ChooseGoodyHutReward; see the
-- header of CivVAccess_ChooseGoodyHutRewardAccess.lua for the selection
-- mirror rationale.
--
-- Row eligibility is layered: outer filter is player:CanTrain, but the
-- base inline-disables specific great-person types that require a finished
-- policy branch (Merchant / Commerce, Scientist / Rationalism,
-- Writer|Artist|Musician / Aesthetics, General / Honor, Admiral /
-- Exploration, Engineer / Tradition) or, for Prophet, require both a
-- pantheon and religion-founding availability. We replicate the same gate
-- in isEnabled so our item list only offers pickable choices rather than
-- offering a choice that CommitItems / Network.SendFaithGreatPersonChoice
-- would silently discard.
```

## Outline

- L40: `local priorInput = InputHandler`
- L41: `local priorShowHide = ShowHideHandler`
- L43: `local function selectionStub()`
- L47: `local function branchFinished(player, branchType)`
- L55: `local function isEnabled(player, info)`
- L84: `local function preambleText()`
- L97: `local mainHandler = BaseMenu.install(ContextPtr, { ... })`
- L107: `local function buildItems(popupInfo)`
- L147: `Events.SerialEventGameMessagePopup.Add(...)`

## Notes

- L43 `selectionStub`: returns a fake control-table satisfying the base popup's `v[2].SelectionAnim:SetHide()` call on re-selection; the blind player cannot observe the animation.
- L55 `isEnabled`: replicates base's per-unit-type policy-branch gate to avoid offering choices the engine would silently reject at commit.
