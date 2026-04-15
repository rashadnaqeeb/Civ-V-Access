# City

Methods on City handles. Obtain via `pPlayer:GetCityByID(cityID)`, `pPlot:GetPlotCity()`, or iteration with `pPlayer:Cities()`.

Extracted from 2194 call sites across 164 distinct methods in the shipped game Lua.

## Methods

### AdoptReligionFully
- `pCity:AdoptReligionFully(GameInfoTypes["RELIGION_CHRISTIANITY"])`
- `capital:AdoptReligionFully(GameInfoTypes["RELIGION_CHRISTIANITY"])`
- `capital:AdoptReligionFully(GameInfoTypes["RELIGION_ISLAM"])`
- `pCity:AdoptReligionFully(GameInfoTypes["RELIGION_ISLAM"])`
- `capital:AdoptReligionFully(GameInfoTypes["RELIGION_PROTESTANTISM"])`
- ...and 3 more distinct call shapes
- 38 callsites. Example: `DLC/Expansion/Scenarios/MedievalScenario/TurnsRemaining.lua:928`

### CanBuyPlotAt
- `pCity:CanBuyPlotAt(plot:GetX(), plot:GetY(), false)`
- `pCity:CanBuyPlotAt(plot:GetX(), plot:GetY(), true)`
- `city:CanBuyPlotAt(hexX, hexY, true)`
- 9 callsites. Example: `UI/InGame/CityView/CityView.lua:1863`

### CanConstruct
- `pCity:CanConstruct(buildingID)`
- `city:CanConstruct(buildingID, 0, 1)`
- `city:CanConstruct(buildingID)`
- 10 callsites. Example: `Tutorial/lua/TutorialChecks.lua:2901`

### CanConstructTooltip
- `pCity:CanConstructTooltip(id)`
- 3 callsites. Example: `UI/InGame/Popups/ProductionPopup.lua:1018`

### CanCreate
- `city:CanCreate(projectID, 0, 1)`
- `city:CanCreate(projectID)`
- 6 callsites. Example: `UI/InGame/Popups/ProductionPopup.lua:350`

### CanMaintain
- `city:CanMaintain(processID, 1)`
- `city:CanMaintain(processID)`
- 3 callsites. Example: `UI/InGame/Popups/ProductionPopup.lua:474`

### CanRangeStrike
- `pHeadSelectedCity:CanRangeStrike()`
- `city:CanRangeStrike()`
- 6 callsites. Example: `UI/InGame/Bombardment.lua:24`

### CanRangeStrikeAt
- `pHeadSelectedCity:CanRangeStrikeAt(plotX,plotY, true, true)`
- 3 callsites. Example: `UI/InGame/WorldView/WorldView.lua:509`

### CanRangeStrikeNow
- `city:CanRangeStrikeNow()`
- 4 callsites. Example: `UI/InGame/CityBannerManager.lua:36`

### CanTrain
- `city:CanTrain(unitID, 0, 1)`
- `city:CanTrain(unitID)`
- `city:CanTrain(unitID, iIsCurrentlyBuilding)`
- 6 callsites. Example: `UI/InGame/Popups/ProductionPopup.lua:295`

### CanTrainTooltip
- `pCity:CanTrainTooltip(id)`
- 3 callsites. Example: `UI/InGame/Popups/ProductionPopup.lua:958`

### CanWork
- `pCity:CanWork(plot)`
- 3 callsites. Example: `UI/InGame/CityView/CityView.lua:1830`

### ChangeProduction
- `pCapital:ChangeProduction(pCapital:ProductionLeft())`
- 1 callsite. Example: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:1317`

### ChooseProduction
- `city:ChooseProduction()`
- 1 callsite. Example: `DLC/DLC_01/Scenarios/Mongol Scenario/CivsAlive.lua:202`

### ConvertPercentFollowers
- `pCity:ConvertPercentFollowers(GameInfoTypes["RELIGION_PROTESTANTISM"], GameInfoTypes["RELIGION_CHRISTIANITY"], 40)`
- `city:ConvertPercentFollowers(-1, GameInfoTypes["RELIGION_AZTEC_PANTHEON"], 100)`
- `city:ConvertPercentFollowers(-1, GameInfoTypes["RELIGION_INCA_PANTHEON"], 100)`
- `city:ConvertPercentFollowers(-1, GameInfoTypes["RELIGION_IROQUOIS_PANTHEON"], 100)`
- `city:ConvertPercentFollowers(-1, GameInfoTypes["RELIGION_MAYA_PANTHEON"], 100)`
- ...and 1 more distinct call shapes
- 6 callsites. Example: `DLC/Expansion/Scenarios/MedievalScenario/TurnsRemaining.lua:1596`

### FoodConsumption
- `city:FoodConsumption(true)`
- `pCity:FoodConsumption(true, 0)`
- 10 callsites. Example: `UI/InGame/CityBannerManager.lua:313`

### FoodDifference
- `pCity:FoodDifference()`
- `city:FoodDifference()`
- `pLoopCity:FoodDifference()`
- 27 callsites. Example: `UI/InGame/CityList.lua:181`

### FoodDifferenceTimes100
- `pCity:FoodDifferenceTimes100()`
- `city:FoodDifferenceTimes100()`
- 26 callsites. Example: `UI/InGame/CityList.lua:198`

### GetAirStrikeDefenseDamage
- `pCity:GetAirStrikeDefenseDamage(pMyUnit, false)`
- 3 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:330`

