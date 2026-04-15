# PreGame

Pre-game / setup-screen state (picked civ, map settings, players). Static table.

Extracted from 1108 call sites across 87 distinct methods in the shipped game Lua.

## Methods

### CanReadyLocalPlayer
- `PreGame.CanReadyLocalPlayer()`
- 1 callsite. Example: `UI/FrontEnd/Multiplayer/StagingRoom.lua:636`

### GameStarted
- `PreGame.GameStarted()`
- 18 callsites. Example: `UI/TurnStatusBehavior.lua:37`

### GetCivilization
- `PreGame.GetCivilization(playerID)`
- `PreGame.GetCivilization(0)`
- `PreGame.GetCivilization()`
- `PreGame.GetCivilization(i)`
- `PreGame.GetCivilization(Game:GetActivePlayer())`
- ...and 2 more distinct call shapes
- 28 callsites. Example: `UI/IconSupport.lua:144`

### GetCivilizationAdjective
- `PreGame.GetCivilizationAdjective(g_EditSlot)`
- 1 callsite. Example: `UI/FrontEnd/GameSetup/SetCivNames.lua:235`

### GetCivilizationColor
- `PreGame.GetCivilizationColor(playerID)`
- 1 callsite. Example: `UI/IconSupport.lua:155`

### GetCivilizationDescription
- `PreGame.GetCivilizationDescription(iPlayer)`
- `PreGame.GetCivilizationDescription(0)`
- `PreGame.GetCivilizationDescription(g_EditSlot)`
- 6 callsites. Example: `UI/InGame/Menus/SaveMenu.lua:100`

### GetCivilizationPackageTextKey
- `PreGame.GetCivilizationPackageTextKey(playerID)`
- 1 callsite. Example: `UI/FrontEnd/Multiplayer/StagingRoom.lua:629`

### GetCivilizationShortDescription
- `PreGame.GetCivilizationShortDescription(pPlayer:GetID())`
- `PreGame.GetCivilizationShortDescription(g_iPlayer)`
- `PreGame.GetCivilizationShortDescription(0)`
- `PreGame.GetCivilizationShortDescription(g_EditSlot)`
- `PreGame.GetCivilizationShortDescription(playerID)`
- 40 callsites. Example: `UI/InGame/Popups/VictoryProgress.lua:401`

### GetEra
- `PreGame.GetEra()`
- 12 callsites. Example: `UI/InGame/Menus/GameMenu.lua:306`

### GetFileHeader
- `PreGame.GetFileHeader(thisLoadFile, true)`
- `PreGame.GetFileHeader(thisLoadFile)`
- `PreGame.GetFileHeader(g_FileList[g_iSelected])`
- `PreGame.GetFileHeader(entry.FileName)`
- 4 callsites. Example: `UI/FrontEnd/LoadMenu.lua:53`

### GetGameOption
- `PreGame.GetGameOption(option.Type)`
- `PreGame.GetGameOption("GAMEOPTION_PITBOSS")`
- `PreGame.GetGameOption("GAMEOPTION_NO_EXTENDED_PLAY")`
- `PreGame.GetGameOption("GAMEOPTION_END_TURN_TIMER_ENABLED")`
- `PreGame.GetGameOption(GameOptionTypes.GAMEOPTION_LOCK_MODS)`
- ...and 2 more distinct call shapes
- 15 callsites. Example: `UI/InGame/Menus/GameMenu.lua:385`

### GetGameSpeed
- `PreGame.GetGameSpeed()`
- 11 callsites. Example: `UI/FrontEnd/SinglePlayer.lua:84`

### GetGameType
- `PreGame.GetGameType()`
- 5 callsites. Example: `UI/InGame/Menus/SaveMenu.lua:100`

