# `src/dlc/UI/InGame/Popups/CivVAccess_DemographicsAccess.lua`

349 lines · Accessibility wrapper for the Demographics popup (F9), presenting one row per metric with rank, value, best/average/worst, and rival civ names in a flat BaseMenu list.

## Header comment

```
-- Demographics accessibility (F9). Wraps the engine Demographics popup as
-- a flat BaseMenu list: one row per metric (Population, Crop Yield, GNP,
-- etc.), each speaking the active player's value, rank, and the rival
-- best / average / worst figures in vanilla column order. The screen has
-- no useful secondary axis -- rows are heterogeneous metrics, not sortable
-- like F2's city table -- so a flat list is the natural shape; vanilla's
-- table is visual scaffolding, not strategic structure.
--
-- Per-metric formulas mirror Demographics.lua's GetXValue functions
-- verbatim so the numbers a sighted onlooker sees in the column match
-- what we speak. Locale.ToNumber with vanilla's format strings keeps
-- comma grouping locale-correct.
--
-- All values are recomputed on every show via onShow -> setItems so the
-- ranking tracks the engine across turn ends. No upvalue caching.
--
-- Engine integration: ships an override of Demographics.lua (verbatim
-- base copy + an include for this module). The engine's OnPopup, OnBack,
-- ShowHideHandler, InputHandler, and GameplaySetActivePlayer wiring stay
-- intact; BaseMenu.install layers our handler on top via priorInput /
-- priorShowHide chains.
```

## Outline

- L43: `local priorInput = InputHandler`
- L44: `local priorShowHide = ShowHideHandler`
- L46: `DemographicsAccess = DemographicsAccess or {}`
- L50: `local function activePlayerId()`
- L54: `local function activeTeamId()`
- L58: `local function isMP()`
- L62: `local function playerHasMet(pPlayer)`
- L73: `local function civDisplayName(pPlayer)`
- L93: `local function eachMajorAlive()`
- L114: `local function formatBig(n)`
- L118: `local function formatPct(n)`
- L128: `local function valuePopulation(pPlayer)`
- L132: `local function valueFood(pPlayer)`
- L136: `local function valueProduction(pPlayer)`
- L140: `local function valueGold(pPlayer)`
- L144: `local function valueLand(pPlayer)`
- L148: `local function valueArmy(pPlayer)`
- L155: `local function valueApproval(pPlayer)`
- L164: `local function valueLiteracy(pPlayer)`
- L185: `local function bestOf(valueFn)`
- L196: `local function worstOf(valueFn)`
- L208: `local function averageOf(valueFn)`
- L221: `local function rankOf(valueFn, pSelf)`
- L256: `local function metricRow(labelKey, valueFn, formatFn, measureKey, magSuffix)`
- L290: `local function buildItems()`
- L307: `DemographicsAccess.civDisplayName = civDisplayName`
- L308: `DemographicsAccess.valuePopulation = valuePopulation`
- L309: `DemographicsAccess.valueFood = valueFood`
- L310: `DemographicsAccess.valueProduction = valueProduction`
- L311: `DemographicsAccess.valueGold = valueGold`
- L312: `DemographicsAccess.valueLand = valueLand`
- L313: `DemographicsAccess.valueArmy = valueArmy`
- L314: `DemographicsAccess.valueApproval = valueApproval`
- L315: `DemographicsAccess.valueLiteracy = valueLiteracy`
- L316: `DemographicsAccess.bestOf = bestOf`
- L317: `DemographicsAccess.worstOf = worstOf`
- L318: `DemographicsAccess.averageOf = averageOf`
- L319: `DemographicsAccess.rankOf = rankOf`
- L320: `DemographicsAccess.buildItems = buildItems`
- L324: `if type(ContextPtr) == "table" and type(ContextPtr.SetShowHideHandler) == "function" then`
- L325: `local handler = BaseMenu.install(ContextPtr, { ... })`
- L338: `handler.bindings[#handler.bindings + 1] = { key = Keys.VK_F9, ... }`

## Notes

- L148 `valueArmy`: Returns `math.sqrt(pPlayer:GetMilitaryMight()) * 2000`, matching the Demographics.lua formula exactly; the raw "might" value is not the number spoken.
- L155 `valueApproval`: Returns 60 + 3*excessHappiness, clamped to 0-100; this is a synthetic approval rating, not a direct engine field.
- L338: F9 re-press binding is appended to `handler.bindings` after install, not declared in the install spec, because it requires the handler reference returned by `BaseMenu.install`.
