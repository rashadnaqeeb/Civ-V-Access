# `src/dlc/UI/InGame/CivVAccess_MultiplayerRewards.lua`

196 lines · MP-only fallback that announces goody-hut rewards, barbarian-camp clears, and natural-wonder discoveries that the engine suppresses in networked multiplayer.

## Header comment

```
-- !!! MULTIPLAYER-ONLY MODULE !!!
--
-- Civ V's engine suppresses three reward popups in networked multiplayer
-- (the !isNetworkMultiPlayer guard in CvPlayer.cpp / CvUnit.cpp / CvPlot.cpp
-- around BUTTONPOPUP_GOODY_HUT_REWARD, BUTTONPOPUP_BARBARIAN_CAMP_REWARD,
-- BUTTONPOPUP_NATURAL_WONDER_REWARD). In single-player the standard
-- *PopupAccess wrappers (GoodyHutPopup / BarbarianCampPopup /
-- NaturalWonderPopup) read the popup's DescriptionLabel and announce
-- through BaseMenu's preamble. In MP those popups never fire, so a blind
-- player would silently miss every ruin reward, every barbarian-camp
-- reward, and every natural-wonder discovery. This module is the MP
-- fallback that closes that gap and only that gap.
--
-- Hot seat is unaffected: the engine gate is on isNetworkMultiPlayer (not
-- isGameMultiPlayer), so hot seat sees the popups normally and rides the
-- existing access wrappers. This module's MP gate matches: it only fires
-- when Game:IsNetworkMultiPlayer() is true, so single-player and hot seat
-- are no-ops here.
--
-- Signal sources, all unconditional in both SP and MP:
-- * Goody hut: GameEvents.CivVAccessGoodyHutReceived (engine fork hook,
--   src/engine/CvGameCoreDLL_Expansion2/CvPlayer.cpp inside the active-
--   player block of CvPlayer::receiveGoody, marked CIVVACCESS:). Args
--   (playerID, eGoody, iSpecialValue) -- iSpecialValue mirrors what the
--   popup's data2 carries: gold, culture, or faith depending on the goody
--   type.
-- * Barbarian camp: GameEvents.CivVAccessBarbarianCampCleared (engine
--   fork hook, CvUnit.cpp, marked CIVVACCESS:). Args (playerID, iX, iY,
--   iNumGold).
-- * Natural wonder: Events.NaturalWonderRevealed (vanilla, fired
--   unconditionally for the active team via gDLL->GameplayNaturalWonder-
--   Revealed). Args (iX, iY). No engine change needed for this one.
--
-- Speech path: speakQueued + MessageBuffer.append("notification") for
-- every announcement. Queueing matches NotificationAnnounce: these
-- discoveries land in inter-turn waves (a unit move can clear a camp AND
-- pop a goody on the same tick), so an interrupt would clip the prior
-- line. The notification category puts the entry on the same Shift+] /
-- Shift+[ filter as engine-generated notifications, since these events
-- are conceptually the same shape.
--
-- Listeners are re-registered fresh on every onInGameBoot. See
-- CivVAccess_Boot.lua's LoadScreenClose registration for the rationale:
-- load-game-from-game kills the prior Context's env, stranding listeners
-- that captured its closures.
```

## Outline

- L47: `MultiplayerRewards = {}`
- L49: `local function emit(text)`
- L64: `function MultiplayerRewards._onGoodyHutReceived(playerID, eGoody, iSpecialValue)`
- L81: `function MultiplayerRewards._onBarbarianCampCleared(playerID, _iX, _iY, iNumGold)`
- L110: `function MultiplayerRewards._onNaturalWonderRevealed(iX, iY)`
- L175: `function MultiplayerRewards.installListeners()`
- L177: `GameEvents.CivVAccessGoodyHutReceived.Add(MultiplayerRewards._onGoodyHutReceived)`
- L183: `GameEvents.CivVAccessBarbarianCampCleared.Add(MultiplayerRewards._onBarbarianCampCleared)`
- L191: `Events.NaturalWonderRevealed.Add(MultiplayerRewards._onNaturalWonderRevealed)`

## Notes

- L110 `MultiplayerRewards._onNaturalWonderRevealed`: Skips finder-gold line entirely (no Lua-side iFinderGold signal in MP); gold still lands in the player's treasury silently before the popup gate.
