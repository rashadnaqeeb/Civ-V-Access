# Unit

Methods on Unit handles. Obtain via `pPlayer:GetUnitByID(unitID)` or iteration with `pPlayer:Units()`.

Extracted from 2142 call sites across 177 distinct methods in the shipped game Lua.

## Methods

### AtPlot
- `pHeadSelectedUnit:AtPlot(plot)`
- 3 callsites. Example: `UI/InGame/WorldView/WorldView.lua:706`

### AttackFortifiedModifier
- `pMyUnit:AttackFortifiedModifier()`
- 3 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:971`

### AttackWoundedModifier
- `pMyUnit:AttackWoundedModifier()`
- 3 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:982`

### CanAirlift
- `pHeadSelectedUnit:CanAirlift(thisPlot, false)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/InGame.lua:669`

### CanAirliftAt
- `pHeadSelectedUnit:CanAirliftAt(thisPlot, plotX, plotY)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/InGame.lua:674`

### CanDisembarkOnto
- `unit:CanDisembarkOnto(targetPlot)`
- `pHeadSelectedUnit:CanDisembarkOnto(plot)`
- 6 callsites. Example: `UI/InGame/InGame.lua:458`

### CanDistanceGift
- `pUnit:CanDistanceGift(iToPlayer)`
- `unit:CanDistanceGift(iToPlayer)`
- 6 callsites. Example: `UI/InGame/InGame.lua:202`

### CanEmbarkOnto
- `unit:CanEmbarkOnto(unit:GetPlot(), targetPlot)`
- `pHeadSelectedUnit:CanEmbarkOnto(pHeadSelectedUnit:GetPlot(), plot)`
- 6 callsites. Example: `UI/InGame/InGame.lua:462`

### CanMakeTradeRoute
- `pHeadSelectedUnit:CanMakeTradeRoute(thisPlot, false)`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/InGame.lua:749`

### CanNuke
- `unit:CanNuke()`
- `pHeadSelectedUnit:CanNuke()`
- 6 callsites. Example: `UI/InGame/Bombardment.lua:208`

### CanParadrop
- `pHeadSelectedUnit:CanParadrop(thisPlot, false)`
- 3 callsites. Example: `UI/InGame/InGame.lua:596`

### CanParadropAt
- `pHeadSelectedUnit:CanParadropAt(thisPlot, plotX, plotY)`
- 3 callsites. Example: `UI/InGame/InGame.lua:610`

### CanPromote
- `unit:CanPromote()`
- 5 callsites. Example: `UI/InGame/UnitList.lua:143`

### CanRangeStrike
- `pHeadSelectedUnit:CanRangeStrike()`
- `unit:CanRangeStrike()`
- 5 callsites. Example: `UI/InGame/Bombardment.lua:33`

### CanRangeStrikeAt
- `pHeadSelectedUnit:CanRangeStrikeAt(plotX, plotY, true, true)`
- `pHeadSelectedUnit:CanRangeStrikeAt(plotX, plotY, false, true)`
- `pHeadSelectedUnit:CanRangeStrikeAt(plotX, plotY, true, bNoncombatAllowed)`
- 15 callsites. Example: `UI/InGame/WorldView/WorldView.lua:411`

### CanRebaseAt
- `pHeadSelectedUnit:CanRebaseAt(thisPlot,plotX,plotY)`
- 3 callsites. Example: `UI/InGame/InGame.lua:574`

### CanTrade
- `pUnit:CanTrade(pUnit:GetPlot())`
- 1 callsite. Example: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:368`

### CapitalDefenseFalloff
- `pMyUnit:CapitalDefenseFalloff()`
- `pTheirUnit:CapitalDefenseFalloff()`
- `theirUnit:CapitalDefenseFalloff()`
- 6 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/EnemyUnitPanel.lua:994`

### CapitalDefenseModifier
- `pMyUnit:CapitalDefenseModifier()`
- `pTheirUnit:CapitalDefenseModifier()`
- `theirUnit:CapitalDefenseModifier()`
- 6 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/EnemyUnitPanel.lua:985`

### CargoSpace
- `pUnit:CargoSpace()`
- `unit:CargoSpace()`
- 8 callsites. Example: `UI/InGame/UnitFlagManager.lua:98`

### ChangeDamage
- `unit:ChangeDamage(10,iPlayer)`
- 1 callsite. Example: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:1214`

### ChangeMoves
- `pUnit:ChangeMoves(60)`
- 1 callsite. Example: `DLC/Expansion2/Scenarios/CivilWarScenario/TurnsRemaining.lua:749`

### CityAttackModifier
- `pMyUnit:CityAttackModifier()`
- 3 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:438`

