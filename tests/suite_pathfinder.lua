-- Pathfinder: A* over the hex grid with a scope-limited port of
-- CvUnitMovement::GetCostsForMove. Each test exercises a distinct rule
-- branch — terrain base cost, hills surcharge, route discount, river
-- crossing end-turn, embarkation, mountain impassable, territory access,
-- ZoC, Great Wall, and trait overrides for Inca / Carthage / Polynesia.

local T = require("support")
local M = {}

-- Feature / terrain / route / tech / trait / promotion / building-class
-- IDs used across the suite. Keep them stable so every test agrees on
-- which row GameInfo.X[id] resolves to.
local FEAT_FOREST = 1
local TERRAIN_GRASS = 1
local TERRAIN_COAST = 2
local TERRAIN_OCEAN = 3
local ROUTE_ROAD = 0
local TECH_ENGINEERING = 10
local TECH_ASTRONOMY = 11
local PROMOTION_IGNORE_TERRAIN_COST = 20
local PROMOTION_AMPHIBIOUS = 21
local PROMOTION_HOVERING_UNIT = 22
local PROMOTION_ROUGH_TERRAIN_ENDS_TURN = 23
local PROMOTION_FLAT_MOVEMENT_COST = 24
local BUILDINGCLASS_GREAT_WALL = 30

-- Reset per-test scenario data only. Engine globals (Map, Game,
-- DirectionTypes, PlotTypes, DomainTypes, GameDefines.MOVE_DENOMINATOR,
-- etc.) come from CivVAccess_Polyfill.lua via run.lua; tests should not
-- re-stub them. MAX_CIV_PLAYERS is not in the polyfill (game-sim-wide
-- constant, only the ZoC/GW sweeps read it) so set it here.
local function setup()
    dofile("src/dlc/UI/InGame/CivVAccess_Pathfinder.lua")

    GameDefines.MAX_CIV_PLAYERS = 4

    GameInfoTypes = {
        TECH_ENGINEERING = TECH_ENGINEERING,
        TECH_ASTRONOMY = TECH_ASTRONOMY,
        PROMOTION_IGNORE_TERRAIN_COST = PROMOTION_IGNORE_TERRAIN_COST,
        PROMOTION_AMPHIBIOUS = PROMOTION_AMPHIBIOUS,
        PROMOTION_HOVERING_UNIT = PROMOTION_HOVERING_UNIT,
        PROMOTION_ROUGH_TERRAIN_ENDS_TURN = PROMOTION_ROUGH_TERRAIN_ENDS_TURN,
        PROMOTION_FLAT_MOVEMENT_COST = PROMOTION_FLAT_MOVEMENT_COST,
        BUILDINGCLASS_GREAT_WALL = BUILDINGCLASS_GREAT_WALL,
    }

    -- Minimal data tables. Movement columns drive tileBaseCost; Type
    -- strings drive ocean / forest / jungle branch detection.
    GameInfo = {
        Terrains = {
            [TERRAIN_GRASS] = { Type = "TERRAIN_GRASS", Movement = 1 },
            [TERRAIN_COAST] = { Type = "TERRAIN_COAST", Movement = 1 },
            [TERRAIN_OCEAN] = { Type = "TERRAIN_OCEAN", Movement = 1 },
        },
        Features = {
            [FEAT_FOREST] = { Type = "FEATURE_FOREST", Movement = 2 },
        },
        Routes = {
            [ROUTE_ROAD] = { Type = "ROUTE_ROAD", FlatMovement = 10 },
        },
        Leaders = {},
        Leader_Traits = function()
            return function()
                return nil
            end
        end,
        Traits = {},
    }

    Players = {}
    Teams = {}
end

-- Install a hex-offset grid. `configure(col, row, plot)` may return a
-- replacement plot to override the defaults. plotIndex is col+row*(2W+1)
-- so every plot has a unique index for cameFrom / zocPlots lookup.
local function installGrid(halfWidth, configure)
    local plots = {}
    local idx = 0
    for col = -halfWidth, halfWidth do
        plots[col] = {}
        for row = -halfWidth, halfWidth do
            local p = T.fakePlot({
                x = col,
                y = row,
                plotIndex = idx,
                terrain = TERRAIN_GRASS,
                plotType = PlotTypes.PLOT_LAND,
            })
            idx = idx + 1
            if configure ~= nil then
                local override = configure(col, row, p)
                if override ~= nil then
                    p = override
                end
            end
            plots[col][row] = p
        end
    end
    local function lookup(col, row)
        local column = plots[col]
        if column == nil then
            return nil
        end
        return column[row]
    end
    Map.GetPlot = lookup
    -- Offset (even-row) neighbor deltas. Pathfinder iterates the six
    -- hex directions via Map.PlotDirection; this table converts each
    -- direction to a (dcol, drow) offset. Parity (even / odd row) shifts
    -- E-facing neighbors; the grid configuration in these tests keeps
    -- the actor near the origin so parity differences don't matter for
    -- the properties under test.
    local function neighborOffset(col, row, dir)
        local even = (row % 2 == 0)
        if dir == DirectionTypes.DIRECTION_EAST then
            return col + 1, row
        elseif dir == DirectionTypes.DIRECTION_WEST then
            return col - 1, row
        elseif dir == DirectionTypes.DIRECTION_NORTHEAST then
            return (even and col or col + 1), row - 1
        elseif dir == DirectionTypes.DIRECTION_NORTHWEST then
            return (even and col - 1 or col), row - 1
        elseif dir == DirectionTypes.DIRECTION_SOUTHEAST then
            return (even and col or col + 1), row + 1
        elseif dir == DirectionTypes.DIRECTION_SOUTHWEST then
            return (even and col - 1 or col), row + 1
        end
        return col, row
    end
    Map.PlotDirection = function(x, y, dir)
        local nx, ny = neighborOffset(x, y, dir)
        return lookup(nx, ny)
    end
    Map.GetNumPlots = function()
        return idx
    end
    Map.GetPlotByIndex = function(i)
        for col = -halfWidth, halfWidth do
            for row = -halfWidth, halfWidth do
                local p = plots[col][row]
                if p:GetPlotIndex() == i then
                    return p
                end
            end
        end
        return nil
    end
    return plots
end

