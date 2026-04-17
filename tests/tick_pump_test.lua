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
    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TickPump.lua")
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

function M.test_install_rewires_setupdate_each_call()
    setup()
    local calls = 0
    local ctx = { SetUpdate = function(self, fn) calls = calls + 1 end }
    TickPump.install(ctx)
    TickPump.install(ctx)
    T.eq(calls, 2)
end

function M.test_runOnce_drained_on_next_tick_then_cleared()
    setup()
    local fires = 0
    TickPump.runOnce(function() fires = fires + 1 end)
    TickPump.tick()
    T.eq(fires, 1)
    TickPump.tick()
    T.eq(fires, 1, "one-shot does not re-fire on subsequent ticks")
end

function M.test_runOnce_queues_multiple_drained_together()
    setup()
    local order = {}
    TickPump.runOnce(function() order[#order + 1] = "a" end)
    TickPump.runOnce(function() order[#order + 1] = "b" end)
    TickPump.tick()
    T.eq(order[1], "a")
    T.eq(order[2], "b")
end

function M.test_runOnce_callback_can_schedule_next_tick()
    setup()
    local fires = {}
    TickPump.runOnce(function()
        fires[#fires + 1] = "first"
        TickPump.runOnce(function() fires[#fires + 1] = "second" end)
    end)
    TickPump.tick()
    T.eq(#fires, 1, "re-queued callback does not run this tick")
    TickPump.tick()
    T.eq(fires[2], "second", "re-queued callback runs next tick")
end

function M.test_runOnce_callback_error_caught_and_logged()
    setup()
    TickPump.runOnce(function() error("kaboom") end)
    TickPump.tick()
    T.truthy(#errors >= 1)
end

return M