### destroy
- `unit:destroy()`
- 1 callsite. Example: `UI/InGame/UnitMemberOverlay.lua:284`

### DomainModifier
- `pMyUnit:DomainModifier(pTheirUnit:GetDomainType())`
- `pTheirUnit:DomainModifier(pMyUnit:GetDomainType())`
- 6 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:955`

### Embark
- `unit:Embark()`
- 3 callsites. Example: `UI/InGame/WorldView/WorldView.lua:166`

### ExecuteSpecialExploreMove
- `pUnit:ExecuteSpecialExploreMove(pTargetPlot)`
- 3 callsites. Example: `DLC/Expansion2/Scenarios/CivilWarScenario/TurnsRemaining.lua:946`

### ExperienceNeeded
- `unit:ExperienceNeeded()`
- 3 callsites. Example: `UI/InGame/WorldView/UnitPanel.lua:428`

### FeatureAttackModifier
- `pMyUnit:FeatureAttackModifier(pToPlot:GetFeatureType())`
- 3 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:1056`

### FeatureDefenseModifier
- `pTheirUnit:FeatureDefenseModifier(pToPlot:GetFeatureType())`
- `theirUnit:FeatureDefenseModifier(theirPlot:GetFeatureType())`
- 6 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:1357`

### FinishMoves
- `pUnit:FinishMoves()`
- 1 callsite. Example: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:1289`

### FlankAttackModifier
- `pMyUnit:FlankAttackModifier()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/EnemyUnitPanel.lua:919`

### FortifyModifier
- `pTheirUnit:FortifyModifier()`
- `theirUnit:FortifyModifier()`
- 6 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:1182`

### GetActivityType
- `unit:GetActivityType()`
- 5 callsites. Example: `UI/InGame/UnitList.lua:149`

### GetAdjacentModifier
- `pMyUnit:GetAdjacentModifier()`
- `pTheirUnit:GetAdjacentModifier()`
- `theirUnit:GetAdjacentModifier()`
- 11 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:906`

### GetAirStrikeDefenseDamage
- `pTheirUnit:GetAirStrikeDefenseDamage(pMyUnit, false)`
- 3 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:635`

### GetAttackModifier
- `pMyUnit:GetAttackModifier()`
- 3 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:917`

### GetBaseCombatStrength
- `unit:GetBaseCombatStrength()`
- `pUnit:GetBaseCombatStrength()`
- 21 callsites. Example: `UI/InGame/PlotMouseoverInclude.lua:267`

### GetBaseRangedCombatStrength
- `unit:GetBaseRangedCombatStrength()`
- `pUnit:GetBaseRangedCombatStrength()`
- `pMyUnit:GetBaseRangedCombatStrength()`
- 21 callsites. Example: `UI/InGame/Popups/MilitaryOverview.lua:258`

### GetBlastTourism
- `unit:GetBlastTourism()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/WorldView/UnitPanel.lua:1280`

### GetBuildType
- `unit:GetBuildType()`
- 11 callsites. Example: `UI/InGame/UnitList.lua:148`

### GetCaptureChance
- `pMyUnit:GetCaptureChance(pTheirUnit)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/EnemyUnitPanel.lua:1664`

### GetCaptureUnitType
- `pUnit:GetCaptureUnitType(pGiftingPlayer:GetCivilizationType())`
- 1 callsite. Example: `UI/InGame/PopupsGeneric/ReturnCivilianPopup.lua:28`

### GetCivilizationType
- `unit:GetCivilizationType()`
- 3 callsites. Example: `UI/InGame/WorldView/UnitPanel.lua:582`

### GetCombatDamage
- `pMyUnit:GetCombatDamage(iMyStrength, iTheirStrength, pMyUnit:GetDamage() + iTheirFireSupportCombatDamage, false, false, true)`
- `pMyUnit:GetCombatDamage(iTheirStrength, iMyStrength, pCity:GetDamage(), false, true, false)`
- `pMyUnit:GetCombatDamage(iMyStrength, iTheirStrength, pMyUnit:GetDamage() + iTheirFireSupportCombatDamage, false, false, false)`
- `pTheirUnit:GetCombatDamage(iTheirStrength, iMyStrength, pTheirUnit:GetDamage(), false, false, false)`
- 12 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:342`

### GetConversionStrength
- `unit:GetConversionStrength()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/UnitPanel.lua:668`

### GetCurrHitPoints
- `pUnit:GetCurrHitPoints()`
- 4 callsites. Example: `UI/InGame/UnitFlagManager.lua:399`

### GetDamage
- `pMyUnit:GetDamage()`
- `unit:GetDamage()`
- `pTheirUnit:GetDamage()`
- `theirUnit:GetDamage()`
- 41 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:342`

