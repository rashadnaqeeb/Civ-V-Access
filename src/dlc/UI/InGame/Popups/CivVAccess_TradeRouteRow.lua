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

-- Origin's side: GPT, science, religion pressure that flow back to the
-- origin city. Field names match the engine's GetTradeRoutes shape (see
-- TradeRouteOverview.lua DisplayData).
function TradeRouteRow.originSideList(route)
    local entries = {}
    appendIf(entries, TradeRouteRow.yieldEntry(YieldTypes.YIELD_GOLD, route.FromGPT or 0))
    appendIf(entries, TradeRouteRow.yieldEntry(YieldTypes.YIELD_SCIENCE, route.FromScience or 0))
    appendIf(entries, TradeRouteRow.pressureEntry(route.FromReligion or 0, route.FromPressure or 0))
    return table.concat(entries, ", ")
end

-- Destination's side: GPT, science, religion pressure plus food / production
-- (the latter two flow on intra-civ routes and the engine reports them as 0
-- on international routes).
function TradeRouteRow.destinationSideList(route)
    local entries = {}
    appendIf(entries, TradeRouteRow.yieldEntry(YieldTypes.YIELD_GOLD, route.ToGPT or 0))
    appendIf(entries, TradeRouteRow.yieldEntry(YieldTypes.YIELD_SCIENCE, route.ToScience or 0))
    appendIf(entries, TradeRouteRow.yieldEntry(YieldTypes.YIELD_FOOD, route.ToFood or 0))
    appendIf(entries, TradeRouteRow.yieldEntry(YieldTypes.YIELD_PRODUCTION, route.ToProduction or 0))
    appendIf(entries, TradeRouteRow.pressureEntry(route.ToReligion or 0, route.ToPressure or 0))
    return table.concat(entries, ", ")
end

-- Row label: header, then "you get {yields}" (active player's gain), then
-- "they get {yields}" (other party's gain), then turns-left when valid.
-- Joined with ". " and a trailing period so each clause reads as its own
-- sentence.
--
-- "You" is always the active player, so the side-mapping flips by tab
-- direction: outbound routes (Yours / Available) put the active player at
-- the origin, inbound routes (With You) put them at the destination. The
-- engine's TurnsLeft is negative on routes that haven't been established
-- (Available tab) and on some transitional states; we mirror the engine's
-- own >= 0 guard from TradeRouteOverview.lua DisplayData and omit the
-- clause rather than speak nonsense like "minus 8 turns left."
function TradeRouteRow.rowLabel(route, isInbound)
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
            parts[#parts + 1] = Text.format(
                "TXT_KEY_CIVVACCESS_TRADE_ROUTE_CITY_GETS",
                route.FromCityName,
                originYields
            )
        end
        if destinationYields ~= "" then
            parts[#parts + 1] = Text.format(
                "TXT_KEY_CIVVACCESS_TRADE_ROUTE_CITY_GETS",
                route.ToCityName,
                destinationYields
            )
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

    return table.concat(parts, ". ") .. "."
end