### GetHandicap
- `PreGame.GetHandicap(0)`
- `PreGame.GetHandicap()`
- `PreGame.GetHandicap(Game.GetActivePlayer())`
- `PreGame.GetHandicap(playerID)`
- `PreGame.GetHandicap(Matchmaking.GetLocalID())`
- 11 callsites. Example: `UI/FrontEnd/SinglePlayer.lua:78`

### GetLeaderName
- `PreGame.GetLeaderName(g_iPlayer)`
- `PreGame.GetLeaderName(Game.GetActivePlayer())`
- `PreGame.GetLeaderName(0)`
- `PreGame.GetLeaderName(iPlayer)`
- `PreGame.GetLeaderName(playerID)`
- ...and 2 more distinct call shapes
- 30 callsites. Example: `UI/InGame/DiploList.lua:232`

### GetLoadFileName
- `PreGame.GetLoadFileName()`
- 13 callsites. Example: `UI/FrontEnd/Multiplayer/StagingRoom.lua:715`

### GetLoadWBScenario
- `PreGame.GetLoadWBScenario()`
- 15 callsites. Example: `UI/InGame/Menus/GameMenu.lua:165`

### GetMapOption
- `PreGame.GetMapOption(option.ID)`
- 4 callsites. Example: `UI/FrontEnd/GameSetup/AdvancedSetup.lua:127`

### GetMapScript
- `PreGame.GetMapScript()`
- 36 callsites. Example: `UI/FrontEnd/SinglePlayer.lua:44`

### GetMaxTurns
- `PreGame.GetMaxTurns()`
- 4 callsites. Example: `UI/FrontEnd/GameSetup/AdvancedSetup.lua:1074`

### GetMultiplayerAIEnabled
- `PreGame.GetMultiplayerAIEnabled()`
- 2 callsites. Example: `UI/FrontEnd/Multiplayer/StagingRoom.lua:510`

### GetNickName
- `PreGame.GetNickName(playerID)`
- `PreGame.GetNickName(i-1)`
- `PreGame.GetNickName(eActivePlayer)`
- `PreGame.GetNickName(g_EditSlot)`
- 5 callsites. Example: `UI/FrontEnd/Multiplayer/StagingRoom.lua:457`

### GetNumMinorCivs
- `PreGame.GetNumMinorCivs()`
- 9 callsites. Example: `UI/FrontEnd/GameSetup/AdvancedSetup.lua:1103`

### GetPassword
- `PreGame.GetPassword(g_EditSlot)`
- 1 callsite. Example: `UI/FrontEnd/GameSetup/SetCivNames.lua:246`

### GetPitbossTurnTime
- `PreGame.GetPitbossTurnTime()`
- 2 callsites. Example: `UI/FrontEnd/Multiplayer/StagingRoom.lua:1428`

### GetQuickCombat
- `PreGame.GetQuickCombat()`
- 2 callsites. Example: `UI/Options/OptionsMenu.lua:114`

### GetQuickMovement
- `PreGame.GetQuickMovement()`
- 2 callsites. Example: `UI/Options/OptionsMenu.lua:118`

### GetSlotClaim
- `PreGame.GetSlotClaim(playerID)`
- `PreGame.GetSlotClaim(pPlayer:GetID())`
- `PreGame.GetSlotClaim(i)`
- 11 callsites. Example: `UI/FrontEnd/Multiplayer/StagingRoom.lua:674`

### GetSlotStatus
- `PreGame.GetSlotStatus(playerID)`
- `PreGame.GetSlotStatus(i)`
- `PreGame.GetSlotStatus(Matchmaking.GetLocalID())`
- `PreGame.GetSlotStatus(Game.GetActivePlayer())`
- `PreGame.GetSlotStatus(i-1)`
- 45 callsites. Example: `UI/FrontEnd/Multiplayer/StagingRoom.lua:492`

### GetTeam
- `PreGame.GetTeam(playerID)`
- `PreGame.GetTeam(i)`
- `PreGame.GetTeam(0)`
- `PreGame.GetTeam(Matchmaking.GetLocalID())`
- 11 callsites. Example: `UI/FrontEnd/GameSetup/AdvancedSetup.lua:1156`

