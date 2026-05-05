-- DiploRelationships accessibility. The Relations tab of DiploOverview is
-- our seat for the F4 Diplomatic Overview's two-table view of met civs.
-- Visually the sighted screen renders Relations on its own panel and
-- Global Politics on a separate panel; the access mod folds Global into
-- the Majors table here so all data about a major civ is reachable from
-- one row.
--
--   Majors  BaseTable. One row per met major civ. Columns left to right:
--           Your relationship (stance + active treaties), Foreign
--           relations (their third-party state), Gold, Resources, Era,
--           Policies, Wonders, Score. Row label: leader-of-civ + team
--           suffix + pending-deal phrase only when one exists. Enter on
--           any data cell opens trade.
--
--   Minors  BaseTable. One row per met city-state. Columns left to right:
--           Relationship (bonuses currently flowing), Trait and
--           personality, Influence, Allied with, Quests, Nearby
--           resources. Row label: CS name + engine status text +
--           bullyable suffix when not implied by status. Enter on any
--           data cell opens BUTTONPOPUP_CITY_STATE_DIPLO.
--
-- Exports column is intentionally absent: Mercantile unique luxuries get
-- placed on the city plot via setResourceType (CvMinorCivAI.cpp:2427),
-- so the nearby-resources scan picks them up; for non-Mercantile CS,
-- exports is just nearby gated by Friends / Allies status, with no
-- distinct content.
--
-- Tab cycling within the shell flips between Majors and Minors without a
-- sighted-tab change (both tabs visually live on Relations). When the
-- shell would wrap forward off Minors or backward off Majors, the
-- onCycleEdge hook fires showDeals, which hides this Context and shows
-- the Deals Context. Coming back from Deals, the bridge stages
-- relationsLanding so the shell lands on the right tab (Majors when
-- arriving via forward Tab from Deals, Minors when arriving via
-- Shift+Tab) -- onShow consumes the flag.
--
-- Sighted Global Politics tab is no longer surfaced in our cycle; its
-- data folds into Majors columns. CivVAccess_DiploGlobalRelationshipsAccess
-- is reduced to a minimal bridge that routes Tab back to Relations if a
-- sighted user navigates the underlying panel.

include("CivVAccess_PopupBoot")
include("CivVAccess_TabbedShell")
include("CivVAccess_BaseTableCore")
include("CivVAccess_DiploCommon")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

-- ===== Shared helpers =================================================

