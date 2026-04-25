-- DiploCurrentDeals accessibility. The popup is reached from DiploOverview
-- and hosts two shapes in one Context: a deal picker (current + historic
-- deal rows) and a trade-style review drawer. We replace the top-level
-- flat list with a deal-picker layout; Your / Their Offer route into the
-- same drawer TradeLogicAccess builds for AI / PvP trades.
--
-- No rebuild triggers are registered (descriptor.skipStandardListeners):
-- the TradeLogicAccess default listeners (AILeaderMessage, trade-opened
-- events, GameplaySetActivePlayer) target on-screen live trades, not a
-- deal-review session. The picker list is stable while the popup is open,
-- so one build at onShow is enough; deal activation mutates g_Deal via
-- OpenDealReview and the drawer reads live state when pushed.
--
-- Your / Their Offer navigability is gated dynamically on the scratch
-- deal's item count rather than rebuilt. This avoids having to re-iterate
-- every deal on each selection (which would mutate g_Deal as a side
-- effect and force a restore-to-selection step).

include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_TextFilter")
include("CivVAccess_InGameStrings_en_US")
include("CivVAccess_Text")
include("CivVAccess_Icons")
include("CivVAccess_SpeechEngine")
include("CivVAccess_SpeechPipeline")
include("CivVAccess_HandlerStack")
include("CivVAccess_InputRouter")
include("CivVAccess_TickPump")
include("CivVAccess_Nav")
include("CivVAccess_BaseMenuItems")
include("CivVAccess_TypeAheadSearch")
include("CivVAccess_BaseMenuHelp")
include("CivVAccess_BaseMenuTabs")
include("CivVAccess_BaseMenuCore")
include("CivVAccess_BaseMenuInstall")
include("CivVAccess_BaseMenuEditMode")
include("CivVAccess_BaseMenuNumberEntry")
include("CivVAccess_TradeLogicAccess")
include("CivVAccess_Help")

-- Tab / Shift+Tab cycle to Global / Relations. See
-- CivVAccess_DiploOverviewBridge for the cross-Context mechanism; the
-- sibling panel's visibility flip fires ShowHide on both panels, which
-- pops our BaseMenu and pushes the sibling's.
local priorInput = InputHandler
local priorShowHide = ShowHideHandler

-- Build one Text item per deal in the current / historic list. Loading the
-- deal is the only way to read its other-player + item count (mirrors base
-- PopulateDealChooser). Iteration leaves g_Deal set to the last-loaded
-- deal; topItemsFn clears it afterwards so Your / Their Offer stay gated
-- off until the user activates one.
local function buildDealItems(iPlayer, isCurrent, count)
    local items = {}
    for i = 0, count - 1 do
        if isCurrent then
            UI.LoadCurrentDeal(iPlayer, i)
        else
            UI.LoadHistoricDeal(iPlayer, i)
        end
        local pScratch = UI.GetScratchDeal()
        local iOtherPlayer = pScratch:GetOtherPlayer(iPlayer)
        local pOther = Players[iOtherPlayer]
        local otherName = (pOther and pOther:GetName()) or "?"
        local nItems = pScratch:GetNumItems() or 0
        local label = Text.format("TXT_KEY_CIVVACCESS_DEAL_SUMMARY", otherName, tostring(nItems))
        local capturedI = i
        local capturedIsCurrent = isCurrent
        items[#items + 1] = BaseMenuItems.Text({
            labelText = label,
            onActivate = function()
                if capturedIsCurrent then
                    UI.LoadCurrentDeal(iPlayer, capturedI)
                else
                    UI.LoadHistoricDeal(iPlayer, capturedI)
                end
                -- OpenDealReview is a plain Lua fn on TradeLogic's env; it
                -- sets g_bTradeReview = true, resets g_iUs / g_iThem from
                -- the loaded deal, and runs DoClearTable + DisplayDeal.
                local ok, err = pcall(OpenDealReview)
                if not ok then
                    Log.error("DiploCurrentDealsAccess OpenDealReview failed: " .. tostring(err))
                end
            end,
        })
    end
    return items
end

-- Your / Their Offer are navigable only once OpenDealReview has populated
-- g_Deal AND set g_bTradeReview. The flag matters: if OpenDealReview fails
-- under pcall in onActivate, g_Deal is still loaded from the prior Load
-- call but the drawer's read-only mode would not be set. Without the flag
-- gate the user could open a mutable drawer against a historical deal.
local function hasLoadedDeal()
    return UI.GetScratchDeal():GetNumItems() > 0 and g_bTradeReview == true
end

local function topItemsFn(_descriptor)
    local iPlayer = Game.GetActivePlayer()
    local items = {}

    local nCurrent = UI.GetNumCurrentDeals(iPlayer) or 0
    if nCurrent > 0 then
        items[#items + 1] = BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_DO_CURRENT_DEALS"),
            items = buildDealItems(iPlayer, true, nCurrent),
        })
    end

    local nHistoric = UI.GetNumHistoricDeals(iPlayer) or 0
    if nHistoric > 0 then
        items[#items + 1] = BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_DO_COMPLETE_DEALS"),
            items = buildDealItems(iPlayer, false, nHistoric),
        })
    end

    -- Early game and post-clean-slate: no current or historic deals. Your
    -- Offer / Their Offer stay non-navigable (gated on hasLoadedDeal), so
    -- without an explicit entry the user lands on a menu with nothing
    -- reachable. Announce the empty state as the first navigable item.
    if nCurrent == 0 and nHistoric == 0 then
        items[#items + 1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_CIVVACCESS_DIPLO_NO_DEALS"),
        })
    end

    -- buildDealItems left the scratch deal holding the last iterated deal.
    -- Clear it so Your / Their Offer report not-navigable on initial show
    -- (and after the user backs out of a review, if we ever rebuild --
    -- today we don't, but the reset keeps behavior correct either way).
    UI.GetScratchDeal():ClearItems()

    -- Your / Their Offer: push the same drawer TradeLogicAccess builds for
    -- AI / PvP trades. Navigability gated on "a deal has been loaded"
    -- rather than a visibility control -- DiploCurrentDeals has no
    -- UsPanel / ThemPanel to read.
    local yourOffer = TradeLogicAccess.buildYourOfferItem()
    yourOffer.isNavigable = hasLoadedDeal
    yourOffer.isActivatable = hasLoadedDeal
    items[#items + 1] = yourOffer

    local theirOffer = TradeLogicAccess.buildTheirOfferItem()
    theirOffer.isNavigable = hasLoadedDeal
    theirOffer.isActivatable = hasLoadedDeal
    items[#items + 1] = theirOffer

    return items
end

TradeLogicAccess.install(ContextPtr, priorInput, priorShowHide, {
    name = "DiploCurrentDeals",
    kind = "Review",
    fallbackDisplayName = Text.key("TXT_KEY_DO_CURRENT_DEALS"),
    topItemsFn = topItemsFn,
    skipStandardListeners = true,
    onTab = function()
        civvaccess_shared.DiploOverview.showGlobal()
    end,
    onShiftTab = function()
        civvaccess_shared.DiploOverview.showRelations()
    end,
    -- See CivVAccess_DiploRelationshipsAccess for the sub-LuaContext
    -- input-bubbling rationale.
    onEscape = function()
        civvaccess_shared.DiploOverview.close()
        return true
    end,
    suppressReactivateOnHide = function()
        return civvaccess_shared.DiploOverview._switching == true
    end,
})
