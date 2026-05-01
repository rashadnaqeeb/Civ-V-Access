-- DiploGlobalRelationships accessibility. The Global Politics tab of
-- DiploOverview; lists major civs with era, war-with-us / we-denounced
-- flags, policy counts per branch, wonders owned, and a third-party
-- strip (civs at war with each other, DoFs, denunciations, CS alliances).
-- Activation opens AI trade / PvP trade, matching base LeaderSelected.
--
-- Tab / Shift+Tab cycle to sibling tabs (Relations / Deals); see
-- CivVAccess_DiploOverviewBridge for the cross-Context mechanism.

include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_TextFilter")
include("CivVAccess_InGameStrings_en_US")
include("CivVAccess_PluralRules")
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

-- Return the display name for a third-party player that respects
-- "nickname for humans, civ short description for AI, TXT_KEY_YOU for
-- the active player" -- matching the base code's third-party branches.
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

-- Policies per branch with non-zero count. Matches base's per-branch
-- iteration; formatted as "Tradition 4".
local function policyFragment(pOther)
    local out = {}
    for branch in GameInfo.PolicyBranchTypes() do
        local count = 0
        for policy in GameInfo.Policies() do
            if policy.PolicyBranchType == branch.Type and pOther:HasPolicy(policy.ID) then
                count = count + 1
            end
        end
        if count > 0 then
            local branchName = Text.key(branch.Description)
            out[#out + 1] = Text.format("TXT_KEY_CIVVACCESS_DIPLO_POLICY_COUNT", branchName, tostring(count))
        end
    end
    if #out == 0 then
        return nil
    end
    return Text.format("TXT_KEY_CIVVACCESS_DIPLO_POLICIES_LIST", table.concat(out, ", "))
end

-- Wonders the other civ has built. Wonder = BuildingClass with
-- MaxGlobalInstances > 0, owned by the civ.
local function wondersFragment(pOther)
    local names = {}
    for building in GameInfo.Buildings() do
        local bc = GameInfo.BuildingClasses[building.BuildingClass]
        if bc.MaxGlobalInstances > 0 and pOther:CountNumBuildings(building.ID) > 0 then
            names[#names + 1] = Text.key(building.Description)
        end
    end
    if #names == 0 then
        return nil
    end
    return Text.format("TXT_KEY_CIVVACCESS_DIPLO_WONDERS_LIST", table.concat(names, ", "))
end

-- Third-party relationship fragments: war, DoF, denounce, CS alliance.
-- Returns a flat list of strings, already formatted.
local function thirdPartyFragments(iUs, iOther, pUsTeam, pOtherTeam, pOther)
    local frags = {}

    -- Wars between pOther and other majors (excluding us -- at-war-with-us
    -- is handled in the header's "at war" flag).
    for i = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        if i ~= iOther and i ~= iUs then
            local pThird = Players[i]
            if pThird ~= nil and pThird:IsAlive() then
                local iThirdTeam = pThird:GetTeam()
                if pUsTeam:IsHasMet(iThirdTeam) and pOtherTeam:IsAtWar(iThirdTeam) then
                    frags[#frags + 1] = Text.format("TXT_KEY_AT_WAR_WITH", thirdPartyName(i, iUs))
                end
            end
        end
    end

    -- Declarations of Friendship between pOther and anyone (including us).
    for i = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        if i ~= iOther then
            local pThird = Players[i]
            if pThird ~= nil and pThird:IsAlive() then
                local iThirdTeam = pThird:GetTeam()
                if (pUsTeam:IsHasMet(iThirdTeam) or i == iUs) and pOther:IsDoF(i) then
                    frags[#frags + 1] = Text.format("TXT_KEY_DIPLO_FRIENDS_WITH", thirdPartyName(i, iUs))
                end
            end
        end
    end

    -- Denunciations from pOther toward anyone.
    for i = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        if i ~= iOther then
            local pThird = Players[i]
            if pThird ~= nil and pThird:IsAlive() then
                local iThirdTeam = pThird:GetTeam()
                if pUsTeam:IsHasMet(iThirdTeam) or i == iUs then
                    if pOther:IsDenouncedPlayer(i) or pThird:IsFriendDeclaredWarOnUs(iOther) then
                        local name = thirdPartyName(i, iUs)
                        if pThird:IsFriendDenouncedUs(iOther) or pThird:IsFriendDeclaredWarOnUs(iOther) then
                            frags[#frags + 1] = Text.format("TXT_KEY_DIPLO_BACKSTABBED", name)
                        else
                            frags[#frags + 1] = Text.format("TXT_KEY_DIPLO_DENOUNCED", name)
                        end
                    end
                end
            end
        end
    end

    -- City-state alliances with pOther.
    for i = GameDefines.MAX_MAJOR_CIVS, GameDefines.MAX_CIV_PLAYERS - 1 do
        local pThird = Players[i]
        if pThird ~= nil and pThird:IsAlive() then
            local iThirdTeam = pThird:GetTeam()
            if (pUsTeam:IsHasMet(iThirdTeam) or i == iUs) and pThird:IsAllies(iOther) then
                local csName = Text.key(pThird:GetCivilizationShortDescription())
                frags[#frags + 1] = Text.format("TXT_KEY_ALLIED_WITH", csName)
            end
        end
    end

    return frags
end

local function majorCivItem(iUs, pUs, pUsTeam, iOther)
    local pOther = Players[iOther]
    local pOtherTeam = Teams[pOther:GetTeam()]
    local civName = Text.key(GameInfo.Civilizations[pOther:GetCivilizationType()].ShortDescription)
    local nameLine = Text.format("TXT_KEY_CIVVACCESS_DIPLO_LEADER_OF_CIV", pOther:GetName(), civName)
    local era = Text.key(GameInfo.Eras[pOther:GetCurrentEra()].Description)

    local parts = { nameLine, era }

    if pUsTeam:IsAtWar(pOther:GetTeam()) then
        parts[#parts + 1] = Text.key("TXT_KEY_DO_AT_WAR")
    end

    if pUs:IsDenouncedPlayer(iOther) then
        if pOther:IsFriendDenouncedUs(iUs) or pOther:IsFriendDeclaredWarOnUs(iUs) then
            parts[#parts + 1] = Text.key("TXT_KEY_DIPLO_YOU_HAVE_BACKSTABBED")
        else
            parts[#parts + 1] = Text.key("TXT_KEY_DIPLO_YOU_HAVE_DENOUNCED")
        end
    end

    local policies = policyFragment(pOther)
    if policies then
        parts[#parts + 1] = policies
    end

    local wonders = wondersFragment(pOther)
    if wonders then
        parts[#parts + 1] = wonders
    end

    for _, f in ipairs(thirdPartyFragments(iUs, iOther, pUsTeam, pOtherTeam, pOther)) do
        parts[#parts + 1] = f
    end

    local capturedOther = iOther
    return BaseMenuItems.Choice({
        labelText = Text.joinNonEmpty(parts),
        pediaName = Text.key(GameInfo.Leaders[pOther:GetLeaderType()].Description),
        activate = function()
            DiploCommon.openTradeWith(capturedOther)
        end,
    })
end

local function buildItems()
    local iUs = Game.GetActivePlayer()
    local pUs = Players[iUs]
    local pUsTeam = Teams[pUs:GetTeam()]
    local items = {}
    for i = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        local pOther = Players[i]
        if i ~= iUs and pOther:IsAlive() and pUsTeam:IsHasMet(pOther:GetTeam()) then
            items[#items + 1] = majorCivItem(iUs, pUs, pUsTeam, i)
        end
    end
    if #items == 0 then
        items[1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_CIVVACCESS_DIPLO_NO_CIVS_MET"),
        })
    end
    return items
end

BaseMenu.install(ContextPtr, {
    name = "DiploGlobalRelationships",
    displayName = Text.key("TXT_KEY_DO_GLOBAL_RELATIONS"),
    priorInput = InputHandler,
    priorShowHide = ShowHideHandler,
    shouldActivate = DiploCommon.shouldActivate,
    onShow = function(h)
        h.setItems(buildItems())
    end,
    onTab = function()
        civvaccess_shared.DiploOverview.showRelations()
    end,
    onShiftTab = function()
        civvaccess_shared.DiploOverview.showDeals()
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
