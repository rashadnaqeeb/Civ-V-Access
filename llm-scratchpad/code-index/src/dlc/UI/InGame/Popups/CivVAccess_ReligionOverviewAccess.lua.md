# `src/dlc/UI/InGame/Popups/CivVAccess_ReligionOverviewAccess.lua`

397 lines · Accessibility wrapper for the Religion Overview popup, presenting three tabs (Your Religion, World Religions, Beliefs) via TabbedShell with live faith-rate refresh on city-info dirty events.

## Header comment

```
-- Accessibility wrapper for the engine's ReligionOverview popup
-- (BUTTONPOPUP_RELIGION_OVERVIEW). Three-tab TabbedShell over the engine's
-- own three-tab screen: tab 1 Your Religion (status, beliefs, faith
-- readout, possible great people, automatic-purchase pulldown), tab 2
-- World Religions (one row per founded religion plus an OVERALL STATUS
-- footer), tab 3 Beliefs (one Group per religion / pantheon, drilling
-- into each religion's beliefs).
--
-- The screen is opened by the engine's existing entry points (Faith string
-- in the top panel, additional-info dropdown, engine Ctrl+P) and by our
-- Ctrl+R binding on BaselineHandler. Engine OnPopup gates on
-- GAMEOPTION_NO_RELIGION, so a religion-off game never queues the popup
-- and our wrapper never installs items against an empty tab.
--
-- Engine integration: ships an override of ReligionOverview.{lua,xml}
-- (verbatim BNW copies plus an include for this module). The engine's
-- OnPopup, InputHandler, ShowHideHandler, RefreshYourReligion /
-- RefreshWorldReligions / RefreshBeliefs, sort wiring, and the
-- AutomaticPurchasePD RegisterSelectionCallback all stay intact;
-- TabbedShell.install layers our handler on top via priorInput /
-- priorShowHide chains.
--
-- Refresh on Events.SerialEventCityInfoDirty rebuilds all three tabs.
-- Faith totals tick on this event each turn-end while the popup stays
-- open; the other tabs are static within a turn but cheap to rebuild
-- alongside, so a single rebuilder covers both.
```

## Outline

- L52: `local priorInput = InputHandler`
- L53: `local priorShowHide = ShowHideHandler`
- L55: `local m_yourTab`
- L56: `local m_worldTab`
- L57: `local m_beliefsTab`
- L59: `local function beliefTypeText(belief)`
- L74: `local function religiousStatusText(player)`
- L94: `local function buildBeliefRow(belief)`
- L104: `local function buildYourReligionItems()`
- L230: `local function buildWorldReligionsItems()`
- L281: `local function buildReligionBeliefGroup(eReligion)`
- L295: `local function buildPantheonBeliefGroup(player, activeTeam)`
- L312: `local function buildBeliefsItems()`
- L347: `PullDownProbe.installFromControls({ "AutomaticPurchasePD" }, {}, {}, {})`
- L368: `TabbedShell.install(ContextPtr, { ... })`
- L387: `Events.SerialEventCityInfoDirty.Add(...)`
