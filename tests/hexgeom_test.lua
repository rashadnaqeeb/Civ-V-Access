-- HexGeom is used by the cursor's S key, the scanner's End key, and the
-- surveyor's radius sweeps. directionString is covered by cursor_test's
-- orient cases; this suite focuses on plotsInRange inclusion and the
-- cube-distance invariant that every caller depends on.

local T = require("support")
local M = {}

local function setup()
    Game.GetActiveTeam = function()
        return 0
    end
    Game.IsDebugMode = function()
        return false
    end
end

-- Build a rectangular grid of revealed plots (-W..W in col, -W..W in row)
-- whose GetPlot(col, row) returns the stored plot, or nil when off the
-- bounding rectangle. Plots flagged in `unrevealed` are registered but
-- return IsRevealed=false. Halfwidth W must be wide enough that the test
-- radius stays inside the rectangle unless the test is specifically
-- probing off-map behaviour.
local function installGrid(halfWidth, unrevealed)
    unrevealed = unrevealed or {}
    local plots = {}
    for col = -halfWidth, halfWidth do
        plots[col] = {}
        for row = -halfWidth, halfWidth do
            local key = col .. "," .. row
            plots[col][row] = T.fakePlot({
                x = col,
                y = row,
                revealed = not unrevealed[key],
            })
        end
    end
    Map.GetPlot = function(col, row)
        local column = plots[col]
        if column == nil then
            return nil
        end
        return column[row]
    end
    return plots
end

-- ===== Inclusion counts =====

