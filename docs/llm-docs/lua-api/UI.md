# UI

UI / presentation layer helpers. Static table.

Extracted from 1510 call sites across 122 distinct methods in the shipped game Lua.

## Methods

### ActivateNotification
- `UI.ActivateNotification(blockingNotificationIndex)`
- `UI.ActivateNotification(Id)`
- `UI.ActivateNotification(id)`
- 10 callsites. Example: `UI/InGame/WorldView/ActionInfoPanel.lua:131`

### AddPopup
- `UI.AddPopup(popupInfo)`
- `UI.AddPopup({ Type = ButtonPopupTypes.BUTTONPOPUP_TEXT, Data1 = 800, Option1 = true, Text = "TXT_KEY_MP_LAST_PLAYER" })`
- `UI.AddPopup({ Type = ButtonPopupTypes.BUTTONPOPUP_TEXT, Data1 = 800, Data2 = backgroundID, Option1 = true, Text = "TXT_KEY_CIVIL_WAR_SCENARIO_CIV5_DAWN_TEXT" })`
- `UI.AddPopup({ Type = ButtonPopupTypes.BUTTONPOPUP_TEXT, Data1 = 800, Data2 = 1, Option1 = true, Text = "TXT_KEY_SCRAMBLE_AFRICA_CIV5_DAWN_TEXT" })`
- `UI.AddPopup({ Type = ButtonPopupTypes.BUTTONPOPUP_TEXT, Data1 = 800, Option1 = true, Text = "TXT_KEY_FOR_SCENARIO_CIV5_DAWN_TEXT" })`
- ...and 9 more distinct call shapes
- 110 callsites. Example: `DLC/Expansion2/Scenarios/CivilWarScenario/TurnsRemaining.lua:447`

### AreMediumLeadersAllowed
- `UI.AreMediumLeadersAllowed()`
- 1 callsite. Example: `UI/Options/OptionsMenu.lua:1366`

### CanDoInterfaceMode
- `UI.CanDoInterfaceMode(interfaceMode)`
- 3 callsites. Example: `UI/InGame/WorldView/WorldView.lua:364`

### CanEndTurn
- `UI.CanEndTurn()`
- 3 callsites. Example: `UI/InGame/WorldView/ActionInfoPanel.lua:162`

### CanPlaceUnitAt
- `UI.CanPlaceUnitAt(unit, plot)`
- 6 callsites. Example: `UI/InGame/InGame.lua:150`

### CanSelectionListFound
- `UI.CanSelectionListFound()`
- 12 callsites. Example: `UI/InGame/InGame.lua:828`

### CanSelectionListWork
- `UI.CanSelectionListWork()`
- 9 callsites. Example: `UI/InGame/InGame.lua:811`

### ChangeStartDiploRepeatCount
- `UI.ChangeStartDiploRepeatCount(1)`
- 14 callsites. Example: `UI/InGame/CityBannerManager.lua:1095`

### CheckForCommandLineInvitation
- `UI:CheckForCommandLineInvitation()`
- 2 callsites. Example: `UI/FrontEnd/FrontEnd.lua:9`

### ClearPlaceUnit
- `UI.ClearPlaceUnit()`
- 6 callsites. Example: `UI/InGame/InGame.lua:142`

### ClearSelectedCities
- `UI.ClearSelectedCities()`
- 24 callsites. Example: `UI/InGame/InGame.lua:396`

### ClearSelectionList
- `UI.ClearSelectionList()`
- 3 callsites. Example: `UI/InGame/CityBannerManager.lua:1012`

### CompareFileTime
- `UI.CompareFileTime(oa.LastModified.High, oa.LastModified.Low, ob.LastModified.High, ob.LastModified.Low)`
- 2 callsites. Example: `UI/FrontEnd/LoadMenu.lua:645`

### CopyLastAutoSave
- `UI.CopyLastAutoSave(Controls.NameBox:GetText())`
- 1 callsite. Example: `UI/InGame/Menus/SaveMenu.lua:53`