### GetWorldSize
- `PreGame.GetWorldSize()`
- 20 callsites. Example: `UI/FrontEnd/SinglePlayer.lua:70`

### HasPassword
- `PreGame.HasPassword(Game.GetActivePlayer())`
- `PreGame.HasPassword(ePlayer)`
- 2 callsites. Example: `UI/InGame/ChangePassword.lua:107`

### IsCivilizationKeyAvailable
- `PreGame.IsCivilizationKeyAvailable(playerID)`
- 1 callsite. Example: `UI/FrontEnd/Multiplayer/StagingRoom.lua:617`

### IsDLCAllowed
- `PreGame.IsDLCAllowed(row.PackageID)`
- 1 callsite. Example: `UI/FrontEnd/Multiplayer/GameSetup/MPGameOptions.lua:1158`

### IsHotSeatGame
- `PreGame.IsHotSeatGame()`
- 60 callsites. Example: `UI/FrontEnd/LoadMenu.lua:76`

### IsInternetGame
- `PreGame.IsInternetGame()`
- 15 callsites. Example: `UI/FrontEnd/LoadMenu.lua:73`

### IsMultiplayerGame
- `PreGame.IsMultiplayerGame()`
- 62 callsites. Example: `UI/FrontEnd/LoadScreen.lua:49`

### IsPrivateGame
- `PreGame.IsPrivateGame()`
- 2 callsites. Example: `UI/FrontEnd/Multiplayer/StagingRoom.lua:1522`

### IsRandomMapScript
- `PreGame.IsRandomMapScript()`
- 20 callsites. Example: `UI/FrontEnd/SinglePlayer.lua:43`

### IsRandomWorldSize
- `PreGame.IsRandomWorldSize()`
- 7 callsites. Example: `UI/FrontEnd/SinglePlayer.lua:69`

### IsReady
- `PreGame.IsReady(m_HostID)`
- `PreGame.IsReady(playerID)`
- `PreGame.IsReady(Matchmaking.GetLocalID())`
- 14 callsites. Example: `UI/FrontEnd/Multiplayer/StagingRoom.lua:701`

### IsVictory
- `PreGame.IsVictory(GameInfo.Victories["VICTORY_SPACE_RACE"].ID)`
- `PreGame.IsVictory(GameInfo.Victories["VICTORY_DIPLOMATIC"].ID)`
- `PreGame.IsVictory(GameInfo.Victories["VICTORY_TIME"].ID)`
- `PreGame.IsVictory(GameInfo.Victories["VICTORY_CULTURAL"].ID)`
- `PreGame.IsVictory(GameInfo.Victories["VICTORY_DOMINATION"].ID)`
- ...and 3 more distinct call shapes
- 38 callsites. Example: `UI/InGame/Popups/VictoryProgress.lua:296`

### LoadPreGameSettings
- `PreGame.LoadPreGameSettings()`
- 3 callsites. Example: `UI/FrontEnd/MainMenu.lua:31`

### RandomizeMapSeed
- `PreGame.RandomizeMapSeed()`
- 6 callsites. Example: `DLC/Expansion/Scenarios/MedievalScenario/MedievalScenarioLoadScreen.lua:108`

### ReadActiveSlotCountFromSaveGame
- `PreGame.ReadActiveSlotCountFromSaveGame()`
- 4 callsites. Example: `UI/FrontEnd/LoadMenu.lua:71`

### Reset
- `PreGame.Reset()`
- 14 callsites. Example: `UI/FrontEnd/ScenariosMenu.lua:46`

### ResetGameOptions
- `PreGame.ResetGameOptions()`
- 5 callsites. Example: `UI/FrontEnd/LoadTutorial.lua:99`

