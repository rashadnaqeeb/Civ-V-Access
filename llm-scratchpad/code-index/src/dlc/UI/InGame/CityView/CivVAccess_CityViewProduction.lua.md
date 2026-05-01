# `src/dlc/UI/InGame/CityView/CivVAccess_CityViewProduction.lua`

389 lines · Production queue sub-handler for the CityView hub: slot-label composers, slot drill-in with queue mutation, post-popup rebuild via TickPump, and a single `CityViewProduction.push` entry point.

## Header comment

```
-- Production queue sub-handler for the CityView accessibility hub. Peeled
-- out of CivVAccess_CityViewAccess.lua. Owns:
--
-- - The slot-label composers (slotOneLabel for the currently-producing
--   item with its production meter percentage, slotNLabel for queued
--   slots without the meter).
-- - The slot drill-in (Move up / Move down / Remove / Back) with engine
--   net-message dispatch (GAMEMESSAGE_SWAP_ORDER / POP_ORDER) and the
--   pop-and-re-push rebuild that follows a successful mutation.
-- - The Production handler itself (push), its item builder
--   (queue slots + queue-mode toggle + Choose Production + Purchase),
--   and the wrapped onActivate that rebuilds the slot list on a popup
--   pop-back via TickPump (the engine's queue mutation isn't visible
--   through GetOrderQueueLength until the next tick).
--
-- Exposes `CityViewProduction.push` for the hub to invoke from
-- buildHubItems. No other external surface; the orchestrator's
-- `CivVAccess_CityViewAccess` only reaches for `.push`.
```

## Outline

- L20: `CityViewProduction = {}`
- L27: `local function isTurnActive()`
- L34: `local function pushCitySub(subName, displayName, items)`
- L46: `local ORDER_INFO_TABLE = { ... }`
- L61: `local function orderNameAndHelp(orderType, data1)`
- L75: `local function slotTurnsLeft(city, orderType, data1, zeroIdx)`
- L86: `local function isGeneratingProduction(city)`
- L90: `local function slotOneLabel(city, orderType, data1)`
- L105: `local function slotNLabel(city, displaySlot, zeroIdx, orderType, data1)`
- L117: `local pushProductionQueue`
- L122: `local function rebuildQueueAfterMutation()`
- L128: `local function pushQueueSlotActions(zeroIdx, slotName)`
- L192: `local function buildProductionQueueItems()`
- L326: `pushProductionQueue = function()`
- L385: `function CityViewProduction.push()`

## Notes

- L117 `local pushProductionQueue`: forward-declared so `rebuildQueueAfterMutation` (L122) can call it recursively; assigned at L326 after `buildProductionQueueItems` is defined.
- L326 `pushProductionQueue`: wraps `handler.onActivate` to defer a `buildProductionQueueItems` rebuild to the next tick (via `TickPump.runOnce`) on every re-activation except the first open, because `GetOrderQueueLength` doesn't reflect `Game.CityPushOrder` mutations until the engine ticks.
- L192 `buildProductionQueueItems`: assigns `._stableTag` to fixed-position items (empty, queue_mode, choose_production, purchase) so the re-activation path can restore the cursor to the same role item when queue length shifts those entries.
