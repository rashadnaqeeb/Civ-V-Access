# `src/dlc/UI/InGame/CivVAccess_TradeLogicOffering.lua`

383 lines · Offering-tab item builder for the diplomacy trade screen: `buildOfferingItems` walks `g_Deal` and emits one BaseMenu item per placed entry on the requested side; `offeringItem` is the per-item-type dispatch switch.

## Header comment

```
-- Offering-tab item builder for the diplomacy trade screen, peeled out
-- of CivVAccess_TradeLogicAccess.lua. Walks the live g_Deal and emits
-- one BaseMenu item per placed entry on the side requested. Read-only
-- branch (AI demand / request / offer, or g_bTradeReview) drops the
-- onActivate paths so items announce but cannot be removed.
--
-- Shared helpers live on the TradeLogicAccess module (`prefix`,
-- `sidePlayer`, `sideIsUs`, `pocketTooltipFn`, `turnsSuffix`,
-- `clearEngineTable`, `afterLocalDealChange`, `emptyPlaceholder`).
-- This file only needs them at call time, not at load time, so the
-- orchestrator's include order (orchestrator includes this file before
-- defining the helpers) does not create a circular-load problem.
```

## Outline

- L14: `TradeLogicOffering = {}`
- L20: `local offeringItem`
- L22: `function TradeLogicOffering.buildOfferingItems(side, readOnly)`
- L56: `offeringItem = function(itemType, data1, data2, data3, flag1, duration, side, readOnly)`
- L382: `return TradeLogicOffering`

## Notes

- L20 `local offeringItem`: forward-declared nil so `buildOfferingItems` can reference it; assigned at L56 after the function it calls is defined.
- L56 `offeringItem`: assigned to a local rather than a module-table field so only `buildOfferingItems` calls it.