-- Produce a warrior-shaped unit at `plot` with the given promotions,
-- plus a team at the same id. Team flags (techs, open borders, etc.)
-- override the default "nothing researched / no agreements" baseline.
local function mkUnit(plot, opts)
    opts = opts or {}
    local unit = T.fakeUnit({
        owner = 0,
        team = 0,
        domain = opts.domain or DomainTypes.DOMAIN_LAND,
        maxMoves = opts.maxMoves or 120,
        movesLeft = opts.movesLeft or (opts.maxMoves or 120),
        promotions = opts.promotions or {},
    })
    unit._plot = plot
    Teams[0] = T.fakeTeam({
        techs = opts.techs or {},
        openBorders = opts.openBorders or {},
        canEmbark = opts.canEmbark or false,
    })
    Players[0] = {
        _team = 0,
        GetTeam = function(self)
            return 0
        end,
        GetLeaderType = function()
            return -1
        end,
        IsAlive = function()
            return true
        end,
        GetBuildingClassCount = function(_, _)
            return 0
        end,
        Units = function()
            return function()
                return nil
            end
        end,
    }
    return unit
end

-- Shared corridor for ZoC tests. Row 0 is open; everything else is
-- impassable mountain. Tests park a ZoC-projecting unit at (0, 1),
-- which is a flanking plot for the A→B step from (0, 0) to (1, 0).
-- The flanking plot itself stays mountain: ZoC projects from the
-- unit's location regardless of the host plot's passability, and
-- leaving it impassable prevents the pathfinder from detouring around
-- the ZoC (which would happen if the trigger tile were walkable).
local function installCorridor()
    return installGrid(4, function(col, row, p)
        if row ~= 0 then
            p._isMountain = true
        end
        return p
    end)
end

-- ===== Tests =====

-- 1. Straight-line open grass: three hexes (cost 60 each), unit has
-- 2 MP / turn. Step 1 mpRem=60. Step 2 mpRem=0. Step 3 overflows:
-- newRemaining = 120-60 = 60, turns=1. Final mpRemaining < maxMoves
-- so final_turns = 1 + 1 = 2.
function M.test_straight_line_open_grass_three_hexes()
    setup()
    local plots = installGrid(4)
    local unit = mkUnit(plots[0][0], {})
    local result, reason = Pathfinder.findPath(unit, plots[3][0])
    T.truthy(result ~= nil, "expected path, got nil: " .. tostring(reason))
    T.eq(result.turns, 2, "3 grass hexes with 2 MP per turn should take 2 turns")
    T.eq(result.mpCost, 180, "3 * 60 MP = 180 in 60ths")
    T.eq(result.mpRemaining, 60, "arrives with 1 MP left on turn 2 after one grass step")
end

-- mpRemaining reports MP left on the arrival turn. Distinct from mpCost
-- (total spent): a 4-MP unit that walks onto a single grass tile has
-- mpCost=60 (spent 1 MP on the step) and mpRemaining=180 (3 MP left
-- that turn). Used by UnitTargetMode to speak "arrives with X unspent".
function M.test_mpRemaining_reflects_arrival_turn_leftover()
    setup()
    local plots = installGrid(4)
    local unit = mkUnit(plots[0][0], { maxMoves = 240 })
    local result = Pathfinder.findPath(unit, plots[1][0])
    T.eq(result.mpCost, 60, "single grass step costs 60")
    T.eq(result.mpRemaining, 180, "4-MP unit has 3 MP left after one grass step")
    T.eq(result.turns, 1)

    -- End-turn step zeroes MP on arrival.
    setup()
    local plots2 = installGrid(4)
    plots2[0][0]._riverCrossings[plots2[1][0]] = true
    plots2[1][0]._riverCrossings[plots2[0][0]] = true
    local unit2 = mkUnit(plots2[0][0], {})
    local result2 = Pathfinder.findPath(unit2, plots2[1][0])
    T.eq(result2.mpRemaining, 0, "river-crossing arrival lands on 0 MP")
end

-- 2. Hills add 1 MP. With a 3-MP unit the surcharge exposes itself as
-- a turn difference: grass-grass-grass fits in one turn (3*60 = 180),
-- but grass-hill-grass overflows (60+120 exactly drains 3 MP, forcing
-- the third grass into turn 2). A 2-MP unit doesn't witness this --
-- partial-MP lets it clamp the hill step and finish in turn 1 -- so
-- the test deliberately uses 3 MP to isolate the surcharge.
function M.test_hills_surcharge_forces_extra_turn()
    setup()
    local plotsGrass = installGrid(4)
    local unitGrass = mkUnit(plotsGrass[0][0], { maxMoves = 180 })
    local resultGrass = Pathfinder.findPath(unitGrass, plotsGrass[3][0])
    T.eq(resultGrass.turns, 1, "three grass at 3 MP should fit in one turn")

    setup()
    local plotsHills = installGrid(4, function(col, row, p)
        if col == 2 and row == 0 then
            p._isHills = true
        end
        return p
    end)
    local unitHills = mkUnit(plotsHills[0][0], { maxMoves = 180 })
    local resultHills = Pathfinder.findPath(unitHills, plotsHills[3][0])
    T.eq(resultHills.turns, 2, "grass-hill-grass should spill into turn two at 3 MP")
end

-- Partial-MP rule. A 2-MP unit with 60 MP left stepping into a forest
-- (raw cost 120) pays its remaining 60 and arrives in the current turn,
-- not the next one -- matching CvUnitMovement's min(iCost, iMoves)
-- clamp. Old wait-for-full-MP semantics would report 2 turns and 120
-- cost; engine-correct is 1 turn and 60 cost.
function M.test_partial_mp_clamps_overflow_step()
    setup()
    local plots = installGrid(4, function(col, row, p)
        if col == 1 and row == 0 then
            p._feature = FEAT_FOREST
        end
        return p
    end)
    local unit = mkUnit(plots[0][0], { maxMoves = 120, movesLeft = 60 })
    local result = Pathfinder.findPath(unit, plots[1][0])
    T.truthy(result ~= nil, "forest target must be reachable with partial MP")
    T.eq(result.turns, 1, "partial-MP lets the unit arrive this turn")
    T.eq(result.mpCost, 60, "cost clamps to remaining 60, not the forest's 120")
end

-- 3. Inca FasterInHills trait cancels the surcharge. Same grid as (2)
-- but a trait flag injected via GameInfo.Traits row; the hill path now
-- fits in one turn again.
function M.test_inca_faster_in_hills_cancels_surcharge()
    setup()
    GameInfo.Leaders = { [0] = { Type = "LEADER_PACHACUTI" } }
    GameInfo.Traits = {
        TRAIT_GREAT_ANDEAN_ROAD = { FasterInHills = true },
    }
    GameInfo.Leader_Traits = function()
        local rows = { { LeaderType = "LEADER_PACHACUTI", TraitType = "TRAIT_GREAT_ANDEAN_ROAD" } }
        local i = 0
        return function()
            i = i + 1
            return rows[i]
        end
    end
    local plots = installGrid(4, function(col, row, p)
        if col == 2 and row == 0 then
            p._isHills = true
        end
        return p
    end)
    local unit = mkUnit(plots[0][0], {})
    Players[0].GetLeaderType = function()
        return 0
    end
    local result = Pathfinder.findPath(unit, plots[2][0])
    T.eq(result.turns, 1, "Inca unit should cross hills without surcharge")