### DebugFlag
- `UI:DebugFlag()`
- 9 callsites. Example: `UI/InGame/InGame.lua:74`

### DebugKeyHandler
- `UI.DebugKeyHandler(uiMsg, wParam, lParam)`
- 1 callsite. Example: `UI/InGame/DebugMenu.lua:400`

### decTurnTimerSemaphore
- `UI.decTurnTimerSemaphore()`
- 97 callsites. Example: `UI/InGame/PlayerChange.lua:168`

### DeleteReplayFile
- `UI.DeleteReplayFile(g_FileList[ g_iSelected ])`
- 1 callsite. Example: `UI/FrontEnd/LoadReplayMenu.lua:44`

### DeleteSavedGame
- `UI.DeleteSavedGame(g_FileList[ g_iSelected ])`
- `UI.DeleteSavedGame(g_MapList[g_iSelected].File)`
- `UI.DeleteSavedGame(g_SelectedEntry.FileName)`
- 3 callsites. Example: `UI/FrontEnd/LoadMenu.lua:125`

### DoDemand
- `UI.DoDemand()`
- 3 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:829`

### DoEqualizeDealWithHuman
- `UI.DoEqualizeDealWithHuman()`
- 3 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:853`

### DoFinalizePlayerDeal
- `UI.DoFinalizePlayerDeal(g_iThem, g_iUs, false)`
- `UI.DoFinalizePlayerDeal(g_iUs, g_iThem, false)`
- `UI.DoFinalizePlayerDeal(g_iThem, g_iUs, true)`
- 9 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:350`

### DoProposeDeal
- `UI.DoProposeDeal()`
- 6 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:809`

### DoSelectCityAtPlot
- `UI.DoSelectCityAtPlot(plot)`
- `UI.DoSelectCityAtPlot(newCity:Plot())`
- `UI.DoSelectCityAtPlot(city:Plot())`
- `UI.DoSelectCityAtPlot(Map.GetPlot( x, y ))`
- 21 callsites. Example: `UI/InGame/CityBannerManager.lua:1123`

### DoWhatDoesAIWant
- `UI.DoWhatDoesAIWant()`
- 3 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:865`

### DoWhatWillAIGive
- `UI.DoWhatWillAIGive()`
- 3 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:877`

### ExitGame
- `UI.ExitGame()`
- 4 callsites. Example: `UI/FrontEnd/ExitConfirm.lua:19`

### GetAvailableLeaderboards
- `UI.GetAvailableLeaderboards()`
- 1 callsite. Example: `UI/InGame/Popups/Leaderboard.lua:112`

### GetCredits
- `UI.GetCredits()`
- 1 callsite. Example: `UI/FrontEnd/Credits.lua:53`

### GetCurrentGameState
- `UI.GetCurrentGameState()`
- 3 callsites. Example: `UI/FrontEnd/LoadMenu.lua:578`

### GetDllGUID
- `UI.GetDllGUID()`
- 1 callsite. Example: `UI/InGame/Popups/Leaderboard.lua:97`

### GetHallofFameData
- `UI.GetHallofFameData()`
- 1 callsite. Example: `UI/InGame/Popups/HallOfFame.lua:27`

### GetHeadSelectedCity
- `UI.GetHeadSelectedCity()`
- 146 callsites. Example: `UI/InGame/Bombardment.lua:12`

### GetHeadSelectedUnit
- `UI.GetHeadSelectedUnit()`
- `UI:GetHeadSelectedUnit()`
- 93 callsites. Example: `UI/InGame/Bombardment.lua:13`

### GetInterfaceMode
- `UI.GetInterfaceMode()`
- 38 callsites. Example: `UI/InGame/Bombardment.lua:232`

### GetInterfaceModeDebugItemID1
- `UI.GetInterfaceModeDebugItemID1()`
- 6 callsites. Example: `UI/InGame/WorldView/WorldView.lua:258`

