# Plot

Methods on Plot handles. Obtain via `Map.GetPlot(x, y)`, `Map.GetPlotByIndex(i)`, or `pUnit:GetPlot()` / `pCity:Plot()`.

Extracted from 4994 call sites across 94 distinct methods in the shipped game Lua.

## Methods

### Area
- `plot:Area()`
- `otherPlot:Area()`
- `pPlot:Area()`
- 48 callsites. Example: `Maps/Great_Plains.lua:815`

### CalculateYield
- `pPlot:CalculateYield(iYield)`
- `plot:CalculateYield(0, true)`
- `plot:CalculateYield(1, true)`
- `plot:CalculateYield(2, true)`
- `plot:CalculateYield(3, true)`
- ...and 2 more distinct call shapes
- 38 callsites. Example: `UI/InGame/GenericWorldAnchor.lua:269`

### CanHaveFeature
- `plot:CanHaveFeature(featureForest)`
- `plot:CanHaveFeature(self.featureFloodPlains)`
- `plot:CanHaveFeature(self.featureIce)`
- `plot:CanHaveFeature(self.featureJungle)`
- `plot:CanHaveFeature(self.featureForest)`
- ...and 6 more distinct call shapes
- 50 callsites. Example: `Maps/Great_Plains.lua:542`

### CanHaveImprovement
- `plot:CanHaveImprovement(improvementID, NO_TEAM)`
- 3 callsites. Example: `Gameplay/Lua/MapGenerator.lua:606`

### CanHaveResource
- `plot:CanHaveResource(resourceID, ignoreLatitude)`
- `plot:CanHaveResource(resource.ID, ignoreLatitude)`
- 7 callsites. Example: `Gameplay/Lua/WorldBuilderRandomItems.lua:56`

### CanSeePlot
- `thisPlot:CanSeePlot(pTargetPlot, thisTeam, iRange - 1, NO_DIRECTION)`
- 1 callsite. Example: `UI/InGame/Bombardment.lua:54`

### ChangeVisibilityCount
- `pPlot:ChangeVisibilityCount(team, -1, -1, true, true)`
- `pPlot:ChangeVisibilityCount(team, 1, -1, true, true)`
- 6 callsites. Example: `UI/InGame/InGame.lua:93`

