# Network

Multiplayer networking. Static table.

Extracted from 227 call sites across 69 distinct methods in the shipped game Lua.

## Methods

### BroadcastGameSettings
- `Network.BroadcastGameSettings()`
- 1 callsite. Example: `UI/FrontEnd/Multiplayer/GameSetup/MPGameOptions.lua:246`

### BroadcastPlayerInfo
- `Network.BroadcastPlayerInfo()`
- 8 callsites. Example: `UI/FrontEnd/Multiplayer/StagingRoom.lua:321`

### GetDebugLogLevel
- `Network.GetDebugLogLevel()`
- 1 callsite. Example: `UI/InGame/NetworkDebug.lua:93`

### GetLocalTurnSliceInfo
- `Network.GetLocalTurnSliceInfo()`
- 1 callsite. Example: `UI/InGame/NetworkDebug.lua:39`

### GetMapRandSeed
- `Network.GetMapRandSeed()`
- 1 callsite. Example: `UI/InGame/DebugMenu.lua:9`

### GetPingTime
- `Network.GetPingTime(playerID)`
- 2 callsites. Example: `UI/InGame/WorldView/MPList.lua:86`

### GetPlayerDesiredSlot
- `Network.GetPlayerDesiredSlot(Matchmaking.GetLocalID())`
- `Network.GetPlayerDesiredSlot(playerID)`
- 2 callsites. Example: `UI/FrontEnd/Multiplayer/StagingRoom.lua:819`

### GetPlayerTurnSliceInfo
- `Network.GetPlayerTurnSliceInfo(i - 1)`
- 1 callsite. Example: `UI/InGame/NetworkDebug.lua:29`

### GetSynchRandSeed
- `Network.GetSynchRandSeed()`
- 1 callsite. Example: `UI/InGame/DebugMenu.lua:8`

### GetTurnSliceMaxMessageCount
- `Network.GetTurnSliceMaxMessageCount()`
- 5 callsites. Example: `UI/InGame/NetworkDebug.lua:49`

### HasReconnectCache
- `Network.HasReconnectCache()`
- 2 callsites. Example: `UI/FrontEnd/Modding/ModsMultiplayer.lua:94`

### HasSentNetTurnAllComplete
- `Network.HasSentNetTurnAllComplete()`
- 3 callsites. Example: `UI/InGame/WorldView/ActionInfoPanel.lua:242`

### HasSentNetTurnComplete
- `Network.HasSentNetTurnComplete()`
- 12 callsites. Example: `UI/InGame/WorldView/ActionInfoPanel.lua:111`

### IsConnectedToSteam
- `Network.IsConnectedToSteam()`
- 2 callsites. Example: `UI/FrontEnd/Modding/ModsMultiplayer.lua:87`

### IsDedicatedServer
- `Network.IsDedicatedServer()`
- 10 callsites. Example: `UI/FrontEnd/LoadMenu.lua:69`

### IsEveryoneConnected
- `Network.IsEveryoneConnected()`
- 4 callsites. Example: `UI/FrontEnd/Multiplayer/StagingRoom.lua:221`

### IsPlayerConnected
- `Network.IsPlayerConnected(playerID)`
- `Network.IsPlayerConnected(pPlayer:GetID())`
- 12 callsites. Example: `UI/FrontEnd/Multiplayer/StagingRoom.lua:484`

### IsPlayerHotJoining
- `Network.IsPlayerHotJoining(pPlayer:GetID())`
- `Network.IsPlayerHotJoining(Matchmaking.GetLocalID())`
- `Network.IsPlayerHotJoining(playerID)`
- 3 callsites. Example: `UI/InGame/WorldView/MPList.lua:248`

### IsPlayerKicked
- `Network.IsPlayerKicked(Game.GetActivePlayer())`
- `Network.IsPlayerKicked(playerID)`
- 4 callsites. Example: `UI/InGame/InGame.lua:1100`

### Reconnect
- `Network.Reconnect()`
- 2 callsites. Example: `UI/FrontEnd/Modding/ModsMultiplayer.lua:49`

