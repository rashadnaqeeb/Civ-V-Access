-- ChooseFreeItem accessibility (Liberty-tree free Great Person). Own-Context
-- popup opened via Events.SerialEventGameMessagePopup with
-- BUTTONPOPUP_CHOOSE_FREE_GREAT_PERSON. Shares the PopulateItems /
-- CommitItems / SelectedItems scaffold with ChooseGoodyHutReward; see the
-- header of CivVAccess_ChooseGoodyHutRewardAccess.lua for the selection
-- mirror rationale.
--
-- Row eligibility matches base's PopulateItems["GreatPeople"]:
-- player:CanTrain(info.ID, true, true, true, false) and (pantheon or not
-- FoundReligion) -- Liberty's prophet reward is gated behind having a
-- pantheon, same as the sighted screen. Close uses UIManager:DequeuePopup
-- via OnClose (this popup was opened via UIManager:QueuePopup in
-- DisplayPopup, unlike GoodyHut which uses ContextPtr:SetHide).

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
    name = "ChooseFreeItem",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_FREE_ITEM"),
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
        if
            player:CanTrain(info.ID, true, true, true, false)
            and (not info.FoundReligion or player:HasCreatedPantheon())
        then
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
            OnClose()
        end,
    })

    return items
end

Events.SerialEventGameMessagePopup.Add(function(popupInfo)
    if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_CHOOSE_FREE_GREAT_PERSON then
        return
    end
    local ok, items = pcall(buildItems, popupInfo)
    if not ok then
        Log.error("ChooseFreeItemAccess buildItems failed: " .. tostring(items))
        return
    end
    mainHandler.setItems(items)
end)
