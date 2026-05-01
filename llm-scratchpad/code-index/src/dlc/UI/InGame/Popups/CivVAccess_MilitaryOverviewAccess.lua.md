# `src/dlc/UI/InGame/Popups/CivVAccess_MilitaryOverviewAccess.lua`

548 lines · Accessibility wrapper for the F3 Military Overview popup, exposing supply, a sortable unit list split into military/civilian groups, and a Great People progress section.

## Header comment

```
-- MilitaryOverview accessibility (F3). The popup lays out one screen:
--   * Great General and Great Admiral progress meters (top right)
--   * Supply block (left column: base supply, cities, population, cap, use,
--     remaining OR deficit+penalty when over-cap), collapsed to one line
--   * Unit list split into military (combat type != -1 or nukes) and civilian
--     stacks (right column, scrollable)
--
-- Level 0 exposes the supply widget, then a sort selector, then a drill-in
-- per non-empty unit stack, then a Great People progress group at the bottom.
-- Unit rows activate to UI.SelectUnit (or LookAtSelectionPlot if already
-- selected, matching the engine click handler), then OnClose +
-- CameraTracker.followAndJumpCursor so the hex cursor ends up on the selected
-- unit's plot. Sort is global across both unit sub-lists to mirror the engine;
-- ascending/descending toggle is deferred (one direction, matching the default
-- each header click lands on).
--
-- Great People group mirrors the engine's GPList: one drillable subgroup per
-- specialist type (Artist / Writer / Musician / Scientist / Engineer /
-- Merchant), each populated with per-city rows sorted by turns ascending.
-- Subgroups are skipped entirely when no city has any progress for that type
-- (matches GPList's section-hiding). Great General and Great Admiral are flat
-- rows in the same group (player-scoped, no per-city breakdown). Great Prophet
-- is intentionally omitted because GPList doesn't list it -- prophet progress
-- is faith-gated, not GPP-gated, and lives on the Religion Overview screen.
```

## Outline

- L49: `local priorInput = InputHandler`
- L50: `local priorShowHide = ShowHideHandler`
- L54: `local SORT_NAME = 1`
- L55: `local SORT_STATUS = 2`
- L56: `local SORT_MOVEMENT = 3`
- L57: `local SORT_MOVES = 4`
- L58: `local SORT_STRENGTH = 5`
- L59: `local SORT_RANGED = 6`
- L61: `local SORT_ORDER = { ... }`
- L63: `local SORT_LABEL_KEYS = { ... }`
- L72: `local m_sortMode = SORT_NAME`
- L77: `local m_sortIndex = 1`
- L81: `local buildTopItems`
- L86: `local function unitStatusText(unit)`
- L132: `local function formatMoves(sixtieths)`
- L155: `local function buildRowEntry(unit)`
- L184: `local function rowLabel(entry)`
- L202: `local function pediaNameFor(unit)`
- L213: `local function activateUnit(unit)`
- L227: `local function sortComparator(a, b)`
- L254: `local function buildGroupItems(entries)`
- L269: `local function collectUnits()`
- L288: `local function gpProgressWidget(labelKey, currentFn, thresholdFn)`
- L297: `local function supplyWidget()`
- L325: `local function sortSelector(handler)`
- L364: `local function gpRateOfChange(city, specialistInfo, player)`
- L415: `local function buildSpecialistCityRow(specialistInfo, unitClass, city, player)`
- L452: `local function buildSpecialistGroup(specialistInfo)`
- L487: `local function buildGreatPeopleGroup()`
- L513: `function buildTopItems(handler)`
- L536: `local function onShow(handler)`
- L540: `BaseMenu.install(ContextPtr, { ... })`

## Notes

- L81 `buildTopItems`: Forward-declared as a bare local (no `local function`) because it is mutually referenced by `sortSelector`'s inner closure; the actual definition at L513 is a bare global assignment, making it a module-level global.
- L364 `gpRateOfChange`: Verbatim port of `GPList.lua`'s `getRateOfChange`; relies on BNW-only player methods and is explicitly documented as such.
- L513 `buildTopItems`: Declared as a global (no `local`) rather than a local function; this is intentional to satisfy the forward-declaration cycle with `sortSelector`.
