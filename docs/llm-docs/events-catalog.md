# Civ V Events.X Catalog

Engine-originated events fired by the native game code. Handlers are Lua functions subscribed via `Events.X.Add(fn)`. These are multicast (`.Add` chains) and carry engine-level state transitions: turn lifecycle, plot changes, unit and city events, diplomacy, UI notifications.

Total events cataloged: 227

Source: Sid Meier's Civilization V UI and DLC Lua (`Assets/UI/`, `Assets/DLC/`).

Notes on inference: argument names come from handler parameter lists where available, otherwise from caller expressions. Types are best-effort inference from variable names. Where no handler is named and the call site is missing, the event is listed with `args: unknown`.

## Reading the entries

Each entry below is tagged with a `direction` indicating which way the event flows:

- **observable** — engine fires the event; Lua only subscribes via `.Add(fn)`. These are what we hook for accessibility output. Detected when `adds >= 1, calls == 0`.
- **fire-only** — Lua fires the event into the engine; subscribing is not useful for observation. Detected when `adds == 0, calls >= 1`.
- **mixed** — both subscribed and fired from Lua (Lua-relay pattern). Detected when `adds >= 1, calls >= 1`.

---

## Special: `SerialEventGameMessagePopup` ButtonPopupTypes

`SerialEventGameMessagePopup` is a central popup dispatcher. Its first argument is a table `popupInfo` whose `Type` field is a value from the `ButtonPopupTypes` enum. The 69 known dispatch types (from `UI/InGame/PopupManager.lua` and related) include: BUTTONPOPUP_TEXT, BUTTONPOPUP_CONFIRM_COMMAND, BUTTONPOPUP_CONFIRM_MENU, BUTTONPOPUP_DECLAREWARMOVE, BUTTONPOPUP_LOADUNIT, BUTTONPOPUP_LEADUNIT, BUTTONPOPUP_BUYTILE, BUTTONPOPUP_CHOOSEPRODUCTION, BUTTONPOPUP_CHOOSE_CITY_PLOT, BUTTONPOPUP_CHOOSE_DISBAND_UNIT, BUTTONPOPUP_ALARM, BUTTONPOPUP_DEAL_CANCELED, BUTTONPOPUP_RELIGION_ESTABLISHED, BUTTONPOPUP_REPUBLIC_GOVERNMENT, BUTTONPOPUP_FOUND_RELIGION, BUTTONPOPUP_ENHANCE_RELIGION, BUTTONPOPUP_REFORMATION_BELIEF, BUTTONPOPUP_DIPLOMATIC_VOTE_RESULT, BUTTONPOPUP_DIPLOMATIC_VOTE, BUTTONPOPUP_DIPLO_VOTE_CHOICE, BUTTONPOPUP_DIPLO_VOTE_RESULTS, BUTTONPOPUP_CONFIRM_POLICY, BUTTONPOPUP_CONFIRM_IDEOLOGY_CHOICE, BUTTONPOPUP_MAIN_MENU, BUTTONPOPUP_MAIN_MENU_OPTIONS, BUTTONPOPUP_DIPLOMACY, BUTTONPOPUP_NEW_ERA, BUTTONPOPUP_NOTIFICATION_LOG, BUTTONPOPUP_CIVILOPEDIA, BUTTONPOPUP_PEDIA_SEARCH, BUTTONPOPUP_GOSSIP, BUTTONPOPUP_TRADE_REPUDIATED, BUTTONPOPUP_CITY_CAPTURED, BUTTONPOPUP_CITY_PRODUCTION_FINISHED, BUTTONPOPUP_BARBARIAN_RANSOM, BUTTONPOPUP_GREAT_PEOPLE_CHOICE, BUTTONPOPUP_UNIT_UPGRADE, BUTTONPOPUP_MINOR_CIV_QUEST, BUTTONPOPUP_MINOR_CIV_INVESTMENT, BUTTONPOPUP_MINOR_CIV_GIFT_TILE, BUTTONPOPUP_MINOR_CIV_DIPLOMACY, BUTTONPOPUP_CITY_NAME_CHANGE, BUTTONPOPUP_LEAGUE_SPLASH, BUTTONPOPUP_LEAGUE_OVERVIEW, BUTTONPOPUP_LEAGUE_PROPOSE, BUTTONPOPUP_LEAGUE_VOTE_ENACT, BUTTONPOPUP_LEAGUE_VOTE_REPEAL, BUTTONPOPUP_CSD_DIPLO_DEAL, BUTTONPOPUP_GREAT_WORK_COMPLETED_ACTIVE_PLAYER, BUTTONPOPUP_ARCHAEOLOGY_CHOICE, BUTTONPOPUP_WAR_STATE_CHANGE, BUTTONPOPUP_DIPLO_OPINION_CHANGE, BUTTONPOPUP_CULTURE_CHOOSE_WONDER, BUTTONPOPUP_TECH_AWARD, BUTTONPOPUP_TECH_TREE, BUTTONPOPUP_POLICY_TREE, BUTTONPOPUP_GREAT_WORK, BUTTONPOPUP_GREAT_PERSON_REWARD, BUTTONPOPUP_MAP, BUTTONPOPUP_WHOSWINNING, BUTTONPOPUP_EXTENDED_GAME, BUTTONPOPUP_PLAYER_DEALT_WITH, BUTTONPOPUP_RESISTANCE_ENDED, BUTTONPOPUP_ESPIONAGE_SPY_CHOICE, BUTTONPOPUP_COUP_RESULT, BUTTONPOPUP_RIG_ELECTION_RESULT, BUTTONPOPUP_YOU_ARE_UNDER_ATTACK, BUTTONPOPUP_ENDGAME, BUTTONPOPUP_ADVANCED_START, BUTTONPOPUP_CIV5_DEFEATED, BUTTONPOPUP_CONFIRM_END_TURN.

For accessibility purposes, each of the 69 subtypes is its own "virtual event" - they share the engine dispatch slot but correspond to distinct UI screens. Treat `popupInfo.Type` as the event discriminator when subscribing for speech output.

---

## AILeaderMessage

- direction: **observable** (engine fires; Lua subscribes)
- args: `iPlayer, iDiploUIState, szLeaderMessage, iAnimationAction, iData1`
- example registration: `UI/InGame/LeaderHead/DiploTrade.lua:5` handler `LeaderMessageHandler`
- handler body: `UI/InGame/LeaderHead/DiscussionDialog.lua:37`
- adds: 8, calls: 0

## AIProcessingEndedForPlayer

- direction: **observable** (engine fires; Lua subscribes)
- args: `iPlayerID, szTag`
- example registration: `UI/FrontEnd/Multiplayer/StagingRoom.lua:879` handler `UpdateTurnStatusForPlayerID`
- handler body: `UI/FrontEnd/Multiplayer/StagingRoom.lua:856`
- adds: 2, calls: 0

## AIProcessingStartedForPlayer

- direction: **observable** (engine fires; Lua subscribes)
- args: `iPlayerID, szTag`
- example registration: `UI/FrontEnd/Multiplayer/StagingRoom.lua:878` handler `UpdateTurnStatusForPlayerID`
- handler body: `UI/FrontEnd/Multiplayer/StagingRoom.lua:856`
- adds: 3, calls: 0

## ActivePlayerTurnEnd

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/InGame/InGame.lua:739` handler `OnActivePlayerTurnEnd`
- handler body: `UI/InGame/InGame.lua:736`
- adds: 10, calls: 0

## ActivePlayerTurnStart

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/InGame/CityBannerManager.lua:1277` handler `OnActivePlayerTurnStart`
- handler body: `UI/InGame/CityBannerManager.lua:1252`
- adds: 15, calls: 0

## AddPopupTextEvent

- direction: **observable** (engine fires; Lua subscribes)
- args: `worldPosition, text, delay`
- example registration: `UI/InGame/InGame.lua:941` handler `AddPopupText`
- handler body: `UI/InGame/InGame.lua:929`
- adds: 3, calls: 0

## AddUnitMoveHexRangeHex

- direction: **observable** (engine fires; Lua subscribes)
- args: `i, j, k, attackMove, unitID`
- example registration: `UI/InGame/WorldView/WorldView.lua:835` handler `OnAddUnitMoveHexRangeHex`
- handler body: `UI/InGame/WorldView/WorldView.lua:828`
- adds: 3, calls: 0

## AdvisorDisplayHide

- direction: **mixed** (both subscribed and fired by Lua)
- args: `(no args)`
- example registration: `UI/InGame/WorldView/Advisors.lua:280` handler `OnClearAdvice`
- handler body: `UI/InGame/WorldView/Advisors.lua:276`
- example callsite: `UI/InGame/WorldView/Advisors.lua:162` `()`
- adds: 1, calls: 1

## AdvisorDisplayShow

- direction: **observable** (engine fires; Lua subscribes)
- args: `eventInfo`
- example registration: `UI/InGame/WorldView/Advisors.lua:274` handler `OnAdvisorDisplayShow`
- handler body: `UI/InGame/WorldView/Advisors.lua:200`
- adds: 1, calls: 0

## AfterModsActivate

- direction: **observable** (engine fires; Lua subscribes)
- args: unknown
- example registration: `UI/IconSupport.lua:307` handler `function(`
- adds: 3, calls: 0

