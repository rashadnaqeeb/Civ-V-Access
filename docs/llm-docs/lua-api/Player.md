# Player

Methods on Player handles. Obtain via `Players[playerID]` or `Game.GetActivePlayer()` (returns player ID, then index `Players[...]`).

Extracted from 6264 call sites across 514 distinct methods in the shipped game Lua.

## Methods

### AddFreeUnit
- `Players[0]:AddFreeUnit(70,5)`
- `Players[0]:AddFreeUnit(63,8)`
- `Players[0]:AddFreeUnit(66,6)`
- 8 callsites. Example: `DLC/DLC_01/Scenarios/Mongol Scenario/CivsAlive.lua:90`

### AddNotification
- `player:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, text, heading)`
- `pPlayer:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, text, heading)`
- `pActivePlayer:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, sMessage, sSummary, -1, -1, iNewOwner)`
- 7 callsites. Example: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:253`

### CalculateGoldRate
- `g_pUs:CalculateGoldRate()`
- `g_pThem:CalculateGoldRate()`
- `pPlayer:CalculateGoldRate()`
- `Players[iPlayer]:CalculateGoldRate()`
- 55 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:1042`

### CalculateGoldRateTimes100
- `pPlayer:CalculateGoldRateTimes100()`
- 3 callsites. Example: `UI/InGame/Popups/EconomicGeneralInfo.lua:189`

### CalculateGrossGold
- `Players[iPlayer]:CalculateGrossGold()`
- `pPlayer:CalculateGrossGold()`
- 2 callsites. Example: `UI/InGame/Popups/Demographics.lua:225`

### CalculateGrossGoldTimes100
- `pPlayer:CalculateGrossGoldTimes100()`
- 3 callsites. Example: `UI/InGame/Popups/EconomicGeneralInfo.lua:199`

### CalculateInflatedCosts
- `pPlayer:CalculateInflatedCosts()`
- 3 callsites. Example: `UI/InGame/Popups/EconomicGeneralInfo.lua:201`

### CalculateTotalYield
- `Players[iPlayer]:CalculateTotalYield(YieldTypes.YIELD_FOOD)`
- `Players[iPlayer]:CalculateTotalYield(YieldTypes.YIELD_PRODUCTION)`
- 2 callsites. Example: `UI/InGame/Popups/Demographics.lua:154`

### CalculateUnitCost
- `pPlayer:CalculateUnitCost()`
- 8 callsites. Example: `UI/InGame/TopPanel.lua:443`

### CalculateUnitSupply
- `pPlayer:CalculateUnitSupply()`
- 5 callsites. Example: `UI/InGame/TopPanel.lua:444`

### CanAdoptPolicy
- `player:CanAdoptPolicy(policyIndex)`
- `player:CanAdoptPolicy(i)`
- `player:CanAdoptPolicy(i, true)`
- 14 callsites. Example: `UI/InGame/Popups/SocialPolicyPopup.lua:79`

### CanCommitVote
- `g_pUs:CanCommitVote(g_pThem:GetID())`
- `g_pThem:CanCommitVote(g_pUs:GetID())`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/TradeLogic.lua:1654`

### CanCreatePantheon
- `pPlayer:CanCreatePantheon(false)`
- `player:CanCreatePantheon(true)`
- `player:CanCreatePantheon(false)`
- 7 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:1127`

### CanEverResearch
- `player:CanEverResearch(techID)`
- 3 callsites. Example: `UI/InGame/TechTree/TechTree.lua:700`

### CanFound
- `Players[Game.GetActivePlayer()]:CanFound(iPlotX, iPlotY)`
- 3 callsites. Example: `UI/InGame/GenericWorldAnchor.lua:103`

### CanGetGoody
- `pPlayer:CanGetGoody(pPlot, iGoodyType, pUnit)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseGoodyHutReward.lua:29`

### CanMajorBullyGold
- `pMinor:CanMajorBullyGold(iMajor)`
- `pPlayer:CanMajorBullyGold(iActivePlayer)`
- 10 callsites. Example: `DLC/Expansion2/UI/InGame/CityStateStatusHelper.lua:63`

### CanMajorBullyUnit
- `pPlayer:CanMajorBullyUnit(iActivePlayer)`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CityStateDiploPopup.lua:971`

### CanMajorBuyout
- `pPlayer:CanMajorBuyout(iActivePlayer)`
- `pMinor:CanMajorBuyout(iActivePlayer)`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CityStateDiploPopup.lua:546`

### CanMajorGiftTileImprovement
- `pPlayer:CanMajorGiftTileImprovement(iActivePlayer)`
- `pMinor:CanMajorGiftTileImprovement(iActivePlayer)`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CityStateDiploPopup.lua:833`

### CanMajorGiftTileImprovementAtPlot
- `pToPlayer:CanMajorGiftTileImprovementAtPlot(iFromPlayer, iPlotX, iPlotY)`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/InGame.lua:282`

### CanMajorStartProtection
- `pPlayer:CanMajorStartProtection(iActivePlayer)`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CityStateDiploPopup.lua:502`

### CanMajorWithdrawProtection
- `pPlayer:CanMajorWithdrawProtection(iActivePlayer)`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CityStateDiploPopup.lua:490`

### CanRaze
- `pPlayer:CanRaze(pCity, false)`
- `pPlayer:CanRaze(pCity, true)`
- `activePlayer:CanRaze(newCity)`
- 9 callsites. Example: `UI/InGame/CityView/CityView.lua:1335`

### CanResearch
- `player:CanResearch(techID)`
- `player:CanResearch(tech.ID)`
- 11 callsites. Example: `UI/InGame/TechPopup.lua:99`

### CanResearchForFree
- `player:CanResearchForFree(techID)`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/TechPopup.lua:130`

### CanSpyStageCoup
- `pActivePlayer:CanSpyStageCoup(v.AgentID)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/EspionageOverview.lua:773`

### CanTrain
- `player:CanTrain(info.ID, true, true, true, false)`
- 7 callsites. Example: `UI/InGame/Popups/ChooseFreeItem.lua:32`

### CanUnlockPolicyBranch
- `player:CanUnlockPolicyBranch(policyBranchIndex)`
- `player:CanUnlockPolicyBranch(i)`
- 12 callsites. Example: `UI/InGame/Popups/SocialPolicyPopup.lua:137`

### ChangeFaith
- `player:ChangeFaith(iFaith2)`
- `player:ChangeFaith(iFaith1)`
- `pPlayer:ChangeFaith(50)`
- 34 callsites. Example: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:530`

### ChangeFreePromotionCount
- `player:ChangeFreePromotionCount(iPromotionID, 1)`
- 8 callsites. Example: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/NewWorld_Scenario_MapScript.lua:2798`

### ChangeGold
- `player:ChangeGold(iGoldReceived)`
- `Players[iPlayer]:ChangeGold(iDiv)`
- `Players[Spain_PlayerID]:ChangeGold(200)`
- `Players[France_PlayerID]:ChangeGold(1000)`
- `Players[England_PlayerID]:ChangeGold(200)`
- ...and 6 more distinct call shapes
- 21 callsites. Example: `DLC/Expansion2/Scenarios/CivilWarScenario/TurnsRemaining.lua:873`

### ChangeJONSCulture
- `Players[iPlayer]:ChangeJONSCulture(20 * iCitiesCaptured)`
- `pPlayer:ChangeJONSCulture(kCultureBonus)`
- `Players[iPlayer]:ChangeJONSCulture(kCultureBonus)`
- 3 callsites. Example: `DLC/Expansion/Scenarios/FallOfRomeScenario/TurnsRemaining.lua:255`

### ChangeNavalCombatExperience
- `player:ChangeNavalCombatExperience(iNaturalAd1)`
- `player:ChangeNavalCombatExperience(150)`
- `player:ChangeNavalCombatExperience(250)`
- `player:ChangeNavalCombatExperience(75)`
- `pPlayer:ChangeNavalCombatExperience(10)`
- 16 callsites. Example: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:860`

### ChangeNewCityExtraPopulation
- `player:ChangeNewCityExtraPopulation(2)`
- 8 callsites. Example: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/NewWorld_Scenario_MapScript.lua:2815`

### ChangeNumFreePolicies
- `Players[0]:ChangeNumFreePolicies(1)`
- 1 callsite. Example: `DLC/DLC_01/Scenarios/Mongol Scenario/CivsAlive.lua:82`

### ChangeNumResourceTotal
- `player:ChangeNumResourceTotal(iResourceID, iManpower)`
- `player:ChangeNumResourceTotal(iResourceID, iIron)`
- 2 callsites. Example: `DLC/Expansion2/Scenarios/CivilWarScenario/TurnsRemaining.lua:365`

### ChangeNumWorldWonders
- `pPlayer:ChangeNumWorldWonders(-1 * (pPlayer:GetScoreFromWonders() / GameDefines["SCORE_WONDER_MULTIPLIER"]))`
- `player:ChangeNumWorldWonders(iNumWondersToCredit)`
- 2 callsites. Example: `DLC/DLC_06/Scenarios/WonderScenario/WonderStatus.lua:289`

### ChangeScoreFromFutureTech
- `pPlayer:ChangeScoreFromFutureTech(10)`
- `player:ChangeScoreFromFutureTech(iVPReceived)`
- `Players[iBestVotePlayer]:ChangeScoreFromFutureTech(250)`
- `pPlayer:ChangeScoreFromFutureTech(-1 * pPlayer:GetScoreFromFutureTech())`
- `pOwner:ChangeScoreFromFutureTech(1 * GameDefines["SCORE_FUTURE_TECH_MULTIPLIER"])`
- ...and 1 more distinct call shapes
- 17 callsites. Example: `DLC/Expansion/Scenarios/MedievalScenario/TurnsRemaining.lua:1185`

### ChangeScoreFromScenario1
- `player:ChangeScoreFromScenario1(iVPReceived)`
- 1 callsite. Example: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:444`

### ChangeScoreFromScenario2
- `pPlayer:ChangeScoreFromScenario2(iVPReceived)`
- `pPlayer:ChangeScoreFromScenario2(iNewVPEarned)`
- `pPlayer:ChangeScoreFromScenario2(iVP - pPlayer:GetScoreFromScenario2())`
- 6 callsites. Example: `DLC/Expansion2/Scenarios/ScrambleAfricaScenario/TurnsRemaining.lua:586`

### ChangeScoreFromScenario3
- `pPlayer:ChangeScoreFromScenario3(iNewVPEarned)`
- `pPlayer:ChangeScoreFromScenario3(iVP - pPlayer:GetScoreFromScenario3())`
- 2 callsites. Example: `DLC/Expansion2/Scenarios/ScrambleAfricaScenario/TurnsRemaining.lua:403`

### ChangeScoreFromScenario4
- `pPlayer:ChangeScoreFromScenario4(iNewVPEarned)`
- 1 callsite. Example: `DLC/Expansion2/Scenarios/ScrambleAfricaScenario/TurnsRemaining.lua:408`

### ChangeScoreFromTechs
- `Players[iOldOwner]:ChangeScoreFromTechs(-5000)`
- `Players[iNewOwner]:ChangeScoreFromTechs(5000)`
- `pPlayer:ChangeScoreFromTechs(5000)`
- `pPlayer:ChangeScoreFromTechs(iScore)`
- 7 callsites. Example: `DLC/DLC_05/Scenarios/KoreaScenario/TurnsRemaining.lua:316`

### ChooseTech
- `Players[0]:ChooseTech(1, Locale.ConvertTextKey("TXT_KEY_MONGOL_SCENARIO_FREE_TECH"), -1)`
- 1 callsite. Example: `DLC/DLC_01/Scenarios/Mongol Scenario/CivsAlive.lua:126`

### Cities
- `pPlayer:Cities()`
- `player:Cities()`
- `pOtherPlayer:Cities()`
- `g_pUs:Cities()`
- `g_pThem:Cities()`
- ...and 3 more distinct call shapes
- 116 callsites. Example: `UI/InGame/CityList.lua:101`

### CountNumBuildings
- `pOtherPlayer:CountNumBuildings(iBuilding)`
- `Players[iLondonPlayer]:CountNumBuildings(GameInfo.Buildings["BUILDING_COURTHOUSE"].ID)`
- 3 callsites. Example: `UI/InGame/Popups/DiploGlobalRelationships.lua:110`

### DoBeginDiploWithHuman
- `Players[ePlayer]:DoBeginDiploWithHuman()`
- `player:DoBeginDiploWithHuman()`
- 14 callsites. Example: `UI/InGame/DiploList.lua:150`

### DoesUnitPassFaithPurchaseCheck
- `player:DoesUnitPassFaithPurchaseCheck(unit.ID)`
- `pPlayer:DoesUnitPassFaithPurchaseCheck(infoID)`
- `player:DoesUnitPassFaithPurchaseCheck(infoID)`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ReligionOverview.lua:403`

### DoTradeScreenClosed
- `Players[g_iThem]:DoTradeScreenClosed(g_bAIMakingOffer)`
- 3 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:382`

### DoTradeScreenOpened
- `Players[g_iAIPlayer]:DoTradeScreenOpened()`
- 3 callsites. Example: `UI/InGame/LeaderHead/LeaderHeadRoot.lua:245`

### GetActiveQuestForPlayer
- `pOtherPlayer:GetActiveQuestForPlayer(player:GetID())`
- `pOtherPlayer:GetActiveQuestForPlayer(g_iPlayer)`
- `pOtherPlayer:GetActiveQuestForPlayer(iActivePlayer)`
- `pPlayer:GetActiveQuestForPlayer(iActivePlayer)`
- 5 callsites. Example: `Tutorial/lua/TutorialChecks.lua:1118`

### GetAlliedTurns
- `pPlayer:GetAlliedTurns()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CityStateDiploPopup.lua:551`

### GetAlly
- `pPlayer:GetAlly()`
- `pLoopPlayer:GetAlly()`
- `Players[city:GetOwner()]:GetAlly()`
- `pMinor:GetAlly()`
- `pOtherPlayer:GetAlly()`
- ...and 1 more distinct call shapes
- 26 callsites. Example: `UI/InGame/Popups/CityStateDiploPopup.lua:266`

### GetAnarchyNumTurns
- `pPlayer:GetAnarchyNumTurns()`
- 8 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:397`

### GetAnyUnitHasOrderToGoody
- `player:GetAnyUnitHasOrderToGoody()`
- 2 callsites. Example: `Tutorial/lua/TutorialChecks.lua:363`

### GetApproachTowardsUsGuess
- `g_pPlayer:GetApproachTowardsUsGuess(iPlayerLoop)`
- `Players[iActivePlayer]:GetApproachTowardsUsGuess(g_iAIPlayer)`
- `pActivePlayer:GetApproachTowardsUsGuess(g_iAIPlayer)`
- `pPlayer:GetApproachTowardsUsGuess(iPlayerLoop)`
- `Players[iActivePlayer]:GetApproachTowardsUsGuess(iLeader)`
- ...and 1 more distinct call shapes
- 17 callsites. Example: `UI/InGame/DiploList.lua:328`

### GetAttackBonusTurns
- `pMyPlayer:GetAttackBonusTurns()`
- 6 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:548`

