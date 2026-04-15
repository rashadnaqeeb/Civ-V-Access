# Game

Global game state. Static table; call with dot syntax: `Game.GetActivePlayer()`.

Extracted from 2531 call sites across 150 distinct methods in the shipped game Lua.

## Methods

### CanDoControl
- `Game.CanDoControl(ControlTypes.CONTROL_RETIRE)`
- `Game.CanDoControl(ControlTypes.CONTROL_RESTART_GAME)`
- 2 callsites. Example: `UI/InGame/Menus/GameMenu.lua:169`

### CanHandleAction
- `Game.CanHandleAction(iAction, 0, 1)`
- `Game.CanHandleAction(iAction)`
- 12 callsites. Example: `UI/InGame/WorldView/UnitPanel.lua:189`

### ChangeNoNukesCount
- `Game:ChangeNoNukesCount(5 + iRandom)`
- 2 callsites. Example: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:1553`

### ChangeNukesExploded
- `Game:ChangeNukesExploded(1)`
- 2 callsites. Example: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:472`

### ChangeNumVotesForTeam
- `Game.ChangeNumVotesForTeam(iTeam, kiVaticanExtraVotes)`
- 1 callsite. Example: `DLC/Expansion/Scenarios/MedievalScenario/TurnsRemaining.lua:401`

### CityPurchaseBuilding
- `Game.CityPurchaseBuilding(city, iData, eYield)`
- `Game.CityPurchaseBuilding(city, iData)`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ProductionPopup.lua:141`

### CityPurchaseProject
- `Game.CityPurchaseProject(city, iData, eYield)`
- `Game.CityPurchaseProject(city, iData)`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ProductionPopup.lua:145`

### CityPurchaseUnit
- `Game.CityPurchaseUnit(city, iData, eYield)`
- `Game.CityPurchaseUnit(city, iData)`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ProductionPopup.lua:137`

### CityPushOrder
- `Game.CityPushOrder(city, eOrder, iData, false, not g_append, true)`
- 3 callsites. Example: `UI/InGame/Popups/ProductionPopup.lua:84`

### CountCivPlayersAlive
- `Game.CountCivPlayersAlive()`
- 3 callsites. Example: `Gameplay/Lua/WorldBuilderRandomItems.lua:42`

### CountCivTeamsEverAlive
- `Game.CountCivTeamsEverAlive()`
- 2 callsites. Example: `Gameplay/Lua/MapmakerUtilities.lua:60`

### CountHumanPlayersAlive
- `Game.CountHumanPlayersAlive()`
- 2 callsites. Example: `UI/InGame/Popups/EndGameMenu.lua:14`

### CycleUnits
- `Game.CycleUnits(true, true, false)`
- `Game.CycleUnits(true, false, false)`
- 6 callsites. Example: `UI/InGame/WorldView/UnitPanel.lua:697`

### DoControl
- `Game.DoControl(GameInfoTypes.CONTROL_PREVCITY)`
- `Game.DoControl(GameInfoTypes.CONTROL_NEXTCITY)`
- `Game.DoControl(iEndTurnControl)`
- `Game.DoControl(ControlTypes.CONTROL_RESTART_GAME)`
- `Game.DoControl(ControlTypes.CONTROL_RETIRE)`
- 17 callsites. Example: `UI/InGame/CityView/CityView.lua:118`

### DoFromUIDiploEvent
- `Game.DoFromUIDiploEvent(FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_COOP_WAR_RESPONSE, g_iAIPlayer, iButtonID, iAgainstPlayer)`
- `Game.DoFromUIDiploEvent(FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_WORK_AGAINST_SOMEONE_RESPONSE, g_iAIPlayer, iButtonID, iAgainstPlayer)`
- `Game.DoFromUIDiploEvent(FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_CAUGHT_YOUR_SPY_RESPONSE, g_iAIPlayer, iButtonID, iAgainstPlayer)`
- `Game.DoFromUIDiploEvent(FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_AGGRESSIVE_MILITARY_WARNING_RESPONSE, g_iAIPlayer, iButtonID, 0)`
- `Game.DoFromUIDiploEvent(FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_ATTACKED_MINOR_RESPONSE, g_iAIPlayer, iButtonID, 0)`
- ...and 35 more distinct call shapes
- 157 callsites. Example: `UI/InGame/LeaderHead/DiscussionDialog.lua:558`

### DoMinorBullyGold
- `Game.DoMinorBullyGold(iActivePlayer, g_iMinorCivID)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CityStateDiploPopup.lua:1076`

### DoMinorBullyUnit
- `Game.DoMinorBullyUnit(iActivePlayer, g_iMinorCivID)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CityStateDiploPopup.lua:1080`

### DoMinorBuyout
- `Game.DoMinorBuyout(iActivePlayer, g_iMinorCivID)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CityStateDiploPopup.lua:661`

### DoMinorGiftTileImprovement
- `Game.DoMinorGiftTileImprovement(iFromPlayer, iToPlayer, iPlotX, iPlotY)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/InGame.lua:283`

### DoMinorGoldGift
- `Game.DoMinorGoldGift(g_iMinorCivID, iGoldGiftSmall)`
- `Game.DoMinorGoldGift(g_iMinorCivID, iGoldGiftMedium)`
- `Game.DoMinorGoldGift(g_iMinorCivID, iGoldGiftLarge)`
- `Game.DoMinorGoldGift(iMinor, iGoldGiftSmall)`
- `Game.DoMinorGoldGift(iMinor, iGoldGiftMedium)`
- ...and 1 more distinct call shapes
- 12 callsites. Example: `UI/InGame/Popups/CityStateDiploPopup.lua:786`

### DoMinorPledgeProtection
- `Game.DoMinorPledgeProtection(Game.GetActivePlayer(), g_iMinorCivID, true)`
- `Game.DoMinorPledgeProtection(iActivePlayer, g_iMinorCivID, false)`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CityStateDiploPopup.lua:631`

