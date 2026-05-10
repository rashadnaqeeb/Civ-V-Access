-- ChooseFreeItem accessibility (Liberty-tree free Great Person). Own-Context
-- popup opened via Events.SerialEventGameMessagePopup with
-- BUTTONPOPUP_CHOOSE_FREE_GREAT_PERSON. Shares the PopulateItems /
-- CommitItems / SelectedItems scaffold with ChooseGoodyHutReward.
--
-- Row eligibility matches base's PopulateItems["GreatPeople"]:
-- player:CanTrain(info.ID, true, true, true, false) and (pantheon or not
-- FoundReligion) -- Liberty's prophet reward is gated behind having a
-- pantheon, same as the sighted screen. Vanilla flow is click-row-then-
-- click-Confirm; we collapse it to a flat list where Enter on a row
-- commits via CommitItems["GreatPeople"] (sends Network.SendGreatPersonChoice)
-- and closes the popup via OnClose. The selectionStub second-slot is a
-- guard against a stray mouse click on a row while our sub-handler is
-- active throwing on base's SelectionAnim:SetHide. Close uses
-- UIManager:DequeuePopup via OnClose (this popup was opened via
-- UIManager:QueuePopup in DisplayPopup, unlike GoodyHut which uses
-- ContextPtr:SetHide).

include("CivVAccess_PopupBoot")
include("CivVAccess_ChoosePopupCommon")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler
local selectionStub = ChoosePopupCommon.selectionStub

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
                labelText = Text.key(info.Description),
                tooltipText = strategy and Text.key(strategy) or nil,
                activate = function()
                    CommitItems["GreatPeople"]({ { unitType, selectionStub() } }, playerID)
                    OnClose()
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
    handlerName = "ChooseFreeItem",
    displayKey = "TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_FREE_ITEM",
    popupType = ButtonPopupTypes.BUTTONPOPUP_CHOOSE_FREE_GREAT_PERSON,
    buildItems = buildItems,
})
