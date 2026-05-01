# `src/dlc/UI/InGame/CivVAccess_Boot.lua`

226 lines · In-game boot sequence: loads and orders all InGame modules via include(), publishes module refs to civvaccess_shared, and registers a fresh Events.LoadScreenClose listener on every WorldView Context include.

## Header comment

(none)

## Outline

- L1: `include("CivVAccess_Polyfill")`
- L2: `include("CivVAccess_Log")`
- L3: `include("CivVAccess_UserPrefs")`
- L4: `include("CivVAccess_AudioCueMode")`
- L5: `include("CivVAccess_TextFilter")`
- L8: `include("CivVAccess_StringsLoader")`
- L9: `include("CivVAccess_InGameStrings_en_US")`
- L10: `StringsLoader.loadOverlay("CivVAccess_InGameStrings")`
- L11: `include("CivVAccess_PluralRules")`
- L12: `include("CivVAccess_Text")`
- L13: `include("CivVAccess_Icons")`
- L14: `include("CivVAccess_SpeechEngine")`
- L15: `include("CivVAccess_SpeechPipeline")`
- L16: `include("CivVAccess_HandlerStack")`
- L17: `include("CivVAccess_InputRouter")`
- L18: `include("CivVAccess_TickPump")`
- L19: `include("CivVAccess_Nav")`
- L23: `include("CivVAccess_RecommendationsCore")`
- L27: `include("CivVAccess_WaypointsCore")`
- L28: `include("CivVAccess_PlotSectionsCore")`
- L29: `include("CivVAccess_PlotSectionUnits")`
- L30: `include("CivVAccess_PlotSectionRiver")`
- L31: `include("CivVAccess_PlotComposers")`
- L32: `include("CivVAccess_HexGeom")`
- L33: `include("CivVAccess_PlotAudio")`
- L34: `include("CivVAccess_CursorCore")`
- L37: `include("CivVAccess_SurveyorStrings_en_US")`
- L38: `StringsLoader.loadOverlay("CivVAccess_SurveyorStrings")`
- L39: `include("CivVAccess_SurveyorCore")`
- L45: `include("CivVAccess_BaseMenuItems")`
- L46: `include("CivVAccess_TypeAheadSearch")`
- L47: `include("CivVAccess_BaseMenuHelp")`
- L48: `include("CivVAccess_BaseMenuTabs")`
- L49: `include("CivVAccess_BaseMenuCore")`
- L50: `include("CivVAccess_BaseMenuInstall")`
- L51: `include("CivVAccess_BaseMenuEditMode")`
- L52: `include("CivVAccess_Help")`
- L53: `include("CivVAccess_VolumeControl")`
- L54: `include("CivVAccess_Settings")`
- L58: `include("CivVAccess_UnitSpeech")`
- L59: `include("CivVAccess_CitySpeech")`
- L60: `include("CivVAccess_UnitActionMenu")`
- L61: `include("CivVAccess_CursorActivate")`
- L62: `include("CivVAccess_CursorPedia")`
- L63: `include("CivVAccess_UnitTargetMode")`
- L64: `include("CivVAccess_CityRangeStrikeMode")`
- L65: `include("CivVAccess_GiftMode")`
- L66: `include("CivVAccess_UnitControl")`
- L70: `include("CivVAccess_Turn")`
- L71: `include("CivVAccess_EmpireStatus")`
- L72: `include("CivVAccess_HotseatCursorRestore")`
- L73: `include("CivVAccess_TaskList")`
- L74: `include("CivVAccess_BaselineHandler")`
- L78: `include("CivVAccess_ScannerStrings_en_US")`
- L79: `StringsLoader.loadOverlay("CivVAccess_ScannerStrings")`
- L80: `include("CivVAccess_ScannerCore")`
- L81: `include("CivVAccess_ScannerBackendCities")`
- L82: `include("CivVAccess_ScannerBackendUnits")`
- L83: `include("CivVAccess_ScannerBackendResources")`
- L84: `include("CivVAccess_ScannerBackendImprovements")`
- L85: `include("CivVAccess_ScannerBackendSpecial")`
- L86: `include("CivVAccess_ScannerBackendTerrain")`
- L87: `include("CivVAccess_ScannerBackendRecommendations")`
- L88: `include("CivVAccess_ScannerBackendWaypoints")`
- L89: `include("CivVAccess_ScannerSnap")`
- L90: `include("CivVAccess_ScannerSearch")`
- L91: `include("CivVAccess_ScannerInput")`
- L92: `include("CivVAccess_ScannerNav")`
- L93: `include("CivVAccess_ScannerHandler")`
- L97: `include("CivVAccess_Bookmarks")`
- L101: `include("CivVAccess_MessageBuffer")`
- L105: `include("CivVAccess_HotseatMessageBufferRestore")`
- L106: `include("CivVAccess_NotificationAnnounce")`
- L112: `include("CivVAccess_MultiplayerRewards")`
- L113: `include("CivVAccess_MultiplayerTurnEnd")`
- L114: `include("CivVAccess_RevealAnnounce")`
- L115: `include("CivVAccess_ForeignUnitWatch")`
- L116: `include("CivVAccess_ForeignClearWatch")`
- L117: `include("CivVAccess_CombatLog")`
- L118: `include("CivVAccess_CameraTracker")`
- L123: `include("CivVAccess_ChatBuffer")`
- L134: `civvaccess_shared.modules = civvaccess_shared.modules or {}`
- L135: `civvaccess_shared.modules.Cursor = Cursor`
- L136: `civvaccess_shared.modules.ScannerNav = ScannerNav`
- L137: `civvaccess_shared.modules.ScannerHandler = ScannerHandler`
- L138: `civvaccess_shared.modules.SurveyorCore = SurveyorCore`
- L139: `civvaccess_shared.modules.PlotComposers = PlotComposers`
- L140: `civvaccess_shared.modules.HexGeom = HexGeom`
- L141: `civvaccess_shared.modules.CityRangeStrikeMode = CityRangeStrikeMode`
- L142: `civvaccess_shared.modules.GiftMode = GiftMode`
- L143: `civvaccess_shared.modules.UnitControl = UnitControl`
- L153: `local function onInGameBoot()`
- L215: `Events.LoadScreenClose.Add(...)`

## Notes

- L153 `onInGameBoot`: The central game-start initializer; clears mapScope/mapAnnouncer, loads audio, installs Baseline and Scanner at fixed stack positions 1 and 2 (using insertAt, not push), then calls installListeners on every feature module.
- L215 `Events.LoadScreenClose.Add(...)`: Registered without an install-once guard by design; see the block comment explaining why dead-env closures on load-from-game require fresh registration every time.