### GetAvailableSpyRelocationCities
- `activePlayer:GetAvailableSpyRelocationCities(agentID)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/EspionageOverview.lua:324`

### GetAvailableTenets
- `player:GetAvailableTenets(iLevel)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/SocialPolicyPopup.lua:795`

### GetBarbarianCombatBonus
- `Players[pMyUnit:GetOwner()]:GetBarbarianCombatBonus()`
- 3 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:1089`

### GetBeliefInPantheon
- `pPlayer:GetBeliefInPantheon()`
- `player:GetBeliefInPantheon()`
- 7 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseReligionPopup.lua:420`

### GetBuildingClassCount
- `pPlayer:GetBuildingClassCount(thisBuildingClass.ID)`
- `Players[iPlayer]:GetBuildingClassCount(t.BuildingClass)`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/EspionageOverview.lua:856`

### GetBuildingGoldMaintenance
- `pPlayer:GetBuildingGoldMaintenance()`
- 8 callsites. Example: `UI/InGame/TopPanel.lua:445`

### GetBuildingOfClosestGreatWorkSlot
- `pActivePlayer:GetBuildingOfClosestGreatWorkSlot(unit:GetX(), unit:GetY(), eGreatWorkSlotType)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/WorldView/UnitPanel.lua:1174`

### GetBuildingProductionNeeded
- `Players[Game.GetActivePlayer()]:GetBuildingProductionNeeded(buildingID)`
- `pActivePlayer:GetBuildingProductionNeeded(iBuildingID)`
- `pPlayer:GetBuildingProductionNeeded(wWonder.Building.ID)`
- 8 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:2748`

### GetBuyoutCost
- `pPlayer:GetBuyoutCost(iActivePlayer)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CityStateDiploPopup.lua:543`

### GetCapitalCity
- `pPlayer:GetCapitalCity()`
- `player:GetCapitalCity()`
- `pOtherPlayer:GetCapitalCity()`
- `Players[iToPlayer]:GetCapitalCity()`
- `pMyPlayer:GetCapitalCity()`
- ...and 1 more distinct call shapes
- 70 callsites. Example: `UI/InGame/Popups/CityStateDiploPopup.lua:286`

### GetCapitalUnhappinessMod
- `pPlayer:GetCapitalUnhappinessMod()`
- 3 callsites. Example: `UI/InGame/Popups/HappinessInfo.lua:509`

### GetCityByID
- `player:GetCityByID(CityID)`
- `activePlayer:GetCityByID(cityID)`
- `player:GetCityByID(cityBanner.cityID)`
- `pPlayer:GetCityByID(cityIndex)`
- `player:GetCityByID(cityIndex)`
- ...and 12 more distinct call shapes
- 52 callsites. Example: `UI/InGame/CityBannerManager.lua:999`

### GetCityConnectionGoldTimes100
- `pPlayer:GetCityConnectionGoldTimes100()`
- 8 callsites. Example: `UI/InGame/TopPanel.lua:426`

### GetCityConnectionRouteGoldTimes100
- `pPlayer:GetCityConnectionRouteGoldTimes100(pCity)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/EconomicGeneralInfo.lua:278`

### GetCityConnectionTradeRouteGoldModifier
- `pPlayer:GetCityConnectionTradeRouteGoldModifier()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/EconomicGeneralInfo.lua:265`

### GetCityCountUnhappinessMod
- `pPlayer:GetCityCountUnhappinessMod()`
- 6 callsites. Example: `UI/InGame/Popups/HappinessInfo.lua:423`

### GetCityOfClosestGreatWorkSlot
- `pActivePlayer:GetCityOfClosestGreatWorkSlot(unit:GetX(), unit:GetY(), eGreatWorkSlotType)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/WorldView/UnitPanel.lua:1175`

### GetCivilizationAdjective
- `player:GetCivilizationAdjective()`
- `Players[plot:GetOwner()]:GetCivilizationAdjective()`
- 2 callsites. Example: `UI/InGame/Popups/ReplayViewer.lua:1244`

### GetCivilizationAdjectiveKey
- `pPlayer:GetCivilizationAdjectiveKey()`
- `Players[iCityAlly]:GetCivilizationAdjectiveKey()`
- `pPlayer1:GetCivilizationAdjectiveKey()`
- `Players[pCity:GetOwner()]:GetCivilizationAdjectiveKey()`
- `pPlayer2:GetCivilizationAdjectiveKey()`
- ...and 2 more distinct call shapes
- 31 callsites. Example: `UI/InGame/PlotMouseoverInclude.lua:273`

### GetCivilizationDescription
- `pPlayer:GetCivilizationDescription()`
- `player:GetCivilizationDescription()`
- `pTargetPlayer:GetCivilizationDescription()`
- 6 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ReligionOverview.lua:451`

### GetCivilizationDescriptionKey
- `Players[iCityAlly]:GetCivilizationDescriptionKey()`
- `player:GetCivilizationDescriptionKey()`
- `Players[iFarthestPlayer]:GetCivilizationDescriptionKey()`
- 5 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/EspionageOverview.lua:762`

### GetCivilizationShortDescription
- `pPlayer:GetCivilizationShortDescription()`
- `pVoteCastPlayer:GetCivilizationShortDescription()`
- `player:GetCivilizationShortDescription()`
- `activePlayer:GetCivilizationShortDescription()`
- 11 callsites. Example: `DLC/Expansion/Scenarios/MedievalScenario/VoteResultsPopup.lua:132`

### GetCivilizationShortDescriptionKey
- `pPlayer:GetCivilizationShortDescriptionKey()`
- `Players[iQuestData1]:GetCivilizationShortDescriptionKey()`
- `Players[iPlayerLoop]:GetCivilizationShortDescriptionKey()`
- `pMinor:GetCivilizationShortDescriptionKey()`
- `player:GetCivilizationShortDescriptionKey()`
- ...and 18 more distinct call shapes
- 147 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:335`

### GetCivilizationType
- `player:GetCivilizationType()`
- `pPlayer:GetCivilizationType()`
- `pOtherPlayer:GetCivilizationType()`
- `g_pThem:GetCivilizationType()`
- `g_pPlayer:GetCivilizationType()`
- ...and 12 more distinct call shapes
- 188 callsites. Example: `UI/InGame/CityBannerManager.lua:415`

### GetClosestGoodyPlot
- `player:GetClosestGoodyPlot()`
- 2 callsites. Example: `Tutorial/lua/TutorialChecks.lua:383`

### GetCombatBonusVsHigherTech
- `pMyPlayer:GetCombatBonusVsHigherTech()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/EnemyUnitPanel.lua:967`

### GetCombatBonusVsLargerCiv
- `pMyPlayer:GetCombatBonusVsLargerCiv()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/EnemyUnitPanel.lua:977`

### GetCombatExperience
- `pPlayer:GetCombatExperience()`
- 6 callsites. Example: `UI/InGame/GPList.lua:161`

### GetCommitVoteDetails
- `g_pUs:GetCommitVoteDetails(g_pThem:GetID())`
- `g_pThem:GetCommitVoteDetails(g_pUs:GetID())`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/TradeLogic.lua:1655`

### GetCommonFoeValue
- `pOtherPlayer:GetCommonFoeValue(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:871`

### GetCoopWarAcceptedState
- `Players[g_iAIPlayer]:GetCoopWarAcceptedState(pActivePlayer:GetID(), iThirdPartyPlayer)`
- 3 callsites. Example: `UI/InGame/LeaderHead/DiscussionDialog.lua:913`

### GetCoupChanceOfSuccess
- `Players[Game.GetActivePlayer()]:GetCoupChanceOfSuccess(city)`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/EspionageOverview.lua:762`

### GetCultureBombTimer
- `pActivePlayer:GetCultureBombTimer()`
- 6 callsites. Example: `UI/InGame/WorldView/UnitPanel.lua:1194`

### GetCultureBonusTurns
- `pPlayer:GetCultureBonusTurns()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:1003`

### GetCultureCityModifier
- `Players[pCity:GetOwner()]:GetCultureCityModifier()`
- 3 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:563`

### GetCulturePerTurnFromBonusTurns
- `pPlayer:GetCulturePerTurnFromBonusTurns()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:994`

### GetCulturePerTurnFromMinorCivs
- `pPlayer:GetCulturePerTurnFromMinorCivs()`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:966`

### GetCulturePerTurnFromReligion
- `pPlayer:GetCulturePerTurnFromReligion()`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:980`

### GetCultureWonderMultiplier
- `Players[pCity:GetOwner()]:GetCultureWonderMultiplier()`
- 3 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:578`

### GetCurrentCapitalFoodBonus
- `pPlayer:GetCurrentCapitalFoodBonus(iActivePlayer)`
- `pMinor:GetCurrentCapitalFoodBonus(iMajor)`
- 5 callsites. Example: `UI/InGame/Popups/CityStateDiploPopup.lua:163`

### GetCurrentCultureBonus
- `pPlayer:GetCurrentCultureBonus(iActivePlayer)`
- 3 callsites. Example: `UI/InGame/Popups/CityStateDiploPopup.lua:157`

### GetCurrentEra
- `pPlayer:GetCurrentEra()`
- `player:GetCurrentEra()`
- `pLoopPlayer:GetCurrentEra()`
- `Players[iPlayer]:GetCurrentEra()`
- `pOtherPlayer:GetCurrentEra()`
- ...and 1 more distinct call shapes
- 22 callsites. Example: `Tutorial/lua/TutorialChecks.lua:2605`

### GetCurrentOtherCityFoodBonus
- `pPlayer:GetCurrentOtherCityFoodBonus(iActivePlayer)`
- `pMinor:GetCurrentOtherCityFoodBonus(iMajor)`
- 5 callsites. Example: `UI/InGame/Popups/CityStateDiploPopup.lua:164`

### GetCurrentResearch
- `pPlayer:GetCurrentResearch()`
- `player:GetCurrentResearch()`
- `pOtherPlayer:GetCurrentResearch()`
- 18 callsites. Example: `UI/InGame/TechPanel.lua:57`

### GetCurrentScienceFriendshipBonusTimes100
- `pPlayer:GetCurrentScienceFriendshipBonusTimes100(iActivePlayer)`
- `pMinor:GetCurrentScienceFriendshipBonusTimes100(iMajor)`
- 5 callsites. Example: `UI/InGame/Popups/CityStateDiploPopup.lua:176`

### GetCurrentSpawnEstimate
- `pPlayer:GetCurrentSpawnEstimate(iActivePlayer)`
- `pMinor:GetCurrentSpawnEstimate(iMajor)`
- 5 callsites. Example: `UI/InGame/Popups/CityStateDiploPopup.lua:170`

### GetDealMyValue
- `g_pUs:GetDealMyValue(g_Deal)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/TradeLogic.lua:380`

### GetDenouncedPlayerCounter
- `activePlayer:GetDenouncedPlayerCounter(RivalId)`
- `Players[g_iUs]:GetDenouncedPlayerCounter(iOtherPlayer)`
- `pOtherPlayer:GetDenouncedPlayerCounter(iThirdPlayer)`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/DeclareWarPopup.lua:166`

### GetDoFCounter
- `activePlayer:GetDoFCounter(RivalId)`
- `pOtherPlayer:GetDoFCounter(iThirdPlayer)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/DeclareWarPopup.lua:161`

### GetDominantPolicyBranchForTitle
- `player:GetDominantPolicyBranchForTitle()`
- 7 callsites. Example: `UI/InGame/Popups/SocialPolicyPopup.lua:256`

### GetEndTurnBlockingNotificationIndex
- `player:GetEndTurnBlockingNotificationIndex()`
- 10 callsites. Example: `UI/InGame/WorldView/ActionInfoPanel.lua:120`

### GetEndTurnBlockingType
- `player:GetEndTurnBlockingType()`
- `pPlayer:GetEndTurnBlockingType()`
- 11 callsites. Example: `UI/InGame/WorldView/ActionInfoPanel.lua:119`

### GetEspionageCityStatus
- `pActivePlayer:GetEspionageCityStatus()`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/EspionageOverview.lua:1000`

### GetEspionageSpies
- `activePlayer:GetEspionageSpies()`
- `pActivePlayer:GetEspionageSpies()`
- `pAIPlayer:GetEspionageSpies()`
- `player:GetEspionageSpies()`
- 15 callsites. Example: `DLC/Expansion2/UI/InGame/CityBannerManager.lua:115`

### GetEverPoppedGoody
- `player:GetEverPoppedGoody()`
- 2 callsites. Example: `Tutorial/lua/TutorialChecks.lua:357`

### GetExcessHappiness
- `pPlayer:GetExcessHappiness()`
- `Players[iPlayer]:GetExcessHappiness()`
- 23 callsites. Example: `UI/InGame/TopPanel.lua:88`

### GetExtraBuildingHappinessFromPolicies
- `pActivePlayer:GetExtraBuildingHappinessFromPolicies(iBuildingID)`
- 3 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:139`

### GetExtraHappinessPerCity
- `pPlayer:GetExtraHappinessPerCity()`
- 8 callsites. Example: `UI/InGame/TopPanel.lua:520`

### GetExtraHappinessPerLuxury
- `pPlayer:GetExtraHappinessPerLuxury()`
- 8 callsites. Example: `UI/InGame/TopPanel.lua:514`

### GetFaith
- `pPlayer:GetFaith()`
- `player:GetFaith()`
- 14 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:173`

### GetFaithPerTurnFromCities
- `pPlayer:GetFaithPerTurnFromCities()`
- `player:GetFaithPerTurnFromCities()`
- 7 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:1092`

### GetFaithPerTurnFromMinorCivs
- `pPlayer:GetFaithPerTurnFromMinorCivs()`
- `player:GetFaithPerTurnFromMinorCivs()`
- 7 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:1099`

### GetFaithPerTurnFromReligion
- `pPlayer:GetFaithPerTurnFromReligion()`
- `player:GetFaithPerTurnFromReligion()`
- 7 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:1106`

### GetFaithPurchaseIndex
- `player:GetFaithPurchaseIndex()`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ReligionOverview.lua:419`

### GetFaithPurchaseType
- `player:GetFaithPurchaseType()`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ReligionOverview.lua:419`

### GetFirstReadyUnit
- `player:GetFirstReadyUnit()`
- 6 callsites. Example: `UI/InGame/WorldView/ActionInfoPanel.lua:146`

