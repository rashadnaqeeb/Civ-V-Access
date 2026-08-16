-- EngineEvents tests. The dispatcher stands between the fork's deferred hook
-- queue and the handlers that used to be raised straight from the game-core
-- thread, so what matters is that a queued event reaches the same handler with
-- the same arguments, that a stock engine still routes through GameEvents, and
-- that a dropped batch is reported rather than swallowed.
--
-- The drain binding is installed per test rather than in the polyfill: its
-- absence is the degraded mode, and leaving it absent by default is what keeps
-- the consumer suites asserting against GameEvents.

local T = require("support")
local M = {}

local warnings, errors
local drained, overflowed
local gameEventsInstalls

local function setup(withBinding)
    warnings, errors = {}, {}
    Log.warn = function(msg)
        warnings[#warnings + 1] = msg
    end
    Log.error = function(msg)
        errors[#errors + 1] = msg
    end
    Log.info = function() end

    drained, overflowed = {}, false
    gameEventsInstalls = {}

    dofile("src/dlc/UI/Shared/CivVAccess_TickPump.lua")
    TickPump._reset()

    -- Capture what the fallback path registers, without disturbing the real
    -- GameEvents table other suites share.
    GameEvents = setmetatable({}, {
        __index = function(_, name)
            return {
                Add = function(fn)
                    gameEventsInstalls[#gameEventsInstalls + 1] = { name = name, fn = fn }
                end,
            }
        end,
    })

    if withBinding then
        Game.CivVAccessDrainEvents = function()
            local batch = drained
            drained = {}
            return batch, overflowed
        end
    else
        Game.CivVAccessDrainEvents = nil
    end

    dofile("src/dlc/UI/InGame/CivVAccess_EngineData.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_EngineEvents.lua")
    EngineEvents.installListeners()
end

local function teardown()
    Game.CivVAccessDrainEvents = nil
end

-- deferred path ------------------------------------------------------------

function M.test_queued_event_reaches_the_handler_with_its_arguments()
    setup(true)
    local seen = {}
    EngineEvents.on("CivVAccessUnitMoved", function(...)
        seen[#seen + 1] = { ... }
    end)
    drained = { { "CivVAccessUnitMoved", 3, 41, 10, 11, 12, 13 } }
    EngineEvents._drain()
    T.eq(#seen, 1, "the queued event is dispatched")
    T.eq(seen[1][1], 3, "owner")
    T.eq(seen[1][2], 41, "unit id")
    T.eq(seen[1][6], 13, "the sixth argument survives the round trip")
    teardown()
end

function M.test_dispatch_preserves_queue_order()
    setup(true)
    local order = {}
    EngineEvents.on("CivVAccessPlotRevealed", function(_team, x)
        order[#order + 1] = x
    end)
    drained = {
        { "CivVAccessPlotRevealed", 1, 7, 7 },
        { "CivVAccessPlotRevealed", 1, 8, 7 },
        { "CivVAccessPlotRevealed", 1, 9, 7 },
    }
    EngineEvents._drain()
    T.eq(table.concat(order, ","), "7,8,9", "consumers replay reveals in simulation order")
    teardown()
end

function M.test_every_handler_for_a_hook_runs()
    setup(true)
    local a, b = 0, 0
    EngineEvents.on("CivVAccessPlotRevealed", function()
        a = a + 1
    end)
    EngineEvents.on("CivVAccessPlotRevealed", function()
        b = b + 1
    end)
    drained = { { "CivVAccessPlotRevealed", 1, 2, 3 } }
    EngineEvents._drain()
    T.eq(a, 1, "RevealAnnounce-style handler ran")
    T.eq(b, 1, "MassNames-style handler ran too")
    teardown()
end

function M.test_a_throwing_handler_does_not_stop_the_batch()
    setup(true)
    local reached = 0
    EngineEvents.on("CivVAccessPlotRevealed", function()
        error("boom")
    end)
    EngineEvents.on("CivVAccessPlotRevealed", function()
        reached = reached + 1
    end)
    drained = { { "CivVAccessPlotRevealed", 1, 2, 3 }, { "CivVAccessPlotRevealed", 1, 4, 5 } }
    EngineEvents._drain()
    T.eq(reached, 2, "a failing listener must not swallow the rest of the queue")
    T.truthy(#errors > 0, "and the failure is logged, never dropped silently")
    teardown()
end

function M.test_drain_is_subscribed_to_the_tick_pump()
    setup(true)
    local seen = 0
    EngineEvents.on("CivVAccessUnitMoved", function()
        seen = seen + 1
    end)
    drained = { { "CivVAccessUnitMoved", 1, 2, 3, 4, 5, 6 } }
    TickPump.tick()
    T.eq(seen, 1, "the pump drives the drain; nothing else has to call it")
    teardown()
end

function M.test_overflow_is_reported()
    setup(true)
    overflowed = true
    EngineEvents._drain()
    T.truthy(#warnings > 0, "a dropped batch has to reach the log")
    teardown()
end

-- fallback path ------------------------------------------------------------

function M.test_without_the_binding_handlers_go_to_game_events()
    setup(false)
    local fn = function() end
    EngineEvents.on("CivVAccessUnitMoved", fn)
    T.eq(#gameEventsInstalls, 1, "a stock engine still gets its listener")
    T.eq(gameEventsInstalls[1].name, "CivVAccessUnitMoved")
    T.eq(gameEventsInstalls[1].fn, fn, "and it is the caller's own handler, unwrapped")
    T.truthy(#warnings > 0, "the degraded mode is announced once at install")
    teardown()
end

function M.test_without_the_binding_nothing_subscribes_to_the_pump()
    setup(false)
    T.eq(
        civvaccess_shared.tickSubscribers["EngineEvents"],
        nil,
        "no queue means no drain, so the pump must not carry a dead subscriber"
    )
    teardown()
end

-- registration guard -------------------------------------------------------

function M.test_non_deferred_hook_is_refused()
    setup(true)
    EngineEvents.on("CivVAccessNukeStart", function() end)
    T.truthy(#errors > 0, "a hook with no queued path must not silently never fire")
    teardown()
end

-- boot lifecycle -----------------------------------------------------------

function M.test_reinstall_drops_the_previous_game_handlers()
    setup(true)
    local stale = 0
    EngineEvents.on("CivVAccessUnitMoved", function()
        stale = stale + 1
    end)
    -- A load-from-game re-boot: installListeners runs again, then the
    -- consumers re-register. The prior game's closures must not survive.
    EngineEvents.installListeners()
    drained = { { "CivVAccessUnitMoved", 1, 2, 3, 4, 5, 6 } }
    EngineEvents._drain()
    T.eq(stale, 0, "handlers from the dead env are gone")
    teardown()
end

return M
