-- luacheck config for Civ-V-Access.
-- Run from the repo root:  luacheck src tests
-- Civ V's embedded Lua is 5.1; keep std to that.

std          = "lua51"
codes        = true       -- include W-codes in output so warnings can be ignored precisely
max_line_length = false   -- Civ V UI Lua has long localized strings; line length isn't useful here
cache        = true       -- stash results under .luacheckcache

-- Global ignores:
--   212  unused argument. Civ V UI callbacks (ShowHideHandler(bIsHide,bIsInit),
--        widget callbacks (self,menu), RegisterCallback(void1,void2)) have
--        engine-fixed signatures; a no-op handler that receives but ignores
--        its args is the norm, not a bug. W211 (unused local variables and
--        functions) stays active, which is where the real dead-code signal is.
ignore = { "212" }

-- Engine globals. The game injects these into every UI Lua context. They are
-- effectively read-only from mod code; assigning to them would replace the
-- engine table, so treat assignments as warnings.
read_globals = {
    -- Context + control tree
    "ContextPtr", "Controls",

    -- Event buses (both expose .Add / .Remove)
    "Events", "LuaEvents",

    -- Localization
    "Locale", "L",

    -- UI surface
    "UI", "UIManager", "InstanceManager",

    -- Input
    "Mouse", "Keys", "InputTypes",

    -- Game world
    "Game", "Map", "Players", "Teams",
    "GameInfo", "GameInfoTypes", "GameDefines", "PreGame",

    -- Enums
    "DirectionTypes", "PlotTypes", "FeatureTypes", "TerrainTypes",
    "ResourceTypes", "ResourceUsageTypes", "ImprovementTypes",
    "RouteTypes", "YieldTypes",
    "DomainTypes", "CombatPredictionTypes",
    "VictoryTypes", "PolicyBranchTypes", "GameOptionTypes",
    "ButtonPopupTypes", "ContentType", "SlotStatus", "ActivityTypes",
    "InterfaceModeTypes", "MissionTypes", "GameMessageTypes",
    "ActionSubTypes", "GameInfoActions", "EndTurnBlockingTypes",
    "TaskTypes",

    -- Platform / session / content
    "Modding", "Matchmaking", "Network", "Steam", "SaveFileList",
    "ContentManager", "OptionsManager", "Path", "DB", "Script",

    -- VFS include (stem-based; not the same as Lua require)
    "include",

    -- Tolk: proxy-injected. `tolk` is the canonical binding; `Tolk` is an
    -- occasional alias seen in the engine. Speech should still go through
    -- SpeechEngine, but the raw tables are globals.
    "tolk", "Tolk",

    -- miniaudio: proxy-injected binding for the per-hex audio cue layer.
    -- Read-only from mod code; tests/run.lua overrides it with a capture
    -- stub (see the tests-section globals entry for the write permission).
    "audio",

    -- Engine hex-geometry helpers injected by WorldView / camera code.
    -- CameraTracker uses them to convert grid coords to world coords.
    "HexToWorld", "ToHexFromGrid",
}

