# InstanceManager

The mod-side UI templating helper defined in `Assets/UI/InstanceManager.lua` (~150 lines, worth reading directly). Methods: `:new(instanceName, rootControlName, parentControl)` constructor, `:GetInstance()` to obtain or recycle a pooled instance, `:ResetInstances()` to free all, `:ReleaseInstance(inst)` to free one. Heavy use across the codebase for list-style UI (city list, civ list, tech tree entries, etc.).

Extracted from 2847 call sites across 4 distinct methods in the shipped game Lua.

## Methods

### GetInstance
- `g_ListItemManager:GetInstance()`
- `g_TheirCombatDataIM:GetInstance()`
- `g_MyCombatDataIM:GetInstance()`
- `g_ListHeadingManager:GetInstance()`
- `g_BBTextManager:GetInstance()`
- ...and 176 more distinct call shapes
- 1443 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:4644`

### new
- `InstanceManager:new("DominationRow", "RowStack", Controls.DominationStack)`
- `InstanceManager:new("TechCiv", "Civ", Controls.TechStack)`
- `InstanceManager:new("DiploCiv", "Civ", Controls.DiploStack)`
- `InstanceManager:new("ScoreCiv", "Civ", Controls.ScoreStack)`
- `InstanceManager:new("DominationItem", "IconFrame", curRow.RowStack)`
- ...and 197 more distinct call shapes
- 526 callsites. Example: `UI/InGame/Popups/VictoryProgress.lua:8`

### ReleaseInstance
- `g_SVStrikeIM:ReleaseInstance(svInstance)`
- `g_TeamIM:ReleaseInstance(instance.SubControls)`
- `g_OtherIM:ReleaseInstance(instance.SubControls)`
- `g_OtherIM:ReleaseInstance(banner.SubControls)`
- `g_TeamIM:ReleaseInstance(banner.SubControls)`
- ...and 5 more distinct call shapes
- 34 callsites. Example: `UI/InGame/CityBannerManager.lua:688`

### ResetInstances
- `g_ListHeadingManager:ResetInstances()`
- `g_ListItemManager:ResetInstances()`
- `g_BBTextManager:ResetInstances()`
- `g_InstanceManager:ResetInstances()`
- `g_PrereqTechManager:ResetInstances()`
- ...and 129 more distinct call shapes
- 844 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:142`
