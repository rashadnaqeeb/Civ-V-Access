# `src/dlc/UI/Shared/CivVAccess_CivDetails.lua`

135 lines · Shared rich civ-label builder used by SelectCivilization and AdvancedSetup's civ pulldown, querying leader, trait, unique unit/building/improvement data from GameInfo.

## Header comment

```
-- Shared rich civ-label builder. Used by SelectCivilization's picker and
-- AdvancedSetup's civ pulldown so both screens produce the same detail:
-- leader, civ short name, unique ability (name + description), unique
-- unit, unique building, unique improvement. Keeps the two screens from
-- drifting.
--
-- The queries are DB.CreateQuery'd at module load so they're prepared
-- once per Context sandbox and reused for each civ-row lookup.
```

## Outline

- L10: `CivDetails = {}`
- L16: `local uniqueUnitsQuery = DB.CreateQuery([[...]])`
- L29: `local uniqueBuildingsQuery = DB.CreateQuery([[...]])`
- L44: `local uniqueImprovementsQuery = DB.CreateQuery([[...]])`
- L46: `local traitsQuery = DB.CreateQuery([[...]])`
- L50: `local function appendLabeled(parts, labelKey, value)`
- L57: `local function appendUnique(parts, labelKey, uniqueDesc, replacesDesc)`
- L75: `function CivDetails.richLabel(row)`
- L108: `function CivDetails.pulldownLabels()`
- L135: `return CivDetails`

## Notes

- L108 `CivDetails.pulldownLabels`: index 1 is always the Random entry (matching base's `mapScripts[0]` pattern); indices 2..N+1 are playable civs sorted by localized leader name via `Locale.Compare`.