### ResetMapOptions
- `PreGame.ResetMapOptions()`
- 5 callsites. Example: `UI/FrontEnd/LoadTutorial.lua:100`

### ResetSlots
- `PreGame.ResetSlots()`
- 17 callsites. Example: `UI/FrontEnd/LoadTutorial.lua:148`

### SetCivilization
- `PreGame.SetCivilization(0, GameInfo.Civilizations[ScenarioCivilizations[playerIndex]].ID)`
- `PreGame.SetCivilization(playerIndex, GameInfo.Civilizations[ScenarioCivilizations[0]].ID)`
- `PreGame.SetCivilization(0, -1)`
- `PreGame.SetCivilization(i, -1)`
- `PreGame.SetCivilization(i, GameInfo.Civilizations[ScenarioCivilizations[i]].ID)`
- ...and 13 more distinct call shapes
- 40 callsites. Example: `DLC/Expansion/Scenarios/MedievalScenario/MedievalScenarioLoadScreen.lua:103`

### SetCivilizationAdjective
- `PreGame.SetCivilizationAdjective(0, "")`
- `PreGame.SetCivilizationAdjective(playerID, "")`
- `PreGame.SetCivilizationAdjective(g_EditSlot, Controls.EditCivAdjective:GetText())`
- `PreGame.SetCivilizationAdjective(Matchmaking.GetLocalID(), "")`
- 8 callsites. Example: `UI/FrontEnd/GameSetup/AdvancedSetup.lua:1287`

### SetCivilizationDescription
- `PreGame.SetCivilizationDescription(0, "")`
- `PreGame.SetCivilizationDescription(playerID, "")`
- `PreGame.SetCivilizationDescription(g_EditSlot, Controls.EditCivName:GetText())`
- `PreGame.SetCivilizationDescription(Matchmaking.GetLocalID(), "")`
- 8 callsites. Example: `UI/FrontEnd/GameSetup/AdvancedSetup.lua:1285`

### SetCivilizationShortDescription
- `PreGame.SetCivilizationShortDescription(0, "")`
- `PreGame.SetCivilizationShortDescription(playerID, "")`
- `PreGame.SetCivilizationShortDescription(g_EditSlot, Controls.EditCivShortName:GetText())`
- `PreGame.SetCivilizationShortDescription(Matchmaking.GetLocalID(), "")`
- 8 callsites. Example: `UI/FrontEnd/GameSetup/AdvancedSetup.lua:1286`

### SetDLCAllowed
- `PreGame.SetDLCAllowed(row.PackageID, bCheck)`
- `PreGame.SetDLCAllowed(row.PackageID, true)`
- 2 callsites. Example: `UI/FrontEnd/Multiplayer/GameSetup/MPGameOptions.lua:1162`

### SetEarthMap
- `PreGame.SetEarthMap(false)`
- 4 callsites. Example: `DLC/Expansion/Scenarios/SteampunkScenario/SteampunkScenarioLoadScreen.lua:89`

### SetEra
- `PreGame.SetEra(wb.StartEra)`
- `PreGame.SetEra(0)`
- `PreGame.SetEra(id)`
- `PreGame.SetEra(2)`
- `PreGame.SetEra(era.ID)`
- ...and 2 more distinct call shapes
- 12 callsites. Example: `UI/FrontEnd/GameSetup/AdvancedSetup.lua:685`

### SetGameOption
- `PreGame.SetGameOption("GAMEOPTION_NO_EXTENDED_PLAY", true)`
- `PreGame.SetGameOption("GAMEOPTION_NO_TUTORIAL", true)`
- `PreGame.SetGameOption("GAMEOPTION_SIMULTANEOUS_TURNS", false)`
- `PreGame.SetGameOption("GAMEOPTION_DYNAMIC_TURNS", false)`
- `PreGame.SetGameOption("GAMEOPTION_PITBOSS", true)`
- ...and 8 more distinct call shapes
- 36 callsites. Example: `DLC/Expansion2/Scenarios/CivilWarScenario/TurnsRemaining.lua:106`

