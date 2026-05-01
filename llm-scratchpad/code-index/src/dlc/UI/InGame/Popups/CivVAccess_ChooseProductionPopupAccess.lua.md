# `src/dlc/UI/InGame/Popups/CivVAccess_ChooseProductionPopupAccess.lua`

451 lines · Accessibility wrapper for BUTTONPOPUP_CHOOSEPRODUCTION with two tabs (Produce/Purchase), five groups per tab, prev/next city cycling, puppet gate, and append-mode queue tracking.

## Header comment

```
-- ChooseProduction popup accessibility. Wraps the in-game ProductionPopup
-- (BUTTONPOPUP_CHOOSEPRODUCTION) with a two-tab BaseMenu (Produce, Purchase),
-- five groups per tab (Units, Buildings, Wonders, Other, Current queue), and
-- a preamble that mirrors the sighted top panel.
--
-- Pure builders for entry construction / sort / cost / label composition live
-- in CivVAccess_ChooseProductionLogic. This file owns the install-side wiring:
-- state, preamble, commit paths, prev/next city hotkeys, and the event
-- intercept that rebuilds tabs on each popup fire.
--
-- Entry: Events.SerialEventGameMessagePopup filters by popupInfo.Type. On a
-- match we record the city ref, set the advisor recommender, rebuild both
-- tabs' items via setItems, and hint the opening tab via setInitialTabIndex
-- (Option2 on popupInfo picks Purchase as initial). The deferred push in
-- BaseMenu.install runs onActivate next tick so our setters land before
-- openInitial reads them.
--
-- Puppets auto-manage production; we short-circuit with a "puppet"
-- announcement and close the Context (matches base's silent bail at
-- ProductionPopup.lua:788-790).
--
-- Append mode (popupInfo.Option1, shift-click entry): each commit announces
-- "added, slot N in queue" with post-commit queue length; queue-full (6)
-- closes the popup with a "queue full" announcement. Purchase tab ignores
-- append -- purchases always commit and close.
--
-- Prev / next city (comma / period) cycle via Game.DoControl, close the
-- current popup, and re-fire SerialEventGameMessagePopup for the new
-- selection so our intercept rebuilds against the new city.
```

## Outline

- L55: `local priorInput = InputHandler`
- L56: `local priorShowHide = ShowHideHandler`
- L61: `local VK_OEM_COMMA = 188`
- L62: `local VK_OEM_PERIOD = 190`
- L64: `local TAB_PRODUCE = 1`
- L65: `local TAB_PURCHASE = 2`
- L70: `local _popupInfo = nil`
- L71: `local _cityOwnerID = -1`
- L72: `local _cityID = -1`
- L73: `local _appendMode = false`
- L75: `local function getCurrentCity()`
- L92: `local function preambleFn()`
- L125: `local function fireBannerDirty(city)`
- L132: `local function commitProduce(city, entry)`
- L149: `local function commitPurchase(city, entry)`
- L177: `local function entryActivate(entry)`
- L197: `local function choiceFromEntry(entry)`
- L211: `local function entriesToItems(entries)`
- L225: `local function buildQueueItems(city)`
- L267: `local function makeGroups(isProduce)`
- L319: `local mainHandler = BaseMenu.install(ContextPtr, { ... })`
- L339: `local function announceNoCycle(direction)`
- L347: `local function cycleCity(direction)`
- L371: `table.insert(mainHandler.bindings, { key = VK_OEM_COMMA, ... })`
- L376: `table.insert(mainHandler.bindings, { key = VK_OEM_PERIOD, ... })`
- L393: `table.insert(mainHandler.bindings, { key = Keys.VK_ESCAPE, ... })`
- L408: `local function isVenicePuppetEntry(player, city, popupInfo)`
- L412: `Events.SerialEventGameMessagePopup.Add(...)`

## Notes

- L267 `makeGroups`: returns a closure-wrapped group table; `withCity` re-evaluates `getCurrentCity()` and calls `Game.SetAdvisorRecommenderCity` on every drill-in so advisor data stays current after a city cycle.
- L408 `isVenicePuppetEntry`: Venice (MayNotAnnex) on a puppet city can still Purchase even though Produce is always empty; this is the exception to the puppet short-circuit.