## AfterModsDeactivate

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/IconSupport.lua:303` handler `function(`
- handler body: `UI/FrontEnd/Multiplayer/StagingRoom.lua:1932`
- adds: 4, calls: 0

## AudioDebugChangeMusic

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `true,false,false`
- example callsite: `UI/InGame/DebugMenu.lua:133` `(true,false,false)`
- adds: 0, calls: 3

## AudioPlay2DSound

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `"AS2D_INTERFACE_CITY_SCREEN_PURCHASE"`
- example callsite: `UI/FrontEnd/Multiplayer/StagingRoom.lua:1815` `("AS2D_IF_MP_CHAT_DING")`
- adds: 0, calls: 36

## BuildFinished

- direction: **observable** (engine fires; Lua subscribes)
- args: unknown
- example registration: `DLC/Expansion2/Scenarios/ScrambleAfricaScenario/TurnsRemaining.lua:143` handler `function(iPlayer, x, y, eImprovement`
- adds: 1, calls: 0

## BuildingLibrarySwap

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `g_iAssetCulture, g_iAssetEra`
- example callsite: `UI/InGame/DebugMode.lua:394` `(g_iAssetCulture, g_iAssetEra)`
- adds: 0, calls: 1

## CameraStartPitchingDown

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `(no args)`
- example callsite: `UI/InGame/DebugMenu.lua:377` `()`
- adds: 0, calls: 1

## CameraStartPitchingUp

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `(no args)`
- example callsite: `UI/InGame/DebugMenu.lua:373` `()`
- adds: 0, calls: 1

## CameraStartRotatingCCW

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `(no args)`
- example callsite: `UI/InGame/DebugMenu.lua:365` `()`
- adds: 0, calls: 1

## CameraStartRotatingCW

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `(no args)`
- example callsite: `UI/InGame/DebugMenu.lua:369` `()`
- adds: 0, calls: 1

## CameraStopPitchingDown

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `(no args)`
- example callsite: `UI/InGame/DebugMenu.lua:338` `()`
- adds: 0, calls: 1

## CameraStopPitchingUp

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `(no args)`
- example callsite: `UI/InGame/DebugMenu.lua:334` `()`
- adds: 0, calls: 1

## CameraStopRotatingCCW

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `(no args)`
- example callsite: `UI/InGame/DebugMenu.lua:326` `()`
- adds: 0, calls: 1

## CameraStopRotatingCW

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `(no args)`
- example callsite: `UI/InGame/DebugMenu.lua:330` `()`
- adds: 0, calls: 1

## CameraViewChanged

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/InGame/PlotHelpManager.lua:348` handler `OnCameraViewChanged`
- handler body: `UI/InGame/PlotHelpManager.lua:340`
- adds: 3, calls: 0

## CanDeclareWar

- direction: **observable** (engine fires; Lua subscribes)
- args: unknown
- example registration: `DLC/DLC_02/Scenarios/NewWorldScenario/TurnsRemaining.lua:274` handler `function(myTeam, theirTeam`
- adds: 3, calls: 0

## CanDisplaceCivilian

- direction: **observable** (engine fires; Lua subscribes)
- args: `iPlayer, iUnitID`
- example registration: `DLC/Expansion2/Scenarios/CivilWarScenario/TurnsRemaining.lua:262` handler `OnCivilianCaptured`
- handler body: `DLC/Expansion2/Scenarios/CivilWarScenario/TurnsRemaining.lua:245`
- adds: 1, calls: 0

## CanPillage

- direction: **observable** (engine fires; Lua subscribes)
- args: unknown
- example registration: `DLC/Expansion2/Scenarios/CivilWarScenario/TurnsRemaining.lua:187` handler `function(iPlayer, iUnitID, iMission`
- adds: 1, calls: 0

## CanRaze

- direction: **observable** (engine fires; Lua subscribes)
- args: `iPlayer, iCityID`
- example registration: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:2210` handler `CanRazeOverride`
- handler body: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:2187`
- adds: 1, calls: 0

## CanRazeOverride

- direction: **observable** (engine fires; Lua subscribes)
- args: `iPlayer, iCityID`
- example registration: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:2209` handler `CanRazeOverride`
- handler body: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:2187`
- adds: 1, calls: 0

## CanSaveUnit

- direction: **observable** (engine fires; Lua subscribes)
- args: `iPlayer, iUnitID`
- example registration: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:378` handler `OnUnitKilled`
- handler body: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:360`
- adds: 2, calls: 0

## CityBuildingsIsBuildingSellable

- direction: **observable** (engine fires; Lua subscribes)
- args: `iPlayerID, iBuildingID`
- example registration: `DLC/Expansion/Scenarios/FallOfRomeScenario/TurnsRemaining.lua:484` handler `IsBuildingSellable`
- handler body: `DLC/Expansion/Scenarios/FallOfRomeScenario/TurnsRemaining.lua:477`
- adds: 1, calls: 0

## CityCanConstruct

- direction: **observable** (engine fires; Lua subscribes)
- args: unknown
- example registration: `DLC/DLC_04/Scenarios/1066Scenario/TurnsRemaining.lua:116` handler `function(iPlayer, iCity, iBuildingType`
- adds: 3, calls: 0

## CityCanTrain

- direction: **observable** (engine fires; Lua subscribes)
- args: unknown
- example registration: `DLC/Expansion2/Scenarios/CivilWarScenario/TurnsRemaining.lua:167` handler `function(iPlayer, iUnitID, iUnitType`
- adds: 1, calls: 0

## CityCaptureComplete

- direction: **observable** (engine fires; Lua subscribes)
- args: `hexPos, playerID, cityID, newPlayerID`
- example registration: `DLC/DLC_02/Scenarios/NewWorldScenario/TurnsRemaining.lua:520` handler `OnCityCaptured`
- handler body: `DLC/DLC_01/Scenarios/Mongol Scenario/CivsAlive.lua:63`
- adds: 8, calls: 0

## CityConvertsReligion

- direction: **observable** (engine fires; Lua subscribes)
- args: unknown
- example registration: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:2072` handler `function(iOwner, eReligion, iX, iY`
- adds: 2, calls: 0

## CityStrategyCanActivate

- direction: **observable** (engine fires; Lua subscribes)
- args: unknown
- example registration: `DLC/Expansion2/Scenarios/CivilWarScenario/TurnsRemaining.lua:116` handler `function(iStrategyID, iPlayer, iCityID`
- adds: 2, calls: 0

## ClearDiplomacyTradeTable

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/InGame/WorldView/TradeLogic.lua:724` handler `DoClearDeal`
- handler body: `UI/InGame/WorldView/TradeLogic.lua:717`
- adds: 3, calls: 0

## ClearHexHighlightStyle

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `"ValidFireTargetBorder"`
- example callsite: `UI/InGame/InGame.lua:518` `(pathBorderStyle)`
- adds: 0, calls: 44

## ClearHexHighlights

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `(no args)`
- example callsite: `UI/InGame/InGame.lua:514` `()`
- adds: 0, calls: 9

## ClearUnitMoveHexRange

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/InGame/WorldView/WorldView.lua:820` handler `OnClearUnitMoveHexRange`
- handler body: `UI/InGame/WorldView/WorldView.lua:816`
- adds: 3, calls: 0

## ConnectedToNetworkHost

- direction: **observable** (engine fires; Lua subscribes)
- args: `playerID`
- example registration: `UI/FrontEnd/Multiplayer/JoiningRoom.lua:187` handler `OnHostConnect`
- handler body: `UI/FrontEnd/Multiplayer/JoiningRoom.lua:113`
- adds: 2, calls: 0

## DisplayMovementIndicator

- direction: **mixed** (both subscribed and fired by Lua)
- args: `popupInfo`
- example registration: `UI/InGame/WorldView/PathHelpManager.lua:56` handler `OnDisplay`
- handler body: `UI/InGame/TechPopup.lua:53`
- example callsite: `UI/InGame/InGame.lua:536` `(true)`
- adds: 1, calls: 12

## DoResolveVictoryVote

- direction: **observable** (engine fires; Lua subscribes)
- args: unknown
- example registration: `DLC/Expansion/Scenarios/MedievalScenario/TurnsRemaining.lua:392` handler `function(bPreliminaryVote`
- adds: 1, calls: 0

## EconomicStrategyCanActivate

- direction: **observable** (engine fires; Lua subscribes)
- args: unknown
- example registration: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:380` handler `function(iStrategyID, iPlayer`
- adds: 3, calls: 0

## EndCombatSim

- direction: **observable** (engine fires; Lua subscribes)
- args: `iAttackingPlayer, iAttackingUnit, iAttackingUnitDamage, iAttackingUnitFinalDamage, iAttackingUnitMaxHitPoints, iDefendingPlayer, iDefendingUnit, iDefendingUnitDamage, iDefendingUnitFinalDamage, iDefendingUnitMaxHitPoints`
- example registration: `UI/InGame/UnitFlagManager.lua:1606` handler `OnCombatEnd`
- handler body: `DLC/Expansion/Tutorial/lua/TutorialChecks.lua:3145`
- adds: 6, calls: 0

## EndGameShow

- direction: **mixed** (both subscribed and fired by Lua)
- args: `popupInfo`
- example registration: `UI/InGame/Popups/EndGameMenu.lua:249` handler `OnDisplay`
- handler body: `UI/InGame/TechPopup.lua:53`
- example callsite: `UI/InGame/WorldView/DiploCorner.lua:406` `(EndGameTypes.Technology, Game.GetActivePlayer()`
- adds: 1, calls: 24

## EndTurnBlockingChanged

- direction: **observable** (engine fires; Lua subscribes)
- args: `ePrevEndTurnBlockingType, eNewEndTurnBlockingType`
- example registration: `UI/InGame/WorldView/ActionInfoPanel.lua:455` handler `OnEndTurnBlockingChanged`
- handler body: `UI/InGame/WorldView/ActionInfoPanel.lua:432`
- adds: 3, calls: 0

## EndTurnTimerUpdate

- direction: **observable** (engine fires; Lua subscribes)
- args: `percentComplete`
- example registration: `UI/InGame/WorldView/MPTurnPanel.lua:325` handler `OnEndTurnTimerUpdate`
- handler body: `UI/InGame/WorldView/MPTurnPanel.lua:265`
- adds: 1, calls: 0

## EventOpenOptionsScreen

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/Options/OptionsMenu.lua:294` handler `OnOptionsEvent`
- handler body: `UI/Options/OptionsMenu.lua:284`
- adds: 1, calls: 0

## EventPoliciesDirty

- direction: **mixed** (both subscribed and fired by Lua)
- args: `(no args)`
- example registration: `UI/InGame/Popups/SocialPolicyPopup.lua:544` handler `UpdateDisplay`
- handler body: `UI/FrontEnd/GameSetup/GameSetupScreen.lua:193`
- example callsite: `UI/InGame/Popups/SocialPolicyPopup.lua:566` `()`
- adds: 7, calls: 5

## Event_ToggleTradeRouteDisplay

- direction: **mixed** (both subscribed and fired by Lua)
- args: `bIsChecked`
- example registration: `DLC/Expansion2/UI/InGame/WorldView/MiniMapPanel.lua:379` handler `OnShowTradeToggled`
- handler body: `DLC/Expansion2/UI/InGame/WorldView/MiniMapPanel.lua:373`
- example callsite: `DLC/Expansion2/UI/InGame/Popups/ChooseInternationalTradeRoutePopup.lua:62` `(true)`
- adds: 1, calls: 4

## ExitToMainMenu

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `(no args)`
- example callsite: `UI/InGame/PlayerChange.lua:55` `()`
- adds: 0, calls: 7

## FrontEndPopup

- direction: **observable** (engine fires; Lua subscribes)
- args: `string`
- example registration: `UI/FrontEnd/FrontEndPopup.lua:10` handler `OnFrontEndPopup`
- handler body: `UI/FrontEnd/FrontEndPopup.lua:5`
- adds: 1, calls: 0

## GameCoreTestVictory

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `DLC/DLC_01/Scenarios/Mongol Scenario/CivsAlive.lua:57` handler `TestVictory`
- handler body: `DLC/DLC_01/Scenarios/Mongol Scenario/CivsAlive.lua:46`
- adds: 9, calls: 0

## GameCoreUpdateBegin

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `DLC/Expansion/Scenarios/MedievalScenario/TurnsRemaining.lua:118` handler `OnGameCoreUpdateBegin`
- handler body: `DLC/Expansion/Scenarios/MedievalScenario/TurnsRemaining.lua:90`
- adds: 2, calls: 0

## GameMessageChat

- direction: **observable** (engine fires; Lua subscribes)
- args: `fromPlayer, toPlayer, text, eTargetType`
- example registration: `UI/FrontEnd/Multiplayer/StagingRoom.lua:1822` handler `OnChat`
- handler body: `UI/FrontEnd/Multiplayer/StagingRoom.lua:1794`
- adds: 5, calls: 0

## GameOptionsChanged

- direction: **observable** (engine fires; Lua subscribes)
- args: `bUpdateOnly`
- example registration: `UI/InGame/InGame.lua:298` handler `OnGameOptionsChanged`
- handler body: `UI/InGame/InGame.lua:293`
- adds: 7, calls: 0

## GameViewTypeChanged

- direction: **observable** (engine fires; Lua subscribes)
- args: `eNewType`
- example registration: `UI/InGame/InGame.lua:1129` handler `OnGameViewTypeChanged`
- handler body: `UI/InGame/InGame.lua:1121`
- adds: 3, calls: 0

## GameplayAlertMessage

- direction: **observable** (engine fires; Lua subscribes)
- args: `data`
- example registration: `UI/InGame/InGame.lua:414` handler `OnGameplayAlertMessage`
- handler body: `UI/InGame/InGame.lua:406`
- adds: 3, calls: 0

## GameplayFX

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `hex.x, hex.y, -1`
- example callsite: `UI/InGame/WorldView/ActionInfoPanel.lua:139` `(hex.x, hex.y, -1)`
- adds: 0, calls: 17

## GameplaySetActivePlayer

- direction: **observable** (engine fires; Lua subscribes)
- args: `iActivePlayer, iPrevActivePlayer`
- example registration: `UI/Civilopedia/CivilopediaScreen.lua:6482` handler `OnClose`
- handler body: `UI/TouchControlsMenu.lua:18`
- adds: 154, calls: 0

## GenericWorldAnchor

- direction: **mixed** (both subscribed and fired by Lua)
- args: `type, bShow, iPlotX, iPlotY, iData1`
- example registration: `UI/InGame/GenericWorldAnchor.lua:34` handler `OnGenericWorldAnchor`
- handler body: `UI/InGame/GenericWorldAnchor.lua:20`
- example callsite: `UI/InGame/InGame.lua:323` `(GenericWorldAnchorTypes.WORLD_ANCHOR_WORKER, false, v.plot:GetX()`
- adds: 3, calls: 30

## GetFounderBenefitsReligion

- direction: **observable** (engine fires; Lua subscribes)
- args: `ePlayer`
- example registration: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:1895` handler `OnGetFounderBenefitsReligion`
- handler body: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:1882`
- adds: 2, calls: 0

## GetReligionToSpread

- direction: **observable** (engine fires; Lua subscribes)
- args: unknown
- example registration: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:2059` handler `function(ePlayer`
- adds: 2, calls: 0

## GetScenarioDiploModifier1

- direction: **observable** (engine fires; Lua subscribes)
- args: unknown
- example registration: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:2212` handler `function(ePlayer1, ePlayer2`
- adds: 4, calls: 0

## GetScenarioDiploModifier2

- direction: **observable** (engine fires; Lua subscribes)
- args: unknown
- example registration: `DLC/Expansion/Scenarios/SteampunkScenario/TurnsRemaining.lua:548` handler `function(ePlayer1, ePlayer2`
- adds: 1, calls: 0

## GoToPediaHomePage

- direction: **mixed** (both subscribed and fired by Lua)
- args: `iHomePage`
- example registration: `UI/Civilopedia/CivilopediaScreen.lua:6306` handler `GoToPediaHomePage`
- handler body: `UI/Civilopedia/CivilopediaScreen.lua:6300`
- example callsite: `UI/InGame/Popups/AdvisorInfoPopup.lua:220` `(GameInfo.Concepts[g_strConcept].CivilopediaPage)`
- adds: 4, calls: 1

## GraphicsOptionsChanged

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/Options/OptionsMenu.lua:770` handler `UpdateGraphicsOptionsDisplay`
- handler body: `UI/Options/OptionsMenu.lua:729`
- adds: 1, calls: 0

## HexFOWStateChanged

- direction: **observable** (engine fires; Lua subscribes)
- args: `hexPos, fowType, bWholeMap`
- example registration: `UI/InGame/CityBannerManager.lua:987` handler `OnHexFogEvent`
- handler body: `UI/InGame/CityBannerManager.lua:945`
- adds: 8, calls: 0

## HexYieldMightHaveChanged

- direction: **observable** (engine fires; Lua subscribes)
- args: `gridX, gridY`
- example registration: `UI/InGame/YieldIconManager.lua:265` handler `OnYieldChangeEvent`
- handler body: `UI/InGame/YieldIconManager.lua:242`
- adds: 3, calls: 0

## InitCityRangeStrike

- direction: **mixed** (both subscribed and fired by Lua)
- args: `PlayerID, CityID`
- example registration: `UI/InGame/CityBannerManager.lua:1042` handler `OnInitCityRangeStrike`
- handler body: `UI/InGame/CityBannerManager.lua:1019`
- example callsite: `UI/InGame/CityBannerManager.lua:1015` `(PlayerID, CityID)`
- adds: 3, calls: 3

## InterfaceModeChanged

- direction: **observable** (engine fires; Lua subscribes)
- args: `oldInterfaceMode, newInterfaceMode`
- example registration: `UI/InGame/CityBannerManager.lua:1223` handler `OnInterfaceModeChanged`
- handler body: `UI/InGame/CityBannerManager.lua:1214`
- adds: 6, calls: 0

## KeyUpEvent

- direction: **observable** (engine fires; Lua subscribes)
- args: `wParam`
- example registration: `UI/InGame/WorldView/WorldView.lua:150` handler `KeyUpHandler`
- handler body: `UI/InGame/WorldView/WorldView.lua:139`
- adds: 3, calls: 0

## LandmarkLibrarySwap

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `(no args)`
- example callsite: `UI/InGame/DebugMode.lua:386` `()`
- adds: 0, calls: 1

## Leaderboard_ScoresDownloaded

- direction: **observable** (engine fires; Lua subscribes)
- args: `leaderboardStatus, atTop, atBottom`
- example registration: `UI/InGame/Popups/Leaderboard.lua:399` handler `OnLeaderboard_ScoresDownloaded`
- handler body: `UI/InGame/Popups/Leaderboard.lua:361`
- adds: 1, calls: 0

## LeavingLeaderViewMode

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/InGame/LeaderHead/DiploTrade.lua:22` handler `OnLeavingLeader`
- handler body: `UI/InGame/LeaderHead/DiploTrade.lua:19`
- adds: 7, calls: 0

## LoadScreenClose

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `(no args)`
- example callsite: `UI/FrontEnd/LoadScreen.lua:99` `()`
- adds: 0, calls: 1

## LocalMachineUnitPositionChanged

- direction: **observable** (engine fires; Lua subscribes)
- args: `playerID, unitID, unitPosition`
- example registration: `UI/InGame/UnitFlagManager.lua:962` handler `OnUnitPositionChanged`
- handler body: `UI/InGame/UnitFlagManager.lua:943`
- adds: 3, calls: 0

## MilitaryStrategyCanActivate

- direction: **observable** (engine fires; Lua subscribes)
- args: unknown
- example registration: `DLC/Expansion2/Scenarios/CivilWarScenario/TurnsRemaining.lua:144` handler `function(iStrategyID, iPlayer`
- adds: 2, calls: 0

## MinimapClickedEvent

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `x, y`
- example callsite: `UI/InGame/WorldView/MiniMapPanel.lua:21` `(x, y)`
- adds: 0, calls: 2

## MinimapTextureBroadcastEvent

- direction: **observable** (engine fires; Lua subscribes)
- args: `uiHandle, width, height, paddingX`
- example registration: `UI/InGame/WorldView/MiniMapPanel.lua:15` handler `OnMinimapInfo`
- handler body: `UI/InGame/WorldView/MiniMapPanel.lua:11`
- adds: 2, calls: 0

## MultiplayerConnectionComplete

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/FrontEnd/Multiplayer/JoiningRoom.lua:188` handler `OnConnectionCompete`
- handler body: `UI/FrontEnd/Multiplayer/JoiningRoom.lua:120`
- adds: 1, calls: 0

## MultiplayerConnectionFailed

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/FrontEnd/Multiplayer/JoiningRoom.lua:190` handler `OnMultiplayerConnectionFailed`
- handler body: `UI/FrontEnd/Multiplayer/JoiningRoom.lua:82`
- adds: 1, calls: 0

## MultiplayerGameAbandoned

- direction: **observable** (engine fires; Lua subscribes)
- args: `eReason`
- example registration: `UI/FrontEnd/Multiplayer/JoiningRoom.lua:191` handler `OnMultiplayerGameAbandoned`
- handler body: `UI/FrontEnd/Multiplayer/JoiningRoom.lua:95`
- adds: 4, calls: 0

## MultiplayerGameHostMigration

- direction: **observable** (engine fires; Lua subscribes)
- args: `playerID`
- example registration: `UI/FrontEnd/Multiplayer/StagingRoom.lua:1094` handler `OnHostMigration`
- handler body: `UI/FrontEnd/Multiplayer/StagingRoom.lua:1089`
- adds: 1, calls: 0

## MultiplayerGameLastPlayer

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/InGame/WorldView/WorldView.lua:868` handler `OnMultiplayerGameLastPlayer`
- handler body: `UI/InGame/WorldView/WorldView.lua:862`
- adds: 3, calls: 0

## MultiplayerGameLaunched

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/FrontEnd/MainMenu.lua:124` handler `OnGameLaunched`
- handler body: `UI/FrontEnd/MainMenu.lua:119`
- adds: 5, calls: 0

## MultiplayerGameListClear

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/FrontEnd/Multiplayer/Lobby.lua:270` handler `OnGameListClear`
- handler body: `UI/FrontEnd/Multiplayer/Lobby.lua:265`
- adds: 1, calls: 0

## MultiplayerGameListComplete

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/FrontEnd/Multiplayer/Lobby.lua:279` handler `OnGameListComplete`
- handler body: `UI/FrontEnd/Multiplayer/Lobby.lua:276`
- adds: 1, calls: 0

## MultiplayerGameListUpdated

- direction: **observable** (engine fires; Lua subscribes)
- args: `eAction, idLobby, eLobbyType, eSearchType`
- example registration: `UI/FrontEnd/Multiplayer/Lobby.lua:306` handler `OnGameListUpdated`
- handler body: `UI/FrontEnd/Multiplayer/Lobby.lua:284`
- adds: 1, calls: 0

## MultiplayerGameLobbyInvite

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/Civilopedia/CivilopediaScreen.lua:6494` handler `OnMultiplayerGameInvite`
- handler body: `UI/Civilopedia/CivilopediaScreen.lua:6489`
- adds: 6, calls: 0

## MultiplayerGamePlayerDisconnected

- direction: **observable** (engine fires; Lua subscribes)
- args: `playerID`
- example registration: `UI/FrontEnd/Multiplayer/StagingRoom.lua:1085` handler `OnDisconnect`
- handler body: `UI/FrontEnd/Multiplayer/StagingRoom.lua:1075`
- adds: 9, calls: 0

## MultiplayerGamePlayerUpdated

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/FrontEnd/Multiplayer/StagingRoom.lua:1070` handler `OnDisconnectOrPossiblyUpdate`
- handler body: `UI/FrontEnd/Multiplayer/StagingRoom.lua:1060`
- adds: 8, calls: 0

## MultiplayerGameServerInvite

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/Civilopedia/CivilopediaScreen.lua:6495` handler `OnMultiplayerGameInvite`
- handler body: `UI/Civilopedia/CivilopediaScreen.lua:6489`
- adds: 6, calls: 0

## MultiplayerHotJoinCompleted

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/FrontEnd/Multiplayer/StagingRoom.lua:291` handler `OnHotJoinCompleted`
- handler body: `UI/FrontEnd/Multiplayer/StagingRoom.lua:284`
- adds: 3, calls: 0

## MultiplayerHotJoinStarted

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/FrontEnd/Multiplayer/StagingRoom.lua:282` handler `OnHotJoinStarted`
- handler body: `UI/FrontEnd/Multiplayer/StagingRoom.lua:276`
- adds: 3, calls: 0

## MultiplayerJoinRoomComplete

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/FrontEnd/Multiplayer/JoiningRoom.lua:185` handler `OnJoinRoomComplete`
- handler body: `UI/FrontEnd/Multiplayer/JoiningRoom.lua:35`
- adds: 1, calls: 0

## MultiplayerJoinRoomFailed

- direction: **observable** (engine fires; Lua subscribes)
- args: `iExtendedError, aExtendedErrorText`
- example registration: `UI/FrontEnd/Multiplayer/JoiningRoom.lua:186` handler `OnJoinRoomFailed`
- handler body: `UI/FrontEnd/Multiplayer/JoiningRoom.lua:54`
- adds: 1, calls: 0

## MultiplayerNetRegistered

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/FrontEnd/Multiplayer/JoiningRoom.lua:189` handler `OnNetRegistered`
- handler body: `UI/FrontEnd/Multiplayer/JoiningRoom.lua:133`
- adds: 1, calls: 0

## MultiplayerPingTimesChanged

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/FrontEnd/Multiplayer/StagingRoom.lua:1221` handler `OnPingTimesChanged`
- handler body: `UI/FrontEnd/Multiplayer/StagingRoom.lua:1194`
- adds: 2, calls: 0

## NaturalWonderRevealed

- direction: **observable** (engine fires; Lua subscribes)
- args: `i, j`
- example registration: `DLC/Expansion/Tutorial/lua/TutorialChecks.lua:2406` handler `DiscoveredNaturalWonder`
- handler body: `DLC/Expansion/Tutorial/lua/TutorialChecks.lua:2402`
- adds: 1, calls: 0

## NewGameTurn

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/FrontEnd/Multiplayer/StagingRoom.lua:888` handler `UpdateTurnStatusForAll`
- handler body: `UI/FrontEnd/Multiplayer/StagingRoom.lua:882`
- adds: 2, calls: 0

## NotificationAdded

- direction: **observable** (engine fires; Lua subscribes)
- args: `Id, type, toolTip, strSummary, iGameValue, iExtraGameData, ePlayer`
- example registration: `UI/InGame/WorldView/NotificationPanel.lua:315` handler `OnNotificationAdded`
- handler body: `UI/InGame/WorldView/NotificationPanel.lua:146`
- adds: 7, calls: 0

## NotificationRemoved

- direction: **observable** (engine fires; Lua subscribes)
- args: `Id`
- example registration: `UI/InGame/WorldView/NotificationPanel.lua:364` handler `NotificationRemoved`
- handler body: `UI/InGame/WorldView/NotificationPanel.lua:356`
- adds: 3, calls: 0

## OpenInfoCorner

- direction: **mixed** (both subscribed and fired by Lua)
- args: `iInfoType`
- example registration: `UI/InGame/CityList.lua:339` handler `OnOpenInfoCorner`
- handler body: `UI/InGame/CityList.lua:332`
- example callsite: `UI/InGame/CityList.lua:43` `(InfoCornerID.None)`
- adds: 11, calls: 13

## OpenPlayerDealScreenEvent

- direction: **mixed** (both subscribed and fired by Lua)
- args: `iOtherPlayer`
- example registration: `UI/InGame/DiploList.lua:175` handler `OnOpenPlayerDealScreen`
- handler body: `UI/InGame/DiploList.lua:159`
- example callsite: `UI/InGame/CityBannerManager.lua:1092` `(ePlayer)`
- adds: 9, calls: 14

## ParticleEffectReloadRequested

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `(no args)`
- example callsite: `UI/InGame/DebugMenu.lua:243` `()`
- adds: 0, calls: 1

## ParticleEffectStatsRequested

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `(no args)`
- example callsite: `UI/InGame/DebugMenu.lua:205` `()`
- adds: 0, calls: 1

## ParticleEffectStatsResponse

- direction: **observable** (engine fires; Lua subscribes)
- args: `responseData`
- example registration: `UI/InGame/DebugMenu.lua:254` handler `OnPEffectStatsResponse`
- handler body: `UI/InGame/DebugMenu.lua:230`
- adds: 1, calls: 0

## PlayerAdoptPolicy

- direction: **observable** (engine fires; Lua subscribes)
- args: `iPlayer, ePolicy`
- example registration: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:2133` handler `PlayerAdoptPolicyHook`
- handler body: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:2122`
- adds: 2, calls: 0

## PlayerCanAdoptPolicyBranch

- direction: **observable** (engine fires; Lua subscribes)
- args: `iPlayerID, iPolicyBranch`
- example registration: `DLC/Expansion/Scenarios/FallOfRomeScenario/TurnsRemaining.lua:474` handler `CanAdoptPolicyBranch`
- handler body: `DLC/Expansion/Scenarios/FallOfRomeScenario/TurnsRemaining.lua:471`
- adds: 3, calls: 0

## PlayerChoseToLoadGame

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `Steam.GetCloudSaveFileName(g_iSelected`
- example callsite: `UI/FrontEnd/LoadMenu.lua:35` `(Steam.GetCloudSaveFileName(g_iSelected)`
- adds: 0, calls: 2

## PlayerCityFounded

- direction: **observable** (engine fires; Lua subscribes)
- args: unknown
- example registration: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:2091` handler `function(iPlayer, iCityX, iCityY`
- adds: 2, calls: 0

## PlayerDoTurn

- direction: **observable** (engine fires; Lua subscribes)
- args: unknown
- example registration: `DLC/DLC_02/Scenarios/NewWorldScenario/TurnsRemaining.lua:322` handler `function(iPlayer`
- adds: 11, calls: 0

## PlayerVersionMismatchEvent

- direction: **observable** (engine fires; Lua subscribes)
- args: `iPlayerID, playerName, bIsHost`
- example registration: `UI/FrontEnd/Multiplayer/JoiningRoom.lua:152` handler `OnVersionMismatch`
- handler body: `UI/FrontEnd/Multiplayer/JoiningRoom.lua:140`
- adds: 2, calls: 0

## PreGameDirty

- direction: **mixed** (both subscribed and fired by Lua)
- args: `(no args)`
- example registration: `UI/FrontEnd/Multiplayer/StagingRoom.lua:1168` handler `OnPreGameDirty`
- handler body: `UI/FrontEnd/Multiplayer/StagingRoom.lua:1161`
- example callsite: `UI/FrontEnd/GameSetup/SetCivNames.lua:76` `()`
- adds: 1, calls: 1

## RemotePlayerTurnEnd

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/FrontEnd/Multiplayer/StagingRoom.lua:889` handler `UpdateTurnStatusForAll`
- handler body: `UI/FrontEnd/Multiplayer/StagingRoom.lua:882`
- adds: 6, calls: 0

## RemotePlayerTurnStart

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/InGame/TurnProcessing.lua:117` handler `OnPlayerTurnStart`
- handler body: `UI/InGame/TurnProcessing.lua:110`
- adds: 2, calls: 0

## RemoveAllArrowsEvent

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `(no args)`
- example callsite: `UI/InGame/Bombardment.lua:198` `()`
- adds: 0, calls: 5

## RequestYieldDisplay

- direction: **mixed** (both subscribed and fired by Lua)
- args: `type`
- example registration: `UI/InGame/ResourceIconManager.lua:165` handler `OnRequestYieldDisplay`
- handler body: `UI/InGame/ResourceIconManager.lua:153`
- example callsite: `UI/InGame/InGame.lua:311` `(YieldDisplayTypes.CITY_WORKED, lastCityEntered:GetX()`
- adds: 3, calls: 24

## RunCombatSim

- direction: **observable** (engine fires; Lua subscribes)
- args: `iAttackingPlayer, iAttackingUnit, iAttackingUnitDamage, iAttackingUnitFinalDamage, iAttackingUnitMaxHitPoints, iDefendingPlayer, iDefendingUnit, iDefendingUnitDamage, iDefendingUnitFinalDamage, iDefendingUnitMaxHitPoints`
- example registration: `UI/InGame/UnitFlagManager.lua:1560` handler `OnCombatBegin`
- handler body: `DLC/Expansion/Tutorial/lua/TutorialChecks.lua:3116`
- adds: 6, calls: 0

## SearchForPediaEntry

- direction: **mixed** (both subscribed and fired by Lua)
- args: `searchString`
- example registration: `UI/Civilopedia/CivilopediaScreen.lua:6295` handler `SearchForPediaEntry`
- handler body: `UI/Civilopedia/CivilopediaScreen.lua:6264`
- example callsite: `UI/InGame/CityList.lua:327` `(searchString)`
- adds: 4, calls: 32

## SequenceGameInitComplete

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/FrontEnd/LoadScreen.lua:168` handler `OnSequenceGameInitComplete`
- handler body: `UI/FrontEnd/LoadScreen.lua:132`
- adds: 1, calls: 0

## SerialEventBuildingSizeChanged

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `g_nBuildingSize/100`
- example callsite: `UI/InGame/DebugMode.lua:184` `(g_nBuildingSize/100)`
- adds: 0, calls: 1

## SerialEventCameraIn

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `Vector2(0.5,0.5`
- example callsite: `UI/InGame/DebugMenu.lua:387` `(Vector2(0.5,0.5)`
- adds: 0, calls: 4

## SerialEventCameraOut

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `Vector2(0.5,0.5`
- example callsite: `UI/InGame/DebugMenu.lua:382` `(Vector2(0.5,0.5)`
- adds: 0, calls: 4

## SerialEventCameraStartMovingBack

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `(no args)`
- example callsite: `UI/InGame/DebugMenu.lua:361` `()`
- adds: 0, calls: 7

## SerialEventCameraStartMovingForward

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `(no args)`
- example callsite: `UI/InGame/DebugMenu.lua:357` `()`
- adds: 0, calls: 7

## SerialEventCameraStartMovingLeft

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `(no args)`
- example callsite: `UI/InGame/DebugMenu.lua:349` `()`
- adds: 0, calls: 7

## SerialEventCameraStartMovingRight

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `(no args)`
- example callsite: `UI/InGame/DebugMenu.lua:353` `()`
- adds: 0, calls: 7

## SerialEventCameraStopMovingBack

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `(no args)`
- example callsite: `UI/InGame/DebugMenu.lua:322` `()`
- adds: 0, calls: 13

## SerialEventCameraStopMovingForward

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `(no args)`
- example callsite: `UI/InGame/DebugMenu.lua:317` `()`
- adds: 0, calls: 13

## SerialEventCameraStopMovingLeft

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `(no args)`
- example callsite: `UI/InGame/DebugMenu.lua:307` `()`
- adds: 0, calls: 13

## SerialEventCameraStopMovingRight

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `(no args)`
- example callsite: `UI/InGame/DebugMenu.lua:312` `()`
- adds: 0, calls: 13

## SerialEventCityCaptured

- direction: **observable** (engine fires; Lua subscribes)
- args: `hexPos, playerID, cityID, newPlayerID`
- example registration: `UI/InGame/CityBannerManager.lua:845` handler `OnCityDestroyed`
- handler body: `UI/InGame/CityBannerManager.lua:818`
- adds: 11, calls: 0

## SerialEventCityContinentChanged

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `g_iHexX, g_iHexY, (g_iCityContinent - 1`
- example callsite: `UI/InGame/DebugMode.lua:175` `(g_iHexX, g_iHexY, (g_iCityContinent - 1)`
- adds: 0, calls: 1

## SerialEventCityCreated

- direction: **observable** (engine fires; Lua subscribes)
- args: `hexPos, playerID, cityID, cultureType, eraType, continent, populationSize, size, fowState`
- example registration: `UI/InGame/CityBannerManager.lua:659` handler `OnCityCreated`
- handler body: `UI/InGame/CityBannerManager.lua:583`
- adds: 7, calls: 0

## SerialEventCityCultureChanged

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `g_iHexX, g_iHexY, g_iCityCulture-1`
- example callsite: `UI/InGame/DebugMode.lua:160` `(g_iHexX, g_iHexY, g_iCityCulture-1)`
- adds: 0, calls: 1

## SerialEventCityDestroyed

- direction: **observable** (engine fires; Lua subscribes)
- args: `hexPos, playerID, cityID, newPlayerID`
- example registration: `UI/InGame/CityBannerManager.lua:844` handler `OnCityDestroyed`
- handler body: `UI/InGame/CityBannerManager.lua:818`
- adds: 10, calls: 0

## SerialEventCityHexHighlightDirty

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/InGame/CityView/CityView.lua:1898` handler `UpdateWorkingHexes`
- handler body: `UI/InGame/CityView/CityView.lua:1733`
- adds: 3, calls: 0

## SerialEventCityInfoDirty

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/InGame/Bombardment.lua:274` handler `OnCityInfoDirty`
- handler body: `UI/InGame/Bombardment.lua:259`
- adds: 25, calls: 0

## SerialEventCityPopulationChanged

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `g_iHexX, g_iHexY, g_iPopulation, iCitySize`
- example callsite: `UI/InGame/DebugMode.lua:168` `(g_iHexX, g_iHexY, g_iPopulation, iCitySize)`
- adds: 0, calls: 1

## SerialEventCityScreenDirty

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/InGame/CityView/CityView.lua:1485` handler `OnCityViewUpdate`
- handler body: `UI/InGame/CityView/CityView.lua:640`
- adds: 6, calls: 0

## SerialEventCitySetDamage

- direction: **observable** (engine fires; Lua subscribes)
- args: `iPlayerID, iCityID, iDamage, iPreviousDamage`
- example registration: `UI/InGame/CityBannerManager.lua:909` handler `OnCitySetDamage`
- handler body: `UI/InGame/CityBannerManager.lua:901`
- adds: 4, calls: 0

## SerialEventDawnOfManHide

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `iCivID`
- example callsite: `UI/FrontEnd/LoadScreen.lua:14` `(iCivID)`
- adds: 0, calls: 1

## SerialEventDawnOfManShow

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `iCivID`
- example callsite: `UI/FrontEnd/LoadScreen.lua:20` `(iCivID)`
- adds: 0, calls: 1

## SerialEventEndTurnDirty

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/InGame/WorldView/ActionInfoPanel.lua:427` handler `OnEndTurnDirty`
- handler body: `UI/InGame/WorldView/ActionInfoPanel.lua:290`
- adds: 3, calls: 0

## SerialEventEnterCityScreen

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/InGame/InGame.lua:346` handler `OnEnterCityScreen`
- handler body: `UI/InGame/InGame.lua:302`
- adds: 18, calls: 0

## SerialEventEraChanged

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `g_iCityEra-1, g_iCurrPlayer`
- example callsite: `UI/InGame/DebugMode.lua:153` `(g_iCityEra-1, g_iCurrPlayer)`
- adds: 0, calls: 1

## SerialEventEspionageScreenDirty

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `DLC/Expansion/UI/InGame/Popups/EspionageOverview.lua:1405` handler `Refresh`
- handler body: `UI/FrontEnd/GameSetup/SelectMapType.lua:128`
- adds: 4, calls: 0

## SerialEventExitCityScreen

- direction: **mixed** (both subscribed and fired by Lua)
- args: `(no args)`
- example registration: `UI/InGame/InGame.lua:402` handler `OnExitCityScreen`
- handler body: `UI/InGame/InGame.lua:351`
- example callsite: `UI/InGame/TopPanel.lua:253` `()`
- adds: 28, calls: 14

## SerialEventGameDataDirty

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/InGame/DiploList.lua:440` handler `UpdateDisplay`
- handler body: `UI/FrontEnd/GameSetup/GameSetupScreen.lua:193`
- adds: 30, calls: 0

## SerialEventGameMessagePopup

- direction: **mixed** (both subscribed and fired by Lua)
- args: `data`
- example registration: `UI/InGame/DiploList.lua:97` handler `OnPopup`
- handler body: `UI/InGame/DiploList.lua:90`
- example callsite: `UI/InGame/CityBannerManager.lua:1121` `(popupInfo)`
- adds: 108, calls: 122

## SerialEventGameMessagePopupProcessed

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `ButtonPopupTypes.BUTTONPOPUP_CHOOSETECH, 0`
- example callsite: `UI/InGame/TechPopup.lua:28` `(ButtonPopupTypes.BUTTONPOPUP_CHOOSETECH, 0)`
- adds: 0, calls: 3

## SerialEventGameMessagePopupShown

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `m_PopupInfo`
- example callsite: `UI/InGame/TechPopup.lua:73` `(popupInfo)`
- adds: 0, calls: 97

## SerialEventGreatWorksScreenDirty

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `DLC/Expansion2/UI/InGame/Popups/CultureOverview.lua:1777` handler `RefreshSwapGreatWorks`
- handler body: `DLC/Expansion2/UI/InGame/Popups/CultureOverview.lua:1773`
- adds: 1, calls: 0

## SerialEventHexDeSelected

- direction: **observable** (engine fires; Lua subscribes)
- args: `iHexX, iHexY`
- example registration: `UI/InGame/DebugMode.lua:42` handler `HexDeSelected`
- handler body: `UI/InGame/DebugMode.lua:32`
- adds: 1, calls: 0

## SerialEventHexGridOff

- direction: **mixed** (both subscribed and fired by Lua)
- args: `(no args)`
- example registration: `UI/InGame/WorldView/MiniMapPanel.lua:361` handler `OnGridOff`
- handler body: `UI/InGame/WorldView/MiniMapPanel.lua:354`
- example callsite: `UI/InGame/InGame.lua:387` `()`
- adds: 2, calls: 3

## SerialEventHexGridOn

- direction: **mixed** (both subscribed and fired by Lua)
- args: `(no args)`
- example registration: `UI/InGame/WorldView/MiniMapPanel.lua:349` handler `OnGridOn`
- handler body: `UI/InGame/WorldView/MiniMapPanel.lua:342`
- example callsite: `UI/InGame/InGame.lua:338` `()`
- adds: 2, calls: 3

## SerialEventHexHighlight

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `hexID, false, workerSuggestHighlightColor, genericUnitHexBorder`
- example callsite: `UI/InGame/Bombardment.lua:75` `(hexID, true, highlightColor, "FireRangeBorder")`
- adds: 0, calls: 50

## SerialEventHexSelected

- direction: **observable** (engine fires; Lua subscribes)
- args: `iHexX, iHexY`
- example registration: `UI/InGame/DebugMode.lua:470` handler `HexSelected`
- handler body: `UI/InGame/DebugMode.lua:409`
- adds: 1, calls: 0

## SerialEventImprovementCreated

- direction: **mixed** (both subscribed and fired by Lua)
- args: `HPosX, HPosY, CultureType, ContinentType, PlayerType, engineImprovementTypeDoNotUse, ImprovementType, engineResourceTypeDoNotUse, RawResourceType, ImprovementEra, ImprovementState`
- example registration: `DLC/Expansion/Tutorial/lua/TutorialChecks.lua:2703` handler `OnImprovementCreated`
- handler body: `DLC/Expansion/Tutorial/lua/TutorialChecks.lua:2681`
- example callsite: `UI/InGame/DebugMode.lua:453` `(iHexX, iHexY, continent,   continent,     playerID,   g_iCreateImprovementType, g_iCreateImprovementRRType, g_iCreateImprovementEra, g_iCreateImprovementState)`
- adds: 1, calls: 1

## SerialEventLeagueScreenDirty

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:242` handler `UpdatePartial`
- handler body: `DLC/Expansion2/UI/InGame/Popups/LeagueOverview.lua:239`
- adds: 1, calls: 0

## SerialEventMouseOverHex

- direction: **observable** (engine fires; Lua subscribes)
- args: `hexX, hexY`
- example registration: `UI/InGame/Bombardment.lua:252` handler `DisplayBombardArrow`
- handler body: `UI/InGame/Bombardment.lua:179`
- adds: 17, calls: 0

## SerialEventRawResourceCreated

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `iHexX, iHexY, continent,   continent,     playerID,   -1,              g_iCreateResourceType, 0,              0`
- example callsite: `UI/InGame/DebugMode.lua:464` `(iHexX, iHexY, continent,   continent,     playerID,   -1,              g_iCreateResourceType, 0,              0)`
- adds: 0, calls: 1

## SerialEventRawResourceIconCreated

- direction: **observable** (engine fires; Lua subscribes)
- args: `hexPosX, hexPosY, ImprovementType, ResourceType`
- example registration: `UI/InGame/ResourceIconManager.lua:124` handler `OnResourceAdded`
- handler body: `UI/InGame/ResourceIconManager.lua:72`
- adds: 1, calls: 0

## SerialEventRawResourceIconDestroyed

- direction: **observable** (engine fires; Lua subscribes)
- args: `hexPosX, hexPosY`
- example registration: `UI/InGame/ResourceIconManager.lua:149` handler `OnResourceRemoved`
- handler body: `UI/InGame/ResourceIconManager.lua:128`
- adds: 1, calls: 0

## SerialEventResearchDirty

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/InGame/TechTree/TechTree.lua:825` handler `OnEventResearchDirty`
- handler body: `UI/InGame/TechTree/TechTree.lua:820`
- adds: 3, calls: 0

## SerialEventRoadCreated

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `g_iHexX, g_iHexY, g_iCurrPlayer, 0`
- example callsite: `UI/InGame/DebugMode.lua:429` `(g_iHexX, g_iHexY, g_iCurrPlayer, 0)`
- adds: 0, calls: 1

## SerialEventRoadDestroyed

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `g_iHexX, g_iHexY`
- example callsite: `UI/InGame/DebugMode.lua:427` `(g_iHexX, g_iHexY)`
- adds: 0, calls: 1

## SerialEventScoreDirty

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/InGame/DiploList.lua:438` handler `UpdateDisplay`
- handler body: `UI/FrontEnd/GameSetup/GameSetupScreen.lua:193`
- adds: 5, calls: 0

## SerialEventStartGame

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `WorldSizeTypes.WORLDSIZE_STANDARD`
- example callsite: `UI/FrontEnd/LoadTutorial.lua:120` `()`
- adds: 0, calls: 22

## SerialEventTurnTimerDirty

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/InGame/TopPanel.lua:920` handler `OnTopPanelDirty`
- handler body: `UI/InGame/TopPanel.lua:229`
- adds: 5, calls: 0

## SerialEventUnitCreated

- direction: **observable** (engine fires; Lua subscribes)
- args: `playerID, unitID, hexVec, unitType, cultureType, civID, primaryColor, secondaryColor, unitFlagIndex, fogState, selected, military, notInvisible`
- example registration: `UI/InGame/UnitFlagManager.lua:935` handler `OnUnitCreated`
- handler body: `UI/InGame/UnitFlagManager.lua:919`
- adds: 6, calls: 0

## SerialEventUnitDestroyed

- direction: **observable** (engine fires; Lua subscribes)
- args: `playerID, unitID`
- example registration: `UI/InGame/InGame.lua:885` handler `OnUnitDestroyed`
- handler body: `UI/InGame/InGame.lua:880`
- adds: 9, calls: 0

## SerialEventUnitFlagSelected

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `Game:GetActivePlayer(`
- example callsite: `UI/InGame/UnitFlagManager.lua:1198` `(playerID, unitID)`
- adds: 0, calls: 8

## SerialEventUnitInfoDirty

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/InGame/Popups/ProductionPopup.lua:825` handler `OnDirty`
- handler body: `UI/InGame/Popups/ProductionPopup.lua:812`
- adds: 6, calls: 0

## SerialEventUnitMove

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/InGame/UnitList.lua:89` handler `OnChangeEvent`
- handler body: `UI/InGame/CityList.lua:65`
- adds: 2, calls: 0

## SerialEventUnitMoveToHexes

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/InGame/UnitList.lua:88` handler `OnChangeEvent`
- handler body: `UI/InGame/CityList.lua:65`
- adds: 2, calls: 0

## SerialEventUnitSetDamage

- direction: **observable** (engine fires; Lua subscribes)
- args: `playerID, unitID, iDamage, iPreviousDamage`
- example registration: `UI/InGame/UnitFlagManager.lua:1265` handler `OnUnitSetDamage`
- handler body: `UI/InGame/UnitFlagManager.lua:1248`
- adds: 5, calls: 0

## SerialEventUnitTeleportedToHex

- direction: **observable** (engine fires; Lua subscribes)
- args: `i, j, playerID, unitID`
- example registration: `UI/InGame/UnitFlagManager.lua:1000` handler `OnUnitTeleported`
- handler body: `UI/InGame/UnitFlagManager.lua:996`
- adds: 5, calls: 0

## SetAlly

- direction: **observable** (engine fires; Lua subscribes)
- args: unknown
- example registration: `DLC/DLC_04/Scenarios/1066Scenario/TurnsRemaining.lua:171` handler `function(iCSPlayer, iOldAlly, iNewAlly`
- adds: 2, calls: 0

## SetPopulation

- direction: **observable** (engine fires; Lua subscribes)
- args: unknown
- example registration: `DLC/DLC_02/Scenarios/NewWorldScenario/TurnsRemaining.lua:72` handler `function(iX, iY, oldPopulation, newPopulation`
- adds: 2, calls: 0

## ShowAttackTargets

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `iPlayerID, unit:GetID(`
- example callsite: `UI/InGame/InGame.lua:636` `(iPlayerID, unit:GetID()`
- adds: 0, calls: 3

## ShowHexYield

- direction: **observable** (engine fires; Lua subscribes)
- args: `x, y, bShow`
- example registration: `UI/InGame/YieldIconManager.lua:61` handler `ShowHexYield`
- handler body: `UI/InGame/YieldIconManager.lua:47`
- adds: 3, calls: 0

## ShowMovementRange

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `iPlayerID, unit:GetID(`
- example callsite: `UI/InGame/InGame.lua:534` `(iPlayerID, unit:GetID()`
- adds: 0, calls: 6

## SpawnArrowEvent

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `attacker:GetX(`
- example callsite: `UI/InGame/Bombardment.lua:196` `(attacker:GetX()`
- adds: 0, calls: 2

## SpecificCityInfoDirty

- direction: **mixed** (both subscribed and fired by Lua)
- args: `iPlayerID, iCityID, eUpdateType`
- example registration: `UI/InGame/CityBannerManager.lua:940` handler `OnSpecificCityInfoDirty`
- handler body: `UI/InGame/CityBannerManager.lua:915`
- example callsite: `UI/InGame/Popups/ProductionPopup.lua:106` `(player, cityID, CityUpdateTypes.CITY_UPDATE_TYPE_BANNER)`
- adds: 4, calls: 9

## StartUnitMoveHexRange

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/InGame/WorldView/WorldView.lua:826` handler `OnStartUnitMoveHexRange`
- handler body: `UI/InGame/WorldView/WorldView.lua:822`
- adds: 3, calls: 0

## StrategicViewStateChanged

- direction: **observable** (engine fires; Lua subscribes)
- args: `bStrategicView, bCityBanners`
- example registration: `UI/InGame/CityBannerManager.lua:1232` handler `OnStrategicViewStateChanged`
- handler body: `UI/InGame/CityBannerManager.lua:1227`
- adds: 18, calls: 0

## SystemUpdateUI

- direction: **mixed** (both subscribed and fired by Lua)
- args: `type, tag`
- example registration: `UI/FrontEnd/MainMenu.lua:298` handler `OnSystemUpdateUI`
- handler body: `UI/FrontEnd/MainMenu.lua:259`
- example callsite: `UI/FrontEnd/MainMenu.lua:35` `(SystemUpdateUIType.RestoreUI, "MainMenu")`
- adds: 11, calls: 9

## TaskListUpdate

- direction: **observable** (engine fires; Lua subscribes)
- args: `fDTime`
- example registration: `UI/InGame/TaskList.lua:47` handler `OnUpdate`
- handler body: `UI/CommonBehaviors.lua:103`
- adds: 1, calls: 0

## TeamMeet

- direction: **observable** (engine fires; Lua subscribes)
- args: `eTeamMet, eTeamMoving`
- example registration: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:2279` handler `TeamMeetHook`
- handler body: `DLC/DLC_07/Scenarios/Conquest of the New World Deluxe/UI/TurnsRemaining.lua:2240`
- adds: 1, calls: 0

## TeamSetHasTech

- direction: **observable** (engine fires; Lua subscribes)
- args: unknown
- example registration: `DLC/Expansion/Scenarios/MedievalScenario/TurnsRemaining.lua:700` handler `function(iTeam, iTech, bAdopted`
- adds: 1, calls: 0

## TeamTechResearched

- direction: **observable** (engine fires; Lua subscribes)
- args: `iTeamID, eTech, iChange`
- example registration: `DLC/DLC_02/Scenarios/NewWorldScenario/TurnsRemaining.lua:538` handler `OnTechResearched`
- handler body: `DLC/DLC_02/Scenarios/NewWorldScenario/TurnsRemaining.lua:522`
- adds: 4, calls: 0

## TechAcquired

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/InGame/Popups/VictoryProgress.lua:1023` handler `CountPreReqsAcquired`
- handler body: `UI/InGame/Popups/VictoryProgress.lua:1008`
- adds: 7, calls: 0

## UIPathFinderUpdate

- direction: **observable** (engine fires; Lua subscribes)
- args: `data`
- example registration: `UI/InGame/WorldView/PathHelpManager.lua:25` handler `OnPath`
- handler body: `UI/InGame/WorldView/PathHelpManager.lua:9`
- adds: 4, calls: 0

## UnitActionChanged

- direction: **observable** (engine fires; Lua subscribes)
- args: `playerID, unitID`
- example registration: `UI/InGame/UnitFlagManager.lua:988` handler `OnFlagTypeChange`
- handler body: `UI/InGame/UnitFlagManager.lua:968`
- adds: 5, calls: 0

## UnitDataEdited

- direction: **mixed** (both subscribed and fired by Lua)
- args: `floatVarList, memberCount, memberIndex, isDebugFSM, specRender, isFromLua`
- example registration: `UI/InGame/DebugMode.lua:714` handler `OnFloatVarListTransfer`
- handler body: `UI/InGame/DebugMode.lua:697`
- example callsite: `UI/InGame/DebugMode.lua:691` `(g_tFloatVarList, g_iUnitMemberCount, g_iUnitMemberIndex-1, false, g_iUnitSpecularRender)`
- adds: 1, calls: 1

## UnitDataRequested

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `g_iUnitMemberIndex-1`
- example callsite: `UI/InGame/DebugMode.lua:668` `(g_iUnitMemberIndex-1)`
- adds: 0, calls: 1

## UnitDebugFSM

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `g_iUnitMemberIndex-1`
- example callsite: `UI/InGame/DebugMode.lua:683` `(g_iUnitMemberIndex-1)`
- adds: 0, calls: 1

## UnitEmbark

- direction: **observable** (engine fires; Lua subscribes)
- args: `playerID, unitID`
- example registration: `UI/InGame/UnitFlagManager.lua:990` handler `OnFlagTypeChange`
- handler body: `UI/InGame/UnitFlagManager.lua:968`
- adds: 8, calls: 0

## UnitFlagUpdated

- direction: **mixed** (both subscribed and fired by Lua)
- args: `(no args)`
- example registration: `UI/InGame/UnitList.lua:85` handler `OnChangeEvent`
- handler body: `UI/InGame/CityList.lua:65`
- example callsite: `UI/InGame/DebugMode.lua:514` `(g_iUnitCulture, g_iUnitType, g_fUnitHealth, g_bUnitFortified)`
- adds: 2, calls: 4

## UnitGarrison

- direction: **observable** (engine fires; Lua subscribes)
- args: `playerID, unitID, bGarrisoned`
- example registration: `UI/InGame/CityBannerManager.lua:1169` handler `OnUnitGarrison`
- handler body: `UI/InGame/CityBannerManager.lua:1153`
- adds: 14, calls: 0

## UnitGetSpecialExploreTarget

- direction: **observable** (engine fires; Lua subscribes)
- args: `iPlayerID, iUnitID`
- example registration: `DLC/DLC_02/Scenarios/NewWorldScenario/TurnsRemaining.lua:596` handler `OnSpecialExploreRequest`
- handler body: `DLC/DLC_02/Scenarios/NewWorldScenario/TurnsRemaining.lua:541`
- adds: 3, calls: 0

## UnitHexHighlight

- direction: **observable** (engine fires; Lua subscribes)
- args: `i, j, k, bOn, unitId`
- example registration: `UI/InGame/InGame.lua:992` handler `OnUnitHexHighlight`
- handler body: `UI/InGame/InGame.lua:975`
- adds: 3, calls: 0

## UnitKilledInCombat

- direction: **observable** (engine fires; Lua subscribes)
- args: unknown
- example registration: `DLC/DLC_05/Scenarios/KoreaScenario/TurnsRemaining.lua:289` handler `function(iPlayer, iKilledPlayer`
- adds: 2, calls: 0

## UnitLibrarySwap

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `(no args)`
- example callsite: `UI/InGame/DebugMode.lua:390` `()`
- adds: 0, calls: 1

## UnitMarkThreatening

- direction: **observable** (engine fires; Lua subscribes)
- args: `playerID, unitID, bMark`
- example registration: `UI/InGame/UnitFlagManager.lua:1429` handler `OnMarkThreateningEvent`
- handler body: `UI/InGame/UnitFlagManager.lua:1406`
- adds: 3, calls: 0

## UnitMemberCombatStateChanged

- direction: **observable** (engine fires; Lua subscribes)
- args: `playerID, unitID, memberID, stateID`
- example registration: `UI/InGame/UnitMemberOverlay.lua:434` handler `OnUnitMemberCombatStateChanged`
- handler body: `UI/InGame/UnitMemberOverlay.lua:410`
- adds: 1, calls: 0

## UnitMemberCombatTargetChanged

- direction: **observable** (engine fires; Lua subscribes)
- args: `playerID, unitID, memberID, targetPlayerID, targetUnitID, targetMemberID`
- example registration: `UI/InGame/UnitMemberOverlay.lua:378` handler `OnUnitMemberCombatTargetChanged`
- handler body: `UI/InGame/UnitMemberOverlay.lua:349`
- adds: 1, calls: 0

## UnitMemberOverlayAdd

- direction: **observable** (engine fires; Lua subscribes)
- args: `playerID, unitID, memberID, position`
- example registration: `UI/InGame/UnitMemberOverlay.lua:260` handler `OnUnitOverlayAdd`
- handler body: `UI/InGame/UnitMemberOverlay.lua:245`
- adds: 1, calls: 0

## UnitMemberOverlayRemove

- direction: **observable** (engine fires; Lua subscribes)
- args: `playerID, unitID, memberID`
- example registration: `UI/InGame/UnitMemberOverlay.lua:290` handler `OnUnitOverlayRemove`
- handler body: `UI/InGame/UnitMemberOverlay.lua:265`
- adds: 1, calls: 0

## UnitMemberOverlayShowHide

- direction: **observable** (engine fires; Lua subscribes)
- args: `playerID, unitID, memberID, bShow`
- example registration: `UI/InGame/UnitMemberOverlay.lua:317` handler `OnUnitOverlayShowHide`
- handler body: `UI/InGame/UnitMemberOverlay.lua:295`
- adds: 1, calls: 0

## UnitMemberPositionChanged

- direction: **observable** (engine fires; Lua subscribes)
- args: `playerID, unitID, memberID, unitPosition`
- example registration: `UI/InGame/UnitMemberOverlay.lua:405` handler `OnUnitMemberPositionChanged`
- handler body: `UI/InGame/UnitMemberOverlay.lua:383`
- adds: 1, calls: 0

## UnitMoveQueueChanged

- direction: **observable** (engine fires; Lua subscribes)
- args: `playerID, unitID, bRemainingMoves`
- example registration: `UI/InGame/CityBannerManager.lua:1190` handler `OnUnitMoveQueueChanged`
- handler body: `UI/InGame/CityBannerManager.lua:1174`
- adds: 6, calls: 0

## UnitNameChanged

- direction: **mixed** (both subscribed and fired by Lua)
- args: `playerID, unitID`
- example registration: `DLC/Expansion/UI/InGame/UnitFlagManager.lua:1315` handler `OnUnitNameChanged`
- handler body: `DLC/Expansion/UI/InGame/UnitFlagManager.lua:1299`
- example callsite: `DLC/Expansion2/Scenarios/CivilWarScenario/TurnsRemaining.lua:406` `(pGeneral:GetOwner()`
- adds: 2, calls: 6

## UnitSelectionChanged

- direction: **mixed** (both subscribed and fired by Lua)
- args: `p, u, i, j, k, isSelected`
- example registration: `UI/InGame/InGame.lua:777` handler `OnUnitSelectionChange`
- handler body: `UI/InGame/InGame.lua:767`
- example callsite: `UI/InGame/DebugMode.lua:437` `(playerID, -1, 0, 0, 0, false, false)`
- adds: 20, calls: 8

## UnitSelectionCleared

- direction: **observable** (engine fires; Lua subscribes)
- args: `(no args)`
- example registration: `UI/InGame/InGame.lua:875` handler `OnUnitSelectionCleared`
- handler body: `UI/InGame/InGame.lua:847`
- adds: 3, calls: 0

## UnitSetXY

- direction: **observable** (engine fires; Lua subscribes)
- args: `iPlayer, iUnitID, iX, iY`
- example registration: `DLC/DLC_02/Scenarios/NewWorldScenario/TurnsRemaining.lua:150` handler `function(iPlayer, iUnitID, iX, iY`
- handler body: `DLC/Expansion/Scenarios/FallOfRomeScenario/TurnsRemaining.lua:1022`
- adds: 8, calls: 0

## UnitShouldDimFlag

- direction: **observable** (engine fires; Lua subscribes)
- args: `playerID, unitID, bDim`
- example registration: `UI/InGame/UnitFlagManager.lua:1399` handler `OnDimEvent`
- handler body: `UI/InGame/UnitFlagManager.lua:1373`
- adds: 4, calls: 0

## UnitStateChangeDetected

- direction: **observable** (engine fires; Lua subscribes)
- args: `playerID, unitID, fogState`
- example registration: `UI/InGame/UnitFlagManager.lua:1351` handler `OnUnitFogEvent`
- handler body: `UI/InGame/UnitFlagManager.lua:1332`
- adds: 6, calls: 0

## UnitTypeChanged

- direction: **fire-only** (Lua fires into engine; not subscribable for observation)
- args (from callsite): `"ART_DEF_UNIT_U_" .. ArtInfo.UniqueUnits[g_iCreateUniqueUnitType].Type`
- example callsite: `UI/InGame/DebugMode.lua:208` `("ART_DEF_UNIT_" .. ArtInfo.Units[g_iCreateCommonGreatUnitType].Type)`
- adds: 0, calls: 2

## UnitVisibilityChanged

- direction: **observable** (engine fires; Lua subscribes)
- args: `playerID, unitID, visible, checkFlag, blendTime`
- example registration: `UI/InGame/UnitFlagManager.lua:1176` handler `OnUnitVisibility`
- handler body: `UI/InGame/UnitFlagManager.lua:1165`
- adds: 3, calls: 0

## UserRequestClose

- direction: **mixed** (both subscribed and fired by Lua)
- args: `(no args)`
- example registration: `UI/FrontEnd/ExitConfirm.lua:12` handler `OnExitGame`
- handler body: `UI/FrontEnd/ExitConfirm.lua:8`
- example callsite: `UI/FrontEnd/MainMenu.lua:107` `()`
- adds: 3, calls: 4

## WarStateChanged

- direction: **observable** (engine fires; Lua subscribes)
- args: `iTeam1, iTeam2, bWar`
- example registration: `UI/InGame/LeaderHead/LeaderHeadRoot.lua:307` handler `WarStateChangedHandler`
- handler body: `UI/InGame/LeaderHead/LeaderHeadRoot.lua:287`
- adds: 3, calls: 0

## WorldMouseOver

- direction: **mixed** (both subscribed and fired by Lua)
- args: `bWorldHasMouseOver`
- example registration: `UI/InGame/WorldView/EnemyUnitPanel.lua:1824` handler `OnWorldMouseOver`
- handler body: `UI/InGame/WorldView/EnemyUnitPanel.lua:1815`
- example callsite: `UI/InGame/PlotHelpManager.lua:353` `(true)`
- adds: 3, calls: 6

