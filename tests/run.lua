-- Entry point. Aggregates all suites into a single runner and exit code.
-- Invoked by test.ps1 with the repo root as CWD.

local T = require("support")

-- Load the production polyfill to populate engine globals (Locale, etc.).
-- The polyfill's sentinel check keeps it a no-op in-game; here it fires.
dofile("src/dlc/UI/InGame/CivVAccess_Polyfill.lua")
dofile("src/dlc/UI/InGame/CivVAccess_InGameStrings_en_US.lua")
dofile("src/dlc/UI/InGame/CivVAccess_SurveyorStrings_en_US.lua")
dofile("src/dlc/UI/Shared/CivVAccess_PluralRules.lua")
-- UserPrefs must load before any ScannerNav-touching suite so the
-- Prefs.getBool / setBool calls ScannerNav makes at dofile time and
-- inside toggleAutoMove resolve to the real production module. The
-- module self-degrades to returning defaults when Modding is absent
-- (as it is here), so no test stub is needed.
dofile("src/dlc/UI/Shared/CivVAccess_UserPrefs.lua")
-- HexGeom is a pure-math helper used by Cursor.orient (and, later, the
-- scanner's End key). Loading it here ensures the cursor suite's setup()
-- dofile chain can call HexGeom.directionString without each test having
-- to dofile it explicitly.
dofile("src/dlc/UI/InGame/CivVAccess_HexGeom.lua")

-- Shared state table that the proxy installs per-Context in-game.
-- HandlerStack and others read it as a module-level reference.
civvaccess_shared = civvaccess_shared or {}

-- Override Locale.ConvertTextKey so it runs the engine's {N_Tag} positional
-- substitution. The polyfill's passthrough is enough to avoid load-time
-- crashes but loses the substitution behavior the cursor / city sections
-- rely on for game-side keys (TXT_KEY_CITY_OF, TXT_KEY_PLOTROLL_*) -- mod-
-- authored CivVAccess keys go through CivVAccess_Strings and don't need
-- this. Existing suites pass single-arg keys, which short-circuit through
-- the no-args branch unchanged.
--
-- baseGameStrings registers a small set of base-game format strings whose
-- VALUES (not just placeholder substitution) the test needs to mirror
-- production. UnitSpeech.unitName builds "Roman Warrior" via the base
-- game's TXT_KEY_PLOTROLL_UNIT_DESCRIPTION_CIV ("{1_Adj} {2_Name}"); in-
-- game the engine resolves the key to its registered string and then
-- substitutes args, but the test stub has no string registry. Mapping
-- the key to its format here closes the gap so suites can assert on the
-- shape of the resolved phrase rather than the literal key.
local baseGameStrings = {
    TXT_KEY_PLOTROLL_UNIT_DESCRIPTION_CIV = "{1_Adj} {2_Name}",
}
Locale = Locale or {}
Locale.ConvertTextKey = function(key, ...)
    local fmt = baseGameStrings[key] or key
    local args = { ... }
    if #args == 0 then
        return fmt
    end
    return (
        fmt:gsub("{(%d+)_[^}]*}", function(n)
            local v = args[tonumber(n)]
            if v == nil then
                return ""
            end
            return tostring(v)
        end)
    )
end

-- Log and SpeechEngine stay as test-owned capturing stubs so suites can
-- monkey-patch them (warn-capture, stop() observation). They're deliberately
-- not in the polyfill: production code owns the real implementations and
-- tests want a seam for inspection.
Log = {
    debug = function() end,
    info = function() end,
    warn = function() end,
    error = function() end,
}
SpeechEngine = {
    say = function() end,
    stop = function() end,
}

-- Audio: capturing stub for the proxy's miniaudio binding so PlotAudio and
-- Cursor suites can assert bed / fog / stinger / cancel_all call ordering
-- without touching real audio. Stays here (not in the polyfill) for the
-- same reason SpeechEngine is test-owned: suites want a monkey-patch seam.
-- `load` returns an incrementing id so every sound-name maps to a distinct
-- handle; `_reset` wipes the call log between tests.
audio = {
    _calls = {},
    _loadCounter = 0,
}
function audio.load(name)
    audio._loadCounter = audio._loadCounter + 1
    audio._calls[#audio._calls + 1] = { op = "load", name = name, id = audio._loadCounter }
    return audio._loadCounter
end
function audio.play(id)
    audio._calls[#audio._calls + 1] = { op = "play", id = id }
end
function audio.play_delayed(id, ms)
    audio._calls[#audio._calls + 1] = { op = "play_delayed", id = id, ms = ms }
end
function audio.cancel_all()
    audio._calls[#audio._calls + 1] = { op = "cancel_all" }
end
function audio.set_master_volume(v)
    audio._calls[#audio._calls + 1] = { op = "set_master_volume", v = v }
end
function audio.set_volume(id, v)
    audio._calls[#audio._calls + 1] = { op = "set_volume", id = id, v = v }
end
function audio._reset()
    audio._calls = {}
    audio._loadCounter = 0
end

T.register("text_filter", require("text_filter_test"))
T.register("speech_pipeline", require("speech_pipeline_test"))
T.register("text", require("text_test"))
T.register("text_rule", require("text_rule_test"))
T.register("plural_rules", require("plural_rules_test"))
T.register("text_plural", require("text_plural_test"))
T.register("strings_loader", require("strings_loader_test"))
T.register("handler_stack", require("handler_stack_test"))
T.register("input_router", require("input_router_test"))
T.register("tick_pump", require("tick_pump_test"))
T.register("baseline_handler", require("baseline_handler_test"))
T.register("pulldown_probe", require("pulldown_probe_test"))
T.register("menu", require("menu_test"))
T.register("tabbed_shell", require("tabbed_shell_test"))
T.register("base_table", require("base_table_test"))
T.register("economic_overview", require("economic_overview_test"))
T.register("menuitem_textfield", require("menuitem_textfield_test"))
T.register("number_entry", require("number_entry_test"))
T.register("type_ahead", require("type_ahead_test"))
T.register("help", require("help_test"))
T.register("settings", require("settings_test"))
T.register("picker_reader", require("picker_reader_test"))
T.register("civilopedia_flat_search", require("civilopedia_flat_search_test"))
T.register("icons", require("icons_test"))
T.register("cursor", require("cursor_test"))
T.register("cursor_activate", require("cursor_activate_test"))
T.register("cursor_pedia", require("cursor_pedia_test"))
T.register("plot_audio", require("plot_audio_test"))
T.register("volume_control", require("volume_control_test"))
T.register("hexgeom", require("hexgeom_test"))
T.register("surveyor", require("surveyor_test"))
T.register("unit_speech", require("suite_unit_speech"))
T.register("unit_control", require("unit_control_test"))
T.register("aircraft_count", require("aircraft_count_test"))
T.register("city_speech", require("suite_city_speech"))
T.register("city_stats", require("suite_city_stats"))
T.register("scanner_taxonomy", require("scanner_taxonomy_test"))
T.register("scanner_classification", require("scanner_classification_test"))
T.register("scanner_snapshot", require("scanner_snapshot_test"))
T.register("scanner_search_filter", require("scanner_search_filter_test"))
T.register("scanner_navigation", require("scanner_navigation_test"))
T.register("scanner_announcement", require("scanner_announcement_test"))
T.register("bookmarks", require("bookmarks_test"))
T.register("notification_announce", require("notification_announce_test"))
T.register("multiplayer_rewards", require("multiplayer_rewards_test"))
T.register("reveal_announce", require("reveal_announce_test"))
T.register("foreign_unit_watch", require("foreign_unit_watch_test"))
T.register("foreign_clear_watch", require("foreign_clear_watch_test"))
T.register("combat_log", require("combat_log_test"))
T.register("message_buffer", require("message_buffer_test"))
T.register("turn", require("turn_test"))
T.register("tasklist", require("tasklist_test"))
T.register("empire_status", require("empire_status_test"))
T.register("empire_status_detail", require("empire_status_detail_test"))
T.register("choose_production", require("choose_production_test"))
T.register("choose_tech", require("choose_tech_test"))
T.register("navigable_graph", require("navigable_graph_test"))
T.register("tech_tree_logic", require("tech_tree_logic_test"))
T.register("social_policy_logic", require("social_policy_logic_test"))
T.register("league_overview_row", require("league_overview_row_test"))

os.exit(T.run() and 0 or 1)
