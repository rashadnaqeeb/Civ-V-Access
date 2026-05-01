# `src/dlc/UI/InGame/CivVAccess_ForeignClearWatch.lua`

157 lines · Counts barbarian camp and goody hut clears by foreign (non-teammate) players on visible plots during the AI turn, announces a summary line at TurnStart, and parks it in civvaccess_shared for the F7 Turn Log.

## Header comment

```
-- Speaks one line at the start of every player turn covering goody huts
-- (ancient ruins) and barbarian camps that some other civ cleared on a
-- plot the active team could see during the AI turn just past. Camps and
-- ruins are tallied separately and joined with the AND key when both are
-- non-zero. The same line lands in civvaccess_shared.foreignClearDelta
-- (a single-element array, mirroring foreignUnitDelta's shape so the F7
-- consumer can iterate uniformly) and in MessageBuffer under the reveal
-- category. Single-player and MP behave identically; the engine fork hooks
-- this watcher subscribes to fire in both modes.
-- [...]
```

## Outline

- L37: `ForeignClearWatch = {}`
- L43: `local _counts = { camps = 0, ruins = 0 }`
- L45: `local function isCountableClear(actorID, iX, iY)`
- L61: `local function bumpClear(category, actorID, iX, iY)`
- L72: `function ForeignClearWatch._onForeignBarbCampCleared(actorID, iX, iY)`
- L76: `function ForeignClearWatch._onForeignGoodyCleared(actorID, iX, iY)`
- L80: `function ForeignClearWatch._onTurnEnd()`
- L91: `function ForeignClearWatch._onTurnStart()`
- L128: `function ForeignClearWatch.installListeners()`

## Notes

- L72 `_onForeignBarbCampCleared` / L76 `_onForeignGoodyCleared`: Subscribe to GameEvents (engine fork hooks), not standard Events; will log a warning and disable if the fork DLL is not deployed.