local function metMajors(iUs, pUsTeam)
    local out = {}
    for i = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        local p = Players[i]
        if i ~= iUs and p:IsAlive() and pUsTeam:IsHasMet(p:GetTeam()) then
            out[#out + 1] = i
        end
    end
    return out
end

local function metMinors(iUs, pUsTeam)
    local out = {}
    for i = GameDefines.MAX_MAJOR_CIVS, GameDefines.MAX_CIV_PLAYERS - 1 do
        local p = Players[i]
        if p ~= nil and p:IsAlive() and pUsTeam:IsHasMet(p:GetTeam()) then
            out[#out + 1] = i
        end
    end
    return out
end

local function noneCell()
    return Text.key("TXT_KEY_CIVVACCESS_DIPLO_NONE")
end

-- ===== Major civ helpers ==============================================

-- Pending-deal fragment. Outgoing dominates incoming for the player's
-- attention; the engine surfaces both via UI.ProposedDealExists.
local function pendingDealPhrase(iUs, iOther)
    if UI.ProposedDealExists(iUs, iOther) then
        return Text.key("TXT_KEY_CIVVACCESS_DIPLO_PROPOSAL_OUTGOING")
    end
    if UI.ProposedDealExists(iOther, iUs) then
        return Text.key("TXT_KEY_CIVVACCESS_DIPLO_PROPOSAL_INCOMING")
    end
    return nil
end

-- Teammate-research phrase. Same-team civs don't have war / denounce /
-- approach state with us, so the row's state slot reads as their current
-- research instead. Mirrors base DiploList.lua:341-348.
local function teammateResearch(pOther)
    if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_SCIENCE) then
        return nil
    end
    local tech = pOther:GetCurrentResearch()
    if tech == -1 or GameInfo.Technologies[tech] == nil then
        return nil
    end
    return Text.format("TXT_KEY_CIVVACCESS_DIPLO_RESEARCHING", Text.key(GameInfo.Technologies[tech].Description))
end

-- Stance phrase: war / they-denouncing / liberated / we-denounced /
-- backstabbed branch first; falls through to the AI's approach guess
-- which the base UI computes but never displays (statusString is
-- assigned and dropped). On a same-team civ the slot reads as their
-- current research.
local function stancePhrase(iUs, pUs, pUsTeam, iOther, pOther)
    if pOther:GetTeam() == pUs:GetTeam() then
        return teammateResearch(pOther)
    end
    if pUsTeam:IsAtWar(pOther:GetTeam()) then
        return Text.key("TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_WAR")
    end
    if pUs:IsDenouncedPlayer(iOther) then
        if pOther:IsFriendDenouncedUs(iUs) or pOther:IsFriendDeclaredWarOnUs(iUs) then
            return Text.key("TXT_KEY_DIPLO_YOU_HAVE_BACKSTABBED")
        end
        return Text.key("TXT_KEY_DIPLO_YOU_HAVE_DENOUNCED")
    end
    if pOther:IsDenouncingPlayer(iUs) then
        return Text.key("TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_DENOUNCING")
    end
    if pOther:WasResurrectedThisTurnBy(iUs) then
        return Text.key("TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_LIBERATED")
    end
    local approach = pUs:GetApproachTowardsUsGuess(iOther)
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

-- Row label: leader name (or nickname for human in MP, mirroring base) +
-- civ short name + team suffix when team has multiple members + pending-
-- deal phrase only when one exists. Stance lives in the Your-relationship
-- cell where the user navigates to read it together with active treaties.
local function majorRowLabel(iOther)
    local iUs = Game.GetActivePlayer()
    local pOther = Players[iOther]
    local pOtherTeam = Teams[pOther:GetTeam()]

    local civName = Text.key(GameInfo.Civilizations[pOther:GetCivilizationType()].ShortDescription)
    local nameLine
    if pOther:IsHuman() and pOther:GetNickName() ~= "" then
        nameLine = Text.format("TXT_KEY_CIVVACCESS_DIPLO_LEADER_OF_CIV", pOther:GetNickName(), civName)
    else
        nameLine = Text.format("TXT_KEY_CIVVACCESS_DIPLO_LEADER_OF_CIV", pOther:GetName(), civName)
    end

    local parts = { nameLine }
    if pOtherTeam:GetNumMembers() > 1 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_DIPLO_TEAM", pOtherTeam:GetID() + 1)
    end
    parts[#parts + 1] = pendingDealPhrase(iUs, iOther)
    return Text.joinNonEmpty(parts)
end

-- Active treaty fragments for the Your-relationship cell. Returns a list
-- (possibly empty) so the caller can prepend the stance word and join.
-- Mirrors today's relationshipStrings + the trade-agreement-available
-- branch from tradeFragments.
local function treatyFragments(iOther)
    local iUs = Game.GetActivePlayer()
    local pUs = Players[iUs]
    local pUsTeam = Teams[pUs:GetTeam()]
    local pOther = Players[iOther]
    local pOtherTeam = Teams[pOther:GetTeam()]
    local out = {}

    local embassyOurs = pUsTeam:HasEmbassyAtTeam(pOther:GetTeam())
    local embassyTheirs = pOtherTeam:HasEmbassyAtTeam(pUs:GetTeam())
    if embassyOurs and embassyTheirs then
        out[#out + 1] = Text.key("TXT_KEY_DIPLO_RELATION_EMBASSY_SHARED")
    elseif embassyOurs then
        out[#out + 1] = Text.key("TXT_KEY_DIPLO_RELATION_EMBASSY_YOUR")
    elseif embassyTheirs then
        out[#out + 1] = Text.key("TXT_KEY_DIPLO_RELATION_EMBASSY_THEIR")
    end

    local obOurs = pOtherTeam:IsAllowsOpenBordersToTeam(pUs:GetTeam())
    local obTheirs = pUsTeam:IsAllowsOpenBordersToTeam(pOther:GetTeam())
    if obOurs and obTheirs then
        out[#out + 1] = Text.key("TXT_KEY_DIPLO_RELATION_OPEN_BORDERS_SHARED")
    elseif obOurs then
        out[#out + 1] = Text.key("TXT_KEY_DIPLO_RELATION_OPEN_BORDERS_YOUR")
    elseif obTheirs then
        out[#out + 1] = Text.key("TXT_KEY_DIPLO_RELATION_OPEN_BORDERS_THEIR")
    end

    if pUsTeam:IsDefensivePact(pOther:GetTeam()) then
        out[#out + 1] = Text.key("TXT_KEY_DIPLO_DEF_PACT")
    end
    if pUsTeam:IsHasResearchAgreement(pOther:GetTeam()) then
        out[#out + 1] = Text.key("TXT_KEY_DIPLO_RESCH_AGREEMENT")
    end

    local g_Deal = UI.GetScratchDeal()
    if g_Deal:IsPossibleToTradeItem(iOther, iUs, TradeableItems.TRADE_ITEM_TRADE_AGREEMENT, Game.GetDealDuration()) then
        out[#out + 1] = Text.key("TXT_KEY_DIPLO_TRADE_AGREEMENT")
    end

    return out
end

-- Your-relationship cell: stance word first (war / denouncing / hostile /
-- guarded / friendly / etc.), then active treaties. Stance is non-nil
-- for every reachable branch except same-team-with-NO_SCIENCE; treaties
-- can be empty. Empty cell (no stance and no treaties) falls back to
-- "none".
local function yourRelationshipCell(iOther)
    local iUs = Game.GetActivePlayer()
    local pUs = Players[iUs]
    local pUsTeam = Teams[pUs:GetTeam()]
    local pOther = Players[iOther]

    local parts = { stancePhrase(iUs, pUs, pUsTeam, iOther, pOther) }
    for _, t in ipairs(treatyFragments(iOther)) do
        parts[#parts + 1] = t
    end
    local joined = Text.joinNonEmpty(parts)
    if joined == nil or joined == "" then
        return noneCell()
    end
    return joined
end

-- Numeric rank for sorting Your-relationship best-to-worst. Mirrors the
-- branch order in stancePhrase so a new stance added there should get a
-- rank here. Same-team is best (permanent ally); war is worst. Treaty
-- count rides as a sub-stance tiebreaker so within one stance, more
-- treaties sort higher; the engine caps treaties well under 10 so the
-- stance band stays intact.
local function yourRelationshipRank(iOther)
    local iUs = Game.GetActivePlayer()
    local pUs = Players[iUs]
    local pUsTeam = Teams[pUs:GetTeam()]
    local pOther = Players[iOther]
    local stance
    if pOther:GetTeam() == pUs:GetTeam() then
        stance = 100
    elseif pUsTeam:IsAtWar(pOther:GetTeam()) then
        stance = 0
    elseif pUs:IsDenouncedPlayer(iOther) then
        if pOther:IsFriendDenouncedUs(iUs) or pOther:IsFriendDeclaredWarOnUs(iUs) then
            stance = 5
        else
            stance = 10
        end
    elseif pOther:IsDenouncingPlayer(iUs) then
        stance = 20
    elseif pOther:WasResurrectedThisTurnBy(iUs) then
        stance = 80
    else
        local approach = pUs:GetApproachTowardsUsGuess(iOther)
        if approach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_WAR then
            stance = 0
        elseif approach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_HOSTILE then
            stance = 30
        elseif approach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_GUARDED then
            stance = 40
        elseif approach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_AFRAID then
            stance = 50
        elseif approach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_NEUTRAL then
            stance = 60
        elseif approach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_FRIENDLY then
            stance = 70
        else
            stance = 60
        end
    end
    return stance * 10 + #treatyFragments(iOther)
end

-- Render a third-party display name. Mirrors base DiploGlobalRelationships
-- thirdName branches: TXT_KEY_YOU for self, nickname for human, civ
-- short description for AI.
local function thirdPartyName(iThird, iUs)
    if iThird == iUs then
        return Text.key("TXT_KEY_YOU")
    end
    local p = Players[iThird]
    if p:IsHuman() then
        return p:GetNickName()
    end
    return Text.key(p:GetCivilizationShortDescription())
end

-- Foreign-relations cell: pOther's wars with other met majors, their
-- DoFs, their denouncements (with backstab variant), and CS alliances.
-- Distinct from Your-relationship -- this is what they have with
-- everyone besides us. Empty case: "none".
local function foreignRelationsCell(iOther)
    local iUs = Game.GetActivePlayer()
    local pUs = Players[iUs]
    local pUsTeam = Teams[pUs:GetTeam()]
    local pOther = Players[iOther]
    local pOtherTeam = Teams[pOther:GetTeam()]
    local out = {}

    -- Wars with other majors (excluding us; at-war-with-us already shows
    -- in the row label's stance).
    for i = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        if i ~= iOther and i ~= iUs then
            local p = Players[i]
            if p ~= nil and p:IsAlive() and pUsTeam:IsHasMet(p:GetTeam()) and pOtherTeam:IsAtWar(p:GetTeam()) then
                out[#out + 1] = Text.format("TXT_KEY_AT_WAR_WITH", thirdPartyName(i, iUs))
            end
        end
    end

    -- DoFs with anyone (incl. us).
    for i = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        if i ~= iOther then
            local p = Players[i]
            if p ~= nil and p:IsAlive() then
                local met = pUsTeam:IsHasMet(p:GetTeam()) or i == iUs
                if met and pOther:IsDoF(i) then
                    out[#out + 1] = Text.format("TXT_KEY_DIPLO_FRIENDS_WITH", thirdPartyName(i, iUs))
                end
            end
        end
    end

    -- Denouncements toward anyone, with backstab variant.
    for i = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        if i ~= iOther then
            local p = Players[i]
            if p ~= nil and p:IsAlive() then
                local met = pUsTeam:IsHasMet(p:GetTeam()) or i == iUs
                if met and (pOther:IsDenouncedPlayer(i) or p:IsFriendDeclaredWarOnUs(iOther)) then
                    local name = thirdPartyName(i, iUs)
                    if p:IsFriendDenouncedUs(iOther) or p:IsFriendDeclaredWarOnUs(iOther) then
                        out[#out + 1] = Text.format("TXT_KEY_DIPLO_BACKSTABBED", name)
                    else
                        out[#out + 1] = Text.format("TXT_KEY_DIPLO_DENOUNCED", name)
                    end
                end
            end
        end
    end

    -- CS alliances with pOther.
    for i = GameDefines.MAX_MAJOR_CIVS, GameDefines.MAX_CIV_PLAYERS - 1 do
        local p = Players[i]
        if p ~= nil and p:IsAlive() then
            local met = pUsTeam:IsHasMet(p:GetTeam()) or i == iUs
            if met and p:IsAllies(iOther) then
                out[#out + 1] = Text.format("TXT_KEY_ALLIED_WITH", Text.key(p:GetCivilizationShortDescription()))
            end
        end
    end

    if #out == 0 then
        return noneCell()
    end
    return table.concat(out, ", ")
end

-- Gold cell: gold-on-hand plus per-turn rate. The cell is sortable on
-- gold-on-hand only; sorting on per-turn rate would need a second column.
local function goldCellValues(iOther)
    local iUs = Game.GetActivePlayer()
    local g_Deal = UI.GetScratchDeal()
    local gold = g_Deal:GetGoldAvailable(iOther, -1) or 0
    local gpt = Players[iOther]:CalculateGoldRate() or 0
    return gold, gpt
end

local function goldCell(iOther)
    local gold, gpt = goldCellValues(iOther)
    return Text.format("TXT_KEY_CIVVACCESS_DIPLO_GOLD_CELL", tostring(gold), tostring(gpt))
end

-- Tradeable strategics + luxuries that pOther could trade to us right now.
-- Returns two arrays so resourcesCell can format them and the sort helper
-- can count them without re-running the scan logic in two places.
local function tradeableResources(iOther)
    local iUs = Game.GetActivePlayer()
    local g_Deal = UI.GetScratchDeal()
    local strategic, luxury = {}, {}
    for row in GameInfo.Resources() do
        local rid = row.ID
        if g_Deal:IsPossibleToTradeItem(iOther, iUs, TradeableItems.TRADE_ITEM_RESOURCES, rid, 1) then
            local count = Players[iOther]:GetNumResourceAvailable(rid, false)
            local entry = Text.format("TXT_KEY_CIVVACCESS_DIPLO_RES_COUNT", Text.key(row.Description), tostring(count))
            if row.ResourceClassType == "RESOURCECLASS_LUXURY" then
                luxury[#luxury + 1] = entry
            else
                strategic[#strategic + 1] = entry
            end
        end
    end
    return strategic, luxury
end

local function resourcesCell(iOther)
    local strategic, luxury = tradeableResources(iOther)
    local out = {}
    if #strategic > 0 then
        out[#out + 1] = Text.format("TXT_KEY_CIVVACCESS_DIPLO_STRATEGIC_LIST", table.concat(strategic, ", "))
    end
    if #luxury > 0 then
        out[#out + 1] = Text.format("TXT_KEY_CIVVACCESS_DIPLO_LUXURY_LIST", table.concat(luxury, ", "))
    end
    if #out == 0 then
        return noneCell()
    end
    return table.concat(out, ", ")
end

local function tradeableResourceCount(iOther)
    local strategic, luxury = tradeableResources(iOther)
    return #strategic + #luxury
end

local function eraCell(iOther)
    return Text.key(GameInfo.Eras[Players[iOther]:GetCurrentEra()].Description)
end

-- Per-branch policy counts. Empty case: "none".
local function policiesCell(iOther)
    local pOther = Players[iOther]
    local items = {}
    for branch in GameInfo.PolicyBranchTypes() do
        local count = 0
        for policy in GameInfo.Policies() do
            if policy.PolicyBranchType == branch.Type and pOther:HasPolicy(policy.ID) then
                count = count + 1
            end
        end
        if count > 0 then
            items[#items + 1] = Text.format(
                "TXT_KEY_CIVVACCESS_DIPLO_POLICY_COUNT",
                Text.key(branch.Description),
                tostring(count)
            )
        end
    end
    if #items == 0 then
        return noneCell()
    end
    return table.concat(items, ", ")
end

local function policyTotalCount(iOther)
    local pOther = Players[iOther]
    local total = 0
    for policy in GameInfo.Policies() do
        if pOther:HasPolicy(policy.ID) then
            total = total + 1
        end
    end
    return total
end

-- Wonders: world wonders (BuildingClass.MaxGlobalInstances > 0) the civ
-- has built. Empty case: "none".
local function wondersList(iOther)
    local pOther = Players[iOther]
    local names = {}
    for building in GameInfo.Buildings() do
        local bc = GameInfo.BuildingClasses[building.BuildingClass]
        if bc.MaxGlobalInstances > 0 and pOther:CountNumBuildings(building.ID) > 0 then
            names[#names + 1] = Text.key(building.Description)
        end
    end
    return names
end

local function wondersCell(iOther)
    local names = wondersList(iOther)
    if #names == 0 then
        return noneCell()
    end
    return table.concat(names, ", ")
end

local function scoreCell(iOther)
    return tostring(Players[iOther]:GetScore())
end

-- Civilopedia entry for a major: the leader article. Every column on the
-- Majors tab uses this so Ctrl+I always lands on the same place
-- regardless of which cell the user is reading -- the row IS the civ /
-- leader, and per-cell-specific articles (era, score, gold) either don't
-- exist as concepts or are too generic to be useful.
local function leaderPedia(iOther)
    return Text.key(GameInfo.Leaders[Players[iOther]:GetLeaderType()].Description)
end

-- ===== Major civ activate =============================================

-- Mirrors base LeaderSelected: skip when our turn isn't active or the
-- network layer is processing, so we don't initiate a trade the engine
-- would immediately reject.
local function activateMajor(iOther)
    if not Players[Game.GetActivePlayer()]:IsTurnActive() or Game.IsProcessingMessages() then
        return
    end
    DiploCommon.openTradeWith(iOther)
end

-- ===== Minor civ helpers ==============================================

-- Personality word: friendly / neutral / hostile / irrational.
local function personalityWord(iOther)
    local p = Players[iOther]:GetPersonality()
    if p == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_FRIENDLY then
        return Text.key("TXT_KEY_CITY_STATE_PERSONALITY_FRIENDLY")
    elseif p == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_NEUTRAL then
        return Text.key("TXT_KEY_CITY_STATE_PERSONALITY_NEUTRAL")
    elseif p == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_HOSTILE then
        return Text.key("TXT_KEY_CITY_STATE_PERSONALITY_HOSTILE")
    elseif p == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_IRRATIONAL then
        return Text.key("TXT_KEY_CITY_STATE_PERSONALITY_IRRATIONAL")
    end
    return ""
end

-- Bonuses currently flowing from this CS to us (Friends / Allies grants).
-- Engine getters return 0 outside the relevant tier and for traits that
-- don't apply, so a non-friend CS adds nothing and an allied CS adds
-- only what the trait actually grants. Mirrors GetCityStateStatusToolTip
-- bFullInfo branch.
local function minorBonusFragments(iOther)
    local iUs = Game.GetActivePlayer()
    local pOther = Players[iOther]
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

-- Relationship cell: everything currently flowing because of the
-- relationship. Yield bonuses (culture, food, science, faith, happiness,
-- military spawn estimate) plus exported resources (the strategics and
-- luxuries an allied / friend CS sends us). Mirrors what the engine
-- credits the player from the city-state. Empty case is silent rather
-- than "none": the row label already names the CS and its status, so an
-- empty cell on a Neutral CS reads naturally as "no bonuses, no exports
-- flowing right now" without an explicit filler word.
local function relationshipCell(iOther)
    local pOther = Players[iOther]
    local items = minorBonusFragments(iOther)
    for row in GameInfo.Resources() do
        local rid = row.ID
        local count = pOther:GetResourceExport(rid)
        if count > 0 and Game.GetResourceUsageType(rid) ~= ResourceUsageTypes.RESOURCEUSAGE_BONUS then
            items[#items + 1] = Text.format(
                "TXT_KEY_CIVVACCESS_DIPLO_RES_COUNT",
                Text.key(row.Description),
                tostring(count)
            )
        end
    end
    return table.concat(items, ", ")
end

-- Numeric rank for sorting the Relationship cell best-to-worst. Allied
-- and Friend are the tiers where bonuses actually flow; Neutral and
-- below carry no bonuses but stay above War. Influence column already
-- sorts by raw influence value; this column groups by tier so the
-- Allies cluster together regardless of small influence differences.
local function minorRelationshipRank(iOther)
    local iUs = Game.GetActivePlayer()
    local pUsTeam = Teams[Players[iUs]:GetTeam()]
    local pOther = Players[iOther]
    if pUsTeam:IsAtWar(pOther:GetTeam()) then
        return 0
    end
    if pOther:IsAllies(iUs) then
        return 4
    end
    if pOther:IsFriends(iUs) then
        return 3
    end
    local inf = pOther:GetMinorCivFriendshipWithMajor(iUs)
    if inf >= GameDefines.FRIENDSHIP_THRESHOLD_NEUTRAL then
        return 2
    end
    return 1
end

-- Trait and personality cell. Trait first (the type that determines what
-- the relationship would grant), personality second (the modifier on
-- influence behavior). Trait is always present; personality always
-- present.
local function traitPersonalityCell(iOther)
    local trait = GetCityStateTraitText(iOther) or ""
    local personality = personalityWord(iOther)
    return Text.format("TXT_KEY_CIVVACCESS_DIPLO_TRAIT_PERSONALITY_CELL", trait, personality)
end

-- Influence cell: current value (signed) + per-turn rate (when nonzero) +
-- anchor (when not equal to current) + threshold gap to the next
-- relationship state. _TO_FRIENDS below the friends threshold,
-- _TO_ALLIES between thresholds, no gap when at or above allies (the
-- "X to displace" number lives on the Allied-with cell).
local function influenceCell(iOther)
    local iUs = Game.GetActivePlayer()
    local pOther = Players[iOther]
    local out = {}

    local inf = pOther:GetMinorCivFriendshipWithMajor(iUs)
    out[#out + 1] = string.format("%+d", inf)

    local perTurn = math.floor(pOther:GetFriendshipChangePerTurnTimes100(iUs) / 100)
    if perTurn ~= 0 then
        out[#out + 1] = Text.format("TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_PER_TURN", string.format("%+d", perTurn))
    end

    local anchor = pOther:GetMinorCivFriendshipAnchorWithMajor(iUs)
    if anchor ~= inf then
        out[#out + 1] = Text.format("TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_ANCHOR", string.format("%+d", anchor))
    end

    local friends = GameDefines.FRIENDSHIP_THRESHOLD_FRIENDS
    local allies = GameDefines.FRIENDSHIP_THRESHOLD_ALLIES
    if inf < friends then
        out[#out + 1] = Text.format("TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_TO_FRIENDS", tostring(friends - inf))
    elseif inf < allies then
        out[#out + 1] = Text.format("TXT_KEY_CIVVACCESS_DIPLO_INFLUENCE_TO_ALLIES", tostring(allies - inf))
    end

    return table.concat(out, ", ")
end

-- Allied-with cell. "you" if we are the ally, "<civ>, X needed to
-- displace" for a non-us ally we can name, "unmet civilization, X
-- needed to displace" for an ally we haven't met (engine still tracks
-- the influence so the displacement value is meaningful even without a
-- name), "nobody" only when no ally exists. The displacement value
-- mirrors CityStateStatusHelper's iInfUntilAllied: ally inf - our inf + 1
-- (need to surpass, not match). Floored at 1 since a value of 0 means
-- the relationship would have already flipped this turn.
local function alliedWithCell(iOther)
    local iUs = Game.GetActivePlayer()
    local pUs = Players[iUs]
    local pUsTeam = Teams[pUs:GetTeam()]
    local pOther = Players[iOther]
    local iAlly = pOther:GetAlly()
    if iAlly == nil or iAlly == -1 then
        return Text.key("TXT_KEY_CIVVACCESS_DIPLO_NOBODY")
    end
    if iAlly == iUs then
        return Text.key("TXT_KEY_CIVVACCESS_DIPLO_ALLY_IS_YOU")
    end
    local allyInf = pOther:GetMinorCivFriendshipWithMajor(iAlly)
    local ourInf = pOther:GetMinorCivFriendshipWithMajor(iUs)
    local need = allyInf - ourInf + 1
    if need < 1 then
        need = 1
    end
    local pAlly = Players[iAlly]
    if not pUsTeam:IsHasMet(pAlly:GetTeam()) then
        return Text.format("TXT_KEY_CIVVACCESS_DIPLO_ALLY_UNMET_DISPLACE", tostring(need))
    end
    return Text.format(
        "TXT_KEY_CIVVACCESS_DIPLO_ALLY_AND_DISPLACE",
        Text.key(pAlly:GetCivilizationShortDescription()),
        tostring(need)
    )
end

-- Quests cell: comma-flattened active-quest tooltip plus threatening-
-- barbarians and proxy-war flags. Suppressed at war (matches base
-- DiploList.lua:627).
local function questsCell(iOther)
    local iUs = Game.GetActivePlayer()
    local pOther = Players[iOther]
    if Teams[Players[iUs]:GetTeam()]:IsAtWar(pOther:GetTeam()) then
        return noneCell()
    end
    local hasQuests = pOther:GetMinorCivNumDisplayedQuestsForPlayer(iUs) > 0
    local hasBarbs = pOther:IsThreateningBarbariansEventActiveForPlayer(iUs)
    local hasProxy = pOther:IsProxyWarActiveForMajor(iUs)
    if not hasQuests and not hasBarbs and not hasProxy then
        return noneCell()
    end
    local raw = GetActiveQuestToolTip(iUs, iOther)
    if raw == nil or raw == "" then
        return noneCell()
    end
    return (raw:gsub("%[NEWLINE%]", ", "))
end

local function questCount(iOther)
    local iUs = Game.GetActivePlayer()
    local pOther = Players[iOther]
    return pOther:GetMinorCivNumDisplayedQuestsForPlayer(iUs)
end

-- Nearby resources: range-5 scan around CS capital, owned-by-CS or
-- close-and-unowned, non-bonus.
local function nearbyResourcesCell(iOther)
    local pOther = Players[iOther]
    local pCapital = pOther:GetCapitalCity()
    if pCapital == nil then
        return noneCell()
    end
    local activeTeam = Game.GetActiveTeam()
    local cx, cy = pCapital:GetX(), pCapital:GetY()
    local items = {}
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
                            items[#items + 1] = Text.format(
                                "TXT_KEY_CIVVACCESS_DIPLO_RES_COUNT",
                                Text.key(GameInfo.Resources[rid].Description),
                                tostring(plot:GetNumResource())
                            )
                        end
                    end
                end
            end
        end
    end
    if #items == 0 then
        return noneCell()
    end
    return table.concat(items, ", ")
end

-- Row label: CS name + engine status text + bullyable suffix when not
-- already implied by status. Engine status surfaces "Afraid" only for
-- low-influence relationships, so a positive-influence bullyable case
-- still earns the suffix.
local function minorRowLabel(iOther)
    local iUs = Game.GetActivePlayer()
    local pOther = Players[iOther]
    local civInfo = GameInfo.MinorCivilizations[pOther:GetMinorCivType()]
    local parts = { Text.key(civInfo.Description) }
    local status = GetCityStateStatusText(iUs, iOther)
    if status ~= nil and status ~= "" then
        parts[#parts + 1] = status
    end
    if pOther:CanMajorBullyGold(iUs)
        and pOther:GetMinorCivFriendshipWithMajor(iUs) >= GameDefines.FRIENDSHIP_THRESHOLD_NEUTRAL
    then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_DIPLO_BULLYABLE")
    end
    return Text.joinNonEmpty(parts)
end

-- Civilopedia entry for a minor: the city-state article. Default fallback
-- for every column on the Minors tab. The Trait/Personality column
-- additionally honours the trait-specific concept article when the trait
-- has one (every shipped MinorCivTrait does today).
local function minorCivPedia(iOther)
    return Text.key(GameInfo.MinorCivilizations[Players[iOther]:GetMinorCivType()].Description)
end

-- CS trait → concept article. Each base / G&K / BNW trait has its own
-- pedia article describing what the trait grants at Friends and Allies
-- tier. Personalities have no dedicated article; the Trait/Personality
-- cell pedias to the trait's article (the more decision-relevant of the
-- two), with a fallback to the city-state pedia entry when a future
-- modded trait isn't in this map.
local TRAIT_PEDIA = {
    MINOR_TRAIT_CULTURED = "TXT_KEY_CITYSTATE_CULTURED_HEADING3_TITLE",
    MINOR_TRAIT_MARITIME = "TXT_KEY_CITYSTATE_MARITIME_HEADING3_TITLE",
    MINOR_TRAIT_MILITARISTIC = "TXT_KEY_CITYSTATE_MILITARISTIC_HEADING3_TITLE",
    MINOR_TRAIT_MERCANTILE = "TXT_KEY_CONCEPT_CITY_STATE_MERCANTILE_DESCRIPTION",
    MINOR_TRAIT_RELIGIOUS = "TXT_KEY_CONCEPT_CITY_STATE_RELIGIOUS_DESCRIPTION",
}

local function traitPersonalityPedia(iOther)
    local civInfo = GameInfo.MinorCivilizations[Players[iOther]:GetMinorCivType()]
    return TRAIT_PEDIA[civInfo.MinorCivTrait] or Text.key(civInfo.Description)
end

-- F4 opens DiploOverview at PopupPriority.InGameUtmost, which sits above
-- CityStateDiplo's PopupPriority. Without closing first the new popup
-- queues behind us and ShowHide doesn't fire until DiploOverview is
-- dequeued. Close DiploOverview so the CS popup surfaces immediately.
local function activateMinor(iOther)
    civvaccess_shared.DiploOverview.close()
    Events.SerialEventGameMessagePopup({
        Type = ButtonPopupTypes.BUTTONPOPUP_CITY_STATE_DIPLO,
        Data1 = iOther,
    })
end

-- ===== Tab construction ===============================================

local function buildMajorColumns()
    local cols = {
        {
            name = "TXT_KEY_CIVVACCESS_DIPLO_COL_YOUR_RELATIONSHIP",
            getCell = yourRelationshipCell,
            sortKey = yourRelationshipRank,
            enterAction = activateMajor,
            pediaName = leaderPedia,
        },
        {
            name = "TXT_KEY_CIVVACCESS_DIPLO_COL_FOREIGN_RELATIONS",
            getCell = foreignRelationsCell,
            enterAction = activateMajor,
            pediaName = leaderPedia,
        },
        {
            name = "TXT_KEY_CIVVACCESS_DIPLO_COL_GOLD",
            getCell = goldCell,
            sortKey = function(iOther)
                local gold = goldCellValues(iOther)
                return gold
            end,
            enterAction = activateMajor,
            pediaName = leaderPedia,
        },
        {
            name = "TXT_KEY_CIVVACCESS_DIPLO_COL_RESOURCES",
            getCell = resourcesCell,
            sortKey = tradeableResourceCount,
            enterAction = activateMajor,
            pediaName = leaderPedia,
        },
        {
            name = "TXT_KEY_CIVVACCESS_DIPLO_COL_ERA",
            getCell = eraCell,
            sortKey = function(iOther)
                return Players[iOther]:GetCurrentEra()
            end,
            enterAction = activateMajor,
            pediaName = leaderPedia,
        },
        {
            name = "TXT_KEY_CIVVACCESS_DIPLO_COL_POLICIES",
            getCell = policiesCell,
            sortKey = policyTotalCount,
            enterAction = activateMajor,
            pediaName = leaderPedia,
        },
        {
            name = "TXT_KEY_CIVVACCESS_DIPLO_COL_WONDERS",
            getCell = wondersCell,
            sortKey = function(iOther)
                return #wondersList(iOther)
            end,
            enterAction = activateMajor,
            pediaName = leaderPedia,
        },
        {
            name = "TXT_KEY_CIVVACCESS_DIPLO_COL_SCORE",
            getCell = scoreCell,
            sortKey = function(iOther)
                return Players[iOther]:GetScore()
            end,
            enterAction = activateMajor,
            pediaName = leaderPedia,
        },
    }
    return cols
end

local function buildMinorColumns()
    local cols = {
        {
            name = "TXT_KEY_CIVVACCESS_DIPLO_COL_RELATIONSHIP",
            getCell = relationshipCell,
            sortKey = minorRelationshipRank,
            enterAction = activateMinor,
            pediaName = minorCivPedia,
        },
        {
            name = "TXT_KEY_CIVVACCESS_DIPLO_COL_TRAIT_PERSONALITY",
            getCell = traitPersonalityCell,
            enterAction = activateMinor,
            pediaName = traitPersonalityPedia,
        },
        {
            name = "TXT_KEY_CIVVACCESS_DIPLO_COL_INFLUENCE",
            getCell = influenceCell,
            sortKey = function(iOther)
                return Players[iOther]:GetMinorCivFriendshipWithMajor(Game.GetActivePlayer())
            end,
            enterAction = activateMinor,
            pediaName = minorCivPedia,
        },
        {
            name = "TXT_KEY_CIVVACCESS_DIPLO_COL_ALLIED_WITH",
            getCell = alliedWithCell,
            enterAction = activateMinor,
            pediaName = minorCivPedia,
        },
        {
            name = "TXT_KEY_CIVVACCESS_DIPLO_COL_QUESTS",
            getCell = questsCell,
            sortKey = questCount,
            enterAction = activateMinor,
            pediaName = minorCivPedia,
        },
        {
            name = "TXT_KEY_CIVVACCESS_DIPLO_COL_NEARBY",
            getCell = nearbyResourcesCell,
            enterAction = activateMinor,
            pediaName = minorCivPedia,
        },
    }
    return cols
end

local function buildMajorsTab()
    return BaseTable.create({
        tabName = "TXT_KEY_CIVVACCESS_DIPLO_MAJORS_GROUP",
        columns = buildMajorColumns(),
        rebuildRows = function()
            local iUs = Game.GetActivePlayer()
            return metMajors(iUs, Teams[Players[iUs]:GetTeam()])
        end,
        rowLabel = majorRowLabel,
    })
end

local function buildMinorsTab()
    return BaseTable.create({
        tabName = "TXT_KEY_CIVVACCESS_DIPLO_MINORS_GROUP",
        columns = buildMinorColumns(),
        rebuildRows = function()
            local iUs = Game.GetActivePlayer()
            return metMinors(iUs, Teams[Players[iUs]:GetTeam()])
        end,
        rowLabel = minorRowLabel,
    })
end

-- ===== Install ========================================================

TabbedShell.install(ContextPtr, {
    name = "DiploRelationships",
    displayName = Text.key("TXT_KEY_DIPLOMACY_OVERVIEW"),
    tabs = {
        buildMajorsTab(),
        buildMinorsTab(),
    },
    initialTabIndex = 1,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    shouldActivate = DiploCommon.shouldActivate,
    -- Consume a staged landing index from the bridge (set by Deals when
    -- Tab / Shift+Tab fires showRelations) so we land on Majors when
    -- entering forward and Minors when entering backward. Default 1
    -- (Majors) when no flag is set, matching F4-from-cold.
    onShow = function(handler)
        local landing = (civvaccess_shared.DiploOverview or {}).relationsLanding
        if type(landing) == "number" and landing >= 1 and landing <= #handler._tabs then
            handler._activeIdx = landing
            handler.rebuildExposed()
        end
        if civvaccess_shared.DiploOverview ~= nil then
            civvaccess_shared.DiploOverview.relationsLanding = nil
        end
    end,
    -- Esc closes the F4 popup. The shell's install handler routes
    -- unbound Esc to onEscape before falling through to priorInput;
    -- DiploOverview's parent InputHandler can't see our keys (Civ V
    -- doesn't bubble unhandled keys back to a parent Context), so the
    -- explicit close is the only path out.
    onEscape = function()
        civvaccess_shared.DiploOverview.close()
        return true
    end,
    -- Tab / Shift+Tab off the edge fires showDeals. The shell pops via
    -- the subsequent ShowHide; the Deals wrapper pushes when its panel
    -- becomes visible.
    onCycleEdge = function(_direction)
        civvaccess_shared.DiploOverview.showDeals()
        return true
    end,
    -- Suppress Scanner's "map mode" reactivation in the gap between this
    -- shell hiding (because of showDeals) and the Deals wrapper pushing.
    -- The bridge raises _switching around the base OnX call.
    suppressReactivateOnHide = function()
        return civvaccess_shared.DiploOverview._switching == true
    end,
})
