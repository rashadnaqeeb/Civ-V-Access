# `src/dlc/UI/InGame/Popups/CivVAccess_TextPopupAccess.lua`

44 lines · Accessibility wrapper for the generic text/informational popup, announcing the DescriptionLabel body with a single Close item.

## Header comment

```
-- TextPopup accessibility. Informational popup with a single Close/OK
-- button; DescriptionLabel holds the body text set via OnPopup. Close and
-- the engine's Esc/Enter fallbacks dismiss via OnCloseButtonClicked.
```

## Outline

- L28: `local priorInput = InputHandler`
- L29: `local priorShowHide = ShowHideHandler`
- L31: `BaseMenu.install(ContextPtr, { ... })`
