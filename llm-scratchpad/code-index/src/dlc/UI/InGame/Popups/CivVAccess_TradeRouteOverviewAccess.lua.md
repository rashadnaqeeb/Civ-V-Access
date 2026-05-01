# `src/dlc/UI/InGame/Popups/CivVAccess_TradeRouteOverviewAccess.lua`

359 lines · Accessibility wrapper for the Ctrl+T Trade Route Overview popup, presenting three tabs (your routes, available routes, routes with you) via TabbedShell with tooltip-driven drill-in sections per route.

## Header comment

```
-- Trade Route Overview accessibility (Ctrl+T). Wraps the engine popup as a
-- three-tab TabbedShell, every tab a flat BaseMenu list of route Groups.
--
--   Your trade routes      pPlayer:GetTradeRoutes()
--                          Routes the active player currently runs (caravans
--                          and cargo ships you have in flight).
--   Available trade routes pPlayer:GetTradeRoutesAvailable()
--                          Routes the active player could establish from
--                          idle trade units.
--   Trade routes with you  pPlayer:GetTradeRoutesToYou()
--                          Routes other civs run that terminate in your
--                          cities (their bonuses, your destination).
--
-- The three accessors return rows with the same field shape (see
-- TradeRouteOverview.lua DisplayData), so the row builder is shared.
--
-- Each row's drill-in is the engine's own tooltip
-- (BuildTradeRouteToolTipString) split per [NEWLINE] line. The engine sets
-- that same tooltip on every cell of the row -- gold cells, science cells,
-- religion cells, etc. -- so a sighted player sees one rich tooltip from any
-- cell hover. We surface the same tooltip line by line so a screen-reader
-- user steps through the same content without trying to navigate cells.
--
-- Engine integration: ships an override of TradeRouteOverview.lua (verbatim
-- BNW copy + an include for this module). The engine's OnPopupMessage,
-- OnClose, ShowHideHandler, InputHandler, RegisterSortOptions, TabSelect,
-- and per-tab RefreshContent stay intact; TabbedShell.install layers our
-- handler on top via priorInput / priorShowHide chains. onShow rebuilds
-- every tab's items so a fresh open after a turn change reflects updated
-- TurnsLeft / GPT values.
```

## Outline

- L54: `local priorInput = InputHandler`
- L55: `local priorShowHide = ShowHideHandler`
- L59: `local m_yoursTab`
- L60: `local m_availableTab`
- L61: `local m_withYouTab`
- L68: `local function civName(playerID)`
- L86: `local function domainLabel(domain)`
- L93: `local function appendIf(list, entry)`
- L102: `local function originSideList(route)`
- L113: `local function destinationSideList(route)`
- L128: `local function splitOn(s, token)`
- L158: `local function buildSectionItem(section)`
- L189: `local function rowLabel(route, isInbound)`
- L233: `local function buildRouteGroup(route, isInbound)`
- L279: `local function sortRoutes(routes)`
- L287: `local function buildItemsFromRoutes(routes, isInbound)`
- L301: `local function buildItemsViaAccessor(accessor, isInbound)`
- L311: `TabbedShell.install(ContextPtr, { ... })`
- L352: `Events.ActivePlayerTurnStart.Add(...)`

## Notes

- L128 `splitOn`: Uses plain-string find (4th arg `true`) so tokens like `[NEWLINE]` are matched literally rather than as Lua patterns.
- L233 `buildRouteGroup`: Sets `cached=false` so each drill re-calls `BuildTradeRouteToolTipString` for live values; the row label itself closes over the snapshot and only updates on `ActivePlayerTurnStart`.
