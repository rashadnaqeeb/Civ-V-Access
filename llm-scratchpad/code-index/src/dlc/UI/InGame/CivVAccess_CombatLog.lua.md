# `src/dlc/UI/InGame/CivVAccess_CombatLog.lua`

93 lines · Accumulates spoken combat strings during the AI turn window and parks them on civvaccess_shared for the F7 Turn Log tab; entries are gated by an in-AI-turn flag that TurnEnd/TurnStart flip.

## Header comment

```
-- Per-AI-turn combat log. Captures the spoken combat-readout text for
-- every combat resolved while the active player is waiting on the AI
-- (between ActivePlayerTurnEnd and the next ActivePlayerTurnStart) and
-- parks the array on civvaccess_shared so NotificationLogPopupAccess can
-- list each combat under the F7 Turn Log tab's Combat Log group for the
-- duration of the player's next turn.
--
-- Combats the active player initiates during their own turn are *not*
-- logged: those already speak in real time at the moment the player
-- pressed Attack, and the combat log exists to recover what happened
-- while the player couldn't react. recordCombat() is called from
-- UnitControl.onCombatResolved with the same string just passed to
-- speakQueued, and the in-AI-turn flag below gates whether it lands.
--
-- Lifecycle. ActivePlayerTurnEnd starts the window: clear the prior
-- turn's list (visible through the just-finished player turn, now
-- stale) and flip _inAiTurn true. ActivePlayerTurnStart closes the
-- window but leaves the list intact so F7 can read it through the
-- whole next player turn. The next TurnEnd clears and reopens. The
-- list lives on civvaccess_shared because the F7 popup Context reads
-- it across the Context boundary; _inAiTurn stays module-local because
-- only this Context flips it, and installListeners resets it on every
-- Boot (load-game-from-game re-runs Boot which re-includes this file
-- and re-arms the listeners against fresh closures).
--
-- Hotseat. AI turns process while the active player is whoever just
-- ended (CvPlayer.cpp:15812 only calls setActivePlayer inside
-- setTurnActive for humans, so AI setTurnActive runs doTurn / doTurnUnits
-- without changing the active player). Combat events during the AI
-- batch are scoped to that human's team via setVisualizeCombat /
-- isActiveVisible, so the log accumulates from their visibility -- not
-- the visibility of the next human about to take over. To avoid leaking
-- AI-window combats from the prior human's view to the next, the
-- hotseat path also clears the log on Events.GameplaySetActivePlayer
-- (which fires only on actual active-player change at CvGame.cpp:5584).
-- A single human against many AIs has no GameplaySetActivePlayer firing
-- between rounds, so their log is preserved across the AI batch as in
-- single-player.
```

## Outline

- L40: `CombatLog = {}`
- L42: `local _inAiTurn = false`
- L44: `function CombatLog.recordCombat(text)`
- L56: `function CombatLog._onTurnEnd()`
- L61: `function CombatLog._onTurnStart()`
- L65: `function CombatLog._onActivePlayerChanged()`
- L72: `function CombatLog.installListeners()`
