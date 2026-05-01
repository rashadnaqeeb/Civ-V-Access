include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_UserPrefs")
include("CivVAccess_AudioCueMode")
include("CivVAccess_TextFilter")
-- StringsLoader before the en_US strings so loadOverlay is callable as
-- soon as the baseline finishes populating CivVAccess_Strings.
include("CivVAccess_StringsLoader")
include("CivVAccess_InGameStrings_en_US")
StringsLoader.loadOverlay("CivVAccess_InGameStrings")
include("CivVAccess_PluralRules")
include("CivVAccess_Text")
include("CivVAccess_Icons")
include("CivVAccess_SpeechEngine")
include("CivVAccess_SpeechPipeline")
include("CivVAccess_HandlerStack")
include("CivVAccess_InputRouter")
include("CivVAccess_TickPump")
include("CivVAccess_Nav")
-- Recommendations Core defines the Recommendations.* helpers that the
-- PlotSections.recommendation Read function invokes, so load it before
-- PlotSectionsCore. The scanner backend further down also uses it.
include("CivVAccess_RecommendationsCore")
-- WaypointsCore feeds PlotSections.waypoint and the waypoints scanner
-- backend; same load-ordering rationale as RecommendationsCore.
include("CivVAccess_WaypointsCore")
include("CivVAccess_PlotSectionsCore")
include("CivVAccess_PlotSectionUnits")
include("CivVAccess_PlotSectionRiver")
include("CivVAccess_PlotComposers")
include("CivVAccess_HexGeom")
include("CivVAccess_PlotAudio")
include("CivVAccess_CursorCore")
-- Surveyor strings before the core so Text.key lookups during module load
-- resolve. BaselineHandler pulls SurveyorCore.getBindings() at create time
-- so the core must be loaded before BaselineHandler is included.
include("CivVAccess_SurveyorStrings_en_US")
StringsLoader.loadOverlay("CivVAccess_SurveyorStrings")
include("CivVAccess_SurveyorCore")
-- BaseMenu family, in the canonical Items / TypeAheadSearch / Help / Tabs
-- / Core / Install / EditMode order used by the other menu-backed Contexts
-- (GameMenuAccess, CivilopediaAccess, SaveMenuAccess, GenericPopupAccess).
-- UnitActionMenu drives a modal via BaseMenu.create; TypeAheadSearch also
-- serves ScannerSearch further down.
include("CivVAccess_BaseMenuItems")
include("CivVAccess_TypeAheadSearch")
include("CivVAccess_BaseMenuHelp")
include("CivVAccess_BaseMenuTabs")
include("CivVAccess_BaseMenuCore")
include("CivVAccess_BaseMenuInstall")
include("CivVAccess_BaseMenuEditMode")
include("CivVAccess_Help")
include("CivVAccess_VolumeControl")
include("CivVAccess_Settings")
-- Unit-control modules. UnitSpeech (pure formatters) first so the menu
-- and target-mode modules can reference it; UnitControl last because it
-- ties the others into the listener / bindings surface.
include("CivVAccess_UnitSpeech")
include("CivVAccess_CitySpeech")
include("CivVAccess_UnitActionMenu")
include("CivVAccess_CursorActivate")
include("CivVAccess_CursorPedia")
include("CivVAccess_UnitTargetMode")
include("CivVAccess_CityRangeStrikeMode")
include("CivVAccess_GiftMode")
include("CivVAccess_UnitControlCore")
-- Turn and EmpireStatus must load before BaselineHandler so their
-- getBindings() are available when BaselineHandler.create concatenates the
-- binding surface.
include("CivVAccess_Turn")
include("CivVAccess_EmpireStatus")
include("CivVAccess_HotseatCursorRestore")
include("CivVAccess_TaskList")
include("CivVAccess_BaselineHandler")
-- Scanner modules. Strings first so Text.key lookups by Nav / Handler
-- find mod-authored keys. Core registers the backend registry that
-- every ScannerBackend* module self-registers into at load time.
include("CivVAccess_ScannerStrings_en_US")
StringsLoader.loadOverlay("CivVAccess_ScannerStrings")
include("CivVAccess_ScannerCore")
include("CivVAccess_ScannerBackendCities")
include("CivVAccess_ScannerBackendUnits")
include("CivVAccess_ScannerBackendResources")
include("CivVAccess_ScannerBackendImprovements")
include("CivVAccess_ScannerBackendSpecial")
include("CivVAccess_ScannerBackendTerrain")
include("CivVAccess_ScannerBackendRecommendations")
include("CivVAccess_ScannerBackendWaypoints")
include("CivVAccess_ScannerSnap")
include("CivVAccess_ScannerSearch")
include("CivVAccess_ScannerInput")
include("CivVAccess_ScannerNav")
include("CivVAccess_ScannerHandler")
-- Bookmarks loads after the scanner: jumpTo calls ScannerNav.markPreJump
-- so backspace returns work. BaselineHandler.create pulls the bindings
-- at LoadScreenClose, which fires after every include here completes.
include("CivVAccess_Bookmarks")
-- MessageBuffer must load before the producers below so their append
-- callsites resolve to the live module. Cleared on every onInGameBoot
-- so a load-from-game session starts with an empty review buffer.
include("CivVAccess_MessageBuffer")
-- HotseatMessageBuffer manipulates civvaccess_shared.messageBuffer on
-- every active-player change, so it loads after MessageBuffer (whose
-- installListeners initializes that slot to nil at boot).
include("CivVAccess_HotseatMessageBufferRestore")
include("CivVAccess_NotificationAnnounce")
-- MP-only fallback: networked multiplayer suppresses three reward popups
-- engine-side, so the standard *PopupAccess wrappers don't fire. This
-- module routes those three events to speech via engine fork hooks
-- (goody hut, barb camp) and Events.NaturalWonderRevealed. No-op in SP
-- and hot seat, where the popup path covers it.
include("CivVAccess_MultiplayerRewards")
include("CivVAccess_MultiplayerTurnEnd")
include("CivVAccess_ForeignUnitSnapshot")
include("CivVAccess_RevealAnnounce")
include("CivVAccess_ForeignUnitWatch")
include("CivVAccess_ForeignClearWatch")
include("CivVAccess_CombatLog")
include("CivVAccess_CameraTracker")
-- ChatBuffer ingests Events.GameMessageChat from WorldView's env so the
-- listener survives load-from-game regardless of DiploCorner child-Context
-- re-init behavior. ChatAccess (in DiploCorner's env) handles the panel
-- UI; both share state via civvaccess_shared._inGameChatLog.
include("CivVAccess_ChatBuffer")

-- Engine fork probe. Several mod features call fork-added Lua bindings
-- bare (no pcall, no feature gate): UnitTargetMode does GeneratePath /
-- GetPath / GetBestBuildRoute / HasLineOfSight; UnitControlMovement does
-- GeneratePath; UnitControlSelection does Game.GetCycleUnits; etc. On a
-- vanilla DLL deploy (e.g. ./deploy.ps1 -SkipEngine on a fresh install,
-- or a sighted MP partner machine that hasn't been deployed against)
-- those calls raise method-not-found errors that the engine's per-
-- listener catch swallows -- the user gets no speech with no log line
-- unless LoggingEnabled=1. This probe runs once per WorldView Context
-- include and emits one line so a contributor reading Lua.log sees the
-- missing-fork case immediately. Game methods are the canary: if they're
-- present, the fork is deployed and the Unit / Plot bindings resolve too.
if Game ~= nil then
    if Game.GetBuildRoutePath ~= nil and Game.GetCycleUnits ~= nil then
        Log.info("CivVAccess_Boot: engine fork bindings present")
    else
        Log.warn("CivVAccess_Boot: engine fork DLL not deployed -- "
            .. "move-target preview, build-route preview, ranged-strike "
            .. "LoS, and unit cycler will silently fail. "
            .. "Run ./deploy.ps1 (without -SkipEngine) to install.")
    end
end

-- Publish mod modules to other in-game Contexts. Civ V sandboxes Lua
-- globals per Context, so the modules loaded above are invisible in
-- CityView / popup / sub-screen Contexts even though they share a
-- lua_State. civvaccess_shared is the engine-wide bridge (proxy-injected
-- into every Context's globals); storing the module tables on it gives
-- other Contexts the same singleton handles rather than forcing them to
-- re-include and fragment state (Cursor._x, ScannerNav._snapshot, etc.).
-- Consumers capture refs into locals at file-scope and nil-guard the
-- value in case Boot hasn't completed (edge: pre-game setup Context).
civvaccess_shared.modules = civvaccess_shared.modules or {}
civvaccess_shared.modules.Cursor = Cursor
civvaccess_shared.modules.ScannerNav = ScannerNav
civvaccess_shared.modules.ScannerHandler = ScannerHandler
civvaccess_shared.modules.SurveyorCore = SurveyorCore
civvaccess_shared.modules.PlotComposers = PlotComposers
civvaccess_shared.modules.HexGeom = HexGeom
civvaccess_shared.modules.CityRangeStrikeMode = CityRangeStrikeMode
civvaccess_shared.modules.GiftMode = GiftMode
civvaccess_shared.modules.UnitControl = UnitControl

-- Boot fires any time the WorldView Context loads (our override of
-- WorldView.lua includes this file). That happens on fresh-game load,
-- on load-game-from-game (WorldView is one of the Contexts the engine
-- reliably re-initializes in that flow, unlike TaskList), and also
-- during the pre-game setup flow. Civ V runs the entire session on one
-- lua_State, so there's no state-level discriminator.
-- Events.LoadScreenClose is the reliable "we are actually in a game now"
-- signal; defer the in-game boot actions to it.
local function onInGameBoot()
    Log.info("in-game boot")
    -- Defensive: clear scoped-cursor hooks in case a prior session (same
    -- lua_State, different game via main-menu exit / reload) left them set
    -- through an aborted sub-handler push. A dangling mapScope would reject
    -- every Cursor.move with "edge of range" until this Context reloads.
    civvaccess_shared.mapScope = nil
    civvaccess_shared.mapAnnouncer = nil
    PlotAudio.loadAll()
    -- Apply persisted master volume now that the proxy's audio engine is
    -- initialized. Setting before loadAll would be a silent no-op.
    VolumeControl.restore()
    TaskList.resetForNewGame()
    -- Bookmarks are session-only and tied to the active map's geometry;
    -- a different game has different cells under those (x, y) pairs.
    Bookmarks.resetForNewGame()
    -- Baseline and Scanner are the floor of the in-game stack: Baseline
    -- owns map / unit / turn keys and is the capturesAllInput barrier;
    -- Scanner sits one above for category cycling. They are not modal
    -- pushes, so they go in at positions 1 and 2 rather than on top.
    -- This matters when a popup pushed itself before LoadScreenClose
    -- fired: hotseat's PlayerChange shows during the load-screen-to-game
    -- transition and is on the stack by the time this listener runs.
    -- push would bury PlayerChange (Scanner becomes active and its
    -- bindings reach InputRouter first; PlayerChange's Esc / Enter / item
    -- bindings never fire). insertAt at the bottom keeps PlayerChange on
    -- top where it belongs. removeByName first clears the prior game's
    -- dead-env Baseline / Scanner closures on a load-from-game transition.
    HandlerStack.removeByName("Baseline")
    HandlerStack.removeByName("Scanner")
    HandlerStack.insertAt(BaselineHandler.create(), 1)
    HandlerStack.insertAt(ScannerHandler.create(), 2)
    TickPump.install(ContextPtr)
    Cursor.init()
    UnitControl.installListeners()
    Turn.installListeners()
    HotseatCursor.installListeners()
    MessageBuffer.installListeners()
    HotseatMessageBuffer.installListeners()
    NotificationAnnounce.install()
    MultiplayerRewards.installListeners()
    MultiplayerTurnEnd.installListeners()
    RevealAnnounce.installListeners()
    ForeignUnitWatch.installListeners()
    ForeignClearWatch.installListeners()
    CombatLog.installListeners()
    CameraTracker.install()
    ChatBuffer.installListeners()
    SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_BOOT_INGAME"))
end

-- Register a fresh LoadScreenClose listener on every Boot include. WHY
-- not install-once: Civ V clears the env table of every Context on
-- load-game-from-game (every global, including engine builtins like
-- `UI`, becomes nil to closures still holding that env). A listener
-- registered in a prior game is stranded with a dead env and silently
-- throws on its first global access. The civvaccess_shared flag
-- protecting it would stay true (civvaccess_shared itself is a shared
-- table that survives), so an install-once guard would block the new
-- Context from ever registering a live listener. Dead listeners
-- accumulate (Events.X.Remove is unverified), but the engine catches
-- per-listener throws so the live one still runs.
if Log.installEvent(Events, "LoadScreenClose", function()
    local ok, err = pcall(onInGameBoot)
    if not ok then
        Log.error("CivVAccess_Boot: onInGameBoot failed: " .. tostring(err))
    end
end, "CivVAccess_Boot", "in-game boot will not fire") then
    Log.info("CivVAccess_Boot: registered LoadScreenClose listener")
end
