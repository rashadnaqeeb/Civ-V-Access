# Modding

Mod activation and query. Static table.

Extracted from 178 call sites across 55 distinct methods in the shipped game Lua.

## Methods

### ActivateAllowedDLC
- `Modding.ActivateAllowedDLC()`
- 4 callsites. Example: `UI/FrontEnd/Multiplayer/JoiningRoom.lua:165`

### ActivateDLC
- `Modding.ActivateDLC()`
- 3 callsites. Example: `UI/FrontEnd/MainMenu.lua:30`

### ActivateEnabledMods
- `Modding.ActivateEnabledMods()`
- 1 callsite. Example: `UI/FrontEnd/Modding/ModsBrowser.lua:51`

### ActivateModsAndDLCForReplay
- `Modding.ActivateModsAndDLCForReplay(replayFile)`
- 1 callsite. Example: `UI/FrontEnd/LoadReplayMenu.lua:26`

### ActivateSpecificMod
- `Modding.ActivateSpecificMod(tutorialModId, tutorialModVersion)`
- `Modding.ActivateSpecificMod(entry.ModID, entry.Version)`
- 3 callsites. Example: `UI/FrontEnd/LoadTutorial.lua:113`

### AllEnabledModsContainPropertyValue
- `Modding.AllEnabledModsContainPropertyValue("SupportsSinglePlayer", 1)`
- `Modding.AllEnabledModsContainPropertyValue("SupportsMultiplayer", 1)`
- 2 callsites. Example: `UI/FrontEnd/Modding/ModsMenu.lua:43`

### AnyActivatedModsContainPropertyValue
- `Modding.AnyActivatedModsContainPropertyValue("DisableQuickSave", "1")`
- `Modding.AnyActivatedModsContainPropertyValue("DisableLoadGameOption", "1")`
- `Modding.AnyActivatedModsContainPropertyValue("DisableSaveGameOption", "1")`
- `Modding.AnyActivatedModsContainPropertyValue("DisableSaveMapOption", "1")`
- 4 callsites. Example: `UI/InGame/Menus/GameMenu.lua:158`

### AnyEnabledModsContainPropertyValue
- `Modding.AnyEnabledModsContainPropertyValue("HideSetupGame", 1)`
- 1 callsite. Example: `UI/FrontEnd/Modding/ModsSinglePlayer.lua:76`

### CanDeleteMod
- `Modding.CanDeleteMod(modId, modVersion)`
- `Modding.CanDeleteMod(modId, version)`
- 2 callsites. Example: `UI/FrontEnd/Modding/InstalledPanel.lua:742`

### CanEnableMod
- `Modding.CanEnableMod(customMod.ModID, customMod.Version)`
- `Modding.CanEnableMod(modsToTestCanEnable)`
- 2 callsites. Example: `UI/FrontEnd/ScenariosMenu.lua:139`

### CanLoadCloudSave
- `Modding.CanLoadCloudSave(g_iSelected)`
- 1 callsite. Example: `UI/FrontEnd/LoadMenu.lua:378`

### CanLoadReplay
- `Modding.CanLoadReplay(g_FileList[g_iSelected])`
- 1 callsite. Example: `UI/FrontEnd/LoadReplayMenu.lua:265`

### CanLoadSavedGame
- `Modding.CanLoadSavedGame(g_FileList[g_iSelected])`
- 1 callsite. Example: `UI/FrontEnd/LoadMenu.lua:380`

### CanUnsubscribeMod
- `Modding.CanUnsubscribeMod(modId, modVersion)`
- `Modding.CanUnsubscribeMod(modId, version)`
- 2 callsites. Example: `UI/FrontEnd/Modding/InstalledPanel.lua:741`

### DeactivateMods
- `Modding.DeactivateMods()`
- 4 callsites. Example: `UI/FrontEnd/LoadReplayMenu.lua:58`

### DeleteMod
- `Modding.DeleteMod(modinfo.ModId, modinfo.Version)`
- 1 callsite. Example: `UI/FrontEnd/Modding/InstalledPanel.lua:784`

### DeleteUserData
- `Modding.DeleteUserData(modinfo.ModId, modinfo.Version)`
- 1 callsite. Example: `UI/FrontEnd/Modding/InstalledPanel.lua:786`

