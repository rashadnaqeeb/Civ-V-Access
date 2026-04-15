# Map

World / map queries. Static table.

Extracted from 4097 call sites across 27 distinct methods in the shipped game Lua.

## Methods

### Areas
- `Map.Areas()`
- 3 callsites. Example: `Gameplay/Lua/WorldBuilderRandomItems.lua:141`

### CalculateAreas
- `Map.CalculateAreas()`
- 3 callsites. Example: `Gameplay/Lua/MapGenerator.lua:579`

### ChangeAIMapHint
- `Map.ChangeAIMapHint(4)`
- `Map.ChangeAIMapHint(1+4)`
- `Map.ChangeAIMapHint(1)`
- `Map.ChangeAIMapHint(5)`
- `Map.ChangeAIMapHint(2)`
- ...and 1 more distinct call shapes
- 21 callsites. Example: `Maps/SmallContinents.lua:127`

### DefaultContinentStamper
- `Map.DefaultContinentStamper()`
- 3 callsites. Example: `Gameplay/Lua/MapGenerator.lua:739`

### FindBiggestArea
- `Map.FindBiggestArea(false)`
- `Map.FindBiggestArea(true)`
- `Map.FindBiggestArea(False)`
- 36 callsites. Example: `Maps/Continents.lua:186`

### FindWater
- `Map.FindWater(plot, riverSourceRange, true)`
- `Map.FindWater(plot, seaWaterRange, false)`
- 26 callsites. Example: `Maps/Great_Plains.lua:845`

### GetArea
- `Map.GetArea(iArea)`
- `Map.GetArea(iAreaID)`
- `Map.GetArea(areaID)`
- `Map.GetArea(testAreaID)`
- 13 callsites. Example: `Gameplay/Lua/FeatureGenerator.lua:391`

### GetClimate
- `Map.GetClimate()`
- 3 callsites. Example: `Gameplay/Lua/FeatureGenerator.lua:275`

### GetCustomOption
- `Map.GetCustomOption(1)`
- `Map.GetCustomOption(4)`
- `Map.GetCustomOption(3)`
- `Map.GetCustomOption(2)`
- `Map.GetCustomOption(5)`
- ...and 1 more distinct call shapes
- 159 callsites. Example: `Maps/Archipelago.lua:38`

### GetFractalFlags
- `Map.GetFractalFlags()`
- 44 callsites. Example: `Maps/Continents.lua:47`

### GetGridSize
- `Map.GetGridSize()`
- 387 callsites. Example: `Maps/Continents.lua:36`

### GetNumPlots
- `Map.GetNumPlots()`
- 21 callsites. Example: `UI/InGame/InGame.lua:89`

### GetNumResources
- `Map.GetNumResources(resourceID)`
- 10 callsites. Example: `Gameplay/Lua/WorldBuilderRandomItems.lua:71`

### GetNumResourcesOnLand
- `Map.GetNumResourcesOnLand(resourceID)`
- 4 callsites. Example: `Gameplay/Lua/WorldBuilderRandomItems.lua:71`

### GetPlot
- `Map.GetPlot(x, y)`
- `Map.GetPlot(iX, iY)`
- `Map.GetPlot(UI.GetMouseOverHex())`
- `Map.GetPlot(searchX, searchY)`
- `Map.GetPlot(realX, realY)`
- ...and 345 more distinct call shapes
- 1136 callsites. Example: `Maps/Continents.lua:226`

### GetPlotByIndex
- `Map.GetPlotByIndex(iPlotLoop)`
- `Map.GetPlotByIndex(i)`
- `Map.GetPlotByIndex(index)`
- `Map.GetPlotByIndex(plotIndex)`
- `Map.GetPlotByIndex(popupInfo.Data2)`
- 20 callsites. Example: `UI/InGame/InGame.lua:90`

