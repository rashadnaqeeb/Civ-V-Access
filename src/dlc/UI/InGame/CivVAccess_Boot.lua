include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_UserPrefs")
include("CivVAccess_AudioCueMode")
include("CivVAccess_TextFilter")
include("CivVAccess_InGameStrings_en_US")
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
include("CivVAccess_PlotSectionsCore")
include("CivVAccess_PlotSectionUnits")
include("CivVAccess_PlotSectionRiver")
include("CivVAccess_PlotComposers")
include("CivVAccess_HexGeom")
include("CivVAccess_Pathfinder")
include("CivVAccess_PlotAudio")
include("CivVAccess_Cursor")
-- Surveyor strings before the core so Text.key lookups during module load
-- resolve. BaselineHandler pulls SurveyorCore.getBindings() at create time
-- so the core must be loaded before BaselineHandler is included.
include("CivVAccess_SurveyorStrings_en_US")
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
-- Unit-control modules. UnitSpeech (pure formatters) first so the menu
-- and target-mode modules can reference it; UnitControl last because it
-- ties the others into the listener / bindings surface.
include("CivVAccess_UnitSpeech")
include("CivVAccess_CitySpeech")
include("CivVAccess_UnitActionMenu")
include("CivVAccess_UnitTargetMode")
include("CivVAccess_UnitControl")
-- Turn must load before BaselineHandler so its getBindings() is available
-- when BaselineHandler.create concatenates the binding surface.
include("CivVAccess_Turn")
include("CivVAccess_BaselineHandler")
-- Scanner modules. Strings first so Text.key lookups by Nav / Handler
-- find mod-authored keys. Core registers the backend registry that
-- every ScannerBackend* module self-registers into at load time.
include("CivVAccess_ScannerStrings_en_US")
include("CivVAccess_ScannerCore")
include("CivVAccess_ScannerBackendCities")
include("CivVAccess_ScannerBackendUnits")
include("CivVAccess_ScannerBackendResources")
include("CivVAccess_ScannerBackendImprovements")
include("CivVAccess_ScannerBackendSpecial")
include("CivVAccess_ScannerBackendTerrain")
include("CivVAccess_ScannerBackendRecommendations")
include("CivVAccess_ScannerSnap")
include("CivVAccess_ScannerSearch")
include("CivVAccess_ScannerInput")
include("CivVAccess_ScannerNav")
include("CivVAccess_ScannerHandler")
include("CivVAccess_NotificationAnnounce")

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

-- Boot fires any time a new in-game Context loads, which may include the
-- pre-game setup flow, not just a real loaded game. Civ V runs the entire
-- session on one lua_State, so there's no state-level discriminator.
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
    HandlerStack.removeByName("Baseline")
    HandlerStack.push(BaselineHandler.create())
    -- Scanner sits directly above Baseline. capturesAllInput=false so
    -- cursor keys fall through unchanged; removeByName before push keeps
    -- Context re-entry idempotent.
    HandlerStack.removeByName("Scanner")
    HandlerStack.push(ScannerHandler.create())
    TickPump.install(ContextPtr)
    Cursor.init()
    UnitControl.installListeners()
    Turn.installListeners()
    NotificationAnnounce.install()
    SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_BOOT_INGAME"))
end

if Events ~= nil and Events.LoadScreenClose ~= nil then
    -- Each in-game Context's onInGameBoot closure is bound to that Context's
    -- env, so registering it directly means the listener goes defunct when
    -- the Context tears down on exit-to-main-menu. The next game's Boot
    -- include would then see a "listener already installed" flag and skip
    -- re-registering, leaving the new game with dead bindings.
    -- Pattern from LoadScreenAccess: store the impl on civvaccess_shared so
    -- the current Context always overwrites it, and register one resolver
    -- that reads the shared slot at fire time.
    civvaccess_shared.ingameBootImpl = onInGameBoot
    if not civvaccess_shared.ingameBootListenerInstalled then
        civvaccess_shared.ingameBootListenerInstalled = true
        Events.LoadScreenClose.Add(function()
            local f = civvaccess_shared.ingameBootImpl
            if f == nil then
                return
            end
            local ok, err = pcall(f)
            if not ok then
                Log.error("CivVAccess_Boot: onInGameBoot failed: " .. tostring(err))
            end
        end)
        Log.info("CivVAccess_Boot: registered LoadScreenClose resolver")
    end
else
    Log.warn("CivVAccess_Boot: Events.LoadScreenClose missing; in-game boot will not fire")
end
