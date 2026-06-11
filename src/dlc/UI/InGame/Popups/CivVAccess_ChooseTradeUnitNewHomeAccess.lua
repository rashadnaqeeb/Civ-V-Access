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
-- via base's OnConfirmYes. The base's per-row GoToCity sub-button is
-- omitted (camera pan, no value to a blind player). The Trade Overview
-- shortcut is wired through to base's TradeOverview() so the route
-- inspector is reachable from here once TradeRouteOverview itself gains
-- accessibility; today it opens a silent screen.

include("CivVAccess_PopupBoot")
include("CivVAccess_ChooseConfirmSub")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local function preambleText()
    return Text.joinVisibleControls({ "StartingCity", "UnitInfo" })
end

-- Vox Populi's row decorates each candidate city with trade-building
-- icons and a tooltip carrying the unhappiness the routes could fight and
-- every destination reachable from that home. Returns (label suffix,
-- tooltip) mirroring that; nil on engines without the CP/VP bindings,
-- whose screen shows the bare city name.
local function cityDetail(pPlayer, pUnit, city)
    if city.IsFoodRoutes == nil then
        return nil, nil
    end

    -- Trade buildings, named as VP's icon tooltip names them.
    local buildings = {}
    if city:IsConnectedToCapital() then
        buildings[#buildings + 1] = Text.key("TXT_KEY_HARBOR")
    end
    if city:IsFoodRoutes() then
        buildings[#buildings + 1] = Text.key("TXT_KEY_CARAVANSARY")
    end
    if city:IsProductionRoutes() then
        buildings[#buildings + 1] = Text.key("TXT_KEY_WORKSHOP")
    end
    if city.HasOffice ~= nil and city:HasOffice() then
        buildings[#buildings + 1] = Text.key("TXT_KEY_CORPORATE_OFFICE")
    end
    local suffix
    if #buildings > 0 then
        suffix = table.concat(buildings, ", ")
    end

    local tip = {}
    if suffix ~= nil then
        tip[#tip + 1] = Text.key("TXT_KEY_TRADE_BUILDINGS") .. ", " .. suffix
    end

    -- Unhappiness in the candidate city that routes from it could fight.
    if city.GetUnhappinessFromYield ~= nil then
        local rows = {
            {
                city:GetUnhappinessFromYield(YieldTypes.YIELD_GOLD),
                "TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_POVERTY",
            },
            {
                city:GetUnhappinessFromYield(YieldTypes.YIELD_SCIENCE),
                "TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_ILLITERACY",
            },
            {
                city:GetUnhappinessFromYield(YieldTypes.YIELD_CULTURE),
                "TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_BOREDOM",
            },
            { city:GetUnhappinessFromIsolation(), "TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_ISOLATION" },
        }
        local unhappy = {}
        for _, r in ipairs(rows) do
            if r[1] > 0 then
                unhappy[#unhappy + 1] = Text.format(r[2], r[1])
            end
        end
        if #unhappy > 0 then
            tip[#tip + 1] = Text.key("TXT_KEY_TRADE_UNIT_HAPPINESS") .. " " .. table.concat(unhappy, ", ")
        end
    end

    -- Destinations reachable if this city becomes home.
    if pPlayer.GetPotentialInternationalTradeRouteDestinationsFrom ~= nil then
        local dests = {}
        for _, r in ipairs(pPlayer:GetPotentialInternationalTradeRouteDestinationsFrom(pUnit, city)) do
            local dPlot = Map.GetPlot(r.X, r.Y)
            local dCity = dPlot and dPlot:GetPlotCity()
            if dCity ~= nil then
                local entry = dCity:GetName()
                local dPlayer = Players[dCity:GetOwner()]
                if dPlayer:IsMinorCiv() then
                    entry = entry .. " (" .. Text.key("TXT_KEY_CIV_MINOR_DESC") .. ")"
                    if
                        dPlayer:IsMinorCivActiveQuestForPlayer(
                            pPlayer:GetID(),
                            MinorCivQuestTypes.MINOR_CIV_QUEST_TRADE_ROUTE
                        )
                    then
                        entry = entry .. ", " .. Text.key("TXT_KEY_CIVVACCESS_TRADE_DEST_QUEST")
                    end
                else
                    entry = entry .. " (" .. dPlayer:GetCivilizationDescription() .. ")"
                end
                dests[#dests + 1] = entry
            end
        end
        if #dests > 0 then
            tip[#tip + 1] = Text.format("TXT_KEY_CHANGE_TRADE_UNIT_HOME_CITY_ITEM_CITY_TT", city:GetName())
                .. " "
                .. table.concat(dests, "; ")
        end
    end

    local tooltip
    if #tip > 0 then
        tooltip = table.concat(tip, ". ")
    end
    return suffix, tooltip
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
    if #candidates == 0 then
        items[#items + 1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_CIVVACCESS_TRADE_UNIT_NEW_HOME_NO_CITIES"),
        })
    end
    for _, v in ipairs(candidates) do
        local plot = Map.GetPlot(v.X, v.Y)
        if plot ~= nil then
            local city = plot:GetPlotCity()
            if city ~= nil then
                local label = Text.format("TXT_KEY_CHANGE_TRADE_UNIT_HOME_CITY_ITEM_CITY", city:GetName())
                local suffix, tip = cityDetail(pPlayer, pUnit, city)
                if suffix ~= nil then
                    label = label .. ", " .. suffix
                end
                local plotX, plotY = v.X, v.Y
                items[#items + 1] = BaseMenuItems.Choice({
                    labelText = label,
                    tooltipText = tip,
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
        controlName = "TradeOverviewButton",
        textKey = "TXT_KEY_CHOOSE_TRADE_ROUTE_TRADE_OVERVIEW",
        activate = function()
            TradeOverview()
        end,
    })

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