### DefenseModifier
- `pToPlot:DefenseModifier(pTheirUnit:GetTeam(), false, false)`
- 3 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:1170`

### GetArchaeologyArtifactEra
- `pPlot:GetArchaeologyArtifactEra()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseArchaeologyPopup.lua:115`

### GetArchaeologyArtifactPlayer1
- `pPlot:GetArchaeologyArtifactPlayer1()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseArchaeologyPopup.lua:113`

### GetArchaeologyArtifactPlayer2
- `pPlot:GetArchaeologyArtifactPlayer2()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseArchaeologyPopup.lua:114`

### GetArchaeologyArtifactType
- `pPlot:GetArchaeologyArtifactType()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseArchaeologyPopup.lua:112`

### GetArchaeologyArtifactWork
- `pPlot:GetArchaeologyArtifactWork()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseArchaeologyPopup.lua:147`

### GetArea
- `plot:GetArea()`
- `adjPlot:GetArea()`
- `adjacentPlot:GetArea()`
- `pPlot:GetArea()`
- 118 callsites. Example: `Maps/Four_Corners.lua:499`

### GetBuildProgress
- `plot:GetBuildProgress(pBuildInfo.ID)`
- `adjacentPlot:GetBuildProgress(iBuildID)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/PlotHelpManager.lua:146`

### GetBuildTurnsLeft
- `plot:GetBuildTurnsLeft(pBuildInfo.ID, 0, 0)`
- `pPlot:GetBuildTurnsLeft(iBuildID, Game.GetActivePlayer(), iExtraBuildRate, iExtraBuildRate)`
- `plot:GetBuildTurnsLeft(pBuildInfo.ID, Game.GetActivePlayer(), 0, 0)`
- 8 callsites. Example: `UI/InGame/PlotHelpManager.lua:146`

### GetContinentArtType
- `plot:GetContinentArtType()`
- 2 callsites. Example: `UI/InGame/DebugMode.lua:450`

### GetCulture
- `plot:GetCulture()`
- 2 callsites. Example: `UI/InGame/PlotMouseoverInclude.lua:411`

### GetFeatureProduction
- `pPlot:GetFeatureProduction(iBuildID, iActiveTeam)`
- 3 callsites. Example: `UI/InGame/WorldView/UnitPanel.lua:1326`

### GetFeatureType
- `plot:GetFeatureType()`
- `pPlot:GetFeatureType()`
- `adjPlot:GetFeatureType()`
- `pToPlot:GetFeatureType()`
- `searchPlot:GetFeatureType()`
- ...and 1 more distinct call shapes
- 228 callsites. Example: `Maps/Great_Plains.lua:517`

### GetImprovementType
- `plot:GetImprovementType()`
- `otherPlot:GetImprovementType()`
- `pPlot:GetImprovementType()`
- `adjacentPlot:GetImprovementType()`
- 9 callsites. Example: `Gameplay/Lua/MapGenerator.lua:610`

### GetInlandCorner
- `plot:GetInlandCorner()`
- 17 callsites. Example: `Maps/Great_Plains.lua:800`

### GetLayerUnit
- `plot:GetLayerUnit(i)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/UnitFlagManager.lua:1361`

### GetNumFriendlyUnitsOfType
- `pPlot:GetNumFriendlyUnitsOfType(unit)`
- 3 callsites. Example: `UI/InGame/WorldView/UnitPanel.lua:1023`

### GetNumLayerUnits
- `plot:GetNumLayerUnits()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/UnitFlagManager.lua:1357`

### GetNumResource
- `pTargetPlot:GetNumResource()`
- `plot:GetNumResource()`
- 17 callsites. Example: `UI/InGame/Popups/CityStateDiploPopup.lua:327`

### GetNumUnits
- `pPlot:GetNumUnits()`
- `plot:GetNumUnits()`
- `startPlot:GetNumUnits()`
- 39 callsites. Example: `UI/InGame/UnitFlagManager.lua:736`

### GetOwner
- `plot:GetOwner()`
- `pPlot:GetOwner()`
- `pTargetPlot:GetOwner()`
- `pToPlot:GetOwner()`
- `adjacentPlot:GetOwner()`
- ...and 2 more distinct call shapes
- 50 callsites. Example: `UI/InGame/CityBannerManager.lua:1105`

### GetPlotCity
- `plot:GetPlotCity()`
- `pPlot:GetPlotCity()`
- `pLoopPlot:GetPlotCity()`
- 57 callsites. Example: `UI/InGame/CityBannerManager.lua:962`

### GetPlotIndex
- `plot:GetPlotIndex()`
- 6 callsites. Example: `UI/InGame/YieldIconManager.lua:51`

### GetPlotType
- `plot:GetPlotType()`
- `adjPlot:GetPlotType()`
- `adjacentPlot:GetPlotType()`
- `searchPlot:GetPlotType()`
- `res_plot:GetPlotType()`
- 278 callsites. Example: `Maps/Continents.lua:230`

### GetResourceType
- `plot:GetResourceType(-1)`
- `res_plot:GetResourceType(-1)`
- `otherPlot:GetResourceType()`
- `pTargetPlot:GetResourceType(Game.GetActiveTeam())`
- `plot:GetResourceType(iActiveTeam)`
- ...and 8 more distinct call shapes
- 125 callsites. Example: `Maps/Great_Plains.lua:1512`

### GetRevealedImprovementType
- `plot:GetRevealedImprovementType(iActiveTeam, bIsDebug)`
- 3 callsites. Example: `UI/InGame/PlotMouseoverInclude.lua:211`

### GetRevealedOwner
- `plot:GetRevealedOwner(iActiveTeam, bIsDebug)`
- 3 callsites. Example: `UI/InGame/PlotMouseoverInclude.lua:347`

### GetRevealedRouteType
- `plot:GetRevealedRouteType(iActiveTeam, bIsDebug)`
- 3 callsites. Example: `UI/InGame/PlotMouseoverInclude.lua:223`

### GetTeam
- `plot:GetTeam()`
- `pPlot:GetTeam()`
- 11 callsites. Example: `UI/InGame/PopupsGeneric/DeclareWarMovePopup.lua:16`

### GetTerrainType
- `plot:GetTerrainType()`
- `adjPlot:GetTerrainType()`
- `pToPlot:GetTerrainType()`
- `searchPlot:GetTerrainType()`
- `res_plot:GetTerrainType()`
- ...and 1 more distinct call shapes
- 298 callsites. Example: `Maps/Four_Corners.lua:514`

### GetUnit
- `pPlot:GetUnit(0)`
- `pPlot:GetUnit(i)`
- `plot:GetUnit(i)`
- `pPlot:GetUnit(iLoopUnits)`
- `startPlot:GetUnit(i)`
- ...and 2 more distinct call shapes
- 133 callsites. Example: `DLC/Expansion/Scenarios/FallOfRomeScenario/TurnsRemaining.lua:1044`

### GetUnitPower
- `pPlot:GetUnitPower()`
- 4 callsites. Example: `Tutorial/lua/TutorialChecks.lua:1363`

### GetVisibilityCount
- `pPlot:GetVisibilityCount()`
- 3 callsites. Example: `UI/InGame/InGame.lua:92`

### GetWorkingCity
- `plot:GetWorkingCity()`
- 9 callsites. Example: `UI/InGame/CityView/CityView.lua:1794`

### GetX
- `riverPlot:GetX()`
- `plot:GetX()`
- `playerStartPlot:GetX()`
- `pPlot:GetX()`
- `startPlot:GetX()`
- ...and 5 more distinct call shapes
- 685 callsites. Example: `Maps/Four_Corners.lua:249`

### GetY
- `riverPlot:GetY()`
- `plot:GetY()`
- `playerStartPlot:GetY()`
- `pPlot:GetY()`
- `startPlot:GetY()`
- ...and 5 more distinct call shapes
- 684 callsites. Example: `Maps/Four_Corners.lua:249`

### GetYield
- `pTargetPlot:GetYield(YieldTypes.YIELD_FOOD)`
- `pTargetPlot:GetYield(YieldTypes.YIELD_PRODUCTION)`
- `pTargetPlot:GetYield(YieldTypes.YIELD_GOLD)`
- 9 callsites. Example: `UI/InGame/GenericWorldAnchor.lua:149`

### GetYieldWithBuild
- `pPlot:GetYieldWithBuild(iBuild, iYield, false, Game.GetActivePlayer())`
- `pPlot:GetYieldWithBuild(iBuildID, iYield, false, iActivePlayer)`
- 6 callsites. Example: `UI/InGame/GenericWorldAnchor.lua:268`

### HasWrittenArtifact
- `pPlot:HasWrittenArtifact()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseArchaeologyPopup.lua:101`

### IsAdjacentTeam
- `pPlot:IsAdjacentTeam(unit:GetTeam(), true)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/UnitPanel.lua:1362`

### IsAdjacentToArea
- `plot:IsAdjacentToArea(region_area_object)`
- 3 callsites. Example: `Gameplay/Lua/AssignStartingPlots.lua:8141`

### IsAdjacentToLand
- `plot:IsAdjacentToLand()`
- 16 callsites. Example: `Gameplay/Lua/AssignStartingPlots.lua:7015`

### IsAdjacentToShallowWater
- `plot:IsAdjacentToShallowWater()`
- 3 callsites. Example: `Gameplay/Lua/MapGenerator.lua:208`

### IsBuildRemovesFeature
- `pPlot:IsBuildRemovesFeature(iBuildID)`
- 3 callsites. Example: `UI/InGame/WorldView/UnitPanel.lua:1312`

### IsCity
- `pPlot:IsCity()`
- `plot:IsCity()`
- 27 callsites. Example: `UI/InGame/UnitFlagManager.lua:226`

### IsCoastalLand
- `plot:IsCoastalLand()`
- `adjPlot:IsCoastalLand()`
- 29 callsites. Example: `Maps/Great_Plains.lua:811`

### IsEnemyCity
- `plot:IsEnemyCity(pUnit)`
- `plot:IsEnemyCity(pHeadSelectedUnit)`
- 6 callsites. Example: `UI/InGame/InGame.lua:250`

### IsFighting
- `plot:IsFighting()`
- 12 callsites. Example: `UI/InGame/WorldView/WorldView.lua:406`

### IsFlatlands
- `plot:IsFlatlands()`
- 12 callsites. Example: `Maps/Great_Plains.lua:538`

### IsFreshWater
- `plot:IsFreshWater()`
- `searchPlot:IsFreshWater()`
- `res_plot:IsFreshWater()`
- 80 callsites. Example: `UI/InGame/PlotHelpManager.lua:248`

### IsFriendlyTerritory
- `pToPlot:IsFriendlyTerritory(iTheirPlayer)`
- `pToPlot:IsFriendlyTerritory(iMyPlayer)`
- `pToPlot:IsFriendlyTerritory(c)`
- 12 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:1236`

