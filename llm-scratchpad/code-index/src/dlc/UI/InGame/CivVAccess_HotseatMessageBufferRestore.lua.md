# `src/dlc/UI/InGame/CivVAccess_HotseatMessageBufferRestore.lua`

66 lines · Hotseat-only per-player MessageBuffer swap on Events.GameplaySetActivePlayer: saves the outgoing player's civvaccess_shared.messageBuffer and restores the incoming player's saved buffer (or nil for a fresh lazy-create).

## Header comment

```
-- Hotseat-only per-player MessageBuffer save / restore. Mirrors
-- HotseatCursor: save each human player's buffer state (entries, filter,
-- position) when active player swaps away, swap their saved state back in
-- when they become active again. Without a saved entry (first activation,
-- or installListeners-cleared after load-from-game), leave
-- civvaccess_shared.messageBuffer nil so MessageBuffer.state() lazy-creates
-- a fresh table on next access.
--
-- Per-session, in-memory only. Buffer entries reference unit / city / turn
-- details that don't survive load-from-game, so the saved table is wiped
-- at every onInGameBoot.
--
-- Hooked to Events.GameplaySetActivePlayer. The engine fires this event
-- only when the active player actually changes (CvGame.cpp:5584's
-- eOldActivePlayer != eNewValue gate), and in hotseat only humans become
-- the active player (CvPlayer.cpp:15812's setActivePlayer call inside
-- setTurnActive is gated on isHuman()). So under normal play both iActive
-- and iPrev are humans here; the IsHuman gate is defensive parity with
-- HotseatCursor.
```

## Outline

- L21: `HotseatMessageBuffer = {}`
- L23: `local saved = {}`
- L25: `function HotseatMessageBuffer._onActivePlayerChanged(iActive, iPrev)`
- L45: `function HotseatMessageBuffer.installListeners()`
- L63: `function HotseatMessageBuffer._reset()`
