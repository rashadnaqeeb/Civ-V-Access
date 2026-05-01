# `src/dlc/UI/InGame/CityView/CivVAccess_CityStats.lua`

630 lines · Pure data layer that builds drillable BaseMenuItems.Group entries for each city stat category (yields, growth, culture, happiness, religion, trade, resources, defense, demand).

## Header comment

```
-- City Stats drillable. The CityView hub item that pushes a sub-handler
-- whose items are BaseMenuItems.Group instances, one per category. Each
-- group contains a flat list of Text rows, except Yields which goes one
-- level deeper (each yield drills into its source-breakdown lines from
-- the engine's Get<Yield>Tooltip output). The category set mirrors the
-- engine's per-city information: yields (with their tooltip drill-ins),
-- growth, culture progress, happiness, religion, trade routes, locally
-- accessible resources, defense, and the WLTKD / resource-demanded line.
--
-- Groups are skipped when they would expose nothing beyond a header --
-- religion before any conversion has happened, trade with no routes
-- touching this city, etc. -- so arrowing through Stats never lands on
-- a group whose drill-in is "no entries". Yields, Growth, Culture,
-- Happiness, and Defense always have content and are unconditional.
--
-- Pure data layer: every entry point takes a city handle plus optional
-- collaborators (active player, the engine's tooltip helpers) and
-- returns either a Group item or nil. The wrapper in CityViewAccess
-- assembles the list and pushes the sub-handler. No state is cached;
-- every group is rebuilt on each Stats push, so a buy / specialist
-- change / route shift in another sub-handler that pops back through
-- Stats produces fresh numbers.
```

## Outline

- L24: `CityStats = {}`
- L31: `local function yieldTooltipFn(yieldKey)`
- L61: `local function splitTooltipLines(text)`
- L94: `local YIELD_DEFS = { ... }`
- L153: `function CityStats.yieldRows(city, helperFn)`
- L174: `local function buildYieldsGroup(city)`
- L203: `function CityStats.growthRows(city)`
- L224: `local function buildGrowthGroup(city)`
- L241: `function CityStats.cultureRows(city)`
- L261: `local function buildCultureGroup(city)`
- L281: `function CityStats.happinessRows(city, player)`
- L291: `local function buildHappinessGroup(city, player)`
- L311: `local function pressureToken(pressureRaw)`
- L316: `function CityStats.religionRows(city)`
- L363: `local function buildReligionGroup(city)`
- L387: `local function tradeDirectionKey(route, cityId)`
- L394: `local function tradeDomainKey(route)`
- L401: `function CityStats.tradeRows(city, player)`
- L430: `local function buildTradeGroup(city, player)`
- L454: `function CityStats.resourceRows(city)`
- L487: `local function buildResourcesGroup(city)`
- L509: `local DEFENSIVE_BUILDING_TYPES = { ... }`
- L516: `local function defensiveBuildingNames(city)`
- L527: `local function defenseGarrisonLabel(city)`
- L540: `function CityStats.defenseRows(city)`
- L556: `local function buildDefenseGroup(city)`
- L573: `function CityStats.demandRow(city)`
- L588: `local function buildDemandGroup(city)`
- L605: `function CityStats.buildItems(city, player)`

## Notes

- L153 `CityStats.yieldRows`: accepts an optional `helperFn` override so the offline test harness can substitute its own yield-tooltip functions without touching engine globals.
- L311 `pressureToken`: divides raw pressure by `GameDefines["RELIGION_MISSIONARY_PRESSURE_MULTIPLIER"]` to match the per-turn display value shown on the sighted hover tooltip.
- L573 `CityStats.demandRow`: calls `city:GetResourceDemanded(true)` (with the `bIgnoreActiveReligi` flag) to detect whether any demand cycle has started at all, then calls it again without the flag to get the actual demanded resource ID.
