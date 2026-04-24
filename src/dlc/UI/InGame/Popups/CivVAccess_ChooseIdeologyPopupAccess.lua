-- ChooseIdeologyPopup accessibility. Own-Context popup opened via
-- Events.SerialEventGameMessagePopup with BUTTONPOPUP_CHOOSE_IDEOLOGY.
-- Three fixed policy branches: Autocracy, Freedom, Order. Each row also
-- lists the civs who have already adopted that ideology and offers a
-- "View Tenets" sub-button; that sub-button is not exposed here because
-- the same information is reachable through the Civilopedia.
--
-- Flow: pick a branch -> SelectIdeologyChoice(branchID) shows the
-- ChooseConfirm overlay with a prompt naming the branch -> we push
-- ChooseConfirmSub over the overlay. Yes fires Network.SendIdeologyChoice
-- via base's OnConfirmYes.

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
include("CivVAccess_ChooseConfirmSub")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local IDEOLOGY_BRANCHES = {
    "POLICY_BRANCH_AUTOCRACY",
    "POLICY_BRANCH_FREEDOM",
    "POLICY_BRANCH_ORDER",
}

local mainHandler = BaseMenu.install(ContextPtr, {
    name = "ChooseIdeologyPopup",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_IDEOLOGY"),
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    deferActivate = true,
    items = {},
})

local function buildItems()
    local items = {}
    for _, branchType in ipairs(IDEOLOGY_BRANCHES) do
        local branch = GameInfo.PolicyBranchTypes[branchType]
        if branch ~= nil then
            local branchID = branch.ID
            local branchDescription = branch.Description
            local iFreePolicies = Game.GetNumFreePolicies(branchID)
            local labelParts = { Locale.ConvertTextKey(branchDescription) }
            if iFreePolicies > 0 then
                labelParts[#labelParts + 1] = Locale.Lookup("TXT_KEY_CHOOSE_IDEOLOGY_NUM_FREE_POLICIES", iFreePolicies)
            end
            items[#items + 1] = BaseMenuItems.Choice({
                labelText = table.concat(labelParts, ", "),
                activate = function()
                    SelectIdeologyChoice(branchID)
                    ChooseConfirmSub.push({
                        onYes = function()
                            OnConfirmYes()
                        end,
                    })
                end,
            })
        end
    end
    return items
end

Events.SerialEventGameMessagePopup.Add(function(popupInfo)
    if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_CHOOSE_IDEOLOGY then
        return
    end
    local ok, items = pcall(buildItems)
    if not ok then
        Log.error("ChooseIdeologyPopupAccess buildItems failed: " .. tostring(items))
        return
    end
    mainHandler.setItems(items)
end)