end

-- 4. Forest feature overrides grass base. A single forest step costs
-- 120 MP (2 * 60); a 4 MP unit spends 120 of 240 on the step and still
-- has 120 left, so the move fits in one turn. The cost check isolates
-- the feature override (grass alone would have cost 60).
function M.test_forest_overrides_grass_base_cost()
    setup()
    local plots = installGrid(4, function(col, row, p)
        if col == 1 and row == 0 then
            p._feature = FEAT_FOREST
        end
        return p
    end)
    local unit = mkUnit(plots[0][0], { maxMoves = 240 })
    local result = Pathfinder.findPath(unit, plots[1][0])
    T.eq(result.mpCost, 120, "forest step should cost 120 MP (2 * 60)")
    T.eq(result.turns, 1, "4-MP unit finishes forest step within one turn")
end

-- 5. Road-to-road reduces cost. Two-hex path with road on both endpoints
-- costs routeFlat * baseMoves (10 * 2 = 20 per step). Compare with the
-- same path sans-road (60 per step) to show the discount applies.
function M.test_road_reduces_mp_cost()
    setup()
    local plotsNoRoad = installGrid(4)
    local unitNoRoad = mkUnit(plotsNoRoad[0][0], {})
    local resultNoRoad = Pathfinder.findPath(unitNoRoad, plotsNoRoad[2][0])
    T.eq(resultNoRoad.mpCost, 120, "baseline grass-grass = 120 in 60ths")

    setup()
    local plotsRoad = installGrid(4, function(col, row, p)
        if row == 0 and col >= 0 and col <= 2 then
            p._route = ROUTE_ROAD
        end
        return p
    end)
    local unitRoad = mkUnit(plotsRoad[0][0], {})
    local resultRoad = Pathfinder.findPath(unitRoad, plotsRoad[2][0])
    T.truthy(resultRoad.mpCost < resultNoRoad.mpCost, "road path must cost less")
    T.eq(resultRoad.mpCost, 40, "road-road = 2 * (10 * 2) = 40 in 60ths")
end

-- 6. Pillaged road disables the discount. One plot in the corridor has
-- IsRoutePillaged=true, so the pair for that step falls back to terrain
-- cost. Round-trip cost returns to the non-road baseline.
function M.test_pillaged_road_disables_discount()
    setup()
    local plots = installGrid(4, function(col, row, p)
        if row == 0 and col >= 0 and col <= 2 then
            p._route = ROUTE_ROAD
            if col == 1 then
                p._isRoutePillaged = true
            end
        end
        return p
    end)
    local unit = mkUnit(plots[0][0], {})
    local result = Pathfinder.findPath(unit, plots[2][0])
    T.eq(result.mpCost, 120, "pillaged road should cost like grass: 2 * 60 = 120")
end

-- 7. River crossing ends turn without Engineering / Amphibious; permits
-- with either. Using IsRiverCrossingToPlot stub to avoid parity work on
-- the per-edge river flags.
function M.test_river_crossing_ends_turn_without_engineering()
    setup()
    local plots = installGrid(4)
    plots[0][0]._riverCrossings[plots[1][0]] = true
    plots[1][0]._riverCrossings[plots[0][0]] = true
    local unit = mkUnit(plots[0][0], {})
    local result = Pathfinder.findPath(unit, plots[1][0])
    T.eq(result.turns, 1, "the end-turn move itself still completes in one turn")
    -- Second-hex target forces a second turn since the first step ate the turn.
    local result2 = Pathfinder.findPath(unit, plots[2][0])
    T.eq(result2.turns, 2, "river-then-grass should take two turns")
end

function M.test_engineering_skips_river_penalty()
    setup()
    local plots = installGrid(4)
    plots[0][0]._riverCrossings[plots[1][0]] = true
    plots[1][0]._riverCrossings[plots[0][0]] = true
    local unit = mkUnit(plots[0][0], { techs = { [TECH_ENGINEERING] = true } })
    local result = Pathfinder.findPath(unit, plots[2][0])
    T.eq(result.turns, 1, "Engineering bypasses the river end-turn")
end

-- River end-turn after the unit already drained its MP on prior tiles.
-- 2-MP unit, 3-hex path (grass, grass, river): steps 1-2 exhaust turn 1,
-- so the river step can't land until turn 2 (where it ends that turn
-- too). Regression test for an early advance() version that skipped the
-- "waiting" turn when endsTurn fired at mpRemaining == 0.
function M.test_river_ends_turn_even_after_mp_drained()
    setup()
    local plots = installGrid(4)
    -- River between (2, 0) and (3, 0). A 2-MP unit taking the east
    -- corridor exhausts its turn 1 MP on hexes 1 and 2, then has to
    -- wait out the turn boundary before the river crossing (which
    -- itself eats turn 2). Baseline 3-hex grass path also takes 2
    -- turns, so both paths are equal-turn; the distinguishing signal
    -- is that the MP-exhausted river case must NOT round down to 1.
    plots[2][0]._riverCrossings[plots[3][0]] = true
    plots[3][0]._riverCrossings[plots[2][0]] = true
    local unit = mkUnit(plots[0][0], {})
    local result = Pathfinder.findPath(unit, plots[3][0])
    T.eq(result.turns, 2, "river at the end of an MP-exhausted path should take two turns")
end

function M.test_amphibious_promotion_skips_river_penalty()
    setup()
    local plots = installGrid(4)
    plots[0][0]._riverCrossings[plots[1][0]] = true
    plots[1][0]._riverCrossings[plots[0][0]] = true
    local unit = mkUnit(plots[0][0], { promotions = { [PROMOTION_AMPHIBIOUS] = true } })
    local result = Pathfinder.findPath(unit, plots[2][0])
    T.eq(result.turns, 1, "Amphibious promotion bypasses the river end-turn")
end

-- 8. Mountain is impassable for land units, passable (but end-turn) for
-- Carthage, and straight-line for hover units. Grid: a single mountain
-- plot at (1,0) between origin and (2,0) forces either a detour or a
-- trait-dependent override.
function M.test_mountain_impassable_for_land_unit()
    setup()
    local plots = installGrid(4, function(col, row, p)
        if col == 1 and row == 0 then
            p._isMountain = true
        end
        return p
    end)
    local unit = mkUnit(plots[0][0], {})
    local result = Pathfinder.findPath(unit, plots[2][0])
    T.truthy(result ~= nil, "there must still be a detour around the mountain")
    T.truthy(result.mpCost > 120, "detour should cost more than the direct two-hex path")
