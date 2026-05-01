# `src/dlc/UI/InGame/Popups/CivVAccess_ChooseTradeUnitNewHomeAccess.lua`

138 lines · Accessibility wrapper for BUTTONPOPUP_CHOOSE_TRADE_UNIT_NEW_HOME that lists eligible re-base cities for a trade unit with a ChooseConfirm sub-overlay.

## Header comment

```
-- ChooseTradeUnitNewHome accessibility. Own-Context popup opened via
-- Events.SerialEventGameMessagePopup with
-- BUTTONPOPUP_CHOOSE_TRADE_UNIT_NEW_HOME. Offers a trade unit (caravan
-- or cargo ship) a choice of home cities to re-base at; the engine
-- pre-filters via pPlayer:GetPotentialTradeUnitNewHomeCity(pUnit).
--
-- Flow mirrors ChooseAdmiralNewPortAccess: pick a city -> base
-- SelectNewHome(x, y) shows the ChooseConfirm overlay -> we push
-- ChooseConfirmSub. Yes fires
-- Game.SelectionListGameNetMessage(MISSION_CHANGE_TRADE_UNIT_HOME_CITY)
-- via base's OnConfirmYes. The base's per-row GoToCity sub-button is
-- omitted (camera pan, no value to a blind player). The Trade Overview
-- shortcut is wired through to base's TradeOverview() so the route
-- inspector is reachable from here once TradeRouteOverview itself gains
-- accessibility; today it opens a silent screen.
```

## Outline

- L39: `local priorInput = InputHandler`
- L40: `local priorShowHide = ShowHideHandler`
- L42: `local function preambleText()`
- L59: `local mainHandler = BaseMenu.install(ContextPtr, { ... })`
- L69: `local function buildItems(popupInfo)`
- L127: `Events.SerialEventGameMessagePopup.Add(...)`
