# `src/dlc/UI/FrontEnd/CivVAccess_MainMenuAccess.lua`

75 lines · Accessibility wiring for the Main Menu, exposing the primary navigation buttons (Single Player, Multiplayer, Mods, Options, Other, expansion switch, Exit) as a flat BaseMenu with deferred activation to handle the EULA-accept popup transition.

## Header comment

```
-- MainMenu accessibility wiring. Included from the MainMenu.lua override
-- after the game's own code has run, so ShowHideHandler is already a live
-- global. MainMenu doesn't install an InputHandler, so priorInput is nil
-- and Esc on MainMenu is silently discarded by the install wrapper.
--
-- Hidden promo buttons (MapPack2/3, AcePatrol, TouchHelp) are omitted from
-- the list — they're date-gated and usually invisible; add them back if a
-- future promo matters to players.
```

## Outline

- L12: `local priorShowHide = ShowHideHandler`
- L18: `BaseMenu.install(ContextPtr, { ... })`

## Notes

- L18 `deferActivate = true`: Prevents the handler from announcing on the brief hide/show pair that occurs when EULA acceptance synchronously transitions popups within a single frame.
