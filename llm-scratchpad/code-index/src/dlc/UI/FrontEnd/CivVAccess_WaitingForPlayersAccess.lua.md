# `src/dlc/UI/FrontEnd/CivVAccess_WaitingForPlayersAccess.lua`

21 lines · Accessibility wiring for the WaitingForPlayers splash screen, announcing only for multiplayer and hotseat sessions (not the brief SP load flash).

## Header comment

```
-- WaitingForPlayers accessibility wiring. Status splash the engine shows
-- during load while one or more players haven't finished. In MP / hotseat
-- the message applies; in SP the engine still flashes this screen briefly
-- even though there is no peer to wait on, so skip the announce via
-- shouldActivate (LoadScreen handles the SP load cue).
```

## Outline

- L9: `local priorShowHide = ShowHide`
- L11: `BaseMenu.install(ContextPtr, { ... })`

## Notes

- L9 `priorShowHide`: captures `ShowHide` (not `ShowHideHandler`), which is the name used in this particular base file.