### GetInterfaceModeDebugItemID2
- `UI.GetInterfaceModeDebugItemID2()`
- 15 callsites. Example: `UI/InGame/WorldView/WorldView.lua:265`

### GetInterfaceModeValue
- `UI.GetInterfaceModeValue()`
- 10 callsites. Example: `UI/InGame/InGame.lua:179`

### GetLastSelectedUnit
- `UI.GetLastSelectedUnit()`
- 6 callsites. Example: `UI/InGame/CityView/CityView.lua:85`

### GetLeaderboardScores
- `UI.GetLeaderboardScores()`
- 1 callsite. Example: `UI/InGame/Popups/Leaderboard.lua:166`

### GetLeaderHeadRootUp
- `UI.GetLeaderHeadRootUp()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/LeaderHead/LeaderHeadRoot.lua:145`

### GetMapPlayers
- `UI.GetMapPlayers(PreGame.GetMapScript())`
- `UI.GetMapPlayers(mapFileName)`
- `UI.GetMapPlayers(mapScriptFileName)`
- 4 callsites. Example: `UI/FrontEnd/GameSetup/SelectCivilization.lua:70`

### GetMapPreview
- `UI.GetMapPreview(map.File)`
- `UI.GetMapPreview(mapScriptFileName)`
- `UI.GetMapPreview(row.FileName)`
- `UI.GetMapPreview(savedMapScript)`
- `UI.GetMapPreview(entry.File)`
- ...and 4 more distinct call shapes
- 18 callsites. Example: `UI/FrontEnd/GameSetup/AdvancedSetup.lua:814`

### GetMouseOverHex
- `UI.GetMouseOverHex()`
- 44 callsites. Example: `UI/InGame/InGame.lua:120`

### GetMultiplayerLobbyMode
- `UI.GetMultiplayerLobbyMode()`
- 3 callsites. Example: `UI/FrontEnd/Multiplayer/Lobby.lua:95`

### GetNumCurrentDeals
- `UI.GetNumCurrentDeals(iPlayer)`
- `UI.GetNumCurrentDeals(data.LeaderId)`
- 2 callsites. Example: `UI/InGame/Popups/DiploCurrentDeals.lua:23`

### GetNumHistoricDeals
- `UI.GetNumHistoricDeals(iPlayer)`
- 1 callsite. Example: `UI/InGame/Popups/DiploCurrentDeals.lua:48`

### GetPlaceUnit
- `UI.GetPlaceUnit()`
- 6 callsites. Example: `UI/InGame/InGame.lua:141`

### GetReplayFileHeader
- `UI.GetReplayFileHeader(g_FileList[g_iSelected])`
- 1 callsite. Example: `UI/FrontEnd/LoadReplayMenu.lua:143`

### GetReplayFiles
- `UI.GetReplayFiles()`
- 1 callsite. Example: `UI/FrontEnd/LoadReplayMenu.lua:366`

### GetReplayInfo
- `UI.GetReplayInfo(file)`
- 1 callsite. Example: `UI/InGame/Popups/ReplayViewer.lua:1196`

### GetReplayModificationTime
- `UI.GetReplayModificationTime(g_FileList[ g_iSelected ])`
- 1 callsite. Example: `UI/FrontEnd/LoadReplayMenu.lua:173`

### GetReplayModificationTimeRaw
- `UI.GetReplayModificationTimeRaw(v)`
- 1 callsite. Example: `UI/FrontEnd/LoadReplayMenu.lua:379`

### GetSavedGameModificationTime
- `UI.GetSavedGameModificationTime(g_FileList[ g_iSelected ])`
- `UI.GetSavedGameModificationTime(entry.File)`
- `UI.GetSavedGameModificationTime(entry.FileName)`
- 3 callsites. Example: `UI/FrontEnd/LoadMenu.lua:281`

### GetSavedGameModificationTimeRaw
- `UI.GetSavedGameModificationTimeRaw(v)`
- 1 callsite. Example: `UI/FrontEnd/LoadMenu.lua:557`

