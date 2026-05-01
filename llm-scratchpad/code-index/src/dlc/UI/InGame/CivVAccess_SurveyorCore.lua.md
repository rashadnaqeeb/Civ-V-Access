# `src/dlc/UI/InGame/CivVAccess_SurveyorCore.lua`

460 lines · Implements the six surveyor scope queries (yields, resources, terrain, own units, enemy units, cities) plus radius grow/shrink and the HandlerStack binding table for Shift+letter keys.

## Header comment

```
-- Surveyor: "what's within N tiles of my cursor." Sits alongside Cursor
-- ("what's on this tile") and Scanner ("where is X"). Each Shift-letter
-- key answers one scope question against the current cursor position and
-- the shared radius on civvaccess_shared.surveyorRadius.
--
-- No per-scope caching; every read re-queries live engine state so a
-- radius 5 sweep after a unit move reflects the new positions. HexGeom
-- does the cube-coord iteration and splits the revealed / unexplored
-- buckets; this module layers filters and formatting on top.
--
-- Boot.lua loads the strings file before this one so Text.key lookups at
-- module load time resolve, but every user-facing lookup happens inside
-- a scope function -- load-time lookups here would bind to whichever
-- locale loaded first and miss later re-includes on Context re-entry.
```

## Outline

- L16: `SurveyorCore = {}`
- L18: `local MOD_SHIFT = 1`
- L20: `local MIN_RADIUS = 1`
- L21: `local MAX_RADIUS = 5`
- L24: `local YIELD_ORDER = { ... }`
- L36: `civvaccess_shared = civvaccess_shared or {}`
- L38: `local function getRadius()`
- L47: `local function setRadius(r)`
- L58: `local function cursorPos()`
- L67: `local function appendUnexplored(body, unexplored)`
- L78: `local function sortedBucketByCountThenName(buckets)`
- L92: `local function formatBucketEntries(entries)`
- L101: `local function speakRadius(r)`
- L111: `function SurveyorCore.grow()`
- L115: `function SurveyorCore.shrink()`
- L120: `function SurveyorCore.yields()`
- L158: `function SurveyorCore.resources()`
- L195: `function SurveyorCore.terrain()`
- L224: `local function distanceDirectionCompare(a, b)`
- L239: `local function formatInstances(instances, cx, cy, labelDirSep, instanceSep)`
- L253: `local function formatUnitInstances(instances, cx, cy)`
- L257: `local function unitLabel(unit, prefixAdj)`
- L269: `function SurveyorCore.ownUnits()`
- L303: `function SurveyorCore.enemyUnits()`
- L355: `function SurveyorCore.cities()`
- L387: `local function speak(s)`
- L394: `local bind = HandlerStack.bind`
- L396: `function SurveyorCore.getBindings()`
- L457: `function SurveyorCore._reset()`
