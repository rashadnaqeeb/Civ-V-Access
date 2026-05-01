# `src/dlc/UI/InGame/CivVAccess_CityRangeStrikeMode.lua`

271 lines · Modal HandlerStack handler for city ranged-strike target picking: Space previews legality, Enter commits the strike, Esc cancels, and Alt+QAZEDC is blocked to prevent Baseline direct-move interference.

## Header comment

```
-- City-ranged-strike target picker. Pushed above Baseline / Scanner after
-- the city screen closes and the engine enters INTERFACEMODE_CITY_RANGE_ATTACK.
-- Structurally a sibling to UnitTargetMode: free Q/E/A/D/Z/C cursor movement
-- via Baseline (no mapScope -- the cursor roams the whole map and Baseline's
-- per-tile speech reads what's there), Space speaks a strike-specific preview
-- ("out of range" or target identity), Enter commits, Esc cancels. Alt+QAZEDC
-- is swallowed to block Baseline's direct-move while the engine holds an
-- attack interface mode.
--
-- CanRangeStrikeNow gates the hub item, so at least one valid target exists
-- on entry. Cursor is jumped to a nearby valid target as a starting point;
-- from there the user navigates freely and Space tells them whether each
-- plot is strikeable. The commit-time CanRangeStrikeAt check is the
-- authoritative validity gate; a stray Enter on an invalid plot speaks
-- "cannot strike" and stays in the mode.
--
-- Exit (commit OR cancel OR external pop) drops back to the world map;
-- the city screen does NOT re-open. Matches the sighted banner-click
-- flow: bombarding from a banner leaves you on the world, not in the
-- city screen.
```

## Outline

- L22: `CityRangeStrikeMode = {}`
- L24: `local MOD_NONE = 0`
- L25: `local MOD_ALT = 4`
- L27: `local bind = HandlerStack.bind`
- L29: `local function speakInterrupt(text)`
- L36: `local function resolveCity(ownerID, cityID)`
- L52: `local function topStrikableTargetAt(plot)`
- L66: `local function strikeFailureReason(city, plot, tx, ty)`
- L95: `local function targetAnnouncement(city, plot, x, y)`
- L113: `local function findFirstTarget(city)`
- L137: `local function abandonEntry()`
- L142: `function CityRangeStrikeMode.enter(city)`

## Notes

- L52 `topStrikableTargetAt`: The 7th arg (bNoncombatAllowed) is a CIVVACCESS engine fork extension; bTestPotentialEnemy is intentionally left off because isPotentialEnemy is a vanilla stub that always returns false.