### EnhanceReligion
- `Game.EnhanceReligion(iPlayer, eReligion, eBelief4, eBelief5)`
- `Game.EnhanceReligion(iVaticanPlayer, eReligion, eBelief4, eBelief5)`
- `Game.EnhanceReligion(iMeccaPlayer, eReligion, eBelief4, eBelief5)`
- 6 callsites. Example: `DLC/Expansion/Scenarios/MedievalScenario/TurnsRemaining.lua:875`

### FoundPantheon
- `Game.FoundPantheon(iPlayer, eBelief1)`
- `Game.FoundPantheon(iVaticanPlayer, eBelief1)`
- `Game.FoundPantheon(iMeccaPlayer, eBelief1)`
- 5 callsites. Example: `DLC/Expansion/Scenarios/MedievalScenario/TurnsRemaining.lua:873`

### FoundReligion
- `Game.FoundReligion(iPlayer, eReligion, nil, eBelief2, eBelief3, -1, -1, capital)`
- `Game.FoundReligion(iVaticanPlayer, eReligion, nil, eBelief2, eBelief3, -1, -1, pVaticanCity)`
- `Game.FoundReligion(iMeccaPlayer, eReligion, nil, eBelief2, eBelief3, -1, -1, pMeccaCity)`
- `Game.FoundReligion(iPlayer, eReligion, nil, eBelief1, eBelief2, eBelief3, -1, pBestCity)`
- `Game.FoundReligion(iActivePlayer, 3, nil, g_BeliefID, -1, -1, -1, pCapital)`
- ...and 9 more distinct call shapes
- 16 callsites. Example: `DLC/Expansion/Scenarios/MedievalScenario/TurnsRemaining.lua:874`

### GetActiveLeague
- `Game.GetActiveLeague()`
- 16 callsites. Example: `DLC/Expansion2/UI/Civilopedia/CivilopediaScreen.lua:3022`

### GetActivePlayer
- `Game.GetActivePlayer()`
- `Game:GetActivePlayer()`
- 831 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:2009`

### GetActiveTeam
- `Game.GetActiveTeam()`
- 201 callsites. Example: `UI/InGame/GenericWorldAnchor.lua:120`

### GetAdvisorCounsel
- `Game.GetAdvisorCounsel()`
- 1 callsite. Example: `UI/InGame/Popups/AdvisorCounselPopup.lua:175`

### GetAllowRClickMovementWhileScrolling
- `Game.GetAllowRClickMovementWhileScrolling()`
- 3 callsites. Example: `UI/InGame/WorldView/WorldView.lua:641`

### GetArtifactName
- `Game.GetArtifactName(pPlot)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseArchaeologyPopup.lua:116`

### GetAvailableBonusBeliefs
- `Game.GetAvailableBonusBeliefs()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseReligionPopup.lua:226`

### GetAvailableEnhancerBeliefs
- `Game.GetAvailableEnhancerBeliefs()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseReligionPopup.lua:198`

### GetAvailableFollowerBeliefs
- `Game.GetAvailableFollowerBeliefs()`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseReligionPopup.lua:142`

### GetAvailableFounderBeliefs
- `Game.GetAvailableFounderBeliefs()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseReligionPopup.lua:114`

### GetAvailablePantheonBeliefs
- `Game.GetAvailablePantheonBeliefs()`
- 7 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ChoosePantheonPopup.lua:91`

### GetAvailableReformationBeliefs
- `Game.GetAvailableReformationBeliefs()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ChoosePantheonPopup.lua:103`

### GetBeliefsInReligion
- `Game.GetBeliefsInReligion(eReligion)`
- 11 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseReligionPopup.lua:378`

