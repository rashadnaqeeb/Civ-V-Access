-- Shared per-yield and religion-pressure formatters for the trade-route
-- popups. Both ChooseInternationalTradeRoutePopupAccess (route picker rows)
-- and TradeRouteOverviewAccess (route summary rows) format yields and
-- religion pressure exactly the same way; sharing one implementation keeps
-- the spoken text identical between the picker the user just came from and
-- the overview they just opened, and means a single edit covers both.
--
-- Trade religion pressure verified via Community-Patch-DLL
-- CvLuaPlayer.cpp:5237-5264 and CvCityReligions::WouldExertTradeRoute
-- PressureToward: From* names the religion the destination city would push
-- toward our origin; To* names the religion our origin pushes toward the
-- destination. So FromPair belongs to "you get" and ToPair to "they get",
-- matching the engine's myBonuses / theirBonuses bucketing.

TradeRouteRow = {}

-- Engine TXT_KEYs for "+{1_Num} [ICON_X] X per turn"; one arg, the value
-- already divided out of the engine's times100 representation.
TradeRouteRow.YIELD_KEYS = {
    [YieldTypes.YIELD_FOOD] = "TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_FOOD",
    [YieldTypes.YIELD_PRODUCTION] = "TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_PRODUCTION",
    [YieldTypes.YIELD_GOLD] = "TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_GOLD",
    [YieldTypes.YIELD_SCIENCE] = "TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_SCIENCE",
    [YieldTypes.YIELD_CULTURE] = "TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_CULTURE",
    [YieldTypes.YIELD_FAITH] = "TXT_KEY_CHOOSE_INTERNATIONAL_TRADE_ROUTE_ITEM_FAITH",
}

function TradeRouteRow.yieldEntry(yieldType, valueTimes100)
    if valueTimes100 == 0 then
        return nil
    end
    local key = TradeRouteRow.YIELD_KEYS[yieldType]
    if key == nil then
        return nil
    end
    return Text.format(key, valueTimes100 / 100)
end

function TradeRouteRow.pressureEntry(religionId, amount)
    -- Match TradeRouteOverview.lua's "religion > 0" guard (line 489 in
    -- the BNW source). NO_RELIGION is -1 and RELIGION_PANTHEON is 0;
    -- neither exerts trade-route pressure. A bare == 0 check would
    -- silently drop Pantheon (correct) but still pass NO_RELIGION
    -- through and would also let any future negative sentinel slip.
    if religionId <= 0 or amount == 0 then
        return nil
    end
    local name = Text.key(Game.GetReligionName(religionId))
    if name == nil or name == "" then
        return nil
    end
    return Text.format("TXT_KEY_CIVVACCESS_TRADE_ROUTE_PRESSURE", amount, name)
end

-- Compose the per-side endpoint identifier for a route row. Three
-- cases. Own city is the bare city name -- the user already knows which
-- civ they are, so the parenthetical civ name only adds noise. City-
-- state endpoints read as "the city-state of X" so the row makes the
-- CS-ness explicit without naming the placeholder "City-State" minor
-- civ ("Sidon (Sidon)" was the prior wording). Foreign major civs
-- reuse the choose-trade-route popup's "Civ, City" framing so the two
-- screens read consistently when the user moves between them.
function TradeRouteRow.cityIdentifier(playerID, cityName)
    if playerID == Game.GetActivePlayer() then
        return cityName
    end
    local pPlayer = Players[playerID]
    if pPlayer == nil then
        return cityName
    end
    if pPlayer:IsMinorCiv() then
        return Text.format("TXT_KEY_CIVVACCESS_TRO_CITY_STATE_OF", cityName)
    end
    return Text.format(
        "TXT_KEY_CIVVACCESS_TRADE_ROUTE_DEST_INTL",
        Text.key(pPlayer:GetCivilizationShortDescriptionKey()),
        cityName
    )
end

function TradeRouteRow.domainLabel(domain)
    if domain == DomainTypes.DOMAIN_SEA then
        return Text.key("TXT_KEY_CIVVACCESS_TRO_DOMAIN_SEA")
    end
    return Text.key("TXT_KEY_CIVVACCESS_TRO_DOMAIN_LAND")
end