### SetGameSpeed
- `PreGame.SetGameSpeed(3)`
- `PreGame.SetGameSpeed(id)`
- `PreGame.SetGameSpeed(wb.DefaultSpeed)`
- `PreGame.SetGameSpeed(GameInfo.GameSpeeds["GAMESPEED_STANDARD"].ID)`
- `PreGame.SetGameSpeed(2)`
- ...and 2 more distinct call shapes
- 20 callsites. Example: `UI/FrontEnd/Multiplayer/GameSetup/MPGameDefaults.lua:35`

### SetGameType
- `PreGame.SetGameType(GameTypes.GAME_NETWORK_MULTIPLAYER)`
- `PreGame.SetGameType(GameTypes.GAME_HOTSEAT_MULTIPLAYER)`
- `PreGame.SetGameType(GAME_SINGLE_PLAYER)`
- `PreGame.SetGameType(GameTypes.GAME_SINGLE_PLAYER)`
- `PreGame.SetGameType(eGameType)`
- 11 callsites. Example: `UI/FrontEnd/Modding/ModsMultiplayer.lua:13`

### SetHandicap
- `PreGame.SetHandicap(0, g_CurrentDifficulty)`
- `PreGame.SetHandicap(playerID, 1)`
- `PreGame.SetHandicap(0, id)`
- `PreGame.SetHandicap(0, 0)`
- `PreGame.SetHandicap(0, handicap.ID)`
- ...and 5 more distinct call shapes
- 27 callsites. Example: `DLC/Expansion2/Scenarios/CivilWarScenario/CivilWarScenarioLoadScreen.lua:58`

### SetInternetGame
- `PreGame.SetInternetGame(false)`
- `PreGame.SetInternetGame(true)`
- `PreGame.SetInternetGame(bIsInternet)`
- 8 callsites. Example: `UI/FrontEnd/Modding/ModsMultiplayer.lua:26`

### SetLeaderName
- `PreGame.SetLeaderName(0, "")`
- `PreGame.SetLeaderName(playerID, "")`
- `PreGame.SetLeaderName(g_EditSlot, Controls.EditCivLeader:GetText())`
- `PreGame.SetLeaderName(Matchmaking.GetLocalID(), "")`
- 8 callsites. Example: `UI/FrontEnd/GameSetup/AdvancedSetup.lua:1284`

### SetLeaderType
- `PreGame.SetLeaderType(12, GameInfo.Leaders["LEADER_GENGHIS_KHAN"].ID)`
- 1 callsite. Example: `DLC/Expansion/Scenarios/MedievalScenario/MedievalScenarioLoadScreen.lua:118`

### SetLoadFileName
- `PreGame.SetLoadFileName(thisLoadFile, true)`
- `PreGame.SetLoadFileName(thisLoadFile)`
- `PreGame.SetLoadFileName("")`
- 3 callsites. Example: `UI/FrontEnd/LoadMenu.lua:52`

### SetLoadWBScenario
- `PreGame.SetLoadWBScenario(false)`
- `PreGame.SetLoadWBScenario(true)`
- `PreGame.SetLoadWBScenario(PreGame.GetLoadWBScenario())`
- `PreGame.SetLoadWBScenario(not PreGame.GetLoadWBScenario())`
- 29 callsites. Example: `UI/FrontEnd/GameSetup/AdvancedSetup.lua:888`

### SetMapOption
- `PreGame.SetMapOption(option.ID, possibleValue.Value)`
- `PreGame.SetMapOption(option.ID, bCheck)`
- 4 callsites. Example: `UI/FrontEnd/GameSetup/AdvancedSetup.lua:122`