### GetBuildingYieldChange
- `Game.GetBuildingYieldChange(buildingID, YieldTypes[yieldType])`
- `Game.GetBuildingYieldChange(iBuildingID, YieldTypes.YIELD_FOOD)`
- `Game.GetBuildingYieldChange(iBuildingID, YieldTypes.YIELD_GOLD)`
- `Game.GetBuildingYieldChange(iBuildingID, YieldTypes.YIELD_SCIENCE)`
- `Game.GetBuildingYieldChange(iBuildingID, YieldTypes.YIELD_PRODUCTION)`
- ...and 2 more distinct call shapes
- 20 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:2794`

### GetBuildingYieldModifier
- `Game.GetBuildingYieldModifier(buildingID, YieldTypes[yieldType])`
- `Game.GetBuildingYieldModifier(iBuildingID, YieldTypes.YIELD_GOLD)`
- `Game.GetBuildingYieldModifier(iBuildingID, YieldTypes.YIELD_SCIENCE)`
- `Game.GetBuildingYieldModifier(iBuildingID, YieldTypes.YIELD_PRODUCTION)`
- 13 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:2809`

### GetCalendar
- `Game.GetCalendar()`
- 1 callsite. Example: `UI/InGame/Popups/ReplayViewer.lua:1217`

### GetCombatPrediction
- `Game.GetCombatPrediction(pMyUnit, pTheirUnit)`
- 3 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:715`

### GetCustomOption
- `Game.GetCustomOption("GAMEOPTION_DISABLE_START_BIAS")`
- 4 callsites. Example: `Gameplay/Lua/AssignStartingPlots.lua:4336`

### GetDealDuration
- `Game.GetDealDuration()`
- 6 callsites. Example: `UI/InGame/Popups/DiploRelationships.lua:19`

### GetElapsedGameTurns
- `Game.GetElapsedGameTurns()`
- 7 callsites. Example: `UI/InGame/Menus/SaveMenu.lua:233`

### GetFaithCost
- `Game.GetFaithCost(unitID)`
- 3 callsites. Example: `DLC/Expansion2/UI/Civilopedia/CivilopediaScreen.lua:2570`

### GetFounder
- `Game.GetFounder(GameInfoTypes["RELIGION_ORTHODOXY"], -1)`
- `Game.GetFounder(GameInfoTypes["RELIGION_ISLAM"], -1)`
- `Game.GetFounder(GameInfoTypes["RELIGION_CHRISTIANITY"], -1)`
- `Game.GetFounder(GameInfoTypes["RELIGION_PROTESTANTISM"], -1)`
- 4 callsites. Example: `DLC/Expansion/Scenarios/MedievalScenario/TurnsRemaining.lua:1184`

### GetFounderBenefitsReligion
- `Game.GetFounderBenefitsReligion(iPlayer)`
- `Game.GetFounderBenefitsReligion(iActivePlayer)`
- 2 callsites. Example: `DLC/Expansion/Scenarios/MedievalScenario/ReligionOverview.lua:113`

### GetGameSpeedType
- `Game.GetGameSpeedType()`
- 1 callsite. Example: `UI/InGame/Popups/ReplayViewer.lua:1213`

### GetGameState
- `Game.GetGameState()`
- `Game:GetGameState()`
- 23 callsites. Example: `UI/InGame/WorldView/DiploCorner.lua:373`

### GetGameTurn
- `Game.GetGameTurn()`
- 109 callsites. Example: `Automation/AutomationStartup.lua:31`

### GetGameTurnYear
- `Game.GetGameTurnYear()`
- 10 callsites. Example: `UI/InGame/NewTurn.lua:44`

### GetGreatWorkArtist
- `Game.GetGreatWorkArtist(iGWIndex)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/GreatWorkPopup.lua:125`

### GetGreatWorkClass
- `Game.GetGreatWorkClass(iIndex)`
- `Game.GetGreatWorkClass(g_iTheirItem)`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CultureOverview.lua:1258`

### GetGreatWorkController
- `Game.GetGreatWorkController(iIndex)`
- `Game.GetGreatWorkController(g_iTheirItem)`
- `Game.GetGreatWorkController(g_iYourItem)`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CultureOverview.lua:1356`

### GetGreatWorkCreator
- `Game.GetGreatWorkCreator(iIndex)`
- `Game.GetGreatWorkCreator(iWritingSwapIndex)`
- `Game.GetGreatWorkCreator(iArtSwapIndex)`
- `Game.GetGreatWorkCreator(iArtifactSwapIndex)`
- 5 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CultureOverview.lua:1279`

