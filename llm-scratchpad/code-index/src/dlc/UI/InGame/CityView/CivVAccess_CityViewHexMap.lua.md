# `src/dlc/UI/InGame/CityView/CivVAccess_CityViewHexMap.lua`

474 lines · Hex map sub-handler for the CityView hub: cursor-scoped tile inspection, citizen toggle / plot purchase Enter actions, L list-worked-tiles, Scanner/Surveyor binding pull-in, and a single `CityViewHexMap.push` entry point.

## Header comment

```
-- Hex map sub-handler for the CityView accessibility hub. Peeled out of
-- CivVAccess_CityViewAccess.lua. Owns:
--
-- - Cursor-driven tile inspection within the city's reach (city center,
--   workable ring, and every purchasable plot including culture grabs
--   beyond the ring).
-- - The scope predicate (hexMapScope) and per-tile announcer
--   (hexTileAnnouncement) installed on civvaccess_shared so the generic
--   Cursor module routes through them without knowing about CityView.
-- - The Enter actions (citizen toggle via TASK_CHANGE_WORKING_PLOT, plot
--   buy via Network.SendCityBuyPlot, the unaffordable / center / blocked
--   no-op branches), plus the L (list worked tiles) chord.
-- - The Scanner / Surveyor binding pull-in (the hub's
--   capturesAllInput=true would otherwise wall those off).
--
-- Exposes `CityViewHexMap.push` for the hub to invoke from buildHubItems.
-- No other external surface; the orchestrator's
-- `CivVAccess_CityViewAccess` only reaches for `.push`.
```

## Outline

- L29: `CityViewHexMap = {}`
- L31: `local _hexDeps = civvaccess_shared.modules or {}`
- L32: `local Cursor = _hexDeps.Cursor`
- L33: `local ScannerNav = _hexDeps.ScannerNav`
- L34: `local ScannerHandler = _hexDeps.ScannerHandler`
- L35: `local SurveyorCore = _hexDeps.SurveyorCore`
- L36: `local PlotComposers = _hexDeps.PlotComposers`
- L37: `local HexGeom = _hexDeps.HexGeom`
- L41: `local function isTurnActive()`
- L53: `local function plotIndexInRing(city, plot)`
- L74: `local function isInWorkingArea(city, plot)`
- L93: `local function workedStateTokens(city, plot)`
- L108: `local function hexTileAnnouncement(plot)`
- L157: `local function hexMapScope(x, y)`
- L183: `local function activateHexTile()`
- L256: `local function listWorkedTilesFromCursor()`
- L312: `local function pushHexMap()`
- L470: `function CityViewHexMap.push()`

## Notes

- L31-37: module refs captured from `civvaccess_shared.modules` at include time (Boot's published singletons); must not be re-included to avoid fragmenting cursor state across Contexts.
- L74 `isInWorkingArea`: double-checks both `GetID()` and `GetOwner()` on the working city to prevent a neighbour city with the same numeric ID but different player from falsely matching.
- L312 `pushHexMap`: installs `civvaccess_shared.mapScope` and `civvaccess_shared.mapAnnouncer` immediately before `HandlerStack.push` so `onActivate`'s `Cursor.jumpTo` sees them; rolls both back manually if the push fails. `onDeactivate` clears them on normal exit.
- L405-426: Surveyor bindings are appended before Scanner bindings so per-feature help (Q radius, A resources) reads before the generic scanner page-cycling chords.