### GetBaseTourism
- `pCity:GetBaseTourism()`
- `city:GetBaseTourism()`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/CityView/CityView.lua:1662`

### GetBaseYieldRate
- `pCity:GetBaseYieldRate(YieldTypes.YIELD_PRODUCTION)`
- `pCity:GetBaseYieldRate(iYieldType)`
- 9 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:461`

### GetBaseYieldRateFromBuildings
- `pCity:GetBaseYieldRateFromBuildings(iYieldType)`
- 3 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:654`

### GetBaseYieldRateFromMisc
- `pCity:GetBaseYieldRateFromMisc(iYieldType)`
- 3 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:668`

### GetBaseYieldRateFromReligion
- `pCity:GetBaseYieldRateFromReligion(iYieldType)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/InfoTooltipInclude.lua:851`

### GetBaseYieldRateFromSpecialists
- `pCity:GetBaseYieldRateFromSpecialists(iYieldType)`
- 3 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:661`

### GetBaseYieldRateFromTerrain
- `pCity:GetBaseYieldRateFromTerrain(iYieldType)`
- `pCity:GetBaseYieldRateFromTerrain(YieldTypes.YIELD_CULTURE)`
- `pCity:GetBaseYieldRateFromTerrain(YieldTypes.YIELD_FAITH)`
- 7 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:647`

### GetBuildingEspionageModifier
- `pCity:GetBuildingEspionageModifier(buildingID)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/EspionageOverview.lua:848`

### GetBuildingFaithPurchaseCost
- `capital:GetBuildingFaithPurchaseCost(GameInfo.Buildings[v2].ID, true)`
- `capital:GetBuildingFaithPurchaseCost(building.ID)`
- `city:GetBuildingFaithPurchaseCost(buildingID)`
- 8 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ReligionOverview.lua:379`

### GetBuildingGlobalEspionageModifier
- `pCity:GetBuildingGlobalEspionageModifier(buildingID)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/EspionageOverview.lua:849`

### GetBuildingGreatWork
- `pCity:GetBuildingGreatWork(iBuildingClass, i)`
- `city:GetBuildingGreatWork(v.BuildingClassID, greatWorkSlotIndex - 1)`
- `city:GetBuildingGreatWork(buildingClassID, greatWorkSlotIndex - 1)`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/CityView/CityView.lua:381`

### GetBuildingProductionTurnsLeft
- `city:GetBuildingProductionTurnsLeft(queuedData1, queuedItemNumber-1)`
- `city:GetBuildingProductionTurnsLeft(buildingID)`
- `city:GetBuildingProductionTurnsLeft(queuedData1, i-1)`
- 9 callsites. Example: `UI/InGame/CityView/CityView.lua:607`

### GetBuildingPurchaseCost
- `city:GetBuildingPurchaseCost(buildingID)`
- 3 callsites. Example: `UI/InGame/Popups/ProductionPopup.lua:423`

### GetBuildingYieldChange
- `pCapital:GetBuildingYieldChange(palace,faith)`
- 1 callsite. Example: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:1384`

### GetBuyablePlotList
- `pCity:GetBuyablePlotList()`
- 6 callsites. Example: `UI/InGame/CityView/CityView.lua:1884`

### GetBuyPlotCost
- `pCity:GetBuyPlotCost(plot:GetX(), plot:GetY())`
- `city:GetBuyPlotCost(hexX, hexY)`
- 9 callsites. Example: `UI/InGame/CityView/CityView.lua:1866`

### GetCityIndexPlot
- `pCity:GetCityIndexPlot(i)`
- `pHeadSelectedCity:GetCityIndexPlot(iPlotIndex)`
- 9 callsites. Example: `UI/InGame/CityView/CityView.lua:1746`

### GetCultureFromSpecialist
- `pCity:GetCultureFromSpecialist(iSpecialistID)`
- 9 callsites. Example: `UI/InGame/CityView/CityView.lua:418`

### GetCultureRateModifier
- `pCity:GetCultureRateModifier()`
- 3 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:570`

