-- TickPump tests. HandlerStack loaded for real so we can verify tick()
-- forwards to the active handler.

local T = require("support")
local M = {}

local errors

local function setup()
    errors = {}
    Log.error = function(msg) errors[#errors + 1] = msg end
    Log.warn  = function() end
    Log.debug = function() end
    dofile("src/mod/UI/CivVAccess_HandlerStack.lua")
    dofile("src/mod/UI/CivVAccess_TickPump.lua")
    HandlerStack._reset()
    TickPump._reset()
end

function M.test_tick_bumps_frame_counter()
    setup()
    T.eq(TickPump.frame(), 0)
    TickPump.tick()
    TickPump.tick()
    T.eq(TickPump.frame(), 2)
end

function M.test_tick_calls_active_handler_tick()
    setup()
    local ticks = 0
    HandlerStack.push({ name = "a",
        tick = function(self) ticks = ticks + 1 end })
    TickPump.tick()
    T.eq(ticks, 1)
end

function M.test_tick_no_active_handler_is_noop()
    setup()
    TickPump.tick()  -- must not crash
    T.eq(TickPump.frame(), 1)
end

function M.test_tick_handler_error_caught_and_logged()
    setup()
    HandlerStack.push({ name = "boom",
        tick = function() error("crash") end })
    TickPump.tick()
    T.truthy(#errors >= 1)
end

function M.test_install_idempotent_second_call_warns()
    setup()
    local warns = {}
    Log.warn = function(msg) warns[#warns + 1] = msg end
    local calls = 0
    local ctx = { SetUpdate = function(self, fn) calls = calls + 1 end }
    TickPump.install(ctx)
    TickPump.install(ctx)
    T.eq(calls, 1)
    T.truthy(#warns >= 1)
end

return M
