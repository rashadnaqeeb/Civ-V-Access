# `src/dlc/UI/InGame/Popups/CivVAccess_EspionageOverviewAccess.lua`

1092 lines · Accessibility wrapper for the EspionageOverview popup (BNW), presenting a three-tab TabbedShell for agents, cities, and intrigue, with move/coup/diplomat sub-flows via stacked BaseMenu handlers.

## Header comment

```
-- Accessibility wrapper for the engine's EspionageOverview popup
-- (BUTTONPOPUP_ESPIONAGE_OVERVIEW, BNW only). TabbedShell over what the
-- engine ships as a single popup with two visual panels: tab 1 splits the
-- engine's left column (agents) and right column (cities) into two flat
-- accessible tabs, tab 3 is intrigue messages. Sortability is dropped --
-- the engine returns spies and cities in a stable order driven by rank /
-- founded order, which is reasonable as a fixed read sequence.
--
-- Engine integration: ships an override of EspionageOverview.lua (verbatim
-- BNW copy plus an include for this module). The engine's OnPopupMessage,
-- InputHandler, ShowHideHandler, RelocateAgent, RefreshAgents,
-- RefreshMyCities, RefreshTheirCities, and RefreshIntrigue stay intact;
-- TabbedShell.install layers our handler on top via the priorInput /
-- priorShowHide chain, and we re-derive every value from live engine
-- queries (GetEspionageSpies / GetEspionageCityStatus / GetIntrigueMessages)
-- so the visual panels and our speech speak from the same engine truth.
--
-- Subflows are all routed through the local pushYesNoConfirm helper, which
-- wraps the engine's Controls.ChooseConfirm overlay (Yes / No buttons) with
-- a sub-handler that pops with reactivate=true on every exit path so the
-- espionage shell re-announces. (The shared ChooseConfirmSub hardcodes
-- reactivate=false on Yes -- correct for popups that close on commit, wrong
-- for Espionage where the screen stays open after a commit.)
--   * Stage Coup (city-state agents): onYes -> Network.SendStageCoup. Coup
--     result feedback arrives later via NotificationAdded which the engine's
--     HandleNotificationAdded surfaces in Controls.NotificationPopup, and
--     speech reaches the user via the regular NotificationAnnounce pipeline.
--   * Move Agent: pushes a sub-handler with the same Your-Cities /
--     Their-Cities split as tab 2 (flat list, no per-city drill), plus a
--     "Move to Hideout" item at the top and a "Cancel" item at the
--     bottom. Eligible cities (from GetAvailableSpyRelocationCities) commit
--     immediately; when the eligible target is an enemy capital of a major
--     civ we are not at war with, the Diplomat-vs-Spy fork uses the same
--     Yes/No sub with onNo wired as a second commit (Diplomat) instead of
--     a cancel.
--   * Move to Hideout: onYes sends Network.SendMoveSpy(..., -1, -1, false).
--
-- Refresh on Events.SerialEventEspionageScreenDirty rebuilds all three
-- tabs from live engine state. The engine fires this after every commit
-- (Move, Coup, intrigue arrival, election cycle) and we listen even with
-- the screen hidden because the engine's own Refresh listener does the
-- same -- a rebuild on a hidden screen is a no-op cost.
```

## Outline

- L67: `local priorInput = InputHandler`
- L68: `local priorShowHide = ShowHideHandler`
- L70: `local m_agentsTab`
- L71: `local m_citiesTab`
- L72: `local m_intrigueTab`
- L81: `local m_announceAfterDirty = false`
- L85: `local function activePlayer()`
- L89: `local function plotCity(x, y)`
- L100: `local function activityKey(agent)`
- L111: `local function activityTooltip(agent, city)`
- L165: `local function viewCity(city)`
- L191: `local function agentRowLabel(agent)`
- L216: `local pushMoveSub`
- L217: `local rebuildAllTabs = function() end`
- L226: `local function agentActions(agent)`
- L325: `local AGENT_ACTIONS_SUB_NAME = "EspionageOverview/AgentActions"`
- L332: `local function pushAgentActionsSub(agent, actions)`
- L365: `local function buildAgentsTabItems()`
- L421: `local function potentialBreakdownEntries(cityInfo)`
- L472: `local function shouldShowBreakdown(cityInfo, isCityState, spy)`
- L486: `local function enrichCityStatus(v)`
- L515: `local function agentInCity(playerID, cityID, spies)`
- L532: `local function spyPresenceClause(spy)`
- L546: `local function potentialClause(cityInfo, isCityState, spy)`
- L574: `local function cityRowLabel(cityInfo, isCityState, spy, dropCiv)`
- L604: `local function buildCityRow(cityInfo, isCityState, spies, dropCiv)`
- L627: `local function buildCitiesTabItems()`
- L707: `local function intrigueRowLabel(msg)`
- L729: `local function buildIntrigueTabItems()`
- L761: `local function pushYesNoConfirm(opts)`
- L819: `local function pushDiplomatPicker(agentId, targetPlayerID, targetCityID, onCommitted)`
- L849: `local function pushHideoutConfirm(agentId, agent, onCommitted)`
- L874: `local function buildMoveSubItems(agent)`
- L1011: `pushMoveSub = function(agent)`
- L1028: `if type(ContextPtr) == "table" and type(ContextPtr.SetShowHideHandler) == "function" then`
- L1042: `rebuildAllTabs = function()`
- L1048: `TabbedShell.install(ContextPtr, { ... })`
- L1065: `Events.SerialEventEspionageScreenDirty.Add(function() ... end)`

## Notes

- L81 `m_announceAfterDirty`: Set true after a user-initiated Network.Send commit; causes the post-dirty rebuild to re-announce the active row so the user hears the updated state rather than the pre-commit label from the natural pop+reactivate.
- L217 `rebuildAllTabs`: Initialized as a no-op stub so closures defined before the install block can safely reference it; the real function is assigned at L1042 inside the install guard.
- L1011 `pushMoveSub`: Assigned as a plain value (not `local function`) because it is forward-declared at L216 and captured by `agentActions` closures before its body is defined.
- L761 `pushYesNoConfirm`: Local variant distinct from the shared `ChooseConfirmSub` because espionage commits do not close the popup, requiring `reactivate=true` on Yes rather than `ChooseConfirmSub`'s hardcoded `false`.