### GetPlotXY
- `Map.GetPlotXY(thisX, thisY, iDX, iDY)`
- `Map.GetPlotXY(plotX, plotY, dx, dy)`
- `Map.GetPlotXY(iX, iY, iDX, iDY)`
- `Map.GetPlotXY(iPlotX, iPlotY, iDX, iDY)`
- 33 callsites. Example: `UI/InGame/Bombardment.lua:49`

### GetRandomResourceQuantity
- `Map.GetRandomResourceQuantity(resourceID)`
- 12 callsites. Example: `Gameplay/Lua/WorldBuilderRandomItems.lua:173`

### GetSeaLevel
- `Map.GetSeaLevel()`
- 3 callsites. Example: `Gameplay/Lua/ContinentsWorld.lua:31`

### GetWorldSize
- `Map.GetWorldSize()`
- 91 callsites. Example: `Maps/Continents.lua:121`

### IsWrapX
- `Map:IsWrapX()`
- `Map.IsWrapX()`
- 47 callsites. Example: `Gameplay/Lua/AssignStartingPlots.lua:583`

### IsWrapY
- `Map:IsWrapY()`
- 43 callsites. Example: `Gameplay/Lua/AssignStartingPlots.lua:588`

### PlotDirection
- `Map.PlotDirection(riverPlot:GetX(), riverPlot:GetY(), DirectionTypes.DIRECTION_EAST)`
- `Map.PlotDirection(riverPlot:GetX(), riverPlot:GetY(), DirectionTypes.DIRECTION_SOUTHEAST)`
- `Map.PlotDirection(riverPlot:GetX(), riverPlot:GetY(), DirectionTypes.DIRECTION_SOUTHWEST)`
- `Map.PlotDirection(riverPlotX, riverPlotY, DirectionTypes.DIRECTION_NORTHWEST)`
- `Map.PlotDirection(x, y, direction)`
- ...and 22 more distinct call shapes
- 564 callsites. Example: `Maps/Four_Corners.lua:249`

### PlotDistance
- `Map.PlotDistance(thisX, thisY, plotX, plotY)`
- `Map.PlotDistance(plotX, plotY, otherPlot:GetX(), otherPlot:GetY())`
- `Map.PlotDistance(iPlotX, iPlotY, plotX, plotY)`
- `Map.PlotDistance(pFirstUnitPlot:GetX(), pFirstUnitPlot:GetY(), pSecondUnitPlot:GetX(), pSecondUnitPlot:GetY())`
- `Map.PlotDistance(pCapital:GetX(), pCapital:GetY(), pMyUnit:GetX(), pMyUnit:GetY())`
- ...and 16 more distinct call shapes
- 53 callsites. Example: `UI/InGame/Bombardment.lua:71`

### PlotXYWithRangeCheck
- `Map.PlotXYWithRangeCheck(plot:GetX(), plot:GetY(), dx, dy, groupRange)`
- `Map.PlotXYWithRangeCheck(unitX, unitY, iX, iY, iRange)`
- `Map.PlotXYWithRangeCheck(plotX, plotY, dx, dy, uniqueRange)`
- `Map.PlotXYWithRangeCheck(plotX, plotY, dx, dy, 4)`
- `Map.PlotXYWithRangeCheck(iCityStateX, iCityStateY, iX, iY, iRange)`
- 17 callsites. Example: `Gameplay/Lua/WorldBuilderRandomItems.lua:181`

### Rand
- `Map.Rand(die_1 + die_2, "Number_of_dots_to_add_to_island_chain_-_Lua")`
- `Map.Rand(x_shrinkage, "Cell_Width_offset_-_Lua")`
- `Map.Rand(y_shrinkage, "Cell_Height_offset_-_Lua")`
- `Map.Rand(4, "Diceroll_-_Lua")`
- `Map.Rand(3, "Random_World_Age_-_Lua")`
- ...and 190 more distinct call shapes
- 1312 callsites. Example: `DLC/Expansion/Maps/Hemispheres.lua:440`

### RecalculateAreas
- `Map.RecalculateAreas()`
- 33 callsites. Example: `Maps/Continents.lua:184`
