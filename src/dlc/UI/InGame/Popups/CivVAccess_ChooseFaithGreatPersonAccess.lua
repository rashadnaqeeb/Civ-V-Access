-- ChooseFaithGreatPerson accessibility. Own-Context popup opened via
-- Events.SerialEventGameMessagePopup with
-- BUTTONPOPUP_CHOOSE_FAITH_GREAT_PERSON. Shares the PopulateItems /
-- CommitItems / SelectedItems scaffold with ChooseGoodyHutReward.
--
-- Row eligibility is layered: outer filter is player:CanTrain, but the
-- base inline-disables specific great-person types that require a finished
-- policy branch (Merchant / Commerce, Scientist / Rationalism,
-- Writer|Artist|Musician / Aesthetics, General / Honor, Admiral /
-- Exploration, Engineer / Tradition) or, for Prophet, require both a
-- pantheon and religion-founding availability. We replicate the same gate
-- in isEnabled so our item list only offers pickable choices rather than
-- offering a choice that CommitItems / Network.SendFaithGreatPersonChoice
-- would silently discard.
--
-- Vanilla flow is click-row-then-click-Confirm; we collapse to a flat list
-- where Enter on a row commits via CommitItems["GreatPeople"] and hides
-- the popup. The selectionStub second-slot guards against a stray mouse
-- click on a row throwing on base's SelectionAnim:SetHide.

include("CivVAccess_PopupBoot")
include("CivVAccess_ChoosePopupCommon")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler
local selectionStub = ChoosePopupCommon.selectionStub

local function branchFinished(player, branchType)
    local row = GameInfo.PolicyBranchTypes[branchType]
    if row == nil then
        return false
    end
    return player:IsPolicyBranchFinished(row.ID)
end

local function isEnabled(player, info)
    if not player:CanTrain(info.ID, true, true, true, false) then
        return false
    end
    local t = info.Type
    if t == "UNIT_PROPHET" then
        if not player:HasCreatedPantheon() then
            return false
        end
        if not player:HasCreatedReligion() and Game.GetNumReligionsStillToFound() == 0 then
            return false
        end
        return true
    elseif t == "UNIT_MERCHANT" then
        return branchFinished(player, "POLICY_BRANCH_COMMERCE")
    elseif t == "UNIT_SCIENTIST" then
        return branchFinished(player, "POLICY_BRANCH_RATIONALISM")
    elseif t == "UNIT_WRITER" or t == "UNIT_ARTIST" or t == "UNIT_MUSICIAN" then
        return branchFinished(player, "POLICY_BRANCH_AESTHETICS")
    elseif t == "UNIT_GREAT_GENERAL" then
        return branchFinished(player, "POLICY_BRANCH_HONOR")
    elseif t == "UNIT_GREAT_ADMIRAL" then
        return branchFinished(player, "POLICY_BRANCH_EXPLORATION")
    elseif t == "UNIT_ENGINEER" then
        return branchFinished(player, "POLICY_BRANCH_TRADITION")
    end
    return true
end

local function buildItems(popupInfo)
    local playerID = popupInfo.Data1
    local player = Players[playerID]
    if player == nil then
        return {}
    end

    local items = {}
    for info in GameInfo.Units({ Special = "SPECIALUNIT_PEOPLE" }) do
        if isEnabled(player, info) then
            local unitType = info.Type
            local strategy = info.Strategy
            items[#items + 1] = BaseMenuItems.Choice({
                labelText = Text.key(info.Description),
                tooltipText = strategy and Text.key(strategy) or nil,
                activate = function()
                    CommitItems["GreatPeople"]({ { unitType, selectionStub() } }, playerID)
                    ContextPtr:SetHide(true)
                end,
            })
        end
    end

    return items
end

ChoosePopupCommon.install({
    contextPtr = ContextPtr,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    handlerName = "ChooseFaithGreatPerson",
    displayKey = "TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_FAITH_GREAT_PERSON",
    popupType = ButtonPopupTypes.BUTTONPOPUP_CHOOSE_FAITH_GREAT_PERSON,
    buildItems = buildItems,
})