### GetCurrentProductionDifference
- `pLoopCity:GetCurrentProductionDifference(bIgnoreFood, bOverflow)`
- `pCity:GetCurrentProductionDifference(false, false)`
- 4 callsites. Example: `UI/InGame/Popups/WhosWinningPopup.lua:213`

### GetCurrentProductionDifferenceTimes100
- `city:GetCurrentProductionDifferenceTimes100(false, false)`
- `pCity:GetCurrentProductionDifferenceTimes100(false, false)`
- 27 callsites. Example: `UI/InGame/CityBannerManager.lua:278`

### GetDamage
- `pCity:GetDamage()`
- `city:GetDamage()`
- 20 callsites. Example: `UI/InGame/CityList.lua:142`

### GetFaithBuildingTourism
- `pCity:GetFaithBuildingTourism()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/InfoTooltipInclude.lua:284`

### GetFaithPerTurn
- `pCity:GetFaithPerTurn()`
- `city:GetFaithPerTurn()`
- 6 callsites. Example: `DLC/Expansion2/UI/InGame/CityView/CityView.lua:1658`

### GetFaithPerTurnFromBuildings
- `pCity:GetFaithPerTurnFromBuildings()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/InfoTooltipInclude.lua:707`

### GetFaithPerTurnFromPolicies
- `pCity:GetFaithPerTurnFromPolicies()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/InfoTooltipInclude.lua:728`

### GetFaithPerTurnFromReligion
- `pCity:GetFaithPerTurnFromReligion()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/InfoTooltipInclude.lua:735`

### GetFaithPerTurnFromTraits
- `pCity:GetFaithPerTurnFromTraits()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/InfoTooltipInclude.lua:714`

### GetFaithPurchaseBuildingTooltip
- `pCity:GetFaithPurchaseBuildingTooltip(id)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ProductionPopup.lua:1310`

### GetFaithPurchaseUnitTooltip
- `pCity:GetFaithPurchaseUnitTooltip(id)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ProductionPopup.lua:1245`

### GetFirstBuildingOrder
- `pCity:GetFirstBuildingOrder(buildingID)`
- 1 callsite. Example: `DLC/DLC_06/Scenarios/WonderScenario/WonderStatus.lua:361`

### GetFocusType
- `pCity:GetFocusType()`
- 3 callsites. Example: `UI/InGame/CityView/CityView.lua:948`

### GetFood
- `pCity:GetFood()`
- `city:GetFood()`
- 19 callsites. Example: `UI/InGame/CityList.lua:179`

### GetFoodTimes100
- `pCity:GetFoodTimes100()`
- 3 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:409`

### GetFoodTurnsLeft
- `pCity:GetFoodTurnsLeft()`
- `city:GetFoodTurnsLeft()`
- 16 callsites. Example: `UI/InGame/CityList.lua:196`

### GetGarrisonedUnit
- `city:GetGarrisonedUnit()`
- `pCity:GetGarrisonedUnit()`
- 13 callsites. Example: `UI/InGame/CityBannerManager.lua:237`

### GetGreatPeopleRateModifier
- `city:GetGreatPeopleRateModifier()`
- `pCity:GetGreatPeopleRateModifier()`
- 6 callsites. Example: `UI/InGame/GPList.lua:238`

### GetHappiness
- `pCity:GetHappiness()`
- 3 callsites. Example: `UI/InGame/Popups/HappinessInfo.lua:270`

### GetID
- `pCity:GetID()`
- `city:GetID()`
- `pHeadSelectedCity:GetID()`
- 108 callsites. Example: `UI/InGame/CityBannerManager.lua:1267`

### GetJONSCulturePerTurn
- `pCity:GetJONSCulturePerTurn()`
- `city:GetJONSCulturePerTurn()`
- 13 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:587`