### DisableMod
- `Modding.DisableMod(v.ModID, v.Version)`
- `Modding.DisableMod(modID, version)`
- 2 callsites. Example: `UI/FrontEnd/Modding/InstalledPanel.lua:381`

### EnableMod
- `Modding.EnableMod(modID, version)`
- 1 callsite. Example: `UI/FrontEnd/Modding/InstalledPanel.lua:342`

### GetActivatedModEntryPoints
- `Modding.GetActivatedModEntryPoints("InGameUIAddin")`
- `Modding.GetActivatedModEntryPoints("CityViewUIAddin")`
- `Modding.GetActivatedModEntryPoints("DiplomacyUIAddin")`
- `Modding.GetActivatedModEntryPoints("Custom")`
- 11 callsites. Example: `UI/InGame/InGame.lua:1136`

### GetActivatedMods
- `Modding.GetActivatedMods()`
- 1 callsite. Example: `UI/InGame/Menus/GameMenu.lua:420`

### GetActivatedModVersion
- `Modding.GetActivatedModVersion(myModId)`
- `Modding.GetActivatedModVersion(ksModID)`
- `Modding.GetActivatedModVersion(MOD_ID)`
- 10 callsites. Example: `DLC/Expansion/Scenarios/FallOfRomeScenario/FoRScenarioLoadScreen.lua:51`

### GetCloudSaveRequirements
- `Modding.GetCloudSaveRequirements(g_iSelected)`
- 1 callsite. Example: `UI/FrontEnd/LoadMenu.lua:387`

### GetDlcAssociations
- `Modding.GetDlcAssociations(modId, modVersion)`
- 1 callsite. Example: `UI/FrontEnd/Modding/InstalledPanel.lua:630`

### GetDlcNameDescriptionKeys
- `Modding.GetDlcNameDescriptionKeys(packageId)`
- 1 callsite. Example: `UI/FrontEnd/Multiplayer/Lobby.lua:493`

### GetDownloadProgress
- `Modding.GetDownloadProgress(modinfo.DownloadHandle)`
- 1 callsite. Example: `UI/FrontEnd/Modding/InstalledPanel.lua:251`

### GetEnabledModsByActivationOrder
- `Modding.GetEnabledModsByActivationOrder()`
- 3 callsites. Example: `UI/FrontEnd/Modding/ModsMenu.lua:57`

### GetEvaluatedFilePath
- `Modding.GetEvaluatedFilePath(addin.ModID, addin.Version, addin.File)`
- `Modding.GetEvaluatedFilePath(customMod.ModID, customMod.Version, customImage)`
- `Modding.GetEvaluatedFilePath(entry.ModID, entry.Version, entry.File)`
- `Modding.GetEvaluatedFilePath(myModId, myModVersion, "NewWorld_Scenario_MapScript.lua")`
- `Modding.GetEvaluatedFilePath(ksModID, iModVersion, "CivilWarEasternTheater.Civ5Map")`
- ...and 10 more distinct call shapes
- 27 callsites. Example: `UI/InGame/InGame.lua:1137`

### GetGameVersionAssociations
- `Modding.GetGameVersionAssociations(modId, modVersion)`
- 1 callsite. Example: `UI/FrontEnd/Modding/InstalledPanel.lua:631`

### GetInstalledFiraxisScenarios
- `Modding.GetInstalledFiraxisScenarios()`
- 2 callsites. Example: `UI/FrontEnd/ScenariosMenu.lua:170`

### GetInstalledModDetails
- `Modding.GetInstalledModDetails(modId, modVersion)`
- 1 callsite. Example: `UI/FrontEnd/Modding/InstalledPanel.lua:518`

### GetInstallProgress
- `Modding.GetInstallProgress()`
- 3 callsites. Example: `UI/FrontEnd/Modding/InstalledPanel.lua:182`

### GetLatestInstalledModVersion
- `Modding.GetLatestInstalledModVersion(tutorialModId)`
- `Modding.GetLatestInstalledModVersion(TutorialID)`
- 3 callsites. Example: `UI/FrontEnd/LoadTutorial.lua:111`

### GetMapFiles
- `Modding.GetMapFiles()`
- 6 callsites. Example: `UI/InGame/Menus/SaveMapMenu.lua:219`

### GetModAssociations
- `Modding.GetModAssociations(modId, modVersion)`
- 1 callsite. Example: `UI/FrontEnd/Modding/InstalledPanel.lua:629`

