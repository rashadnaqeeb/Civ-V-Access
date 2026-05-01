# `src/dlc/UI/InGame/CivVAccess_TradeLogicAccess.lua`

568 lines · Orchestrator for the diplomacy trade screen accessibility layer: declares the `TradeLogicAccess` global, includes the two sub-modules, exposes shared helpers on the table for cross-module use, and owns the drawer-push / top-items / action-button / install / rebuild / listener logic for three Context wrappers (AI DiploTrade, PvP SimpleDiploTrade, DiploCurrentDeals).

## Header comment

```
-- Diplomacy trade screen accessibility orchestrator. Loaded via include
-- from three Context wrappers (AI DiploTrade, PvP SimpleDiploTrade,
-- review DiploCurrentDeals); each Context calls TradeLogicAccess.install
-- with a descriptor naming the kind, preamble, and any Context-specific
-- top-items override.
--
-- The screen has a flat top-level BaseMenu with up to six items
-- (Your Offer, Their Offer, an AI query slot, Propose, Cancel, Modify).
-- Activating Your / Their Offer pushes a drawer -- a tabbed BaseMenu with
-- Offering (items currently on the table) and Available (items that
-- could be placed). Read-only states (AI demand / request / offer, or
-- g_bTradeReview) push a flat Offering-only drawer instead.
--
-- The Offering and Available item builders live in two sibling files:
--   CivVAccess_TradeLogicOffering.lua  -> TradeLogicOffering.buildOfferingItems
--   CivVAccess_TradeLogicAvailable.lua -> TradeLogicAvailable.buildAvailableItems
-- Both are included from this orchestrator so that whichever Context
-- pulls in CivVAccess_TradeLogicAccess gets the full split transparently.
-- The shared per-side helpers (prefix, sidePlayer, sideIsUs, turnsSuffix,
-- pocketTooltipFn, dealDuration, peaceDuration, afterLocalDealChange,
-- emptyPlaceholder, clearEngineTable) are exposed on the TradeLogicAccess
-- table so the sub-modules can call them at item-build time.
--
-- Reads of TradeLogic state rely on eight g_* names we promoted to globals
-- in our shipped TradeLogic.lua override (g_Deal, g_iUs, g_iThem,
-- g_iDiploUIState, g_bTradeReview, g_LeagueVoteList, g_UsTableResources,
-- g_ThemTableResources). The base file declares them `local` at chunk
-- scope, which Lua 5.1 hides from the next included chunk -- so without
-- the promotion, every read here would see nil and every build* function
-- would return its empty-placeholder path.
--
-- Rebuild triggers: any state change that could flip an item's visibility
-- or label (AI responded, remote PvP peer proposed/withdrew, active player
-- changed, deal wiped). Listeners register fresh on every Context include
-- per CLAUDE.md's no-install-once-guards rule -- dead listeners from a
-- prior game throw harmlessly on first global access under the engine's
-- per-listener pcall.
```

## Outline

- L39: `include("CivVAccess_TradeLogicOffering")`
- L40: `include("CivVAccess_TradeLogicAvailable")`
- L42: `TradeLogicAccess = {}`
- L44: `local DRAWER_NAME = "DiploTrade/Drawer"`
- L51: `local _handler = nil`
- L52: `local _drawerHandler = nil`
- L53: `local _descriptor = nil`
- L60: `local function dealDuration()`
- L64: `local function peaceDuration()`
- L76: `local function turnsSuffix(duration)`
- L88: `local function isReadOnly()`
- L103: `local function isHumanDemand()`
- L110: `local function sidePlayer(side)`
- L117: `local function sideIsUs(side)`
- L125: `local function prefix(side)`
- L134: `local function pocketTooltipFn(controlName)`
- L147: `local function clearEngineTable()`
- L161: `local function emptyPlaceholder(textKey)`
- L169: `local function rebuildDrawer()`
- L203: `local function afterLocalDealChange()`
- L224: `TradeLogicAccess.dealDuration = dealDuration`
- L225: `TradeLogicAccess.peaceDuration = peaceDuration`
- L226: `TradeLogicAccess.turnsSuffix = turnsSuffix`
- L227: `TradeLogicAccess.isReadOnly = isReadOnly`
- L228: `TradeLogicAccess.isHumanDemand = isHumanDemand`
- L229: `TradeLogicAccess.sidePlayer = sidePlayer`
- L230: `TradeLogicAccess.sideIsUs = sideIsUs`
- L231: `TradeLogicAccess.prefix = prefix`
- L232: `TradeLogicAccess.pocketTooltipFn = pocketTooltipFn`
- L233: `TradeLogicAccess.clearEngineTable = clearEngineTable`
- L234: `TradeLogicAccess.emptyPlaceholder = emptyPlaceholder`
- L235: `TradeLogicAccess.afterLocalDealChange = afterLocalDealChange`
- L239: `TradeLogicAccess.buildOfferingItems = TradeLogicOffering.buildOfferingItems`
- L240: `TradeLogicAccess.buildAvailableItems = TradeLogicAvailable.buildAvailableItems`
- L244: `local function pushDrawer(side)`
- L293: `function TradeLogicAccess.buildYourOfferItem(useVisibilityControl)`
- L306: `function TradeLogicAccess.buildTheirOfferItem(useVisibilityControl)`
- L328: `local function actionButtonLeaf(controlName, activate, fallbackLabel)`
- L368: `local function buildTopItems(descriptor)`
- L470: `local function effectiveTopItems(descriptor)`
- L482: `function TradeLogicAccess.rebuild()`
- L491: `function TradeLogicAccess.install(ContextPtr, priorInput, priorShowHide, descriptor)`
- L567: `return TradeLogicAccess`

## Notes

- L239-L240: re-export aliases so callers that previously reached `TradeLogicAccess.buildOfferingItems` / `buildAvailableItems` before the split continue to work without changes.
- L293 `buildYourOfferItem` / L306 `buildTheirOfferItem`: exported so Contexts with a non-standard top-level list (DiploCurrentDeals) can compose them into their own `topItemsFn`.
