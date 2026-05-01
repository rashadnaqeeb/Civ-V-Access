-- DiploRelationships accessibility. The Relations tab of DiploOverview;
-- lists major civs the active player has met (with diplomatic state,
-- score, and trade-availability strip) and met city-states (with trait,
-- personality, ally, resources). Activation opens AI trade / PvP trade
-- for majors, CityStateDiploPopup for minors.
--
-- Tab / Shift+Tab cycle to the sibling tabs. The sibling panels' base
-- switch functions (OnDeals / OnGlobal) are published on
-- civvaccess_shared by CivVAccess_DiploOverviewBridge; calling them
-- flips panel visibility, which fires ShowHide on both panels, popping
-- our BaseMenu and pushing the sibling's.
--
-- Esc falls through BaseMenu to the Context's priorInput (base
-- DiploRelationships has none) and bubbles up to DiploOverview, which
-- closes the popup.

include("CivVAccess_PopupBoot")
include("CivVAccess_DiploCommon")

-- Pending deal between us and a major civ. Mostly an MP signal (AI
-- proposals fire as popups in SP) but real when present, so it leads the
-- row.
local function pendingDealFragment(iUs, iOther)
    if UI.ProposedDealExists(iUs, iOther) then
        return Text.key("TXT_KEY_CIVVACCESS_DIPLO_PROPOSAL_OUTGOING")
    end
    if UI.ProposedDealExists(iOther, iUs) then
        return Text.key("TXT_KEY_CIVVACCESS_DIPLO_PROPOSAL_INCOMING")
    end
    return nil
end

-- Teammate's current research. Nil under NO_SCIENCE or when no research
-- is active, mirroring base DiploList.lua:341-348 which leaves DiploState
-- empty in those cases.
local function teammateResearchFragment(pOther)
    if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_SCIENCE) then
        return nil
    end
    local currentTech = pOther:GetCurrentResearch()
    if currentTech == -1 or GameInfo.Technologies[currentTech] == nil then
        return nil
    end
    return Text.format("TXT_KEY_CIVVACCESS_DIPLO_RESEARCHING", Text.key(GameInfo.Technologies[currentTech].Description))
end