### GetDeclareWarRangeStrike
- `pHeadSelectedUnit:GetDeclareWarRangeStrike(plot)`
- 9 callsites. Example: `UI/InGame/WorldView/WorldView.lua:420`

### GetDefenseModifier
- `pTheirUnit:GetDefenseModifier()`
- `theirUnit:GetDefenseModifier()`
- 6 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:1258`

### GetDiscoverAmount
- `unit:GetDiscoverAmount()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/WorldView/UnitPanel.lua:1214`

### GetDomainType
- `pUnit:GetDomainType()`
- `pMyUnit:GetDomainType()`
- `unit:GetDomainType()`
- `pTheirUnit:GetDomainType()`
- `pPlotUnit:GetDomainType()`
- ...and 2 more distinct call shapes
- 76 callsites. Example: `UI/InGame/UnitFlagManager.lua:85`

### GetDropRange
- `pHeadSelectedUnit:GetDropRange()`
- `unit:GetDropRange()`
- 6 callsites. Example: `UI/InGame/InGame.lua:597`

### GetEmbarkedUnitDefense
- `pTheirUnit:GetEmbarkedUnitDefense()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/EnemyUnitPanel.lua:681`

### GetExoticGoodsGoldAmount
- `unit:GetExoticGoodsGoldAmount()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/WorldView/UnitPanel.lua:1196`

### GetExoticGoodsXPAmount
- `unit:GetExoticGoodsXPAmount()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/WorldView/UnitPanel.lua:1198`

### GetExperience
- `unit:GetExperience()`
- 3 callsites. Example: `UI/InGame/WorldView/UnitPanel.lua:425`

### GetExtraCombatPercent
- `pMyUnit:GetExtraCombatPercent()`
- `pTheirUnit:GetExtraCombatPercent()`
- `theirUnit:GetExtraCombatPercent()`
- 9 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:850`

### GetFireSupportUnit
- `pMyUnit:GetFireSupportUnit(pCity:GetOwner(), pPlot:GetX(), pPlot:GetY())`
- `pMyUnit:GetFireSupportUnit(pTheirUnit:GetOwner(), pToPlot:GetX(), pToPlot:GetY())`
- 6 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:337`

### GetFortifyTurns
- `unit:GetFortifyTurns()`
- `pUnit:GetFortifyTurns()`
- `pTheirUnit:GetFortifyTurns()`
- 11 callsites. Example: `UI/InGame/UnitList.lua:175`

### GetFriendlyLandsAttackModifier
- `pMyUnit:GetFriendlyLandsAttackModifier()`
- 3 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:869`

### GetFriendlyLandsModifier
- `pMyUnit:GetFriendlyLandsModifier()`
- `pTheirUnit:GetFriendlyLandsModifier()`
- `theirUnit:GetFriendlyLandsModifier()`
- 9 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:861`

### GetGameTurnCreated
- `pUnit:GetGameTurnCreated()`
- 1 callsite. Example: `DLC/Expansion2/Scenarios/CivilWarScenario/TurnsRemaining.lua:782`

### GetGarrisonedCity
- `unit:GetGarrisonedCity()`
- 6 callsites. Example: `UI/InGame/CityBannerManager.lua:1159`

### GetGivePoliciesCulture
- `unit:GetGivePoliciesCulture()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/WorldView/UnitPanel.lua:1264`

### GetGoldenAgeTurns
- `unit:GetGoldenAgeTurns()`
- 3 callsites. Example: `UI/InGame/WorldView/UnitPanel.lua:1059`

### GetGreatGeneralCombatModifier
- `pMyUnit:GetGreatGeneralCombatModifier()`
- `pTheirUnit:GetGreatGeneralCombatModifier()`
- `theirUnit:GetGreatGeneralCombatModifier()`
- 16 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/EnemyUnitPanel.lua:542`

### GetGreatWorkSlotType
- `unit:GetGreatWorkSlotType()`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/WorldView/UnitPanel.lua:1173`

### GetHurryProduction
- `unit:GetHurryProduction(unit:GetPlot())`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/WorldView/UnitPanel.lua:1230`

### GetID
- `unit:GetID()`
- `pUnit:GetID()`
- `pSelectedUnit:GetID()`
- `pPlotUnit:GetID()`
- 66 callsites. Example: `UI/InGame/InGame.lua:534`

