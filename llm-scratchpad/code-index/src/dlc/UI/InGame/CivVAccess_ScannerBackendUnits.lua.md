# `src/dlc/UI/InGame/CivVAccess_ScannerBackendUnits.lua`

205 lines · Scanner backend that enumerates all visible units, partitioned into my/neutral/enemy top-level categories and role subcategories (melee, ranged, siege, mounted, air, naval, civilian, great people, barbarians).

## Header comment

```
-- Scanner backend: units. Partitioned into My / Neutral / Enemy by the
-- scanning player's team stance, plus the Barbarians subcategory under
-- Enemy. Role subcategory is derived from Domain + UnitCombat per the
-- table in docs/scanner-design.md section 2.
```

## Outline

- L6: `ScannerBackendUnits = { name = "units" }`
- L15: `local MAX_PLAYER_INDEX = (GameDefines and GameDefines.MAX_CIV_PLAYERS) or 63`
- L21: `local MELEE_COMBATS = { ... }`
- L28: `local MOUNTED_COMBATS = { ... }`
- L38: `local function roleSubcategory(unit)`
- L83: `local function ownerCategory(ownerId, activePlayerId, activeTeam)`
- L109: `local function unitItemName(unit, category)`
- L125: `function ScannerBackendUnits.Scan(activePlayer, activeTeam)`
- L172: `function ScannerBackendUnits.ValidateEntry(entry, _cursorPlotIndex)`
- L200: `function ScannerBackendUnits.FormatName(entry)`
- L204: `ScannerCore.registerBackend(ScannerBackendUnits)`

## Notes

- L15 `MAX_PLAYER_INDEX`: Set to `MAX_CIV_PLAYERS` (not `MAX_CIV_PLAYERS - 1`) so the barbarian player slot (which sits at that index) is included; the Cities backend uses a tighter bound because barbarians don't own cities.
- L109 `unitItemName`: Non-own units prepend the civ adjective ("Arabian Warrior") so the scanner collapse-by-name key keeps Roman Warriors separate from Babylonian Warriors; own units use the bare description since the category already disambiguates.
- L172 `ValidateEntry`: A unit that moved still passes validation (the stored `plotIndex` may be stale); the entry stays live and the stale position is only used for distance sorting until the next snapshot rebuild.