### GetJONSCulturePerTurnFromBuildings
- `pCity:GetJONSCulturePerTurnFromBuildings()`
- 3 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:493`

### GetJONSCulturePerTurnFromGreatWorks
- `pCity:GetJONSCulturePerTurnFromGreatWorks()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/InfoTooltipInclude.lua:571`

### GetJONSCulturePerTurnFromLeagues
- `pCity:GetJONSCulturePerTurnFromLeagues()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/InfoTooltipInclude.lua:599`

### GetJONSCulturePerTurnFromPolicies
- `pCity:GetJONSCulturePerTurnFromPolicies()`
- 3 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:507`

### GetJONSCulturePerTurnFromReligion
- `pCity:GetJONSCulturePerTurnFromReligion()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/InfoTooltipInclude.lua:585`

### GetJONSCulturePerTurnFromSpecialists
- `pCity:GetJONSCulturePerTurnFromSpecialists()`
- 3 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:521`

### GetJONSCulturePerTurnFromTerrain
- `pCity:GetJONSCulturePerTurnFromTerrain()`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:535`

### GetJONSCulturePerTurnFromTraits
- `pCity:GetJONSCulturePerTurnFromTraits()`
- 3 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:549`

### GetJONSCultureStored
- `pCity:GetJONSCultureStored()`
- 6 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:588`

### GetJONSCultureThreshold
- `pCity:GetJONSCultureThreshold()`
- 6 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:589`

### GetLeagueBuildingClassYieldChange
- `pCity:GetLeagueBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_CULTURE)`
- `pCity:GetLeagueBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_FAITH)`
- `pCity:GetLeagueBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_FOOD)`
- `pCity:GetLeagueBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_GOLD)`
- `pCity:GetLeagueBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_SCIENCE)`
- ...and 1 more distinct call shapes
- 6 callsites. Example: `DLC/Expansion2/UI/InGame/InfoTooltipInclude.lua:170`

### GetLocalHappiness
- `pCity:GetLocalHappiness()`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/HappinessInfo.lua:337`

### GetMaxHitPoints
- `pCity:GetMaxHitPoints()`
- `city:GetMaxHitPoints()`
- 12 callsites. Example: `UI/InGame/CityList.lua:137`

### GetName
- `city:GetName()`
- `pCity:GetName()`
- `pTargetCity:GetName()`
- `capital:GetName()`
- 99 callsites. Example: `UI/InGame/Popups/ProductionPopup.lua:228`

### GetNameKey
- `city:GetNameKey()`
- `pCity:GetNameKey()`
- `pTargetCity:GetNameKey()`
- 50 callsites. Example: `UI/InGame/CityBannerManager.lua:154`

### GetNumCityPlots
- `pCity:GetNumCityPlots()`
- 6 callsites. Example: `UI/InGame/CityView/CityView.lua:1745`

### GetNumFollowers
- `city:GetNumFollowers(iReligionID)`
- `city:GetNumFollowers(eReligion)`
- 6 callsites. Example: `DLC/Expansion2/UI/InGame/InfoTooltipInclude.lua:1261`

### GetNumForcedWorkingPlots
- `pCity:GetNumForcedWorkingPlots()`
- 3 callsites. Example: `UI/InGame/CityView/CityView.lua:967`

### GetNumFreeBuilding
- `pCity:GetNumFreeBuilding(buildingID)`
- 3 callsites. Example: `UI/InGame/CityView/CityView.lua:309`

### GetNumGreatWorks
- `city:GetNumGreatWorks()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/CultureOverview.lua:686`

### GetNumSpecialistsAllowedByBuilding
- `pCity:GetNumSpecialistsAllowedByBuilding(buildingID)`
- 10 callsites. Example: `UI/InGame/CityView/CityView.lua:343`

### GetNumSpecialistsInBuilding
- `pCity:GetNumSpecialistsInBuilding(buildingID)`
- `pCity:GetNumSpecialistsInBuilding(iBuilding)`
- 6 callsites. Example: `UI/InGame/CityView/CityView.lua:360`

### GetNumTradeRoutesAddingPressure
- `city:GetNumTradeRoutesAddingPressure(iReligionID)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/InfoTooltipInclude.lua:1289`

### GetNumWorldWonders
- `pCity:GetNumWorldWonders()`
- 3 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:577`

### GetOrderFromQueue
- `city:GetOrderFromQueue(i-1)`
- `city:GetOrderFromQueue(queuedItemNumber-1)`
- 9 callsites. Example: `UI/InGame/Popups/ProductionPopup.lua:180`

### GetOrderQueueLength
- `city:GetOrderQueueLength()`
- `pCity:GetOrderQueueLength()`
- 15 callsites. Example: `UI/InGame/CityView/CityView.lua:1925`

### GetOriginalOwner
- `pCity:GetOriginalOwner()`
- `city:GetOriginalOwner()`
- 15 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/VictoryProgress.lua:302`

