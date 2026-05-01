-- ChooseInternationalTradeRoutePopup accessibility. Own-Context popup
-- opened via Events.SerialEventGameMessagePopup with
-- BUTTONPOPUP_CHOOSE_INTERNATIONAL_TRADE_ROUTE. Offers a trade unit
-- (caravan or cargo ship) a choice of destination cities to start a
-- new trade route at; the engine pre-filters via
-- pPlayer:GetPotentialInternationalTradeRouteDestinations(pUnit).
--
-- Items are three drillable Groups (Your Cities / Major Civilizations
-- / City States) matching the engine's three on-screen stacks. Each
-- candidate is a Choice that calls base SelectTradeDestinationChoice
-- to populate the ChooseConfirm overlay, then we push ChooseConfirmSub
-- whose Yes calls base OnConfirmYes
-- (Game.SelectionListGameNetMessage(MISSION_ESTABLISH_TRADE_ROUTE)).
-- The base's per-row GoToCity sub-button is omitted (camera pan, no
-- value to a blind player). The Trade Overview shortcut is wired
-- through to base TradeOverview() so the route inspector is reachable
-- from here once TradeRouteOverview gains accessibility; today it
-- opens a silent screen.

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
include("CivVAccess_TradeRouteRow")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local function preambleText()
    return Text.joinVisibleControls({ "StartingCity", "UnitInfo", "UnitRange" })
end

local function sideList(dest, isMine)
    local entries = {}
    for j, u in ipairs(dest.Yields) do
        local yieldType = j - 1
        local value = isMine and u.Mine or u.Theirs
        local entry = TradeRouteRow.yieldEntry(yieldType, value)
        if entry ~= nil then
            entries[#entries + 1] = entry
        end
    end
    local pressure
    if isMine then
        pressure = TradeRouteRow.pressureEntry(dest.FromReligion, dest.FromPressureAmount)
    else
        pressure = TradeRouteRow.pressureEntry(dest.ToReligion, dest.ToPressureAmount)
    end
    if pressure ~= nil then
        entries[#entries + 1] = pressure
    end
    return table.concat(entries, ", ")
end

local function destIdentifier(dest, targetPlayer)
    if dest.Category == 2 then
        local civDesc = Text.key(targetPlayer:GetCivilizationShortDescriptionKey())
        return Text.format("TXT_KEY_CIVVACCESS_TRADE_ROUTE_DEST_INTL", civDesc, dest.CityName)
    end
    return dest.CityName
end

local function rowLabel(dest, originCity, targetPlayer)
    local parts = {}
    if dest.OldTradeRoute then
        parts[#parts + 1] = Text.key("TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_PREV_ROUTE")
    end
    parts[#parts + 1] = destIdentifier(dest, targetPlayer)

    local distance = Map.PlotDistance(originCity:GetX(), originCity:GetY(), dest.X, dest.Y)
    parts[#parts + 1] = Text.formatPlural("TXT_KEY_CIVVACCESS_TRADE_ROUTE_DISTANCE", distance, distance)

    local mine = sideList(dest, true)
    if mine ~= "" then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_TRADE_ROUTE_YOU_GET", mine)
    end
    local theirs = sideList(dest, false)
    if theirs ~= "" then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_TRADE_ROUTE_THEY_GET", theirs)
    end

    return table.concat(parts, ". ") .. "."
end

local mainHandler = BaseMenu.install(ContextPtr, {
    name = "ChooseInternationalTradeRoutePopup",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CHOOSE_INTERNATIONAL_TRADE_ROUTE"),
    preamble = preambleText,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    deferActivate = true,
    items = {},
})

local CATEGORY_GROUP_KEYS = {
    [1] = "TXT_KEY_CHOOSE_TRADE_ROUTE_YOUR_CITIES",
    [2] = "TXT_KEY_CHOOSE_TRADE_ROUTE_MAJOR_CIVS",
    [3] = "TXT_KEY_CHOOSE_TRADE_ROUTE_CITY_STATES",
}

local function buildItems(popupInfo)
    local pPlayer = Players[Game.GetActivePlayer()]
    if pPlayer == nil then
        return {}
    end
    local pUnit = pPlayer:GetUnitByID(popupInfo.Data2)
    if pUnit == nil then
        return {}
    end
    local originCity = pUnit:GetPlot():GetPlotCity()
    if originCity == nil then
        return {}
    end

    local buckets = { {}, {}, {} }
    local candidates = pPlayer:GetPotentialInternationalTradeRouteDestinations(pUnit)
    for _, dest in ipairs(candidates) do
        local plot = Map.GetPlot(dest.X, dest.Y)
        if plot ~= nil then
            local city = plot:GetPlotCity()
            if city ~= nil then
                local targetOwner = city:GetOwner()
                local targetPlayer = Players[targetOwner]
                local category
                if targetOwner == pPlayer:GetID() then
                    category = 1
                elseif targetOwner < GameDefines.MAX_MAJOR_CIVS then
                    category = 2
                else
                    category = 3
                end
                dest.Category = category
                dest.CityName = city:GetName()
                local destX, destY, tradeType = dest.X, dest.Y, dest.TradeConnectionType
                local label = rowLabel(dest, originCity, targetPlayer)
                buckets[category][#buckets[category] + 1] = BaseMenuItems.Choice({
                    labelText = label,
                    activate = function()
                        SelectTradeDestinationChoice(destX, destY, tradeType)
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

    local items = {}
    if #buckets[1] + #buckets[2] + #buckets[3] == 0 then
        items[#items + 1] = BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_CIVVACCESS_TRADE_ROUTE_NO_DESTINATIONS"),
        })
    end
    for cat = 1, 3 do
        items[#items + 1] = BaseMenuItems.Group({
            labelText = Text.key(CATEGORY_GROUP_KEYS[cat]),
            items = buckets[cat],
            cached = false,
        })
    end

    items[#items + 1] = BaseMenuItems.Button({
        controlName = "TradeOverviewButton",
        textKey = "TXT_KEY_CHOOSE_TRADE_ROUTE_TRADE_OVERVIEW",
        activate = function()
            TradeOverview()
        end,
    })

    return items
end

Events.SerialEventGameMessagePopup.Add(function(popupInfo)
    if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_CHOOSE_INTERNATIONAL_TRADE_ROUTE then
        return
    end
    local ok, items = pcall(buildItems, popupInfo)
    if not ok then
        Log.error("ChooseInternationalTradeRoutePopupAccess buildItems failed: " .. tostring(items))
        return
    end
    mainHandler.setItems(items)
end)
