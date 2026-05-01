# `src/dlc/UI/InGame/Popups/CivVAccess_TradeRouteRow.lua`

49 lines · Shared module providing yield and religion-pressure speech formatters used by both the trade route picker and the trade route overview popups.

## Header comment

```
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
```

## Outline

- L15: `TradeRouteRow = {}`
- L19: `TradeRouteRow.YIELD_KEYS = { ... }`
- L28: `function TradeRouteRow.yieldEntry(yieldType, valueTimes100)`
- L39: `function TradeRouteRow.pressureEntry(religionId, amount)`

## Notes

- L28 `TradeRouteRow.yieldEntry`: `valueTimes100` is the raw engine value (times 100); the function divides by 100 before formatting so callers pass the raw field directly.