### IsHills
- `plot:IsHills()`
- `pToPlot:IsHills()`
- `pPlot:IsHills()`
- 48 callsites. Example: `Maps/Great_Plains.lua:538`

### IsImpassable
- `plot:IsImpassable()`
- 3 callsites. Example: `Gameplay/Lua/MapGenerator.lua:618`

### IsImprovementPillaged
- `plot:IsImprovementPillaged()`
- 3 callsites. Example: `UI/InGame/PlotMouseoverInclude.lua:218`

### IsLake
- `plot:IsLake()`
- `adjPlot:IsLake()`
- `searchPlot:IsLake()`
- `pPlot:IsLake()`
- 79 callsites. Example: `Maps/Terra.lua:744`

### IsMountain
- `plot:IsMountain()`
- `pPlot:IsMountain()`
- 55 callsites. Example: `Maps/Great_Plains.lua:807`

### IsNEOfRiver
- `riverPlot:IsNEOfRiver()`
- 55 callsites. Example: `Maps/Four_Corners.lua:278`

### IsNWOfRiver
- `riverPlot:IsNWOfRiver()`
- 54 callsites. Example: `Maps/Four_Corners.lua:262`

### IsOpenGround
- `pToPlot:IsOpenGround()`
- 6 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:1002`

### IsOwned
- `pTargetPlot:IsOwned()`
- `pPlot:IsOwned()`
- 4 callsites. Example: `UI/InGame/GenericWorldAnchor.lua:154`

### IsResourceConnectedByImprovement
- `pPlot:IsResourceConnectedByImprovement(iImprovement)`
- 3 callsites. Example: `UI/InGame/WorldView/UnitPanel.lua:1289`

### IsRevealed
- `pPlot:IsRevealed(player:GetTeam())`
- `plot:IsRevealed(Game.GetActiveTeam(), false)`
- `pPlot:IsRevealed(pPlayer:GetTeam())`
- `pPlot:IsRevealed(iTeam, false)`
- `plot:IsRevealed(iActiveTeam, bIsDebug)`
- ...and 3 more distinct call shapes
- 69 callsites. Example: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:518`