### GetInterceptorCount
- `pMyUnit:GetInterceptorCount(pPlot, nil, true, true)`
- `pMyUnit:GetInterceptorCount(pToPlot, pTheirUnit, true, true)`
- 6 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:331`

### GetLevel
- `unit:GetLevel()`
- 3 callsites. Example: `UI/InGame/WorldView/UnitPanel.lua:427`

### GetMajorityReligionAfterSpread
- `unit:GetMajorityReligionAfterSpread()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/UnitPanel.lua:1157`

### GetMaxAttackStrength
- `pMyUnit:GetMaxAttackStrength(pFromPlot, pToPlot, nil)`
- `pMyUnit:GetMaxAttackStrength(pFromPlot, pToPlot, pTheirUnit)`
- 6 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:311`

### GetMaxDefenseStrength
- `pTheirUnit:GetMaxDefenseStrength(pToPlot, pMyUnit, true)`
- `pTheirUnit:GetMaxDefenseStrength(pToPlot, pMyUnit)`
- 6 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:631`

### GetMaxHitPoints
- `pUnit:GetMaxHitPoints()`
- 3 callsites. Example: `UI/InGame/UnitFlagManager.lua:399`

### GetMaxRangedCombatStrength
- `pMyUnit:GetMaxRangedCombatStrength(nil, pCity, true, true)`
- `pMyUnit:GetMaxRangedCombatStrength(pTheirUnit, nil, true, true)`
- `pTheirUnit:GetMaxRangedCombatStrength(pMyUnit, nil, false, true)`
- 9 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:306`

### GetName
- `unit:GetName()`
- `pUnit:GetName()`
- `pPlotUnit:GetName()`
- 34 callsites. Example: `UI/InGame/WorldView/UnitPanel.lua:399`

### GetNameKey
- `pUnit:GetNameKey()`
- `unit:GetNameKey()`
- 44 callsites. Example: `UI/InGame/UnitFlagManager.lua:185`

### GetNameNoDesc
- `unit:GetNameNoDesc()`
- `pUnit:GetNameNoDesc()`
- 6 callsites. Example: `UI/InGame/PlotMouseoverInclude.lua:278`

### GetNearbyImprovementModifier
- `pMyUnit:GetNearbyImprovementModifier()`
- `pTheirUnit:GetNearbyImprovementModifier()`
- 18 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:524`

### GetNumEnemyUnitsAdjacent
- `pTheirUnit:GetNumEnemyUnitsAdjacent(pMyUnit)`
- `pMyUnit:GetNumEnemyUnitsAdjacent(pTheirUnit)`
- 6 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:840`

### GetNumFollowersAfterSpread
- `unit:GetNumFollowersAfterSpread()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/UnitPanel.lua:1149`

### GetNumResourceNeededToUpgrade
- `unit:GetNumResourceNeededToUpgrade(iResourceLoop)`
- 3 callsites. Example: `UI/InGame/WorldView/UnitPanel.lua:997`

### GetOriginalOwner
- `unit:GetOriginalOwner()`
- 1 callsite. Example: `DLC/DLC_04/Scenarios/1066Scenario/TurnsRemaining.lua:179`

### GetOutsideFriendlyLandsModifier
- `pMyUnit:GetOutsideFriendlyLandsModifier()`
- `pTheirUnit:GetOutsideFriendlyLandsModifier()`
- `theirUnit:GetOutsideFriendlyLandsModifier()`
- 9 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:881`

### GetOwner
- `unit:GetOwner()`
- `pUnit:GetOwner()`
- `theirUnit:GetOwner()`
- `pPlotUnit:GetOwner()`
- `pMyUnit:GetOwner()`
- ...and 2 more distinct call shapes
- 63 callsites. Example: `UI/InGame/PlotMouseoverInclude.lua:269`

### GetPlot
- `pUnit:GetPlot()`
- `unit:GetPlot()`
- `pMyUnit:GetPlot()`
- `pHeadSelectedUnit:GetPlot()`
- `pTheirUnit:GetPlot()`
- ...and 1 more distinct call shapes
- 99 callsites. Example: `UI/InGame/UnitFlagManager.lua:225`

### GetRangeCombatDamage
- `pMyUnit:GetRangeCombatDamage(nil, pCity, false)`
- `pMyUnit:GetRangeCombatDamage(pTheirUnit, nil, false)`
- 6 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:327`