### GetModBrowserDownloadingListings
- `Modding.GetModBrowserDownloadingListings()`
- 2 callsites. Example: `UI/FrontEnd/Modding/InstalledPanel.lua:159`

### GetModBrowserInstalledListings
- `Modding.GetModBrowserInstalledListings()`
- 1 callsite. Example: `UI/FrontEnd/Modding/InstalledPanel.lua:136`

### GetModProperty
- `Modding.GetModProperty(v.ModID, v.Version, "Name")`
- `Modding.GetModProperty(customMod.ModID, customMod.Version, "Custom_Background_" .. customMod.Name)`
- `Modding.GetModProperty(customMod.ModID, customMod.Version, "Custom_Foreground_" .. customMod.Name)`
- `Modding.GetModProperty(v.ID, v.Version, "Name")`
- 8 callsites. Example: `UI/FrontEnd/Modding/InstalledPanel.lua:368`

### GetModsBrowserInstalledListingsState
- `Modding.GetModsBrowserInstalledListingsState()`
- 1 callsite. Example: `UI/FrontEnd/Modding/InstalledPanel.lua:457`

### GetModsRequiredToDisableMod
- `Modding.GetModsRequiredToDisableMod(modID, version)`
- 1 callsite. Example: `UI/FrontEnd/Modding/InstalledPanel.lua:348`

### GetReplayRequirements
- `Modding.GetReplayRequirements(g_FileList[g_iSelected])`
- 1 callsite. Example: `UI/FrontEnd/LoadReplayMenu.lua:268`

### GetSavedGameRequirements
- `Modding.GetSavedGameRequirements(g_FileList[g_iSelected])`
- 1 callsite. Example: `UI/FrontEnd/LoadMenu.lua:389`

### GetSystemProperty
- `Modding.GetSystemProperty("ShowDLCMods")`
- 1 callsite. Example: `UI/FrontEnd/Modding/InstalledPanel.lua:852`

### HasPendingInstalls
- `Modding.HasPendingInstalls()`
- 1 callsite. Example: `UI/FrontEnd/Modding/InstalledPanel.lua:482`

### HasUserData
- `Modding.HasUserData(modinfo.ModId, modinfo.Version)`
- 1 callsite. Example: `UI/FrontEnd/Modding/InstalledPanel.lua:776`

### InstallMods
- `Modding.InstallMods()`
- 1 callsite. Example: `UI/FrontEnd/Modding/InstalledPanel.lua:483`

### OpenSaveData
- `Modding.OpenSaveData()`
- 38 callsites. Example: `DLC/Expansion2/Scenarios/CivilWarScenario/TurnsRemaining.lua:304`

### OpenUserData
- `Modding.OpenUserData(TutorialID, latestTutorialVersion)`
- 1 callsite. Example: `UI/FrontEnd/LoadTutorial.lua:229`

### PerformActions
- `Modding.PerformActions("OnTutorial0")`
- `Modding.PerformActions("OnTutorial" .. index)`
- 2 callsites. Example: `UI/FrontEnd/LoadTutorial.lua:114`

### PostProcessModActions
- `Modding.PostProcessModActions()`
- 2 callsites. Example: `UI/FrontEnd/LoadTutorial.lua:115`

### PublishedFileIdsMatch
- `Modding.PublishedFileIdsMatch(v.PublishedFileId, downloadingFiles[i].PublishedFileId)`
- 1 callsite. Example: `UI/FrontEnd/Modding/InstalledPanel.lua:465`

### SetSystemProperty
- `Modding.SetSystemProperty("ShowDLCMods", "1")`
- `Modding.SetSystemProperty("ShowDLCMods", "0")`
- 2 callsites. Example: `UI/FrontEnd/Modding/InstalledPanel.lua:867`

### UnsubscribeMod
- `Modding.UnsubscribeMod(modinfo.ModId, modinfo.Version)`
- 1 callsite. Example: `UI/FrontEnd/Modding/InstalledPanel.lua:812`

### UpdateMod
- `Modding.UpdateMod(modinfo.ModId, modinfo.Version)`
- 1 callsite. Example: `UI/FrontEnd/Modding/InstalledPanel.lua:228`

### UpdateModdingSystem
- `Modding.UpdateModdingSystem()`
- 1 callsite. Example: `UI/FrontEnd/Modding/InstalledPanel.lua:454`
