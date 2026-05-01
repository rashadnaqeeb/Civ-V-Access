# `src/dlc/UI/InGame/Popups/CivVAccess_GreatPersonRewardPopupAccess.lua`

44 lines · Minimal accessibility wrapper for the GreatPersonRewardPopup, speaking the birth announcement from DescriptionLabel as a preamble with a single Close button.

## Header comment

```
-- GreatPersonRewardPopup accessibility. BUTTONPOPUP_GREAT_PERSON_REWARD pops
-- when a Great Person is born. DescriptionLabel is populated by base OnPopup
-- with TXT_KEY_GREAT_PERSON_REWARD formatted against the unit type and host
-- city. Single Close button dismisses via OnCloseButtonClicked.
```

## Outline

- L28: `local priorInput = InputHandler`
- L29: `local priorShowHide = ShowHideHandler`
- L31: `BaseMenu.install(ContextPtr, { ... })`