### GetOwner
- `pCity:GetOwner()`
- `city:GetOwner()`
- `pTargetCity:GetOwner()`
- `pHeadSelectedCity:GetOwner()`
- 108 callsites. Example: `UI/InGame/CityView/CityView.lua:71`

### GetPopulation
- `pCity:GetPopulation()`
- `city:GetPopulation()`
- 35 callsites. Example: `UI/InGame/CityList.lua:173`

### GetPressurePerTurn
- `city:GetPressurePerTurn(eReligion)`
- `city:GetPressurePerTurn(iReligionID)`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/InfoTooltipInclude.lua:1237`

### GetPreviousOwner
- `city:GetPreviousOwner()`
- `pCity:GetPreviousOwner()`
- 3 callsites. Example: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:242`

### GetProduction
- `city:GetProduction()`
- `pCity:GetProduction()`
- 8 callsites. Example: `UI/InGame/CityBannerManager.lua:309`

### GetProductionBuilding
- `city:GetProductionBuilding()`
- `pCity:GetProductionBuilding()`
- 23 callsites. Example: `UI/InGame/CityBannerManager.lua:362`

### GetProductionModifier
- `pCity:GetProductionModifier()`
- `city:GetProductionModifier()`
- 12 callsites. Example: `UI/InGame/CityView/CityView.lua:1548`

### GetProductionNameKey
- `city:GetProductionNameKey()`
- `pCity:GetProductionNameKey()`
- 20 callsites. Example: `UI/InGame/CityBannerManager.lua:330`

### GetProductionNeeded
- `city:GetProductionNeeded()`
- `pCity:GetProductionNeeded()`
- 13 callsites. Example: `UI/InGame/CityBannerManager.lua:310`

### GetProductionProcess
- `city:GetProductionProcess()`
- `pCity:GetProductionProcess()`
- 20 callsites. Example: `UI/InGame/CityBannerManager.lua:364`

### GetProductionProject
- `city:GetProductionProject()`
- `pCity:GetProductionProject()`
- 19 callsites. Example: `UI/InGame/CityBannerManager.lua:363`

### GetProductionTimes100
- `pCity:GetProductionTimes100()`
- `city:GetProductionTimes100()`
- 6 callsites. Example: `UI/InGame/CityView/CityView.lua:1540`

### GetProductionTurnsLeft
- `city:GetProductionTurnsLeft()`
- `pCity:GetProductionTurnsLeft()`
- 16 callsites. Example: `UI/InGame/CityBannerManager.lua:279`

### GetProductionUnit
- `city:GetProductionUnit()`
- `pCity:GetProductionUnit()`
- 20 callsites. Example: `UI/InGame/CityBannerManager.lua:361`

### GetProjectProductionTurnsLeft
- `city:GetProjectProductionTurnsLeft(queuedData1, queuedItemNumber-1)`
- `city:GetProjectProductionTurnsLeft(projectID)`
- `city:GetProjectProductionTurnsLeft(queuedData1, i-1)`
- 9 callsites. Example: `UI/InGame/CityView/CityView.lua:616`

### GetProjectPurchaseCost
- `city:GetProjectPurchaseCost(projectID)`
- 3 callsites. Example: `UI/InGame/Popups/ProductionPopup.lua:371`

### GetPurchaseBuildingTooltip
- `pCity:GetPurchaseBuildingTooltip(id)`
- 3 callsites. Example: `UI/InGame/Popups/ProductionPopup.lua:1023`

### GetPurchaseUnitTooltip
- `pCity:GetPurchaseUnitTooltip(id)`
- 3 callsites. Example: `UI/InGame/Popups/ProductionPopup.lua:963`

### GetRawProductionDifference
- `pCity:GetRawProductionDifference(true, false)`
- 1 callsite. Example: `DLC/Expansion/Scenarios/SteampunkScenario/TurnsRemaining.lua:238`

### GetRazingTurns
- `city:GetRazingTurns()`
- `pCity:GetRazingTurns()`
- 6 callsites. Example: `UI/InGame/CityBannerManager.lua:193`

### GetReligionBuildingClassHappiness
- `pCity:GetReligionBuildingClassHappiness(buildingClassID)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/InfoTooltipInclude.lua:160`