end

function M.test_hover_unit_ignores_mountain()
    setup()
    local plots = installGrid(4, function(col, row, p)
        if col == 1 and row == 0 then
            p._isMountain = true
        end
        return p
    end)
    local unit = mkUnit(plots[0][0], {
        domain = DomainTypes.DOMAIN_HOVER,
        promotions = { [PROMOTION_HOVERING_UNIT] = true },
    })
    local result = Pathfinder.findPath(unit, plots[2][0])
    T.eq(result.mpCost, 120, "hover straight-lines through mountain at 60/hex")
end

function M.test_carthage_crosses_mountain_with_end_turn()
    setup()
    GameInfo.Leaders = { [0] = { Type = "LEADER_DIDO" } }
    GameInfo.Traits = { TRAIT_PHOENICIAN_HERITAGE = { CrossesMountainsAfterGreatGeneral = true } }
    GameInfo.Leader_Traits = function()
        local rows = { { LeaderType = "LEADER_DIDO", TraitType = "TRAIT_PHOENICIAN_HERITAGE" } }
        local i = 0
        return function()
            i = i + 1
            return rows[i]
        end
    end
    local plots = installGrid(4, function(col, row, p)
        if col == 1 and row == 0 then
            p._isMountain = true
        end
        return p
    end)
    local unit = mkUnit(plots[0][0], {})
    Players[0].GetLeaderType = function()
        return 0
    end
    local result = Pathfinder.findPath(unit, plots[1][0])
    T.eq(result.turns, 1, "Carthage mountain crossing itself is one turn")
    local result2 = Pathfinder.findPath(unit, plots[2][0])
    T.eq(result2.turns, 2, "second hex after mountain should push into next turn")
end

-- 9. Closed enemy borders reject the step. Direct path through an enemy
-- tile must detour around it.
function M.test_closed_borders_block_path()
    setup()
    local plots = installGrid(4, function(col, row, p)
        if col == 1 and row == 0 then
            p._owner = 1
        end
        return p
    end)
    Players[1] = {
        _team = 1,
        GetTeam = function()
            return 1
        end,
        IsAlive = function()
            return true
        end,
        GetBuildingClassCount = function()
            return 0
        end,
        Units = function()
            return function()
                return nil
            end
        end,
    }
    Teams[1] = T.fakeTeam({})
    local unit = mkUnit(plots[0][0], {})
    local result = Pathfinder.findPath(unit, plots[2][0])
    T.truthy(result ~= nil, "a detour must exist")
    T.truthy(result.mpCost > 120, "detour must cost more than the direct 2-hex path")
end

-- 10. Great Wall border entry ends turn. Enemy owner holds the wonder;
-- stepping onto an owned plot consumes the whole turn. Compare against
-- an otherwise-equivalent enemy tile without the wonder.
function M.test_great_wall_tile_ends_turn()
    setup()
    local plots = installGrid(4, function(col, row, p)
        if col == 1 and row == 0 then
            p._owner = 1
        end
        return p
    end)
    Players[1] = {
        _team = 1,
        GetTeam = function()
            return 1
        end,
        IsAlive = function()
            return true
        end,
        GetBuildingClassCount = function(_, cls)
            return cls == BUILDINGCLASS_GREAT_WALL and 1 or 0
        end,
        Units = function()
            return function()
                return nil
            end
        end,
    }
    Teams[0] = T.fakeTeam({ atWar = { [1] = true } })
    Teams[1] = T.fakeTeam({ atWar = { [0] = true } })
    local unit = mkUnit(plots[0][0], {})
    -- Reinstall team after mkUnit so war flags aren't overwritten.
    Teams[0] = T.fakeTeam({ atWar = { [1] = true } })
    local result = Pathfinder.findPath(unit, plots[2][0])
    T.truthy(result ~= nil, "wall tile should still be enterable, just end turn")
    T.eq(result.turns, 2, "entering Great Wall tile ends turn, next hex = turn 2")
end

-- 11. ZoC drains remaining MP when a flanking plot holds an at-war
-- enemy combat unit. A 4-MP unit on the corridor baseline reaches
-- (2, 0) in one turn; with an enemy at (0, 1) flanking the first E
-- step, ZoC fires on step (0,0)->(1,0), zeroing MP. Step two must
-- then wait out the turn boundary, pushing arrival to turn 2.
function M.test_zoc_entry_ends_turn()
    setup()
    local plotsBase = installCorridor()
    local unitBase = mkUnit(plotsBase[0][0], { maxMoves = 240 })
    local baseline = Pathfinder.findPath(unitBase, plotsBase[2][0])
    T.truthy(baseline ~= nil, "corridor baseline should be reachable")
    T.eq(baseline.turns, 1, "2 grass hexes at 4 MP should finish in one turn")

    setup()
    local plots = installCorridor()
    local enemyUnit = T.fakeUnit({ owner = 1, team = 1, combat = true, invisible = false })
    enemyUnit._plot = plots[0][1]
    Players[1] = {
        _team = 1,
        GetTeam = function()
            return 1
        end,
        IsAlive = function()
            return true
        end,
        GetBuildingClassCount = function()
            return 0
        end,
        Units = function()
            local sent = false
            return function()
                if sent then
                    return nil
                end
                sent = true
                return enemyUnit
            end
        end,
    }
    Teams[1] = T.fakeTeam({ atWar = { [0] = true } })
    local unit = mkUnit(plots[0][0], { maxMoves = 240 })
    Teams[0] = T.fakeTeam({ atWar = { [1] = true } })
    local result = Pathfinder.findPath(unit, plots[2][0])
    T.truthy(result ~= nil, "corridor with ZoC must still be pathable")
    T.truthy(
        result.turns > baseline.turns,
        "ZoC entry must add at least one turn; got "
            .. tostring(result.turns)
            .. " vs baseline "
            .. tostring(baseline.turns)
    )
end

-- 12. Embarkation: land unit entering water ends turn; with flat-cost
-- promotion it's one MP instead.
function M.test_embarkation_ends_turn_without_flat_cost()
    setup()
    local plots = installGrid(4, function(col, row, p)
        if col >= 1 then
            p._isWater = true
            p._terrain = TERRAIN_COAST
        end
        return p
    end)
    local unit = mkUnit(plots[0][0], { canEmbark = true })
    local result = Pathfinder.findPath(unit, plots[1][0])
    T.eq(result.turns, 1, "the embark step itself fits in the current turn")
    local result2 = Pathfinder.findPath(unit, plots[2][0])
    T.eq(result2.turns, 2, "embark + second water hex spans two turns")
