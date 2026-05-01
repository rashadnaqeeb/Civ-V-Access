# `src/dlc/UI/InGame/Popups/CivVAccess_EconomicOverviewAccess.lua`

851 lines · Accessibility wrapper for the Economic Overview popup (F2), presenting a four-tab TabbedShell: Cities (sortable BaseTable), Gold (income/expense breakdown), Happiness (sources/sinks), and Resources (available/imported/exported/local).

## Header comment

```
-- Economic Overview accessibility (F2 / Domestic Advisor). Wraps the engine
-- popup as a four-tab TabbedShell:
--
--   Cities    -- BaseTable, one row per owned city, columns for population,
--                 name, defensive strength, food, science, gold, culture,
--                 faith, production. Sortable on every column. Enter on the
--                 Production cell opens the city's Choose Production popup;
--                 Enter on the Name cell focuses the city on the map.
--   Gold      -- BaseMenu list, treasury / income / expense breakdown with
--                 expandable per-city sub-lists for cities, trade routes,
--                 and building maintenance.
--   Happiness -- BaseMenu list, combined happiness and unhappiness sources
--                 (engine pairs them in one column already), per-city
--                 expansions for resources, buildings, trade routes, local
--                 cities, and per-city unhappiness with occupation flag.
--   Resources -- BaseMenu list, four collapsible sections: Available,
--                 Imported, Exported, Local. Lists each resource and its
--                 net count. Bonus resources excluded.
--
-- Initial tab is Cities (the densest user-facing data; matches the engine's
-- default landing tab "General Information" of which the city table is the
-- right pane).
--
-- Engine integration: the base game ships
-- Assets/UI/InGame/Popups/EconomicOverview.lua which we override with a
-- verbatim copy plus an include line for this module. The override-as-extend
-- pattern keeps the engine's button registration, popup queueing, and
-- GameplaySetActivePlayer wiring intact, and our include() at the tail wires
-- the TabbedShell on top.
```

## Outline

- L54: `local priorInput = InputHandler`
- L55: `local priorShowHide = ShowHideHandler`
- L62: `EconomicOverviewAccess = EconomicOverviewAccess or {}`
- L67: `local function activePlayer()`
- L74: `local function formatSigned(n)`
- L87: `local function formatGoldT100(t100)`
- L91: `local function formatNumber(n)`
- L100: `local function cityAnnotation(city)`
- L113: `local function cityRowLabel(city)`
- L122: `local function rebuildCityRows()`
- L134: `local function cityProductionPerTurn(city)`
- L144: `local function productionCellText(city)`
- L165: `local function productionColumnCell(city)`
- L173: `local function focusCity(city)`
- L178: `local function openChooseProduction(city)`
- L194: `local function constPedia(textKey)`
- L198: `local function buildCityColumns()`
- L272: `local function buildCitiesTab()`
- L283: `local function goldTextItem(labelKey, valueFn)`
- L295: `local function perCityGoldEntries(amountFn, includePred)`
- L321: `local function buildGoldItems()`
- L447: `local function buildGoldTab()`
- L462: `local function perCityHappinessEntries(amountFn, includePred, annotateFn)`
- L496: `local function perLuxuryHappinessEntries()`
- L521: `local function buildHappinessItems()`
- L722: `local function buildHappinessTab()`
- L737: `local function isLuxOrStrategic(resourceID)`
- L741: `local function resourceEntries(amountFn)`
- L768: `local function buildResourcesItems()`
- L809: `local function buildResourcesTab()`
- L821: `EconomicOverviewAccess.formatSigned = formatSigned`
- L822: `EconomicOverviewAccess.formatGoldT100 = formatGoldT100`
- L823: `EconomicOverviewAccess.formatNumber = formatNumber`
- L824: `EconomicOverviewAccess.cityAnnotation = cityAnnotation`
- L825: `EconomicOverviewAccess.cityRowLabel = cityRowLabel`
- L826: `EconomicOverviewAccess.cityProductionPerTurn = cityProductionPerTurn`
- L827: `EconomicOverviewAccess.productionColumnCell = productionColumnCell`
- L828: `EconomicOverviewAccess.buildCityColumns = buildCityColumns`
- L829: `EconomicOverviewAccess.rebuildCityRows = rebuildCityRows`
- L836: `if type(ContextPtr) == "table" and type(ContextPtr.SetShowHideHandler) == "function" then`
- L837: `TabbedShell.install(ContextPtr, { ... })`

## Notes

- L87 `formatGoldT100`: Takes a times-100 integer (engine's gold representation) and divides before formatting; passing a raw GPT value would produce a result 100x too large.
- L134 `cityProductionPerTurn`: Applies the city's production modifier percentage on top of the base yield, matching `EconomicGeneralInfo.lua`'s `totalProductionPerTurn` computation.
