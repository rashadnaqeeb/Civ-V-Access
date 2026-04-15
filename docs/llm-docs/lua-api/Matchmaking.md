# Matchmaking

Multiplayer lobby / matchmaking. Static table.

Extracted from 114 call sites across 26 distinct methods in the shipped game Lua.

## Methods

### GetCurrentGameName
- `Matchmaking.GetCurrentGameName()`
- 1 callsite. Example: `UI/FrontEnd/Multiplayer/StagingRoom.lua:1400`

### GetFriendList
- `Matchmaking.GetFriendList()`
- 1 callsite. Example: `UI/FrontEnd/Multiplayer/StagingRoom.lua:1629`

### GetHostID
- `Matchmaking.GetHostID()`
- 2 callsites. Example: `UI/InGame/WorldView/MPList.lua:282`

### GetLocalID
- `Matchmaking.GetLocalID()`
- 37 callsites. Example: `UI/InGame/Menus/SaveMenu.lua:102`

### GetMultiplayerGameCount
- `Matchmaking.GetMultiplayerGameCount()`
- 1 callsite. Example: `UI/FrontEnd/Multiplayer/Lobby.lua:247`

### GetMultiplayerGameList
- `Matchmaking.GetMultiplayerGameList()`
- 1 callsite. Example: `UI/FrontEnd/Multiplayer/Lobby.lua:515`

### GetMultiplayerServerEntry
- `Matchmaking.GetMultiplayerServerEntry(idLobby)`
- 1 callsite. Example: `UI/FrontEnd/Multiplayer/Lobby.lua:287`

### GetPlayerList
- `Matchmaking.GetPlayerList()`
- 11 callsites. Example: `UI/InGame/DiploList.lua:9`

### HostHotSeatGame
- `Matchmaking.HostHotSeatGame(strGameName, PreGame.ReadActiveSlotCountFromSaveGame())`
- `Matchmaking.HostHotSeatGame(strGameName, worldInfo.DefaultPlayers)`
- 2 callsites. Example: `UI/FrontEnd/LoadMenu.lua:77`

### HostInternetGame
- `Matchmaking.HostInternetGame(strGameName, PreGame.ReadActiveSlotCountFromSaveGame())`
- `Matchmaking.HostInternetGame(strGameName, worldInfo.DefaultPlayers)`
- 2 callsites. Example: `UI/FrontEnd/LoadMenu.lua:74`

### HostLANGame
- `Matchmaking.HostLANGame(strGameName, PreGame.ReadActiveSlotCountFromSaveGame())`
- `Matchmaking.HostLANGame(strGameName, worldInfo.DefaultPlayers)`
- 2 callsites. Example: `UI/FrontEnd/LoadMenu.lua:79`

### HostServerGame
- `Matchmaking.HostServerGame(strGameName, PreGame.ReadActiveSlotCountFromSaveGame(), false)`
- `Matchmaking.HostServerGame(strGameName, worldInfo.DefaultPlayers, false)`
- 2 callsites. Example: `UI/FrontEnd/LoadMenu.lua:71`

### InitInternetLobby
- `Matchmaking.InitInternetLobby()`
- 1 callsite. Example: `UI/FrontEnd/Multiplayer/Lobby.lua:604`

### InitLanLobby
- `Matchmaking.InitLanLobby()`
- 1 callsite. Example: `UI/FrontEnd/Multiplayer/Lobby.lua:606`

### IsHost
- `Matchmaking.IsHost()`
- 16 callsites. Example: `UI/Options/OptionsMenu.lua:104`

### IsLaunchingGame
- `Matchmaking.IsLaunchingGame()`
- 4 callsites. Example: `UI/FrontEnd/Multiplayer/DedicatedServer.lua:5`

### IsRefreshingGameList
- `Matchmaking.IsRefreshingGameList()`
- 2 callsites. Example: `UI/FrontEnd/Multiplayer/Lobby.lua:158`

### JoinIPAddress
- `Matchmaking.JoinIPAddress(Controls.ConnectIPEdit:GetText())`
- 1 callsite. Example: `UI/FrontEnd/Multiplayer/Lobby.lua:185`

### JoinMultiplayerGame
- `Matchmaking.JoinMultiplayerGame(serverID)`
- 1 callsite. Example: `UI/FrontEnd/Multiplayer/Lobby.lua:129`

### KickPlayer
- `Matchmaking.KickPlayer(iPlayerID)`
- `Matchmaking.KickPlayer(g_kickIdx)`
- 3 callsites. Example: `UI/FrontEnd/Multiplayer/JoiningRoom.lua:143`

### LaunchMultiplayerGame
- `Matchmaking.LaunchMultiplayerGame()`
- 1 callsite. Example: `UI/FrontEnd/Multiplayer/StagingRoom.lua:268`

### LeaveMultiplayerGame
- `Matchmaking.LeaveMultiplayerGame()`
- 6 callsites. Example: `UI/FrontEnd/Multiplayer/JoiningRoom.lua:19`

### RefreshInternetGameList
- `Matchmaking.RefreshInternetGameList()`
- 5 callsites. Example: `UI/FrontEnd/Modding/ModsMultiplayer.lua:15`

### RefreshLANGameList
- `Matchmaking.RefreshLANGameList()`
- 5 callsites. Example: `UI/FrontEnd/Modding/ModsMultiplayer.lua:29`

### SetMultiplayerGameListType
- `Matchmaking.SetMultiplayerGameListType(g_ListTypes[id].listType, g_ListTypes[id].searchType)`
- `Matchmaking.SetMultiplayerGameListType(LIST_SERVERS, SEARCH_INTERNET)`
- `Matchmaking.SetMultiplayerGameListType(LIST_SERVERS, SEARCH_LAN)`
- `Matchmaking.SetMultiplayerGameListType(LIST_LOBBIES, SEARCH_INTERNET)`
- 4 callsites. Example: `UI/FrontEnd/Multiplayer/Lobby.lua:244`

### StopRefreshingGameList
- `Matchmaking.StopRefreshingGameList()`
- 1 callsite. Example: `UI/FrontEnd/Multiplayer/Lobby.lua:172`
