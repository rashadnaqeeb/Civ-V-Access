# `src/dlc/UI/InGame/CivVAccess_MultiplayerTurnEnd.lua`

115 lines · Announces when remote human players end their turn in networked MP by diffing HasReceivedNetTurnComplete against a per-turn announced-set stored on civvaccess_shared.

## Header comment

```
-- Per-remote-player turn-end announcement for networked multiplayer.
-- Civ V's only sighted-player cue when a remote human ends their turn is
-- the MPList row dimming on the right side of the HUD; without speech, a
-- blind player has no way to tell who is still acting and who the wave
-- is waiting on. This module routes each remote-human turn-end into a
-- queued speech line plus a "notification" entry in the message buffer.
--
-- Signal: Events.RemotePlayerTurnEnd. Fires with no args (the engine's
-- ICvDLLUserInterface::PublishRemotePlayerTurnEnd is parameterless), so
-- we diff HasReceivedNetTurnComplete against a per-turn set of already-
-- announced player IDs. The set is cleared on Events.NewGameTurn, which
-- marks the start of a fresh turn cycle for the whole game (not just for
-- the local player). Using Events.ActivePlayerTurnStart instead would be
-- wrong in sequential MP: that fires when the local human's turn comes
-- up mid-cycle, while already-ended remote players still carry the
-- net-turn-complete flag, so a later RemotePlayerTurnEnd for any other
-- player would rescan and re-announce them.
--
-- Boot seeding matters: civvaccess_shared persists across load-from-game,
-- and a load mid-simul-turn lands in a state where some remote players
-- are already ended. Seeding the set from current state on every
-- installListeners() prevents the next RemotePlayerTurnEnd from
-- "discovering" everyone whose turn ended before the load.
--
-- Filter chain: network MP, not the local active player, IsHuman, IsAlive,
-- not Observer, Network.IsPlayerConnected. AI turn-ends flow through the
-- same event but are noise -- the engine drives AI deterministically and
-- the user is not waiting on any specific AI. A disconnected human has
-- been taken over by the AI; same reasoning, skip it.
--
-- Speech path: speakQueued + MessageBuffer.append(..., "notification"),
-- matching MultiplayerRewards. Turn-end fires arrive alongside other
-- inter-turn announcements; queueing avoids clipping prior lines.
```

## Outline

- L35: `MultiplayerTurnEnd = {}`
- L37: `local function isAnnounceable(pPlayer)`
- L57: `local function announcedSet()`
- L66: `local function clearSet()`
- L73: `function MultiplayerTurnEnd._onRemoteTurnEnd()`
- L89: `function MultiplayerTurnEnd._onNewGameTurn()`
- L93: `function MultiplayerTurnEnd.installListeners()`
- L104: `Events.RemotePlayerTurnEnd.Add(MultiplayerTurnEnd._onRemoteTurnEnd)`
- L109: `Events.NewGameTurn.Add(MultiplayerTurnEnd._onNewGameTurn)`

## Notes

- L57 `announcedSet`: Lazily creates `civvaccess_shared.mpTurnEnded` on first access so the table survives load-from-game; `installListeners` seeds it from current engine state to avoid re-announcing players who already ended before the load.
