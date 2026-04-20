include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_UserPrefs")
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
include("CivVAccess_PlotSectionsCore")
include("CivVAccess_PlotSectionUnits")
include("CivVAccess_PlotSectionRiver")
include("CivVAccess_PlotComposers")
include("CivVAccess_HexGeom")
include("CivVAccess_Cursor")
-- Surveyor strings before the core so Text.key lookups during module load
-- resolve. BaselineHandler pulls SurveyorCore.getBindings() at create time
-- so the core must be loaded before BaselineHandler is included.
include("CivVAccess_SurveyorStrings_en_US")
include("CivVAccess_SurveyorCore")
include("CivVAccess_BaselineHandler")
-- TypeAheadSearch is the tier/position match primitive ScannerSearch
-- calls when Ctrl+F commits. Menu-backed handlers include it on their
-- own, but the scanner runs without going through BaseMenu.install, so
-- Boot pulls it in before ScannerSearch.
include("CivVAccess_TypeAheadSearch")
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
include("CivVAccess_ScannerSnap")
include("CivVAccess_ScannerSearch")
include("CivVAccess_ScannerInput")
include("CivVAccess_ScannerNav")
include("CivVAccess_ScannerHandler")

-- Boot fires any time a new in-game Context loads, which may include the
-- pre-game setup flow, not just a real loaded game. Civ V runs the entire
-- session on one lua_State, so there's no state-level discriminator.
-- Events.LoadScreenClose is the reliable "we are actually in a game now"
-- signal; defer the in-game boot actions to it.
local function onInGameBoot()
    Log.info("in-game boot")
    HandlerStack.removeByName("Baseline")
    HandlerStack.push(BaselineHandler.create())
    -- Scanner sits directly above Baseline. capturesAllInput=false so
    -- cursor keys fall through unchanged; removeByName before push keeps
    -- Context re-entry idempotent.
    HandlerStack.removeByName("Scanner")
    HandlerStack.push(ScannerHandler.create())
    TickPump.install(ContextPtr)
    Cursor.init()
    SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_BOOT_INGAME"))
end

if Events ~= nil and Events.LoadScreenClose ~= nil then
    -- Guard against multiple in-game contexts each registering a listener
    -- within the same lua_State; civvaccess_shared persists across contexts.
    if not civvaccess_shared.ingameListenerInstalled then
        civvaccess_shared.ingameListenerInstalled = true
        Events.LoadScreenClose.Add(onInGameBoot)
        Log.info("CivVAccess_Boot: registered LoadScreenClose listener")
    end
else
    Log.warn("CivVAccess_Boot: Events.LoadScreenClose missing; in-game boot will not fire")
end