local function appendIf(list, entry)
    if entry ~= nil and entry ~= "" then
        list[#list + 1] = entry
    end
end

-- Origin's side: GPT, science, culture, religion pressure that flow back
-- to the origin city. Field names match the engine's GetTradeRoutes shape
-- (see TradeRouteOverview.lua DisplayData). Culture is a Vox Populi trade
-- yield only; vanilla GetTradeRoutes omits FromCulture, so the entry is
-- dropped (value 0) on vanilla and the side list is unchanged there.
function TradeRouteRow.originSideList(route)
    local entries = {}
    appendIf(entries, TradeRouteRow.yieldEntry(YieldTypes.YIELD_GOLD, route.FromGPT or 0))
    appendIf(entries, TradeRouteRow.yieldEntry(YieldTypes.YIELD_SCIENCE, route.FromScience or 0))
    appendIf(entries, TradeRouteRow.yieldEntry(YieldTypes.YIELD_CULTURE, route.FromCulture or 0))
    appendIf(entries, TradeRouteRow.pressureEntry(route.FromReligion or 0, route.FromPressure or 0))
    return table.concat(entries, ", ")
end

-- Destination's side: GPT, science, culture, religion pressure plus food /
-- production (the latter two flow on intra-civ routes and the engine
-- reports them as 0 on international routes). Culture is VP-only (see
-- originSideList).
function TradeRouteRow.destinationSideList(route)
    local entries = {}
    appendIf(entries, TradeRouteRow.yieldEntry(YieldTypes.YIELD_GOLD, route.ToGPT or 0))
    appendIf(entries, TradeRouteRow.yieldEntry(YieldTypes.YIELD_SCIENCE, route.ToScience or 0))
    appendIf(entries, TradeRouteRow.yieldEntry(YieldTypes.YIELD_CULTURE, route.ToCulture or 0))
    appendIf(entries, TradeRouteRow.yieldEntry(YieldTypes.YIELD_FOOD, route.ToFood or 0))
    appendIf(entries, TradeRouteRow.yieldEntry(YieldTypes.YIELD_PRODUCTION, route.ToProduction or 0))
    appendIf(entries, TradeRouteRow.pressureEntry(route.ToReligion or 0, route.ToPressure or 0))
    return table.concat(entries, ", ")
end

-- Vox Populi corporation franchise status for a route, mirroring VP's
-- office / franchise icons in the Trade Route Overview and the route
-- picker. The origin player (route.FromID) is the one whose corporation
-- the franchise belongs to -- the active player on outbound routes, a
-- foreign player on routes that terminate in our cities. Returns a short
-- spoken word, or nil where VP shows no icon (and on vanilla, where the
-- IsFranchised binding is absent). isAvailable narrows the can-create
-- check to the Available tab, matching where VP offers it.
function TradeRouteRow.franchiseStatus(route, isAvailable)
    local targetCity = route.ToCity
    if targetCity == nil or targetCity.IsFranchised == nil then
        return nil
    end
    if targetCity:IsFranchised(route.FromID) then
        return Text.key("TXT_KEY_CIVVACCESS_TRADE_ROUTE_FRANCHISED")
    end
    if isAvailable and route.FromCity ~= nil and route.FromCity:HasOffice() then
        local pPlayer = Players[route.FromID]
        if pPlayer ~= nil and pPlayer:CanCreateFranchiseInCity(route.FromCity, targetCity) then
            return Text.key("TXT_KEY_CIVVACCESS_TRADE_ROUTE_CAN_FRANCHISE")
        end
        return Text.key("TXT_KEY_CIVVACCESS_TRADE_ROUTE_NO_FRANCHISE")
    end
    return nil
end

-- Discrete row-label clauses: header, then "you get {yields}" (active
-- player's gain), then "they get {yields}" (other party's gain), then
-- turns-left when valid. Returned as an array so rowLabel can join them
-- into one spoken sentence and rowLabelSections can hand them to the
-- Alt+Up/Down reviewer one clause at a time.
--
-- "You" is always the active player, so the side-mapping flips by tab
-- direction: outbound routes (Yours / Available) put the active player at
-- the origin, inbound routes (With You) put them at the destination. The
-- engine's TurnsLeft is negative on routes that haven't been established
-- (Available tab) and on some transitional states; we mirror the engine's
-- own >= 0 guard from TradeRouteOverview.lua DisplayData and omit the
-- clause rather than speak nonsense like "minus 8 turns left."
local function rowLabelParts(route, isInbound)
    local parts = {}
    parts[#parts + 1] = Text.format(
        "TXT_KEY_CIVVACCESS_TRO_ROUTE_HEADER",
        TradeRouteRow.domainLabel(route.Domain),
        TradeRouteRow.cityIdentifier(route.FromID, route.FromCityName),
        TradeRouteRow.cityIdentifier(route.ToID, route.ToCityName)
    )

    local originYields = TradeRouteRow.originSideList(route)
    local destinationYields = TradeRouteRow.destinationSideList(route)
    if route.FromID == route.ToID then
        -- Domestic route: both endpoints are the active player's cities.
        -- "You get / they get" is meaningless when both sides are us,
        -- so frame each side by the city that earns the yields.
        if originYields ~= "" then
            parts[#parts + 1] =
                Text.format("TXT_KEY_CIVVACCESS_TRADE_ROUTE_CITY_GETS", route.FromCityName, originYields)
        end
        if destinationYields ~= "" then
            parts[#parts + 1] =
                Text.format("TXT_KEY_CIVVACCESS_TRADE_ROUTE_CITY_GETS", route.ToCityName, destinationYields)
        end
    else
        local yourSide, theirSide
        if isInbound then
            yourSide = destinationYields
            theirSide = originYields
        else
            yourSide = originYields
            theirSide = destinationYields
        end
        if yourSide ~= "" then
            parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_TRADE_ROUTE_YOU_GET", yourSide)
        end
        if theirSide ~= "" then
            parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_TRADE_ROUTE_THEY_GET", theirSide)
        end
    end

    local turns = route.TurnsLeft
    if turns ~= nil and turns >= 0 then
        parts[#parts + 1] = Text.formatPlural("TXT_KEY_CIVVACCESS_TRO_TURNS_LEFT", turns, turns)
    end

    return parts
end

-- One spoken sentence per clause, joined with ". " and a trailing period.
function TradeRouteRow.rowLabel(route, isInbound)
    return table.concat(rowLabelParts(route, isInbound), ". ") .. "."
end

-- The same clauses as rowLabel, each kept as its own review section so
-- Alt+Up/Down walks header, your yields, their yields, and turns-left one
-- at a time instead of the whole ". "-joined blob arriving as a single
-- atomic section. The caller appends the VP route extras as further
-- sections.
function TradeRouteRow.rowLabelSections(route, isInbound)
    return rowLabelParts(route, isInbound)
end
