# `src/dlc/UI/InGame/Popups/CivVAccess_DiploCurrentDealsAccess.lua`

275 lines · Accessibility wrapper for the Current Deals tab of DiploOverview, presenting active and historic deals as a read-only flat BaseMenu list.

## Header comment

```
-- DiploCurrentDeals accessibility. The Current Deals tab of DiploOverview;
-- lists active and historic deals the player is party to. Each deal
-- renders as a single Text leaf whose label inlines the full contents
-- (other civ, what we give, what they give) with per-item duration where
-- the item carries one. There's no drill past the deal, no Your / Their
-- offer drawer, and no scratch-deal mutation outside build time -- review
-- is read-only and the trade-screen drawer pattern only earns its keep
-- when the user is composing or modifying an offer.
--
-- The picker list is stable while the popup is open, so one build at
-- onShow is enough; building loads each deal into the engine's scratch
-- slot to read its items and clears the slot afterwards so it doesn't
-- leak loaded state into other consumers.
```

## Outline

- L41: `local priorInput = InputHandler`
- L42: `local priorShowHide = ShowHideHandler`
- L47: `local function turnsSuffix(duration)`
- L55: `local BOOLEAN_KEYS = { ... }`
- L66: `local function thirdPartyName(teamId)`
- L81: `local function describeDealItem(itemType, data1, data2, data3, flag1, duration)`
- L159: `local function buildDealLabel(iPlayer, pScratch)`
- L199: `local function buildDealItems(iPlayer, isCurrent, count)`
- L216: `local function buildItems()`
- L250: `BaseMenu.install(ContextPtr, { ... })`

## Notes

- L250 `BaseMenu.install`: Uses `onTab` / `onShiftTab` to cycle to Global/Relations tabs via `civvaccess_shared.DiploOverview`; uses `onEscape` to close DiploOverview entirely because sub-LuaContext input handlers do not bubble unclaimed keys to the parent Context.
- L271 `suppressReactivateOnHide`: Returns `civvaccess_shared.DiploOverview._switching` to prevent Scanner reactivation during sibling tab swaps.