### GetScratchDeal
- `UI.GetScratchDeal()`
- 8 callsites. Example: `UI/InGame/Popups/DiploCurrentDeals.lua:8`

### GetTempString
- `UI.GetTempString()`
- 1 callsite. Example: `UI/InGame/Popups/CityStateGreetingPopup.lua:337`

### GetUnitFlagIcon
- `UI.GetUnitFlagIcon(pUnit)`
- `UI.GetUnitFlagIcon(unit)`
- 6 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:96`

### GetUnitPortraitIcon
- `UI.GetUnitPortraitIcon(unitProduction, city:GetOwner())`
- `UI.GetUnitPortraitIcon(info.ID, playerID)`
- `UI.GetUnitPortraitIcon(queuedData1, city:GetOwner())`
- `UI.GetUnitPortraitIcon(unitProduction, pCity:GetOwner())`
- `UI.GetUnitPortraitIcon(gp.ID, pCity:GetOwner())`
- ...and 7 more distinct call shapes
- 45 callsites. Example: `UI/InGame/CityBannerManager.lua:368`

### GetVersionInfo
- `UI.GetVersionInfo()`
- 3 callsites. Example: `UI/FrontEnd/MainMenu.lua:14`

### HasMadeProposal
- `UI.HasMadeProposal(g_iPlayer)`
- `UI.HasMadeProposal(g_iUs)`
- `UI.HasMadeProposal(iUs)`
- 17 callsites. Example: `UI/InGame/DiploList.lua:164`

### HasShownLegal
- `UI:HasShownLegal()`
- 1 callsite. Example: `UI/FrontEnd/FrontEnd.lua:11`

### HighlightCanPlacePlots
- `UI.HighlightCanPlacePlots(unit, city:Plot())`
- 3 callsites. Example: `UI/InGame/CityBannerManager.lua:1079`

### incTurnTimerSemaphore
- `UI.incTurnTimerSemaphore()`
- 97 callsites. Example: `UI/InGame/PlayerChange.lua:157`

### interruptTurnTimer
- `UI.interruptTurnTimer()`
- 1 callsite. Example: `UI/InGame/WorldView/MPTurnPanel.lua:389`

### IsAIRequestingConcessions
- `UI.IsAIRequestingConcessions()`
- 9 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:623`

### IsCameraMoving
- `UI.IsCameraMoving()`
- 3 callsites. Example: `UI/InGame/WorldView/WorldView.lua:641`

### IsCityScreenUp
- `UI.IsCityScreenUp()`
- 8 callsites. Example: `UI/InGame/TopPanel.lua:18`

### IsCityScreenViewingMode
- `UI.IsCityScreenViewingMode()`
- 17 callsites. Example: `UI/InGame/CityView/CityView.lua:554`

### IsDX9
- `UI.IsDX9()`
- 1 callsite. Example: `UI/Options/OptionsMenu.lua:1354`

### IsLoadedGame
- `UI:IsLoadedGame()`
- 1 callsite. Example: `UI/FrontEnd/LoadScreen.lua:141`

### IsMapScenario
- `UI.IsMapScenario(mapScriptFileName)`
- 2 callsites. Example: `UI/FrontEnd/GameSetup/GameSetupScreen.lua:224`

### IsTouchScreenEnabled
- `UI.IsTouchScreenEnabled()`
- 67 callsites. Example: `UI/FrontEnd/MainMenu.lua:301`

### LoadCurrentDeal
- `UI.LoadCurrentDeal(iPlayer, index)`
- `UI.LoadCurrentDeal(iPlayer, i)`
- `UI.LoadCurrentDeal(data.LeaderId, i)`
- 5 callsites. Example: `UI/InGame/Popups/DiploCurrentDeals.lua:194`

### LoadHistoricDeal
- `UI.LoadHistoricDeal(iPlayer, index)`
- `UI.LoadHistoricDeal(iPlayer, i)`
- 4 callsites. Example: `UI/InGame/Popups/DiploCurrentDeals.lua:196`