### SendArchaeologyChoice
- `Network.SendArchaeologyChoice(Game.GetActivePlayer(), g_iUnitIndex, g_iChoice)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseArchaeologyPopup.lua:359`

### SendBarbarianRansom
- `Network.SendBarbarianRansom(0, iUnitID)`
- `Network.SendBarbarianRansom(1, iUnitID)`
- 2 callsites. Example: `UI/InGame/PopupsGeneric/BarbarianRansomPopup.lua:23`

### SendChangeIdeology
- `Network.SendChangeIdeology()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/SocialPolicyPopup.lua:1264`

### SendChangeWar
- `Network.SendChangeWar(eRivalTeam, true)`
- `Network.SendChangeWar(g_WarTarget, true)`
- `Network.SendChangeWar(g_iMinorCivTeamID, false)`
- `Network.SendChangeWar(g_iMinorCivTeamID, true)`
- 15 callsites. Example: `UI/InGame/PopupsGeneric/DeclareWarMovePopup.lua:71`

### SendChat
- `Network.SendChat(text, g_iChatTeam, g_iChatPlayer)`
- `Network.SendChat(text)`
- 5 callsites. Example: `UI/InGame/WorldView/DiploCorner.lua:193`

### SendCityBuyPlot
- `Network.SendCityBuyPlot(pHeadSelectedCity:GetID(), plotX, plotY)`
- 3 callsites. Example: `UI/InGame/CityView/CityView.lua:1723`

### SendDiploVote
- `Network.SendDiploVote(iVotePlayer)`
- 4 callsites. Example: `UI/InGame/Popups/DiploVotePopup.lua:12`

### SendDoTask
- `Network.SendDoTask(pCity:GetID(), TaskTypes.TASK_CHANGE_WORKING_PLOT, 0, -1, false, bAlt, bShift, bCtrl)`
- `Network.SendDoTask(cityID, TaskTypes.TASK_ANNEX_PUPPET, -1, -1, false, false, false, false)`
- `Network.SendDoTask(pCity:GetID(), TaskTypes.TASK_CHANGE_WORKING_PLOT, iPlotIndex, -1, false, bAlt, bShift, bCtrl)`
- `Network.SendDoTask(pCity:GetID(), TaskTypes.TASK_UNRAZE, -1, -1, false, false, false, false)`
- `Network.SendDoTask(cityID, TaskTypes.TASK_CREATE_PUPPET, -1, -1, false, false, false, false)`
- ...and 4 more distinct call shapes
- 24 callsites. Example: `UI/InGame/CityView/CityView.lua:237`

### SendEnhanceReligion
- `Network.SendEnhanceReligion(Game.GetActivePlayer(), g_CurrentReligionID, customName, g_Beliefs[4], g_Beliefs[5], g_iCityX, g_iCityY)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseReligionPopup.lua:622`

### SendExtendedGame
- `Network.SendExtendedGame()`
- 1 callsite. Example: `UI/InGame/Popups/EndGameMenu.lua:59`

### SendFaithGreatPersonChoice
- `Network.SendFaithGreatPersonChoice(playerID, unit.ID)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseFaithGreatPerson.lua:128`

### SendFaithPurchase
- `Network.SendFaithPurchase(Game.GetActivePlayer(), v1, v2)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ReligionOverview.lua:425`

### SendFoundPantheon
- `Network.SendFoundPantheon(Game.GetActivePlayer(), g_BeliefID)`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ChoosePantheonPopup.lua:163`

### SendFoundReligion
- `Network.SendFoundReligion(Game.GetActivePlayer(), g_CurrentReligionID, customName, beliefsToSend[1], beliefsToSend[2], beliefsToSend[3], beliefsToSend[4], g_iCityX, g_iCityY)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseReligionPopup.lua:620`

### SendGameOptions
- `Network.SendGameOptions(options)`
- 1 callsite. Example: `UI/Options/OptionsMenu.lua:122`

### SendGiftUnit
- `Network.SendGiftUnit(iGiftedPlayer, iUnitIndex)`
- 1 callsite. Example: `UI/InGame/PopupsGeneric/ConfirmGiftPopup.lua:36`

### SendGoodyChoice
- `Network.SendGoodyChoice(playerID, pPlot:GetX(), pPlot:GetY(), iGoodyType, pUnit:GetID())`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseGoodyHutReward.lua:89`

