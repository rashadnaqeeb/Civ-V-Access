# `tests/support.lua`

645 lines · Shared test helpers: assertion utilities, a case-registration/runner model, and fixture factories for plots, units, players, cities, teams, maps, recommendations globals, scan entries, and the original-capital helper used by coordinate-string tests.

## Header comment

```
-- Test support: assertion helpers and a flat registration/runner model.
-- Suites return a table of test_*/Test* functions; the runner aggregates.
```

## Outline

- L4: `local T = {}`
- L5: `T.cases = {}`
- L7: `function T.case(name, fn)`
- L11: `function T.register(prefix, mod)`
- L25: `local function fmt(v)`
- L32: `function T.eq(actual, expected, note)`
- L38: `function T.truthy(v, note)`
- L43: `function T.falsy(v, note)`
- L54: `function T.fakePlot(opts)`
- L256: `function T.fakeUnit(opts)`
- L385: `function T.fakePlayer(opts)`
- L466: `function T.fakeCity(opts)`
- L467: `function T.fakeTeam(opts)`
- L507: `function T.installOriginalCapital(capX, capY, opts)`
- L531: `function T.installMap(plots)`
- L555: `function T.installRecGlobals(opts)`
- L570: `function T.installRecPlayer(opts)`
- L607: `function T.mkEntry(cat, sub, name, plotIndex, opts)`
- L627: `function T.run()`
- L645: `return T`

## Notes

- L54 `T.fakePlot`: The most complex fixture - implements 30+ plot methods including `CanSeePlot`/`HasLineOfSight` (delegates to an `opts.canSeePlot` hook for targetability tests), `IsFriendlyTerritory` (models OB grants via `opts.isFriendlyTerritory` map), and `GetLayerUnit` (merges `_units` and `_layerUnits` to mirror the engine's layer semantics).
- L256 `T.fakeUnit`: Includes `GetMissionQueue`, `Range`, `IsRangeAttackIgnoreLOS`, `CargoSpace`, and `GetTransportUnit` alongside the core movement/status accessors needed by scanner and cursor tests.
- L385 `T.fakePlayer`: Provides `Cities()` as a stateful iterator over `opts.cities` (or the capital singleton) and includes `IsDoF`/`IsFriends`/`IsAllies` for diplomacy tests.
- L507 `T.installOriginalCapital`: Builds a full chain (fakePlot -> fakeCity -> fakePlayer -> Players[slot]) so HexGeom coordinate-string tests can find the active player's original capital without requiring a full map install.
- L531 `T.installMap`: Installs `Map.GetNumPlots`, `Map.GetPlotByIndex`, `Map.PlotDistance` (Chebyshev), and `Map.GetPlot` (linear x/y scan) from a flat array of plots.
- L570 `T.installRecPlayer`: Installs `Players[0]` with settler/worker recommendation lists and `CanFound`/`GetNumResourceAvailable`, shared by scanner backend and cursor recommendation tests.
- L607 `T.mkEntry`: Builds a `ScanEntry`-shaped table with synthetic `key` and `sortKey` defaults; the `opts.backend` field lets nav-dispatch tests override the placeholder backend.
- L7 `T.case` / L11 `T.register`: `register` sorts keys alphabetically for deterministic execution order before delegating to `case`; test files that return a module table use `register`, while suites may call `case` directly.
