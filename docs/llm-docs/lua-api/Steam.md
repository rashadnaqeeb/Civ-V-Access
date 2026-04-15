# Steam

Steam platform integration. Static table.

Extracted from 20 call sites across 10 distinct methods in the shipped game Lua.

## Methods

### ActivateGameOverlayToStore
- `Steam.ActivateGameOverlayToStore()`
- `Steam.ActivateGameOverlayToStore(65980)`
- 2 callsites. Example: `UI/FrontEnd/MainMenu.lua:242`

### ActivateGameOverlayToWebPage
- `Steam.ActivateGameOverlayToWebPage(v.customurl)`
- `Steam.ActivateGameOverlayToWebPage("http://store.steampowered.com/news/_appids_8930")`
- `Steam.ActivateGameOverlayToWebPage("http://steamcommunity.com/workshop/browse_appid_8930")`
- 3 callsites. Example: `UI/FrontEnd/MainMenu.lua:244`

### ActivateInviteOverlay
- `Steam.ActivateInviteOverlay()`
- 4 callsites. Example: `UI/InGame/WorldView/DiploCorner.lua:210`

### CopyLastAutoSaveToSteamCloud
- `Steam.CopyLastAutoSaveToSteamCloud(i)`
- 1 callsite. Example: `UI/InGame/Menus/SaveMenu.lua:38`

### GetCloudSaveFileName
- `Steam.GetCloudSaveFileName(g_iSelected)`
- 2 callsites. Example: `UI/FrontEnd/LoadMenu.lua:35`

### GetCloudSaves
- `Steam.GetCloudSaves()`
- 2 callsites. Example: `UI/FrontEnd/LoadMenu.lua:683`

### GetMaxCloudSaves
- `Steam.GetMaxCloudSaves()`
- 2 callsites. Example: `UI/FrontEnd/LoadMenu.lua:500`

### IsOverlayEnabled
- `Steam.IsOverlayEnabled()`
- 1 callsite. Example: `UI/FrontEnd/Modding/ModsBrowser.lua:38`

### SaveGameToCloud
- `Steam.SaveGameToCloud(i)`
- 2 callsites. Example: `UI/InGame/Menus/SaveMenu.lua:40`

### SetOverlayNotificationPosition
- `Steam.SetOverlayNotificationPosition("bottom_left")`
- 1 callsite. Example: `UI/FrontEnd/MainMenu.lua:114`
