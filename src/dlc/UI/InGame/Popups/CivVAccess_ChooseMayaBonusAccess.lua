-- ChooseMayaBonus accessibility. Own-Context popup opened via
-- Events.SerialEventGameMessagePopup with BUTTONPOPUP_CHOOSE_MAYA_BONUS.
-- Fires at the end of each Maya long-count baktun. Shares the
-- PopulateItems / CommitItems / SelectedItems scaffold with
-- ChooseGoodyHutReward; see that file's header for the selection mirror
-- rationale.
--
-- Row eligibility: player:CanTrain(info.ID, ...) AND (either this is a
-- free Maya great-person choice OR the unit hasn't already been taken in
-- an earlier baktun). player:GetUnitBaktun(info.ID) > 0 signals a
-- prior pick; player:IsFreeMayaGreatPersonChoice() waives that gate (the
-- one-off "free choice" every civ gets on their first baktun roll).

include("CivVAccess_PopupBoot")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local function selectionStub()
    return { SelectionAnim = { SetHide = function() end } }
end

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
    name = "ChooseMayaBonus",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_MAYA_BONUS"),
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
                labelText = Text.key(info.Description),
                tooltipText = strategy and Text.key(strategy) or nil,
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
    if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_CHOOSE_MAYA_BONUS then
        return
    end
    local ok, items = pcall(buildItems, popupInfo)
    if not ok then
        Log.error("ChooseMayaBonusAccess buildItems failed: " .. tostring(items))
        return
    end
    mainHandler.setItems(items)
end)
