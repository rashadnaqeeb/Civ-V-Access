# `src/dlc/UI/InGame/CivVAccess_ScannerBackendResources.lua`

74 lines · Scanner backend that enumerates all revealed, tech-unlocked resources and partitions them by usage type (bonus/strategic/luxury).

## Header comment

```
-- Scanner backend: resources. Subcategory keyed off GameInfo.Resources
-- .ResourceUsage (0 bonus / 1 strategic / 2 luxury).
--
-- Visibility gating is in two layers because the engine splits them:
--   * plot:IsRevealed(team, isDebug)      fog-of-war gate (explored yet?)
--   * plot:GetResourceType(team)          tech gate (returns -1 when a
--                                         strategic resource is present
--                                         but the team lacks the reveal
--                                         tech, e.g. Iron before BW)
-- Both must pass. The engine's own tooltip pipeline does the same pairing
-- (PlotHelpManager gates on IsRevealed before calling
-- GenerateResourceToolTip, which then calls GetResourceType with the
-- active team). Skipping the IsRevealed check surfaces resources on
-- unexplored plots, which is the whole-map leak we hit in testing.
```

## Outline

- L16: `ScannerBackendResources = { name = "resources" }`
- L20: `local USAGE_SUBS = { [0] = "bonus", [1] = "strategic", [2] = "luxury" }`
- L26: `function ScannerBackendResources.Scan(_activePlayer, activeTeam)`
- L56: `function ScannerBackendResources.ValidateEntry(entry, _cursorPlotIndex)`
- L69: `function ScannerBackendResources.FormatName(entry)`
- L73: `ScannerCore.registerBackend(ScannerBackendResources)`
