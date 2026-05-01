# `src/dlc/UI/InGame/Popups/CivVAccess_NewEraPopupAccess.lua`

44 lines · Accessibility wrapper for the new-era notification popup, announcing the era description label with a single Close item.

## Header comment

```
-- NewEraPopup accessibility. DescriptionLabel is populated with
-- "TXT_KEY_POP_NEW_ERA_DESCRIPTION" formatted against the era. Single
-- Close button dismisses via OnClose.
```

## Outline

- L28: `local priorInput = InputHandler`
- L29: `local priorShowHide = ShowHideHandler`
- L30: `BaseMenu.install(ContextPtr, { ... })`
