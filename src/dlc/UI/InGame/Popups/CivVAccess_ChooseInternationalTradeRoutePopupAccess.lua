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

include("CivVAccess_PopupBoot")
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

-- City-state trait adjective, as VP's row text appends it (vanilla data,
-- VP-only display; speaking it everywhere is harmless and useful).
local TRAIT_ADJECTIVE_KEYS = {
    [MinorCivTraitTypes.MINOR_CIV_TRAIT_CULTURED] = "TXT_KEY_CITY_STATE_CULTURED_ADJECTIVE",
    [MinorCivTraitTypes.MINOR_CIV_TRAIT_MILITARISTIC] = "TXT_KEY_CITY_STATE_MILITARISTIC_ADJECTIVE",
    [MinorCivTraitTypes.MINOR_CIV_TRAIT_MARITIME] = "TXT_KEY_CITY_STATE_MARITIME_ADJECTIVE",
    [MinorCivTraitTypes.MINOR_CIV_TRAIT_MERCANTILE] = "TXT_KEY_CITY_STATE_MERCANTILE_ADJECTIVE",
    [MinorCivTraitTypes.MINOR_CIV_TRAIT_RELIGIOUS] = "TXT_KEY_CITY_STATE_RELIGIOUS_ADJECTIVE",
}

-- Corporation franchise status for the row, mirroring VP's CityIcons
-- column: checkbox icon = this city already holds your franchise, invest
-- icon = a route here would create one, denounce icon = it can't. Returns
-- (short status, tooltip with the engine's explanation plus benefit text),
-- or nil where VP shows no icon. The bindings are VP-only.
local function franchiseInfo(pPlayer, originCity, targetCity)
    if targetCity.IsFranchised == nil then
        return nil, nil
    end
    if targetCity:IsFranchised(Game.GetActivePlayer()) then
        return Text.key("TXT_KEY_CIVVACCESS_TRADE_ROUTE_FRANCHISED"),
            Text.key("TXT_KEY_HAS_FRANCHISE_TT") .. pPlayer:GetTradeRouteBenefitHelper()
    end
    if originCity:HasOffice() then
        if pPlayer:CanCreateFranchiseInCity(originCity, targetCity) then
            return Text.key("TXT_KEY_CIVVACCESS_TRADE_ROUTE_CAN_FRANCHISE"),
                Text.key("TXT_KEY_CAN_FRANCHISE_TT") .. pPlayer:GetCurrentOfficeBenefit()
        end
        return Text.key("TXT_KEY_CIVVACCESS_TRADE_ROUTE_NO_FRANCHISE"), Text.key("TXT_KEY_NO_FRANCHISE_HERE_TT")
    end
    return nil, nil
end

-- Returns (label, tooltip, parts). The parts array is the per-sentence
-- fragment list the label is joined from; it doubles as the Alt+Up/Down
-- section list so review walks the row one clause at a time (destination,
-- distance, turns, franchise, "you get", "they get") instead of treating the
-- whole period-joined sentence as one atomic blob. Label and sections share
-- this one array so they can never drift. tooltip is nil unless the row
-- carries franchise detail.
local function rowLabel(dest, pPlayer, pUnit, originCity, targetCity, targetPlayer)
    local parts = {}
    if dest.OldTradeRoute then
        parts[#parts + 1] = Text.key("TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_PREV_ROUTE")
    end
    parts[#parts + 1] = destIdentifier(dest, targetPlayer)

    if targetPlayer:IsMinorCiv() then
        local traitKey = TRAIT_ADJECTIVE_KEYS[targetPlayer:GetMinorCivTrait()]
        if traitKey ~= nil then
            parts[#parts + 1] = Text.key(traitKey)
        end
    end

    -- VP computes the actual route path and shows that distance plus
    -- travel turns; the bindings are VP-only. Vanilla's screen shows no
    -- distance at all, so straight-line hex distance is the best
    -- available there.
    local distance
    if pPlayer.GetTradeConnectionDistance ~= nil then
        distance = pPlayer:GetTradeConnectionDistance(originCity, targetCity, pUnit:GetDomainType())
    else
        distance = Map.PlotDistance(originCity:GetX(), originCity:GetY(), dest.X, dest.Y)
    end
    parts[#parts + 1] = Text.formatPlural("TXT_KEY_CIVVACCESS_TRADE_ROUTE_DISTANCE", distance, distance)
    if pPlayer.GetTradeRouteTurns ~= nil then
        local turns = pPlayer:GetTradeRouteTurns(originCity, targetCity, pUnit:GetDomainType())
        if turns > 0 then
            parts[#parts + 1] = Text.format("TXT_KEY_DIPLO_TURNS", turns)
        end
    end

    local franchise, franchiseTip = franchiseInfo(pPlayer, originCity, targetCity)
    if franchise ~= nil then
        parts[#parts + 1] = franchise
    end

    local mine = sideList(dest, true)
    if mine ~= "" then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_TRADE_ROUTE_YOU_GET", mine)
    end
    local theirs = sideList(dest, false)
    if theirs ~= "" then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_TRADE_ROUTE_THEY_GET", theirs)
    end

    -- Sections mirror the label's clauses, then the franchise tooltip (the one
    -- piece the label carries as a real tooltip rather than an inline clause)
    -- so Alt+Up/Down review still reaches it. Built as a copy so appending the
    -- tip can't leak into the spoken label.
    local sections = {}
    for _, p in ipairs(parts) do
        sections[#sections + 1] = p
    end
    if franchiseTip ~= nil then
        BaseMenuItems.addSections(sections, franchiseTip)
    end

    return table.concat(parts, ". ") .. ".", franchiseTip, sections
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
                local label, tip, sections = rowLabel(dest, pPlayer, pUnit, originCity, city, targetPlayer)
                buckets[category][#buckets[category] + 1] = BaseMenuItems.Choice({
                    labelText = label,
                    tooltipText = tip,
                    sectionsFn = function()
                        return sections
                    end,
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
