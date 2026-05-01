# `src/dlc/UI/InGame/CivVAccess_ScannerBackendImprovements.lua`

110 lines · Scanner backend that sweeps all revealed plots for improvements, skipping barb camps / goody huts / roads, and partitions them by owner stance (my/neutral/enemy).

## Header comment

```
-- Scanner backend: improvements (My / Neutral / Enemy by owner team
-- stance). Reads plot:GetRevealedImprovementType(activeTeam) so the
-- scanner matches the engine's own rendering under fog. Skips the
-- barb-camp and goody-hut improvements (handled by the Cities and
-- Special backends respectively) and the road / railroad improvements
-- if they exist (base game treats them as routes, not improvements;
-- the skip is belt-and-braces in case a mod promotes them).
--
-- Ownership buckets via plot:GetRevealedOwner because Civ V does not
-- expose a GetRevealedImprovementOwner; the tile owner IS the
-- improvement owner in every base-game case (forts in no-man's-land
-- end up with RevealedOwner == -1, which buckets to Neutral per the
-- design's explicit "unowned improvements fall under Neutral" rule).
```

## Outline

- L15: `ScannerBackendImprovements = { name = "improvements" }`
- L19: `local SKIP_TYPES = { ... }`
- L26: `local function ownerSubcategory(ownerId, activePlayerId, activeTeam)`
- L47: `function ScannerBackendImprovements.Scan(activePlayer, activeTeam)`
- L88: `function ScannerBackendImprovements.ValidateEntry(entry, _cursorPlotIndex)`
- L105: `function ScannerBackendImprovements.FormatName(entry)`
- L109: `ScannerCore.registerBackend(ScannerBackendImprovements)`
