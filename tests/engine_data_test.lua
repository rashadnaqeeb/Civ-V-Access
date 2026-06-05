-- EngineData port tests. Most drift reads are covered where they are
-- consumed (combat in the unit-speech suite, happiness in the empire-status
-- suite, and so on); this suite owns the behavior unique to the port
-- itself: graceful degradation of fork-added bindings when the engine fork
-- DLL is absent, the case that silenced the tile read on a stock engine. It
-- also covers the trade resource-count drift read directly, since the trade
-- Available drawer has no consumer suite to exercise it through.

local T = require("support")
local M = {}

-- Run fn with the global Game shaped so EngineData.forkPresent() reports
-- the fork present or absent, restoring Game afterward even on failure.
local function withFork(present, fn)
    local savedGame = Game
    if present then
        Game = {
            GetBuildRoutePath = function() end,
            GetCycleUnits = function() end,
            GetClosestSearchedPlot = function() end,
        }
    else
        Game = {}
    end
    local ok, err = pcall(fn)
    Game = savedGame
    if not ok then
        error(err, 0)
    end
end

function M.test_mission_queue_passes_through_when_fork_present()
    withFork(true, function()
        local unit = {
            GetMissionQueue = function()
                return { "a", "b" }
            end,
        }
        T.eq(#EngineData.missionQueue(unit), 2)
    end)
end

function M.test_mission_queue_degrades_to_empty_when_fork_absent()
    withFork(false, function()
        local savedWarn = Log.warn
        local warned = false
        Log.warn = function()
            warned = true
        end
        local unit = {
            GetMissionQueue = function()
                error("binding must not be called when the fork is absent")
            end,
        }
        local ok, result = pcall(EngineData.missionQueue, unit)
        Log.warn = savedWarn
        T.truthy(ok, "absent fork must not throw: " .. tostring(result))
        T.eq(#result, 0)
        T.truthy(warned, "absent fork must log a warning")
    end)
end

-- Trade resource count: the vanilla body is a deal-scoped getter taking
-- (playerId, resourceType). Pins the argument order and pass-through so a
-- regression that swaps player and resource (which would silently report
-- the wrong tradeable count) fails here.
function M.test_deal_resource_count_passes_player_and_resource_through()
    local seen
    local deal = {
        GetNumResource = function(_, playerId, resType)
            seen = { playerId = playerId, resType = resType }
            return 5
        end,
    }
    T.eq(EngineData.dealResourceCount(deal, 3, 7), 5)
    T.eq(seen.playerId, 3)
    T.eq(seen.resType, 7)
end

return M