### IsRiver
- `plot:IsRiver()`
- `searchPlot:IsRiver()`
- `pPlot:IsRiver()`
- 36 callsites. Example: `UI/InGame/PlotMouseoverInclude.lua:128`

### IsRiverSide
- `plot:IsRiverSide()`
- `searchPlot:IsRiverSide()`
- 33 callsites. Example: `Gameplay/Lua/AssignStartingPlots.lua:651`

### IsRoughGround
- `pToPlot:IsRoughGround()`
- 6 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:1032`

### IsRoutePillaged
- `plot:IsRoutePillaged()`
- 3 callsites. Example: `UI/InGame/PlotMouseoverInclude.lua:232`

### IsStartingPlot
- `otherPlot:IsStartingPlot()`
- 3 callsites. Example: `Gameplay/Lua/MapGenerator.lua:648`

### IsTradeRoute
- `plot:IsTradeRoute()`
- 6 callsites. Example: `UI/InGame/PlotHelpManager.lua:195`

### IsValidDomainForLocation
- `pPlot:IsValidDomainForLocation(pUnit)`
- 1 callsite. Example: `DLC/Expansion2/Scenarios/ScrambleAfricaScenario/PostProcessAfrica.lua:520`

### IsVisible
- `pPlot:IsVisible(iTeam, false)`
- `plot:IsVisible(player:GetTeam(), false)`
- `plot:IsVisible(iActiveTeam, bIsDebug)`
- `plot:IsVisible(Game.GetActiveTeam())`
- `pPlot:IsVisible(myTeamID, false)`
- ...and 1 more distinct call shapes
- 19 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:1874`

