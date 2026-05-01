# `src/dlc/UI/InGame/Popups/CivVAccess_NaturalWonderPopupAccess.lua`

55 lines · Accessibility wrapper for the natural wonder discovery popup, announcing the wonder name and yield/bonus description with a single Close item.

## Header comment

```
-- NaturalWonderPopup accessibility. WonderLabel holds the feature name
-- (set from feature.Description in OnPopup); DescriptionLabel holds the
-- yield/happiness/promotion/gold summary. Single Close button dismisses
-- via OnCloseButtonClicked.
```

## Outline

- L28: `local priorInput = InputHandler`
- L29: `local priorShowHide = ShowHideHandler`
- L31: `local function preamble()`
- L41: `BaseMenu.install(ContextPtr, { ... })`
