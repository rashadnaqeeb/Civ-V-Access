# `src/dlc/UI/FrontEnd/CivVAccess_JoiningRoomAccess.lua`

57 lines · Accessibility wiring for the multiplayer JoiningRoom status splash, refreshing the preamble from the live `Controls.JoiningLabel` as each handshake phase completes.

## Header comment

```
-- JoiningRoom accessibility wiring. Status splash during multiplayer
-- handshake; no buttons, but Controls.JoiningLabel changes as each phase
-- completes (room join -> host connect -> net registered). Dynamic
-- preamble reads the live label; refresh() runs on the three progress
-- events.
--
-- Ordering matters: the game's own OnJoinRoomComplete / OnHostConnect /
-- OnNetRegistered handlers are the ones that actually update the label,
-- and they're installed inside the game's ShowHideHandler on first show.
-- We wrap priorShowHide so our Events.X.Add calls happen AFTER the game
-- registers its handlers; .Add chains, so our listener then fires after
-- the game's and reads the updated label.
```

## Outline

- L16: `local priorShowHide = ShowHideHandler`
- L17: `local priorInput = InputHandler`
- L19: `local function wrappedPriorShowHide(bIsHide, bIsInit)`
- L45: `civvaccess_shared._joiningRoomHandler = BaseMenu.install(ContextPtr, { ... })`

## Notes

- L19 `wrappedPriorShowHide`: Delays `Events.MultiplayerJoinRoomComplete/ConnectedToNetworkHost/MultiplayerNetRegistered` listener registration until after the base ShowHide has run (and installed the game's own label-update handlers), so our refresh fires after the label is already updated.
