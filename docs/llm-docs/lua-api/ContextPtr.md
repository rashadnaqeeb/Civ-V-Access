# ContextPtr

The per-context pointer exposed in every UI Lua file. Provides lifecycle hooks (`SetShowHandler`, `SetHideHandler`, `SetUpdate`, `SetInputHandler`) and control lookup (`LookUpControl`).

Extracted from 1064 call sites across 16 distinct methods in the shipped game Lua.

## Methods

### BuildInstance
- `ContextPtr:BuildInstance(self.m_InstanceName, controlTable)`
- 2 callsites. Example: `UI/InstanceManager.lua:88`

### BuildInstanceForControl
- `ContextPtr:BuildInstanceForControl("SelectCivInstance", controlTable, Controls.SelectCivStack)`
- `ContextPtr:BuildInstanceForControl("ItemInstance", controlTable, Controls.DifficultyStack)`
- `ContextPtr:BuildInstanceForControl("ItemInstance", controlTable, stackControl)`
- `ContextPtr:BuildInstanceForControl("Entry", instance, Controls.MainStack)`
- `ContextPtr:BuildInstanceForControl("TextEntry", textControls, controlTable.PactStack)`
- ...and 54 more distinct call shapes
- 181 callsites. Example: `DLC/Expansion2/Scenarios/CivilWarScenario/CivilWarScenarioLoadScreen.lua:146`

### BuildInstanceForControlAtIndex
- `ContextPtr:BuildInstanceForControlAtIndex("ItemInstance", controlTable, Controls.Stack, i-1)`
- 1 callsite. Example: `UI/FrontEnd/GameSetup/SelectGameSpeed.lua:68`

### CallParentShowHideHandler
- `ContextPtr:CallParentShowHideHandler(false)`
- `ContextPtr:CallParentShowHideHandler(true)`
- 13 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:354`

### ClearUpdate
- `ContextPtr:ClearUpdate()`
- 21 callsites. Example: `UI/Options/OptionsMenu.lua:215`

### DestroyChild
- `ContextPtr:DestroyChild(iter)`
- 1 callsite. Example: `UI/InstanceManager.lua:135`

### GetID
- `ContextPtr:GetID()`
- 13 callsites. Example: `UI/Options/OptionsMenu.lua:99`

### IsHidden
- `ContextPtr:IsHidden()`
- 128 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:6283`

### IsHotLoad
- `ContextPtr:IsHotLoad()`
- 11 callsites. Example: `UI/FrontEnd/MainMenu.lua:28`

### LoadNewContext
- `ContextPtr:LoadNewContext(path)`
- `ContextPtr:LoadNewContext(strData1)`
- 11 callsites. Example: `UI/InGame/InGame.lua:1144`

### LookUpControl
- `ContextPtr:LookUpControl("/InGame/WorldView/UnitPanel/Base")`
- `ContextPtr:LookUpControl("/InGame/WorldView/InfoCorner")`
- `ContextPtr:LookUpControl("..")`
- `ContextPtr:LookUpControl("/InGame/WorldView/PlotHelpText")`
- `ContextPtr:LookUpControl("../SelectedUnitContainer")`
- ...and 12 more distinct call shapes
- 63 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseAdmiralNewPort.lua:185`

### SetHide
- `ContextPtr:SetHide(true)`
- `ContextPtr:SetHide(false)`
- 180 callsites. Example: `UI/TouchControlsMenu.lua:10`

### SetInputHandler
- `ContextPtr:SetInputHandler(InputHandler)`
- `ContextPtr:SetInputHandler(function(uiMsg, wParam, lParam) if uiMsg == KeyEvents.KeyDown then if wParam == Keys.VK_ESCAPE or wParam == Keys.VK_RETURN then OnBack(); end end return true; end)`
- `ContextPtr:SetInputHandler(ProcessInput)`
- `ContextPtr:SetInputHandler(function(uiMsg, wParam, lParam) if uiMsg == KeyEvents.KeyDown then if wParam == Keys.VK_ESCAPE then NavigateBack(); end end return true; end)`
- `ContextPtr:SetInputHandler(function(uiMsg, wParam, lParam) if uiMsg == KeyEvents.KeyDown then if wParam == Keys.VK_ESCAPE then OnBack(); end end return true; end)`
- ...and 2 more distinct call shapes
- 199 callsites. Example: `UI/TouchControlsMenu.lua:15`

### SetShowHideHandler
- `ContextPtr:SetShowHideHandler(ShowHideHandler)`
- `ContextPtr:SetShowHideHandler(OnShowHide)`
- `ContextPtr:SetShowHideHandler(ShowHide)`
- `ContextPtr:SetShowHideHandler(function(isHide) if( not isHide ) then if (not ContextPtr:IsHotLoad()) then UIManager:SetUICursor( 1 ); Modding.ActivateDLC(); PreGame.LoadPreGameSettings(); UIManager:SetUICursor( 0 ); Events.SystemUpdateUI( SystemUpdateUIType.RestoreUI, "ScenariosMenuReset" ); end SetupFileButtonList(); end end)`
- `ContextPtr:SetShowHideHandler(function(isHide) end)`
- ...and 5 more distinct call shapes
- 203 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:6477`

### SetShutdown
- `ContextPtr:SetShutdown(OnShutdown)`
- 3 callsites. Example: `UI/InGame/UnitFlagManager.lua:1618`

### SetUpdate
- `ContextPtr:SetUpdate(OnUpdate)`
- `ContextPtr:SetUpdate(UpdateHandler)`
- `ContextPtr:SetUpdate(UpdateNetworkDisplay)`
- `ContextPtr:SetUpdate(function() if(g_ModList == nil) then SetupFileButtonList(); end end)`
- `ContextPtr:SetUpdate(function(dTime) if(g_AnimUpdate == nil or g_AnimUpdate(dTime) == true) then ContextPtr:ClearUpdate(); end end)`
- ...and 13 more distinct call shapes
- 34 callsites. Example: `UI/FrontEnd/PreGameScreen.lua:41`
