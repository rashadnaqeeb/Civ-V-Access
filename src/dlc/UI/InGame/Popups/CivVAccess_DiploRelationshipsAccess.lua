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
include("CivVAccess_DiploCommon")
include("CivVAccess_Help")

-- State for a major civ. Mirrors base DiploRelationships.InitMajorCivList's
-- war/denouncing/liberated branch, then falls through to the AI approach
-- guess -- which the base code computes but assigns to a never-displayed
-- `statusString` local, so the sighted UI shows nothing for the common
-- case. We speak it.
local function majorState(iUs, pUsTeam, iOther, pOther)
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

local function majorCivItem(iUs, pUs, pUsTeam, iOther)
    local pOther = Players[iOther]
    local civName = Text.key(GameInfo.Civilizations[pOther:GetCivilizationType()].ShortDescription)
    local nameLine = Text.format("TXT_KEY_CIVVACCESS_DIPLO_LEADER_OF_CIV", pOther:GetName(), civName)

    local parts = { nameLine, majorState(iUs, pUsTeam, iOther, pOther) }
    parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_DIPLO_SCORE_VAL", tostring(pOther:GetScore() or 0))

    -- Don't compute trade fragments for civs we're at war with; base
    -- hides the trade strip in that branch.
    if not pUsTeam:IsAtWar(pOther:GetTeam()) then
        for _, f in ipairs(tradeFragments(iUs, iOther)) do
            parts[#parts + 1] = f
        end
    end

    local capturedOther = iOther
    return BaseMenuItems.Choice({
        labelText = DiploCommon.joinParts(parts),
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

local function minorCivItem(iUs, pUsTeam, iOther)
    local pOther = Players[iOther]
    local civInfo = GameInfo.MinorCivilizations[pOther:GetMinorCivType()]
    local parts = { Text.key(civInfo.Description) }
    if pUsTeam:IsAtWar(pOther:GetTeam()) then
        parts[#parts + 1] = Text.key("TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_WAR")
    end
    parts[#parts + 1] = GetCityStateTraitText(iOther)
    parts[#parts + 1] = minorPersonality(pOther)
    parts[#parts + 1] = GetAllyText(iUs, iOther)
    parts[#parts + 1] = minorNearbyResources(iOther, pOther)

    local capturedOther = iOther
    return BaseMenuItems.Choice({
        labelText = DiploCommon.joinParts(parts),
        activate = function()
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

BaseMenu.install(ContextPtr, {
    name = "DiploRelationships",
    displayName = Text.key("TXT_KEY_DO_YOUR_RELATIONS"),
    priorInput = InputHandler,
    priorShowHide = ShowHideHandler,
    onShow = function(h)
        h.setItems(buildItems())
    end,
    onTab = function()
        civvaccess_shared.DiploOverview.showDeals()
    end,
    onShiftTab = function()
        civvaccess_shared.DiploOverview.showGlobal()
    end,
    -- Base DiploOverview's InputHandler maps Esc/Enter to OnClose, but it's
    -- installed on the DiploOverview Context. Sub-LuaContext InputHandlers
    -- (our BaseMenu wrappers) consume keys first; Civ V doesn't bubble an
    -- unclaimed key back to the parent Context, so the user can never
    -- close the popup from a sub-tab without the explicit bridge.
    onEscape = function()
        civvaccess_shared.DiploOverview.close()
        return true
    end,
    -- Tab swap: bridge wraps showX with a _switching flag so Scanner's
    -- onActivate doesn't fire in the gap between this panel hiding and
    -- the sibling pushing.
    suppressReactivateOnHide = function()
        return civvaccess_shared.DiploOverview._switching == true
    end,
    items = {},
})
