-- MCP bridge (CivVAccess_Rpc) tests: the JSON encoder that shapes every
-- reply the MCP server parses, and the request dispatch loop. The `rpc`
-- proxy binding is stubbed with a capture table (the file mailbox is
-- native code); queries themselves run against the engine and are
-- exercised live, not here.

local T = require("support")
local M = {}

local sent -- JSON strings handed to rpc.respond
local pending -- request line the next poll returns
local warns, errors

local function setup()
    warns, errors = {}, {}
    Log.warn = function(msg)
        warns[#warns + 1] = msg
    end
    Log.error = function(msg)
        errors[#errors + 1] = msg
    end
    sent = {}
    pending = nil
    rpc = {
        poll = function()
            local line = pending
            pending = nil
            return line
        end,
        respond = function(s)
            sent[#sent + 1] = s
            return true
        end,
    }
    dofile("src/dlc/UI/Shared/CivVAccess_TickPump.lua")
    TickPump._reset()
    dofile("src/dlc/UI/InGame/CivVAccess_Rpc.lua")
end

-- encoder -------------------------------------------------------------------

function M.test_encode_scalars()
    setup()
    T.eq(Rpc._encode(nil), "null")
    T.eq(Rpc._encode(true), "true")
    T.eq(Rpc._encode(false), "false")
    T.eq(Rpc._encode(42), "42")
    T.eq(Rpc._encode(-7), "-7")
    T.eq(Rpc._encode(2.5), "2.5")
    T.eq(Rpc._encode("plain"), '"plain"')
end

function M.test_encode_string_escapes()
    setup()
    T.eq(Rpc._encode('say "hi"'), '"say \\"hi\\""')
    T.eq(Rpc._encode("back\\slash"), '"back\\\\slash"')
    T.eq(Rpc._encode("line\nbreak\ttab"), '"line\\nbreak\\ttab"')
    T.eq(Rpc._encode(string.char(7)), '"\\u0007"')
end

function M.test_encode_non_finite_numbers_become_null()
    setup()
    T.eq(Rpc._encode(math.huge), "null")
    T.eq(Rpc._encode(-math.huge), "null")
    T.eq(Rpc._encode(0 / 0), "null")
end

function M.test_encode_array_and_nested_object()
    setup()
    T.eq(Rpc._encode({ 1, 2, 3 }), "[1,2,3]")
    T.eq(Rpc._encode({}), "[]")
    T.eq(Rpc._encode({ { x = 1 }, { x = 2 } }), '[{"x":1},{"x":2}]')
end

function M.test_encode_object_keys_stringified()
    setup()
    T.eq(Rpc._encode({ turn = 12 }), '{"turn":12}')
end

-- dispatch ------------------------------------------------------------------

function M.test_poll_without_request_responds_nothing()
    setup()
    Rpc._poll()
    T.eq(#sent, 0)
end

function M.test_dispatch_success_envelope()
    setup()
    Rpc._queries.echo = function(a, b)
        return { first = a, second = b }
    end
    pending = "req1\techo\tfoo\tbar"
    Rpc._poll()
    T.eq(#sent, 1)
    T.truthy(sent[1]:find('"id":"req1"', 1, true))
    T.truthy(sent[1]:find('"ok":true', 1, true))
    T.truthy(sent[1]:find('"first":"foo"', 1, true))
    T.truthy(sent[1]:find('"second":"bar"', 1, true))
    T.truthy(sent[1]:find('"turn":', 1, true), "envelope carries the turn stamp")
end

function M.test_dispatch_consumes_request_once()
    setup()
    Rpc._queries.echo = function()
        return {}
    end
    pending = "req2\techo"
    Rpc._poll()
    Rpc._poll() -- TickPump may run a subscriber twice per frame
    T.eq(#sent, 1)
end

function M.test_unknown_query_reports_error()
    setup()
    pending = "req3\tno_such_query"
    Rpc._poll()
    T.eq(#sent, 1)
    T.truthy(sent[1]:find('"ok":false', 1, true))
    T.truthy(sent[1]:find("unknown query", 1, true))
    T.truthy(#warns >= 1, "unknown query is logged")
end

function M.test_malformed_request_reports_error()
    setup()
    pending = "only-an-id"
    Rpc._poll()
    T.eq(#sent, 1)
    T.truthy(sent[1]:find('"ok":false', 1, true))
    T.truthy(sent[1]:find("malformed request", 1, true))
    T.truthy(#warns >= 1)
end

function M.test_query_raise_becomes_error_reply_and_log()
    setup()
    Rpc._queries.boom = function()
        error("resource melted")
    end
    pending = "req4\tboom"
    Rpc._poll()
    T.eq(#sent, 1)
    T.truthy(sent[1]:find('"ok":false', 1, true))
    T.truthy(sent[1]:find("resource melted", 1, true))
    T.truthy(#errors >= 1, "query failure reaches Log.error")
end

function M.test_error_reply_strips_file_line_prefix()
    setup()
    Rpc._queries.boom = function()
        -- error() with a string prepends "file:line: "; the reply must
        -- carry only the message while the log keeps the full string.
        error("bad argument")
    end
    pending = "req7\tboom"
    Rpc._poll()
    T.truthy(sent[1]:find('"error":"bad argument"', 1, true), sent[1])
    T.truthy(errors[1]:find("rpc_test.lua", 1, true), "log keeps the file prefix")
end

function M.test_respond_write_failure_is_logged()
    setup()
    rpc.respond = function()
        return false
    end
    Rpc._queries.echo = function()
        return {}
    end
    pending = "req5\techo"
    Rpc._poll()
    T.truthy(#errors >= 1, "mailbox write failure reaches Log.error")
end

-- point_cursor ---------------------------------------------------------------

function M.test_point_cursor_validates_args()
    setup()
    pending = "req8\tpoint_cursor\tfive\tsix"
    Rpc._poll()
    T.eq(#sent, 1)
    T.truthy(sent[1]:find('"ok":false', 1, true))
    T.truthy(sent[1]:find("numeric x and y", 1, true), sent[1])
end

function M.test_point_cursor_moves_and_speaks()
    setup()
    local origMap, origCursor, origSpeech = Map, Cursor, SpeechPipeline
    Map = {
        GetPlot = function()
            return {}
        end,
    }
    local jumped, spoken
    Cursor = {
        jumpTo = function(x, y)
            jumped = { x, y }
            return "grass"
        end,
    }
    SpeechPipeline = {
        speakInterrupt = function(s)
            spoken = s
        end,
    }
    pending = "req9\tpoint_cursor\t5\t6"
    Rpc._poll()
    T.truthy(sent[1]:find('"ok":true', 1, true), sent[1])
    T.eq(jumped[1], 5)
    T.eq(jumped[2], 6)
    T.eq(spoken, "grass")
    T.truthy(sent[1]:find('"spoken":"grass"', 1, true), sent[1])
    Map, Cursor, SpeechPipeline = origMap, origCursor, origSpeech
end

function M.test_point_cursor_empty_glance_stays_silent()
    setup()
    local origMap, origCursor, origSpeech = Map, Cursor, SpeechPipeline
    Map = {
        GetPlot = function()
            return {}
        end,
    }
    local spoke = false
    Cursor = {
        jumpTo = function()
            return ""
        end,
    }
    SpeechPipeline = {
        speakInterrupt = function()
            spoke = true
        end,
    }
    pending = "req10\tpoint_cursor\t1\t2"
    Rpc._poll()
    T.truthy(sent[1]:find('"ok":true', 1, true), sent[1])
    T.eq(spoke, false, "an empty glance must not reach the speech pipeline")
    Map, Cursor, SpeechPipeline = origMap, origCursor, origSpeech
end

function M.test_install_without_proxy_rpc_warns_and_skips()
    setup()
    rpc = nil
    Rpc.installListeners()
    T.truthy(#warns >= 1, "missing proxy binding is logged, not silent")
    TickPump.tick() -- no subscriber must have been registered
    T.eq(#sent, 0)
end

function M.test_install_subscribes_to_tick_pump()
    setup()
    Rpc._queries.echo = function()
        return {}
    end
    Rpc.installListeners()
    pending = "req6\techo"
    TickPump.tick()
    T.eq(#sent, 1, "poll runs from the TickPump subscription")
end

return M
