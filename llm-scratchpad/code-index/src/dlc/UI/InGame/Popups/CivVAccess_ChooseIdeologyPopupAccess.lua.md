# `src/dlc/UI/InGame/Popups/CivVAccess_ChooseIdeologyPopupAccess.lua`

95 lines · Accessibility wrapper for BUTTONPOPUP_CHOOSE_IDEOLOGY presenting the three ideology branches with free-policy counts and a ChooseConfirm sub-overlay.

## Header comment

```
-- ChooseIdeologyPopup accessibility. Own-Context popup opened via
-- Events.SerialEventGameMessagePopup with BUTTONPOPUP_CHOOSE_IDEOLOGY.
-- Three fixed policy branches: Autocracy, Freedom, Order. Each row also
-- lists the civs who have already adopted that ideology and offers a
-- "View Tenets" sub-button; that sub-button is not exposed here because
-- the same information is reachable through the Civilopedia.
--
-- Flow: pick a branch -> SelectIdeologyChoice(branchID) shows the
-- ChooseConfirm overlay with a prompt naming the branch -> we push
-- ChooseConfirmSub over the overlay. Yes fires Network.SendIdeologyChoice
-- via base's OnConfirmYes.
```

## Outline

- L35: `local priorInput = InputHandler`
- L36: `local priorShowHide = ShowHideHandler`
- L38: `local IDEOLOGY_BRANCHES = { ... }`
- L45: `local mainHandler = BaseMenu.install(ContextPtr, { ... })`
- L54: `local function buildItems()`
- L84: `Events.SerialEventGameMessagePopup.Add(...)`
