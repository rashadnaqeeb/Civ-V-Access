# `src/dlc/UI/InGame/CivVAccess_ScannerBackendRecommendations.lua`

150 lines · Scanner backend that maps AI settler and worker tile recommendations into scanner entries, delegating all logic to RecommendationsCore.

## Header comment

```
-- Scanner backend: AI tile recommendations. Mirrors the on-map anchor
-- markers the game places for Settlers and Workers by calling the same
-- Player:GetRecommendedFoundCityPlots / GetRecommendedWorkerPlots APIs
-- the engine uses in GenericWorldAnchor.lua.
--
-- All the gating, list, membership, and reason logic lives in
-- CivVAccess_RecommendationsCore.lua (Recommendations.*) because the
-- plot-section path (cursor-land "recommendation: X" announcement)
-- needs the same helpers. This file is just the scanner shape: map
-- those helpers onto ScanEntry tuples.
-- [...]
```

## Outline

- L28: `ScannerBackendRecommendations = { name = "recommendations" }`
- L32: `local CITY_SITE_KEY = "TXT_KEY_CIVVACCESS_SCANNER_RECOMMENDATION_CITY_SITE"`
- L34: `local function buildItemName(buildType)`
- L45: `local function emitSettlerEntries(player, out)`
- L67: `local function emitWorkerEntries(player, out)`
- L90: `function ScannerBackendRecommendations.Scan(activePlayer, _activeTeam)`
- L115: `function ScannerBackendRecommendations.ValidateEntry(entry, _cursorPlotIndex)`
- L145: `function ScannerBackendRecommendations.FormatName(entry)`
- L149: `ScannerCore.registerBackend(ScannerBackendRecommendations)`

## Notes

- L115 `ValidateEntry`: Re-runs full gating and re-checks membership in the fresh rec list, not just `CanFound`, because the engine's strategic assessment can drop a plot from the list while `CanFound` remains true (e.g. a city founded within the exclusion radius of a different plot).
