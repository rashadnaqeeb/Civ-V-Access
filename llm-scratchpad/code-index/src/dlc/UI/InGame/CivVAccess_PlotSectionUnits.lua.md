# `src/dlc/UI/InGame/CivVAccess_PlotSectionUnits.lua`

75 lines · Plot section that walks all unit layers on a plot and returns a spoken description for each visible non-cargo, non-air unit.

## Header comment

```
-- Units section. Walks plot:GetLayerUnit(-1) so the iteration covers
-- every plot layer, not just base. Trade units (caravans, cargo ships
-- on a route) live on TRADE_UNIT_MAP_LAYER (CvTradeClasses.h) and are
-- absent from plot:GetNumUnits(); base game's GetUnitsString skips them
-- because the trade overview surfaces them separately, but the cursor's
-- job is to announce everything visibly on the tile, so we include them.
-- Each survivor is gated by IsInvisible(activeTeam, isDebug); cargo
-- (inside a transport) and air (parked in a city / on a carrier) are
-- skipped -- they're not "on the tile" in the spatial sense the cursor
-- cares about.
```

## Outline

- L16: `local function unitDescription(unit)`
- L24: `local function describeUnit(unit, activeTeam, isDebug)`
- L55: `PlotSectionUnits = { Read = function(plot) ... end }`

## Notes

- L16 `unitDescription`: Delegates to `UnitSpeech.unitName` for personal-name handling, then adds the "embarked" prefix on top if the unit is embarked.
- L55 `PlotSectionUnits`: Uses `GetLayerUnit(i, -1)` (layer -1 = all layers) rather than `GetUnit(i)` so trade units on the trade-unit map layer are included.
