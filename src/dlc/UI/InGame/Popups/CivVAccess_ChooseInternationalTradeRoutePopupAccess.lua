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

local YIELD_KEYS = {
    [YieldTypes.YIELD_FOOD] = "TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_FOOD",
    [YieldTypes.YIELD_PRODUCTION] = "TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_PRODUCTION",
    [YieldTypes.YIELD_GOLD] = "TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_GOLD",
    [YieldTypes.YIELD_SCIENCE] = "TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_SCIENCE",
    [YieldTypes.YIELD_CULTURE] = "TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_CULTURE",
    [YieldTypes.YIELD_FAITH] = "TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_FAITH",
}

local function preambleText()
    local parts = {}
    for _, name in ipairs({ "StartingCity", "UnitInfo", "UnitRange" }) do
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

-- Yield strings come from the engine's per-yield TXT keys (e.g.
-- TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_GOLD = "+{1_Num}
-- [ICON_GOLD] Gold per turn"). TextFilter strips the icon markup,
-- leaving the speech-clean number + name.
local function yieldEntry(yieldType, valueTimes100)
    if valueTimes100 == 0 then
        return nil
    end
    local key = YIELD_KEYS[yieldType]
    if key == nil then
        return nil
    end
    local raw = Locale.Lookup(key, valueTimes100 / 100)
    return TextFilter.strip(raw)
end

-- Trade religion pressure verified via Community-Patch-DLL
-- CvLuaPlayer.cpp:5237-5264 and CvCityReligions::WouldExertTradeRoute
-- PressureToward: From* names the religion the destination city would
-- push toward our origin; To* names the religion our origin pushes
-- toward the destination. So FromPair belongs to "you get" and ToPair
-- to "they get", matching the engine's myBonuses / theirBonuses
-- bucketing.
local function pressureEntry(religionId, amount)
    if religionId == 0 or amount == 0 then
        return nil
    end
    local name = Text.key(Game.GetReligionName(religionId))
    if name == nil or name == "" then
        return nil
    end
    return Text.format("TXT_KEY_CIVVACCESS_TRADE_ROUTE_PRESSURE", amount, name)
end

local function sideList(dest, isMine)
    local entries = {}
    for j, u in ipairs(dest.Yields) do
        local yieldType = j - 1
        local value = isMine and u.Mine or u.Theirs
        local entry = yieldEntry(yieldType, value)
        if entry ~= nil then
            entries[#entries + 1] = entry
        end
    end
    local pressure
    if isMine then
        pressure = pressureEntry(dest.FromReligion, dest.FromPressureAmount)
    else
        pressure = pressureEntry(dest.ToReligion, dest.ToPressureAmount)
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
    parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_TRADE_ROUTE_DISTANCE", distance)

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