### GetFoundedReligionEnemyCityCombatMod
- `pMyPlayer:GetFoundedReligionEnemyCityCombatMod(pPlot)`
- `pMyPlayer:GetFoundedReligionEnemyCityCombatMod(pToPlot)`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/EnemyUnitPanel.lua:453`

### GetFoundedReligionFriendlyCityCombatMod
- `pMyPlayer:GetFoundedReligionFriendlyCityCombatMod(pToPlot)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/EnemyUnitPanel.lua:957`

### GetFriendshipChangePerTurnTimes100
- `pMinor:GetFriendshipChangePerTurnTimes100(iMajor)`
- `pPlayer:GetFriendshipChangePerTurnTimes100(iForPlayer)`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/CityStateStatusHelper.lua:230`

### GetFriendshipFromGoldGift
- `pPlayer:GetFriendshipFromGoldGift(iActivePlayer, iGold)`
- 12 callsites. Example: `UI/InGame/Popups/CityStateDiploPopup.lua:733`

### GetFriendshipFromUnitGift
- `pPlayer:GetFriendshipFromUnitGift(iActivePlayer, false, true)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/CityStateDiploPopup.lua:813`

### GetGiftTileImprovementCost
- `pPlayer:GetGiftTileImprovementCost(iActivePlayer)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CityStateDiploPopup.lua:831`

### GetGold
- `pPlayer:GetGold()`
- `pActivePlayer:GetGold()`
- `player:GetGold()`
- `Players[g_iUs]:GetGold()`
- `Players[g_iThem]:GetGold()`
- 49 callsites. Example: `UI/InGame/TopPanel.lua:46`

### GetGoldenAgeGreatArtistRateModifier
- `player:GetGoldenAgeGreatArtistRateModifier()`
- `pPlayer:GetGoldenAgeGreatArtistRateModifier()`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/GPList.lua:282`

### GetGoldenAgeGreatMusicianRateModifier
- `player:GetGoldenAgeGreatMusicianRateModifier()`
- `pPlayer:GetGoldenAgeGreatMusicianRateModifier()`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/GPList.lua:287`

### GetGoldenAgeGreatWriterRateModifier
- `player:GetGoldenAgeGreatWriterRateModifier()`
- `pPlayer:GetGoldenAgeGreatWriterRateModifier()`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/GPList.lua:277`

### GetGoldenAgeProgressMeter
- `pPlayer:GetGoldenAgeProgressMeter()`
- 10 callsites. Example: `UI/InGame/TopPanel.lua:118`

### GetGoldenAgeProgressThreshold
- `pPlayer:GetGoldenAgeProgressThreshold()`
- 10 callsites. Example: `UI/InGame/TopPanel.lua:118`

### GetGoldenAgeTourismModifier
- `pPlayer:GetGoldenAgeTourismModifier()`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:124`

### GetGoldenAgeTurns
- `pPlayer:GetGoldenAgeTurns()`
- `player:GetGoldenAgeTurns()`
- 26 callsites. Example: `UI/InGame/TopPanel.lua:115`

### GetGoldFromCitiesMinusTradeRoutesTimes100
- `pPlayer:GetGoldFromCitiesMinusTradeRoutesTimes100()`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:530`

### GetGoldFromCitiesTimes100
- `pPlayer:GetGoldFromCitiesTimes100()`
- 8 callsites. Example: `UI/InGame/TopPanel.lua:425`

### GetGoldPerTurnFromDiplomacy
- `pPlayer:GetGoldPerTurnFromDiplomacy()`
- 11 callsites. Example: `UI/InGame/TopPanel.lua:418`

### GetGoldPerTurnFromReligion
- `pPlayer:GetGoldPerTurnFromReligion()`
- 6 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:528`

### GetGoldPerTurnFromTraits
- `pPlayer:GetGoldPerTurnFromTraits()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:534`

### GetGreatArtistRateModifier
- `player:GetGreatArtistRateModifier()`
- `pPlayer:GetGreatArtistRateModifier()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/GPList.lua:281`

### GetGreatEngineerRateModifier
- `player:GetGreatEngineerRateModifier()`
- `pPlayer:GetGreatEngineerRateModifier()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/GPList.lua:295`

### GetGreatGeneralCombatBonus
- `pMyPlayer:GetGreatGeneralCombatBonus()`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/EnemyUnitPanel.lua:523`

### GetGreatMerchantRateModifier
- `player:GetGreatMerchantRateModifier()`
- `pPlayer:GetGreatMerchantRateModifier()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/GPList.lua:293`

### GetGreatMusicianRateModifier
- `player:GetGreatMusicianRateModifier()`
- `pPlayer:GetGreatMusicianRateModifier()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/GPList.lua:286`

### GetGreatPeopleRateModifier
- `player:GetGreatPeopleRateModifier()`
- `pPlayer:GetGreatPeopleRateModifier()`
- 6 callsites. Example: `UI/InGame/GPList.lua:239`

### GetGreatScientistRateModifier
- `player:GetGreatScientistRateModifier()`
- `pPlayer:GetGreatScientistRateModifier()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/GPList.lua:291`

### GetGreatWorks
- `activePlayer:GetGreatWorks(iGreatWorkType)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/CultureOverview.lua:1433`

### GetGreatWriterRateModifier
- `player:GetGreatWriterRateModifier()`
- `pPlayer:GetGreatWriterRateModifier()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/GPList.lua:276`

### GetHandicapType
- `Players[Game.GetActivePlayer()]:GetHandicapType()`
- `player:GetHandicapType()`
- 8 callsites. Example: `UI/InGame/Menus/GameMenu.lua:254`

### GetHappiness
- `pPlayer:GetHappiness()`
- 11 callsites. Example: `UI/InGame/TopPanel.lua:530`

### GetHappinessFromBuildings
- `pPlayer:GetHappinessFromBuildings()`
- 8 callsites. Example: `UI/InGame/TopPanel.lua:515`

### GetHappinessFromCities
- `pPlayer:GetHappinessFromCities()`
- 6 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:635`

### GetHappinessFromGarrisonedUnits
- `pPlayer:GetHappinessFromGarrisonedUnits()`
- 2 callsites. Example: `UI/InGame/TopPanel.lua:516`

### GetHappinessFromLeagues
- `pPlayer:GetHappinessFromLeagues()`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:642`

### GetHappinessFromLuxury
- `pPlayer:GetHappinessFromLuxury(resourceID)`
- 5 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:677`

### GetHappinessFromMinor
- `pPlayer:GetHappinessFromMinor(iPlayerLoop)`
- 2 callsites. Example: `UI/InGame/TopPanel.lua:527`

### GetHappinessFromMinorCivs
- `pPlayer:GetHappinessFromMinorCivs()`
- 6 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:641`

### GetHappinessFromNaturalWonders
- `pPlayer:GetHappinessFromNaturalWonders()`
- 8 callsites. Example: `UI/InGame/TopPanel.lua:519`

### GetHappinessFromPolicies
- `pPlayer:GetHappinessFromPolicies()`
- 8 callsites. Example: `UI/InGame/TopPanel.lua:512`

### GetHappinessFromReligion
- `pPlayer:GetHappinessFromReligion()`
- 8 callsites. Example: `UI/InGame/TopPanel.lua:518`

### GetHappinessFromResources
- `pPlayer:GetHappinessFromResources()`
- 8 callsites. Example: `UI/InGame/TopPanel.lua:513`

### GetHappinessFromResourceVariety
- `pPlayer:GetHappinessFromResourceVariety()`
- 8 callsites. Example: `UI/InGame/TopPanel.lua:574`

### GetHappinessFromTradeRoutes
- `pPlayer:GetHappinessFromTradeRoutes()`
- 8 callsites. Example: `UI/InGame/TopPanel.lua:517`

### GetHappinessPerGarrisonedUnit
- `pPlayer:GetHappinessPerGarrisonedUnit()`
- 3 callsites. Example: `UI/InGame/Popups/HappinessInfo.lua:332`

### GetHappinessPerTradeRoute
- `pPlayer:GetHappinessPerTradeRoute()`
- 3 callsites. Example: `UI/InGame/Popups/HappinessInfo.lua:308`

### GetID
- `pPlayer:GetID()`
- `player:GetID()`
- `pActivePlayer:GetID()`
- `activePlayer:GetID()`
- `pVoteCastPlayer:GetID()`
- ...and 5 more distinct call shapes
- 184 callsites. Example: `UI/InGame/CityView/CityView.lua:750`

### GetImprovementGoldMaintenance
- `pPlayer:GetImprovementGoldMaintenance()`
- 8 callsites. Example: `UI/InGame/TopPanel.lua:446`

### GetIncomingUnitCountdown
- `pPlayer:GetIncomingUnitCountdown(iActivePlayer)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/CityStateDiploPopup.lua:817`

### GetInfluenceOn
- `pActivePlayer:GetInfluenceOn(iPlayer)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/VictoryProgress.lua:623`

### GetInfluenceTradeRouteScienceBonus
- `pOtherPlayer:GetInfluenceTradeRouteScienceBonus(iPlayer)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/TradeRouteHelpers.lua:236`

### GetInternationalTradeRouteBaseBonus
- `pPlayer:GetInternationalTradeRouteBaseBonus(pOriginCity, pTargetCity, true)`
- `pOtherPlayer:GetInternationalTradeRouteBaseBonus(pOriginCity, pTargetCity, false)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/TradeRouteHelpers.lua:17`

### GetInternationalTradeRouteDomainModifier
- `pPlayer:GetInternationalTradeRouteDomainModifier(eDomain)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/TradeRouteHelpers.lua:76`

### GetInternationalTradeRouteExclusiveBonus
- `pPlayer:GetInternationalTradeRouteExclusiveBonus(pOriginCity, pTargetCity)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/TradeRouteHelpers.lua:58`

### GetInternationalTradeRouteGPTBonus
- `pPlayer:GetInternationalTradeRouteGPTBonus(pOriginCity, pTargetCity, true)`
- `pPlayer:GetInternationalTradeRouteGPTBonus(pOriginCity, pTargetCity, false)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/TradeRouteHelpers.lua:18`

### GetInternationalTradeRouteOtherTraitBonus
- `pPlayer:GetInternationalTradeRouteOtherTraitBonus(pOriginCity, pTargetCity, eDomain, true)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/TradeRouteHelpers.lua:64`

### GetInternationalTradeRoutePlotToolTip
- `Players[iActivePlayer]:GetInternationalTradeRoutePlotToolTip(plot)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/PlotMouseoverInclude.lua:501`

### GetInternationalTradeRoutePolicyBonus
- `pPlayer:GetInternationalTradeRoutePolicyBonus(pOriginCity, pTargetCity, eDomain)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/TradeRouteHelpers.lua:21`

### GetInternationalTradeRouteResourceTraitModifier
- `pPlayer:GetInternationalTradeRouteResourceTraitModifier()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/TradeRouteHelpers.lua:49`

### GetInternationalTradeRouteRiverModifier
- `pPlayer:GetInternationalTradeRouteRiverModifier(pOriginCity, pTargetCity, eDomain, true)`
- `pPlayer:GetInternationalTradeRouteRiverModifier(pOriginCity, pTargetCity, eDomain, false)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/TradeRouteHelpers.lua:70`

### GetInternationalTradeRouteScience
- `pOtherPlayer:GetInternationalTradeRouteScience(pOriginCity, pTargetCity, eDomain, false)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/TradeRouteHelpers.lua:210`

### GetInternationalTradeRouteTheirBuildingBonus
- `pPlayer:GetInternationalTradeRouteTheirBuildingBonus(pOriginCity, pTargetCity, eDomain, true)`
- `pOtherPlayer:GetInternationalTradeRouteTheirBuildingBonus(pOriginCity, pTargetCity, eDomain, false)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/TradeRouteHelpers.lua:33`

### GetInternationalTradeRouteTotal
- `pPlayer:GetInternationalTradeRouteTotal(pOriginCity, pTargetCity, eDomain, true)`
- `pOtherPlayer:GetInternationalTradeRouteTotal(pOriginCity, pTargetCity, eDomain, false)`
- `pPlayer:GetInternationalTradeRouteTotal(pOriginCity, pTargetCity, true, true)`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/TradeRouteHelpers.lua:83`

### GetInternationalTradeRouteYourBuildingBonus
- `pPlayer:GetInternationalTradeRouteYourBuildingBonus(pOriginCity, pTargetCity, eDomain, true)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/TradeRouteHelpers.lua:27`

### GetIntrigueMessages
- `pActivePlayer:GetIntrigueMessages()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/EspionageOverview.lua:1505`

### GetJONSCulture
- `player:GetJONSCulture()`
- `pPlayer:GetJONSCulture()`
- `Players[iPlayer]:GetJONSCulture()`
- 57 callsites. Example: `UI/InGame/Popups/SocialPolicyPopup.lua:233`