### GetRangedAttackModifier
- `pMyUnit:GetRangedAttackModifier()`
- 6 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:498`

### GetReligion
- `pUnit:GetReligion()`
- `unit:GetReligion()`
- 6 callsites. Example: `DLC/Expansion2/UI/InGame/UnitFlagManager.lua:595`

### GetReverseGreatGeneralModifier
- `pMyUnit:GetReverseGreatGeneralModifier()`
- `pTheirUnit:GetReverseGreatGeneralModifier()`
- 18 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:516`

### GetScenarioData
- `unit:GetScenarioData()`
- 1 callsite. Example: `DLC/DLC_06/Scenarios/WonderScenario/WonderStatus.lua:426`

### GetScrapGold
- `unit:GetScrapGold()`
- 3 callsites. Example: `UI/InGame/WorldView/UnitPanel.lua:1095`

### GetSpecialUnitType
- `pUnit:GetSpecialUnitType()`
- 2 callsites. Example: `Tutorial/lua/TutorialChecks.lua:63`

### GetSpreadsLeft
- `unit:GetSpreadsLeft()`
- 6 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/UnitPanel.lua:667`

### GetStrategicResourceCombatPenalty
- `pMyUnit:GetStrategicResourceCombatPenalty()`
- `pTheirUnit:GetStrategicResourceCombatPenalty()`
- `theirUnit:GetStrategicResourceCombatPenalty()`
- 12 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:540`

### GetTeam
- `unit:GetTeam()`
- `theirUnit:GetTeam()`
- `pUnit:GetTeam()`
- `pHeadSelectedUnit:GetTeam()`
- `pTheirUnit:GetTeam()`
- 31 callsites. Example: `UI/InGame/InGame.lua:466`

### GetTourismBlastStrength
- `unit:GetTourismBlastStrength()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/UnitPanel.lua:674`

### GetTradeGold
- `unit:GetTradeGold(unit:GetPlot())`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/WorldView/UnitPanel.lua:1248`

### GetTradeInfluence
- `unit:GetTradeInfluence(unit:GetPlot())`
- 1 callsite. Example: `DLC/Expansion2/UI/InGame/WorldView/UnitPanel.lua:1246`

### GetTransportUnit
- `pUnit:GetTransportUnit()`
- `pPlotUnit:GetTransportUnit()`
- 6 callsites. Example: `UI/InGame/UnitFlagManager.lua:121`

### GetType
- `unit:GetType()`
- 1 callsite. Example: `DLC/Expansion2/Scenarios/CivilWarScenario/TurnsRemaining.lua:195`

### GetUnhappinessCombatPenalty
- `pMyUnit:GetUnhappinessCombatPenalty()`
- `pTheirUnit:GetUnhappinessCombatPenalty()`
- `theirUnit:GetUnhappinessCombatPenalty()`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/EnemyUnitPanel.lua:566`

### GetUnitAIType
- `pUnit:GetUnitAIType()`
- 7 callsites. Example: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:1288`

### GetUnitClassModifier
- `pMyUnit:GetUnitClassModifier(pTheirUnit:GetUnitClassType())`
- 3 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:925`

### GetUnitClassType
- `pTheirUnit:GetUnitClassType()`
- `pMyUnit:GetUnitClassType()`
- 18 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:925`

### GetUnitCombatType
- `pTheirUnit:GetUnitCombatType()`
- `pMyUnit:GetUnitCombatType()`
- `unit:GetUnitCombatType()`
- 25 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:943`

### GetUnitType
- `unit:GetUnitType()`
- `pUnit:GetUnitType()`
- `pMyUnit:GetUnitType()`
- `pTheirUnit:GetUnitType()`
- `theirUnit:GetUnitType()`
- 53 callsites. Example: `UI/InGame/InGame.lua:1006`

### GetUpgradeUnitFromPlot
- `unit:GetUpgradeUnitFromPlot(adjacentPlot)`
- 3 callsites. Example: `UI/InGame/InGame.lua:504`

### GetUpgradeUnitType
- `unit:GetUpgradeUnitType()`
- 3 callsites. Example: `UI/InGame/WorldView/UnitPanel.lua:938`

### GetX
- `unit:GetX()`
- `pUnit:GetX()`
- `pHeadSelectedUnit:GetX()`
- `pMyUnit:GetX()`
- `pTheirUnit:GetX()`
- ...and 1 more distinct call shapes
- 54 callsites. Example: `UI/InGame/InGame.lua:439`

### GetY
- `unit:GetY()`
- `pUnit:GetY()`
- `pHeadSelectedUnit:GetY()`
- `pMyUnit:GetY()`
- `pTheirUnit:GetY()`
- ...and 1 more distinct call shapes
- 56 callsites. Example: `UI/InGame/InGame.lua:439`

