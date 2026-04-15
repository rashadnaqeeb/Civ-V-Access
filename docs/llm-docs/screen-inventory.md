# Civilization V UI Screen Inventory

This is a map, not deep documentation. Each entry gives the bare stem (the name `include("Foo")` and Civ's VFS resolve), a one-line purpose, which DLC overrides exist, and the top-level interactive controls. "Overrides" means the same stem also appears under `DLC/Expansion/UI` (G&K) or `DLC/Expansion2/UI` (BNW) and shadows the base file at runtime; unless explicitly noted, the override is structurally similar to the base version.

Paths below are relative to `C:\Program Files (x86)\Steam\steamapps\common\Sid Meier's Civilization V\Assets\`. Where a file exists only in an expansion, that is called out. The `_small` XML variants are alternate layouts selected by resolution and share the same Lua. The ContextPtr's identity for lookup purposes is the filename stem; XML root `ID=` attributes are unreliable and have been omitted.

## FrontEnd — Main Menu, Setup, Load

Base entry points and confirmation dialogs.

- `FrontEnd` (UI/FrontEnd/FrontEnd.xml) — top-level FrontEnd context, hosts logo/animation, no direct controls.
- `MainMenu` (UI/FrontEnd/MainMenu.xml, G&K override) — Single Player, Multiplayer, Mods, Options, Other, ExpansionRulesSwitch, Exit, plus promo buttons.
- `SinglePlayer` (UI/FrontEnd/SinglePlayer.xml, G&K override) — StartGame, GameSetup, LoadGame, Scenarios, LoadTutorial, Back.
- `OtherMenu` (UI/FrontEnd/OtherMenu.xml, G&K override) — LatestNews, Civilopedia, HallOfFame, ViewReplays, Credits, Leaderboard, Back.
- `PreGameScreen` — placeholder with LeaderButton, BackButton.
- `PremiumContentMenu` — DLC/expansion enable toggles (EnableDLC, DisableExpansion1, etc.), LargeButton launch.
- `ExitConfirm` — yes/no dialog for quitting.
- `FrontEndPopup` — generic modal popup in front-end context; CloseButton.
- `Credits` (G&K override XML only) — scrolling credits with BackButton.
- `LegalScreen` (G&K override XML only) — ContinueButton past legalese.
- `LoadScreen` (BNW override XML only) — splash between frontend and ingame, ActivateButton.
- `LoadTutorial` — tutorial list with Start/Learn/Back.
- `WaitingForPlayers` — MP waiting splash.
- `ContentSwitch` — mod/DLC content swap confirmation.
- `GridExamples` and `UITestMenu` — developer test/demo screens (PullDown, EditBox, Sliders).
- `ToolTips` — registers reusable tooltip templates, no visible controls.
- `ScenariosMenu` — scenarios list launcher.

### Setup (single-player)

- `GameSetupScreen` — top-level quick setup. Randomize, Advanced, Back, Start, Civilization, MapType, MapSize, Difficulty, GameSpeed buttons and ScenarioCheck.
- `AdvancedSetup` (G&K override XML only) — full customization. CivPulldown, TeamPullDown, RemoveButton, per-option CheckBox/PullDown trees, MinorCivsSlider, MaxTurnsCheck.
- `SelectCivilization`, `SelectDifficulty`, `SelectGameSpeed`, `SelectMapSize`, `SelectMapType` — pickers launched from GameSetupScreen.
- `SetCivNames` — pre-game custom civ name/password editor (all EditBoxes).
- `WorldPicker` — world-size selector with one button per size.
- `UniqueBonuses` — Lua-only helper for displaying civ uniques in setup.

### Multiplayer

- `MultiplayerSelect` (G&K override XML only) — Internet/LAN/HotSeat/Pitboss/Reconnect/Back.
- `Lobby` — server browser. Host/Join/Refresh, Sort-by buttons, ConnectIPEdit, ListTypePulldown.
- `JoiningRoom` — transient connecting screen.
- `StagingRoom` — pre-game lobby. InvitePulldown, CivPulldown, TeamPulldown, SlotTypePulldown, HandicapPulldown, Kick/Swap, LockCheck, EnableCheck.
- `MPGameSetupScreen` — MP variant of AdvancedSetup with TurnModePull, TurnTimerCheck/Edit, MaxTurnsCheck/Edit.
- `MPGameDefaults`, `MPGameOptions` — Lua-only helpers for MP defaults/option data.
- `DedicatedServer` — pitboss control screen (Lua-heavy, few top-level controls).

### Mods

- `ModsMenu` (G&K override XML only) — Single/Multi/Back.
- `ModsSinglePlayer` / `ModsMultiplayer` (G&K override XML only) — mirrors of the non-mod menus but operating on enabled mods.
- `ModsBrowser` — Steam Workshop browser. SmallButton1/2, LargeButton, Back.
- `InstalledPanel` — installed mods list. EnableButton, DisableButton, UpdateButton, OptionsButton, SortByName/Enabled, DeleteUserData, ShowDLCMods, OptionsOK.
- `ModsError` — error popup with OKButton.
- `CustomMod` — custom mod start flow (Start/Back).
- `EULA` (G&K override XML only) — Decline/Accept.

### Replays / Hall of Fame

- `LoadMenu` — saved game loader; Delete, Back, Start, AutoCheck, CloudCheck, SortByPullDown, ShowDLC/Mods toggles.
- `LoadReplayMenu` — sibling for replays; SelectReplayButton.
- `HallOfFame` — past-game list with BackButton.
- `Leaderboard` — online leaderboards. Friends/Personal/Global, LeaderboardPull, Refresh, Back.
- `ReplayViewer` — replay playback, same stem in-game. ShowHide, ReplayInfoPulldown, GraphDataSetPulldown, TurnSlider, PlayPauseButton.

## InGame — HUD, World View, Top Bar

The permanent visible UI during play.

- `InGame` (UI/InGame/InGame.xml, G&K and BNW overrides) — root InGame context, hosts Scroll buttons and imports most other panels. This is the parent screen most popups reparent under.
- `WorldView` (G&K and BNW overrides) — world interaction Lua driving hex input; XML is mostly structural.
- `TopPanel` (G&K and BNW overrides) — the top status bar. SciencePerTurn, GoldPerTurn, InternationalTradeRoutes, HappinessString, GoldenAgeString, CultureString, TourismString (BNW), FaithString (G&K+), ResourceString, UnitSupplyString, MenuButton, CivilopediaButton. All TextButton — they are the primary clickable readouts.
- `DiploCorner` (G&K and BNW overrides) — the persistent chat/diplomacy corner. ChatPull, ChatEntry, DiploButton, CultureOverviewButton, SocialPoliciesButton, EspionageButton, MultiPull, ChatToggle, MPInvite, EndGameButton.
- `MiniMapPanel` (G&K XML-only override, BNW full override) — minimap and overlays. OverlayDropDown, IconDropDown, ShowFeatures/ShowFogOfWar/HideRecommendation/ShowResources/ShowYield/ShowGrid/ShowTrade checkboxes, StrategicViewButton, MapOptionsButton.
- `ActionInfoPanel` (G&K and BNW overrides) — the End Turn button/action status. EndTurnButton (GridButton).
- `UnitPanel` (G&K and BNW overrides) — selected-unit panel. UnitActionButton, EditButton (rename), RecommendedActionButton, PromotionButton, UnitNameButton, CycleLeft, CycleRight, plus TextButton stat readouts (Movement, Strength, RangedAttack).
- `EnemyUnitPanel` (G&K and BNW overrides) — hover preview of foreign unit/tile (display-only).
- `Advisors` (base only) — floating advisor prompt. Question1..Question4, AdvisorDismissButton, ActivateButton, DontShowAgainCheckbox.
- `InfoCorner` (root `UnitList`) — collapsible info panel host. LeftPull, PDButton.
- `CityList` — cities list sidebar. SortPopulation, SortCityName, SortStrength, SortProduction, OpenEconButton, ProdButton, CityRangeStrikeAnim, Close.
- `UnitList` (BNW Lua override) — units list sidebar. SortName, SortStatus, SortMovement, OpenOverviewButton, Close.
- `GPList` (G&K and BNW overrides) — Great People progress list. SortCity, SortTurns, per-type toggles (Artist/Engineer/Merchant/Musician/Scientist/Writer), Close.
- `ResourceList` — strategic/luxury/bonus list. SortName, SortTradeInfo, LuxuryToggle, StrategicToggle, BonusToggle.
- `DiploList` (G&K and BNW overrides) — known-civs list. ScoreBox, MajorButton/MinorButton filters, DiplomaticOverviewButton, LeagueOverviewButton, LeaderButton, WarButton, QuestIcon, Close, Yes/No.
- `NotificationPanel` (G&K and BNW overrides) — the notification stack on the right. Many typed buttons: CityStateButton, MetCityStateButton, CityStateRequest, PeaceOtherButton, WarOtherButton, EnemyInTerritoryButton, GenericButton, PantheonFoundedButton, ReligionFoundedButton, ReligionEnhancedButton, ReformationBeliefAddedButton, EnoughFaithButton (and many more of the same pattern).
- `TechPanel` (G&K and BNW overrides) — compact current-research panel. TechButton, BigTechButton, B1..B5 free-tech slots.
- `CityBannerManager` (G&K and BNW overrides) — on-world city labels. BannerButton, CityBannerProductionButton, EjectGarrison, CityRangeStrikeButton.
- `UnitFlagManager` (G&K and BNW Lua overrides) — on-world unit icons. MajorButton, NormalButton, HealthBarButton.
- `ResourceIconManager` / `YieldIconManager` (G&K and BNW overrides for Yield) — world-layer icon painters, display-only.
- `PlotHelpManager` (BNW Lua override) — hex tooltip popup. TheBox.
- `PlotHelpText` (BNW Lua override) — text-only tooltip variant.
- `PathHelpManager` — pathing/movement tooltip.
- `PlotMouseoverInclude` (G&K and BNW overrides) — include file, no controls (mouseover helper logic).
- `InfoTooltipInclude` (G&K and BNW overrides) — include file with the big tooltip generator for units/buildings.
- `ResourceTooltipGenerator` (Lua-only) — resource tooltip helper.
- `GenericWorldAnchor` (G&K and BNW Lua overrides) — anchors UI to world positions.
- `UnitMemberOverlay` — per-unit combat overlay.
- `Bombardment` (Lua-only) — artillery/ranged visual feedback.
- `FluidFOW` — fog-of-war tuning debug panel.
- `MPList` — MP player list overlay. Kick, DiploWaiting.
- `MPTurnPanel` — MP turn timer. EndTurnTimerButton.
- `Tutorial` — tutorial overlays; TutorialTextBox.
- `NewTurn`, `TurnProcessing` — brief animated overlays between turns (no controls).
- `ChangePassword`, `PlayerChange` — hotseat password and player-swap screens. EditBoxes and Continue/ChangePassword/Save/MainMenu.
- `SetCityName`, `SetUnitName` — in-world rename prompts (EditBox + Accept/Cancel).
- `TaskList` — objective list label (display-only).
- `ColorKey`, `DebugMenu`, `DebugMode`, `GraphicsPanel`, `HexDebugTextPanel`, `NetworkDebug`, `TerrainPanel` — in-game developer/debug panels. Most users never see these; they are wired up through `DebugMenu`. Useful to know they exist so we do not accidentally announce them.
- `LeaderViewer`, `LeaderViewerHidden` — leader model viewer (dev tool; QuitButton, LoadLeaderButton, ChangeLeaderButton, skin/DOF/glow toggles).
- `TouchControlsMenu` — touch-input help (DontShowAgainCheckbox).

## City Screen

- `CityView` (G&K and BNW overrides) — the full city panel. Dozens of per-building b#up/b#down/b#remove buttons (one per building slot), ProductionPortraitButton, and the whole production/yield/citizen layout. BNW layer adds the great-works and tourism bits. The `_small` XML variant is resolution-specific.

## Diplomacy and LeaderHead

- `LeaderHeadRoot` (G&K and BNW overrides) — the leader diplomacy root. BackButton, DiscussButton, DemandButton, TradeButton, WarButton.
- `DiscussLeader` (base only) — option menu: Opinion, Like, Dislike, Attack, Back.
- `DiscussionDialog` (G&K and BNW overrides) — multi-button dialog (Button1..Button8), CloseLeaderPanel, DenounceConfirmYes/No.
- `DiploTrade` (G&K and BNW XML-only overrides) — full trade UI. AmountEdit, UsPocket/ThemPocket buttons for Gold, GoldPerTurn, Luxury, Strategic, Vote, AllowEmbassy, OpenBorders, DefensivePact, etc.
- `SimpleDiploTrade` (G&K XML-only and BNW XML-only overrides) — condensed trade variant with the same pocket/table structure.
- `TradeLogic` (G&K and BNW Lua overrides) — include file driving trade state, no controls.
- `DiploOverview` (G&K and BNW XML-only overrides) — overview tabs. RelationsButton, DealsButton, GlobalPoliticsButton, Close.
- `DiploRelationships` (G&K and BNW overrides) — civ relations tab. DiploButton, LeaderButton.
- `DiploGlobalRelationships` (base plus BNW Lua-only override) — global-politics tab.
- `DiploCurrentDeals` (G&K and BNW XML-only overrides) — current/historic deals. CurrentDealsButton, HistoricDealsButton, plus per-category pocket toggles mirroring DiploTrade.

## Tech Tree

- `TechTree` (G&K and BNW split: XML under InGame/TechTree, Lua under TechTree/) — the full tree. CloseButton, TechButton, B1..B5 free-tech indicators. Note: BNW has its own `DLC/Expansion2/UI/TechTree/TechTree.lua` (different folder, same stem).
- `TechPopup` (G&K and BNW overrides) — "choose next tech" popup. TechButton, B1..B5, OpenTTButton.
- `TechButtonInclude` (G&K and BNW overrides) — shared tech-button rendering helper; no standalone UI.
- `TechHelpInclude` (BNW override) — tech tooltip helper.

## Civilopedia

- `CivilopediaScreen` (G&K and BNW overrides) — the pedia. ListItemButton, ListHeadingButton, PrereqTechButton, LeadsToTechButton, ObsoleteTechButton, UpgradeButton, RevealTechButton, UnlockedUnitButton, UnlockedBuildingButton, RequiredBuildingButton, RevealedResourceButton, RequiredResourceButton (and more — it is highly dynamic).

## Options

- `OptionsMenu` — tabbed options. GameButton, IFaceButton, VideoButton, AudioButton, MultiplayerButton tabs; Tooltip1TimerSlider, Tooltip2TimerSlider, TutorialPull, ResetTutorialButton, SinglePlayerAutoEndTurnCheckBox, MultiplayerAutoEndTurnCheckbox, SPQuickCombatCheckBox (and a long list of video/audio/interface toggles beyond the 12-item cap).
- `GameMenu` (G&K and BNW XML-only overrides) — in-game pause menu. RestartGameButton, QuickSaveButton, SaveGameButton, LoadGameButton, OptionsButton, RetireButton, MainMenuButton, ExitGameButton, ReturnButton, DetailsButton, ModsButton, Yes confirm.
- `SaveMenu` — in-game save. NameBox EditBox, SaveButton, Delete, BackButton, SaveMapButton, CloudCheck, Yes/No.
- `SaveMapMenu` — map save variant without CloudCheck.

## Popups — Generic

- `GenericPopup` — Button1..Button4 plus CloseButton.
- `TextPopup` — message-only popup; CloseButton (and `TextPopup_small` variant).
- `EmptyPopup` — blank template.
- `AdvisorInfoPopup` (G&K and BNW XML-only overrides) — pre-game advisor info. Forward, Back, Civilopedia, Civilopedia_List, Close.
- `AdvisorCounselPopup` (G&K and BNW XML-only overrides) — advisor counsel. Prev/Next per category (Economic, Military, Foreign, Science), Close.
- `AdvisorModal` — modal advisor prompt. ConfirmButton, CancelButton, DontShowAgainCheckbox.
- `NotificationLogPopup` (G&K and BNW XML-only overrides) — past notifications list. GenericButton, Close.

## Popups — Combat, Diplomacy, Generic Game Prompts

The `PopupsGeneric/` directory holds Lua-only popups that reuse `GenericPopup.xml`. They have no XML of their own, so the ContextPtr ID comes from GenericPopup; identify them by stem.

- `AnnexCityPopup`, `PuppetCityPopup` (G&K and BNW Lua overrides) — after capturing a city.
- `CityPlotManagementPopup` — manual tile work assignments.
- `ConfirmCityTaskPopup`, `ConfirmCommandPopup`, `ConfirmGiftPopup`, `ConfirmImprovementRebuildPopup` (BNW Lua override), `ConfirmPolicyBranchPopup` — confirm-an-action popups.
- `DeclareWarMovePopup` (G&K and BNW Lua overrides) — move that starts a war.
- `DeclareWarRangeStrikePopup` (BNW Lua override) — range strike starts war.
- `DeclareWarPlunderTradeRoutePopup` (BNW only) — plunder a trade route.
- `DeclareWarPopup` (BNW only, has XML) — full declaration screen with DiplomacyHeader, UnderProtectionOfHeader, AlliedCityStatesHeader, ActiveDealsHeader, TradeRoutesHeader, Button1, Button2.
- `BarbarianRansomPopup`, `MinorCivEnterTerritoryPopup`, `MinorCivGoldPopup`, `LiberateMinorPopup`, `ReturnCivilianPopup`, `NetworkKickedPopup` — one-off prompts.

## Popups — Choosers

- `ChooseFreeItem` (G&K and BNW Lua overrides) — "pick one" popup. ConfirmButton, Close.
- `ProductionPopup` (G&K and BNW overrides) — production chooser. UnitButton, BuildingsButton, WondersButton, OtherButton, ProduceResearchButton, ProduceGoldButton, plus BNW ProduceLeagueProject buttons and ResearchQMiniButton/WealthQMiniButton shortcuts.
- `SocialPolicyPopup` (G&K XML-only and BNW full overrides) — policy/ideology chooser. PolicyIcon, TenetButton, TabButtonSocialPolicies, TabButtonIdeologies, PolicyInfo, BranchButton0..8, ToIdeologyTab.
- `ChoosePantheonPopup` (G&K and BNW overrides) — pick a pantheon. CloseButton, Yes, No.
- `ChooseReligionPopup` (G&K and BNW overrides) — found/enhance religion. LabelReligionName, PantheonBelief/FounderBelief/FollowerBelief/FollowerBelief2/EnhancerBelief/BonusBelief buttons, FoundReligion, NewName EditBox, Close.
- `ChooseFaithGreatPerson` (G&K and BNW overrides) — buy a great person with faith. ConfirmButton.
- `ChooseMayaBonus` (G&K and BNW overrides) — Maya b'ak'tun picker.
- `ChooseIdeologyPopup` (BNW only) — pick an ideology. ShowTenets, Level1TenetsHeader/Level2/Level3, ViewTenetsCloseButton, ConfirmYes, ConfirmNo.
- `ChooseGoodyHutReward` (BNW only) — BNW variant of goody-hut choice.
- `ChooseAdmiralNewPort` (BNW only) — pick a new admiral home. GoToCity, ConfirmYes, ConfirmNo.
- `ChooseArchaeologyPopup` (BNW only) — archaeology dig result. GreatArtifactIcon, GreatArtifactWritingIcon, ViewButton, ConfirmYes, ConfirmNo.
- `ChooseInternationalTradeRoutePopup` (BNW only) — trade-route picker. GoToCity, TradeOverviewButton, SortByPullDown, YourCitiesHeader, MajorCivsHeader, CityStatesHeader, ConfirmYes, ConfirmNo.
- `ChooseTradeUnitNewHome` (BNW only) — rebase trade unit. GoToCity, TradeOverviewButton, ConfirmYes, ConfirmNo.
- `GreatPersonRewardPopup` (G&K and BNW XML-only overrides) — display-only great-person banner.
- `GreatWorkPopup` (BNW only) — great work display popup.

## Popups — City-State, League, Diplomacy

- `CityStateGreetingPopup` (G&K and BNW overrides) — first-meet greeting. ScreenButton, Close, FindOnMapButton. The `CityStateGreetingPopupOpenCenter.xml` is an alternate XML layout reused by the same Lua.
- `CityStateDiploPopup` (G&K and BNW overrides) — full CS diplo. QuestInfo, PeaceButton, GiveButton, PledgeButton, RevokePledgeButton, TakeButton, WarButton, NoUnitSpawningButton, BuyoutButton, Small/Medium/Large GiftButton.
- `CityStateStatusHelper` (G&K and BNW Lua-only) — quest/CS status helper, no UI.
- `DiploVotePopup` (G&K and BNW overrides) — UN/world congress vote. Close.
- `VoteResultsPopup` (G&K and BNW overrides) — vote result readout. Close.
- `LeagueSplash` (BNW only) — league founded/meeting splash. Close.
- `LeagueOverview` (BNW only) — World Congress main screen. ResolutionButton, VoteUpButton, VoteDownButton, ResolutionChoiceButton, RenameButton, TurnsUntilVoteFrame, LeaderButton, MemberButton1..4+ per seat.
- `LeagueProjectPopup` (BNW only) — international project UI. Close.
- `TradeRouteOverview` (BNW only) — trade routes overview. TabButtonYourTR/AvailableTR/TRWithYou, Domain filter, sort headers FromOwner/FromCity/ToOwner/ToCity/FromGPT/ToGPT/FromScience/ToScience.
- `TradeRouteHelpers` (BNW Lua-only) — trade UI helpers, no controls.
- `EspionageOverview` (G&K and BNW overrides) — spies screen. ViewCityButton, StageCoupButton, RelocateButton, CitySelectButton, TabButtonOverview, TabButtonIntrigue, sort headers (Name/Rank, Location, Activity), UnassignButton, Cancel.
- `ReligionOverview` (G&K and BNW overrides) — religion screen. TabButtonYourReligion, TabButtonWorldReligions, TabButtonBeliefs, AutomaticPurchasePD, sort headers for world-religions and beliefs.
- `CultureOverview` (BNW only) — culture/great-works. Per-wonder GreatWork slot buttons, WonderButton.

## Popups — Information / Overviews

- `EconomicOverview` (G&K and BNW XML-only overrides) — GeneralInfoButton, HappinessButton, Close.
- `EconomicGeneralInfo` (G&K and BNW overrides) — sort headers (Population, CityName, Strength, Food, Research, Gold, Culture, Faith, Production), CityToggle, TradeToggle, BuildingsToggle.
- `HappinessInfo` (G&K and BNW overrides) — happiness breakdown toggles (Luxury, LocalCity, CityBuilding, TradeRoute, CityUnhappiness, ResourcesAvailable/Imported/Exported/Local).
- `MilitaryOverview` (G&K and BNW overrides) — unit list. Sort by Name/Status/Movement/Moves/Strength/Ranged, Close, GP/GA icons.
- `Demographics` (G&K and BNW XML-only overrides) — demographics table, BackButton only.
- `Ranking` — ranking graph/table (display-only).
- `VictoryProgress` (G&K and BNW overrides) — victory progress tabs. ScoreDetails, SpaceRaceClose, DiploClose, ScoreClose, SpaceRaceDetails, Back.
- `WhosWinningPopup` (G&K XML-only and BNW full override) — diplo-victory summary. Close.
- `EndGameMenu` (G&K and BNW XML-only overrides) — after-game screen. GameOverButton, DemographicsButton, RankingButton, ReplayButton, MainMenuButton, BackButton, BeyondButton ("one more turn").
- `EndGameReplay` (base only) — replay viewer launched from end-game.

## Popups — World Events

- `BarbarianCampPopup` (G&K and BNW XML-only overrides) — Close only.
- `GoodyHutPopup` (G&K and BNW overrides) — Close only (base game pre-BNW handled choice here; BNW moved to ChooseGoodyHutReward).
- `NaturalWonderPopup` (G&K and BNW overrides) — Close only.
- `NewEraPopup` (G&K and BNW overrides) — Close only.
- `GoldenAgePopup` (G&K and BNW XML-only overrides) — Close only.
- `TechAwardPopup` (G&K and BNW XML-only overrides) — awarded-tech display. Close, Continue, B1..B5.
- `WonderPopup` (G&K and BNW XML-only overrides) — wonder-built splash. Close.

## Support / Include Files (not screens)

These have no UI but are included into other contexts and worth knowing by stem because `include()` pulls them in:

- `CommonBehaviors` — UI handler helpers, InputHandler plumbing.
- `SupportFunctions` — misc helpers.
- `IconSupport` — icon atlas lookups.
- `InstanceManager` — dynamic instance-of-XML-template manager (used everywhere lists are built).
- `TurnStatusBehavior` — end-turn button state machine.
- `TechButtonInclude`, `TechHelpInclude`, `InfoTooltipInclude`, `PlotMouseoverInclude` — the `*Include` family, shared helpers pulled into the top-level panels.
- `ResourceTooltipGenerator`, `TradeLogic`, `TradeRouteHelpers`, `CityStateStatusHelper`, `MPGameDefaults`, `MPGameOptions`, `UniqueBonuses` — domain-specific Lua-only helpers.
- `ColorAtlas`, `ColorAtlas_Expansion2`, `Styles`, `Styles_Expansion1`, `Styles_Expansion2`, `ArrowSettings` — XML-only style/data files, no context.

## Notes on Overrides

Civ V's VFS resolves `include("Foo")` to whichever `Foo.lua` has highest DLC priority; loaded mods override DLC, DLC overrides base. The pattern across these files:

- Base game ships the full set.
- G&K (`DLC/Expansion/UI`) overrides screens that gained religion and espionage plumbing (`CityView`, `CityBannerManager`, `TopPanel`, `LeaderHeadRoot`, `DiploList`, `TechPanel`, `TechPopup`, `NotificationPanel`, `UnitPanel`, `CityStateDiploPopup`, `HappinessInfo`, `EconomicGeneralInfo`, `ProductionPopup`, `DiploRelationships`, `DiploVotePopup`, `VoteResultsPopup`, `VictoryProgress`, `GoodyHutPopup`, `NaturalWonderPopup`, `NewEraPopup`, `MilitaryOverview`, `DiscussionDialog`). Most DLC override XMLs are structural re-layouts; the Lua overrides add logic for religion/espionage. Some overrides are XML-only (no Lua change); a few are Lua-only. Always check both.
- BNW (`DLC/Expansion2/UI`) adds trade, ideology, world congress, great works, archaeology, and tourism. It overrides most G&K files and adds the new chooser popups, `CultureOverview`, `LeagueOverview`/`LeagueProjectPopup`/`LeagueSplash`, `TradeRouteOverview`, `DiploGlobalRelationships`, `DeclareWarPopup`, `GreatWorkPopup`, `PlotHelpManager`, `PlotHelpText`, and `UnitList` Lua.
- `TechTree` is unusual: base ships Lua and XML under `UI/InGame/TechTree/`, but G&K/BNW ship the Lua under `DLC/Expansion{,2}/UI/TechTree/` (no `InGame/` segment) while keeping the XML under the `InGame/TechTree/` path. Since VFS keys on stem only, all three versions collide by name and DLC priority wins.

## Unusual Finds

- Many popups under `PopupsGeneric/` are Lua-only and reuse `GenericPopup.xml` at runtime — they will never show up in an XML grep for their stem.
- The mod screens (`ModsMenu`, `ModsSinglePlayer`, `ModsMultiplayer`, `EULA`, `MainMenu`, `Credits`, `LegalScreen`, `SinglePlayer`, `OtherMenu`, `MultiplayerSelect`, `AdvancedSetup`) have G&K XML-only overrides — the base Lua still runs, just against a re-laid-out XML tree. Control IDs are stable across the pair.
- A handful of debug/dev screens exist that shipped with the game: `DebugMenu`, `DebugMode`, `GraphicsPanel`, `HexDebugTextPanel`, `TerrainPanel`, `FluidFOW`, `ColorKey`, `NetworkDebug`, `UITestMenu`, `GridExamples`, `LeaderViewer`, `LeaderViewerHidden`. They are normally hidden but reachable via key bindings.
- `TechTree` is the only screen split across two different folder paths in the same DLC (see above).
- `CityStateGreetingPopupOpenCenter.xml` is an alternate layout with no Lua of its own — its Lua counterpart is `CityStateGreetingPopup.lua`.
- `_small` XML variants (`CityView_small`, `TechPanel_small`, `TechPopup_small`, `TextPopup_small`, `EnemyUnitPanel_small`, `UnitPanel_small`) are resolution alternates; they share Lua with their non-`_small` sibling and load conditionally.
