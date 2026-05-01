# `src/dlc/UI/InGame/CivVAccess_TradeLogicAccess.lua`

1397 lines · Shared logic for the diplomacy trade screen accessibility layer, building BaseMenu item trees for the Offering and Available tabs and installing the top-level handler with rebuild listeners for three Context wrappers (AI DiploTrade, PvP SimpleDiploTrade, DiploCurrentDeals).

## Header comment

```
-- Shared logic for the diplomacy trade screen accessibility layer. Loaded
-- from three Context wrappers (AI DiploTrade, PvP SimpleDiploTrade, review
-- DiploCurrentDeals) via include; each Context gets its own function table
-- bound to that Context's Controls / globals.
--
-- The screen has a flat top-level BaseMenu with six items (Your Offer, Their
-- Offer, an AI query slot, Propose, Cancel, Modify). Activating Your / Their
-- Offer pushes a drawer -- a tabbed BaseMenu with Offering (items on the
-- table) and Available (items that could be placed). Read-only states
-- (AI demand / request / offer, or g_bTradeReview) push a flat Offering-only
-- drawer instead.
--
-- Reads of TradeLogic state rely on eight g_* names we promoted to globals
-- in our shipped TradeLogic.lua override [...]. The base file declares them
-- `local` at chunk scope, which Lua 5.1 hides from the next included chunk.
--
-- Rebuild triggers: any state change that could flip an item's visibility
-- or label [...]. Listeners register fresh on every Context include
-- per CLAUDE.md's no-install-once-guards rule.
```

## Outline

- L28: `TradeLogicAccess = {}`
- L30: `local DRAWER_NAME = "DiploTrade/Drawer"`
- L37: `local _handler = nil`
- L38: `local _drawerHandler = nil`
- L39: `local _descriptor = nil`
- L44: `local function dealDuration()`
- L49: `local function peaceDuration()`
- L63: `local function turnsSuffix(duration)`
- L72: `local function isReadOnly()`
- L87: `local function isHumanDemand()`
- L94: `local function sidePlayer(side)`
- L100: `local function sideIsUs(side)`
- L109: `local function prefix(side)`
- L117: `local function rebuildDrawer()`
- L151: `local function afterLocalDealChange()`
- L172: `local function pocketTooltipFn(controlName)`
- L186: `local offeringItem`
- L192: `local function clearEngineTable()`
- L211: `local function emptyPlaceholder(textKey)`
- L215: `function TradeLogicAccess.buildOfferingItems(side, readOnly)`
- L251: `offeringItem = function(itemType, data1, data2, data3, flag1, duration, side, readOnly)`
- L593: `local function disabledPocketLeaf(label, controlName)`
- L603: `local function availableGoldLeaf(side)`
- L635: `local function availableGoldPerTurnLeaf(side)`
- L667: `local function availableResourceLeaf(side, resType, resInfo)`
- L725: `local function availableBooleanLeaf(side, labelKey, itemConstant, controlSuffix, addFn, bothSides)`
- L762: `local function availableResourceGroups(side)`
- L808: `local function availableVotesGroup(side)`
- L882: `local function availableCitiesGroup(side)`
- L930: `local function availableOtherPlayersGroup(side)`
- L999: `function TradeLogicAccess.buildAvailableItems(side)`
- L1074: `local function pushDrawer(side)`
- L1123: `function TradeLogicAccess.buildYourOfferItem(useVisibilityControl)`
- L1136: `function TradeLogicAccess.buildTheirOfferItem(useVisibilityControl)`
- L1158: `local function actionButtonLeaf(controlName, activate, fallbackLabel)`
- L1198: `local function buildTopItems(descriptor)`
- L1300: `local function effectiveTopItems(descriptor)`
- L1312: `function TradeLogicAccess.rebuild()`
- L1321: `function TradeLogicAccess.install(ContextPtr, priorInput, priorShowHide, descriptor)`
- L1397: `return TradeLogicAccess`

## Notes

- L186 `local offeringItem`: forward-declared nil then assigned at L251 as a function value so `buildOfferingItems` above it can reference it.
- L251 `offeringItem`: not a module-table function; assigned to a local so only `buildOfferingItems` calls it.
- L593 `disabledPocketLeaf`: name implies it only surfaces engine-disabled states, but it is also used for items that fail IsPossibleToTradeItem (legally unavailable, not just temporarily greyed).
