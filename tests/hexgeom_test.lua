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

-- ===== coordinateString =====
-- Wipes Players so prior cursor / scanner suite leftovers don't satisfy
-- the IsOriginalCapital scan. Each test installs exactly the player slots
-- it cares about. Default Map.IsWrapX=false; tests that exercise wrap
-- override it explicitly.
local function coordSetup()
    setupSteps()
    Game.GetActivePlayer = function()
        return 0
    end
    Map.IsWrapX = function()
        return false
    end
    for i = 0, 63 do
        Players[i] = nil
    end
end

function M.test_coordinateString_at_capital_is_zero_zero()
    coordSetup()
    T.installOriginalCapital(5, 5)
    T.eq(HexGeom.coordinateString(5, 5), "0, 0")
end

function M.test_coordinateString_step_east()
    coordSetup()
    T.installOriginalCapital(0, 0)
    T.eq(HexGeom.coordinateString(1, 0), "1, 0")
end

function M.test_coordinateString_step_west()
    coordSetup()
    T.installOriginalCapital(0, 0)
    T.eq(HexGeom.coordinateString(-1, 0), "-1, 0")
end

function M.test_coordinateString_step_ne_lands_on_half()
    -- NE from a row-0 (even) plot lands at (col, row+1). Row 1 is odd
    -- (half-shifted), so the geometric x is +0.5 relative to the
    -- capital and y is +1. Each NE step is exactly the user's stated
    -- (+0.5, +1) increment.
    coordSetup()
    T.installOriginalCapital(0, 0)
    T.eq(HexGeom.coordinateString(0, 1), "0.5, 1")
end

function M.test_coordinateString_step_se_lands_on_half_negative_y()
    -- SE from row 0: (col, row-1). Each SE step is (+0.5, -1) so the
    -- design's "NE then SE = (1, 0)" identity works out.
    coordSetup()
    T.installOriginalCapital(0, 0)
    T.eq(HexGeom.coordinateString(0, -1), "0.5, -1")
end

function M.test_coordinateString_capital_on_odd_row_subtracts_half()
    -- Capital at engine (3, 1) (odd row, geometrically (3.5, 1)). Cursor
    -- at engine (3, 0) (even row, (3, 0)). Geometric delta is (-0.5, -1)
    -- which is one SW step from the capital -- the user's mental model
    -- carries through across rows of either parity.
    coordSetup()
    T.installOriginalCapital(3, 1)
    T.eq(HexGeom.coordinateString(3, 0), "-0.5, -1")
end

function M.test_coordinateString_pre_capital_returns_empty()
    -- Active player has no cities yet (turn 0 settler not founded).
    -- Iteration finds nothing; coord callers no-op silently.
    coordSetup()
    T.eq(HexGeom.coordinateString(5, 5), "")
end

function M.test_coordinateString_finds_captured_capital()
    -- Original capital captured by player 2. The city object now lives
    -- under Players[2] but GetOriginalOwner() still says 0, so the
    -- iteration picks it up.
    coordSetup()
    T.installOriginalCapital(4, 4, { slot = 2, originalOwner = 0 })
    T.eq(HexGeom.coordinateString(5, 4), "1, 0")
end

function M.test_coordinateString_no_match_when_other_player_capital()
    -- Other major civ's original capital exists, but it's not active
    -- player's capital. Iteration must skip it.
    coordSetup()
    T.installOriginalCapital(4, 4, { slot = 1 })
    T.eq(HexGeom.coordinateString(5, 4), "")
end

function M.test_coordinateString_wrap_folds_far_east_to_negative()
    -- Width-80 wrap, capital at engine x=10. Cursor at engine x=78 is
    -- 68 east via simple subtraction but only 12 west across the seam,
    -- so the algorithm folds it to -12.
    coordSetup()
    Map.IsWrapX = function()
        return true
    end
    Map.GetGridSize = function()
        return 80, 40
    end
    T.installOriginalCapital(10, 0)
    T.eq(HexGeom.coordinateString(78, 0), "-12, 0")
end

function M.test_coordinateString_wrap_within_half_unchanged()
    -- raw=30 lands inside [-40, 40], so wrap correction is a no-op and
    -- the user hears 30, not the seam-crossing alternative.
    coordSetup()
    Map.IsWrapX = function()
        return true
    end
    Map.GetGridSize = function()
        return 80, 40
    end
    T.installOriginalCapital(10, 0)
    T.eq(HexGeom.coordinateString(40, 0), "30, 0")
end

function M.test_coordinateString_no_wrap_keeps_far_east_positive()
    -- Same geometry as the fold test, but the map is flat so simple
    -- subtraction is the only thing that makes sense. The user hears 68.
    coordSetup()
    T.installOriginalCapital(10, 0)
    T.eq(HexGeom.coordinateString(78, 0), "68, 0")
end

return M