### LoadProposedDeal
- `UI.LoadProposedDeal(g_iUs, g_iThem)`
- `UI.LoadProposedDeal(g_iThem, g_iUs)`
- 6 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:280`

### LocationSelect
- `UI.LocationSelect(plot, bCtrl, bAlt, bShift)`
- 3 callsites. Example: `UI/InGame/InGame.lua:125`

### LookAt
- `UI.LookAt(pPlot, 0)`
- `UI.LookAt(plot)`
- `UI.LookAt(plot, 0)`
- `UI.LookAt(lastCityEnteredPlot, 2)`
- `UI.LookAt(pCity:Plot(), 0)`
- ...and 2 more distinct call shapes
- 43 callsites. Example: `UI/InGame/WorldView/ActionInfoPanel.lua:136`

### LookAtSelectionPlot
- `UI.LookAtSelectionPlot(0)`
- `UI.LookAtSelectionPlot()`
- 11 callsites. Example: `UI/InGame/UnitList.lua:57`

### MoveScenarioPlayerToSlot
- `UI.MoveScenarioPlayerToSlot(playerIndex, 0)`
- `UI.MoveScenarioPlayerToSlot(i - 1, 0)`
- `UI.MoveScenarioPlayerToSlot(scenarioPlayerID, 0)`
- `UI.MoveScenarioPlayerToSlot(0, 0)`
- 11 callsites. Example: `DLC/Expansion2/Scenarios/CivilWarScenario/CivilWarScenarioLoadScreen.lua:68`

### OnHumanDemand
- `UI.OnHumanDemand(g_iAIPlayer)`
- 3 callsites. Example: `UI/InGame/LeaderHead/LeaderHeadRoot.lua:260`

### OnHumanOpenedTradeScreen
- `UI.OnHumanOpenedTradeScreen(g_iAIPlayer)`
- 3 callsites. Example: `UI/InGame/LeaderHead/LeaderHeadRoot.lua:249`

### PostKeyMessage
- `UI.PostKeyMessage(13)`
- `UI.PostKeyMessage(8)`
- `UI.PostKeyMessage(48 + number)`
- 6 callsites. Example: `DLC/Tablet/UI/NumberPad.lua:8`

### ProposedDealExists
- `UI.ProposedDealExists(localPlayer, iPlayerLoop)`
- `UI.ProposedDealExists(iPlayerLoop, localPlayer)`
- `UI.ProposedDealExists(iOtherPlayer, g_iPlayer)`
- `UI.ProposedDealExists(iOtherPlayer, iUs)`
- `UI.ProposedDealExists(iOtherPlayer, g_iUs)`
- ...and 4 more distinct call shapes
- 34 callsites. Example: `UI/InGame/DiploList.lua:358`

### QuickSave
- `UI.QuickSave()`
- 1 callsite. Example: `UI/InGame/Menus/GameMenu.lua:50`

### RebroadcastNotifications
- `UI.RebroadcastNotifications()`
- 6 callsites. Example: `UI/InGame/WorldView/NotificationPanel.lua:426`

### RefreshYieldVisibleMode
- `UI.RefreshYieldVisibleMode()`
- 6 callsites. Example: `UI/InGame/YieldIconManager.lua:280`

### RemoveNotification
- `UI.RemoveNotification(blockingNotificationIndex)`
- `UI.RemoveNotification(Id)`
- 6 callsites. Example: `UI/InGame/WorldView/ActionInfoPanel.lua:193`

### RequestLeaderboardScores
- `UI.RequestLeaderboardScores()`
- 1 callsite. Example: `UI/InGame/Popups/Leaderboard.lua:135`

### RequestLeaveLeader
- `UI.RequestLeaveLeader()`
- 9 callsites. Example: `UI/InGame/LeaderHead/DiscussionDialog.lua:381`

### RequestMinimapBroadcast
- `UI:RequestMinimapBroadcast()`
- 2 callsites. Example: `UI/InGame/WorldView/MiniMapPanel.lua:16`

### ResetScenarioPlayerSlots
- `UI.ResetScenarioPlayerSlots(true)`
- `UI.ResetScenarioPlayerSlots()`
- 11 callsites. Example: `DLC/Expansion2/Scenarios/CivilWarScenario/CivilWarScenarioLoadScreen.lua:56`

### SaveFileList
- `UI.SaveFileList(g_FileList, g_GameType, g_ShowAutoSaves, true)`
- `UI.SaveFileList(savedGames, gameType, false, true)`
- 2 callsites. Example: `UI/FrontEnd/LoadMenu.lua:545`

### SaveGame
- `UI.SaveGame(Controls.NameBox:GetText())`
- 2 callsites. Example: `UI/InGame/Menus/SaveMenu.lua:55`

### SaveMap
- `UI.SaveMap(Controls.NameBox:GetText())`
- 2 callsites. Example: `UI/InGame/Menus/SaveMapMenu.lua:27`

### ScrollLeaderboardDown
- `UI.ScrollLeaderboardDown()`
- 1 callsite. Example: `UI/InGame/Popups/Leaderboard.lua:72`

### ScrollLeaderboardUp
- `UI.ScrollLeaderboardUp()`
- 1 callsite. Example: `UI/InGame/Popups/Leaderboard.lua:62`

### SelectCity
- `UI.SelectCity(city)`
- 6 callsites. Example: `UI/InGame/CityBannerManager.lua:1013`

### SelectUnit
- `UI.SelectUnit(pUnit)`
- `UI.SelectUnit(v)`
- `UI.SelectUnit(UI.GetLastSelectedUnit())`
- `UI.SelectUnit(unit)`
- 19 callsites. Example: `UI/InGame/WorldView/ActionInfoPanel.lua:150`

### SendPathfinderUpdate
- `UI.SendPathfinderUpdate()`
- 9 callsites. Example: `UI/InGame/InGame.lua:535`

### SetAdvisorMessageHasBeenSeen
- `UI.SetAdvisorMessageHasBeenSeen(g_TutorialQueue[1].IDName, true)`
- 1 callsite. Example: `UI/InGame/WorldView/Advisors.lua:35`

### SetCityScreenViewingMode
- `UI.SetCityScreenViewingMode(true)`
- `UI.SetCityScreenViewingMode(false)`
- 15 callsites. Example: `UI/InGame/PopupsGeneric/AnnexCityPopup.lua:35`

### SetDirty
- `UI.SetDirty(InterfaceDirtyBits.GameData_DIRTY_BIT, true)`
- 3 callsites. Example: `UI/InGame/InGame.lua:400`

### SetDontShowPopups
- `UI.SetDontShowPopups(true)`
- `UI.SetDontShowPopups(false)`
- 2 callsites. Example: `UI/FrontEnd/LoadScreen.lua:26`

### SetGridVisibleMode
- `UI.SetGridVisibleMode(mapOptions.ShowGrid)`
- `UI.SetGridVisibleMode(bIsChecked)`
- 4 callsites. Example: `UI/InGame/WorldView/MiniMapPanel.lua:117`

### SetInterfaceMode
- `UI.SetInterfaceMode(InterfaceModeTypes.INTERFACEMODE_SELECTION)`
- `UI.SetInterfaceMode(interfaceModeSelection)`
- `UI.SetInterfaceMode(InterfaceModeTypes.INTERFACEMODE_CITY_RANGE_ATTACK)`
- `UI.SetInterfaceMode(InterfaceModeTypes.INTERFACEMODE_PLACE_UNIT)`
- `UI.SetInterfaceMode(InterfaceModeTypes.INTERFACEMODE_PURCHASE_PLOT)`
- ...and 2 more distinct call shapes
- 124 callsites. Example: `UI/InGame/Bombardment.lua:235`

### SetInterfaceModeValue
- `UI.SetInterfaceModeValue(g_iMinorCivID)`
- 5 callsites. Example: `UI/InGame/Popups/CityStateDiploPopup.lua:579`

### SetLeaderboard
- `UI.SetLeaderboard(m_LeaderboardPulldownData[leaderboardIdx].ModID, m_LeaderboardPulldownData[leaderboardIdx].Name)`
- 1 callsite. Example: `UI/InGame/Popups/Leaderboard.lua:85`

### SetLeaderboardCategory
- `UI.SetLeaderboardCategory(which)`
- 1 callsite. Example: `UI/InGame/Popups/Leaderboard.lua:45`

### SetLeaderHeadRootUp
- `UI.SetLeaderHeadRootUp(false)`
- `UI.SetLeaderHeadRootUp(true)`
- 9 callsites. Example: `UI/InGame/LeaderHead/LeaderHeadRoot.lua:116`

### SetMultiplayerLobbyMode
- `UI.SetMultiplayerLobbyMode(MultiplayerLobbyMode.LOBBYMODE_PITBOSS_INTERNET)`
- `UI.SetMultiplayerLobbyMode(MultiplayerLobbyMode.LOBBYMODE_STANDARD_INTERNET)`
- `UI.SetMultiplayerLobbyMode(MultiplayerLobbyMode.LOBBYMODE_PITBOSS_LAN)`
- `UI.SetMultiplayerLobbyMode(MultiplayerLobbyMode.LOBBYMODE_STANDARD_LAN)`
- 4 callsites. Example: `UI/FrontEnd/Multiplayer/MultiplayerSelect.lua:33`

### SetOfferTradeRepeatCount
- `UI.SetOfferTradeRepeatCount(0)`
- 3 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:392`

