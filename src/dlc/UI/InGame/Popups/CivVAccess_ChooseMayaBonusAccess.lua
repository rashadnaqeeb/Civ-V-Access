-- ChooseMayaBonus accessibility. Own-Context popup opened via
-- Events.SerialEventGameMessagePopup with BUTTONPOPUP_CHOOSE_MAYA_BONUS.
-- Fires at the end of each Maya long-count baktun. Shares the
-- PopulateItems / CommitItems / SelectedItems scaffold with
-- ChooseGoodyHutReward.
--
-- Row eligibility: player:CanTrain(info.ID, ...) AND (either this is a
-- free Maya great-person choice OR the unit hasn't already been taken in
-- an earlier baktun). player:GetUnitBaktun(info.ID) > 0 signals a
-- prior pick; player:IsFreeMayaGreatPersonChoice() waives that gate (the
-- one-off "free choice" every civ gets on their first baktun roll).
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

local function isEnabled(player, info)
    if not player:CanTrain(info.ID, true, true, true, false) then
        return false
    end
    local iEarlierBaktun = player:GetUnitBaktun(info.ID)
    if iEarlierBaktun > 0 and not player:IsFreeMayaGreatPersonChoice() then
        return false
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
    handlerName = "ChooseMayaBonus",
    displayKey = "TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_MAYA_BONUS",
    popupType = ButtonPopupTypes.BUTTONPOPUP_CHOOSE_MAYA_BONUS,
    buildItems = buildItems,
})