### GetReligionBuildingClassYieldChange
- `pCity:GetReligionBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_CULTURE)`
- `pCity:GetReligionBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_FAITH)`
- `pCity:GetReligionBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_FOOD)`
- `pCity:GetReligionBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_GOLD)`
- `pCity:GetReligionBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_SCIENCE)`
- ...and 1 more distinct call shapes
- 12 callsites. Example: `DLC/Expansion2/UI/InGame/InfoTooltipInclude.lua:169`

### GetReligiousMajority
- `city:GetReligiousMajority()`
- `pCity:GetReligiousMajority()`
- `pCapital:GetReligiousMajority()`
- 9 callsites. Example: `DLC/Expansion2/UI/InGame/CityBannerManager.lua:222`

### GetResistanceTurns
- `city:GetResistanceTurns()`
- `pCity:GetResistanceTurns()`
- 6 callsites. Example: `UI/InGame/CityBannerManager.lua:201`

### GetResourceDemanded
- `pCity:GetResourceDemanded(true)`
- `pCity:GetResourceDemanded()`
- 6 callsites. Example: `UI/InGame/CityView/CityView.lua:1299`

### GetSellBuildingRefund
- `pCity:GetSellBuildingRefund(iBuildingID)`
- 3 callsites. Example: `UI/InGame/CityView/CityView.lua:2389`

### GetSpecialistCount
- `city:GetSpecialistCount(specialistInfo.ID)`
- `pCity:GetSpecialistCount(slackerType)`
- `pCity:GetSpecialistCount(pSpecialistInfo.ID)`
- 9 callsites. Example: `UI/InGame/GPList.lua:226`

### GetSpecialistGreatPersonProgress
- `pCity:GetSpecialistGreatPersonProgress(iSpecialistIndex)`
- `city:GetSpecialistGreatPersonProgress(iSpecialistIndex)`
- 12 callsites. Example: `UI/InGame/GPList.lua:107`

### GetSpecialistUpgradeThreshold
- `pCity:GetSpecialistUpgradeThreshold()`
- `pCity:GetSpecialistUpgradeThreshold(iUnitClass)`
- `pCity:GetSpecialistUpgradeThreshold(unitClass.ID)`
- 6 callsites. Example: `UI/InGame/GPList.lua:120`

### GetSpecialistYield
- `pCity:GetSpecialistYield(iSpecialistID, iYieldID)`
- 9 callsites. Example: `UI/InGame/CityView/CityView.lua:425`

### GetStrengthValue
- `pCity:GetStrengthValue()`
- `city:GetStrengthValue()`
- 16 callsites. Example: `UI/InGame/CityList.lua:124`

### GetTeam
- `pCity:GetTeam()`
- `pHeadSelectedCity:GetTeam()`
- `city:GetTeam()`
- 8 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:1859`

### GetThemingBonus
- `pCity:GetThemingBonus(iBuildingClass)`
- `city:GetThemingBonus(v.BuildingClassID)`
- `city:GetThemingBonus(wonder.BuildingClassID)`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/CityView/CityView.lua:370`

### GetThemingTooltip
- `pCity:GetThemingTooltip(iBuildingClass)`
- `city:GetThemingTooltip(v.BuildingClassID)`
- `city:GetThemingTooltip(wonder.BuildingClassID)`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/CityView/CityView.lua:372`

### GetTotalBaseBuildingMaintenance
- `pCity:GetTotalBaseBuildingMaintenance()`
- 6 callsites. Example: `UI/InGame/CityView/CityView.lua:1126`

### GetTotalSlotsTooltip
- `city:GetTotalSlotsTooltip()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/CultureOverview.lua:687`

### GetTourismTooltip
- `pCity:GetTourismTooltip()`
- `city:GetTourismTooltip()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/InfoTooltipInclude.lua:762`

### GetUnitFaithPurchaseCost
- `capital:GetUnitFaithPurchaseCost(GameInfo.Units[v2].ID, true)`
- `capital:GetUnitFaithPurchaseCost(unit.ID, true)`
- `capital:GetUnitFaithPurchaseCost(infoID, true)`
- `city:GetUnitFaithPurchaseCost(unitID, true)`
- 10 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ReligionOverview.lua:375`

### GetUnitProductionTurnsLeft
- `city:GetUnitProductionTurnsLeft(queuedData1, queuedItemNumber-1)`
- `city:GetUnitProductionTurnsLeft(unitID)`
- `city:GetUnitProductionTurnsLeft(queuedData1, i-1)`
- 9 callsites. Example: `UI/InGame/CityView/CityView.lua:598`

