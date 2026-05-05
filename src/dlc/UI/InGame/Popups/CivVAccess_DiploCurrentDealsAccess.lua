-- DiploCurrentDeals accessibility. The Deals tab of DiploOverview; lists
-- active and historical deals the player is party to. Each deal
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

include("CivVAccess_PopupBoot")
include("CivVAccess_DiploCommon")

-- Tab / Shift+Tab both cycle to the Relations Context, which now hosts
-- a TabbedShell with Majors and Minors sub-tabs. Forward Tab lands on
-- Majors (the conceptual "next" after Deals); Shift+Tab lands on Minors
-- (the conceptual "previous"). The bridge stages the landing index on
-- civvaccess_shared.DiploOverview.relationsLanding and the shell's
-- onShow consumes it. See CivVAccess_DiploOverviewBridge for the
-- cross-Context mechanism; the sibling panel's visibility flip fires
-- ShowHide on both panels, which pops our BaseMenu and pushes the
-- sibling's.
local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local RELATIONS_TAB_MAJORS = 1
local RELATIONS_TAB_MINORS = 2

-- Per-item duration suffix. Empty string for items that don't carry one
-- (lump gold, cities, third-party, vote, allow embassy in BNW where it's
-- permanent), so the caller can append unconditionally.
local function turnsSuffix(duration)
    if duration == nil or duration <= 0 then
        return ""
    end
    return ", " .. Text.format("TXT_KEY_DIPLO_TURNS", duration)
end

-- Boolean diplo items share a label-key shape; map item type to its key.
local BOOLEAN_KEYS = {
    [TradeableItems.TRADE_ITEM_ALLOW_EMBASSY] = "TXT_KEY_DIPLO_ALLOW_EMBASSY",
    [TradeableItems.TRADE_ITEM_OPEN_BORDERS] = "TXT_KEY_DIPLO_OPEN_BORDERS",
    [TradeableItems.TRADE_ITEM_DEFENSIVE_PACT] = "TXT_KEY_DIPLO_DEF_PACT",
    [TradeableItems.TRADE_ITEM_RESEARCH_AGREEMENT] = "TXT_KEY_DIPLO_RESCH_AGREEMENT",
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
        return Text.format("TXT_KEY_DIPLO_PEACE_TREATY", duration or 0)
    end
    if itemType == TradeableItems.TRADE_ITEM_GOLD then
        return Text.format(
            "TXT_KEY_CIVVACCESS_DIPLO_GOLD_AMOUNT",
            Text.key("TXT_KEY_DIPLO_GOLD"),
            data1 or 0
        )
    end
    if itemType == TradeableItems.TRADE_ITEM_GOLD_PER_TURN then
        local base = Text.format(
            "TXT_KEY_CIVVACCESS_DIPLO_GOLD_AMOUNT",
            Text.key("TXT_KEY_DIPLO_GOLD_PER_TURN"),
            data1 or 0
        )
        return base .. turnsSuffix(duration)
    end
    if itemType == TradeableItems.TRADE_ITEM_RESOURCES then
        local resInfo = GameInfo.Resources[data1]
        local resName = resInfo and Text.key(resInfo.Description) or "?"
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
        return Text.key("TXT_KEY_RAZED_CITY")
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
        return Text.key("TXT_KEY_CIVVACCESS_TRADE_VOTE_UNKNOWN")
    end
    local boolKey = BOOLEAN_KEYS[itemType]
    if boolKey ~= nil then
        return Text.key(boolKey) .. turnsSuffix(duration)
    end
    return nil
end

-- Compose the full label and the Civilopedia search string for one loaded
-- deal. Label: "<other civ>. we give: ...; they give: ...". Skips an empty
-- side; if both sides are empty (every item dropped as unrecognized) falls
-- back to just the civ name. pediaName routes Ctrl+I to the other-civ
-- leader article (nil when the deal's other party is unresolvable).
local function buildDealLabel(iPlayer, pScratch, isHistoric)
    local iOther = pScratch:GetOtherPlayer(iPlayer)
    local pOther = Players[iOther]
    local otherName = (pOther and pOther:GetName()) or "?"
    local pediaName = nil
    if pOther ~= nil then
        local leader = GameInfo.Leaders[pOther:GetLeaderType()]
        if leader ~= nil then
            pediaName = Text.key(leader.Description)
        end
    end

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

    local weKey = isHistoric and "TXT_KEY_CIVVACCESS_DEAL_WE_GAVE" or "TXT_KEY_CIVVACCESS_DEAL_WE_GIVE"
    local theyKey = isHistoric and "TXT_KEY_CIVVACCESS_DEAL_THEY_GAVE" or "TXT_KEY_CIVVACCESS_DEAL_THEY_GIVE"
    local parts = { otherName }
    if #weGive > 0 then
        parts[#parts + 1] = Text.format(weKey, table.concat(weGive, "; "))
    end
    if #theyGive > 0 then
        parts[#parts + 1] = Text.format(theyKey, table.concat(theyGive, "; "))
    end
    return table.concat(parts, ". "), pediaName
end

local function buildDealItems(iPlayer, isCurrent, count)
    local items = {}
    for i = 0, count - 1 do
        if isCurrent then
            UI.LoadCurrentDeal(iPlayer, i)
        else
            UI.LoadHistoricDeal(iPlayer, i)
        end
        local label, pediaName = buildDealLabel(iPlayer, UI.GetScratchDeal(), not isCurrent)
        items[#items + 1] = BaseMenuItems.Text({
            labelText = label,
            pediaName = pediaName,
        })
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
            labelText = Text.key("TXT_KEY_CIVVACCESS_DIPLO_HISTORICAL_DEALS"),
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
    displayName = Text.key("TXT_KEY_CIVVACCESS_DIPLO_DEALS_TAB"),
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    shouldActivate = DiploCommon.shouldActivate,
    onShow = function(h)
        h.setItems(buildItems())
    end,
    items = {},
    onTab = function()
        civvaccess_shared.DiploOverview.showRelations(RELATIONS_TAB_MAJORS)
    end,
    onShiftTab = function()
        civvaccess_shared.DiploOverview.showRelations(RELATIONS_TAB_MINORS)
    end,
    onEscape = function()
        civvaccess_shared.DiploOverview.close()
        return true
    end,
    suppressReactivateOnHide = function()
        return civvaccess_shared.DiploOverview._switching == true
    end,
})