### GetGreatWorkCurrentThemingBonus
- `Game.GetGreatWorkCurrentThemingBonus(v.Index)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/CultureOverview.lua:1450`

### GetGreatWorkEraShort
- `Game.GetGreatWorkEraShort(iIndex)`
- `Game.GetGreatWorkEraShort(v.Index)`
- `Game.GetGreatWorkEraShort(iWritingSwapIndex)`
- `Game.GetGreatWorkEraShort(iArtSwapIndex)`
- `Game.GetGreatWorkEraShort(iArtifactSwapIndex)`
- ...and 3 more distinct call shapes
- 9 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CultureOverview.lua:1282`

### GetGreatWorkName
- `Game.GetGreatWorkName(v.Index)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/CultureOverview.lua:1447`

### GetGreatWorkTooltip
- `Game.GetGreatWorkTooltip(greatWorkIndex, playerID)`
- `Game.GetGreatWorkTooltip(iIndex, activePlayerID)`
- `Game.GetGreatWorkTooltip(iGreatWorkIndex, pCity:GetOwner())`
- `Game.GetGreatWorkTooltip(iIndex, g_iTradingPartner)`
- `Game.GetGreatWorkTooltip(v.Index, activePlayerID)`
- ...and 6 more distinct call shapes
- 13 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CultureOverview.lua:711`

### GetGreatWorkType
- `Game.GetGreatWorkType(iGreatWorkIndex)`
- `Game.GetGreatWorkType(greatWorkIndex)`
- `Game.GetGreatWorkType(iGWIndex)`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/CityView/CityView.lua:387`

### GetHandicapType
- `Game:GetHandicapType()`
- 48 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:1087`

### GetHolyCityForReligion
- `Game.GetHolyCityForReligion(eReligion, iPlayer)`
- `Game.GetHolyCityForReligion(GameInfoTypes["RELIGION_PROTESTANTISM"], -1)`
- `Game.GetHolyCityForReligion(GameInfoTypes["RELIGION_ORTHODOXY"], -1)`
- `Game.GetHolyCityForReligion(GameInfoTypes["RELIGION_ISLAM"], -1)`
- `Game.GetHolyCityForReligion(GameInfoTypes["RELIGION_CHRISTIANITY"], -1)`
- ...and 1 more distinct call shapes
- 11 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ReligionOverview.lua:448`

### GetLeague
- `Game.GetLeague(m_iCurrentLeague)`
- `Game.GetLeague(m_iLeague)`
- `Game.GetLeague(controller.LeagueId)`
- `Game.GetLeague(iLeagueLoop)`
- `Game.GetLeague(iLeague)`
- ...and 1 more distinct call shapes
- 8 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:132`

### GetLongestCityConnectionPlots
- `Game.GetLongestCityConnectionPlots()`
- 1 callsite. Example: `DLC/Expansion2/Scenarios/ScrambleAfricaScenario/TurnsRemaining.lua:427`

### GetMaxTurns
- `Game.GetMaxTurns()`
- 6 callsites. Example: `UI/InGame/Popups/VictoryProgress.lua:506`

### GetMinimumFaithNextPantheon
- `Game.GetMinimumFaithNextPantheon()`
- 5 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:1128`

### GetNoNukesCount
- `Game:GetNoNukesCount()`
- 2 callsites. Example: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:1538`

### GetNukesExploded
- `Game:GetNukesExploded()`
- 4 callsites. Example: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:424`

### GetNumActiveLeagues
- `Game.GetNumActiveLeagues()`
- 17 callsites. Example: `DLC/Expansion2/UI/Civilopedia/CivilopediaScreen.lua:3021`

### GetNumArchaeologySites
- `Game.GetNumArchaeologySites()`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/CultureOverview.lua:497`

