-- ChooseTradeUnitNewHome accessibility. Own-Context popup opened via
-- Events.SerialEventGameMessagePopup with
-- BUTTONPOPUP_CHOOSE_TRADE_UNIT_NEW_HOME. Offers a trade unit (caravan
-- or cargo ship) a choice of home cities to re-base at; the engine
-- pre-filters via pPlayer:GetPotentialTradeUnitNewHomeCity(pUnit).
--
-- Flow mirrors ChooseAdmiralNewPortAccess: pick a city -> base
-- SelectNewHome(x, y) shows the ChooseConfirm overlay -> we push
-- ChooseConfirmSub. Yes fires
-- Game.SelectionListGameNetMessage(MISSION_CHANGE_TRADE_UNIT_HOME_CITY)
-- via base's OnConfirmYes. The base's per-row GoToCity sub-button and
-- the Trade Overview shortcut are omitted; both serve map-focus features
-- a blind player does not use.

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

local function preambleText()
    local parts = {}
    for _, name in ipairs({ "StartingCity", "UnitInfo" }) do
        local c = Controls[name]
        if c ~= nil and not c:IsHidden() then
            local ok, t = pcall(function()
                return c:GetText()
            end)
            if ok and t ~= nil and t ~= "" then
                parts[#parts + 1] = tostring(t)
            end
        end
    end
    return table.concat(parts, ", ")
end

local mainHandler = BaseMenu.install(ContextPtr, {
    name = "ChooseTradeUnitNewHome",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_TRADE_UNIT_NEW_HOME"),
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
    local candidates = pPlayer:GetPotentialTradeUnitNewHomeCity(pUnit)
    for _, v in ipairs(candidates) do
        local plot = Map.GetPlot(v.X, v.Y)
        if plot ~= nil then
            local city = plot:GetPlotCity()
            if city ~= nil then
                local label = Locale.Lookup("TXT_KEY_CHANGE_TRADE_UNIT_HOME_CITY_ITEM_CITY", city:GetName())
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
    if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_CHOOSE_TRADE_UNIT_NEW_HOME then
        return
    end
    local ok, items = pcall(buildItems, popupInfo)
    if not ok then
        Log.error("ChooseTradeUnitNewHomeAccess buildItems failed: " .. tostring(items))
        return
    end
    mainHandler.setItems(items)
end)