### HasCargo
- `pUnit:HasCargo()`
- 3 callsites. Example: `UI/InGame/UnitFlagManager.lua:709`

### HasName
- `pUnit:HasName()`
- `unit:HasName()`
- 9 callsites. Example: `UI/InGame/UnitFlagManager.lua:184`

### HillsAttackModifier
- `pMyUnit:HillsAttackModifier()`
- 3 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:993`

### HillsDefenseModifier
- `pTheirUnit:HillsDefenseModifier()`
- `theirUnit:HillsDefenseModifier()`
- 6 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:1323`

### IsActionRecommended
- `unit:IsActionRecommended(iAction)`
- 3 callsites. Example: `UI/InGame/WorldView/UnitPanel.lua:241`

### IsAmphib
- `pMyUnit:IsAmphib()`
- 6 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:485`

### IsAutomated
- `unit:IsAutomated()`
- `pUnit:IsAutomated()`
- `pSelectedUnit:IsAutomated()`
- 10 callsites. Example: `UI/InGame/UnitList.lua:158`

### IsBarbarian
- `pTheirUnit:IsBarbarian()`
- `theirUnit:IsBarbarian()`
- 6 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:1086`

### IsCanAttack
- `pHeadSelectedUnit:IsCanAttack()`
- 1 callsite. Example: `UI/InGame/WorldView/WorldView.lua:692`

### IsCargo
- `pUnit:IsCargo()`
- `pPlotUnit:IsCargo()`
- 9 callsites. Example: `UI/InGame/UnitFlagManager.lua:120`

### IsCombatUnit
- `pUnit:IsCombatUnit()`
- `unit:IsCombatUnit()`
- `pTheirUnit:IsCombatUnit()`
- `theirUnit:IsCombatUnit()`
- 22 callsites. Example: `UI/InGame/UnitFlagManager.lua:82`

### IsDead
- `unit:IsDead()`
- 10 callsites. Example: `UI/InGame/UnitMemberOverlay.lua:253`

### IsDelayedDeath
- `unit:IsDelayedDeath()`
- `pUnit:IsDelayedDeath()`
- `pSelectedUnit:IsDelayedDeath()`
- 11 callsites. Example: `DLC/Expansion2/Scenarios/CivilWarScenario/TurnsRemaining.lua:861`

### IsEmbarked
- `unit:IsEmbarked()`
- `pUnit:IsEmbarked()`
- `pTheirUnit:IsEmbarked()`
- 27 callsites. Example: `UI/InGame/InGame.lua:456`

### IsEverFortifyable
- `unit:IsEverFortifyable()`
- 3 callsites. Example: `UI/InGame/WorldView/UnitPanel.lua:1039`

### IsFound
- `pUnit:IsFound()`
- 1 callsite. Example: `DLC/Expansion/Scenarios/MedievalScenario/TurnsRemaining.lua:1085`

### IsFriendlyUnitAdjacent
- `pMyUnit:IsFriendlyUnitAdjacent(bCombatUnit)`
- `pTheirUnit:IsFriendlyUnitAdjacent(bCombatUnit)`
- `theirUnit:IsFriendlyUnitAdjacent(bCombatUnit)`
- 11 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:909`

### IsGarrisoned
- `pUnit:IsGarrisoned()`
- `unit:IsGarrisoned()`
- 22 callsites. Example: `UI/InGame/UnitFlagManager.lua:174`

### IsGreatPerson
- `unit:IsGreatPerson()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/UnitPanel.lua:422`

### IsHasPromotion
- `pUnit:IsHasPromotion(unitPromotionID)`
- `unit:IsHasPromotion(unitPromotionID)`
- `pUnit:IsHasPromotion(GameInfoTypes["PROMOTION_BUFFALO_HORNS"])`
- `pUnit:IsHasPromotion(GameInfoTypes["PROMOTION_BUFFALO_LOINS"])`
- `pUnit:IsHasPromotion(GameInfoTypes["PROMOTION_BUFFALO_CHEST"])`
- 9 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:142`

### IsHigherTechThan
- `pTheirUnit:IsHigherTechThan(pMyUnit:GetUnitType())`
- `pMyUnit:IsHigherTechThan(pTheirUnit:GetUnitType())`
- `pMyUnit:IsHigherTechThan(theirUnit:GetUnitType())`
- 5 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/EnemyUnitPanel.lua:969`

### IsIgnoreGreatGeneralBenefit
- `pMyUnit:IsIgnoreGreatGeneralBenefit()`
- `pTheirUnit:IsIgnoreGreatGeneralBenefit()`
- `theirUnit:IsIgnoreGreatGeneralBenefit()`
- 8 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/EnemyUnitPanel.lua:534`

