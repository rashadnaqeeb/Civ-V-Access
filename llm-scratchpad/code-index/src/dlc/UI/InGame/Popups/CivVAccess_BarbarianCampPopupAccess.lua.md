# `src/dlc/UI/InGame/Popups/CivVAccess_BarbarianCampPopupAccess.lua`

43 lines · Minimal accessibility wrapper for the barbarian-camp-cleared reward popup, announcing the reward text and offering a Close button.

## Header comment

```
-- BarbarianCampPopup accessibility. DescriptionLabel (populated by OnPopup)
-- holds the reward text. Single Close button dismisses via
-- OnCloseButtonClicked; engine's Esc/Enter fallbacks already invoke it.
```

## Outline

- L27: `local priorInput = InputHandler`
- L28: `local priorShowHide = ShowHideHandler`
- L30: `BaseMenu.install(ContextPtr, { ... })`
