# Civ V LuaEvents.X Catalog

Pure-Lua pub/sub events used between UI scripts. One Lua Context fires, others listen. Subscribe with `LuaEvents.X.Add(fn)`, fire by calling `LuaEvents.X(args)` (or `LuaEvents.X.Call(args)` where present). No engine involvement - these are purely Lua-to-Lua.

Total events cataloged: 25

Source: Sid Meier's Civilization V UI and DLC Lua (`Assets/UI/`, `Assets/DLC/`).

Notes on inference: argument names come from handler parameter lists where available, otherwise from caller expressions. Types are best-effort inference from variable names. Where no handler is named and the call site is missing, the event is listed with `args: unknown`.

---

## AdditionalInformationDropdownGatherEntries

- args (from callsite): `additionalEntries`
- example registration: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/ReligionOverview.lua:586` handler `function(entries`
- example callsite: `UI/InGame/WorldView/DiploCorner.lua:46` `(additionalEntries)`
- adds: 7, calls: 3

## AdditionalInformationDropdownSortEntries

- args: `entries`
- example registration: `UI/InGame/WorldView/DiploCorner.lua:85` handler `SortAdditionalInformationDropdownEntries`
- handler body: `UI/InGame/WorldView/DiploCorner.lua:80`
- example callsite: `UI/InGame/WorldView/DiploCorner.lua:49` `(additionalEntries)`
- adds: 3, calls: 3

## AdvisorButtonEvent

- args: `button`
- example registration: `UI/InGame/WorldView/Advisors.lua:25` handler `OnAdvisorButton`
- handler body: `UI/InGame/WorldView/Advisors.lua:11`
- example callsite: `UI/InGame/WorldView/DiploCorner.lua:102` `(Mouse.eRClick)`
- adds: 1, calls: 3

## ChatShow

- args: `(no args)`
- example registration: `UI/InGame/WorldView/MPList.lua:528` handler `OnChatToggle`
- handler body: `UI/InGame/WorldView/DiploCorner.lua:110`
- example callsite: `UI/InGame/WorldView/DiploCorner.lua:126` `(m_bChatOpen)`
- adds: 1, calls: 4

## EnemyPanelHide

- args: `bIsEnemyPanelHide`
- example registration: `UI/InGame/WorldView/UnitPanel.lua:1392` handler `OnEnemyPanelHide`
- handler body: `UI/InGame/WorldView/UnitPanel.lua:1387`
- example callsite: `UI/InGame/WorldView/EnemyUnitPanel.lua:2027` `(bIsHide)`
- adds: 3, calls: 3

## ModBrowserSetDeleteButtonState

- args (from callsite): `true, true, Locale.Lookup("TXT_KEY_MODDING_UNSUBSCRIBE_MOD"`
- example registration: `UI/FrontEnd/Modding/ModsBrowser.lua:79` handler `function(...`
- example callsite: `UI/FrontEnd/Modding/InstalledPanel.lua:88` `(false, false)`
- adds: 1, calls: 4

## ModBrowserSetDownloadButtonState

- args (from callsite): `false, false`
- example callsite: `UI/FrontEnd/Modding/InstalledPanel.lua:89` `(false, false)`
- adds: 0, calls: 1

## ModBrowserSetLikeButtonState

- args (from callsite): `false, false`
- example callsite: `UI/FrontEnd/Modding/InstalledPanel.lua:90` `(false, false)`
- adds: 0, calls: 1

## ModBrowserSetReportButtonState

- args (from callsite): `false, false`
- example callsite: `UI/FrontEnd/Modding/InstalledPanel.lua:91` `(false, false)`
- adds: 0, calls: 1

## OnModBrowserDeleteButtonClicked

- args (from callsite): `(no args)`
- example registration: `UI/FrontEnd/Modding/InstalledPanel.lua:890` handler `function(`
- example callsite: `UI/FrontEnd/Modding/ModsBrowser.lua:64` `()`
- adds: 1, calls: 1

## OnModsBrowserNavigateBack

- args (from callsite): `args`
- example registration: `UI/FrontEnd/Modding/InstalledPanel.lua:883` handler `function(args`
- example callsite: `UI/FrontEnd/Modding/ModsBrowser.lua:11` `(args)`
- adds: 1, calls: 1

## OnRecommendationCheckChanged

- args: `value`
- example registration: `UI/InGame/InGame.lua:289` handler `SetRecommendationCheck`
- handler body: `UI/InGame/InGame.lua:284`
- example callsite: `UI/InGame/WorldView/MiniMapPanel.lua:121` `(mapOptions.HideTileRecommendations)`
- adds: 3, calls: 4

## OpenAILeaderDiploTrade

- args: `(no args)`
- example registration: `UI/InGame/WorldView/SimpleDiploTrade.lua:46` handler `OnOpenAILeaderDiploTrade`
- handler body: `UI/InGame/WorldView/SimpleDiploTrade.lua:40`
- example callsite: `UI/InGame/LeaderHead/DiploTrade.lua:30` `()`
- adds: 1, calls: 1

## OpenSimpleDiploTrade

- args: `(no args)`
- example registration: `UI/InGame/LeaderHead/DiploTrade.lua:45` handler `OnOpenSimpleDiploTrade`
- handler body: `UI/InGame/LeaderHead/DiploTrade.lua:39`
- example callsite: `UI/InGame/WorldView/SimpleDiploTrade.lua:30` `()`
- adds: 1, calls: 1

## PasswordChanged

- args (from callsite): `Game.GetActivePlayer(`
- example registration: `UI/InGame/PlayerChange.lua:181` handler `function(ePlayer`
- example callsite: `UI/InGame/ChangePassword.lua:16` `(Game.GetActivePlayer()`
- adds: 1, calls: 1

## ProductionPopup

- args: `bIsHide`
- example registration: `UI/InGame/CityView/CityView.lua:2366` handler `OnProductionPopup`
- handler body: `UI/InGame/CityView/CityView.lua:2352`
- example callsite: `UI/InGame/Popups/ProductionPopup.lua:1137` `(bIsHide)`
- adds: 3, calls: 3

## ReplayViewer_LoadReplay

- args (from callsite): `replayFile`
- example registration: `UI/InGame/Popups/ReplayViewer.lua:1194` handler `function(file`
- example callsite: `UI/FrontEnd/LoadReplayMenu.lua:29` `(replayFile)`
- adds: 1, calls: 1

## RequestRefreshAdditionalInformationDropdownEntries

- args: `(no args)`
- example registration: `UI/InGame/WorldView/DiploCorner.lua:78` handler `RefreshAdditionalInformationEntries`
- handler body: `UI/InGame/WorldView/DiploCorner.lua:25`
- example callsite: `UI/InGame/WorldView/DiploCorner.lua:230` `()`
- adds: 3, calls: 10

## ScenarioPlayerStatusChanged

- args: `tPlayerStatus, iTurn, iYear, iPlayerAboutToWin, iTurnsControlHeld`
- example registration: `DLC/Expansion/Scenarios/SteampunkScenario/TurnsRemaining.lua:565` handler `ReceivePlayerStatusChanged`
- handler body: `DLC/Expansion/Scenarios/SteampunkScenario/TurnsRemaining.lua:562`
- example callsite: `DLC/Expansion/Scenarios/SteampunkScenario/TurnsRemaining.lua:420` `(tCopy, Game.GetGameTurn()`
- adds: 2, calls: 3

## ScenarioUnitTiersChanged

- args: `tUnitTiers`
- example registration: `DLC/Expansion/Scenarios/SteampunkScenario/TurnsRemaining.lua:570` handler `ReceiveUnitTiersChanged`
- handler body: `DLC/Expansion/Scenarios/SteampunkScenario/TurnsRemaining.lua:567`
- example callsite: `DLC/Expansion/Scenarios/SteampunkScenario/TurnsRemaining.lua:191` `(tCopy)`
- adds: 2, calls: 3

## SetCivNameEditSlot

- args (from callsite): `playerID`
- example registration: `UI/FrontEnd/GameSetup/SetCivNames.lua:297` handler `function(iSlot`
- example callsite: `UI/FrontEnd/Multiplayer/StagingRoom.lua:90` `(0)`
- adds: 1, calls: 2

## SetKickPlayer

- args (from callsite): `selectionIndex, playerName`
- example registration: `DLC/Shared/UI/InGame/Popups/ConfirmKick.lua:64` handler `function(playerID, playerName`
- example callsite: `UI/FrontEnd/Multiplayer/StagingRoom.lua:356` `(playerID, playerName)`
- adds: 1, calls: 2

## ShowScoreList

- args: `bShow`
- example registration: `UI/InGame/WorldView/MPList.lua:564` handler `OnShowScoreList`
- handler body: `UI/InGame/WorldView/MPList.lua:556`
- example callsite: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:2306` `(true)`
- adds: 1, calls: 2

## TryDismissTutorial

- args (from callsite): `"DIPLO_TRADE_SCREEN"`
- example callsite: `UI/InGame/CityView/CityView.lua:76` `("CITY_SCREEN")`
- adds: 0, calls: 6

## TryQueueTutorial

- args (from callsite): `"DIPLO_TRADE_SCREEN", true`
- example callsite: `UI/InGame/CityView/CityView.lua:1691` `("CITY_SCREEN", true)`
- adds: 0, calls: 6

