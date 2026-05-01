# `src/dlc/UI/InGame/Popups/CivVAccess_GoldenAgePopupAccess.lua`

43 lines · Minimal accessibility wrapper for the GoldenAgePopup, speaking the flavor text from DescriptionLabel as a preamble with a single Close button.

## Header comment

```
-- GoldenAgePopup accessibility. DescriptionLabel (populated by OnPopup from
-- TXT_KEY_GOLDEN_AGE_FLAVOR) holds the flavor text. Single Close button
-- dismisses via OnCloseButtonClicked.
```

## Outline

- L27: `local priorInput = InputHandler`
- L28: `local priorShowHide = ShowHideHandler`
- L30: `BaseMenu.install(ContextPtr, { ... })`