-- Per-civ score breakdown. Same field set DiploList's score tooltip
-- surfaces (DiploList.lua:411-426), gated by the same NO_SCIENCE /
-- NO_POLICIES / NO_RELIGION game options.
local function scoreBreakdownFragments(pOther)
    local out = {}
    out[#out + 1] = Text.format("TXT_KEY_DIPLO_MY_SCORE_CITIES", pOther:GetScoreFromCities())
    out[#out + 1] = Text.format("TXT_KEY_DIPLO_MY_SCORE_POPULATION", pOther:GetScoreFromPopulation())
    out[#out + 1] = Text.format("TXT_KEY_DIPLO_MY_SCORE_LAND", pOther:GetScoreFromLand())
    out[#out + 1] = Text.format("TXT_KEY_DIPLO_MY_SCORE_WONDERS", pOther:GetScoreFromWonders())
    if not Game.IsOption(GameOptionTypes.GAMEOPTION_NO_SCIENCE) then
        out[#out + 1] = Text.format("TXT_KEY_DIPLO_MY_SCORE_TECH", pOther:GetScoreFromTechs())
        out[#out + 1] = Text.format("TXT_KEY_DIPLO_MY_SCORE_FUTURE_TECH", pOther:GetScoreFromFutureTech())
    end
    if not Game.IsOption(GameOptionTypes.GAMEOPTION_NO_POLICIES) then
        out[#out + 1] = Text.format("TXT_KEY_DIPLO_MY_SCORE_POLICIES", pOther:GetScoreFromPolicies())
    end
    out[#out + 1] = Text.format("TXT_KEY_DIPLO_MY_SCORE_GREAT_WORKS", pOther:GetScoreFromGreatWorks())
    if not Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION) then
        out[#out + 1] = Text.format("TXT_KEY_DIPLO_MY_SCORE_RELIGION", pOther:GetScoreFromReligion())
    end
    return out
end

-- State for a major civ. Same-team short-circuits to the teammate's
-- research, since war / denounce / approach don't apply between
-- teammates. Otherwise mirrors base DiploRelationships.InitMajorCivList's
-- war/denouncing/liberated branch, then falls through to the AI approach
-- guess -- which the base code computes but assigns to a never-displayed
-- `statusString` local, so the sighted UI shows nothing for the common
-- case. We speak it.
local function majorState(iUs, pUsTeam, iOther, pOther)
    if pOther:GetTeam() == Players[iUs]:GetTeam() then
        return teammateResearchFragment(pOther)
    end
    if pUsTeam:IsAtWar(pOther:GetTeam()) then
        return Text.key("TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_WAR")
    end
    if pOther:IsDenouncingPlayer(iUs) then
        return Text.key("TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_DENOUNCING")
    end
    if pOther:WasResurrectedThisTurnBy(iUs) then
        return Text.key("TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_LIBERATED")
    end
    local approach = Players[iUs]:GetApproachTowardsUsGuess(iOther)
    local key
    if approach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_WAR then
        key = "TXT_KEY_WAR_CAPS"
    elseif approach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_HOSTILE then
        key = "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_HOSTILE"
    elseif approach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_GUARDED then
        key = "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_GUARDED"
    elseif approach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_AFRAID then
        key = "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_AFRAID"
    elseif approach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_FRIENDLY then
        key = "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_FRIENDLY"
    elseif approach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_NEUTRAL then
        key = "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_NEUTRAL"
    end
    return key and Text.key(key) or nil
end

-- Embassy / open borders / DP / RA strings for an established
-- relationship. Empty list when no established relationships exist.
local function relationshipStrings(iUs, iOther)
    local pUsTeam = Teams[Players[iUs]:GetTeam()]
    local pOtherTeam = Teams[Players[iOther]:GetTeam()]
    local out = {}

    local embassyOurs = pUsTeam:HasEmbassyAtTeam(Players[iOther]:GetTeam())
    local embassyTheirs = pOtherTeam:HasEmbassyAtTeam(Players[iUs]:GetTeam())
    if embassyOurs and embassyTheirs then
        out[#out + 1] = Text.key("TXT_KEY_DIPLO_RELATION_EMBASSY_SHARED")
    elseif embassyOurs then
        out[#out + 1] = Text.key("TXT_KEY_DIPLO_RELATION_EMBASSY_YOUR")
    elseif embassyTheirs then
        out[#out + 1] = Text.key("TXT_KEY_DIPLO_RELATION_EMBASSY_THEIR")
    end

    local obOurs = pOtherTeam:IsAllowsOpenBordersToTeam(Players[iUs]:GetTeam())
    local obTheirs = pUsTeam:IsAllowsOpenBordersToTeam(Players[iOther]:GetTeam())
    if obOurs and obTheirs then
        out[#out + 1] = Text.key("TXT_KEY_DIPLO_RELATION_OPEN_BORDERS_SHARED")
    elseif obOurs then
        out[#out + 1] = Text.key("TXT_KEY_DIPLO_RELATION_OPEN_BORDERS_YOUR")
    elseif obTheirs then
        out[#out + 1] = Text.key("TXT_KEY_DIPLO_RELATION_OPEN_BORDERS_THEIR")
    end

    if pUsTeam:IsDefensivePact(Players[iOther]:GetTeam()) then
        out[#out + 1] = Text.key("TXT_KEY_DIPLO_DEF_PACT")
    end
    if pUsTeam:IsHasResearchAgreement(Players[iOther]:GetTeam()) then
        out[#out + 1] = Text.key("TXT_KEY_DIPLO_RESCH_AGREEMENT")
    end
    return out
end

-- Tradeable resources from iOther to iUs. Returns strategic-list and
-- luxury-list, each nil when the bucket is empty.
local function tradeableResources(iUs, iOther)
    local g_Deal = UI.GetScratchDeal()
    local strategic, luxury = {}, {}
    for row in GameInfo.Resources() do
        local rid = row.ID
        if g_Deal:IsPossibleToTradeItem(iOther, iUs, TradeableItems.TRADE_ITEM_RESOURCES, rid, 1) then
            local count = Players[iOther]:GetNumResourceAvailable(rid, false)
            local name = Text.key(row.Description)
            local entry = Text.format("TXT_KEY_CIVVACCESS_DIPLO_RES_COUNT", name, tostring(count))
            if row.ResourceClassType == "RESOURCECLASS_LUXURY" then
                luxury[#luxury + 1] = entry
            else
                strategic[#strategic + 1] = entry
            end
        end
    end
    local s, l = nil, nil
    if #strategic > 0 then
        s = Text.format("TXT_KEY_CIVVACCESS_DIPLO_STRATEGIC_LIST", table.concat(strategic, ", "))
    end
    if #luxury > 0 then
        l = Text.format("TXT_KEY_CIVVACCESS_DIPLO_LUXURY_LIST", table.concat(luxury, ", "))
    end
    return s, l
end

-- Trade-availability fragment for a major civ: their gold, their GPT,
-- trade-agreement legality, and established relationships + tradeable
-- resources. Mirrors base PopulateTrade's category set.
local function tradeFragments(iUs, iOther)
    local g_Deal = UI.GetScratchDeal()
    local fragments = {}

    local gold = g_Deal:GetGoldAvailable(iOther, -1) or 0
    fragments[#fragments + 1] = Text.format("TXT_KEY_CIVVACCESS_DIPLO_GOLD_VAL", tostring(gold))

    local gpt = Players[iOther]:CalculateGoldRate() or 0
    fragments[#fragments + 1] = Text.format("TXT_KEY_CIVVACCESS_DIPLO_GPT_VAL", tostring(gpt))

    for _, s in ipairs(relationshipStrings(iUs, iOther)) do
        fragments[#fragments + 1] = s
    end

    if g_Deal:IsPossibleToTradeItem(iOther, iUs, TradeableItems.TRADE_ITEM_TRADE_AGREEMENT, Game.GetDealDuration()) then
        fragments[#fragments + 1] = Text.key("TXT_KEY_DIPLO_TRADE_AGREEMENT")
    end

    local strategic, luxury = tradeableResources(iUs, iOther)
    if strategic then
        fragments[#fragments + 1] = strategic
    end
    if luxury then
        fragments[#fragments + 1] = luxury
    end

    return fragments
end

-- Row order: pending-deal first (attention-grabbing); name + team;
-- diplomatic state (or teammate research, when same team); trade
-- fragments (skipped for at-war and same-team); score and breakdown last
-- as a single tail unit so the user can stop attending after the
-- headline score if they don't need the breakdown.
local function majorCivItem(iUs, pUs, pUsTeam, iOther)
    local pOther = Players[iOther]
    local pOtherTeam = Teams[pOther:GetTeam()]
    local atWar = pUsTeam:IsAtWar(pOther:GetTeam())
    local sameTeam = pOther:GetTeam() == pUs:GetTeam()

    local civName = Text.key(GameInfo.Civilizations[pOther:GetCivilizationType()].ShortDescription)
    local nameLine = Text.format("TXT_KEY_CIVVACCESS_DIPLO_LEADER_OF_CIV", pOther:GetName(), civName)
    if pOtherTeam:GetNumMembers() > 1 then
        nameLine = nameLine .. ", " .. Text.format("TXT_KEY_CIVVACCESS_DIPLO_TEAM", pOtherTeam:GetID() + 1)
    end

    local parts = {}
    parts[#parts + 1] = pendingDealFragment(iUs, iOther)
    parts[#parts + 1] = nameLine
    parts[#parts + 1] = majorState(iUs, pUsTeam, iOther, pOther)

    if not atWar and not sameTeam then
        for _, f in ipairs(tradeFragments(iUs, iOther)) do
            parts[#parts + 1] = f
        end
    end

    parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_DIPLO_SCORE_VAL", pOther:GetScore())
    for _, f in ipairs(scoreBreakdownFragments(pOther)) do
        parts[#parts + 1] = f
    end

    local capturedOther = iOther
    return BaseMenuItems.Choice({
        labelText = Text.joinNonEmpty(parts),
        pediaName = Text.key(GameInfo.Leaders[pOther:GetLeaderType()].Description),
        -- Base LeaderSelected guards on the active player's turn being
        -- live and the network layer not processing; mirror that to
        -- avoid starting a trade the engine would immediately reject.
        activate = function()
            if not Players[Game.GetActivePlayer()]:IsTurnActive() or Game.IsProcessingMessages() then
                return
            end
            DiploCommon.openTradeWith(capturedOther)
        end,
    })
end

-- City-state personality: friendly / neutral / hostile / irrational.
local function minorPersonality(pOther)
    local p = pOther:GetPersonality()
    if p == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_FRIENDLY then
        return Text.key("TXT_KEY_CITY_STATE_PERSONALITY_FRIENDLY")
    elseif p == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_NEUTRAL then
        return Text.key("TXT_KEY_CITY_STATE_PERSONALITY_NEUTRAL")
    elseif p == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_HOSTILE then
        return Text.key("TXT_KEY_CITY_STATE_PERSONALITY_HOSTILE")
    elseif p == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_IRRATIONAL then
        return Text.key("TXT_KEY_CITY_STATE_PERSONALITY_IRRATIONAL")
    end
    return nil
end

-- Nearby-resources list for a city-state. Mirrors base
-- PopulateCityStateInfo's scan: range 5, owned-by-CS or close-unowned.
-- Omits bonus resources (base does the same).
local function minorNearbyResources(iOther, pOther)
    local pCapital = pOther:GetCapitalCity()
    if pCapital == nil then
        return nil
    end
    local activeTeam = Game.GetActiveTeam()
    local cx, cy = pCapital:GetX(), pCapital:GetY()
    local names = {}
    local seen = {}
    local iRange, iCloseRange = 5, 2
    for dx = -iRange, iRange do
        for dy = -iRange, iRange do
            local plot = Map.GetPlotXY(cx, cy, dx, dy)
            if plot ~= nil then
                local owner = plot:GetOwner()
                if owner == iOther or owner == -1 then
                    local dist = Map.PlotDistance(cx, cy, plot:GetX(), plot:GetY())
                    if dist <= iRange and (dist <= iCloseRange or owner == iOther) then
                        local rid = plot:GetResourceType(activeTeam)
                        if
                            rid ~= -1
                            and Game.GetResourceUsageType(rid) ~= ResourceUsageTypes.RESOURCEUSAGE_BONUS
                            and not seen[rid]
                        then
                            seen[rid] = true
                            local name = Text.key(GameInfo.Resources[rid].Description)
                            local qty = plot:GetNumResource()
                            names[#names + 1] = Text.format("TXT_KEY_CIVVACCESS_DIPLO_RES_COUNT", name, tostring(qty))
                        end
                    end
                end
            end
        end
    end
    if #names == 0 then
        return nil
    end
    return Text.format("TXT_KEY_CIVVACCESS_DIPLO_NEARBY_LIST", table.concat(names, ", "))
end

-- City-state status (Allies, Friends, Neutral, hostile / war variants,
-- etc.) via the engine helper. "War" subsumes the at-war flag we used
-- to add separately.
local function minorStatusFragment(iUs, iOther)
    local raw = GetCityStateStatusText(iUs, iOther)
    if raw == nil or raw == "" then
        return nil
    end
    return raw
end

-- Influence value, per-turn rate, and anchor. Per-turn drops when zero;
-- anchor drops when equal to the current value. Signed format
-- throughout because hostile relationships report negative influence
-- and decay rates.
local function minorInfluenceFragments(iUs, pOther)
    local out = {}
    local inf = pOther:GetMinorCivFriendshipWithMajor(iUs)
    out[#out + 1] = Text.format("TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE", string.format("%+d", inf))
    local perTurn = math.floor(pOther:GetFriendshipChangePerTurnTimes100(iUs) / 100)
    if perTurn ~= 0 then
        out[#out + 1] = Text.format("TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_PER_TURN", string.format("%+d", perTurn))
    end
    local anchor = pOther:GetMinorCivFriendshipAnchorWithMajor(iUs)
    if anchor ~= inf then
        out[#out + 1] = Text.format("TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_ANCHOR", string.format("%+d", anchor))
    end
    return out
end

-- Friendship bonuses by category. Engine getters return 0 outside
-- Friends / Allies and for traits that don't apply to this CS, so a
-- non-allied CS adds nothing and an allied CS adds only what it
-- actually grants. Mirrors GetCityStateStatusToolTip's bFullInfo branch
-- (CityStateStatusHelper.lua:308-357).
local function minorBonusFragments(iUs, pOther)
    local out = {}
    local culture = pOther:GetMinorCivCurrentCultureBonus(iUs)
    if culture ~= 0 then
        out[#out + 1] = Text.format("TXT_KEY_CIVVACCESS_DIPLO_BONUS_CULTURE", culture)
    end
    local foodCap = math.floor(pOther:GetCurrentCapitalFoodBonus(iUs) / 100)
    if foodCap ~= 0 then
        out[#out + 1] = Text.format("TXT_KEY_CIVVACCESS_DIPLO_BONUS_FOOD_CAPITAL", foodCap)
    end
    local foodOther = math.floor(pOther:GetCurrentOtherCityFoodBonus(iUs) / 100)
    if foodOther ~= 0 then
        out[#out + 1] = Text.format("TXT_KEY_CIVVACCESS_DIPLO_BONUS_FOOD_OTHER", foodOther)
    end
    local science = math.floor(pOther:GetCurrentScienceFriendshipBonusTimes100(iUs) / 100)
    if science ~= 0 then
        out[#out + 1] = Text.format("TXT_KEY_CIVVACCESS_DIPLO_BONUS_SCIENCE", science)
    end
    local happiness = pOther:GetMinorCivCurrentHappinessBonus(iUs)
    if happiness ~= 0 then
        out[#out + 1] = Text.format("TXT_KEY_CIVVACCESS_DIPLO_BONUS_HAPPINESS", happiness)
    end
    local faith = pOther:GetMinorCivCurrentFaithBonus(iUs)
    if faith ~= 0 then
        out[#out + 1] = Text.format("TXT_KEY_CIVVACCESS_DIPLO_BONUS_FAITH", faith)
    end
    local spawn = pOther:GetCurrentSpawnEstimate(iUs)
    if spawn ~= 0 then
        out[#out + 1] = Text.formatPlural("TXT_KEY_CIVVACCESS_DIPLO_BONUS_MILITARY", spawn, spawn)
    end
    return out
end

-- Resources the CS is currently exporting to us (i.e. providing while
-- Friends / Allies). Bonus-class filter matches base
-- CityStateStatusHelper.lua:364-373. Distinct from minorNearbyResources
-- (unowned resources near the CS regardless of trade state).
local function minorExportsFragment(pOther)
    local items = {}
    for row in GameInfo.Resources() do
        local rid = row.ID
        local count = pOther:GetResourceExport(rid)
        if count > 0 and Game.GetResourceUsageType(rid) ~= ResourceUsageTypes.RESOURCEUSAGE_BONUS then
            local name = Text.key(row.Description)
            items[#items + 1] = Text.format("TXT_KEY_CIVVACCESS_DIPLO_RES_COUNT", name, count)
        end
    end
    if #items == 0 then
        return nil
    end
    return Text.format("TXT_KEY_CIVVACCESS_DIPLO_EXPORTS_LIST", table.concat(items, ", "))
end

local function minorOpenBordersFragment(iUs, pOther)
    if pOther:IsPlayerHasOpenBorders(iUs) then
        return Text.key("TXT_KEY_CIVVACCESS_DIPLO_OPEN_BORDERS")
    end
    return nil
end

-- "Ally of X" line for a CS allied to someone other than us. Skipped
-- when we're the ally (status text already says "Allies"), when there's
-- no ally, and when the ally is unmet (no useful name to speak).
local function minorOtherAllyFragment(iUs, pOther)
    local iAlly = pOther:GetAlly()
    if iAlly == nil or iAlly == -1 or iAlly == iUs then
        return nil
    end
    if not Teams[Players[iUs]:GetTeam()]:IsHasMet(Players[iAlly]:GetTeam()) then
        return nil
    end
    local civ = Text.key(Players[iAlly]:GetCivilizationShortDescriptionKey())
    return Text.format("TXT_KEY_CIVVACCESS_DIPLO_ALLY_OF", civ)
end

-- Active quests, threatening-barbarians, and proxy-war events as one
-- fragment. Reuses the engine's GetActiveQuestToolTip so BNW's full
-- quest set, per-quest turns-remaining, and the contest winning /
-- losing branches all come through localized. Replace [NEWLINE] with
-- ", " before SpeechPipeline filters the token away, so multi-quest
-- output reads as a flat list rather than collapsing into one run-on.
local function minorQuestsFragment(iUs, iOther, pOther)
    local hasQuests = pOther:GetMinorCivNumDisplayedQuestsForPlayer(iUs) > 0
    local hasBarbs = pOther:IsThreateningBarbariansEventActiveForPlayer(iUs)
    local hasProxy = pOther:IsProxyWarActiveForMajor(iUs)
    if not hasQuests and not hasBarbs and not hasProxy then
        return nil
    end
    local raw = GetActiveQuestToolTip(iUs, iOther)
    return (raw:gsub("%[NEWLINE%]", ", "))
end

-- Bullyable indicator. Engine's status text already says "Afraid" when
-- influence is below neutral threshold AND we can bully, so skip the
-- inline tag in that case to avoid saying it twice. Edge case is a
-- positive-relationship CS that is somehow bullyable; if never observed
-- the helper can be dropped.
local function minorBullyableFragment(iUs, pOther)
    if not pOther:CanMajorBullyGold(iUs) then
        return nil
    end
    if pOther:GetMinorCivFriendshipWithMajor(iUs) < GameDefines.FRIENDSHIP_THRESHOLD_NEUTRAL then
        return nil
    end
    return Text.key("TXT_KEY_CIVVACCESS_DIPLO_BULLYABLE")
end

local function minorCivItem(iUs, pUsTeam, iOther)
    local pOther = Players[iOther]
    local civInfo = GameInfo.MinorCivilizations[pOther:GetMinorCivType()]
    local atWar = pUsTeam:IsAtWar(pOther:GetTeam())

    local parts = { Text.key(civInfo.Description) }

    parts[#parts + 1] = minorStatusFragment(iUs, iOther)

    for _, f in ipairs(minorInfluenceFragments(iUs, pOther)) do
        parts[#parts + 1] = f
    end
    for _, f in ipairs(minorBonusFragments(iUs, pOther)) do
        parts[#parts + 1] = f
    end

    parts[#parts + 1] = minorExportsFragment(pOther)
    parts[#parts + 1] = minorOpenBordersFragment(iUs, pOther)
    parts[#parts + 1] = minorOtherAllyFragment(iUs, pOther)

    -- Base hides quests when at war (DiploList.lua:627); mirror.
    if not atWar then
        parts[#parts + 1] = minorQuestsFragment(iUs, iOther, pOther)
    end

    parts[#parts + 1] = minorBullyableFragment(iUs, pOther)
    parts[#parts + 1] = GetCityStateTraitText(iOther)
    parts[#parts + 1] = minorPersonality(pOther)
    parts[#parts + 1] = minorNearbyResources(iOther, pOther)

    local capturedOther = iOther
    return BaseMenuItems.Choice({
        labelText = Text.joinNonEmpty(parts),
        pediaName = Text.key(civInfo.Description),
        -- F4 opens DiploOverview with Data1=1 -> InGameUtmost (62).
        -- CityStateDiplo queues at priority 27, far below, so it sits
        -- in the queue with ShowHide unfired until DiploOverview is
        -- dequeued. Close DiploOverview first so CityStateDiplo
        -- surfaces immediately. Mouse-corner open uses priority 26
        -- and wouldn't need this, but closing is harmless there too.
        activate = function()
            civvaccess_shared.DiploOverview.close()
            Events.SerialEventGameMessagePopup({
                Type = ButtonPopupTypes.BUTTONPOPUP_CITY_STATE_DIPLO,
                Data1 = capturedOther,
            })
        end,
    })
end

local function buildItems()
    local iUs = Game.GetActivePlayer()
    local pUs = Players[iUs]
    local pUsTeam = Teams[pUs:GetTeam()]

    local majors = {}
    for i = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        local pOther = Players[i]
        if i ~= iUs and pOther:IsAlive() and pUsTeam:IsHasMet(pOther:GetTeam()) then
            majors[#majors + 1] = majorCivItem(iUs, pUs, pUsTeam, i)
        end
    end

    local minors = {}
    for i = GameDefines.MAX_MAJOR_CIVS, GameDefines.MAX_CIV_PLAYERS - 1 do
        local pOther = Players[i]
        if pOther ~= nil and pOther:IsAlive() and pUsTeam:IsHasMet(pOther:GetTeam()) then
            minors[#minors + 1] = minorCivItem(iUs, pUsTeam, i)
        end
    end

    local groups = {}
    if #majors > 0 then
        groups[#groups + 1] = BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_CIVVACCESS_DIPLO_MAJORS_GROUP"),
            items = majors,
        })
    end
    if #minors > 0 then
        groups[#groups + 1] = BaseMenuItems.Group({
            labelText = Text.key("TXT_KEY_CIVVACCESS_DIPLO_MINORS_GROUP"),
            items = minors,
        })
    end
    if #groups == 0 then
        groups[1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_CIVVACCESS_DIPLO_NO_CIVS_MET"),
        })
    end
    return groups
end

BaseMenu.install(ContextPtr, DiploCommon.applyTabBindings({
    name = "DiploRelationships",
    displayName = Text.key("TXT_KEY_DO_YOUR_RELATIONS"),
    priorInput = InputHandler,
    priorShowHide = ShowHideHandler,
    shouldActivate = DiploCommon.shouldActivate,
    onShow = function(h)
        h.setItems(buildItems())
    end,
    items = {},
}, "showDeals", "showGlobal"))