### IsImmobile
- `pUnit:IsImmobile()`
- 3 callsites. Example: `UI/InGame/UnitFlagManager.lua:595`

### IsInvisible
- `pUnit:IsInvisible(iTeam, false)`
- `unit:IsInvisible(iActiveTeam, bIsDebug)`
- `theirUnit:IsInvisible(myTeamID, false)`
- 12 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:1882`

### IsLargerCivThan
- `pTheirUnit:IsLargerCivThan(pMyUnit)`
- `pMyUnit:IsLargerCivThan(pTheirUnit)`
- `pMyUnit:IsLargerCivThan(theirUnit)`
- 5 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/EnemyUnitPanel.lua:978`

### IsNearGreatGeneral
- `pMyUnit:IsNearGreatGeneral()`
- `pTheirUnit:IsNearGreatGeneral()`
- `theirUnit:IsNearGreatGeneral()`
- 12 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:507`

### IsNearSapper
- `pMyUnit:IsNearSapper(pCity)`
- `theirUnit:IsNearSapper(myCity)`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/EnemyUnitPanel.lua:461`

### IsRangeAttackIgnoreLOS
- `pHeadSelectedUnit:IsRangeAttackIgnoreLOS()`
- 1 callsite. Example: `UI/InGame/Bombardment.lua:35`

### IsRangeAttackOnlyInDomain
- `pHeadSelectedUnit:IsRangeAttackOnlyInDomain()`
- 1 callsite. Example: `UI/InGame/Bombardment.lua:41`

### IsRangedSupportFire
- `pMyUnit:IsRangedSupportFire()`
- `pTheirUnit:IsRangedSupportFire()`
- 2 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/EnemyUnitPanel.lua:305`

### IsReadyToMove
- `pUnit:IsReadyToMove()`
- `pSelectedUnit:IsReadyToMove()`
- 5 callsites. Example: `UI/InGame/WorldView/ActionInfoPanel.lua:444`

### IsRiverCrossingNoPenalty
- `pMyUnit:IsRiverCrossingNoPenalty()`
- 6 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:471`

### IsStackedGreatGeneral
- `pMyUnit:IsStackedGreatGeneral()`
- `pTheirUnit:IsStackedGreatGeneral()`
- `theirUnit:IsStackedGreatGeneral()`
- 8 callsites. Example: `DLC/Expansion2/UI/InGame/WorldView/EnemyUnitPanel.lua:542`

### IsTrade
- `unit:IsTrade()`
- `pUnit:IsTrade()`
- 4 callsites. Example: `DLC/Expansion2/UI/InGame/UnitList.lua:162`

### IsWork
- `unit:IsWork()`
- 5 callsites. Example: `UI/InGame/UnitList.lua:159`

### JumpToNearestValidPlot
- `unit:JumpToNearestValidPlot()`
- `pUnit:JumpToNearestValidPlot()`
- 371 callsites. Example: `DLC/Expansion2/Scenarios/CivilWarScenario/TurnsRemaining.lua:338`

### Kill
- `unit:Kill(true, -1)`
- `pUnit:Kill()`
- `unit:Kill()`
- 19 callsites. Example: `UI/InGame/WorldView/WorldView.lua:178`

### MaxMoves
- `unit:MaxMoves()`
- `pUnit:MaxMoves()`
- 11 callsites. Example: `UI/InGame/UnitList.lua:217`

### MovesLeft
- `unit:MovesLeft()`
- `pPlotUnit:MovesLeft()`
- `pUnit:MovesLeft()`
- 25 callsites. Example: `UI/InGame/UnitList.lua:135`

### NoDefensiveBonus
- `pTheirUnit:NoDefensiveBonus()`
- `theirUnit:NoDefensiveBonus()`
- 6 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:1171`

### OpenAttackModifier
- `pMyUnit:OpenAttackModifier()`
- 3 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:1005`

### OpenDefenseModifier
- `pTheirUnit:OpenDefenseModifier()`
- `theirUnit:OpenDefenseModifier()`
- 6 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:1334`

### OpenRangedAttackModifier
- `pMyUnit:OpenRangedAttackModifier()`
- 3 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:1014`

### Range
- `pHeadSelectedUnit:Range()`
- `unit:Range()`
- 9 callsites. Example: `UI/InGame/Bombardment.lua:34`