-- Mod-authored module globals. Each file defines one of these at top level;
-- other files read them after include(). Listing them here lets luacheck
-- warn on typos (e.g. `Scaner.foo`) while allowing the expected top-level
-- assignments and cross-file reads.
--
-- Base-game globals our wrappers interact with also go here rather than in
-- read_globals because the wrappers follow Civ V's chaining pattern (capture
-- the old InputHandler / ShowHideHandler / OnBack / ..., install a new one
-- that delegates to it). Both the read and the write are intentional, so a
-- read-only annotation would produce noise on every wrapper.
globals = {
    -- Proxy-injected cross-Context shared state table (mod-writable)
    "civvaccess_shared",

    -- Shared modules (UI/Shared/)
    "HandlerStack", "InputRouter", "TickPump", "BaselineHandler",
    "SpeechEngine", "SpeechPipeline", "TextFilter", "Text",
    "Log", "Help", "Nav", "Icons",
    "PickerReader", "PullDownProbe", "TypeAheadSearch",
    "BaseMenu", "BaseMenuItems", "BaseMenuTabs", "BaseMenuHelp", "BaseMenuEditMode",
    "BaseMenuNumberEntry",
    "MPGameSetupShared", "SavedGameShared",
    "InstalledPanel", "LoadMenu", "LoadReplayMenu", "Lobby", "SaveMenu",
    "CivDetails", "Civilopedia", "CivilopediaCategory",
    "AudioCueMode",
    "CameraTracker", "NavigableGraph",

    -- InGame modules
    "Cursor", "CursorActivate", "CursorPedia", "HexGeom", "Pathfinder",
    "PlotComposers", "PlotSections", "PlotSectionRiver", "PlotSectionUnits",
    "PlotAudio",
    "ScannerCore", "ScannerHandler", "ScannerInput", "ScannerNav",
    "ScannerSearch", "ScannerSnap",
    "ScannerBackendCities", "ScannerBackendImprovements",
    "ScannerBackendRecommendations",
    "ScannerBackendResources", "ScannerBackendSpecial", "ScannerBackendTerrain",
    "ScannerBackendUnits",
    "SurveyorCore",
    "CitySpeech",
    "CityRangeStrikeMode",
    "ChooseProductionLogic", "ChooseTechLogic",
    "NotificationAnnounce",
    "Recommendations",
    "SocialPolicyLogic",
    "TechTreeLogic",
    "TradeLogicAccess",
    "Turn",
    "UnitSpeech", "UnitActionMenu", "UnitTargetMode", "UnitControl",

    -- Base-game helpers pulled in by TechTree's include chain
    -- (TechHelpInclude.lua defines GetHelpTextForTech). Our TechTreeLogic
    -- reads it; tests monkey-patch it, so it lives here rather than in
    -- read_globals.
    "GetHelpTextForTech",

    -- User-preference module (Shared/)
    "Prefs",

    -- Test / polyfill surface
    "Polyfill",

    -- String tables loaded by the Text module
    "CivVAccess_Strings",

    -- Civ V UI Context convention: every screen defines these at module
    -- scope; base files install them and our *Access wrappers frequently
    -- replace them with a chaining version that calls the captured prior.
    "InputHandler", "ShowHideHandler", "OnUpdate",

    -- Base-game handler functions our wrappers chain onto. Sourced from the
    -- base .lua files we ship but don't lint (MainMenu, OtherMenu, LoadMenu,
    -- ModsBrowser, StagingRoom, OptionsMenu, SaveMenu, SelectMapType, ...).
    -- Kept as writable since several wrappers replace-and-chain.
    "OnBack", "OnOK", "OnCancel", "OnStart", "OnExitGame", "OnShowHide",
    "OnCountdownYes", "OnCountdownNo", "OnCategory", "OnSenarioCheck",
    "OnEditBoxChange", "OnGraphicsChangedOK",
    "BackButtonClick", "HallOfFameClick", "ViewReplaysButtonClick",
    "CreditsClicked", "LeaderboardClick", "CivilizationSelected",
    "NavigateBack", "HandleExitRequest",
    "SetSelected", "SortByName", "SortByLastModified",
    "ShowResolutionCountdown", "ShowLanguageCountdown",
    "StartCountdown", "StopCountdown",
    "Validate", "ValidateText", "View",
    "RefreshDLC", "RefreshMods", "SetupFileButtonList",
    "SortAndDisplayListings", "ModListPreamble", "DEFAULT_BACKGROUND",

    -- Base-game state tables and module singletons we read at speech time.
    -- These are defined in the base .lua files and live in the shared
    -- lua_State for the duration of the screen.
    "PopupPriority", "GameTypes", "MapUtilities",
    "g_CurrentSort", "g_SortOptions", "g_iSelected",
    "g_FileList", "g_SlotInstances", "g_SavedGames",
    "g_SavedGameModsRequired", "g_SavedGameDLCRequired",
    "g_ReplayModsRequired", "g_ReplayDLCRequired",
    "g_ScenarioList", "g_TutorialEntries", "g_ModList", "g_SortedMods",
    "g_GameOptionsManager", "g_DropDownOptionsManager",
    "g_VictoryCondtionsManager", "g_fCountdownTimer",
    "sortedList",

    -- Civilopedia article-history triple: promoted to globals in our
    -- CivilopediaScreen.lua override so the accessibility wiring can read
    -- the current article during Alt+Left / Alt+Right navigation and
    -- write the cursor as it steps through history.
    "currentTopic", "endTopic", "listOfTopicsViewed",
}