### GetUnitPurchaseCost
- `city:GetUnitPurchaseCost(unitID)`
- 3 callsites. Example: `UI/InGame/Popups/ProductionPopup.lua:320`

### GetWeLoveTheKingDayCounter
- `pCity:GetWeLoveTheKingDayCounter()`
- 3 callsites. Example: `UI/InGame/CityView/CityView.lua:1308`

### GetX
- `capital:GetX()`
- `pCity:GetX()`
- `pCapital:GetX()`
- `city:GetX()`
- `pHeadSelectedCity:GetX()`
- ...and 1 more distinct call shapes
- 149 callsites. Example: `DLC/Expansion2/Scenarios/CivilWarScenario/TurnsRemaining.lua:337`

### GetY
- `capital:GetY()`
- `pCity:GetY()`
- `pCapital:GetY()`
- `city:GetY()`
- `pHeadSelectedCity:GetY()`
- ...and 1 more distinct call shapes
- 145 callsites. Example: `DLC/Expansion2/Scenarios/CivilWarScenario/TurnsRemaining.lua:337`

### GetYieldModifierTooltip
- `pCity:GetYieldModifierTooltip(YieldTypes.YIELD_PRODUCTION)`
- `pCity:GetYieldModifierTooltip(iYieldType)`
- 9 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:463`

### GetYieldPerPopTimes100
- `pCity:GetYieldPerPopTimes100(iYieldType)`
- 6 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:611`

### GetYieldRate
- `city:GetYieldRate(YieldTypes.YIELD_PRODUCTION)`
- `city:GetYieldRate(YieldTypes.YIELD_FOOD)`
- `pCity:GetYieldRate(YieldTypes.YIELD_PRODUCTION)`
- `pCity:GetYieldRate(YieldTypes.YIELD_GOLD)`
- `pCity:GetYieldRate(YieldTypes.YIELD_SCIENCE)`
- ...and 5 more distinct call shapes
- 38 callsites. Example: `UI/InGame/CityBannerManager.lua:311`

### GetYieldRateTimes100
- `pCity:GetYieldRateTimes100(YieldTypes.YIELD_GOLD)`
- `pCity:GetYieldRateTimes100(iYieldType)`
- `pCity:GetYieldRateTimes100(YieldTypes.YIELD_SCIENCE)`
- 12 callsites. Example: `UI/InGame/CityView/CityView.lua:1372`

### GrowthThreshold
- `pCity:GrowthThreshold()`
- `city:GrowthThreshold()`
- 22 callsites. Example: `UI/InGame/CityList.lua:180`

### IsBlockaded
- `city:IsBlockaded()`
- `pCity:IsBlockaded()`
- 12 callsites. Example: `UI/InGame/CityBannerManager.lua:174`

### IsBuildingSellable
- `pCity:IsBuildingSellable(buildingID)`
- `pCity:IsBuildingSellable(iBuildingID)`
- 6 callsites. Example: `UI/InGame/CityView/CityView.lua:541`

### IsCanAddSpecialistToBuilding
- `pCity:IsCanAddSpecialistToBuilding(iBuilding)`
- 3 callsites. Example: `UI/InGame/CityView/CityView.lua:2067`

### IsCanPurchase
- `city:IsCanPurchase(true, true, iData, -1, -1, eYield)`
- `city:IsCanPurchase(true, true, -1, iData, -1, eYield)`
- `city:IsCanPurchase(true, true, -1, -1, iData, eYield)`
- `city:IsCanPurchase(false, false, unitID, -1, -1, YieldTypes.YIELD_GOLD)`
- `city:IsCanPurchase(true, true, unitID, -1, -1, YieldTypes.YIELD_GOLD)`
- ...and 12 more distinct call shapes
- 29 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ProductionPopup.lua:136`

### IsCapital
- `city:IsCapital()`
- `pCity:IsCapital()`
- 21 callsites. Example: `UI/InGame/CityBannerManager.lua:159`

### IsCoastal
- `pCity:IsCoastal(9)`
- 2 callsites. Example: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:2104`

### IsFoodProduction
- `city:IsFoodProduction()`
- `pCity:IsFoodProduction()`
- 20 callsites. Example: `UI/InGame/CityBannerManager.lua:260`

### IsForcedAvoidGrowth
- `pCity:IsForcedAvoidGrowth()`
- 6 callsites. Example: `UI/InGame/CityView/CityView.lua:966`