### SetMapScript
- `PreGame.SetMapScript(scenarioMap.EvaluatedPath)`
- `PreGame.SetMapScript(row.FileName)`
- `PreGame.SetMapScript(mapScript.FileName)`
- `PreGame.SetMapScript(g_CurrentMap)`
- `PreGame.SetMapScript(file.EvaluatedPath)`
- ...and 10 more distinct call shapes
- 30 callsites. Example: `DLC/Expansion2/Scenarios/CivilWarScenario/CivilWarScenarioLoadScreen.lua:54`

### SetMaxTurns
- `PreGame.SetMaxTurns(0)`
- `PreGame.SetMaxTurns(wb.MaxTurns)`
- `PreGame.SetMaxTurns(Controls.MaxTurnsEdit:GetText())`
- `PreGame.SetMaxTurns(100)`
- `PreGame.SetMaxTurns(200)`
- ...and 1 more distinct call shapes
- 13 callsites. Example: `UI/FrontEnd/GameSetup/AdvancedSetup.lua:1060`

### SetNickName
- `PreGame.SetNickName(playerID, "")`
- `PreGame.SetNickName(playerID, Locale.ConvertTextKey( "TXT_KEY_MULTIPLAYER_DEFAULT_PLAYER_NAME", playerID + 1 ))`
- `PreGame.SetNickName(g_EditSlot, Controls.EditNickName:GetText())`
- 6 callsites. Example: `UI/FrontEnd/Multiplayer/StagingRoom.lua:454`

### SetNumMinorCivs
- `PreGame.SetNumMinorCivs(world.DefaultMinorCivs)`
- `PreGame.SetNumMinorCivs(wb.CityStateCount)`
- `PreGame.SetNumMinorCivs(-1)`
- `PreGame.SetNumMinorCivs(worldSize.DefaultMinorCivs)`
- `PreGame.SetNumMinorCivs(8)`
- ...and 9 more distinct call shapes
- 28 callsites. Example: `UI/FrontEnd/GameSetup/AdvancedSetup.lua:672`

### SetOverrideScenarioHandicap
- `PreGame.SetOverrideScenarioHandicap(true)`
- 10 callsites. Example: `UI/FrontEnd/GameSetup/GameSetupScreen.lua:28`

### SetPassword
- `PreGame.SetPassword(ePlayer, Controls.NewPasswordEditBox:GetText(), Controls.OldPasswordEditBox:GetText())`
- `PreGame.SetPassword(g_EditSlot, Controls.EditPassword:GetText())`
- `PreGame.SetPassword(g_EditSlot, "")`
- 3 callsites. Example: `UI/InGame/ChangePassword.lua:12`

### SetPersistSettings
- `PreGame.SetPersistSettings(false)`
- `PreGame.SetPersistSettings(true)`
- `PreGame.SetPersistSettings(not bIsModding)`
- 5 callsites. Example: `UI/FrontEnd/LoadTutorial.lua:97`

### SetPitbossTurnTime
- `PreGame.SetPitbossTurnTime(Controls.TurnTimerEdit:GetText())`
- 1 callsite. Example: `UI/FrontEnd/Multiplayer/GameSetup/MPGameOptions.lua:865`

### SetPlayerColor
- `PreGame.SetPlayerColor(12, GameInfo.PlayerColors["PLAYERCOLOR_MONGOL"].ID)`
- 1 callsite. Example: `DLC/Expansion/Scenarios/MedievalScenario/MedievalScenarioLoadScreen.lua:117`

### SetPrivateGame
- `PreGame.SetPrivateGame(false)`
- `PreGame.SetPrivateGame(bChecked)`
- 2 callsites. Example: `UI/FrontEnd/SinglePlayer.lua:20`

### SetQuickCombat
- `PreGame.SetQuickCombat(OptionsManager.GetMultiplayerQuickCombatEnabled())`
- 1 callsite. Example: `UI/FrontEnd/Multiplayer/GameSetup/MPGameSetupScreen.lua:165`

