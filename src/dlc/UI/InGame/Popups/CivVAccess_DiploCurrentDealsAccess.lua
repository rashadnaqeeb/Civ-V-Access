-- DiploCurrentDeals accessibility. The Current Deals tab of DiploOverview;
-- lists active and historic deals the player is party to. Each deal
-- renders as a single Text leaf whose label inlines the full contents
-- (other civ, what we give, what they give) with per-item duration where
-- the item carries one. There's no drill past the deal, no Your / Their
-- offer drawer, and no scratch-deal mutation outside build time -- review
-- is read-only and the trade-screen drawer pattern only earns its keep
-- when the user is composing or modifying an offer.
--
-- The picker list is stable while the popup is open, so one build at
-- onShow is enough; building loads each deal into the engine's scratch
-- slot to read its items and clears the slot afterwards so it doesn't
-- leak loaded state into other consumers.

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
include("CivVAccess_Help")

-- Tab / Shift+Tab cycle to Global / Relations. See
-- CivVAccess_DiploOverviewBridge for the cross-Context mechanism; the
-- sibling panel's visibility flip fires ShowHide on both panels, which
-- pops our BaseMenu and pushes the sibling's.
local priorInput = InputHandler
local priorShowHide = ShowHideHandler

-- Per-item duration suffix. Empty string for items that don't carry one
-- (lump gold, cities, third-party, vote, allow embassy in BNW where it's
-- permanent), so the caller can append unconditionally.
local function turnsSuffix(duration)
    if duration == nil or duration <= 0 then
        return ""
    end
    return ", " .. Locale.ConvertTextKey("TXT_KEY_DIPLO_TURNS", duration)
end

-- Boolean diplo items share a label-key shape; map item type to its key.
local BOOLEAN_KEYS = {
    [TradeableItems.TRADE_ITEM_ALLOW_EMBASSY] = "TXT_KEY_DIPLO_ALLOW_EMBASSY",
    [TradeableItems.TRADE_ITEM_OPEN_BORDERS] = "TXT_KEY_DIPLO_OPEN_BORDERS",
    [TradeableItems.TRADE_ITEM_DEFENSIVE_PACT] = "TXT_KEY_DIPLO_DEFENSIVE_PACT",
    [TradeableItems.TRADE_ITEM_RESEARCH_AGREEMENT] = "TXT_KEY_DIPLO_RESEARCH_AGREEMENT",
    [TradeableItems.TRADE_ITEM_TRADE_AGREEMENT] = "TXT_KEY_DIPLO_TRADE_AGREEMENT",
    [TradeableItems.TRADE_ITEM_DECLARATION_OF_FRIENDSHIP] = "TXT_KEY_DIPLO_DECLARATION_OF_FRIENDSHIP",
}

-- Resolve a third-party item's target team to a player name. Mirrors
-- DisplayOtherPlayerItem in TradeLogic.
local function thirdPartyName(teamId)
    for i = 0, (GameDefines.MAX_CIV_PLAYERS or 64) - 1 do
        local pl = Players[i]
        if pl and pl:IsEverAlive() and pl:GetTeam() == teamId then
            return pl:GetName()
        end
    end
    return "?"
end

