# `src/dlc/UI/InGame/CityView/CivVAccess_CityViewAccess.lua`

2002 lines · Hub accessibility handler for the CityView screen, wiring a multi-section BaseMenu with sub-handlers for production queue, hex map, buildings, specialists, wonders, great works, great people, worker focus, stats, ranged strike, rename, and raze.

## Header comment

```
-- CityView accessibility. Hub handler for the city management screen.
--
-- Opens when the engine shows the CityView Context (banner click on own
-- city, Enter on a friendly hex, etc.). Every section of the screen is
-- reached through a sub-handler pushed on top of this hub. This phase
-- wires only the hub scaffold: preamble announcement, F1 re-read, Esc
-- close, next / previous city hotkeys, and auto-re-announce on
-- city-change. Hub items and sub-handlers are added in later phases.
--
-- SerialEventCityScreenDirty fires on city switches AND on turn ticks
-- while the screen is up. A city-ID compare filters out the turn-tick
-- case so only real city changes re-announce.
```

## Outline

- L44: `local priorInput = InputHandler`
- L49: `local VK_OEM_COMMA = 188`
- L50: `local VK_OEM_PERIOD = 190`
- L52: `local hubHandler`
- L64: `local function preamble()`
- L88: `local function hasOtherCities()`
- L96: `local function nextCity()`
- L104: `local function previousCity()`
- L120: `local _lastCityID = nil`
- L122: `local function onCityScreenDirty()`
- L151: `Events.SerialEventCityScreenDirty.Add(function() ... pcall(onCityScreenDirty) ... end)`
- L168: `local function wrappedShowHide(bIsHide, _bIsInit)`
- L189: `local function makeHubItem(spec, activateFn)`
- L194: `local function sortByLocalizedName(list)`
- L204: `local function pushCitySub(subName, displayName, items)`
- L214: `local function isTurnActive()`
- L226: `local function isWonderBuilding(building)`
- L243: `local function cityHasAnyWonder(city)`
- L252: `local function pushWonders()`
- L288: `local function cityHasAnyGreatPersonProgress(city)`
- L297: `local function pushGreatPeople()`
- L336: `local FOCUS_TYPES = { ... }`
- L347: `local function pushWorkerFocus()`
- L422: `local function unemployedLabel()`
- L428: `local function activateUnemployed()`
- L456: `local function pushSellConfirmSub(buildingID)`
- L492: `local function pushBuildings()`
- L538: `local function cityHasAnyNonWonderBuilding(city)`
- L567: `local function cityHasAnySpecialistSlots(city)`
- L583: `local function buildSpecialistTooltip(city, specID, specInfo)`
- L605: `local function pushSpecialists()`
- L762: `local function pushGreatWorks()`
- L777: `local GW_SLOT_TYPE_KEY = { ... }`
- L783: `local function isGreatWorkBuilding(building)`
- L787: `local function cityHasAnyGreatWorkSlots(city)`
- L796: `local function pushGreatWorks()`
- L920: `local ORDER_INFO_TABLE = { ... }`
- L935: `local function orderNameAndHelp(orderType, data1)`
- L949: `local function slotTurnsLeft(city, orderType, data1, zeroIdx)`
- L960: `local function isGeneratingProduction(city)`
- L964: `local function slotOneLabel(city, orderType, data1)`
- L979: `local function slotNLabel(city, displaySlot, zeroIdx, orderType, data1)`
- L991: `local pushProductionQueue`
- L996: `local function rebuildQueueAfterMutation()`
- L1002: `local function pushQueueSlotActions(zeroIdx, slotName)`
- L1066: `local function buildProductionQueueItems()`
- L1200: `pushProductionQueue = function()`
- L1276: `local _hexDeps = civvaccess_shared.modules or {}`
- L1277: `local Cursor = _hexDeps.Cursor`
- L1278: `local ScannerNav = _hexDeps.ScannerNav`
- L1279: `local ScannerHandler = _hexDeps.ScannerHandler`
- L1280: `local SurveyorCore = _hexDeps.SurveyorCore`
- L1281: `local PlotComposers = _hexDeps.PlotComposers`
- L1282: `local HexGeom = _hexDeps.HexGeom`
- L1298: `local function plotIndexInRing(city, plot)`
- L1319: `local function isInWorkingArea(city, plot)`
- L1338: `local function workedStateTokens(city, plot)`
- L1353: `local function hexTileAnnouncement(plot)`
- L1402: `local function hexMapScope(x, y)`
- L1428: `local function activateHexTile()`
- L1501: `local function listWorkedTilesFromCursor()`
- L1557: `local function pushHexMap()`
- L1738: `local function pushRangedStrike()`
- L1800: `local function activateRename()`
- L1830: `local function canShowRaze(city)`
- L1841: `local function activateRaze()`
- L1853: `local function activateUnraze()`
- L1870: `local function pushStats()`
- L1897: `local function buildHubItems(city)`
- L1945: `local function rebuildHubItems()`
- L1953: `local function onShow(_handler)`
- L1961: `local hubHandler = BaseMenu.install(ContextPtr, { name = "CityView", ... })`
- L1976: `hubHandler.onActivate = function(self) ... rebuildHubItems() ... end`
- L1982: `hubHandler.bindings[...] = { key = VK_OEM_PERIOD, fn = nextCity }`
- L1988: `hubHandler.bindings[...] = { key = VK_OEM_COMMA, fn = previousCity }`
- L1994: `BaseMenuHelp.addScreenKey(hubHandler, { keyLabel = "..._KEY_NEXT", ... })`
- L1998: `BaseMenuHelp.addScreenKey(hubHandler, { keyLabel = "..._KEY_PREV", ... })`

## Notes

- L991 `local pushProductionQueue`: declared before `buildProductionQueueItems` and assigned at L1200 because `rebuildQueueAfterMutation` (L996) needs to call `pushProductionQueue` recursively and forward-declaring avoids a circular upvalue.
- L1276-1282: module refs captured from `civvaccess_shared.modules` at include time; these are Boot's published singletons and must not be re-included (which would fragment cursor state across Contexts).
- L1319 `isInWorkingArea`: checks `plot:GetWorkingCity():GetID() == city:GetID() AND GetOwner() == city:GetOwner()` - the double check prevents a neighbour city with the same numeric ID from a different player falsely matching.
- L1557 `pushHexMap`: installs `civvaccess_shared.mapScope` and `civvaccess_shared.mapAnnouncer` immediately before `HandlerStack.push` so `onActivate`'s `Cursor.jumpTo` sees them; rolls both back manually if the push fails.
- L1738 `pushRangedStrike`: uses a double `TickPump.runOnce` (outer waits for the hub's activate flow to return; inner waits for the city screen's `ContextPtr` hide before pushing `CityRangeStrikeMode`) to avoid the handler being popped as collateral damage of `popAbove`.