### GetNumCitiesFollowing
- `Game.GetNumCitiesFollowing(eReligion)`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/ReligionOverview.lua:468`

### GetNumCitiesPolicyCostMod
- `Game.GetNumCitiesPolicyCostMod()`
- 5 callsites. Example: `UI/InGame/TopPanel.lua:828`

### GetNumCitiesTechCostMod
- `Game.GetNumCitiesTechCostMod()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:498`

### GetNumFreePolicies
- `Game.GetNumFreePolicies(branch.ID)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseIdeologyPopup.lua:146`

### GetNumGameTurnActive
- `Game.GetNumGameTurnActive()`
- 3 callsites. Example: `UI/InGame/PlayerChange.lua:69`

### GetNumHiddenArchaeologySites
- `Game.GetNumHiddenArchaeologySites()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/CultureOverview.lua:502`

### GetNumLeaguesEverFounded
- `Game.GetNumLeaguesEverFounded()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueProjectPopup.lua:48`

### GetNumReligionsFounded
- `Game.GetNumReligionsFounded()`
- 1 callsite. Example: `DLC/Expansion/Scenarios/MedievalScenario/ReligionOverview.lua:264`

### GetNumReligionsStillToFound
- `Game.GetNumReligionsStillToFound()`
- 18 callsites. Example: `DLC/Expansion2/UI/InGame/TopPanel.lua:1119`

### GetNumResourceRequiredForUnit
- `Game.GetNumResourceRequiredForUnit(iUnitID, iResourceID)`
- 3 callsites. Example: `UI/InGame/InfoTooltipInclude.lua:52`

### GetNumVotesForTeam
- `Game.GetNumVotesForTeam(iTeamLoop)`
- 4 callsites. Example: `UI/InGame/Popups/VoteResultsPopup.lua:221`

### GetNumWorldWonders
- `Game.GetNumWorldWonders()`
- 2 callsites. Example: `UI/InGame/Popups/WhosWinningPopup.lua:165`

### GetPeaceDuration
- `Game.GetPeaceDuration()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/TradeLogic.lua:34`

### GetPreviousVoteCast
- `Game.GetPreviousVoteCast(iTeam)`
- `Game.GetPreviousVoteCast(iTeamLoop)`
- 5 callsites. Example: `DLC/Expansion/UI/InGame/Popups/VictoryProgress.lua:801`

### GetReligionName
- `Game.GetReligionName(eReligion)`
- `Game.GetReligionName(iQuestData1)`
- `Game.GetReligionName(iReligionID)`
- `Game.GetReligionName(g_CurrentReligionID)`
- `Game.GetReligionName(unit:GetReligion())`
- ...and 1 more distinct call shapes
- 26 callsites. Example: `DLC/Expansion2/UI/InGame/InfoTooltipInclude.lua:1222`

### GetReplayMessages
- `Game.GetReplayMessages()`
- 2 callsites. Example: `UI/InGame/Popups/EndGameReplay.lua:19`

### GetResearchAgreementCost
- `Game.GetResearchAgreementCost(g_iUs, g_iThem)`
- `Game.GetResearchAgreementCost(g_iThem, g_iUs)`
- 7 callsites. Example: `UI/InGame/WorldView/TradeLogic.lua:923`

### GetResourceUsageType
- `Game.GetResourceUsageType(iResourceLoop)`
- `Game.GetResourceUsageType(iResourceID)`
- `Game.GetResourceUsageType(iResourceType)`
- `Game.GetResourceUsageType(iResource)`
- `Game.GetResourceUsageType(res_ID[use_this_res_index])`
- ...and 1 more distinct call shapes
- 50 callsites. Example: `UI/InGame/TopPanel.lua:162`

### GetStartEra
- `Game.GetStartEra()`
- 6 callsites. Example: `UI/InGame/Popups/ReplayViewer.lua:1212`

### GetStartTurn
- `Game.GetStartTurn()`
- 6 callsites. Example: `UI/InGame/Menus/GameMenu.lua:167`

### GetStartYear
- `Game.GetStartYear()`
- 1 callsite. Example: `UI/InGame/Popups/ReplayViewer.lua:1220`

### GetTimeString
- `Game.GetTimeString()`
- 1 callsite. Example: `UI/InGame/Menus/SaveMenu.lua:79`

### GetTurnsBetweenMinorCivElections
- `Game.GetTurnsBetweenMinorCivElections()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/EspionageOverview.lua:1238`

### GetTurnString
- `Game.GetTurnString()`
- 4 callsites. Example: `UI/InGame/TopPanel.lua:224`

### GetTurnsUntilMinorCivElection
- `Game.GetTurnsUntilMinorCivElection()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/EspionageOverview.lua:1238`

### GetTutorialLevel
- `Game.GetTutorialLevel()`
- 3 callsites. Example: `Tutorial/lua/TutorialEngine.lua:96`

### GetUnitedNationsCountdown
- `Game.GetUnitedNationsCountdown()`
- 3 callsites. Example: `UI/InGame/WorldView/DiploCorner.lua:371`

### GetUnitUpgradesTo
- `Game.GetUnitUpgradesTo(unitID)`
- 4 callsites. Example: `UI/Civilopedia/CivilopediaScreen.lua:2507`

### GetVariableCitySizeFromPopulation
- `Game.GetVariableCitySizeFromPopulation(g_iPopulation)`
- 1 callsite. Example: `UI/InGame/DebugMode.lua:167`

### GetVictory
- `Game.GetVictory()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/VictoryProgress.lua:523`

### GetVoteCast
- `Game.GetVoteCast(iTeam)`
- 4 callsites. Example: `UI/InGame/Popups/VoteResultsPopup.lua:105`

### GetVotesNeededForDiploVictory
- `Game.GetVotesNeededForDiploVictory()`
- 11 callsites. Example: `UI/InGame/Popups/VictoryProgress.lua:437`

### GetWinner
- `Game.GetWinner()`
- `Game:GetWinner()`
- 3 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/VictoryProgress.lua:525`

