# `src/dlc/UI/InGame/CivVAccess_WaypointsCore.lua`

207 lines · Computes and caches the queued-movement waypoint list for the active selected unit, identifying stop-plots (turn-end nodes and leg destinations) via the engine fork's Unit:ComputePath binding.

## Header comment

```
-- Queued-movement waypoint computation, cached per selected unit. Drives
-- three consumers: the scanner's "waypoints" category, the plot-glance
-- "waypoint K of N" lead token, and UnitSpeech's queued-move status
-- rung. Same cache so all three see the same numbering for one
-- selection frame.
--
-- A waypoint is a plot where the unit STOPS on its queued path, not
-- every step it walks through. Two kinds of stops: (1) end-of-turn
-- plots, where the unit ran out of MP and pauses overnight before
-- resuming next turn; (2) leg destinations, the queue-entry
-- coordinates the user shift+entered. Sighted parity: the path-line's
-- turn-number badges land on exactly these plots, not on every step.
-- Detection signal is the pathfinder node's m_iData1 (MP remaining at
-- that node): m_iData1 == 0 means the unit ends a turn here. The
-- final node of each leg is always a waypoint regardless of MP, since
-- the unit pauses between queue entries.
--
-- The cache is keyed by (unitID, queueSig). queueSig is a string built
-- from the live mission queue; any mutation produces a different sig and
-- the next read recomputes. Engine doesn't fire a Lua event on queue
-- pop / push, so signature comparison is the only honest invalidation.
-- Scanner snapshot rebuilds and cursor moves trigger reads; pathfinder
-- runs only when the sig actually changed.
```

## Outline

- L25: `Waypoints = {}`
- L30: `local function pathBearingMissions()`
- L44: `local function computeSig(queue)`
- L60: `local function compute(unit, queue)`
- L117: `local function activeSnapshot()`
- L160: `function Waypoints.list()`
- L170: `function Waypoints.totalTurns()`
- L182: `function Waypoints.atXY(x, y)`
- L199: `function Waypoints.finalAndTurns()`

## Notes

- L60 `compute`: the engine fork's `Unit:ComputePath` is pcall-guarded with a logged warning because it is absent in the vanilla DLL; failure silently returns empty waypoints rather than throwing.
- L117 `activeSnapshot`: cache key includes (unitX, unitY) in addition to (unitID, sig) so a mid-leg progress on a multi-turn mission invalidates even when the queue entry coordinates (data1/data2) haven't changed.
