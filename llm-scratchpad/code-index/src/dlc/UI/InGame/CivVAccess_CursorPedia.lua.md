# `src/dlc/UI/InGame/CivVAccess_CursorPedia.lua`

237 lines · Ctrl+I on the hex cursor: enumerates pedia-article-eligible things on the plot (units, city wonders, improvement, resource, feature, rivers/lakes, terrain, plot type, route), dedupes by name, and opens a picker or direct article.

## Header comment

```
-- Ctrl+I on the hex cursor. Enumerates everything on the plot that has
-- a Civilopedia article (units, world wonders in the city, improvement,
-- resource, feature, terrain, route), dedupes by pedia name so a carrier
-- with four fighters collapses to a single Fighter entry, and either
-- opens the pedia directly on a single result or pops a BaseMenu picker.
-- Unrevealed plots short-circuit: the user's own fog-of-war knowledge is
-- the gate, not arbitrary dedup rules.
--
-- Foreign units count: if the tile reveals a rival Warrior you still want
-- to know what a Warrior is. Invisible units (stealth, fog) are filtered
-- via IsInvisible, matching CursorActivate / Cursor.unitAtTile.
```

## Outline

- L13: `CursorPedia = {}`
- L15: `local function addEntry(entries, seen, name)`
- L26: `local function collectUnits(plot, entries, seen)`
- L41: `local function isWorldWonder(building)`
- L49: `local function collectCityWonders(plot, entries, seen)`
- L64: `local function collectImprovement(plot, entries, seen)`
- L76: `local function collectResource(plot, entries, seen)`
- L88: `local function collectFeature(plot, entries, seen)`
- L107: `local function collectRiverLake(plot, entries, seen)`
- L126: `local function collectTerrain(plot, entries, seen)`
- L138: `local function collectRoute(plot, entries, seen)`
- L156: `local function collectPlotType(plot, entries, seen)`
- L178: `local function buildEntries(plot)`
- L195: `function CursorPedia.run(plot)`
- L236: `CursorPedia._buildEntries = buildEntries`

## Notes

- L107 `collectRiverLake`: Accesses GameInfo.FakeFeatures by string key (unverified in base code); logs a warning on nil rather than silently skipping, per the no-silent-failures rule.
- L156 `collectPlotType`: Hills and Mountain are plot types, not terrain values, so they need separate collection beyond collectTerrain.
