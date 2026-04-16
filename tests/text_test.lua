-- Text wrapper tests. Locale.ConvertTextKey is replaced by the polyfill in
-- run.lua; these tests override it per-case to simulate engine hit / miss.
-- Log.warn is swapped for a capturing stub so we can assert on missing-key
-- logging at the wrapper boundary.

local T = require("support")
local M = {}

local warnings
local origWarn, origConvert

local function setup()
    warnings = {}
    origWarn = Log.warn
    origConvert = Locale.ConvertTextKey
    Log.warn = function(msg) warnings[#warnings + 1] = msg end
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
end

local function teardown()
    Log.warn = origWarn
    Locale.ConvertTextKey = origConvert
end

function M.test_key_returns_engine_value()
    setup()
    Locale.ConvertTextKey = function(k) return "Hello, world" end
    T.eq(Text.key("TXT_KEY_GREETING"), "Hello, world")
    T.eq(#warnings, 0)
    teardown()
end

function M.test_key_logs_and_passes_through_when_missing()
    setup()
    Locale.ConvertTextKey = function(k) return k end
    local out = Text.key("TXT_KEY_MISSING_FOO")
    T.eq(out, "TXT_KEY_MISSING_FOO")
    T.eq(#warnings, 1)
    T.truthy(warnings[1]:find("TXT_KEY_MISSING_FOO", 1, true),
        "warning should mention the key name")
    teardown()
end

function M.test_key_no_warn_for_non_txt_key_input()
    setup()
    Locale.ConvertTextKey = function(k) return k end
    local out = Text.key("Hello")
    T.eq(out, "Hello")
    T.eq(#warnings, 0)
    teardown()
end

function M.test_key_returns_civvaccess_string_from_table()
    setup()
    local calls = 0
    Locale.ConvertTextKey = function() calls = calls + 1; return "SHOULD_NOT_BE_CALLED" end
    CivVAccess_Strings = CivVAccess_Strings or {}
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEST_FIXTURE"] = "hello"
    T.eq(Text.key("TXT_KEY_CIVVACCESS_TEST_FIXTURE"), "hello")
    T.eq(calls, 0)
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_TEST_FIXTURE"] = nil
    teardown()
end

function M.test_format_passes_varargs_through()
    setup()
    local capturedArgs
    Locale.ConvertTextKey = function(...)
        capturedArgs = { select("#", ...), ... }
        return "formatted"
    end
    local out = Text.format("TXT_KEY_FMT", "a", 2, true)
    T.eq(out, "formatted")
    T.eq(capturedArgs[1], 4)
    T.eq(capturedArgs[2], "TXT_KEY_FMT")
    T.eq(capturedArgs[3], "a")
    T.eq(capturedArgs[4], 2)
    T.eq(capturedArgs[5], true)
    teardown()
end

return M
