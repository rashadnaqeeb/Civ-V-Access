# Civ V Access fork additions

Methods added by our `CvGameCore_Expansion2.dll` fork that the auto-extracted per-class docs don't cover. The extractor scans shipped game Lua and bins by call site; these bindings have no game-side callers, so they don't appear there.

## Source of truth

`src/engine/CvGameCoreDLL_Expansion2/` — every fork-added binding or hook has a `// CIVVACCESS:` comment block on its declaration site. Grep that marker for the canonical list and read the C++ for behavior. Additions only resolve when the deployed `CvGameCore_Expansion2.dll` is our build (default behavior of `deploy.ps1`; pass `-SkipEngine` to leave the vanilla DLL in place); on a vanilla deploy `Unit:GeneratePath` raises `luaL_error("NYI")`, the other bindings produce method-not-found errors, and the GameEvents hook just never fires.

## Current bindings

### Unit

- `unit:GeneratePath(toPlot, [iFlags=0], [bReuse=false])` — runs the engine unit pathfinder against `toPlot`. Returns `(reachable, pathTurns)` where `pathTurns` starts at 1 (initial node) and increments at each turn boundary. Firaxis shipped this as `luaL_error("NYI")`; the fork fills in the body.
- `unit:GetPath()` — reads the path computed by the most recent `GeneratePath` call. Returns a 1-indexed Lua array ordered start to destination, each entry `{x, y, moves, turn, flags}` where `moves` is in `MOVE_DENOMINATOR` 60ths and `turn` matches the engine's per-node `iData2`.
- `unit:GetMissionQueue()` — returns the unit's pending mission queue as a 1-indexed array of `{mission, data1, data2, flags, pushTurn}`. `mission` is the `MissionTypes` enum value.

### Game

- `Game.GetCycleUnits()` — returns the active player's `CvUnitCycler` order as a 1-indexed Lua array of unit IDs. Same data structure the engine's `Game.CycleUnits` walks; exposing it Lua-side replaces a nearest-neighbor reimplementation.
- `Game.GetBuildRoutePath(sx, sy, ex, ey, playerID, [route=NO_ROUTE])` — wraps `GC.GetBuildRouteFinder().GeneratePath`. Returns a 1-indexed array ordered start to destination, each entry `{x, y}`. Empty array on no path. Callers sum build turns via `Plot:GetBuildTurnsLeft`.

### GameEvents hooks

- `GameEvents.CivVAccessPlotRevealed(eTeam, iX, iY)` — fires on first reveal of a plot for a team (state flip from unrevealed to revealed). Sits inside the existing `if(isRevealed(eTeam) != bNewValue)` guard in `CvPlot::setRevealed`, gated on `bNewValue == true` and `eTeam != BARBARIAN_TEAM`. Does not fire on visibility transitions of already-revealed plots — for that, subscribe to vanilla `Events.HexFOWStateChanged`. Consumed by `CivVAccess_RevealAnnounce.lua` to drive the "tiles revealed" announcement.
