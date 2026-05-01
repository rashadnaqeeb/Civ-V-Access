# `src/dlc/UI/InGame/Popups/CivVAccess_ChooseInternationalTradeRoutePopupAccess.lua`

217 lines · Accessibility wrapper for BUTTONPOPUP_CHOOSE_INTERNATIONAL_TRADE_ROUTE that groups destinations by category (own cities, major civs, city-states) with yield and distance details.

## Header comment

```
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
```

## Outline

- L45: `local priorInput = InputHandler`
- L46: `local priorShowHide = ShowHideHandler`
- L48: `local function preambleText()`
- L63: `local function sideList(dest, isMine)`
- L85: `local function destIdentifier(dest, targetPlayer)`
- L93: `local function rowLabel(dest, originCity, targetPlayer)`
- L115: `local mainHandler = BaseMenu.install(ContextPtr, { ... })`
- L125: `local CATEGORY_GROUP_KEYS = { ... }`
- L131: `local function buildItems(popupInfo)`
- L206: `Events.SerialEventGameMessagePopup.Add(...)`

## Notes

- L63 `sideList`: builds the yield+religion-pressure clause for one side of a trade route (mine or theirs); delegates to `TradeRouteRow` helpers for individual entries.
- L85 `destIdentifier`: returns city name for own-city routes (category 1) and "civ, city" format for international routes (category 2); category 3 (city-states) falls through to bare city name.
