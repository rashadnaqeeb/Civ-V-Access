# `src/dlc/UI/InGame/Popups/CivVAccess_LeagueSplashAccess.lua`

66 lines · Accessibility wrapper for the World Congress founding/session splash popup, announcing title and era bullet labels as the preamble with a single Close item.

## Header comment

```
-- LeagueSplash accessibility (World Congress founding / session splash).
-- TitleLabel is dynamic (pLeague:GetLeagueSplashTitle), DescriptionLabel
-- holds the narrative, ThisEraLabel / NextEraLabel hold era bullet lists.
-- Single Close button dismisses via OnClose.
```

## Outline

- L28: `local priorInput = InputHandler`
- L29: `local priorShowHide = ShowHideHandler`
- L31: `local function labelOf(name)`
- L39: `local function preamble()`
- L52: `BaseMenu.install(ContextPtr, { ... })`