### IsForcedWorkingPlot
- `pCity:IsForcedWorkingPlot(plot)`
- 3 callsites. Example: `UI/InGame/CityView/CityView.lua:1770`

### IsHasBuilding
- `pCity:IsHasBuilding(buildingID)`
- `city:IsHasBuilding(buildingID)`
- `pCity:IsHasBuilding(GameInfo.Buildings["BUILDING_PUBLIC_SCHOOL"].ID)`
- `pCity:IsHasBuilding(building.ID)`
- `city:IsHasBuilding(v.BuildingID)`
- ...and 11 more distinct call shapes
- 40 callsites. Example: `UI/InGame/CityView/CityView.lua:299`

### IsHasResourceLocal
- `pTargetCity:IsHasResourceLocal(iResourceLoop)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/TradeRouteHelpers.lua:47`

### IsHolyCityForReligion
- `city:IsHolyCityForReligion(eReligion)`
- `city:IsHolyCityForReligion(iReligionID)`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/InfoTooltipInclude.lua:1226`

### IsNoAutoAssignSpecialists
- `pCity:IsNoAutoAssignSpecialists()`
- 9 callsites. Example: `UI/InGame/CityView/CityView.lua:657`

### IsNoOccupiedUnhappiness
- `pCity:IsNoOccupiedUnhappiness()`
- `city:IsNoOccupiedUnhappiness()`
- 17 callsites. Example: `UI/InGame/CityList.lua:165`

### IsOccupied
- `pCity:IsOccupied()`
- `city:IsOccupied()`
- 20 callsites. Example: `UI/InGame/CityList.lua:165`

### IsOriginalCapital
- `city:IsOriginalCapital()`
- 4 callsites. Example: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:1689`

### IsOriginalMajorCapital
- `pCity:IsOriginalMajorCapital()`
- 6 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/VictoryProgress.lua:299`

### IsPlotBlockaded
- `pCity:IsPlotBlockaded(plot)`
- 3 callsites. Example: `UI/InGame/CityView/CityView.lua:1806`

### IsProduction
- `city:IsProduction()`
- 7 callsites. Example: `UI/InGame/CityBannerManager.lua:277`

### IsProductionProcess
- `city:IsProductionProcess()`
- `pCity:IsProductionProcess()`
- 23 callsites. Example: `UI/InGame/CityBannerManager.lua:277`

### IsPuppet
- `city:IsPuppet()`
- `pCity:IsPuppet()`
- 25 callsites. Example: `UI/InGame/CityBannerManager.lua:207`

### IsRazing
- `pCity:IsRazing()`
- `city:IsRazing()`
- 17 callsites. Example: `UI/InGame/CityView/CityView.lua:688`

### IsResistance
- `city:IsResistance()`
- `pCity:IsResistance()`
- 6 callsites. Example: `UI/InGame/CityBannerManager.lua:199`

### IsThemingBonusPossible
- `city:IsThemingBonusPossible(v.BuildingClassID)`
- `city:IsThemingBonusPossible(wonder.BuildingClassID)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CultureOverview.lua:728`

### IsWorkingPlot
- `pCity:IsWorkingPlot(plot)`
- 6 callsites. Example: `UI/InGame/CityView/CityView.lua:1770`

### Kill
- `city:Kill()`
- 3 callsites. Example: `UI/InGame/WorldView/WorldView.lua:240`

### Plot
- `pCity:Plot()`
- `city:Plot()`
- `pHeadSelectedCity:Plot()`
- `capital:Plot()`
- `pCapital:Plot()`
- 34 callsites. Example: `UI/InGame/WorldView/ActionInfoPanel.lua:220`

### ProductionLeft
- `pCapital:ProductionLeft()`
- 1 callsite. Example: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:1317`

### SetNumRealBuilding
- `pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_MONUMENT"], 1)`
- `pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_COLOSSEUM"], 1)`
- `city:SetNumRealBuilding(iBuildingID, 1)`
- `capital:SetNumRealBuilding(iBuildingID, 1)`
- `pCity:SetNumRealBuilding(GameInfoTypes["BUILDING_MARKET"], 1)`
- ...and 17 more distinct call shapes
- 214 callsites. Example: `DLC/Expansion/Scenarios/FallOfRomeScenario/TurnsRemaining.lua:752`

### SetPopulation
- `capital:SetPopulation(5, true)`
- `city:SetPopulation(10, true)`
- 4 callsites. Example: `DLC/Expansion/Scenarios/MedievalScenario/TurnsRemaining.lua:1079`
