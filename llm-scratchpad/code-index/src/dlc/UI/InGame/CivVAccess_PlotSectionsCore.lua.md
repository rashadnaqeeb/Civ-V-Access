# `src/dlc/UI/InGame/CivVAccess_PlotSectionsCore.lua`

316 lines · Core plot-description sections registry: owner identity, city banner, terrain/feature shape, resource, improvement, route, AI recommendation, and waypoint.

## Header comment

```
-- Plot description sections. Each section is { Read = function(plot, ctx) }
-- returning a list of zero or more localized tokens; composers join the
-- non-empty ones with ", ". Sections are stateless across calls. The ctx
-- table is a per-Compose scratch space reserved for future cross-section
-- coordination; no current section reads or writes it.
--
-- The Owner section here is NOT in the per-move composer -- the cursor's
-- owner-prefix diff already speaks owner identity. Owner lives in the
-- registry so the Cursor can borrow the same builder without
-- reimplementing the civ / unclaimed branching. The City section below
-- handles the city banner (TXT_KEY_CITY_OF / TXT_KEY_CITY_STATE_OF) on
-- city tiles independently of owner identity.
--
-- Per-section visibility rules: revealed-but-fogged plots get terrain /
-- plot-shape / feature / improvement / route / owner via the GetRevealed*
-- family; live-only data (yields, units, build progress) is gated by the
-- composer at compose time, not in the section itself. PlotMouseoverInclude
-- (Expansion2) is the canonical reference for which fields stale safely.
```

## Outline

- L20: `PlotSections = {}`
- L22: `local function lookupName(table, id)`
- L39: `function PlotSections.ownerIdentity(plot)`
- L60: `PlotSections.city = { Read = function(plot) ... end }`
- L102: `local FEATURE_SUPPRESSES_TERRAIN = { ... }`
- L118: `PlotSections.terrainShape = { Read = function(plot, ctx) ... end }`
- L157: `PlotSections.resource = { Read = function(plot) ... end }`
- L199: `local function pillagedSection(getRevealedId, infoTable, isPillaged)`
- L219: `PlotSections.improvement = pillagedSection(...)`
- L229: `PlotSections.route = pillagedSection(...)`
- L249: `local function settlerRecTokens(player, plot, x, y)`
- L267: `local function workerRecTokens(player, plot, x, y)`
- L289: `PlotSections.recommendation = { Read = function(plot) ... end }`
- L307: `PlotSections.waypoint = { Read = function(plot) ... end }`

## Notes

- L39 `PlotSections.ownerIdentity`: Returns two values - the spoken string and an opaque identity token for cursor diffing; city tiles share the surrounding civ's identity token so stepping civ-tile to same-civ city-tile doesn't re-announce the owner prefix.
- L60 `PlotSections.city`: Reads `civvaccess_shared.borderAlwaysAnnounce` to suppress the civ-adjective in always-announce mode where the cursor prefix already named the civ on every step.
- L199 `pillagedSection`: Factory that builds improvement and route sections with identical logic; the two instances differ only in the getter, table name, and pillage-check function passed in.