-- One-line description of a single deal item. Returns nil for unrecognized
-- types so the caller can drop them. Mirrors the readOnly label shapes
-- TradeLogicAccess.offeringItem builds, with duration appended for the
-- item types that carry one (per-item, since durations within one deal can
-- differ -- gold-per-turn 30 turns alongside a 50-turn open borders, etc).
local function describeDealItem(itemType, data1, data2, data3, flag1, duration)
    if itemType == TradeableItems.TRADE_ITEM_PEACE_TREATY then
        -- TXT_KEY_DIPLO_PEACE_TREATY already embeds the turn count.
        return Locale.ConvertTextKey("TXT_KEY_DIPLO_PEACE_TREATY", duration or 0)
    end
    if itemType == TradeableItems.TRADE_ITEM_GOLD then
        return Locale.ConvertTextKey("TXT_KEY_DIPLO_GOLD") .. ", " .. tostring(data1 or 0)
    end
    if itemType == TradeableItems.TRADE_ITEM_GOLD_PER_TURN then
        return Locale.ConvertTextKey("TXT_KEY_DIPLO_GOLD_PER_TURN")
            .. ", "
            .. tostring(data1 or 0)
            .. turnsSuffix(duration)
    end
    if itemType == TradeableItems.TRADE_ITEM_RESOURCES then
        local resInfo = GameInfo.Resources[data1]
        local resName = resInfo and Locale.ConvertTextKey(resInfo.Description) or "?"
        local isStrategic = resInfo and resInfo.ResourceUsage == 1
        if isStrategic then
            return Text.format("TXT_KEY_CIVVACCESS_TRADE_STRATEGIC_OFFERING", resName, tostring(data2 or 0))
                .. turnsSuffix(duration)
        end
        return resName .. turnsSuffix(duration)
    end
    if itemType == TradeableItems.TRADE_ITEM_CITIES then
        local plot = Map.GetPlot(data1, data2)
        local city = plot and plot:GetPlotCity()
        if city ~= nil then
            return Text.format(
                "TXT_KEY_CIVVACCESS_TRADE_CITY_OFFERING",
                city:GetName(),
                tostring(city:GetPopulation())
            )
        end
        return Locale.ConvertTextKey("TXT_KEY_RAZED_CITY")
    end
    if
        itemType == TradeableItems.TRADE_ITEM_THIRD_PARTY_PEACE
        or itemType == TradeableItems.TRADE_ITEM_THIRD_PARTY_WAR
    then
        local key = (itemType == TradeableItems.TRADE_ITEM_THIRD_PARTY_PEACE)
                and "TXT_KEY_CIVVACCESS_TRADE_MAKE_PEACE_WITH"
            or "TXT_KEY_CIVVACCESS_TRADE_DECLARE_WAR_ON"
        return Text.format(key, thirdPartyName(data1))
    end
    if itemType == TradeableItems.TRADE_ITEM_VOTE_COMMITMENT then
        local pLeague = (Game and Game.GetNumActiveLeagues and Game.GetNumActiveLeagues() > 0)
                and Game.GetActiveLeague()
            or nil
        local iVoteIndex = (type(GetLeagueVoteIndexFromData) == "function")
                and GetLeagueVoteIndexFromData(data1, data2, flag1)
            or nil
        local tVote = iVoteIndex and g_LeagueVoteList and g_LeagueVoteList[iVoteIndex]
        if pLeague ~= nil and tVote ~= nil and type(GetVoteText) == "function" then
            local proposal = GetVoteText(pLeague, iVoteIndex, flag1, data3)
            local choice = pLeague:GetTextForChoice(tVote.VoteDecision, tVote.VoteChoice)
            return tostring(proposal) .. ", " .. tostring(choice)
        end
        return Locale.ConvertTextKey("TXT_KEY_CIVVACCESS_TRADE_VOTE_UNKNOWN")
    end
    local boolKey = BOOLEAN_KEYS[itemType]
    if boolKey ~= nil then
        return Locale.ConvertTextKey(boolKey) .. turnsSuffix(duration)
    end
    return nil
end

-- Compose the full label for one loaded deal: "<other civ>. we give: ...;
-- they give: ...". Skips an empty side. If both sides are empty (every
-- item dropped as unrecognized) falls back to just the civ name.
local function buildDealLabel(iPlayer, pScratch)
    local iOther = pScratch:GetOtherPlayer(iPlayer)
    local pOther = Players[iOther]
    local otherName = (pOther and pOther:GetName()) or "?"

    local weGive, theyGive = {}, {}
    pScratch:ResetIterator()
    -- 8-tuple matches engine: itemType, duration, finalTurn, data1, data2,
    -- data3, flag1, fromPlayer. finalTurn isn't surfaced here; per-item
    -- duration is the relevant time field for review.
    local itemType, duration, _, data1, data2, data3, flag1, fromPlayer = pScratch:GetNextItem()
    while itemType ~= nil do
        local desc = describeDealItem(itemType, data1, data2, data3, flag1, duration)
        if desc ~= nil then
            if fromPlayer == iPlayer then
                weGive[#weGive + 1] = desc
            else
                theyGive[#theyGive + 1] = desc
            end
        end
        itemType, duration, _, data1, data2, data3, flag1, fromPlayer = pScratch:GetNextItem()
    end

    local parts = { otherName }
    if #weGive > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_DEAL_WE_GIVE", table.concat(weGive, "; "))
    end
    if #theyGive > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_DEAL_THEY_GIVE", table.concat(theyGive, "; "))
    end
    return table.concat(parts, ". ")
end

local function buildDealItems(iPlayer, isCurrent, count)
    local items = {}
    for i = 0, count - 1 do
        if isCurrent then
            UI.LoadCurrentDeal(iPlayer, i)
        else
            UI.LoadHistoricDeal(iPlayer, i)
        end
        local label = buildDealLabel(iPlayer, UI.GetScratchDeal())
        items[#items + 1] = BaseMenuItems.Text({ labelText = label })
    end
    return items
end

local function buildItems()
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

    if nCurrent == 0 and nHistoric == 0 then
        items[#items + 1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_CIVVACCESS_DIPLO_NO_DEALS"),
        })
    end

    -- buildDealItems left the scratch deal holding the last iterated deal.
    -- Clear so it doesn't leak loaded state into other consumers reading
    -- UI.GetScratchDeal later.
    UI.GetScratchDeal():ClearItems()

    return items
end

BaseMenu.install(ContextPtr, {
    name = "DiploCurrentDeals",
    displayName = Text.key("TXT_KEY_DO_CURRENT_DEALS"),
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    onShow = function(h)
        h.setItems(buildItems())
    end,
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
    items = {},
})
