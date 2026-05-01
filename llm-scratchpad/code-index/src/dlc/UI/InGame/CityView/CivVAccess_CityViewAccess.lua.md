# `src/dlc/UI/InGame/CityView/CivVAccess_CityViewAccess.lua`

1188 lines · Orchestrator for the CityView accessibility hub: includes sub-modules, wires hub lifecycle, navigation hotkeys, and owns the smaller section pushers (Wonders, Buildings, Specialists, Great Works, Great People, Worker Focus, Stats, Ranged Strike, Rename, Raze).

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

- L14: `include("CivVAccess_Polyfill")`
- L15: `include("CivVAccess_Log")`
- L16: `include("CivVAccess_TextFilter")`
- L17: `include("CivVAccess_InGameStrings_en_US")`
- L22: `include("CivVAccess_ScannerStrings_en_US")`
- L23: `include("CivVAccess_SurveyorStrings_en_US")`
- L24: `include("CivVAccess_PluralRules")`
- L25: `include("CivVAccess_Text")`
- L26: `include("CivVAccess_Icons")`
- L27: `include("CivVAccess_SpeechEngine")`
- L28: `include("CivVAccess_SpeechPipeline")`
- L29: `include("CivVAccess_HandlerStack")`
- L30: `include("CivVAccess_InputRouter")`
- L31: `include("CivVAccess_TickPump")`
- L32: `include("CivVAccess_Nav")`
- L33: `include("CivVAccess_BaseMenuItems")`
- L34: `include("CivVAccess_TypeAheadSearch")`
- L35: `include("CivVAccess_BaseMenuHelp")`
- L36: `include("CivVAccess_BaseMenuTabs")`
- L37: `include("CivVAccess_BaseMenuCore")`
- L38: `include("CivVAccess_BaseMenuInstall")`
- L39: `include("CivVAccess_BaseMenuEditMode")`
- L40: `include("CivVAccess_Help")`
- L41: `include("CivVAccess_CitySpeech")`
- L42: `include("CivVAccess_CityStats")`
- L50: `include("CivVAccess_CityViewProduction")`
- L51: `include("CivVAccess_CityViewHexMap")`
- L53: `local priorInput = InputHandler`
- L58: `local VK_OEM_COMMA = 188`
- L59: `local VK_OEM_PERIOD = 190`
- L61: `local hubHandler`
- L73: `local function preamble()`
- L97: `local function hasOtherCities()`
- L105: `local function nextCity()`
- L113: `local function previousCity()`
- L129: `local _lastCityID = nil`
- L131: `local function onCityScreenDirty()`
- L160: `Events.SerialEventCityScreenDirty.Add(function() ... pcall(onCityScreenDirty) ... end)`
- L177: `local function wrappedShowHide(bIsHide, _bIsInit)`
- L198: `local function makeHubItem(spec, activateFn)`
- L203: `local function sortByLocalizedName(list)`
- L213: `local function pushCitySub(subName, displayName, items)`
- L223: `local function isTurnActive()`
- L235: `local function isWonderBuilding(building)`
- L252: `local function cityHasAnyWonder(city)`
- L261: `local function pushWonders()`
- L297: `local function cityHasAnyGreatPersonProgress(city)`
- L306: `local function pushGreatPeople()`
- L345: `local FOCUS_TYPES = { ... }`
- L356: `local function pushWorkerFocus()`
- L431: `local function unemployedLabel()`
- L437: `local function activateUnemployed()`
- L465: `local function pushSellConfirmSub(buildingID)`
- L501: `local function pushBuildings()`
- L547: `local function cityHasAnyNonWonderBuilding(city)`
- L576: `local function cityHasAnySpecialistSlots(city)`
- L592: `local function buildSpecialistTooltip(city, specID, specInfo)`
- L614: `local function pushSpecialists()`
- L786: `local GW_SLOT_TYPE_KEY = { ... }`
- L792: `local function isGreatWorkBuilding(building)`
- L796: `local function cityHasAnyGreatWorkSlots(city)`
- L805: `local function pushGreatWorks()`
- L925: `local function pushRangedStrike()`
- L987: `local function activateRename()`
- L1017: `local function canShowRaze(city)`
- L1028: `local function activateRaze()`
- L1040: `local function activateUnraze()`
- L1057: `local function pushStats()`
- L1084: `local function buildHubItems(city)`
- L1132: `local function rebuildHubItems()`
- L1140: `local function onShow(_handler)`
- L1148: `local hubHandler = BaseMenu.install(ContextPtr, { name = "CityView", ... })`
- L1163: `hubHandler.onActivate = function(self) ... rebuildHubItems() ... end`
- L1169: `hubHandler.bindings[...] = { key = VK_OEM_PERIOD, fn = nextCity }`
- L1175: `hubHandler.bindings[...] = { key = VK_OEM_COMMA, fn = previousCity }`
- L1181: `BaseMenuHelp.addScreenKey(hubHandler, { keyLabel = "..._KEY_NEXT", ... })`
- L1185: `BaseMenuHelp.addScreenKey(hubHandler, { keyLabel = "..._KEY_PREV", ... })`

## Notes

- L50-51: `CityViewProduction` and `CityViewHexMap` are included here; their globals expose a single `.push` entry point that `buildHubItems` calls in place of the old inline closures.
- L925 `pushRangedStrike`: double `TickPump.runOnce` - outer waits for hub activate flow to return; inner waits for city screen hide before pushing `CityRangeStrikeMode` to avoid the handler being popped as collateral damage of `popAbove`.