### GetWorldNumCitiesUnhappinessPercent
- `Game:GetWorldNumCitiesUnhappinessPercent()`
- 6 callsites. Example: `UI/InGame/Popups/HappinessInfo.lua:433`

### HandleAction
- `Game.HandleAction(action)`
- 3 callsites. Example: `UI/InGame/WorldView/UnitPanel.lua:809`

### IsBuildingClassMaxedOut
- `Game.IsBuildingClassMaxedOut(buildingClassID)`
- 1 callsite. Example: `DLC/DLC_06/Scenarios/WonderScenario/WonderStatus.lua:352`

### IsBuildingRecommended
- `Game.IsBuildingRecommended(iBuilding, iAdvisorLoop)`
- 3 callsites. Example: `UI/InGame/Popups/ProductionPopup.lua:1066`

### IsDebugMode
- `Game.IsDebugMode()`
- 14 callsites. Example: `UI/InGame/InGame.lua:87`

### IsEverAttackedTutorial
- `Game:IsEverAttackedTutorial()`
- 2 callsites. Example: `Tutorial/lua/TutorialChecks.lua:1231`

### IsEverRightClickMoved
- `Game.IsEverRightClickMoved()`
- 2 callsites. Example: `Tutorial/lua/TutorialChecks.lua:1968`

### IsGameMultiPlayer
- `Game.IsGameMultiPlayer()`
- `Game:IsGameMultiPlayer()`
- 19 callsites. Example: `UI/InGame/DiploList.lua:230`

### IsHotSeat
- `Game.IsHotSeat()`
- 6 callsites. Example: `UI/InGame/Popups/EndGameMenu.lua:14`

### IsNetworkMultiPlayer
- `Game:IsNetworkMultiPlayer()`
- `Game.IsNetworkMultiPlayer()`
- 112 callsites. Example: `UI/FrontEnd/LoadMenu.lua:673`

### IsOption
- `Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION)`
- `Game.IsOption(GameOptionTypes.GAMEOPTION_NO_SCIENCE)`
- `Game.IsOption(GameOptionTypes.GAMEOPTION_NO_HAPPINESS)`
- `Game.IsOption(GameOptionTypes.GAMEOPTION_NO_POLICIES)`
- `Game.IsOption(GameOptionTypes.GAMEOPTION_ALWAYS_WAR)`
- ...and 12 more distinct call shapes
- 218 callsites. Example: `DLC/Expansion2/UI/Civilopedia/CivilopediaScreen.lua:463`

### IsPaused
- `Game.IsPaused()`
- 2 callsites. Example: `Tutorial/lua/TutorialEngine.lua:184`

### IsProcessingMessages
- `Game.IsProcessingMessages()`
- 19 callsites. Example: `UI/InGame/CityBannerManager.lua:1086`

### IsProjectRecommended
- `Game.IsProjectRecommended(iProject, iAdvisorLoop)`
- 3 callsites. Example: `UI/InGame/Popups/ProductionPopup.lua:1070`

### IsStaticTutorialActive
- `Game.IsStaticTutorialActive()`
- 4 callsites. Example: `UI/InGame/Menus/GameMenu.lua:164`

### IsTechRecommended
- `Game.IsTechRecommended(tech.ID, iAdvisorLoop)`
- 3 callsites. Example: `UI/InGame/TechPopup.lua:251`

### IsTutorialLogging
- `Game.IsTutorialLogging()`
- 2 callsites. Example: `Tutorial/lua/TutorialChecks.lua:1`