### SetPlaceUnit
- `UI.SetPlaceUnit(unit)`
- 3 callsites. Example: `UI/InGame/CityBannerManager.lua:1076`

### SetRepeatActionPlayer
- `UI.SetRepeatActionPlayer(ePlayer)`
- 14 callsites. Example: `UI/InGame/CityBannerManager.lua:1094`

### SetResourceVisibleMode
- `UI.SetResourceVisibleMode(mapOptions.ShowResources)`
- `UI.SetResourceVisibleMode(bIsChecked)`
- 4 callsites. Example: `UI/InGame/WorldView/MiniMapPanel.lua:119`

### SetYieldVisibleMode
- `UI.SetYieldVisibleMode(mapOptions.ShowYield)`
- `UI.SetYieldVisibleMode(bIsChecked)`
- 4 callsites. Example: `UI/InGame/WorldView/MiniMapPanel.lua:118`

### ShiftKeyDown
- `UI:ShiftKeyDown()`
- 3 callsites. Example: `UI/InGame/InGame.lua:74`

### ToggleGridVisibleMode
- `UI.ToggleGridVisibleMode()`
- 3 callsites. Example: `UI/InGame/InGame.lua:102`

### UnlockAchievement
- `UI.UnlockAchievement("ACHIEVEMENT_XP2_55")`
- `UI.UnlockAchievement("ACHIEVEMENT_SCENARIO_02_ROUTE_TO_ORIENT")`
- `UI.UnlockAchievement("ACHIEVEMENT_SCENARIO_02_RETURN_TREASURE")`
- `UI.UnlockAchievement("ACHIEVEMENT_XP2_60")`
- `UI.UnlockAchievement("ACHIEVEMENT_XP1_44")`
- ...and 9 more distinct call shapes
- 19 callsites. Example: `DLC/Expansion2/Scenarios/ScrambleAfricaScenario/TurnsRemaining.lua:593`

### UpdateCityScreen
- `UI.UpdateCityScreen()`
- 3 callsites. Example: `UI/InGame/CityView/CityView.lua:1724`

### WaitingForRemotePlayers
- `UI.WaitingForRemotePlayers()`
- 3 callsites. Example: `UI/InGame/WorldView/ActionInfoPanel.lua:403`
