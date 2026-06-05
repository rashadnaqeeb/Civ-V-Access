-- EngineData port tests. The drift reads are covered where they are
-- consumed (combat in the unit-speech suite, happiness in the empire-status
-- suite, and so on); this suite owns the behavior unique to the port
-- itself: graceful degradation of fork-added bindings when the engine fork
-- DLL is absent, the case that silenced the tile read on a stock engine.

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

return M