function M.test_plotsInRange_r0_contains_only_center()
    setup()
    installGrid(3)
    local result = HexGeom.plotsInRange(0, 0, 0)
    T.eq(#result.plots, 1, "r=0 must return exactly the center plot")
    T.eq(result.plots[1]:GetX(), 0)
    T.eq(result.plots[1]:GetY(), 0)
    T.eq(result.unexplored, 0)
end

function M.test_plotsInRange_r1_contains_seven_plots()
    setup()
    installGrid(3)
    local result = HexGeom.plotsInRange(0, 0, 1)
    T.eq(#result.plots, 7, "r=1 is center + 6 neighbours")
    T.eq(result.unexplored, 0)
end

function M.test_plotsInRange_r3_contains_thirtyseven_plots()
    setup()
    installGrid(6)
    local result = HexGeom.plotsInRange(0, 0, 3)
    -- 1 + 6 + 12 + 18.
    T.eq(#result.plots, 37, "r=3 hex count must be 1 + 6 + 12 + 18")
end

function M.test_plotsInRange_r5_contains_ninetyone_plots()
    setup()
    installGrid(10)
    local result = HexGeom.plotsInRange(0, 0, 5)
    -- 1 + 6 + 12 + 18 + 24 + 30.
    T.eq(#result.plots, 91, "r=5 hex count must be 91")
end

-- ===== Cube-distance invariant =====

function M.test_every_returned_plot_is_within_cube_distance()
    setup()
    installGrid(10)
    for _, r in ipairs({ 0, 1, 2, 3, 4, 5 }) do
        local result = HexGeom.plotsInRange(0, 0, r)
        for _, plot in ipairs(result.plots) do
            local d = HexGeom.cubeDistance(0, 0, plot:GetX(), plot:GetY())
            T.truthy(
                d <= r,
                "r=" .. r .. " returned plot (" .. plot:GetX() .. "," .. plot:GetY() .. ") at cube distance " .. d
            )
        end
    end
end

-- ===== Unexplored split =====

function M.test_unrevealed_plots_counted_separately()
    setup()
    installGrid(3, { ["1,0"] = true, ["-1,0"] = true })
    local result = HexGeom.plotsInRange(0, 0, 1)
    T.eq(#result.plots, 5, "two of the six neighbours fogged out")
    T.eq(result.unexplored, 2, "the two fogged plots must land in unexplored")
end

function M.test_offmap_plots_do_not_inflate_unexplored()
    -- halfWidth=1 means anything outside (-1..1, -1..1) is off-map
    -- (Map.GetPlot returns nil). At r=2 several in-range cube positions
    -- fall outside the bounding rectangle and must NOT count toward
    -- unexplored -- they're simply not real plots.
    setup()
    installGrid(1)
    local result = HexGeom.plotsInRange(0, 0, 2)
    T.eq(result.unexplored, 0, "nil plots (off-map) must not bump unexplored")
    -- Every returned plot must still be on-grid.
    for _, plot in ipairs(result.plots) do
        T.truthy(math.abs(plot:GetX()) <= 1 and math.abs(plot:GetY()) <= 1)
    end
end

function M.test_every_plot_lands_in_exactly_one_bucket()
    -- Property: every in-range plot that Map.GetPlot knows about is
    -- either in `plots` (revealed) or counted in `unexplored`, never
    -- both, never neither. With all plots revealed, the total must
    -- equal the hex count for the radius.
    setup()
    installGrid(6)
    local result = HexGeom.plotsInRange(0, 0, 3)
    T.eq(#result.plots + result.unexplored, 37)
end

-- ===== cubeDistance sanity =====
function M.test_cubeDistance_matches_ring_counts()
    -- The r=3 ring has exactly 6*3 = 18 plots at distance 3 from center.
    setup()
    installGrid(6)
    local result = HexGeom.plotsInRange(0, 0, 3)
    local ring3 = 0
    for _, plot in ipairs(result.plots) do
        if HexGeom.cubeDistance(0, 0, plot:GetX(), plot:GetY()) == 3 then
            ring3 = ring3 + 1
        end
    end
    T.eq(ring3, 18, "the r=3 ring must contain 18 plots")
end

-- ===== directionRank =====
function M.test_directionRank_e_beats_se()
    setup()
    -- (1,0) at even row 0: cube delta (1, -1, 0) -> pure E, rank 1.
    -- (0,-1) at odd row -1: cube delta (1, 0, -1) -> pure SE, rank 2.
    T.eq(HexGeom.directionRank(0, 0, 1, 0), 1, "pure E must rank 1")
    T.eq(HexGeom.directionRank(0, 0, 0, -1), 2, "pure SE must rank 2")
end

-- ===== stepListString =====
-- Run-length grouping over a sequence of DirectionTypes constants. Used
-- by move-path preview to speak the actual step chain. Test relies on
-- Text.key resolving the DIR_* keys via run.lua's strings dofile.
local function setupSteps()
    setup()
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
end

function M.test_stepListString_empty_input_returns_empty()
    setupSteps()
    T.eq(HexGeom.stepListString({}), "")
    T.eq(HexGeom.stepListString(nil), "")
end

function M.test_stepListString_single_direction_run()
    setupSteps()
    local steps = {
        DirectionTypes.DIRECTION_EAST,
        DirectionTypes.DIRECTION_EAST,
        DirectionTypes.DIRECTION_EAST,
    }
    T.eq(HexGeom.stepListString(steps), "3e")
end

function M.test_stepListString_groups_consecutive_only()
    setupSteps()
    -- E, E, SE, NW, NW, NW, E -> runs are 2e, 1se, 3nw, 1e (not merged
    -- with the leading 2e because the SE / NW blocks split them).
    local steps = {
        DirectionTypes.DIRECTION_EAST,
        DirectionTypes.DIRECTION_EAST,
        DirectionTypes.DIRECTION_SOUTHEAST,
        DirectionTypes.DIRECTION_NORTHWEST,
        DirectionTypes.DIRECTION_NORTHWEST,
        DirectionTypes.DIRECTION_NORTHWEST,
        DirectionTypes.DIRECTION_EAST,
    }
    T.eq(HexGeom.stepListString(steps), "2e, 1se, 3nw, 1e")
end

return M