### IsVisibleEnemyUnit
- `pTargetPlot:IsVisibleEnemyUnit(player:GetID())`
- `plot:IsVisibleEnemyUnit(pUnit)`
- `plot:IsVisibleEnemyUnit(pCity:GetOwner())`
- `plot:IsVisibleEnemyUnit(pHeadSelectedUnit:GetOwner())`
- 13 callsites. Example: `Tutorial/lua/TutorialChecks.lua:1430`

### IsWater
- `riverPlot:IsWater()`
- `adjacentPlot:IsWater()`
- `plot:IsWater()`
- `adjPlot:IsWater()`
- `pTargetPlot:IsWater()`
- ...and 2 more distinct call shapes
- 500 callsites. Example: `Maps/Four_Corners.lua:250`

### IsWOfRiver
- `riverPlot:IsWOfRiver()`
- 57 callsites. Example: `Maps/Four_Corners.lua:250`

### SetArea
- `plot:SetArea(-1)`
- 3 callsites. Example: `Gameplay/Lua/MapGenerator.lua:567`

### SetContinentArtType
- `plot:SetContinentArtType(0)`
- `plot:SetContinentArtType(1)`
- `plot:SetContinentArtType(3)`
- `plot:SetContinentArtType(2)`
- 12 callsites. Example: `Maps/Great_Plains.lua:1610`

### SetFeatureType
- `plot:SetFeatureType(self.featureIce, -1)`
- `plot:SetFeatureType(featureForest, -1)`
- `forcePlot:SetFeatureType(FeatureTypes.NO_FEATURE, -1)`
- `plot:SetFeatureType(self.featureJungle, -1)`
- `plot:SetFeatureType(featureMarsh, -1)`
- ...and 28 more distinct call shapes
- 155 callsites. Example: `Maps/Ice_Age.lua:464`

### SetImprovementPillaged
- `plot:SetImprovementPillaged(true)`
- 3 callsites. Example: `UI/InGame/WorldView/WorldView.lua:213`

### SetImprovementType
- `pPlot:SetImprovementType(GameInfoTypes["IMPROVEMENT_WAJO"])`
- `plot:SetImprovementType(-1)`
- `plot:SetImprovementType(g_ImprovementPlopper.ImprovementType)`
- `plot:SetImprovementType(iImprovementID)`
- `plot:SetImprovementType(improvementID)`
- ...and 2 more distinct call shapes
- 23 callsites. Example: `DLC/DLC_05/Scenarios/KoreaScenario/TurnsRemaining.lua:442`