-- Per-directory overrides.
files["tests/"] = {
    -- Tests dofile the polyfill before each suite, which populates engine
    -- enums / tables into the runner's global env. They also assign Log
    -- and SpeechEngine as capturing stubs, and individual suites monkey-
    -- patch Events.* / Game.* to drive code paths. Allow those writes.
    globals = {
        "Events", "Game", "Map", "Players", "Teams",
        "GameInfo", "GameInfoTypes", "GameDefines",
        "Locale", "UI", "Controls", "ContextPtr",
        "Mouse", "Keys",
        "DirectionTypes", "PlotTypes", "FeatureTypes", "TerrainTypes",
        "ResourceTypes", "ResourceUsageTypes", "ImprovementTypes",
        "RouteTypes", "YieldTypes",
        "DomainTypes", "ActivityTypes", "EndTurnBlockingTypes",
        -- Engine tables whose fields the suites monkey-patch. These are
        -- read-only at top level; tests need write access to drive code
        -- paths (e.g. turn_test flips PreGame.IsMultiplayerGame to cover
        -- both SP and MP endturn dispatch).
        "PreGame", "Network", "OptionsManager",
        -- Engine enum the suites stub to drive popup dispatch tests.
        "ButtonPopupTypes",
        -- Engine enums only the ChooseProduction suite needs; shimmed in
        -- that suite's setup rather than in the polyfill.
        "OrderTypes", "AdvisorTypes",
        -- Proxy-injected miniaudio binding. run.lua installs a capture
        -- stub before each suite; declaring it writable here lets the
        -- stub assignment and monkey-patches pass without warnings.
        "audio",
        -- Mod modules the test suites exercise directly.
        "UnitSpeech", "Pathfinder", "ScannerBackendTerrain",
    },
    -- Test suites are tables of test_* functions returned via `return M`;
    -- setup helpers and per-test locals are often declared but only used
    -- in a subset of tests in the same file. Relax the strictest warnings
    -- without hiding real bugs.
    ignore = {
        "212",  -- unused argument (test fixtures often accept but ignore args)
        "213",  -- unused loop variable
        "542",  -- empty if branch (placeholder in skeleton tests)
    },
}

-- Our *Access wrappers layer behavior over a specific base-game screen by
-- reading that screen's functions and state tables (every MainMenu has its
-- own OnBack / g_FileList / SortListingsBy / ReconnectButtonClick / ...).
-- Whitelisting every base symbol is unsustainable — new bindings appear with
-- each screen we wrap. Silence "accessing undefined variable" for the
-- wrappers only; real typo-catching stays active in the pure-mod modules
-- (ScannerCore, SpeechPipeline, TickPump, etc.) that don't touch base
-- globals.
--
-- luacheck's files keys are glob patterns (Unix-style; ** matches any depth).
files["**/CivVAccess_*Access.lua"]    = { ignore = { "113" } }
files["**/CivVAccess_*Core.lua"]      = { ignore = { "113" } }
files["**/CivVAccess_*Shared.lua"]    = { ignore = { "113" } }
files["**/CivVAccess_FrontendBoot.lua"]   = { ignore = { "113" } }
files["**/CivVAccess_FrontendCommon.lua"] = { ignore = { "113" } }
files["**/CivVAccess_ProbeBoot.lua"]      = { ignore = { "113" } }
files["**/CivVAccess_ModListPreamble.lua"] = { ignore = { "113" } }

-- Polyfill's whole job is to create engine globals when ContextPtr is nil.
-- Every assignment is intentional; suppress the "setting ... global" warnings
-- and the self-shadowing from method definitions inside widget factories.
files["src/dlc/UI/InGame/CivVAccess_Polyfill.lua"] = {
    ignore = {
        "111", "112", "113",  -- set/mutate non-standard global, access undefined
        "121", "122", "131",  -- set read-only global / field, unused read-only global
        "142",                -- set undefined field of global
        "431",                -- shadowing upvalue (method defs inside factories)
    },
}