### SendGreatPersonChoice
- `Network.SendGreatPersonChoice(playerID, unit.ID)`
- 3 callsites. Example: `UI/InGame/Popups/ChooseFreeItem.lua:99`

### SendIdeologyChoice
- `Network.SendIdeologyChoice(Game.GetActivePlayer(), g_iChoice)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseIdeologyPopup.lua:263`

### SendIgnoreWarning
- `Network.SendIgnoreWarning(eOtherTeam)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/DeclareWarPopup.lua:639`

### SendLeagueEditName
- `Network.SendLeagueEditName(m_iCurrentLeague, Game.GetActivePlayer(), name)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:993`

### SendLeagueProposeEnact
- `Network.SendLeagueProposeEnact(controller.LeagueId, proposal.Type, controller.ActivePlayerId, choice)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:1565`

### SendLeagueProposeRepeal
- `Network.SendLeagueProposeRepeal(controller.LeagueId, proposal.Id, controller.ActivePlayerId)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:1567`

### SendLeagueVoteAbstain
- `Network.SendLeagueVoteAbstain(controller.LeagueId, controller.ActivePlayerId, controller.VotesAvailable)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:1139`

### SendLeagueVoteEnact
- `Network.SendLeagueVoteEnact(controller.LeagueId, entry.ResolutionId, controller.ActivePlayerId, votes, choice)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:1131`

### SendLeagueVoteRepeal
- `Network.SendLeagueVoteRepeal(controller.LeagueId, entry.ResolutionId, controller.ActivePlayerId, votes, choice)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:1133`

### SendLiberateMinor
- `Network.SendLiberateMinor(iLiberatedPlayer, cityID)`
- `Network.SendLiberateMinor(eMinor, iCityID)`
- 4 callsites. Example: `UI/InGame/PopupsGeneric/PuppetCityPopup.lua:47`

### SendMayaBonusChoice
- `Network.SendMayaBonusChoice(playerID, unit.ID)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseMayaBonus.lua:105`

### SendMinorCivEnterTerritory
- `Network.SendMinorCivEnterTerritory(eRivalTeam)`
- 1 callsite. Example: `UI/InGame/PopupsGeneric/MinorCivEnterTerritoryPopup.lua:23`

### SendMinorNoUnitSpawning
- `Network.SendMinorNoUnitSpawning(g_iMinorCivID, not bSpawningDisabled)`
- 3 callsites. Example: `UI/InGame/Popups/CityStateDiploPopup.lua:603`

### SendMoveGreatWorks
- `Network.SendMoveGreatWorks(activePlayerID, g_CurrentGreatWorkSlot.CityID, g_CurrentGreatWorkSlot.BuildingClassID, g_CurrentGreatWorkSlot.GreatWorkSlotIndex, selectionPoint.CityID, selectionPoint.BuildingClassID, selectionPoint.GreatWorkSlotIndex)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/CultureOverview.lua:1105`

