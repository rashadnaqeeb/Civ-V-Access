# `src/dlc/UI/InGame/Popups/CivVAccess_GoodyHutPopupAccess.lua`

45 lines · Minimal accessibility wrapper for the GoodyHutPopup (informational variant), speaking the reward description from DescriptionLabel as a preamble with a single Close button.

## Header comment

```
-- GoodyHutPopup accessibility (informational variant). DescriptionLabel is
-- populated by OnPopup from the selected GoodyHuts row's Description,
-- formatted with Data2 (gold/culture/faith amount) when applicable. The
-- choice-picker popup is a separate Context (ChooseGoodyHutReward) and
-- not handled here. Single Close button dismisses via OnCloseButtonClicked.
```

## Outline

- L29: `local priorInput = InputHandler`
- L30: `local priorShowHide = ShowHideHandler`
- L32: `BaseMenu.install(ContextPtr, { ... })`
