# `src/dlc/UI/InGame/CivVAccess_ScannerBackendCities.lua`

142 lines · Scanner backend that enumerates all known cities (partitioned into my/neutral/enemy subcategories) and barbarian camps from a revealed-improvement sweep.

## Header comment

```
-- Scanner backend: cities (My / Neutral / Enemy) and barbarian camps.
-- Iterates Players[p]:Cities() across every major + minor slot, gating each
-- player by Teams[activeTeam]:IsHasMet; partitions ownership against the
-- active team's war state. Barb camps come from a separate plot sweep for
-- IMPROVEMENT_BARBARIAN_CAMP -- they're improvements, not cities, but live
-- under Cities because that's the hostile-settlement mental slot.
```

## Outline

- L8: `ScannerBackendCities = { name = "cities" }`
- L12: `local MAX_PLAYERS = (GameDefines and GameDefines.MAX_CIV_PLAYERS) or 64`
- L17: `local function citySubcategory(cityOwnerId, activePlayerId, activeTeam)`
- L35: `local function scanCities(activePlayer, activeTeam, out)`
- L72: `local function scanBarbCamps(activeTeam, out)`
- L99: `function ScannerBackendCities.Scan(activePlayer, activeTeam)`
- L106: `function ScannerBackendCities.ValidateEntry(entry, _cursorPlotIndex)`
- L137: `function ScannerBackendCities.FormatName(entry)`
- L141: `ScannerCore.registerBackend(ScannerBackendCities)`

## Notes

- L72 `scanBarbCamps`: Sweeps all map plots via `Map.GetNumPlots` rather than iterating a player's city list because barbarian camps are improvements, not city objects.