### SetQuickMovement
- `PreGame.SetQuickMovement(OptionsManager.GetMultiplayerQuickMovementEnabled())`
- 1 callsite. Example: `UI/FrontEnd/Multiplayer/GameSetup/MPGameSetupScreen.lua:166`

### SetRandomMapScript
- `PreGame.SetRandomMapScript(false)`
- `PreGame.SetRandomMapScript(true)`
- 26 callsites. Example: `UI/FrontEnd/LoadTutorial.lua:101`

### SetRandomWorldSize
- `PreGame.SetRandomWorldSize(false)`
- `PreGame.SetRandomWorldSize(true)`
- 21 callsites. Example: `UI/FrontEnd/GameSetup/AdvancedSetup.lua:670`

### SetReady
- `PreGame.SetReady(Matchmaking.GetLocalID(), bChecked)`
- `PreGame.SetReady(playerID, false)`
- `PreGame.SetReady(Matchmaking.GetLocalID())`
- 3 callsites. Example: `UI/FrontEnd/Multiplayer/StagingRoom.lua:378`

### SetSlotClaim
- `PreGame.SetSlotClaim(i, SlotClaim.SLOTCLAIM_ASSIGNED)`
- `PreGame.SetSlotClaim(playerID, SlotClaim.SLOTCLAIM_ASSIGNED)`
- `PreGame.SetSlotClaim(playerID, SlotClaim.SLOTCLAIM_RESERVED)`
- `PreGame.SetSlotClaim(playerID, SlotClaim.SLOTCLAIM_UNASSIGNED)`
- 10 callsites. Example: `DLC/Expansion/Scenarios/SteampunkScenario/SteampunkScenarioLoadScreen.lua:67`

### SetSlotStatus
- `PreGame.SetSlotStatus(i, SlotStatus.SS_COMPUTER)`
- `PreGame.SetSlotStatus(i, SlotStatus.SS_CLOSED)`
- `PreGame.SetSlotStatus(i, SlotStatus.SS_OPEN)`
- `PreGame.SetSlotStatus(playerID, SlotStatus.SS_COMPUTER)`
- `PreGame.SetSlotStatus(playerID, SlotStatus.SS_TAKEN)`
- ...and 4 more distinct call shapes
- 27 callsites. Example: `UI/FrontEnd/GameSetup/AdvancedSetup.lua:1315`

### SetTeam
- `PreGame.SetTeam(playerID, playerChoiceID)`
- `PreGame.SetTeam(i, i)`
- 3 callsites. Example: `UI/FrontEnd/GameSetup/AdvancedSetup.lua:1152`

### SetVictory
- `PreGame.SetVictory(row.ID, true)`
- `PreGame.SetVictory(row.ID, victories[row.Type])`
- `PreGame.SetVictory(row.ID, false)`
- `PreGame.SetVictory(row.ID, bCheck)`
- `PreGame.SetVictory(victory.ID, true)`
- 19 callsites. Example: `UI/FrontEnd/GameSetup/AdvancedSetup.lua:1407`

### SetWorldSize
- `PreGame.SetWorldSize(wb.MapSize)`
- `PreGame.SetWorldSize(id)`
- `PreGame.SetWorldSize(GameInfo.Worlds.WORLDSIZE_STANDARD.ID)`
- `PreGame.SetWorldSize(worldSize.ID)`
- `PreGame.SetWorldSize(worldInfo.ID)`
- ...and 7 more distinct call shapes
- 22 callsites. Example: `UI/FrontEnd/GameSetup/AdvancedSetup.lua:690`

### TestPassword
- `PreGame.TestPassword(Game.GetActivePlayer(), Controls.EnterPasswordEditBox:GetText())`
- `PreGame.TestPassword(ePlayer, Controls.OldPasswordEditBox:GetText())`
- `PreGame.TestPassword(Game.GetActivePlayer(), Controls.OldPasswordEditBox:GetText())`
- 5 callsites. Example: `UI/InGame/PlayerChange.lua:10`