### IsUnitedNationsActive
- `Game.IsUnitedNationsActive()`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:192`

### IsUnitRecommended
- `Game.IsUnitRecommended(iUnit, iAdvisorLoop)`
- 3 callsites. Example: `UI/InGame/Popups/ProductionPopup.lua:1062`

### MouseoverUnit
- `Game.MouseoverUnit(pMouseOverUnit,true)`
- `Game.MouseoverUnit(pMouseOverUnit,false)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/UnitFlagManager.lua:217`

### Rand
- `Game.Rand(100, "Rolling_for_treasure")`
- `Game.Rand(#g_tListOfDudes, "Rolling_to_determine_Progress_Screen_dude.")`
- `Game.Rand(#g_tListModeText+1, "Rolling_to_determine_Progress_Screen_list_type.")`
- `Game.Rand(iNumMissions, "Scrambling_mission_order")`
- `Game.Rand(20, "Delay_between_natural_wonder_treasures")`
- ...and 13 more distinct call shapes
- 29 callsites. Example: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:288`

### SelectedCitiesGameNetMessage
- `Game.SelectedCitiesGameNetMessage(GameMessageTypes.GAMEMESSAGE_DO_TASK, TaskTypes.TASK_NO_AUTO_ASSIGN_SPECIALISTS, -1, -1, true)`
- `Game.SelectedCitiesGameNetMessage(GameMessageTypes.GAMEMESSAGE_POP_ORDER, num)`
- `Game.SelectedCitiesGameNetMessage(GameMessageTypes.GAMEMESSAGE_SWAP_ORDER, num)`
- `Game.SelectedCitiesGameNetMessage(GameMessageTypes.GAMEMESSAGE_DO_TASK, TaskTypes.TASK_NO_AUTO_ASSIGN_SPECIALISTS, -1, -1, bValue)`
- `Game.SelectedCitiesGameNetMessage(GameMessageTypes.GAMEMESSAGE_DO_TASK, TaskTypes.TASK_ADD_SPECIALIST, iSpecialist, iBuilding)`
- ...and 2 more distinct call shapes
- 24 callsites. Example: `UI/InGame/CityView/CityView.lua:2060`

### SelectedUnit_SpeculativePopupTradeRoute_Display
- `Game.SelectedUnit_SpeculativePopupTradeRoute_Display(tradeRoute.PlotX, tradeRoute.PlotY, tradeRoute.TradeConnectionType, tradeRoute.eDomain)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseInternationalTradeRoutePopup.lua:346`

### SelectedUnit_SpeculativePopupTradeRoute_Hide
- `Game.SelectedUnit_SpeculativePopupTradeRoute_Hide(tradeRoute.PlotX, tradeRoute.PlotY, tradeRoute.TradeConnectionType)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/Popups/ChooseInternationalTradeRoutePopup.lua:347`

### SelectionListGameNetMessage
- `Game.SelectionListGameNetMessage(GameMessageTypes.GAMEMESSAGE_PUSH_MISSION, eInterfaceModeMission, plotX, plotY, 0, false, bShift)`
- `Game.SelectionListGameNetMessage(GameMessageTypes.GAMEMESSAGE_PUSH_MISSION, MissionTypes.MISSION_RANGE_ATTACK, plotX, plotY, 0, false, bShift)`
- `Game.SelectionListGameNetMessage(GameMessageTypes.GAMEMESSAGE_PUSH_MISSION, MissionTypes.MISSION_EMBARK, plotX, plotY, 0, false, bShift)`
- `Game.SelectionListGameNetMessage(GameMessageTypes.GAMEMESSAGE_PUSH_MISSION, MissionTypes.MISSION_DISEMBARK, plotX, plotY, 0, false, bShift)`
- `Game.SelectionListGameNetMessage(GameMessageTypes.GAMEMESSAGE_PUSH_MISSION, iMission, plotX, plotY, 0, false, bShift)`
- ...and 10 more distinct call shapes
- 33 callsites. Example: `UI/InGame/WorldView/WorldView.lua:365`

### SelectionListMove
- `Game.SelectionListMove(plot, false, false, false)`
- `Game.SelectionListMove(plot, bAlt, bShift, bCtrl)`
- `Game.SelectionListMove(g_referencePlot, false, false, false)`
- 10 callsites. Example: `UI/InGame/InGame.lua:251`

### SetActivePlayer
- `Game.SetActivePlayer(iNextPlayer)`
- 1 callsite. Example: `UI/InGame/Popups/EndGameMenu.lua:30`

### SetAdvisorBadAttackInterrupt
- `Game.SetAdvisorBadAttackInterrupt(false)`
- 1 callsite. Example: `UI/InGame/Popups/AdvisorModal.lua:92`

### SetAdvisorCityAttackInterrupt
- `Game.SetAdvisorCityAttackInterrupt(false)`
- 1 callsite. Example: `UI/InGame/Popups/AdvisorModal.lua:90`

### SetAdvisorMessageHasBeenSeen
- `Game.SetAdvisorMessageHasBeenSeen(eventInfo.IDName, true)`
- 1 callsite. Example: `UI/InGame/WorldView/Advisors.lua:214`

### SetAdvisorRecommenderCity
- `Game.SetAdvisorRecommenderCity(city)`
- 3 callsites. Example: `UI/InGame/Popups/ProductionPopup.lua:216`

### SetAdvisorRecommenderTech
- `Game.SetAdvisorRecommenderTech(playerID)`
- 3 callsites. Example: `UI/InGame/TechPopup.lua:85`

### SetCombatWarned
- `Game.SetCombatWarned(true)`
- 1 callsite. Example: `UI/InGame/Popups/AdvisorModal.lua:106`

### SetEstimateEndTurn
- `Game.SetEstimateEndTurn(50)`
- `Game.SetEstimateEndTurn(100)`
- `Game.SetEstimateEndTurn(300)`
- 3 callsites. Example: `DLC/Expansion2/Scenarios/CivilWarScenario/TurnsRemaining.lua:1172`

### SetEverRightClickMoved
- `Game.SetEverRightClickMoved(true)`
- 3 callsites. Example: `UI/InGame/WorldView/WorldView.lua:647`

### SetFounder
- `Game.SetFounder(GameInfoTypes["RELIGION_ISLAM"], iMeccaPlayer)`
- `Game.SetFounder(GameInfoTypes["RELIGION_CHRISTIANITY"], iVaticanPlayer)`
- `Game.SetFounder(GameInfoTypes["RELIGION_ORTHODOXY"], iNewOwner)`
- `Game.SetFounder(GameInfoTypes["RELIGION_ORTHODOXY"], pNewHolyCity:GetOwner())`
- `Game.SetFounder(GameInfoTypes["RELIGION_ISLAM"], iNewOwner)`
- ...and 9 more distinct call shapes
- 16 callsites. Example: `DLC/Expansion/Scenarios/MedievalScenario/TurnsRemaining.lua:340`

### SetGameState
- `Game.SetGameState(GameplayGameStateTypes.GAMESTATE_OVER)`
- `Game.SetGameState(GameplayGameStateTypes.GAMESTATE_ON)`
- 12 callsites. Example: `DLC/Expansion2/Scenarios/CivilWarScenario/TurnsRemaining.lua:109`

### SetMinimumFaithNextPantheon
- `Game.SetMinimumFaithNextPantheon(100000)`
- `Game.SetMinimumFaithNextPantheon(0)`
- 3 callsites. Example: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:1349`

### SetOption
- `Game.SetOption("GAMEOPTION_NO_LEAGUES", true)`
- `Game.SetOption(GameOptionTypes.GAMEOPTION_NO_CITY_RAZING, true)`
- `Game.SetOption(GameOptionTypes.GAMEOPTION_NO_TUTORIAL, true)`
- 3 callsites. Example: `DLC/Expansion2/Scenarios/CivilWarScenario/TurnsRemaining.lua:1175`

### SetPausePlayer
- `Game.SetPausePlayer(Game.GetActivePlayer())`
- `Game.SetPausePlayer(-1)`
- 5 callsites. Example: `UI/FrontEnd/LoadScreen.lua:139`

### SetStartYear
- `Game.SetStartYear(1492)`
- `Game.SetStartYear(1095)`
- `Game.SetStartYear(300)`
- 4 callsites. Example: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/NewWorld_Scenario_MapScript.lua:2543`

### SetStaticTutorialActive
- `Game.SetStaticTutorialActive(true)`
- 1 callsite. Example: `UI/InGame/Tutorial.lua:8`

### SetUnitedNationsCountdown
- `Game.SetUnitedNationsCountdown(50)`
- 1 callsite. Example: `DLC/Expansion/Scenarios/MedievalScenario/TurnsRemaining.lua:1878`

### SetVictoryValid
- `Game.SetVictoryValid(1,false)`
- `Game.SetVictoryValid(3,false)`
- `Game.SetVictoryValid(4,false)`
- `Game.SetVictoryValid(0,true)`
- `Game.SetVictoryValid(2,false)`
- ...and 10 more distinct call shapes
- 31 callsites. Example: `DLC/Expansion/Scenarios/MedievalScenario/TurnsRemaining.lua:1873`

### SetWinner
- `Game.SetWinner(Players[Game.GetActivePlayer()]:GetTeam(), GameInfo.Victories["VICTORY_DOMINATION"].ID)`
- `Game.SetWinner(Players[Game.GetActivePlayer()]:GetTeam(), GameInfo.Victories["VICTORY_TIME"].ID)`
- `Game.SetWinner(player:GetTeam(), GameInfo.Victories["VICTORY_DOMINATION"].ID)`
- `Game.SetWinner(iLeaderTeam, GameInfo.Victories["VICTORY_TIME"].ID)`
- `Game.SetWinner(iTopScoreTeam , GameInfo.Victories["VICTORY_TIME"].ID)`
- ...and 5 more distinct call shapes
- 15 callsites. Example: `DLC/Expansion/Scenarios/FallOfRomeScenario/TurnsRemaining.lua:44`

### ToggleDebugMode
- `Game.ToggleDebugMode()`
- 3 callsites. Example: `UI/InGame/InGame.lua:84`

### UpdateFOW
- `Game.UpdateFOW(false)`
- 1 callsite. Example: `UI/InGame/DebugMenu.lua:32`