### RoughAttackModifier
- `pMyUnit:RoughAttackModifier()`
- 3 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:1035`

### RoughDefenseModifier
- `pTheirUnit:RoughDefenseModifier()`
- `theirUnit:RoughDefenseModifier()`
- 6 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:1345`

### RoughRangedAttackModifier
- `pMyUnit:RoughRangedAttackModifier()`
- 3 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:1044`

### SetDeployFromOperationTurn
- `unit:SetDeployFromOperationTurn(1)`
- 152 callsites. Example: `DLC/Expansion/Scenarios/FallOfRomeScenario/TurnsRemaining.lua:1641`

### SetEmbarked
- `unit:SetEmbarked(true)`
- 51 callsites. Example: `DLC/Expansion/Scenarios/FallOfRomeScenario/TurnsRemaining.lua:1696`

### SetHasPromotion
- `pUnit:SetHasPromotion(iPromotionID, true)`
- `unit:SetHasPromotion(iPromotionID, true)`
- `pUnit:SetHasPromotion(iPromotionID1, true)`
- `pUnit:SetHasPromotion(iPromotionID2, true)`
- `unit:SetHasPromotion(GameInfoTypes["PROMOTION_SMALLPOX5"], true)`
- ...and 4 more distinct call shapes
- 13 callsites. Example: `DLC/Expansion2/Scenarios/ScrambleAfricaScenario/TurnsRemaining.lua:937`

### SetMessage1
- `unit:SetMessage1(memberID)`
- 1 callsite. Example: `UI/InGame/UnitMemberOverlay.lua:257`

### SetName
- `pUnit:SetName(strName)`
- 1 callsite. Example: `DLC/Expansion2/Scenarios/CivilWarScenario/TurnsRemaining.lua:462`

### SetPosition
- `unit:SetPosition(position)`
- 1 callsite. Example: `UI/InGame/UnitMemberOverlay.lua:258`

### SetUnitAIType
- `unit:SetUnitAIType(GameInfo.UnitAIInfos["UNITAI_ARCHAEOLOGIST"].ID)`
- 2 callsites. Example: `DLC/Expansion2/Scenarios/ScrambleAfricaScenario/TurnsRemaining.lua:694`

### ShowHide
- `unit:ShowHide(true)`
- `unit:ShowHide(bShow)`
- 2 callsites. Example: `UI/InGame/UnitMemberOverlay.lua:256`

### TerrainAttackModifier
- `pMyUnit:TerrainAttackModifier(pToPlot:GetTerrainType())`
- `pMyUnit:TerrainAttackModifier(GameInfo.Terrains["TERRAIN_HILL"].ID)`
- 6 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:1066`

### TerrainDefenseModifier
- `pTheirUnit:TerrainDefenseModifier(pToPlot:GetTerrainType())`
- `pTheirUnit:TerrainDefenseModifier(GameInfo.Terrains["TERRAIN_HILL"].ID)`
- `theirUnit:TerrainDefenseModifier(theirPlot:GetTerrainType())`
- `theirUnit:TerrainDefenseModifier(GameInfo.Terrains["TERRAIN_HILL"].ID)`
- 12 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:1367`

### UnitClassAttackModifier
- `pMyUnit:UnitClassAttackModifier(pTheirUnit:GetUnitClassType())`
- 3 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:934`

### UnitClassDefenseModifier
- `pTheirUnit:UnitClassDefenseModifier(pMyUnit:GetUnitClassType())`
- 3 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:1266`

### UnitCombatModifier
- `pMyUnit:UnitCombatModifier(pTheirUnit:GetUnitCombatType())`
- `pTheirUnit:UnitCombatModifier(pMyUnit:GetUnitCombatType())`
- 6 callsites. Example: `UI/InGame/WorldView/EnemyUnitPanel.lua:944`

### UpdateFlagOffset
- `unit:UpdateFlagOffset()`
- 3 callsites. Example: `UI/InGame/UnitFlagManager.lua:985`

### UpdateFlagType
- `unit:UpdateFlagType()`
- 3 callsites. Example: `UI/InGame/UnitFlagManager.lua:984`

### UpgradePrice
- `unit:UpgradePrice(iUnitType)`
- 3 callsites. Example: `UI/InGame/WorldView/UnitPanel.lua:939`

### WorkRate
- `unit:WorkRate(true, iBuildID)`
- `pUnit:WorkRate()`
- 5 callsites. Example: `UI/InGame/WorldView/UnitPanel.lua:1230`
