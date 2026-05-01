# `src/dlc/UI/InGame/CivVAccess_ScannerBackendWaypoints.lua`

60 lines · Scanner backend that exposes the selected unit's queued mission waypoints as numbered scanner entries, sourced from WaypointsCore.

## Header comment

```
-- Scanner backend: queued-move waypoints for the active selected unit.
-- One entry per plot the unit will step onto across its mission queue,
-- numbered start-to-end. Source of truth is WaypointsCore (cached by
-- selection / queue signature); this file is just the scanner shape.
--
-- Multiple waypoints can land on the same plot (a queue with reversal
-- legs walks the same plot twice). Each gets its own scanner entry with
-- a unique key so identity-preserving rebuild doesn't collapse them.
```

## Outline

- L10: `ScannerBackendWaypoints = { name = "waypoints" }`
- L14: `function ScannerBackendWaypoints.Scan(_activePlayer, _activeTeam)`
- L41: `function ScannerBackendWaypoints.ValidateEntry(entry, _cursorPlotIndex)`
- L55: `function ScannerBackendWaypoints.FormatName(entry)`
- L59: `ScannerCore.registerBackend(ScannerBackendWaypoints)`

## Notes

- L14 `ScannerBackendWaypoints.Scan`: The entry key includes both `plotIdx` and `i` (`"waypoints:" .. plotIdx .. ":" .. i`) so two waypoints on the same plot get distinct keys and are not collapsed by the snapshot's identity-preserving rebuild.
- L41 `ValidateEntry`: Checks that the waypoint at the stored index still maps to the stored plot coordinates; a shift in queue numbering (unit completes a leg, or shift+queuing reorders) invalidates stale entries rather than mis-announcing a wrong waypoint number.
