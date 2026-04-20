-- Entry point. Aggregates all suites into a single runner and exit code.
-- Invoked by test.ps1 with the repo root as CWD.

local T = require("support")

-- Load the production polyfill to populate engine globals (Locale, etc.).
-- The polyfill's sentinel check keeps it a no-op in-game; here it fires.
dofile("src/dlc/UI/InGame/CivVAccess_Polyfill.lua")
dofile("src/dlc/UI/InGame/CivVAccess_InGameStrings_en_US.lua")
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
Locale = Locale or {}
Locale.ConvertTextKey = function(key, ...)
    local args = { ... }
    if #args == 0 then return key end
    return (key:gsub("{(%d+)_[^}]*}", function(n)
        local v = args[tonumber(n)]
        if v == nil then return "" end
        return tostring(v)
    end))
end

-- Log and SpeechEngine stay as test-owned capturing stubs so suites can
-- monkey-patch them (warn-capture, stop() observation). They're deliberately
-- not in the polyfill: production code owns the real implementations and
-- tests want a seam for inspection.
Log = {
    debug = function() end, info = function() end,
    warn  = function() end, error = function() end,
}
SpeechEngine = {
    say  = function() end,
    stop = function() end,
}

T.register("text_filter", require("text_filter_test"))
T.register("speech_pipeline", require("speech_pipeline_test"))
T.register("text", require("text_test"))
T.register("handler_stack", require("handler_stack_test"))
T.register("input_router", require("input_router_test"))
T.register("tick_pump", require("tick_pump_test"))
T.register("baseline_handler", require("baseline_handler_test"))
T.register("pulldown_probe", require("pulldown_probe_test"))
T.register("menu", require("menu_test"))
T.register("menuitem_textfield", require("menuitem_textfield_test"))
T.register("type_ahead", require("type_ahead_test"))
T.register("help", require("help_test"))
T.register("picker_reader", require("picker_reader_test"))
T.register("icons", require("icons_test"))
T.register("cursor", require("cursor_test"))

os.exit(T.run() and 0 or 1)
