-- ChooseFaithGreatPerson accessibility. Own-Context popup opened via
-- Events.SerialEventGameMessagePopup with
-- BUTTONPOPUP_CHOOSE_FAITH_GREAT_PERSON. Shares the PopulateItems /
-- CommitItems / SelectedItems scaffold with ChooseGoodyHutReward; see the
-- header of CivVAccess_ChooseGoodyHutRewardAccess.lua for the selection
-- mirror rationale.
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
include("CivVAccess_Help")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local function selectionStub()
    return { SelectionAnim = { SetHide = function() end } }
end

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

local function preambleText()
    local parts = {}
    local t = Controls.TitleLabel and Controls.TitleLabel:GetText() or ""
    if t ~= "" then
        parts[#parts + 1] = t
    end
    local d = Controls.DescriptionLabel and Controls.DescriptionLabel:GetText() or ""
    if d ~= "" then
        parts[#parts + 1] = d
    end
    return table.concat(parts, ", ")
end

local mainHandler = BaseMenu.install(ContextPtr, {
    name = "ChooseFaithGreatPerson",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_FAITH_GREAT_PERSON"),
    preamble = preambleText,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    deferActivate = true,
    items = {},
})

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
                labelText = Locale.ConvertTextKey(info.Description),
                tooltipText = strategy and Locale.ConvertTextKey(strategy) or nil,
                selectedFn = function()
                    return #SelectedItems > 0 and SelectedItems[1][1] == unitType
                end,
                activate = function()
                    SelectedItems = { { unitType, selectionStub() } }
                    if Controls.ConfirmButton ~= nil then
                        Controls.ConfirmButton:SetDisabled(false)
                    end
                end,
            })
        end
    end

    items[#items + 1] = BaseMenuItems.Button({
        controlName = "ConfirmButton",
        textKey = "TXT_KEY_OK_BUTTON",
        activate = function()
            CommitItems["GreatPeople"](SelectedItems, playerID)
            ContextPtr:SetHide(true)
        end,
    })

    return items
end

Events.SerialEventGameMessagePopup.Add(function(popupInfo)
    if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_CHOOSE_FAITH_GREAT_PERSON then
        return
    end
    local ok, items = pcall(buildItems, popupInfo)
    if not ok then
        Log.error("ChooseFaithGreatPersonAccess buildItems failed: " .. tostring(items))
        return
    end
    mainHandler.setItems(items)
end)