end

function M.test_embarkation_flat_cost_trait()
    setup()
    GameInfo.Leaders = { [0] = { Type = "LEADER_TEST" } }
    GameInfo.Traits = { TRAIT_TEST = { EmbarkedToLandFlatCost = true } }
    GameInfo.Leader_Traits = function()
        local rows = { { LeaderType = "LEADER_TEST", TraitType = "TRAIT_TEST" } }
        local i = 0
        return function()
            i = i + 1
            return rows[i]
        end
    end
    local plots = installGrid(4, function(col, row, p)
        if col >= 1 then
            p._isWater = true
            p._terrain = TERRAIN_COAST
        end
        return p
    end)
    local unit = mkUnit(plots[0][0], { canEmbark = true })
    Players[0].GetLeaderType = function()
        return 0
    end
    local result = Pathfinder.findPath(unit, plots[2][0])
    T.eq(result.turns, 1, "EmbarkedToLandFlatCost trait keeps embark + water step in one turn")
end

-- PROMOTION_FLAT_MOVEMENT_COST (Flight) is per-tile 1 MP that bypasses
-- the route discount. Engine: CvUnitMovement.cpp:165 returns
-- iMoveDenominator before the route branch ever sees this unit. So a
-- helicopter-shaped unit crosses forest at 60 (not 120) AND road at 60
-- (not the road's 20) -- the promotion flattens terrain without
-- stacking route speedups on top.
function M.test_flat_movement_cost_per_tile_ignores_terrain_and_route()
    setup()
    local plots = installGrid(4, function(col, row, p)
        if col == 1 and row == 0 then
            p._feature = FEAT_FOREST
        end
        if col == 2 and row == 0 then
            p._route = ROUTE_ROAD
        end
        if col == 3 and row == 0 then
            p._route = ROUTE_ROAD
        end
        return p
    end)
    local unit = mkUnit(plots[0][0], {
        maxMoves = 240,
        promotions = { [PROMOTION_FLAT_MOVEMENT_COST] = true },
    })
    local forestResult = Pathfinder.findPath(unit, plots[1][0])
    T.eq(forestResult.mpCost, 60, "flat-cost flattens forest's 120 to 60")

    setup()
    local plots2 = installGrid(4, function(col, row, p)
        if col == 2 and row == 0 then
            p._route = ROUTE_ROAD
        end
        if col == 3 and row == 0 then
            p._route = ROUTE_ROAD
        end
        return p
    end)
    local unit2 = mkUnit(plots2[2][0], {
        maxMoves = 240,
        promotions = { [PROMOTION_FLAT_MOVEMENT_COST] = true },
    })
    local roadResult = Pathfinder.findPath(unit2, plots2[3][0])
    T.eq(roadResult.mpCost, 60, "flat-cost ignores road's 20, stays at 60")
end

-- 13. Polynesia's EmbarkedAllWater trait permits water entry before
-- Optics. Absence of canEmbark would normally reject the step; the
-- trait flips ctx.canEmbark.
function M.test_polynesia_starts_embarked_without_optics()
    setup()
    GameInfo.Leaders = { [0] = { Type = "LEADER_KAMEHAMEHA" } }
    GameInfo.Traits = { TRAIT_WAYFINDING = { EmbarkedAllWater = true } }
    GameInfo.Leader_Traits = function()
        local rows = { { LeaderType = "LEADER_KAMEHAMEHA", TraitType = "TRAIT_WAYFINDING" } }
        local i = 0
        return function()
            i = i + 1
            return rows[i]
        end
    end
    local plots = installGrid(4, function(col, row, p)
        if col >= 1 then
            p._isWater = true
            p._terrain = TERRAIN_COAST
        end
        return p
    end)
    local unit = mkUnit(plots[0][0], { canEmbark = false })
    Players[0].GetLeaderType = function()
        return 0
    end
    local result, reason = Pathfinder.findPath(unit, plots[1][0])
    T.truthy(result ~= nil, "Polynesia should path into coast without Optics: " .. tostring(reason))
end

-- 14. Open borders are unidirectional. The pathfinder is entering THEIR
-- territory, so the question is whether THEIR team has granted US the
-- right to enter -- not whether we granted them ours. Two-step setup:
-- the wrong direction must NOT permit entry, the right one must.
function M.test_open_borders_uses_their_grant_not_ours()
    local function build()
        local plots = installGrid(4, function(col, row, p)
            if col == 1 and row == 0 then
                p._owner = 1
            end
            return p
        end)
        Players[1] = {
            _team = 1,
            GetTeam = function()
                return 1
            end,
            IsAlive = function()
                return true
            end,
            GetBuildingClassCount = function()
                return 0
            end,
            Units = function()
                return function()
                    return nil
                end
            end,
        }
        return plots
    end

    setup()
    local plotsA = build()
    -- Our team grants them OB, theirs does NOT grant us OB. We must NOT
    -- be able to transit their tile -- the discount goes the wrong way.
    Teams[0] = T.fakeTeam({ openBorders = { [1] = true } })
    Teams[1] = T.fakeTeam({})
    local unitA = mkUnit(plotsA[0][0], {})
    Teams[0] = T.fakeTeam({ openBorders = { [1] = true } })
    local resultA = Pathfinder.findPath(unitA, plotsA[2][0])
    T.truthy(resultA ~= nil, "detour around their territory must still exist")
    T.truthy(resultA.mpCost > 120, "must detour, not transit their territory")

    setup()
    local plotsB = build()
    Teams[0] = T.fakeTeam({})
    Teams[1] = T.fakeTeam({ openBorders = { [0] = true } })
    local unitB = mkUnit(plotsB[0][0], {})
    Teams[1] = T.fakeTeam({ openBorders = { [0] = true } })
    local resultB = Pathfinder.findPath(unitB, plotsB[2][0])
    T.eq(resultB.mpCost, 120, "their grant to us should permit straight transit")
end

-- 15. Barbarians live one slot above MAX_CIV_PLAYERS, so iterating
-- 0..MAX-1 misses them entirely. Place a barb combat unit so its ZoC
-- projects onto the corridor; expect the same end-turn surcharge as a
-- regular enemy.
function M.test_barbarian_zoc_projects()
    setup()
    local plots = installCorridor()
    local barbUnit = T.fakeUnit({ owner = 4, team = 4, combat = true, invisible = false })
    barbUnit._plot = plots[0][1]
    Players[4] = {
        GetTeam = function()
            return 4
        end,
        IsAlive = function()
            return true
        end,
        GetBuildingClassCount = function()
            return 0
        end,
        Units = function()
            local sent = false
            return function()
                if sent then
                    return nil
                end
                sent = true
                return barbUnit
            end
        end,
    }
    Teams[4] = T.fakeTeam({ atWar = { [0] = true } })
    local unit = mkUnit(plots[0][0], { maxMoves = 240 })
    Teams[0] = T.fakeTeam({ atWar = { [4] = true } })
    local result = Pathfinder.findPath(unit, plots[2][0])
    T.truthy(result ~= nil, "barb-ZoC corridor must still be pathable")
    T.truthy(result.turns > 1, "barb at MAX_CIV_PLAYERS slot must project ZoC; turns=" .. tostring(result.turns))
end

-- 16. ZoC fires only from at-war players. A neutral combat unit (not
-- at war, no open borders) sitting next to the corridor should not
-- inflate turn count. Without this check the path would gain a phantom
-- ZoC end-turn whenever a city-state or AI peer parks near the route.
function M.test_zoc_skips_non_war_units()
    setup()
    local plots = installCorridor()
    local neutralUnit = T.fakeUnit({ owner = 1, team = 1, combat = true, invisible = false })
    neutralUnit._plot = plots[0][1]
    Players[1] = {
        GetTeam = function()
            return 1
        end,
        IsAlive = function()
            return true
        end,
        GetBuildingClassCount = function()
            return 0
        end,
        Units = function()
            local sent = false
            return function()
                if sent then
                    return nil
                end
                sent = true
                return neutralUnit
            end
        end,
    }
    Teams[0] = T.fakeTeam({})
    Teams[1] = T.fakeTeam({})
    local unit = mkUnit(plots[0][0], { maxMoves = 240 })
    local result = Pathfinder.findPath(unit, plots[2][0])
    T.truthy(result ~= nil, "neutral-adjacent corridor should be pathable")
    T.eq(result.turns, 1, "non-war unit must not project ZoC")
end

-- 17. Enemies in fog don't project ZoC. The engine doesn't surface a
-- ZoC end-turn for a unit you can't see, so neither should the preview.
function M.test_zoc_skips_fogged_enemies()
    setup()
    local plots = installCorridor()
    plots[0][1]._isVisible = false
    local enemyUnit = T.fakeUnit({ owner = 1, team = 1, combat = true, invisible = false })
    enemyUnit._plot = plots[0][1]
    Players[1] = {
        GetTeam = function()
            return 1
        end,
        IsAlive = function()
            return true
        end,
        GetBuildingClassCount = function()
            return 0
        end,
        Units = function()
            local sent = false
            return function()
                if sent then
                    return nil
                end
                sent = true
                return enemyUnit
            end
        end,
    }
    Teams[1] = T.fakeTeam({ atWar = { [0] = true } })
    local unit = mkUnit(plots[0][0], { maxMoves = 240 })
    Teams[0] = T.fakeTeam({ atWar = { [1] = true } })
    local result = Pathfinder.findPath(unit, plots[2][0])
    T.eq(result.turns, 1, "ZoC from a fog-hidden unit must not fire")
end

-- 18. Iroquois MoveFriendlyWoodsAsRoad treats friendly forest as a road
-- for *cost* but not as a *bridge*. A river crossing into a friendly
-- forest must still end the turn for a non-Engineering, non-Amphibious
-- unit -- the trait is a movement overlay, not infrastructure.
function M.test_woods_as_road_does_not_waive_river_crossing()
    setup()
    GameInfo.Leaders = { [0] = { Type = "LEADER_HIAWATHA" } }
    GameInfo.Traits = { TRAIT_GREAT_WARPATH = { MoveFriendlyWoodsAsRoad = true } }
    GameInfo.Leader_Traits = function()
        local rows = { { LeaderType = "LEADER_HIAWATHA", TraitType = "TRAIT_GREAT_WARPATH" } }
        local i = 0
        return function()
            i = i + 1
            return rows[i]
        end
    end
    -- Force the corridor through the river-forest tile by walling off
    -- row-1 / row-(-1) with mountains. Without this block, the detour
    -- via a non-river forest step at (0,1) avoids the river entirely
    -- and makes the test vacuous.
    local plots = installGrid(4, function(col, row, p)
        if col == 1 and row == 0 then
            p._feature = FEAT_FOREST
            p._owner = 0
        elseif row ~= 0 then
            p._isMountain = true
        end
        return p
    end)
    plots[0][0]._riverCrossings[plots[1][0]] = true
    plots[1][0]._riverCrossings[plots[0][0]] = true
    local unit = mkUnit(plots[0][0], {})
    Players[0].GetLeaderType = function()
        return 0
    end
    local result = Pathfinder.findPath(unit, plots[2][0])
    T.eq(result.turns, 2, "river-into-friendly-forest must still cost a turn for Iroquois without Engineering")
end

-- 19. A tile occupied by a visible enemy COMBAT unit blocks transit
-- when it's on the path but not the destination -- the engine treats
-- that as an attack, a different code path than move. When it IS the
-- destination, the move resolves as an attack on arrival, so the
-- pathfinder returns a path with the final step charging full MP
-- (combat consumes the turn). Non-combat enemies do not block -- see
-- the civilian-transit test for that branch.
function M.test_enemy_combat_intermediate_blocks_transit()
    setup()
    local enemyCombat = T.fakeUnit({ owner = 1, team = 1, combat = true, invisible = false })
    -- Mountain-walled corridor along row 0 so the enemy at (1, 0) is the
    -- only reachable path between (0, 0) and (2, 0); without the walls
    -- the pathfinder detours through offset rows.
    local plots = installGrid(3, function(col, row, p)
        if row ~= 0 then
            p._plotType = PlotTypes.PLOT_MOUNTAIN
            p.IsMountain = function()
                return true
            end
        end
        if col == 1 and row == 0 then
            p._units = { enemyCombat }
        end
        return p
    end)
    local unit = mkUnit(plots[0][0], {})
    local result, reason = Pathfinder.findPath(unit, plots[2][0])
    T.truthy(result == nil, "enemy combat unit on the only path must block")
    T.eq(reason, "unreachable")
end

function M.test_enemy_combat_target_permits_attack_step()
    setup()
    local enemyCombat = T.fakeUnit({ owner = 1, team = 1, combat = true, invisible = false })
    local plots = installGrid(2, function(col, row, p)
        if col == 1 and row == 0 then
            p._units = { enemyCombat }
        end
        return p
    end)
    local unit = mkUnit(plots[0][0], {})
    local result = Pathfinder.findPath(unit, plots[1][0])
    T.truthy(result ~= nil, "enemy combat unit at destination must allow attack-on-arrival path")
    -- One step into the enemy plot consumes the unit's full remaining
    -- MP (combat ends the turn). With a 120 maxMoves unit at full MP,
    -- the reported mpCost should be 120 even though the underlying
    -- terrain is plain grass.
    T.eq(result.mpCost, 120, "attack step costs full MP, not tile cost")
end

-- Non-combat enemies (workers, Great People) get captured by a move
-- rather than attacked, so a tile holding only civilians is a valid
-- intermediate and destination for move-preview. Without this, the
-- user hears "no path" for a perfectly legal capture.
function M.test_enemy_civilian_permits_capture_transit()
    setup()
    local enemyCiv = T.fakeUnit({ owner = 1, team = 1, combat = false, invisible = false })
    local plots = installGrid(2, function(col, row, p)
        if col == 1 and row == 0 then
            p._units = { enemyCiv }
        end
        return p
    end)
    local unit = mkUnit(plots[0][0], {})
    local result = Pathfinder.findPath(unit, plots[1][0])
    T.truthy(result ~= nil, "non-combat enemy must not block move-preview")
    T.eq(result.mpCost, 60, "straight grass step cost, capture doesn't surcharge")
end

-- 20. Friendly stacking limit. A non-start plot already holding a
-- friendly unit of the same stacking class blocks the path.
function M.test_friendly_stack_blocks_transit()
    setup()
    local plots = installGrid(4, function(col, row, p)
        if col == 1 and row == 0 then
            p._friendlyStackCount = 1
        end
        return p
    end)
    local unit = mkUnit(plots[0][0], {})
    local result = Pathfinder.findPath(unit, plots[2][0])
    T.truthy(result ~= nil, "a detour around the stacked tile must exist")
    T.truthy(result.mpCost > 120, "path must avoid the friendly-stacked tile")
end

-- 21. mpCost reporting accounts for partial starting MP. A 2-MP unit
-- that's already spent 1 MP (movesLeft = 60) and walks one grass hex
-- to a target should report cost = 60, not 120 -- the formula carried
-- a (maxMoves - startMP) offset before this fix.
function M.test_mpcost_subtracts_partial_starting_offset()
    setup()
    local plots = installGrid(4)
    local unit = mkUnit(plots[0][0], { maxMoves = 120, movesLeft = 60 })
    local result = Pathfinder.findPath(unit, plots[1][0])
    T.eq(result.mpCost, 60, "one grass step from 1-MP-left start should report 60 in 60ths")
end

-- 22. Heuristic admissibility for a 1-MP unit. A* returns the first
-- goal popped from the open set; with an inadmissible heuristic the
-- first popped goal can be a suboptimal one. For 1-MP units, road cost
-- is 10/step (FlatMovement * maxMoves/60 = 10 * 1 = 10) but the
-- prior heuristic estimated 2 60ths/step minimum -- 1/5 the truth.
-- Two paths to the target: 2-hex direct grass (cost 120) vs 3-hex road
-- detour (cost 30). A* must return the cheaper road path.
function M.test_one_mp_unit_picks_optimal_road_detour()
    setup()
    local plots = installGrid(4, function(col, row, p)
        -- Road along the row-1 detour: (0,0) -> (0,1) -> (1,1) -> (1,0).
        if (col == 0 and row == 1) or (col == 1 and row == 1) or (col == 1 and row == 0) then
            p._route = ROUTE_ROAD
        end
        if col == 0 and row == 0 then
            p._route = ROUTE_ROAD
        end
        return p
    end)
    local unit = mkUnit(plots[0][0], { maxMoves = 60 })
    local result = Pathfinder.findPath(unit, plots[1][0])
    T.truthy(result ~= nil, "1-MP unit must reach target")
    -- Road path: 3 steps * 10 60ths = 30. Direct grass: 1 step * 60 = 60.
    -- A returned mpCost > 30 means A* committed to grass before fully
    -- exploring the cheaper road detour -- the inadmissibility symptom.
    T.truthy(result.mpCost <= 30, "must take road detour, got " .. tostring(result.mpCost))
end

-- 23. Destination in fog short-circuits to "unexplored". Without the
-- early bail, A* would exhaust trying to enter the unrevealed tile and
-- mis-report "unreachable" -- which conflates "you've been there, no
-- way through" with "you've never seen it."
function M.test_unexplored_destination_short_circuits()
    setup()
    local plots = installGrid(2, function(col, row, p)
        if col == 1 and row == 0 then
            p._isRevealed = false
        end
        return p
    end)
    local unit = mkUnit(plots[0][0], {})
    local result, reason = Pathfinder.findPath(unit, plots[1][0])
    T.truthy(result == nil, "fogged destination must not return a path")
    T.eq(reason, "unexplored")
end

-- 24. Fully-impassable surround returns unreachable. Target ringed by
-- mountains; a non-hover land unit cannot enter.
function M.test_unreachable_target_returns_reason()
    setup()
    local plots = installGrid(3, function(col, row, p)
        -- Mountain ring around (2, 0).
        if
            (col == 1 and row == 0)
            or (col == 3 and row == 0)
            or (col == 2 and row == -1)
            or (col == 2 and row == 1)
        then
            p._isMountain = true
        end
        -- Also block diagonal neighbors so the odd-row offsets don't
        -- accidentally leave a gap through (even vs. odd row parity
        -- gives six unique neighbors; mount them all).
        if col == 2 and (row == -1 or row == 1) then
            p._isMountain = true
        end
        if col == 1 and (row == -1 or row == 1) then
            p._isMountain = true
        end
        if col == 3 and (row == -1 or row == 1) then
            p._isMountain = true
        end
        return p
    end)
    local unit = mkUnit(plots[0][0], {})
    local result, reason = Pathfinder.findPath(unit, plots[2][0])
    T.truthy(result == nil, "surrounded target must be unreachable")
    T.eq(reason, "unreachable")
end

-- Impassable feature (FEATURE_ICE for a naval unit). The engine reads
-- GameInfo.Features.Impassable via IsTeamImpassable; Lua's no-arg
-- Plot:IsImpassable() covers mountains only, so the pathfinder has to
-- consult the feature XML directly. Natural wonders hit the same path.
function M.test_impassable_feature_blocks_ship()
    setup()
    local FEAT_ICE = 2
    GameInfo.Features[FEAT_ICE] = { Type = "FEATURE_ICE", Movement = 1, Impassable = true }
    local plots = installGrid(4, function(col, row, p)
        p._isWater = true
        p._terrain = TERRAIN_COAST
        if col == 1 and row == 0 then
            p._feature = FEAT_ICE
        end
        return p
    end)
    local unit = mkUnit(plots[0][0], { domain = DomainTypes.DOMAIN_SEA, maxMoves = 240 })
    local result = Pathfinder.findPath(unit, plots[2][0])
    T.truthy(result ~= nil, "detour around ice must exist")
    T.truthy(result.mpCost > 120, "path must detour, not go through ice; got " .. tostring(result.mpCost))
end

-- Great Wall is obsoleted when the WALL OWNER researches Dynamite, not
-- the attacker. CvTeam.cpp:742 decrements the border-obstacle counter
-- on the wall owner's team when the tech completes; attackers with or
-- without Dynamite pass through unaffected as long as the defender has
-- it. The pathfinder skips building the wall set for obsoleted owners.
function M.test_great_wall_obsolete_after_owner_dynamite()
    setup()
    local TECH_DYNAMITE = 12
    GameInfoTypes.TECH_DYNAMITE = TECH_DYNAMITE
    local plots = installGrid(4, function(col, row, p)
        if col == 1 and row == 0 then
            p._owner = 1
        end
        return p
    end)
    Players[1] = {
        _team = 1,
        GetTeam = function()
            return 1
        end,
        IsAlive = function()
            return true
        end,
        GetBuildingClassCount = function(_, cls)
            return cls == BUILDINGCLASS_GREAT_WALL and 1 or 0
        end,
        Units = function()
            return function()
                return nil
            end
        end,
    }
    Teams[1] = T.fakeTeam({
        atWar = { [0] = true },
        techs = { [TECH_DYNAMITE] = true },
    })
    local unit = mkUnit(plots[0][0], {})
    Teams[0] = T.fakeTeam({ atWar = { [1] = true } })
    local result = Pathfinder.findPath(unit, plots[2][0])
    T.truthy(result ~= nil, "GW-obsolete enemy tile must be transitable")
    T.eq(result.turns, 1, "owner's Dynamite turns GW off; no end-turn surcharge")
    T.eq(result.mpCost, 120, "straight 2-hex grass cost with GW neutralized")
end

-- Asymmetric routes: one endpoint road, other railroad. Engine takes
-- MAX of the two endpoint costs (slower dominates) per
-- CvUnitMovement.cpp:93. Old code read the destination only and
-- under-charged when the faster route was at `to`.
function M.test_route_cost_uses_max_of_endpoints()
    setup()
    local ROUTE_RAIL = 1
    GameInfo.Routes[ROUTE_RAIL] = { Type = "ROUTE_RAILROAD", FlatMovement = 1 }
    local plots = installGrid(4, function(col, row, p)
        if col == 0 and row == 0 then
            p._route = ROUTE_ROAD
        end
        if col == 1 and row == 0 then
            p._route = ROUTE_RAIL
        end
        return p
    end)
    local unit = mkUnit(plots[0][0], {})
    local result = Pathfinder.findPath(unit, plots[1][0])
    -- Road=10, Rail=1 for 2-MP unit -> per-step max(10, 1) * 2 = 20.
    T.eq(result.mpCost, 20, "road+rail endpoints must pick slower road cost, not rail")
end

-- Naval transit through a friendly non-team city. The DOMAIN_SEA branch
-- used to return nil for any non-war non-team city, blocking a naval
-- unit from transiting a coastal ally's city under Open Borders even
-- though the engine permits it.
function M.test_naval_open_borders_city_transit()
    setup()
    local city = T.fakeCity({ owner = 1 })
    city.GetTeam = function()
        return 1
    end
    local plots = installGrid(4, function(col, row, p)
        p._isWater = true
        p._terrain = TERRAIN_COAST
        if col == 1 and row == 0 then
            p._isWater = false
            p._terrain = TERRAIN_GRASS
            p._isCity = true
            p._city = city
            p._owner = 1
        end
        return p
    end)
    Players[1] = {
        _team = 1,
        GetTeam = function()
            return 1
        end,
        IsAlive = function()
            return true
        end,
        GetBuildingClassCount = function()
            return 0
        end,
        Units = function()
            return function()
                return nil
            end
        end,
    }
    Teams[1] = T.fakeTeam({ openBorders = { [0] = true } })
    local unit = mkUnit(plots[0][0], { domain = DomainTypes.DOMAIN_SEA, maxMoves = 240 })
    Teams[1] = T.fakeTeam({ openBorders = { [0] = true } })
    local result = Pathfinder.findPath(unit, plots[1][0])
    T.truthy(result ~= nil, "OB-friendly city should be naval-reachable")
    T.eq(result.turns, 1, "city transit fits in one turn")
end

-- Step list reconstruction: A* must publish the chosen path as an array
-- of DirectionTypes constants from start to goal, one per hex stepped.
-- Three eastward grass tiles produce three DIRECTION_EAST entries; this
-- pins the parent-walk reconstruction order (start at goal, walk back,
-- then reverse so element 1 is the first step the unit takes).
function M.test_directions_returned_for_straight_line()
    setup()
    local plots = installGrid(4)
    local unit = mkUnit(plots[0][0], {})
    local result = Pathfinder.findPath(unit, plots[3][0])
    T.truthy(result ~= nil, "expected path")
    T.truthy(result.directions ~= nil, "result must include a directions array")
    T.eq(#result.directions, 3, "three hexes east means three steps")
    T.eq(result.directions[1], DirectionTypes.DIRECTION_EAST)
    T.eq(result.directions[2], DirectionTypes.DIRECTION_EAST)
    T.eq(result.directions[3], DirectionTypes.DIRECTION_EAST)
end

-- Detour around a mountain forces the path off the straight line,
-- exposing the multi-direction step list. Mountain at (1,0) blocks the
-- direct E-E-E route from (0,0) to (2,0); the detour must take a
-- non-east step at some point and end at the goal.
function M.test_directions_track_detour_around_mountain()
    setup()
    local plots = installGrid(4, function(col, row, p)
        if col == 1 and row == 0 then
            p._isMountain = true
        end
        return p
    end)
    local unit = mkUnit(plots[0][0], {})
    local result = Pathfinder.findPath(unit, plots[2][0])
    T.truthy(result ~= nil, "detour must exist")
    T.truthy(#result.directions >= 2, "detour requires at least two steps")
    local hasNonEast = false
    for _, dir in ipairs(result.directions) do
        if dir ~= DirectionTypes.DIRECTION_EAST then
            hasNonEast = true
            break
        end
    end
    T.truthy(hasNonEast, "detour must include at least one non-east step")
end

return M