-- Base-game files we ship as verbatim copies with an include() appended
-- (bootstrap overrides plus screen-level overrides like CityView) contain
-- base-game code we don't control. Don't lint them; just check syntax.
files["src/dlc/UI/InGame/TaskList.lua"]           = { ignore = { "1", "2", "3", "4", "5", "6" } }
files["src/dlc/UI/InGame/InGame.lua"]             = { ignore = { "1", "2", "3", "4", "5", "6" } }
files["src/dlc/UI/InGame/WorldView/WorldView.lua"] = { ignore = { "1", "2", "3", "4", "5", "6" } }
files["src/dlc/UI/InGame/WorldView/Advisors.lua"]  = { ignore = { "1", "2", "3", "4", "5", "6" } }
files["src/dlc/UI/InGame/CityView/CityView.lua"]  = { ignore = { "1", "2", "3", "4", "5", "6" } }
files["src/dlc/UI/TechTree/TechTree.lua"]         = { ignore = { "1", "2", "3", "4", "5", "6" } }
files["src/dlc/UI/FrontEnd/ToolTips.lua"]         = { ignore = { "1", "2", "3", "4", "5", "6" } }

-- Skip the base-game Lua we ship verbatim. Our CivVAccess_* wrappers pair
-- with each one and layer behavior over it via ContextPtr / LuaEvents; the
-- base file itself is unmodified, so linting it is noise. The rule of thumb:
-- any .lua under src/dlc/UI/ whose name does NOT start with CivVAccess_ is
-- a base-game copy and should be excluded.
exclude_files = {
    "src/dlc/UI/FrontEnd/MainMenu.lua",
    "src/dlc/UI/FrontEnd/ModsMenu.lua",
    "src/dlc/UI/FrontEnd/OtherMenu.lua",
    "src/dlc/UI/FrontEnd/ModsSinglePlayer.lua",
    "src/dlc/UI/FrontEnd/ModsMultiplayer.lua",
    "src/dlc/UI/FrontEnd/ModsError.lua",
    "src/dlc/UI/FrontEnd/SinglePlayer.lua",
    "src/dlc/UI/FrontEnd/MultiplayerSelect.lua",
    "src/dlc/UI/FrontEnd/ScenariosMenu.lua",
    "src/dlc/UI/FrontEnd/OptionsMenu.lua",
    "src/dlc/UI/FrontEnd/PremiumContentMenu.lua",
    "src/dlc/UI/FrontEnd/LoadMenu.lua",
    "src/dlc/UI/FrontEnd/LoadReplayMenu.lua",
    "src/dlc/UI/FrontEnd/LoadScreen.lua",
    "src/dlc/UI/FrontEnd/LoadTutorial.lua",
    "src/dlc/UI/FrontEnd/Credits.lua",
    "src/dlc/UI/FrontEnd/EULA.lua",
    "src/dlc/UI/FrontEnd/ExitConfirm.lua",
    "src/dlc/UI/FrontEnd/FrontEndPopup.lua",
    "src/dlc/UI/FrontEnd/JoiningRoom.lua",
    "src/dlc/UI/FrontEnd/LegalScreen.lua",
    "src/dlc/UI/FrontEnd/ContentSwitch.lua",
    "src/dlc/UI/FrontEnd/WaitingForPlayers.lua",
    "src/dlc/UI/FrontEnd/WorldPicker.lua",
    "src/dlc/UI/FrontEnd/GameSetup/",
    "src/dlc/UI/FrontEnd/Modding/",
    "src/dlc/UI/FrontEnd/Multiplayer/",
    "src/dlc/UI/InGame/Menus/GameMenu.lua",
    "src/dlc/UI/InGame/Menus/SaveMenu.lua",
    "src/dlc/UI/InGame/Popups/",
    "src/dlc/UI/InGame/LeaderHead/LeaderHeadRoot.lua",
    "src/dlc/UI/InGame/LeaderHead/DiscussionDialog.lua",
    "src/dlc/UI/InGame/LeaderHead/DiploTrade.lua",
    "src/dlc/UI/InGame/WorldView/SimpleDiploTrade.lua",
    "src/dlc/UI/InGame/CivilopediaScreen.lua",
    "src/dlc/UI/InGame/PlayerChange.lua",
    "third_party/",
    ".luacheckcache/",
}
