# `src/dlc/UI/InGame/CivVAccess_ScannerBackendTerrain.lua`

129 lines · Scanner backend that emits up to three entries per revealed plot (base terrain, feature, and elevation) to support independent "where is ..." searches.

## Header comment

```
-- Scanner backend: terrain. Emits up to three entries per revealed plot,
-- one per applicable subcategory:
--   base       the plot's terrain row description (grassland, plains,
--              desert, coast, ocean, mountain, ...).
--   features   the plot's feature row description (forest, jungle, oasis,
--              floodplains, natural wonders, ...) when one is present.
--   elevation  hills or mountain, when IsHills() / IsMountain() is true.
--
-- Double-listing is intentional per the scanner design: a forested hill
-- on grassland produces Grassland under base, Forest under features, and
-- Hills under elevation, and a natural-wonder tile also surfaces under
-- special.natural_wonders via ScannerBackendSpecial. Each sub answers a
-- different "where is ..." question (base material / overlay / relief)
-- and collapsing them would force the user to mentally re-query.
--
-- Visibility: plot:IsRevealed gate only. Terrain and features have no
-- GetRevealedTerrainType / GetRevealedFeatureType -- unlike improvements
-- and resources, the engine treats terrain and features as reveal-and-
-- remember data, so the live getters match what the player's fog map
-- shows (a forest chopped under fog stays a forest to the player until
-- they re-enter visibility, and the scanner honours the same ambiguity).
```

## Outline

- L23: `ScannerBackendTerrain = { name = "terrain" }`
- L27: `local HILLS_KEY = "TXT_KEY_TERRAIN_HILLS_HEADING3_TITLE"`
- L28: `local MOUNTAIN_KEY = "TXT_KEY_TERRAIN_MOUNTAIN_HEADING3_TITLE"`
- L30: `function ScannerBackendTerrain.Scan(_activePlayer, activeTeam)`
- L101: `function ScannerBackendTerrain.ValidateEntry(entry, _cursorPlotIndex)`
- L124: `function ScannerBackendTerrain.FormatName(entry)`
- L128: `ScannerCore.registerBackend(ScannerBackendTerrain)`

## Notes

- L30 `ScannerBackendTerrain.Scan`: A single plot can produce up to three entries (base + feature + elevation); the key suffixes (`terrain:base:`, `terrain:feature:`, `terrain:elevation:`) keep them distinct in the scanner snapshot.