### SendMoveSpy
- `Network.SendMoveSpy(Game.GetActivePlayer(), selectedAgentIndex, v.PlayerID, v.CityID, false)`
- `Network.SendMoveSpy(Game.GetActivePlayer(), selectedAgentIndex, v.PlayerID, v.CityID)`
- `Network.SendMoveSpy(Game.GetActivePlayer(), g_SelectedAgentID, -1, -1, false)`
- `Network.SendMoveSpy(Game.GetActivePlayer(), selectedAgentIndex, v.PlayerID, v.CityID, true)`
- `Network.SendMoveSpy(Game.GetActivePlayer(), g_SelectedAgentID, -1, -1)`
- 8 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/EspionageOverview.lua:1096`

### SendPledgeMinorProtection
- `Network.SendPledgeMinorProtection(g_iMinorCivID, true)`
- `Network.SendPledgeMinorProtection(g_iMinorCivID, false)`
- 2 callsites. Example: `UI/InGame/Popups/CityStateDiploPopup.lua:626`

### SendRenameCity
- `Network.SendRenameCity(pCity:GetID(), Controls.EditCityName:GetText())`
- 1 callsite. Example: `UI/InGame/Popups/SetCityName.lua:20`

### SendRenameUnit
- `Network.SendRenameUnit(pUnit:GetID(), Controls.EditUnitName:GetText())`
- 1 callsite. Example: `UI/InGame/Popups/SetUnitName.lua:20`

### SendResearch
- `Network.SendResearch(eTech, player:GetNumFreeTechs(), -1, UIManager:GetShift())`
- `Network.SendResearch(eTech, 0, iValue, false)`
- `Network.SendResearch(eTech, iValue, -1, false)`
- `Network.SendResearch(eTech, 0, stealingTechTargetPlayerID, UIManager:GetShift())`
- `Network.SendResearch(eTech, iDiscover, -1, false)`
- 10 callsites. Example: `UI/InGame/TechTree/TechTree.lua:436`

### SendReturnCivilian
- `Network.SendReturnCivilian(true, iGiftedPlayer, iUnitIndex)`
- `Network.SendReturnCivilian(false, iGiftedPlayer, iUnitIndex)`
- 2 callsites. Example: `UI/InGame/PopupsGeneric/ReturnCivilianPopup.lua:48`

### SendSellBuilding
- `Network.SendSellBuilding(pCity:GetID(), g_iBuildingToSell)`
- 3 callsites. Example: `UI/InGame/CityView/CityView.lua:2404`

### SendSetCityAIFocus
- `Network.SendSetCityAIFocus(pCity:GetID(), focus)`
- 3 callsites. Example: `UI/InGame/CityView/CityView.lua:2285`

### SendSetCityAvoidGrowth
- `Network.SendSetCityAvoidGrowth(pCity:GetID(), not pCity:IsForcedAvoidGrowth())`
- 3 callsites. Example: `UI/InGame/CityView/CityView.lua:2315`

### SendSetSwappableGreatWork
- `Network.SendSetSwappableGreatWork(activePlayerID, workType, index)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/CultureOverview.lua:1456`

### SendStageCoup
- `Network.SendStageCoup(Game.GetActivePlayer(), v.AgentID)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/EspionageOverview.lua:756`

### SendSwapGreatWorks
- `Network.SendSwapGreatWorks(activePlayerID, g_iYourItem, g_iTradingPartner, g_iTheirItem)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/CultureOverview.lua:1393`

### SendTurnUnready
- `Network.SendTurnUnready()`
- 3 callsites. Example: `UI/InGame/WorldView/ActionInfoPanel.lua:112`

### SendUpdateCityCitizens
- `Network.SendUpdateCityCitizens(pCity:GetID())`
- 3 callsites. Example: `UI/InGame/CityView/CityView.lua:1688`

### SendUpdatePolicies
- `Network.SendUpdatePolicies(m_gPolicyID, m_gAdoptingPolicy, true)`
- `Network.SendUpdatePolicies(g_SelectedTenet, true, true)`
- `Network.SendUpdatePolicies(iNewPolicyBranch, bPolicy, true)`
- 9 callsites. Example: `UI/InGame/Popups/SocialPolicyPopup.lua:918`

### SetDebugLogLevel
- `Network.SetDebugLogLevel(2)`
- `Network.SetDebugLogLevel(1)`
- 2 callsites. Example: `UI/InGame/NetworkDebug.lua:56`

### SetPlayerDesiredSlot
- `Network.SetPlayerDesiredSlot(playerID)`
- 1 callsite. Example: `UI/FrontEnd/Multiplayer/StagingRoom.lua:372`

### SetTurnSliceMaxMessageCount
- `Network.SetTurnSliceMaxMessageCount(Network.GetTurnSliceMaxMessageCount() - 1)`
- `Network.SetTurnSliceMaxMessageCount(Network.GetTurnSliceMaxMessageCount() + 1)`
- 2 callsites. Example: `UI/InGame/NetworkDebug.lua:66`
