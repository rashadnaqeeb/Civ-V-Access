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
    if religionId == 0 or amount == 0 then
        return nil
    end
    local name = Text.key(Game.GetReligionName(religionId))
    if name == nil or name == "" then
        return nil
    end
    return Text.format("TXT_KEY_CIVVACCESS_TRADE_ROUTE_PRESSURE", amount, name)
end
