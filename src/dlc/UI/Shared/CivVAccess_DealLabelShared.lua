-- Read-only deal rendering, shared by every screen that lists deals a player
-- is party to without composing or modifying an offer: the DiploOverview
-- Deals tab (CivVAccess_DiploCurrentDealsAccess) and the Espionage diplomat
-- "view trade deals" panel (CivVAccess_EspionageOverviewVP). Each deal renders
-- as one line inlining its full contents (other civ, what each side gives)
-- with per-item duration where the item carries one. There is no drill past
-- the deal and no scratch-deal mutation outside the caller's build pass -- the
-- trade-screen drawer pattern only earns its keep when the user is composing.
--
-- Depends on the TradeLogic include for the league-vote globals
-- (g_LeagueVoteList, GetVoteText, GetLeagueVoteIndexFromData); every consumer
-- Context already includes TradeLogic, so this module names them at call time.

DealLabel = {}

-- Per-item duration suffix. Empty string for items that don't carry one, so
-- the caller can append unconditionally.
--
-- Current deals report turns remaining: finalTurn is the engine's absolute
-- expiry turn, stamped on deal activation as duration + game turn, so
-- remaining is finalTurn minus the current turn. Items with no end date
-- (lump gold, cities, third-party, vote, permanent BNW embassy) keep the
-- engine's finalTurn == -1 sentinel and get no suffix -- the same condition
-- that drives the feature also drops the never-expiring items. Historic
-- deals are already over, so remaining is meaningless; they keep reporting
-- the duration the item ran for.
local function turnsSuffix(isHistoric, duration, finalTurn)
    if isHistoric then
        if duration == nil or duration <= 0 then
            return ""
        end
        return ", " .. Text.format("TXT_KEY_DIPLO_TURNS", duration)
    end
    if finalTurn == nil or finalTurn <= 0 then
        return ""
    end
    local remaining = finalTurn - Game.GetGameTurn()
    if remaining < 1 then
        return ""
    end
    return ", " .. Text.formatPlural("TXT_KEY_CIVVACCESS_DIPLO_TURNS_LEFT", remaining, remaining)
end

-- Boolean diplo items share a label-key shape; map item type to its key.
local BOOLEAN_KEYS = {
    [TradeableItems.TRADE_ITEM_ALLOW_EMBASSY] = "TXT_KEY_DIPLO_ALLOW_EMBASSY",
    [TradeableItems.TRADE_ITEM_OPEN_BORDERS] = "TXT_KEY_DIPLO_OPEN_BORDERS",
    [TradeableItems.TRADE_ITEM_DEFENSIVE_PACT] = "TXT_KEY_DIPLO_DEF_PACT",
    [TradeableItems.TRADE_ITEM_RESEARCH_AGREEMENT] = "TXT_KEY_DIPLO_RESCH_AGREEMENT",
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
local function describeDealItem(itemType, data1, data2, data3, flag1, duration, finalTurn, isHistoric)
    if itemType == TradeableItems.TRADE_ITEM_PEACE_TREATY then
        -- Historic: TXT_KEY_DIPLO_PEACE_TREATY embeds the turn count the
        -- treaty ran for. Current: a bare label plus the turns-left clause,
        -- since the count-embedding key can't express turns remaining.
        if isHistoric then
            return Text.format("TXT_KEY_DIPLO_PEACE_TREATY", duration or 0)
        end
        return Text.key("TXT_KEY_CIVVACCESS_DIPLO_PEACE_TREATY") .. turnsSuffix(false, duration, finalTurn)
    end
    if itemType == TradeableItems.TRADE_ITEM_GOLD then
        return Text.format("TXT_KEY_CIVVACCESS_DIPLO_GOLD_AMOUNT", Text.key("TXT_KEY_DIPLO_GOLD"), data1 or 0)
    end
    if itemType == TradeableItems.TRADE_ITEM_GOLD_PER_TURN then
        local base =
            Text.format("TXT_KEY_CIVVACCESS_DIPLO_GOLD_AMOUNT", Text.key("TXT_KEY_DIPLO_GOLD_PER_TURN"), data1 or 0)
        return base .. turnsSuffix(isHistoric, duration, finalTurn)
    end
    if itemType == TradeableItems.TRADE_ITEM_RESOURCES then
        local resInfo = GameInfo.Resources[data1]
        local resName = resInfo and Text.key(resInfo.Description) or "?"
        local isStrategic = resInfo and resInfo.ResourceUsage == 1
        if isStrategic then
            return Text.format("TXT_KEY_CIVVACCESS_TRADE_STRATEGIC_OFFERING", resName, tostring(data2 or 0))
                .. turnsSuffix(isHistoric, duration, finalTurn)
        end
        return resName .. turnsSuffix(isHistoric, duration, finalTurn)
    end
    if itemType == TradeableItems.TRADE_ITEM_CITIES then
        local plot = Map.GetPlot(data1, data2)
        local city = plot and plot:GetPlotCity()
        if city ~= nil then
            return Text.format("TXT_KEY_CIVVACCESS_TRADE_CITY_OFFERING", city:GetName(), tostring(city:GetPopulation()))
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
        return Text.key(boolKey) .. turnsSuffix(isHistoric, duration, finalTurn)
    end
    return nil
end

-- Compose the full label and the Civilopedia search string for one loaded
-- deal. Label: "<other civ>. we give: ...; they give: ...". Skips an empty
-- side; if both sides are empty (every item dropped as unrecognized) falls
-- back to just the civ name. pediaName routes Ctrl+I to the other-civ
-- leader article (nil when the deal's other party is unresolvable).
--
-- iPlayer is the perspective player: items they contribute read as "we
-- give", the counterparty's as "they give". The Espionage diplomat view
-- passes the spied civ as iPlayer so the deal reads from that civ's seat.
function DealLabel.buildDealLabel(iPlayer, pScratch, isHistoric)
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
    -- data3, flag1, fromPlayer. Current deals report turns remaining off
    -- finalTurn (the absolute expiry turn); historic deals report duration.
    local itemType, duration, finalTurn, data1, data2, data3, flag1, fromPlayer = pScratch:GetNextItem()
    while itemType ~= nil do
        local desc = describeDealItem(itemType, data1, data2, data3, flag1, duration, finalTurn, isHistoric)
        if desc ~= nil then
            if fromPlayer == iPlayer then
                weGive[#weGive + 1] = desc
            else
                theyGive[#theyGive + 1] = desc
            end
        end
        itemType, duration, finalTurn, data1, data2, data3, flag1, fromPlayer = pScratch:GetNextItem()
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

return DealLabel