### GetJONSCultureEverGenerated
- `pPlayer:GetJONSCultureEverGenerated()`
- `Players[0]:GetJONSCultureEverGenerated()`
- 5 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CultureOverview.lua:1968`

### GetJONSCulturePerTurnForFree
- `pPlayer:GetJONSCulturePerTurnForFree()`
- 5 callsites. Example: `UI/InGame/TopPanel.lua:770`

### GetJONSCulturePerTurnFromCities
- `pPlayer:GetJONSCulturePerTurnFromCities()`
- 5 callsites. Example: `UI/InGame/TopPanel.lua:784`

### GetJONSCulturePerTurnFromExcessHappiness
- `pPlayer:GetJONSCulturePerTurnFromExcessHappiness()`
- 5 callsites. Example: `UI/InGame/TopPanel.lua:798`

### GetJONSCulturePerTurnFromMinorCivs
- `pPlayer:GetJONSCulturePerTurnFromMinorCivs()`
- 1 callsite. Example: `UI/InGame/TopPanel.lua:812`

### GetJONSCulturePerTurnFromTraits
- `pPlayer:GetJONSCulturePerTurnFromTraits()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:952`

### GetLandDisputeLevel
- `pOtherPlayer:GetLandDisputeLevel(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:911`

### GetLastTurnLifetimeCulture
- `pPlayer:GetLastTurnLifetimeCulture()`
- 1 callsite. Example: `DLC/Expansion2/Scenarios/ScrambleAfricaScenario/TurnsRemaining.lua:406`

### GetLateGamePolicyTree
- `player:GetLateGamePolicyTree()`
- `pPlayer:GetLateGamePolicyTree()`
- 5 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseIdeologyPopup.lua:128`

### GetLeaderType
- `pPlayer:GetLeaderType()`
- `pOtherPlayer:GetLeaderType()`
- `player:GetLeaderType()`
- `g_pPlayer:GetLeaderType()`
- `g_pThem:GetLeaderType()`
- ...and 2 more distinct call shapes
- 55 callsites. Example: `UI/InGame/PlayerChange.lua:126`

### GetLiberationPreviewString
- `player:GetLiberationPreviewString(city:GetOriginalOwner())`
- `activePlayer:GetLiberationPreviewString(iLiberatedPlayer)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/CityBannerManager.lua:218`

### GetLifetimeCombatExperience
- `pPlayer:GetLifetimeCombatExperience()`
- `Players[0]:GetLifetimeCombatExperience()`
- 2 callsites. Example: `DLC/DLC_06/Scenarios/WonderScenario/WonderStatus.lua:337`

### GetLifetimeGrossGold
- `pPlayer:GetLifetimeGrossGold()`
- `Players[iPlayer]:GetLifetimeGrossGold()`
- `Players[0]:GetLifetimeGrossGold()`
- 4 callsites. Example: `DLC/Expansion2/Scenarios/ScrambleAfricaScenario/TurnsRemaining.lua:401`

### GetMajorBullyGoldDetails
- `pPlayer:GetMajorBullyGoldDetails(iActivePlayer)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/CityStateDiploPopup.lua:957`

### GetMajorBullyUnitDetails
- `pPlayer:GetMajorBullyUnitDetails(iActivePlayer)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/CityStateDiploPopup.lua:970`

### GetMayaCalendarLongString
- `pPlayer:GetMayaCalendarLongString()`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:259`

### GetMayaCalendarString
- `pPlayer:GetMayaCalendarString()`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:258`

### GetMilitaryMight
- `pPlayer:GetMilitaryMight()`
- `Players[iPlayer]:GetMilitaryMight()`
- 3 callsites. Example: `UI/InGame/Popups/WhosWinningPopup.lua:246`

### GetMinimumFaithNextGreatProphet
- `pPlayer:GetMinimumFaithNextGreatProphet()`
- `player:GetMinimumFaithNextGreatProphet()`
- 9 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:1121`

### GetMinorCivBullyGoldAmount
- `pPlayer:GetMinorCivBullyGoldAmount(iActivePlayer)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CityStateDiploPopup.lua:955`

### GetMinorCivContestValueForLeader
- `pMinor:GetMinorCivContestValueForLeader(MinorCivQuestTypes.MINOR_CIV_QUEST_CONTEST_CULTURE)`
- `pMinor:GetMinorCivContestValueForLeader(MinorCivQuestTypes.MINOR_CIV_QUEST_CONTEST_FAITH)`
- `pMinor:GetMinorCivContestValueForLeader(MinorCivQuestTypes.MINOR_CIV_QUEST_CONTEST_TECHS)`
- 6 callsites. Example: `DLC/Expansion2/UI/InGame/CityStateStatusHelper.lua:612`

### GetMinorCivContestValueForPlayer
- `pMinor:GetMinorCivContestValueForPlayer(iMajor, MinorCivQuestTypes.MINOR_CIV_QUEST_CONTEST_CULTURE)`
- `pMinor:GetMinorCivContestValueForPlayer(iMajor, MinorCivQuestTypes.MINOR_CIV_QUEST_CONTEST_FAITH)`
- `pMinor:GetMinorCivContestValueForPlayer(iMajor, MinorCivQuestTypes.MINOR_CIV_QUEST_CONTEST_TECHS)`
- 6 callsites. Example: `DLC/Expansion2/UI/InGame/CityStateStatusHelper.lua:613`

### GetMinorCivCurrentCultureBonus
- `pMinor:GetMinorCivCurrentCultureBonus(iMajor)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/CityStateStatusHelper.lua:322`

### GetMinorCivCurrentFaithBonus
- `pMinor:GetMinorCivCurrentFaithBonus(iMajor)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/CityStateStatusHelper.lua:353`

### GetMinorCivCurrentHappinessBonus
- `pMinor:GetMinorCivCurrentHappinessBonus(iMajor)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/CityStateStatusHelper.lua:347`

### GetMinorCivDisputeLevel
- `pOtherPlayer:GetMinorCivDisputeLevel(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:920`

### GetMinorCivFriendshipAnchorWithMajor
- `pMinor:GetMinorCivFriendshipAnchorWithMajor(iMajor)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/CityStateStatusHelper.lua:231`

### GetMinorCivFriendshipLevelWithMajor
- `Players[iPlotOwner]:GetMinorCivFriendshipLevelWithMajor(pPlayer:GetID())`
- 2 callsites. Example: `Tutorial/lua/TutorialChecks.lua:2457`

### GetMinorCivFriendshipWithMajor
- `pPlayer:GetMinorCivFriendshipWithMajor(iActivePlayer)`
- `pPlayer:GetMinorCivFriendshipWithMajor(iForPlayer)`
- `pMinor:GetMinorCivFriendshipWithMajor(iMajor)`
- `player:GetMinorCivFriendshipWithMajor(iActivePlayer)`
- `Players[iMinor]:GetMinorCivFriendshipWithMajor(iMajor)`
- ...and 4 more distinct call shapes
- 38 callsites. Example: `UI/InGame/Popups/CityStateDiploPopup.lua:132`

### GetMinorCivNumActiveQuestsForPlayer
- `pOtherPlayer:GetMinorCivNumActiveQuestsForPlayer(player:GetID())`
- `pOtherPlayer:GetMinorCivNumActiveQuestsForPlayer(g_iPlayer)`
- 3 callsites. Example: `DLC/Expansion/Tutorial/lua/TutorialChecks.lua:1118`

### GetMinorCivNumDisplayedQuestsForPlayer
- `pOtherPlayer:GetMinorCivNumDisplayedQuestsForPlayer(g_iPlayer)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/DiploList.lua:624`

### GetMinorCivTrait
- `pPlayer:GetMinorCivTrait()`
- `pOtherPlayer:GetMinorCivTrait()`
- `pMinor:GetMinorCivTrait()`
- `Players[i]:GetMinorCivTrait()`
- `Players[playerID]:GetMinorCivTrait()`
- 16 callsites. Example: `UI/InGame/Popups/CityStateDiploPopup.lua:223`

### GetMinorCivType
- `pPlayer:GetMinorCivType()`
- `pOtherPlayer:GetMinorCivType()`
- `player:GetMinorCivType()`
- 29 callsites. Example: `UI/InGame/Popups/CityStateDiploPopup.lua:72`

### GetMinorCivUniqueUnit
- `pMinor:GetMinorCivUniqueUnit()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/CityStateStatusHelper.lua:711`

### GetName
- `pPlayer:GetName()`
- `pOtherPlayer:GetName()`
- `pAIPlayer:GetName()`
- `g_pThem:GetName()`
- `player:GetName()`
- ...and 5 more distinct call shapes
- 62 callsites. Example: `UI/InGame/WorldView/MPList.lua:205`

### GetNameKey
- `pPlayer:GetNameKey()`
- `pOtherPlayer:GetNameKey()`
- `player:GetNameKey()`
- `Players[iQuestData1]:GetNameKey()`
- `pVoteCastPlayer:GetNameKey()`
- ...and 4 more distinct call shapes
- 43 callsites. Example: `UI/InGame/Popups/VictoryProgress.lua:895`

### GetNaturalWonderYieldModifier
- `Players[Game.GetActivePlayer()]:GetNaturalWonderYieldModifier()`
- `player:GetNaturalWonderYieldModifier()`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/PlotMouseoverInclude.lua:481`

### GetNavalCombatExperience
- `pPlayer:GetNavalCombatExperience()`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/GPList.lua:182`

### GetNegativeArchaeologyPoints
- `activePlayer:GetNegativeArchaeologyPoints(g_iAIPlayer)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/LeaderHead/DiscussionDialog.lua:250`

### GetNegativeReligiousConversionPoints
- `activePlayer:GetNegativeReligiousConversionPoints(g_iAIPlayer)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/LeaderHead/DiscussionDialog.lua:240`

### GetNextDigCompletePlot
- `pPlayer:GetNextDigCompletePlot()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseArchaeologyPopup.lua:99`

### GetNextPolicyCost
- `player:GetNextPolicyCost()`
- `pPlayer:GetNextPolicyCost()`
- 69 callsites. Example: `UI/InGame/Popups/SocialPolicyPopup.lua:230`

### GetNickName
- `pPlayer:GetNickName()`
- `pOtherPlayer:GetNickName()`
- `pAIPlayer:GetNickName()`
- `g_pPlayer:GetNickName()`
- `g_pThem:GetNickName()`
- ...and 6 more distinct call shapes
- 198 callsites. Example: `UI/InGame/PlotMouseoverInclude.lua:272`

### GetNotificationDismissed
- `player:GetNotificationDismissed((numNotifications - 1) - i)`
- 1 callsite. Example: `UI/InGame/Popups/NotificationLogPopup.lua:32`

### GetNotificationIndex
- `player:GetNotificationIndex(i)`
- `player:GetNotificationIndex((numNotifications - 1) - i)`
- 5 callsites. Example: `UI/InGame/WorldView/ActionInfoPanel.lua:373`

### GetNotificationStr
- `player:GetNotificationStr(i)`
- `player:GetNotificationStr((numNotifications - 1) - i)`
- 5 callsites. Example: `UI/InGame/WorldView/ActionInfoPanel.lua:374`

### GetNotificationSummaryStr
- `player:GetNotificationSummaryStr(i)`
- 3 callsites. Example: `UI/InGame/WorldView/ActionInfoPanel.lua:388`

### GetNotificationTurn
- `player:GetNotificationTurn((numNotifications - 1) - i)`
- 1 callsite. Example: `UI/InGame/Popups/NotificationLogPopup.lua:31`

### GetNumAvailableTradeUnits
- `pPlayer:GetNumAvailableTradeUnits(DomainTypes.DOMAIN_LAND)`
- `pPlayer:GetNumAvailableTradeUnits(DomainTypes.DOMAIN_SEA)`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:1255`

### GetNumCities
- `pPlayer:GetNumCities()`
- `player:GetNumCities()`
- `Players[0]:GetNumCities()`
- `Players[playerID]:GetNumCities()`
- `pOtherPlayer:GetNumCities()`
- 77 callsites. Example: `UI/InGame/CityBannerManager.lua:1263`

### GetNumCiviliansReturnedToMe
- `pOtherPlayer:GetNumCiviliansReturnedToMe(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:789`

### GetNumCivsInfluentialOn
- `pPlayer:GetNumCivsInfluentialOn()`
- `pLoopPlayer:GetNumCivsInfluentialOn()`
- 5 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:1053`

### GetNumCivsToBeInfluentialOn
- `pPlayer:GetNumCivsToBeInfluentialOn()`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:1054`

### GetNumFaithGreatPeople
- `activePlayer:GetNumFaithGreatPeople()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseFaithGreatPerson.lua:127`

### GetNumFreeGreatPeople
- `activePlayer:GetNumFreeGreatPeople()`
- 3 callsites. Example: `UI/InGame/Popups/ChooseFreeItem.lua:98`

### GetNumFreePolicies
- `player:GetNumFreePolicies()`
- 12 callsites. Example: `UI/InGame/Popups/SocialPolicyPopup.lua:270`

### GetNumFreeTechs
- `player:GetNumFreeTechs()`
- 15 callsites. Example: `UI/InGame/TechPopup.lua:87`

### GetNumFreeTenets
- `player:GetNumFreeTenets()`
- 8 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/SocialPolicyPopup.lua:575`

### GetNumFriendsDenouncedBy
- `pActivePlayer:GetNumFriendsDenouncedBy()`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:811`

### GetNumGreatWorks
- `pPlayer:GetNumGreatWorks()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:1043`

### GetNumGreatWorkSlots
- `pPlayer:GetNumGreatWorkSlots()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:1044`

### GetNumInternationalTradeRoutesAvailable
- `pPlayer:GetNumInternationalTradeRoutesAvailable()`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:84`

### GetNumInternationalTradeRoutesUsed
- `pPlayer:GetNumInternationalTradeRoutesUsed()`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:83`

### GetNumMaintenanceFreeUnits
- `pPlayer:GetNumMaintenanceFreeUnits(DomainTypes.NO_DOMAIN, false)`
- `pPlayer:GetNumMaintenanceFreeUnits()`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/EconomicGeneralInfo.lua:315`

### GetNumMayaBoosts
- `activePlayer:GetNumMayaBoosts()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseMayaBonus.lua:104`

### GetNumMilitaryUnits
- `player:GetNumMilitaryUnits()`
- 6 callsites. Example: `Tutorial/lua/TutorialChecks.lua:487`

### GetNumMinorCivsMet
- `player:GetNumMinorCivsMet()`
- 2 callsites. Example: `Tutorial/lua/TutorialChecks.lua:1031`

### GetNumNotifications
- `player:GetNumNotifications()`
- 5 callsites. Example: `UI/InGame/Popups/NotificationLogPopup.lua:26`

### GetNumPlots
- `Players[iPlayer]:GetNumPlots()`
- 1 callsite. Example: `UI/InGame/Popups/Demographics.lua:260`

### GetNumPolicies
- `pPlayer:GetNumPolicies()`
- `player:GetNumPolicies()`
- `pLoopPlayer:GetNumPolicies()`
- `Players[iPlayer]:GetNumPolicies()`
- 9 callsites. Example: `UI/InGame/Popups/WhosWinningPopup.lua:234`

### GetNumPoliciesInBranch
- `player:GetNumPoliciesInBranch(eCurrentIdeology)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/SocialPolicyPopup.lua:1248`

### GetNumPolicyBranchesFinished
- `Players[b]:GetNumPolicyBranchesFinished()`
- `Players[a]:GetNumPolicyBranchesFinished()`
- `pPlayer:GetNumPolicyBranchesFinished()`
- `player:GetNumPolicyBranchesFinished()`
- 16 callsites. Example: `UI/InGame/Popups/VictoryProgress.lua:798`

### GetNumPolicyBranchesUnlocked
- `player:GetNumPolicyBranchesUnlocked()`
- 6 callsites. Example: `UI/InGame/Popups/SocialPolicyPopup.lua:291`

### GetNumRequestsRefused
- `pOtherPlayer:GetNumRequestsRefused(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:865`

### GetNumResourceAvailable
- `pPlayer:GetNumResourceAvailable(iResourceLoop, true)`
- `pPlayer:GetNumResourceAvailable(iResource)`
- `Players[iPlayer]:GetNumResourceAvailable(iResourceLoop, false)`
- `pActivePlayer:GetNumResourceAvailable(iResourceLoop)`
- `Players[g_iUs]:GetNumResourceAvailable(resourceId, false)`
- ...and 11 more distinct call shapes
- 38 callsites. Example: `UI/InGame/TopPanel.lua:172`

### GetNumResourceTotal
- `pPlayer:GetNumResourceTotal(iResourceLoop, true)`
- `pPlayer:GetNumResourceTotal(resourceID, true)`
- `pPlayer:GetNumResourceTotal(iResourceID, true)`
- `pPlayer:GetNumResourceTotal(iResourceID, false)`
- `pPlayer:GetNumResourceTotal(iResource, true)`
- 20 callsites. Example: `UI/InGame/TopPanel.lua:174`

### GetNumResourceUsed
- `pPlayer:GetNumResourceUsed(iResourceLoop)`
- `pPlayer:GetNumResourceUsed(iResource)`
- 11 callsites. Example: `UI/InGame/TopPanel.lua:173`

### GetNumSpies
- `player:GetNumSpies()`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/EspionageOverview.lua:1459`

### GetNumTechDifference
- `pOtherPlayer:GetNumTechDifference(iPlayer)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/TradeRouteHelpers.lua:235`

### GetNumTechsToSteal
- `player:GetNumTechsToSteal(stealingTechTargetPlayerID)`
- 2 callsites. Example: `DLC/Expansion2/UI/TechTree/TechTree.lua:603`

### GetNumTimesCultureBombed
- `pOtherPlayer:GetNumTimesCultureBombed(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:832`

### GetNumUnits
- `pPlayer:GetNumUnits()`
- 9 callsites. Example: `UI/InGame/Popups/EconomicGeneralInfo.lua:289`

### GetNumUnitsOutOfSupply
- `pPlayer:GetNumUnitsOutOfSupply()`
- `player:GetNumUnitsOutOfSupply()`
- 10 callsites. Example: `UI/InGame/TopPanel.lua:213`

### GetNumUnitsSupplied
- `pPlayer:GetNumUnitsSupplied()`
- 11 callsites. Example: `UI/InGame/TopPanel.lua:212`

### GetNumUnitsSuppliedByCities
- `pPlayer:GetNumUnitsSuppliedByCities()`
- 3 callsites. Example: `UI/InGame/Popups/MilitaryOverview.lua:96`

### GetNumUnitsSuppliedByHandicap
- `pPlayer:GetNumUnitsSuppliedByHandicap()`
- 3 callsites. Example: `UI/InGame/Popups/MilitaryOverview.lua:95`

### GetNumUnitsSuppliedByPopulation
- `pPlayer:GetNumUnitsSuppliedByPopulation()`
- 3 callsites. Example: `UI/InGame/Popups/MilitaryOverview.lua:97`

### GetNumWarsFought
- `pActivePlayer:GetNumWarsFought(iOtherPlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:766`

### GetNumWondersBeatenTo
- `pOtherPlayer:GetNumWondersBeatenTo(iBuilder)`
- 1 callsite. Example: `DLC/DLC_06/Scenarios/WonderScenario/WonderStatus.lua:405`

### GetNumWorldWonders
- `pPlayer:GetNumWorldWonders()`
- `player:GetNumWorldWonders()`
- 3 callsites. Example: `UI/InGame/Popups/WhosWinningPopup.lua:242`

### GetOccupiedPopulationUnhappinessMod
- `pPlayer:GetOccupiedPopulationUnhappinessMod()`
- 3 callsites. Example: `UI/InGame/Popups/HappinessInfo.lua:538`

### GetOpinionTable
- `pOtherPlayer:GetOpinionTable(iActivePlayer)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/InfoTooltipInclude.lua:1170`

### GetOtherPlayerNumProtectedMinorsAttacked
- `pOtherPlayer:GetOtherPlayerNumProtectedMinorsAttacked(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:901`

### GetOtherPlayerNumProtectedMinorsKilled
- `pOtherPlayer:GetOtherPlayerNumProtectedMinorsKilled(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:897`

### GetOthersGreatWorks
- `activePlayer:GetOthersGreatWorks()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/CultureOverview.lua:1577`

### GetPersonality
- `pPlayer:GetPersonality()`
- 13 callsites. Example: `UI/InGame/Popups/CityStateDiploPopup.lua:244`

### GetPlayerBuildingClassHappiness
- `pActivePlayer:GetPlayerBuildingClassHappiness(buildingClassID)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/InfoTooltipInclude.lua:160`

### GetPlayerBuildingClassYieldChange
- `pActivePlayer:GetPlayerBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_CULTURE)`
- `pActivePlayer:GetPlayerBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_FAITH)`
- `pActivePlayer:GetPlayerBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_FOOD)`
- `pActivePlayer:GetPlayerBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_GOLD)`
- `pActivePlayer:GetPlayerBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_SCIENCE)`
- ...and 1 more distinct call shapes
- 12 callsites. Example: `DLC/Expansion2/UI/InGame/InfoTooltipInclude.lua:169`

### GetPlayerColor
- `player:GetPlayerColor()`
- 1 callsite. Example: `UI/InGame/Popups/ReplayViewer.lua:1239`

### GetPlayerColors
- `pPlayer:GetPlayerColors()`
- `pOtherPlayer:GetPlayerColors()`
- `player:GetPlayerColors()`
- `pOriginalOwner:GetPlayerColors()`
- 41 callsites. Example: `UI/InGame/Popups/CityStateDiploPopup.lua:86`

### GetPlotDanger
- `player:GetPlotDanger(plot)`
- 6 callsites. Example: `Tutorial/lua/TutorialChecks.lua:303`

### GetPolicyBuildingClassYieldChange
- `pActivePlayer:GetPolicyBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_SCIENCE)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/InfoTooltipInclude.lua:234`

### GetPolicyBuildingClassYieldModifier
- `pActivePlayer:GetPolicyBuildingClassYieldModifier(buildingClassID, YieldTypes.YIELD_GOLD)`
- `pActivePlayer:GetPolicyBuildingClassYieldModifier(buildingClassID, YieldTypes.YIELD_SCIENCE)`
- `pActivePlayer:GetPolicyBuildingClassYieldModifier(buildingClassID, YieldTypes.YIELD_PRODUCTION)`
- 9 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:168`

### GetPolicyCatchSpiesModifier
- `activePlayer:GetPolicyCatchSpiesModifier()`
- `pActivePlayer:GetPolicyCatchSpiesModifier()`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/EspionageOverview.lua:448`

### GetPolicyEspionageCatchSpiesModifier
- `pPlayer:GetPolicyEspionageCatchSpiesModifier(i)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/EspionageOverview.lua:919`

### GetPolicyEspionageModifier
- `pPlayer:GetPolicyEspionageModifier(i)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/EspionageOverview.lua:869`

### GetPolicyGreatArtistRateModifier
- `pPlayer:GetPolicyGreatArtistRateModifier()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/CityView/CityView.lua:1151`

### GetPolicyGreatEngineerRateModifier
- `pPlayer:GetPolicyGreatEngineerRateModifier()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/CityView/CityView.lua:1181`

### GetPolicyGreatMerchantRateModifier
- `pPlayer:GetPolicyGreatMerchantRateModifier()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/CityView/CityView.lua:1175`

### GetPolicyGreatMusicianRateModifier
- `pPlayer:GetPolicyGreatMusicianRateModifier()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/CityView/CityView.lua:1160`

### GetPolicyGreatPeopleRateModifier
- `pPlayer:GetPolicyGreatPeopleRateModifier()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/CityView/CityView.lua:1129`

### GetPolicyGreatScientistRateModifier
- `pPlayer:GetPolicyGreatScientistRateModifier()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/CityView/CityView.lua:1169`

### GetPolicyGreatWriterRateModifier
- `pPlayer:GetPolicyGreatWriterRateModifier()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/CityView/CityView.lua:1142`

### GetPotentialAdmiralNewPort
- `pPlayer:GetPotentialAdmiralNewPort(pUnit)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseAdmiralNewPort.lua:112`

### GetPotentialInternationalTradeRouteDestinations
- `pActivePlayer:GetPotentialInternationalTradeRouteDestinations(pHeadSelectedUnit)`
- `pPlayer:GetPotentialInternationalTradeRouteDestinations(pUnit)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/InGame.lua:750`

### GetPotentialTradeUnitNewHomeCity
- `pPlayer:GetPotentialTradeUnitNewHomeCity(pUnit)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseTradeUnitNewHome.lua:122`

### GetProjectProductionNeeded
- `Players[Game.GetActivePlayer()]:GetProjectProductionNeeded(projectID)`
- `pActivePlayer:GetProjectProductionNeeded(iProjectID)`
- 7 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:3157`

### GetPublicOpinionPreferredIdeology
- `player:GetPublicOpinionPreferredIdeology()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/SocialPolicyPopup.lua:735`

### GetPublicOpinionTooltip
- `pPlayer:GetPublicOpinionTooltip()`
- `player:GetPublicOpinionTooltip()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CultureOverview.lua:1848`

### GetPublicOpinionType
- `pPlayer:GetPublicOpinionType()`
- `player:GetPublicOpinionType()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CultureOverview.lua:1836`

### GetPublicOpinionUnhappiness
- `player:GetPublicOpinionUnhappiness()`
- `pPlayer:GetPublicOpinionUnhappiness()`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/SocialPolicyPopup.lua:729`

### GetPublicOpinionUnhappinessTooltip
- `pPlayer:GetPublicOpinionUnhappinessTooltip()`
- `player:GetPublicOpinionUnhappinessTooltip()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CultureOverview.lua:1858`

### GetQuestData1
- `pMinor:GetQuestData1(iMajor, eType)`
- `pMinor:GetQuestData1(g_iPlayer, MinorCivQuestTypes.MINOR_CIV_QUEST_KILL_CAMP)`
- `pOtherPlayer:GetQuestData1(iActivePlayer, MinorCivQuestTypes.MINOR_CIV_QUEST_KILL_CAMP)`
- `pMinor:GetQuestData1(iActivePlayer, MinorCivQuestTypes.MINOR_CIV_QUEST_KILL_CAMP)`
- `pOtherPlayer:GetQuestData1(g_iPlayer)`
- ...and 2 more distinct call shapes
- 14 callsites. Example: `DLC/Expansion2/UI/InGame/CityStateStatusHelper.lua:474`

### GetQuestData2
- `pMinor:GetQuestData2(iMajor, eType)`
- `pMinor:GetQuestData2(g_iPlayer, MinorCivQuestTypes.MINOR_CIV_QUEST_KILL_CAMP)`
- `pOtherPlayer:GetQuestData2(iActivePlayer, MinorCivQuestTypes.MINOR_CIV_QUEST_KILL_CAMP)`
- `pMinor:GetQuestData2(iActivePlayer, MinorCivQuestTypes.MINOR_CIV_QUEST_KILL_CAMP)`
- `pOtherPlayer:GetQuestData2(g_iPlayer)`
- ...and 2 more distinct call shapes
- 14 callsites. Example: `DLC/Expansion2/UI/InGame/CityStateStatusHelper.lua:475`

### GetQuestTurnsRemaining
- `pMinor:GetQuestTurnsRemaining(iMajor, eType, Game.GetGameTurn() - 1)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/CityStateStatusHelper.lua:589`

### GetQueuePosition
- `player:GetQueuePosition(techID)`
- `player:GetQueuePosition(tech.ID)`
- 9 callsites. Example: `UI/InGame/TechTree/TechTree.lua:690`

### GetRealPopulation
- `Players[iPlayer]:GetRealPopulation()`
- 1 callsite. Example: `UI/InGame/Popups/Demographics.lua:119`

### GetRecentAssistValue
- `pOtherPlayer:GetRecentAssistValue(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:874`

### GetRecentIntrigueInfo
- `pPlayer:GetRecentIntrigueInfo(g_iAIPlayer)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/LeaderHead/DiscussionDialog.lua:678`

### GetRecentTradeValue
- `pOtherPlayer:GetRecentTradeValue(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:868`

### GetRecommendedFoundCityPlots
- `player:GetRecommendedFoundCityPlots()`
- 3 callsites. Example: `UI/InGame/InGame.lua:830`

### GetRecommendedWorkerPlots
- `player:GetRecommendedWorkerPlots()`
- 3 callsites. Example: `UI/InGame/InGame.lua:813`

### GetReligionCreatedByPlayer
- `pPlayer:GetReligionCreatedByPlayer()`
- `player:GetReligionCreatedByPlayer()`
- 22 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseReligionPopup.lua:277`

### GetReplayData
- `player:GetReplayData()`
- 1 callsite. Example: `UI/InGame/Popups/ReplayViewer.lua:1251`

### GetResearchCost
- `pPlayer:GetResearchCost(eCurrentTech)`
- `player:GetResearchCost(techID)`
- `pActivePlayer:GetResearchCost(iTechID)`
- 8 callsites. Example: `UI/InGame/TechPanel.lua:73`

### GetResearchProgress
- `pPlayer:GetResearchProgress(eCurrentTech)`
- `player:GetResearchProgress(techID)`
- `pActivePlayer:GetResearchProgress(iTechID)`
- 8 callsites. Example: `UI/InGame/TechPanel.lua:72`

### GetResearchTurnsLeft
- `player:GetResearchTurnsLeft(techID, true)`
- `pPlayer:GetResearchTurnsLeft(eCurrentTech, true)`
- `player:GetResearchTurnsLeft(tech.ID, true)`
- 20 callsites. Example: `UI/InGame/TechPopup.lua:100`

### GetResourceExport
- `pPlayer:GetResourceExport(iResourceID)`
- `pPlayer:GetResourceExport(iResourceLoop)`
- `pMinor:GetResourceExport(iResourceLoop)`
- `pPlayer:GetResourceExport(iResource)`
- 12 callsites. Example: `UI/InGame/Popups/HappinessInfo.lua:700`

### GetResourceImport
- `pPlayer:GetResourceImport(iResourceID)`
- `pPlayer:GetResourceImport(iResource)`
- 4 callsites. Example: `UI/InGame/Popups/HappinessInfo.lua:658`

### GetRouteGoldTimes100
- `pPlayer:GetRouteGoldTimes100(pCity)`
- 2 callsites. Example: `UI/InGame/Popups/EconomicGeneralInfo.lua:255`

### GetScience
- `player:GetScience()`
- `pPlayer:GetScience()`
- 46 callsites. Example: `UI/InGame/TechPopup.lua:152`

### GetScienceFromBudgetDeficitTimes100
- `pPlayer:GetScienceFromBudgetDeficitTimes100()`
- 8 callsites. Example: `UI/InGame/TopPanel.lua:328`

### GetScienceFromCitiesTimes100
- `pPlayer:GetScienceFromCitiesTimes100()`
- `pPlayer:GetScienceFromCitiesTimes100(true)`
- `pPlayer:GetScienceFromCitiesTimes100(false)`
- 7 callsites. Example: `UI/InGame/TopPanel.lua:343`

### GetScienceFromHappinessTimes100
- `pPlayer:GetScienceFromHappinessTimes100()`
- 5 callsites. Example: `UI/InGame/TopPanel.lua:371`

### GetScienceFromOtherPlayersTimes100
- `pPlayer:GetScienceFromOtherPlayersTimes100()`
- 5 callsites. Example: `UI/InGame/TopPanel.lua:357`

### GetScienceFromResearchAgreementsTimes100
- `pPlayer:GetScienceFromResearchAgreementsTimes100()`
- 5 callsites. Example: `UI/InGame/TopPanel.lua:385`

### GetScore
- `pPlayer:GetScore()`
- `player:GetScore()`
- `pOtherPlayer:GetScore()`
- `Players[b]:GetScore()`
- `Players[a]:GetScore()`
- ...and 2 more distinct call shapes
- 51 callsites. Example: `UI/InGame/Popups/VictoryProgress.lua:185`

### GetScoreFromCities
- `pPlayer:GetScoreFromCities()`
- `g_pPlayer:GetScoreFromCities()`
- `pOtherPlayer:GetScoreFromCities()`
- 12 callsites. Example: `UI/InGame/Popups/VictoryProgress.lua:179`

### GetScoreFromFutureTech
- `pPlayer:GetScoreFromFutureTech()`
- `g_pPlayer:GetScoreFromFutureTech()`
- `pOtherPlayer:GetScoreFromFutureTech()`
- 14 callsites. Example: `UI/InGame/Popups/VictoryProgress.lua:184`

### GetScoreFromGreatWorks
- `g_pPlayer:GetScoreFromGreatWorks()`
- `pOtherPlayer:GetScoreFromGreatWorks()`
- `pPlayer:GetScoreFromGreatWorks()`
- 6 callsites. Example: `DLC/Expansion2/UI/InGame/DiploList.lua:230`

### GetScoreFromLand
- `pPlayer:GetScoreFromLand()`
- `g_pPlayer:GetScoreFromLand()`
- `pOtherPlayer:GetScoreFromLand()`
- 12 callsites. Example: `UI/InGame/Popups/VictoryProgress.lua:181`

### GetScoreFromPolicies
- `g_pPlayer:GetScoreFromPolicies()`
- `pOtherPlayer:GetScoreFromPolicies()`
- `pPlayer:GetScoreFromPolicies()`
- 6 callsites. Example: `DLC/Expansion2/UI/InGame/DiploList.lua:228`

### GetScoreFromPopulation
- `pPlayer:GetScoreFromPopulation()`
- `g_pPlayer:GetScoreFromPopulation()`
- `pOtherPlayer:GetScoreFromPopulation()`
- 12 callsites. Example: `UI/InGame/Popups/VictoryProgress.lua:180`

### GetScoreFromReligion
- `g_pPlayer:GetScoreFromReligion()`
- `pOtherPlayer:GetScoreFromReligion()`
- `pPlayer:GetScoreFromReligion()`
- 6 callsites. Example: `DLC/Expansion2/UI/InGame/DiploList.lua:232`

### GetScoreFromScenario1
- `g_pPlayer:GetScoreFromScenario1()`
- `pOtherPlayer:GetScoreFromScenario1()`
- `pPlayer:GetScoreFromScenario1()`
- 6 callsites. Example: `DLC/Expansion2/UI/InGame/DiploList.lua:236`

### GetScoreFromScenario2
- `pPlayer:GetScoreFromScenario2()`
- `g_pPlayer:GetScoreFromScenario2()`
- `pOtherPlayer:GetScoreFromScenario2()`
- 7 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/VictoryProgress.lua:205`

### GetScoreFromScenario3
- `pPlayer:GetScoreFromScenario3()`
- `g_pPlayer:GetScoreFromScenario3()`
- `pOtherPlayer:GetScoreFromScenario3()`
- 8 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/VictoryProgress.lua:206`

### GetScoreFromScenario4
- `pPlayer:GetScoreFromScenario4()`
- `g_pPlayer:GetScoreFromScenario4()`
- `pOtherPlayer:GetScoreFromScenario4()`
- 7 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/VictoryProgress.lua:207`

### GetScoreFromTechs
- `pPlayer:GetScoreFromTechs()`
- `g_pPlayer:GetScoreFromTechs()`
- `pOtherPlayer:GetScoreFromTechs()`
- 13 callsites. Example: `UI/InGame/Popups/VictoryProgress.lua:183`

### GetScoreFromWonders
- `pPlayer:GetScoreFromWonders()`
- `g_pPlayer:GetScoreFromWonders()`
- `pOtherPlayer:GetScoreFromWonders()`
- 13 callsites. Example: `UI/InGame/Popups/VictoryProgress.lua:182`

### GetStartingPlot
- `pLoopPlayer:GetStartingPlot()`
- `pPlayer:GetStartingPlot()`
- `player:GetStartingPlot()`
- `pPlayer1:GetStartingPlot()`
- `pPlayer2:GetStartingPlot()`
- ...and 4 more distinct call shapes
- 86 callsites. Example: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:1563`

### GetStateReligionKey
- `pPlayer:GetStateReligionKey()`
- 3 callsites. Example: `UI/InGame/CityView/CityView.lua:320`

### GetSwappableGreatArt
- `activePlayer:GetSwappableGreatArt()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CultureOverview.lua:1209`

### GetSwappableGreatArtifact
- `activePlayer:GetSwappableGreatArtifact()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CultureOverview.lua:1212`

### GetSwappableGreatMusic
- `activePlayer:GetSwappableGreatMusic()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/CultureOverview.lua:1218`

### GetSwappableGreatWriting
- `activePlayer:GetSwappableGreatWriting()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CultureOverview.lua:1215`

### GetTeam
- `pPlayer:GetTeam()`
- `player:GetTeam()`
- `pOtherPlayer:GetTeam()`
- `Players[Game.GetActivePlayer()]:GetTeam()`
- `pActivePlayer:GetTeam()`
- ...and 40 more distinct call shapes
- 611 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:2010`

### GetTenet
- `player:GetTenet(iIdeology, 1, i)`
- `player:GetTenet(iIdeology, 2, i)`
- `player:GetTenet(iIdeology, 3, i)`
- 6 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/SocialPolicyPopup.lua:552`

### GetTotalFaithPerTurn
- `pPlayer:GetTotalFaithPerTurn()`
- 5 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:173`

### GetTotalJONSCulturePerTurn
- `pPlayer:GetTotalJONSCulturePerTurn()`
- `player:GetTotalJONSCulturePerTurn()`
- 49 callsites. Example: `UI/InGame/TopPanel.lua:137`

### GetTotalPopulation
- `pPlayer:GetTotalPopulation()`
- 4 callsites. Example: `UI/InGame/Popups/HappinessInfo.lua:407`

### GetTourism
- `pPlayer:GetTourism()`
- `pLoopPlayer:GetTourism()`
- `player:GetTourism()`
- 5 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:163`

### GetTradeRouteGoldModifier
- `pPlayer:GetTradeRouteGoldModifier()`
- 1 callsite. Example: `DLC/Expansion/UI/InGame/Popups/EconomicGeneralInfo.lua:265`

### GetTradeRouteRange
- `pPlayer:GetTradeRouteRange(eDomain, pOriginCity)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseInternationalTradeRoutePopup.lua:278`

### GetTradeRoutes
- `activePlayer:GetTradeRoutes()`
- `pPlayer:GetTradeRoutes()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/DeclareWarPopup.lua:330`

### GetTradeRoutesAvailable
- `pPlayer:GetTradeRoutesAvailable()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/TradeRouteOverview.lua:353`

### GetTradeRoutesToYou
- `activePlayer:GetTradeRoutesToYou()`
- `pPlayer:GetTradeRoutesToYou()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/DeclareWarPopup.lua:331`

### GetTradeToYouRoutesTTString
- `pPlayer:GetTradeToYouRoutesTTString()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:1287`

### GetTradeUnitType
- `pPlayer:GetTradeUnitType(DomainTypes.DOMAIN_LAND)`
- `pPlayer:GetTradeUnitType(DomainTypes.DOMAIN_SEA)`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:1257`

### GetTradeYourRoutesTTString
- `pPlayer:GetTradeYourRoutesTTString()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:1279`

### GetTraitCityStateCombatModifier
- `pMyPlayer:GetTraitCityStateCombatModifier()`
- 6 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:461`

### GetTraitCityUnhappinessMod
- `pPlayer:GetTraitCityUnhappinessMod()`
- 6 callsites. Example: `UI/InGame/Popups/HappinessInfo.lua:428`

### GetTraitGoldenAgeCombatModifier
- `pMyPlayer:GetTraitGoldenAgeCombatModifier()`
- 6 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:454`

### GetTraitGreatGeneralExtraBonus
- `pMyPlayer:GetTraitGreatGeneralExtraBonus()`
- 6 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:509`

### GetTraitGreatScientistRateModifier
- `player:GetTraitGreatScientistRateModifier()`
- `pPlayer:GetTraitGreatScientistRateModifier()`
- 4 callsites. Example: `UI/InGame/GPList.lua:241`

### GetTraitPopUnhappinessMod
- `pPlayer:GetTraitPopUnhappinessMod()`
- 3 callsites. Example: `UI/InGame/Popups/HappinessInfo.lua:504`

### GetTurnLastPledgeBrokenByMajor
- `pPlayer:GetTurnLastPledgeBrokenByMajor(iActivePlayer)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CityStateDiploPopup.lua:507`

### GetTurnLastPledgedProtectionByMajor
- `pPlayer:GetTurnLastPledgedProtectionByMajor(iActivePlayer)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CityStateDiploPopup.lua:495`

### GetTurnsSinceThreatenedByBarbarians
- `pOtherPlayer:GetTurnsSinceThreatenedByBarbarians()`
- `pPlayer:GetTurnsSinceThreatenedByBarbarians()`
- 5 callsites. Example: `Tutorial/lua/TutorialChecks.lua:1124`

### GetUnhappiness
- `pPlayer:GetUnhappiness()`
- `activePlayer:GetUnhappiness()`
- 11 callsites. Example: `UI/InGame/TopPanel.lua:628`

### GetUnhappinessForecast
- `activePlayer:GetUnhappinessForecast(nil, newCity)`
- `activePlayer:GetUnhappinessForecast(newCity, nil)`
- 8 callsites. Example: `UI/InGame/PopupsGeneric/PuppetCityPopup.lua:39`

### GetUnhappinessFromCapturedCityCount
- `pPlayer:GetUnhappinessFromCapturedCityCount()`
- 8 callsites. Example: `UI/InGame/TopPanel.lua:631`

### GetUnhappinessFromCityCount
- `pPlayer:GetUnhappinessFromCityCount()`
- 8 callsites. Example: `UI/InGame/TopPanel.lua:630`

### GetUnhappinessFromCityForUI
- `pPlayer:GetUnhappinessFromCityForUI(pCity)`
- 3 callsites. Example: `UI/InGame/Popups/HappinessInfo.lua:564`

### GetUnhappinessFromCityPopulation
- `pPlayer:GetUnhappinessFromCityPopulation()`
- 8 callsites. Example: `UI/InGame/TopPanel.lua:635`

### GetUnhappinessFromCitySpecialists
- `pPlayer:GetUnhappinessFromCitySpecialists()`
- 5 callsites. Example: `UI/InGame/TopPanel.lua:634`

### GetUnhappinessFromOccupiedCities
- `pPlayer:GetUnhappinessFromOccupiedCities()`
- 8 callsites. Example: `UI/InGame/TopPanel.lua:638`

### GetUnhappinessFromPublicOpinion
- `pPlayer:GetUnhappinessFromPublicOpinion()`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:754`

### GetUnhappinessFromPuppetCityPopulation
- `pPlayer:GetUnhappinessFromPuppetCityPopulation()`
- 5 callsites. Example: `UI/InGame/TopPanel.lua:633`

### GetUnhappinessFromUnits
- `pPlayer:GetUnhappinessFromUnits()`
- 8 callsites. Example: `UI/InGame/TopPanel.lua:629`

### GetUnhappinessMod
- `pPlayer:GetUnhappinessMod()`
- 3 callsites. Example: `UI/InGame/Popups/HappinessInfo.lua:499`

### GetUnimprovedAvailableLuxuryResource
- `player:GetUnimprovedAvailableLuxuryResource()`
- 4 callsites. Example: `Tutorial/lua/TutorialChecks.lua:876`

### GetUnitBaktun
- `player:GetUnitBaktun(info.ID)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseMayaBonus.lua:40`

### GetUnitByID
- `Players[playerID]:GetUnitByID(unitID)`
- `Players[self.m_PlayerID]:GetUnitByID(self.m_UnitID)`
- `player:GetUnitByID(iUnitID)`
- `player:GetUnitByID(unitID)`
- `pPlayer:GetUnitByID(iUnitID)`
- ...and 5 more distinct call shapes
- 113 callsites. Example: `UI/InGame/UnitFlagManager.lua:80`

### GetUnitClassCount
- `pPlayer:GetUnitClassCount(t.UnitClass)`
- `pPlayer:GetUnitClassCount(iAirshipUnitClass)`
- `pPlayer:GetUnitClassCount(iLandshipUnitClass)`
- 3 callsites. Example: `DLC/Expansion/Scenarios/SteampunkScenario/TurnsRemaining.lua:172`

### GetUnitProductionMaintenanceMod
- `pPlayer:GetUnitProductionMaintenanceMod()`
- 8 callsites. Example: `UI/InGame/TopPanel.lua:210`

### GetUnitProductionNeeded
- `Players[Game.GetActivePlayer()]:GetUnitProductionNeeded(unitID)`
- `pActivePlayer:GetUnitProductionNeeded(iUnitID)`
- 7 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:2362`

### GetWarmongerPreviewString
- `activePlayer:GetWarmongerPreviewString(iPreviousOwner)`
- `player:GetWarmongerPreviewString(city:GetOwner())`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/PopupsGeneric/PuppetCityPopup.lua:76`

### GetWarmongerThreat
- `pOtherPlayer:GetWarmongerThreat(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:923`

### GetWeDeclaredWarOnFriendCount
- `pActivePlayer:GetWeDeclaredWarOnFriendCount()`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:805`

### GetWeDenouncedFriendCount
- `pActivePlayer:GetWeDenouncedFriendCount()`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:808`

### GetWonderDisputeLevel
- `pOtherPlayer:GetWonderDisputeLevel(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:917`

### GetWrittenArtifactCulture
- `pPlayer:GetWrittenArtifactCulture()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseArchaeologyPopup.lua:296`

### GreatAdmiralThreshold
- `pPlayer:GreatAdmiralThreshold()`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/GPList.lua:183`

### GreatGeneralThreshold
- `pPlayer:GreatGeneralThreshold()`
- 6 callsites. Example: `UI/InGame/GPList.lua:162`

### HasAvailableGreatWorkSlot
- `pPlayer:HasAvailableGreatWorkSlot(GameInfo.GreatWorkSlots.GREAT_WORK_SLOT_ART_ARTIFACT.ID)`
- `pPlayer:HasAvailableGreatWorkSlot(GameInfo.GreatWorkSlots.GREAT_WORK_SLOT_LITERATURE.ID)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseArchaeologyPopup.lua:97`

### HasCreatedPantheon
- `player:HasCreatedPantheon()`
- `pPlayer:HasCreatedPantheon()`
- 21 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseFaithGreatPerson.lua:40`

### HasCreatedReligion
- `pPlayer:HasCreatedReligion()`
- `player:HasCreatedReligion()`
- `Players[0]:HasCreatedReligion()`
- 33 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:1119`

### HasPolicy
- `player:HasPolicy(i)`
- `player:HasPolicy(policyIndex)`
- `pPlayer:HasPolicy(i)`
- `pOtherPlayer:HasPolicy(iPolicy)`
- `pPlayer:HasPolicy(GameInfo.Policies["POLICY_BARBARIAN_FINISHER"].ID)`
- ...and 6 more distinct call shapes
- 33 callsites. Example: `UI/InGame/Popups/SocialPolicyPopup.lua:459`

### HasReceivedNetTurnComplete
- `pPlayer:HasReceivedNetTurnComplete()`
- `otherPlayer:HasReceivedNetTurnComplete()`
- 6 callsites. Example: `UI/TurnStatusBehavior.lua:39`

### HasRecentIntrigueAbout
- `activePlayer:HasRecentIntrigueAbout(iPlayer)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/LeaderHead/DiscussionDialog.lua:220`

### HasReligionInMostCities
- `pPlayer:HasReligionInMostCities(eReligion)`
- 1 callsite. Example: `DLC/Expansion/Scenarios/MedievalScenario/TurnsRemaining.lua:726`

### HasSpyEstablishedSurveillance
- `pActivePlayer:HasSpyEstablishedSurveillance(v.AgentID)`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/EspionageOverview.lua:781`

### HasTurnTimerExpired
- `pPlayer:HasTurnTimerExpired()`
- 1 callsite. Example: `UI/TurnStatusBehavior.lua:45`

### HasUnitOfClassType
- `player:HasUnitOfClassType(unitClassID)`
- `player:HasUnitOfClassType(unitClassProphetID)`
- 2 callsites. Example: `DLC/Expansion2/Tutorial/Lua/TutorialInclude_Expansion2.lua:68`

### InitCity
- `player:InitCity(plot:GetX(), plot:GetY())`
- `pActivePlayer:InitCity(plotX, plotY)`
- `pPlayer:InitCity(startPlot:GetX(), startPlot:GetY())`
- `pPlayer:InitCity(start_plot:GetX(), start_plot:GetY())`
- `player:InitCity(68, 68)`
- ...and 7 more distinct call shapes
- 17 callsites. Example: `UI/InGame/WorldView/WorldView.lua:231`

### InitUnit
- `pPlayer:InitUnit(GameInfoTypes["UNIT_CARTHAGINIAN_QUINQUEREME"], iSpawnX, iSpawnY)`
- `pPlayer:InitUnit(GameInfoTypes["UNIT_CATAPULT"], iSpawnX, iSpawnY)`
- `pPlayer:InitUnit(GameInfoTypes["UNIT_COMPOSITE_BOWMAN"], iSpawnX, iSpawnY)`
- `pPlayer:InitUnit(GameInfoTypes["UNIT_VANDAL_AXEMAN"], iSpawnX, iSpawnY)`
- `pPlayer:InitUnit(GameInfoTypes["UNIT_HORSEMAN"], iSpawnX, iSpawnY)`
- ...and 57 more distinct call shapes
- 225 callsites. Example: `DLC/Expansion/Scenarios/FallOfRomeScenario/TurnsRemaining.lua:1639`

### InitUnitWithNameOffset
- `player:InitUnitWithNameOffset(g_UnitPlopper.UnitType, g_UnitPlopper.UnitNameOffset, plot:GetX(), plot:GetY())`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/WorldView/WorldView.lua:169`

### IsAbleToAnnexCityStates
- `pActivePlayer:IsAbleToAnnexCityStates()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CityStateDiploPopup.lua:549`

### IsAlive
- `pPlayer:IsAlive()`
- `pOtherPlayer:IsAlive()`
- `Players[playerID]:IsAlive()`
- `player:IsAlive()`
- `pLoopPlayer:IsAlive()`
- ...and 4 more distinct call shapes
- 217 callsites. Example: `UI/TurnStatusBehavior.lua:38`

### IsAllies
- `pMinor:IsAllies(iMajor)`
- `pPlayer:IsAllies(iActivePlayer)`
- `Players[eOwner]:IsAllies(ePlayer)`
- `player:IsAllies(iActivePlayer)`
- `pPlayer:IsAllies(iForPlayer)`
- 18 callsites. Example: `DLC/Expansion2/UI/InGame/CityStateStatusHelper.lua:64`

### IsAnarchy
- `pPlayer:IsAnarchy()`
- `player:IsAnarchy()`
- 15 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:396`

### IsAnyGoodyPlotAccessible
- `player:IsAnyGoodyPlotAccessible()`
- 2 callsites. Example: `Tutorial/lua/TutorialChecks.lua:368`

### IsAnyPlotImproved
- `player:IsAnyPlotImproved()`
- 4 callsites. Example: `Tutorial/lua/TutorialChecks.lua:411`

### IsAskedToStopConverting
- `pAIPlayer:IsAskedToStopConverting(iActivePlayer)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/LeaderHead/DiscussionDialog.lua:240`

### IsAskedToStopDigging
- `pAIPlayer:IsAskedToStopDigging(iActivePlayer)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/LeaderHead/DiscussionDialog.lua:250`

### IsBarbarian
- `player:IsBarbarian()`
- 6 callsites. Example: `UI/InGame/TurnProcessing.lua:60`

### IsBuildBlockedByFeature
- `pActivePlayer:IsBuildBlockedByFeature(iBuildID, iFeature)`
- 3 callsites. Example: `UI/InGame/WorldView/UnitPanel.lua:1160`

### IsCanPurchaseAnyCity
- `player:IsCanPurchaseAnyCity(false, true, unit.ID, -1, YieldTypes.YIELD_FAITH)`
- `player:IsCanPurchaseAnyCity(false, true, -1, building.ID, YieldTypes.YIELD_FAITH)`
- `pPlayer:IsCanPurchaseAnyCity(false, true, infoID, -1, YieldTypes.YIELD_FAITH)`
- `player:IsCanPurchaseAnyCity(false, true, infoID, -1, YieldTypes.YIELD_FAITH)`
- 8 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ReligionOverview.lua:402`

### IsCapitalCapturedBy
- `pOtherPlayer:IsCapitalCapturedBy(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:892`

### IsCapitalConnectedToCity
- `pPlayer:IsCapitalConnectedToCity(pCity)`
- `player:IsCapitalConnectedToCity(city)`
- 12 callsites. Example: `UI/InGame/CityView/CityView.lua:671`

### IsConnected
- `pPlayer:IsConnected()`
- 1 callsite. Example: `UI/InGame/WorldView/MPList.lua:252`

### IsDemandEverMade
- `pOtherPlayer:IsDemandEverMade(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:829`

### IsDenouncedPlayer
- `activePlayer:IsDenouncedPlayer(iPlayer)`
- `Players[g_iUs]:IsDenouncedPlayer(iOtherPlayer)`
- `pOtherPlayer:IsDenouncedPlayer(iThirdPlayer)`
- `pActivePlayer:IsDenouncedPlayer(iOtherPlayer)`
- `pOtherPlayer:IsDenouncedPlayer(iActivePlayer)`
- ...and 1 more distinct call shapes
- 12 callsites. Example: `UI/InGame/LeaderHead/DiscussionDialog.lua:205`

### IsDenouncingPlayer
- `pOtherPlayer:IsDenouncingPlayer(g_iPlayer)`
- `Players[g_iAIPlayer]:IsDenouncingPlayer(iActivePlayer)`
- `Players[g_iAIPlayer]:IsDenouncingPlayer(Game.GetActivePlayer())`
- `pOtherPlayer:IsDenouncingPlayer(iPlayer)`
- `Players[iLeader]:IsDenouncingPlayer(iActivePlayer)`
- 16 callsites. Example: `UI/InGame/DiploList.lua:323`

### IsDoF
- `pAIPlayer:IsDoF(iActivePlayer)`
- `pOtherPlayer:IsDoF(iThirdPlayer)`
- `g_pUs:IsDoF(g_iThem)`
- `g_pThem:IsDoF(g_iUs)`
- `pActivePlayer:IsDoF(iOtherPlayer)`
- ...and 1 more distinct call shapes
- 14 callsites. Example: `UI/InGame/LeaderHead/DiscussionDialog.lua:190`

### IsDoFMessageTooSoon
- `pAIPlayer:IsDoFMessageTooSoon(iActivePlayer)`
- 6 callsites. Example: `UI/InGame/LeaderHead/DiscussionDialog.lua:190`

### IsDontSettleMessageTooSoon
- `pAIPlayer:IsDontSettleMessageTooSoon(iActivePlayer)`
- 3 callsites. Example: `UI/InGame/LeaderHead/DiscussionDialog.lua:183`

### IsEmpireSuperUnhappy
- `pPlayer:IsEmpireSuperUnhappy()`
- 5 callsites. Example: `UI/InGame/TopPanel.lua:534`

### IsEmpireUnhappy
- `pPlayer:IsEmpireUnhappy()`
- `player:IsEmpireUnhappy()`
- 17 callsites. Example: `UI/InGame/TopPanel.lua:92`

### IsEmpireVeryUnhappy
- `pPlayer:IsEmpireVeryUnhappy()`
- `pMyPlayer:IsEmpireVeryUnhappy()`
- `player:IsEmpireVeryUnhappy()`
- `pActivePlayer:IsEmpireVeryUnhappy()`
- 32 callsites. Example: `UI/InGame/TopPanel.lua:96`

### IsEverAlive
- `pPlayer:IsEverAlive()`
- `player:IsEverAlive()`
- `pLoopPlayer:IsEverAlive()`
- `Players[i]:IsEverAlive()`
- 75 callsites. Example: `UI/InGame/Popups/VictoryProgress.lua:223`

### IsFreeMayaGreatPersonChoice
- `player:IsFreeMayaGreatPersonChoice()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseMayaBonus.lua:41`

### IsFriendDeclaredWarOnUs
- `pOtherPlayer:IsFriendDeclaredWarOnUs(g_iUs)`
- `pOtherPlayer:IsFriendDeclaredWarOnUs(iActivePlayer)`
- 3 callsites. Example: `UI/InGame/Popups/DiploGlobalRelationships.lua:134`

### IsFriendDenouncedUs
- `pOtherPlayer:IsFriendDenouncedUs(g_iUs)`
- `pOtherPlayer:IsFriendDenouncedUs(iActivePlayer)`
- 3 callsites. Example: `UI/InGame/Popups/DiploGlobalRelationships.lua:134`

### IsFriends
- `pPlayer:IsFriends(iActivePlayer)`
- `pMinor:IsFriends(iMajor)`
- `pOtherPlayer:IsFriends()`
- `player:IsFriends(iActivePlayer)`
- `pPlayer:IsFriends(iForPlayer)`
- 14 callsites. Example: `UI/InGame/Popups/CityStateDiploPopup.lua:77`

### IsGaveAssistanceTo
- `pOtherPlayer:IsGaveAssistanceTo(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:883`

### IsGoldenAge
- `pMyPlayer:IsGoldenAge()`
- 6 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:455`

### IsGoldenAgeCultureBonusDisabled
- `pPlayer:IsGoldenAgeCultureBonusDisabled()`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:839`

### IsHalfSpecialistUnhappiness
- `pPlayer:IsHalfSpecialistUnhappiness()`
- 6 callsites. Example: `UI/InGame/Popups/HappinessInfo.lua:514`

### IsHasLostCapital
- `pPlayer:IsHasLostCapital()`
- 14 callsites. Example: `UI/InGame/Popups/VictoryProgress.lua:241`

### IsHasPaidTributeTo
- `pOtherPlayer:IsHasPaidTributeTo(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:886`

### IsHuman
- `player:IsHuman()`
- `pPlayer:IsHuman()`
- `pOtherPlayer:IsHuman()`
- `Players[ePlayer]:IsHuman()`
- `Players[iPlayerID]:IsHuman()`
- ...and 7 more distinct call shapes
- 152 callsites. Example: `UI/InGame/CityBannerManager.lua:1091`

### IsLiberatedCapital
- `pOtherPlayer:IsLiberatedCapital(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:877`

### IsLiberatedCity
- `pOtherPlayer:IsLiberatedCity(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:880`

### IsMinorCiv
- `pPlayer:IsMinorCiv()`
- `player:IsMinorCiv()`
- `pOtherPlayer:IsMinorCiv()`
- `owner:IsMinorCiv()`
- `pLoopPlayer:IsMinorCiv()`
- ...and 12 more distinct call shapes
- 140 callsites. Example: `UI/InGame/Popups/Demographics.lua:48`

### IsMinorCivActiveQuestForPlayer
- `pMinor:IsMinorCivActiveQuestForPlayer(iMajor, eType)`
- `pMinor:IsMinorCivActiveQuestForPlayer(g_iPlayer, MinorCivQuestTypes.MINOR_CIV_QUEST_KILL_CAMP)`
- `pOtherPlayer:IsMinorCivActiveQuestForPlayer(iActivePlayer, MinorCivQuestTypes.MINOR_CIV_QUEST_KILL_CAMP)`
- `pMinor:IsMinorCivActiveQuestForPlayer(iActivePlayer, MinorCivQuestTypes.MINOR_CIV_QUEST_KILL_CAMP)`
- 5 callsites. Example: `DLC/Expansion/UI/InGame/CityStateStatusHelper.lua:401`

### IsMinorCivContestLeader
- `pMinor:IsMinorCivContestLeader(iMajor, MinorCivQuestTypes.MINOR_CIV_QUEST_CONTEST_CULTURE)`
- `pMinor:IsMinorCivContestLeader(iMajor, MinorCivQuestTypes.MINOR_CIV_QUEST_CONTEST_FAITH)`
- `pMinor:IsMinorCivContestLeader(iMajor, MinorCivQuestTypes.MINOR_CIV_QUEST_CONTEST_TECHS)`
- 6 callsites. Example: `DLC/Expansion2/UI/InGame/CityStateStatusHelper.lua:614`

### IsMinorCivDisplayedQuestForPlayer
- `pMinor:IsMinorCivDisplayedQuestForPlayer(iMajor, eType)`
- `pMinor:IsMinorCivDisplayedQuestForPlayer(g_iPlayer, MinorCivQuestTypes.MINOR_CIV_QUEST_KILL_CAMP)`
- `pOtherPlayer:IsMinorCivDisplayedQuestForPlayer(iActivePlayer, MinorCivQuestTypes.MINOR_CIV_QUEST_KILL_CAMP)`
- `pMinor:IsMinorCivDisplayedQuestForPlayer(iActivePlayer, MinorCivQuestTypes.MINOR_CIV_QUEST_KILL_CAMP)`
- 6 callsites. Example: `DLC/Expansion2/UI/InGame/CityStateStatusHelper.lua:469`

### IsMinorCivHasUniqueUnit
- `pMinor:IsMinorCivHasUniqueUnit()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/CityStateStatusHelper.lua:710`

### IsMinorCivUnitSpawningDisabled
- `pPlayer:IsMinorCivUnitSpawningDisabled(iActivePlayer)`
- 6 callsites. Example: `UI/InGame/Popups/CityStateDiploPopup.lua:456`

### IsMinorPermanentWar
- `pPlayer:IsMinorPermanentWar(iActiveTeam)`
- `pMinor:IsMinorPermanentWar(iActiveTeam)`
- `pLoopPlayer:IsMinorPermanentWar(iFromPlayer)`
- `player:IsMinorPermanentWar(iActiveTeam)`
- 12 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:357`

### IsMinorWarQuestWithMajorActive
- `pOtherPlayer:IsMinorWarQuestWithMajorActive()`
- `pPlayer:IsMinorWarQuestWithMajorActive(iPlayerLoop)`
- 7 callsites. Example: `Tutorial/lua/TutorialChecks.lua:1128`

### IsMyDiplomatVisitingThem
- `pActivePlayer:IsMyDiplomatVisitingThem(iPlayer)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:371`

### IsNukedBy
- `pOtherPlayer:IsNukedBy(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:889`

### IsObserver
- `pPlayer:IsObserver()`
- 9 callsites. Example: `UI/InGame/WorldView/MPList.lua:34`

### IsPeaceBlocked
- `pPlayer:IsPeaceBlocked(iActiveTeam)`
- `pMinor:IsPeaceBlocked(iActiveTeam)`
- `player:IsPeaceBlocked(iActiveTeam)`
- 12 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:363`

### IsPlayerBrokenBorderPromise
- `pOtherPlayer:IsPlayerBrokenBorderPromise(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:847`

### IsPlayerBrokenCityStatePromise
- `pOtherPlayer:IsPlayerBrokenCityStatePromise(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:853`

### IsPlayerBrokenCoopWarPromise
- `pOtherPlayer:IsPlayerBrokenCoopWarPromise(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:859`

### IsPlayerBrokenExpansionPromise
- `pOtherPlayer:IsPlayerBrokenExpansionPromise(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:841`

### IsPlayerBrokenMilitaryPromise
- `pOtherPlayer:IsPlayerBrokenMilitaryPromise(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:835`

### IsPlayerDenouncedEnemy
- `pActivePlayer:IsPlayerDenouncedEnemy(iOtherPlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:786`

### IsPlayerDenouncedFriend
- `pOtherPlayer:IsPlayerDenouncedFriend(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:823`

### IsPlayerDoFwithAnyEnemy
- `pOtherPlayer:IsPlayerDoFwithAnyEnemy(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:820`

### IsPlayerDoFwithAnyFriend
- `pActivePlayer:IsPlayerDoFwithAnyFriend(iOtherPlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:783`

### IsPlayerHasOpenBorders
- `pPlayer:IsPlayerHasOpenBorders(iActivePlayer)`
- `pMinor:IsPlayerHasOpenBorders(iMajor)`
- 5 callsites. Example: `UI/InGame/Popups/CityStateDiploPopup.lua:144`

### IsPlayerHasOpenBordersAutomatically
- `pPlayer:IsPlayerHasOpenBordersAutomatically(iActivePlayer)`
- `pMinor:IsPlayerHasOpenBordersAutomatically(iMajor)`
- 5 callsites. Example: `UI/InGame/Popups/CityStateDiploPopup.lua:148`

### IsPlayerIgnoredBorderPromise
- `pOtherPlayer:IsPlayerIgnoredBorderPromise(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:850`

### IsPlayerIgnoredCityStatePromise
- `pOtherPlayer:IsPlayerIgnoredCityStatePromise(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:856`

### IsPlayerIgnoredExpansionPromise
- `pOtherPlayer:IsPlayerIgnoredExpansionPromise(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:844`

### IsPlayerIgnoredMilitaryPromise
- `pOtherPlayer:IsPlayerIgnoredMilitaryPromise(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:838`

### IsPlayerNoSettleRequestEverAsked
- `pOtherPlayer:IsPlayerNoSettleRequestEverAsked(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:826`

### IsPlayerRecklessExpander
- `pOtherPlayer:IsPlayerRecklessExpander(iActivePlayer)`
- 1 callsite. Example: `UI/InGame/InfoTooltipInclude.lua:862`

### IsPolicyBlocked
- `player:IsPolicyBlocked(policyIndex)`
- `player:IsPolicyBlocked(i)`
- `pPlayer:IsPolicyBlocked(i)`
- 22 callsites. Example: `UI/InGame/Popups/SocialPolicyPopup.lua:83`

### IsPolicyBranchBlocked
- `player:IsPolicyBranchBlocked(policy.ID)`
- `player:IsPolicyBranchBlocked(policyBranchIndex)`
- `player:IsPolicyBranchBlocked(i)`
- `pPlayer:IsPolicyBranchBlocked(GameInfo.PolicyBranchTypes["POLICY_BRANCH_AUTOCRACY"].ID)`
- `pPlayer:IsPolicyBranchBlocked(GameInfo.PolicyBranchTypes["POLICY_BRANCH_COMMERCE"].ID)`
- ...and 3 more distinct call shapes
- 36 callsites. Example: `DLC/Expansion/UI/InGame/Popups/ReligionOverview.lua:270`

### IsPolicyBranchFinished
- `pPlayer:IsPolicyBranchFinished(row.ID)`
- `player:IsPolicyBranchFinished(GameInfo.PolicyBranchTypes["POLICY_BRANCH_AESTHETICS"].ID)`
- `player:IsPolicyBranchFinished(GameInfo.PolicyBranchTypes["POLICY_BRANCH_COMMERCE"].ID)`
- `player:IsPolicyBranchFinished(GameInfo.PolicyBranchTypes["POLICY_BRANCH_RATIONALISM"].ID)`
- `player:IsPolicyBranchFinished(GameInfo.PolicyBranchTypes["POLICY_BRANCH_HONOR"].ID)`
- ...and 2 more distinct call shapes
- 13 callsites. Example: `UI/InGame/Popups/VictoryProgress.lua:849`

### IsPolicyBranchUnlocked
- `player:IsPolicyBranchUnlocked(policy.ID)`
- `player:IsPolicyBranchUnlocked(policyBranchIndex)`
- `player:IsPolicyBranchUnlocked(i)`
- `pPlayer:IsPolicyBranchUnlocked(GameInfo.PolicyBranchTypes["POLICY_BRANCH_AUTOCRACY"].ID)`
- `pPlayer:IsPolicyBranchUnlocked(GameInfo.PolicyBranchTypes["POLICY_BRANCH_COMMERCE"].ID)`
- ...and 8 more distinct call shapes
- 42 callsites. Example: `DLC/Expansion/UI/InGame/Popups/ReligionOverview.lua:270`

### IsProtectedByMajor
- `pPlayer:IsProtectedByMajor(iActivePlayer)`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CityStateDiploPopup.lua:390`

### IsProtectingMinor
- `pOtherPlayer:IsProtectingMinor(g_iMinorCivID)`
- `pOtherPlayer:IsProtectingMinor(iMinor)`
- `pActivePlayer:IsProtectingMinor(iPlayer)`
- `player:IsProtectingMinor(RivalId)`
- 9 callsites. Example: `UI/InGame/Popups/CityStateDiploPopup.lua:649`

### IsProxyWarActiveForMajor
- `pMinor:IsProxyWarActiveForMajor(iMajor)`
- `pOtherPlayer:IsProxyWarActiveForMajor(g_iPlayer)`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/CityStateStatusHelper.lua:528`

### IsSimultaneousTurns
- `pPlayer:IsSimultaneousTurns()`
- 1 callsite. Example: `UI/InGame/WorldView/MPTurnPanel.lua:90`

### IsSpyDiplomat
- `pActivePlayer:IsSpyDiplomat(v.AgentID)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/EspionageOverview.lua:795`

### IsSpySchmoozing
- `pActivePlayer:IsSpySchmoozing(v.AgentID)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/EspionageOverview.lua:796`

### IsStopSpyingMessageTooSoon
- `pAIPlayer:IsStopSpyingMessageTooSoon(iActivePlayer)`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/LeaderHead/DiscussionDialog.lua:235`

### IsThreateningBarbariansEventActiveForPlayer
- `pMinor:IsThreateningBarbariansEventActiveForPlayer(iMajor)`
- `pOtherPlayer:IsThreateningBarbariansEventActiveForPlayer(g_iPlayer)`
- 7 callsites. Example: `DLC/Expansion2/UI/InGame/CityStateStatusHelper.lua:522`

### IsTraitBonusReligiousBelief
- `pPlayer:IsTraitBonusReligiousBelief()`
- 6 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseReligionPopup.lua:463`

### IsTurnActive
- `Players[Game.GetActivePlayer()]:IsTurnActive()`
- `player:IsTurnActive()`
- `pPlayer:IsTurnActive()`
- 61 callsites. Example: `UI/InGame/CityBannerManager.lua:1086`

### IsUsingMayaCalendar
- `pPlayer:IsUsingMayaCalendar()`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:257`

### IsWillAcceptPeaceWithPlayer
- `Players[iFromPlayer]:IsWillAcceptPeaceWithPlayer(iLoopPlayer)`
- `pLoopPlayer:IsWillAcceptPeaceWithPlayer(iFromPlayer)`
- 6 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:2603`

### MayNotAnnex
- `player:MayNotAnnex()`
- `activePlayer:MayNotAnnex()`
- 6 callsites. Example: `DLC/Expansion2/UI/InGame/CityBannerManager.lua:193`

### SetEmbarkedGraphicOverride
- `pLoopPlayer:SetEmbarkedGraphicOverride("ART_DEF_UNIT_U_SPANISH_GALLEON")`
- 2 callsites. Example: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:1777`

### SetFaith
- `pPlayer:SetFaith(125)`
- `pPlayer:SetFaith(100)`
- `pPlayer:SetFaith(75)`
- `pPlayer:SetFaith(50)`
- `pPlayer:SetFaith(25)`
- ...and 6 more distinct call shapes
- 12 callsites. Example: `DLC/Expansion/Scenarios/MedievalScenario/TurnsRemaining.lua:1624`

### SetFaithPurchaseIndex
- `player:SetFaithPurchaseIndex(v2)`
- 1 callsite. Example: `DLC/Expansion/Scenarios/MedievalScenario/ReligionOverview.lua:481`

### SetFaithPurchaseType
- `player:SetFaithPurchaseType(v1)`
- 1 callsite. Example: `DLC/Expansion/Scenarios/MedievalScenario/ReligionOverview.lua:480`

### SetGold
- `pPlayer:SetGold(250)`
- `Players[Spain_PlayerID]:SetGold(200)`
- `Players[France_PlayerID]:SetGold(1000)`
- `Players[England_PlayerID]:SetGold(200)`
- `Players[Inca_PlayerID]:SetGold(2000)`
- ...and 16 more distinct call shapes
- 28 callsites. Example: `DLC/Expansion/Scenarios/MedievalScenario/TurnsRemaining.lua:1625`

### SetGreatGeneralCombatBonus
- `pPlayer:SetGreatGeneralCombatBonus(30)`
- `pPlayer:SetGreatGeneralCombatBonus(10)`
- `pPlayer:SetGreatGeneralCombatBonus(20)`
- `Players[Union_PlayerID]:SetGreatGeneralCombatBonus(10)`
- `Players[Confederate_PlayerID]:SetGreatGeneralCombatBonus(20)`
- 8 callsites. Example: `DLC/Expansion2/Scenarios/CivilWarScenario/TurnsRemaining.lua:409`

### SetHasPolicy
- `pPlayer:SetHasPolicy(GameInfo.Policies["POLICY_ORGANIZED_RELIGION"].ID, true)`
- `pPlayer:SetHasPolicy(GameInfo.Policies["POLICY_DISCIPLINE"].ID, true)`
- `pPlayer:SetHasPolicy(GameInfo.Policies["POLICY_ROMAN_ATROPHY"].ID, true)`
- `pPlayer:SetHasPolicy(GameInfo.Policies["POLICY_SASSANID_HERITAGE"].ID, true)`
- `pPlayer:SetHasPolicy(GameInfo.Policies["POLICY_BARBARIAN_HERITAGE"].ID, true)`
- ...and 6 more distinct call shapes
- 14 callsites. Example: `DLC/DLC_05/Scenarios/KoreaScenario/TurnsRemaining.lua:645`

### SetJONSCulture
- `pPlayer:SetJONSCulture(125)`
- `Players[iPlayer]:SetJONSCulture(iMod)`
- `pPlayer:SetJONSCulture(0)`
- `pPlayer:SetJONSCulture(1740)`
- 17 callsites. Example: `DLC/Expansion/Scenarios/MedievalScenario/TurnsRemaining.lua:1623`

### SetMinorCivUniqueUnit
- `Players[i]:SetMinorCivUniqueUnit(eUniqueUnit)`
- 2 callsites. Example: `DLC/Expansion2/Scenarios/ScrambleAfricaScenario/TurnsRemaining.lua:732`

### SetNumWondersBeatenTo
- `pOtherPlayer:SetNumWondersBeatenTo(iBuilder, iWondersBeatenTo)`
- 1 callsite. Example: `DLC/DLC_06/Scenarios/WonderScenario/WonderStatus.lua:407`

### SetPolicyBranchUnlocked
- `pPlayer:SetPolicyBranchUnlocked(GameInfo.PolicyBranchTypes["POLICY_BRANCH_PIETY"].ID, true)`
- `pPlayer:SetPolicyBranchUnlocked(GameInfo.PolicyBranchTypes["POLICY_BRANCH_HONOR"].ID, true)`
- `pPlayer:SetPolicyBranchUnlocked(GameInfo.PolicyBranchTypes["POLICY_BRANCH_ROMAN"].ID, true)`
- `pPlayer:SetPolicyBranchUnlocked(GameInfo.PolicyBranchTypes["POLICY_BRANCH_SASSANID"].ID, true)`
- `pPlayer:SetPolicyBranchUnlocked(GameInfo.PolicyBranchTypes["POLICY_BRANCH_BARBARIAN"].ID, true)`
- ...and 7 more distinct call shapes
- 15 callsites. Example: `DLC/DLC_05/Scenarios/KoreaScenario/TurnsRemaining.lua:644`

### SetStartingPlot
- `player:SetStartingPlot(plot)`
- `player:SetStartingPlot(start_plot)`
- `pPlayer:SetStartingPlot(start_plot)`
- 88 callsites. Example: `Gameplay/Lua/AssignStartingPlots.lua:4490`

### Units
- `player:Units()`
- `pPlayer:Units()`
- 128 callsites. Example: `UI/InGame/InGame.lua:437`

### WasResurrectedThisTurnBy
- `Players[g_iAIPlayer]:WasResurrectedThisTurnBy(iActivePlayer)`
- `pOtherPlayer:WasResurrectedThisTurnBy(g_iPlayer)`
- `pOtherPlayer:WasResurrectedThisTurnBy(iPlayer)`
- 9 callsites. Example: `DLC/Expansion2/UI/InGame/LeaderHead/DiscussionDialog.lua:71`