### SetNEOfRiver
- `riverPlot:SetNEOfRiver(true, thisFlowDirection)`
- `riverPlot:SetNEOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_SOUTHEAST)`
- `riverPlot:SetNEOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHWEST)`
- 60 callsites. Example: `Maps/Four_Corners.lua:283`

### SetNWOfRiver
- `riverPlot:SetNWOfRiver(true, thisFlowDirection)`
- `riverPlot:SetNWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_SOUTHWEST)`
- `riverPlot:SetNWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTHEAST)`
- 62 callsites. Example: `Maps/Four_Corners.lua:267`

### SetOwner
- `plot:SetOwner(Spain_PlayerID, city_ID, true, true)`
- `plot:SetOwner(France_PlayerID, city_ID, true, true)`
- `plot:SetOwner(England_PlayerID, city_ID, true, true)`
- `plot:SetOwner(-1, -1, false, false)`
- `plot:SetOwner(Netherlands_PlayerID, city_ID, true, true)`
- ...and 4 more distinct call shapes
- 13 callsites. Example: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/NewWorld_Scenario_MapScript.lua:2572`

### SetPlotType
- `plot:SetPlotType(PlotTypes.PLOT_LAND, false, false)`
- `plot:SetPlotType(PlotTypes.PLOT_HILLS, false, false)`
- `plot:SetPlotType(PlotTypes.PLOT_MOUNTAIN, false, false)`
- `forcePlot:SetPlotType(PlotTypes.PLOT_LAND, false, true)`
- `plot:SetPlotType(PlotTypes.PLOT_HILLS, false, true)`
- ...and 8 more distinct call shapes
- 116 callsites. Example: `Maps/North_vs_South.lua:138`

### SetResourceType
- `res_plot:SetResourceType(res_ID[use_this_res_index], res_quantity[use_this_res_index])`
- `plot:SetResourceType(self.deer_ID, 1)`
- `plot:SetResourceType(self.cow_ID, 1)`
- `plot:SetResourceType(self.wheat_ID, 1)`
- `res_plot:SetResourceType(selected_ID, selected_quantity)`
- ...and 22 more distinct call shapes
- 119 callsites. Example: `Gameplay/Lua/AssignStartingPlots.lua:7367`

### SetRevealed
- `pPlot:SetRevealed(team, false)`
- `pPlot:SetRevealed(team, bIsDebug)`
- `plot:SetRevealed(Spain_PlayerID, true)`
- `plot:SetRevealed(France_PlayerID, true)`
- `plot:SetRevealed(England_PlayerID, true)`
- ...and 4 more distinct call shapes
- 16 callsites. Example: `UI/InGame/InGame.lua:95`

### SetRouteType
- `plot:SetRouteType(iRouteID)`
- 3 callsites. Example: `UI/InGame/WorldView/WorldView.lua:274`

### SetTerrainType
- `plot:SetTerrainType(TerrainTypes.TERRAIN_GRASS, false, false)`
- `adjPlot:SetTerrainType(TerrainTypes.TERRAIN_COAST, false, false)`
- `plot:SetTerrainType(self.terrainPlains, false, true)`
- `forcePlot:SetTerrainType(TerrainTypes.TERRAIN_GRASS, false, true)`
- `plot:SetTerrainType(self.terrainTundra, false, true)`
- ...and 10 more distinct call shapes
- 107 callsites. Example: `Gameplay/Lua/AssignStartingPlots.lua:4049`

### SetWOfRiver
- `riverPlot:SetWOfRiver(true, thisFlowDirection)`
- `riverPlot:SetWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_NORTH)`
- `riverPlot:SetWOfRiver(true, FlowDirectionTypes.FLOWDIRECTION_SOUTH)`
- 62 callsites. Example: `Maps/Four_Corners.lua:255`
