-- ChooseAdmiralNewPort accessibility. Own-Context popup opened via
-- Events.SerialEventGameMessagePopup with BUTTONPOPUP_CHOOSE_ADMIRAL_PORT.
-- Offers the Great Admiral a choice of home cities to re-base at (the
-- engine resolves movement range and owner rules; we read the filtered
-- list via pPlayer:GetPotentialAdmiralNewPort(pUnit)).
--
-- Flow: pick a city -> base SelectNewHome(x, y) stashes the plot coords
-- and shows the ChooseConfirm overlay -> we push ChooseConfirmSub. Yes
-- fires Game.SelectionListGameNetMessage(MISSION_CHANGE_ADMIRAL_PORT)
-- via base's OnConfirmYes. A trailing Close item bypasses to the base's
-- CloseButton (also mapped to Esc via priorInput).

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
include("CivVAccess_BaseMenuEditMode")
include("CivVAccess_Help")
include("CivVAccess_ChooseConfirmSub")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local function preambleText()
    return Text.joinVisibleControls({ "StartingCity", "UnitInfo" })
end

local mainHandler = BaseMenu.install(ContextPtr, {
    name = "ChooseAdmiralNewPort",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_ADMIRAL_NEW_PORT"),
    preamble = preambleText,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    deferActivate = true,
    items = {},
})

local function buildItems(popupInfo)
    local pPlayer = Players[Game.GetActivePlayer()]
    if pPlayer == nil then
        return {}
    end
    local pUnit = pPlayer:GetUnitByID(popupInfo.Data1)
    if pUnit == nil then
        return {}
    end

    local items = {}
    local candidates = pPlayer:GetPotentialAdmiralNewPort(pUnit)
    for _, v in ipairs(candidates) do
        local plot = Map.GetPlot(v.X, v.Y)
        if plot ~= nil then
            local city = plot:GetPlotCity()
            if city ~= nil then
                local label = Text.format("TXT_KEY_CHANGE_ADMIRAL_PORT_ITEM_CITY", city:GetName())
                local plotX, plotY = v.X, v.Y
                items[#items + 1] = BaseMenuItems.Choice({
                    labelText = label,
                    activate = function()
                        SelectNewHome(plotX, plotY)
                        ChooseConfirmSub.push({
                            onYes = function()
                                OnConfirmYes()
                            end,
                        })
                    end,
                })
            end
        end
    end

    items[#items + 1] = BaseMenuItems.Button({
        controlName = "CloseButton",
        textKey = "TXT_KEY_CLOSE",
        activate = function()
            OnClose()
        end,
    })

    return items
end

Events.SerialEventGameMessagePopup.Add(function(popupInfo)
    if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_CHOOSE_ADMIRAL_PORT then
        return
    end
    local ok, items = pcall(buildItems, popupInfo)
    if not ok then
        Log.error("ChooseAdmiralNewPortAccess buildItems failed: " .. tostring(items))
        return
    end
    mainHandler.setItems(items)
end)
