-- WaypointsCore tests. Two groups: pass-through assertions on
-- Waypoints.queuedActionStatus (seeded cache, fast), and integration
-- tests on compute() that drive a cache miss and exercise the engine-
-- API plumbing for move-to / route-to legs through stubs.

local T = require("support")
local M = {}

-- ===== Pass-through group =====
-- Seeds civvaccess_shared.waypointsCache with a pre-baked snapshot so
-- activeSnapshot's cache-hit path returns it directly, skipping
-- compute(). Verifies the shape contract that statusToken consumes.

local function setupWithCache(chunks, ux, uy)
    civvaccess_shared = civvaccess_shared or {}
    dofile("src/dlc/UI/InGame/CivVAccess_WaypointsCore.lua")
    Game = Game or {}
    Game.GetActivePlayer = function()
        return 0
    end
    local unit = {
        _id = 1,
        _x = ux or 0,
        _y = uy or 0,
        _owner = 0,
        _queue = {},
    }
    function unit:GetID()
        return self._id
    end
    function unit:GetX()
        return self._x
    end
    function unit:GetY()
        return self._y
    end
    function unit:GetOwner()
        return self._owner
    end
    function unit:GetMissionQueue()
        return self._queue
    end
    UI = UI or {}
    UI.GetHeadSelectedUnit = function()
        return unit
    end
    civvaccess_shared.waypointsCache = {
        unitID = unit._id,
        unitX = unit._x,
        unitY = unit._y,
        sig = "",
        waypoints = {},
        chunks = chunks,
    }
    return unit
end

-- Pure-move queue: one move chunk pass-through.
function M.test_queued_action_status_passes_through_move_chunk()
    setupWithCache({
        { kind = "move", segments = { "2ne", "2e", "1ne" }, turns = 3 },
    }, 0, 0)
    local status = Waypoints.queuedActionStatus()
    T.eq(#status.chunks, 1, "one chunk")
    T.eq(status.chunks[1].kind, "move", "chunk kind")
    T.eq(status.chunks[1].turns, 3, "chunk turns")
    T.eq(#status.chunks[1].segments, 3, "segment count")
end

-- Pure-route queue: one route chunk with routeName pass-through.
function M.test_queued_action_status_passes_through_route_chunk()
    setupWithCache({
        { kind = "route", segments = { "1e", "1e", "1e" }, turns = 9, routeName = "road" },
    }, 0, 0)
    local status = Waypoints.queuedActionStatus()
    T.eq(#status.chunks, 1, "one chunk")
    T.eq(status.chunks[1].kind, "route", "chunk kind")
    T.eq(status.chunks[1].routeName, "road", "route name")
    T.eq(status.chunks[1].turns, 9, "build turns")
end

-- Mixed queue: chunks pass through in order so the renderer can join
-- them with the right separator and arrive suffix.
function M.test_queued_action_status_passes_through_multi_chunk()
    setupWithCache({
        { kind = "route", segments = { "1e", "1e", "1e" }, turns = 9, routeName = "road" },
        { kind = "move", segments = { "2e", "1ne" }, turns = 2 },
    }, 0, 0)
    local status = Waypoints.queuedActionStatus()
    T.eq(#status.chunks, 2, "two chunks")
    T.eq(status.chunks[1].kind, "route", "first chunk is route")
    T.eq(status.chunks[2].kind, "move", "second chunk is move")
end

function M.test_queued_action_status_nil_on_empty_chunks()
    setupWithCache({}, 0, 0)
    T.eq(Waypoints.queuedActionStatus(), nil, "empty chunks returns nil")
end

-- Defensive: a chunk with no segments would render as "queued move,
-- N turns: , arrive". queuedActionStatus rejects the whole status
-- rather than risk that.
function M.test_queued_action_status_nil_on_chunk_with_empty_segments()
    setupWithCache({
        { kind = "move", segments = {}, turns = 0 },
    }, 0, 0)
    T.eq(Waypoints.queuedActionStatus(), nil, "empty segment chunk returns nil")
end

function M.test_queued_action_status_nil_when_no_head_selected_unit()
    setupWithCache({
        { kind = "move", segments = { "1e" }, turns = 1 },
    }, 0, 0)
    UI.GetHeadSelectedUnit = function()
        return nil
    end
    T.eq(Waypoints.queuedActionStatus(), nil, "no head selection returns nil")
end

-- ===== Compute integration group =====
-- Drives a cache miss with a stubbed engine surface so compute() runs
-- end-to-end. Verifies the parts of compute() that aren't trivial:
-- chunk grouping, route-build path math, and the walked-through tile
-- direction fold.

local function fakePlot(x, y, opts)
    opts = opts or {}
    return {
        _x = x,
        _y = y,
        _isCity = opts.isCity or false,
        _routeType = opts.routeType or -1,
        _buildTurnsLeft = opts.buildTurnsLeft or 3,
        _owner = opts.owner or 0,
        GetX = function(self)
            return self._x
        end,
        GetY = function(self)
            return self._y
        end,
        IsCity = function(self)
            return self._isCity
        end,
        GetRouteType = function(self)
            return self._routeType
        end,
        GetBuildTurnsLeft = function(self, _buildId, _owner, _extra1, _extra2)
            return self._buildTurnsLeft
        end,
        GetOwner = function(self)
            return self._owner
        end,
        GetPlotIndex = function(self)
            return self._x * 100 + self._y
        end,
    }
end

-- Sets up Map.GetPlot to return fakePlots from a coord-keyed table, and
-- installs the GameInfoTypes / GameInfo / engine globals compute() needs.
local function setupCompute(opts)
    civvaccess_shared = civvaccess_shared or {}
    civvaccess_shared.waypointsCache = nil
    dofile("src/dlc/UI/InGame/CivVAccess_WaypointsCore.lua")

    GameInfoTypes = GameInfoTypes or {}
    GameInfoTypes.MISSION_MOVE_TO = 1
    GameInfoTypes.MISSION_ROUTE_TO = 2
    GameInfoTypes.MISSION_MOVE_TO_UNIT = 3
    GameInfoTypes.MISSION_EMBARK = 4
    GameInfoTypes.MISSION_DISEMBARK = 5
    GameInfoTypes.MISSION_SWAP_UNITS = 6

    GameInfo = GameInfo or {}
    GameInfo.Routes = {
        [0] = { Description = "TXT_KEY_ROUTE_ROAD", Value = 1 },
        [1] = { Description = "TXT_KEY_ROUTE_RAILROAD", Value = 2 },
    }

    Game = Game or {}
    Game.GetActivePlayer = function()
        return 0
    end
    Game.GetBuildRoutePath = opts.getBuildRoutePath or function()
        return {}
    end

    local plots = opts.plots or {}
    Map = Map or {}
    Map.GetPlot = function(x, y)
        return plots[x .. "," .. y]
    end

    Locale = Locale or {}
    Locale.ConvertTextKey = function(key)
        if key == "TXT_KEY_ROUTE_ROAD" then
            return "Road"
        end
        if key == "TXT_KEY_ROUTE_RAILROAD" then
            return "Railroad"
        end
        return key
    end
    Locale.ToLower = function(s)
        return s:lower()
    end

    local unit = {
        _id = 1,
        _x = opts.unitX or 0,
        _y = opts.unitY or 0,
        _owner = 0,
        _queue = opts.queue or {},
        _plot = plots[(opts.unitX or 0) .. "," .. (opts.unitY or 0)],
        _buildType = opts.unitBuildType or -1,
    }
    function unit:GetID()
        return self._id
    end
    function unit:GetX()
        return self._x
    end
    function unit:GetY()
        return self._y
    end
    function unit:GetOwner()
        return self._owner
    end
    function unit:GetPlot()
        return self._plot
    end
    function unit:GetMissionQueue()
        return self._queue
    end
    function unit:GetBuildType()
        return self._buildType
    end
    function unit:ComputePath(fromPlot, toPlot, _flags)
        local nodes = (opts.computePath and opts.computePath(fromPlot, toPlot)) or {}
        return nodes, #nodes > 0, opts.legTurns or 1
    end
    function unit:GetBestBuildRoute(_fromPlot)
        if opts.bestBuildRoute then
            return opts.bestBuildRoute()
        end
        return -1, -1
    end
    function unit:WorkRate(_team, _buildId)
        return opts.workRate or 100
    end
    UI = UI or {}
    UI.GetHeadSelectedUnit = function()
        return unit
    end
    return unit
end

-- A single MOVE_TO leg with three turn-end stops and a final
-- destination produces one move chunk whose segments are the
-- direction strings between stops.
function M.test_compute_move_to_produces_move_chunk()
    local plots = {
        ["0,0"] = fakePlot(0, 0),
        ["3,0"] = fakePlot(3, 0),
    }
    setupCompute({
        plots = plots,
        unitX = 0,
        unitY = 0,
        queue = { { mission = 1, data1 = 3, data2 = 0, flags = 0 } },
        computePath = function()
            return {
                { x = 0, y = 0, moves = 100 },
                { x = 1, y = 0, moves = 0 },
                { x = 2, y = 0, moves = 0 },
                { x = 3, y = 0, moves = 100 },
            }
        end,
        legTurns = 3,
    })
    local status = Waypoints.queuedActionStatus()
    T.eq(#status.chunks, 1, "one chunk")
    local c = status.chunks[1]
    T.eq(c.kind, "move", "kind")
    T.eq(c.turns, 3, "turns")
    T.eq(#c.segments, 3, "three segments (two turn-ends + leg final)")
    T.eq(c.segments[1], "1e", "first segment")
    T.eq(c.segments[2], "1e", "second segment")
    T.eq(c.segments[3], "1e", "third segment")
end

-- A single ROUTE_TO leg whose build path covers three tiles, all
-- needing 3 build turns each, produces one route chunk named "road"
-- with three segments summing to 9 turns.
function M.test_compute_route_to_produces_route_chunk()
    local plots = {
        ["0,0"] = fakePlot(0, 0),
        ["1,0"] = fakePlot(1, 0),
        ["2,0"] = fakePlot(2, 0),
        ["3,0"] = fakePlot(3, 0),
    }
    setupCompute({
        plots = plots,
        unitX = 0,
        unitY = 0,
        queue = { { mission = 2, data1 = 3, data2 = 0, flags = 0 } },
        bestBuildRoute = function()
            return 0, 100
        end,
        getBuildRoutePath = function()
            return {
                { x = 0, y = 0 },
                { x = 1, y = 0 },
                { x = 2, y = 0 },
                { x = 3, y = 0 },
            }
        end,
    })
    local status = Waypoints.queuedActionStatus()
    T.eq(#status.chunks, 1, "one chunk")
    local c = status.chunks[1]
    T.eq(c.kind, "route", "kind")
    T.eq(c.routeName, "road", "route name (lowercased)")
    T.eq(c.turns, 9, "summed build turns (3 tiles x 3 turns)")
    T.eq(#c.segments, 3, "three build stops")
    T.eq(c.segments[1], "1e", "first segment")
end

-- A ROUTE_TO leg whose first build path tile already has a road at the
-- target tier: that tile contributes 0 build turns, so its direction
-- folds into the next emitted segment. The user hears the cumulative
-- reach to the first real build.
function M.test_compute_route_to_skips_walked_through_tile_and_folds_direction()
    local plots = {
        ["0,0"] = fakePlot(0, 0),
        -- Already at road tier: no build needed.
        ["1,0"] = fakePlot(1, 0, { routeType = 0 }),
        ["2,0"] = fakePlot(2, 0),
        ["3,0"] = fakePlot(3, 0),
    }
    setupCompute({
        plots = plots,
        unitX = 0,
        unitY = 0,
        queue = { { mission = 2, data1 = 3, data2 = 0, flags = 0 } },
        bestBuildRoute = function()
            return 0, 100
        end,
        getBuildRoutePath = function()
            return {
                { x = 0, y = 0 },
                { x = 1, y = 0 },
                { x = 2, y = 0 },
                { x = 3, y = 0 },
            }
        end,
    })
    local status = Waypoints.queuedActionStatus()
    local c = status.chunks[1]
    T.eq(#c.segments, 2, "walked-through tile produces no segment")
    -- Tile 1 was walked through, so segment 1 reaches from (0, 0) to
    -- the first real build at (2, 0) -- direction is two-east.
    T.eq(c.segments[1], "2e", "first segment folds past the walked-through tile")
    T.eq(c.segments[2], "1e", "second segment measured from last real build")
    T.eq(c.turns, 6, "summed build turns (2 tiles x 3 turns)")
end

-- Two consecutive MOVE_TO legs merge into one move chunk. The user
-- hears one announcement rather than "queued move ..., then queued
-- move ...", because the queue is semantically one continuous move.
function M.test_compute_consecutive_move_legs_merge_into_one_chunk()
    local plots = {
        ["0,0"] = fakePlot(0, 0),
        ["2,0"] = fakePlot(2, 0),
        ["4,0"] = fakePlot(4, 0),
    }
    setupCompute({
        plots = plots,
        unitX = 0,
        unitY = 0,
        queue = {
            { mission = 1, data1 = 2, data2 = 0, flags = 0 },
            { mission = 1, data1 = 4, data2 = 0, flags = 0 },
        },
        computePath = function(fromPlot, toPlot)
            -- Cheap two-node path from fromPlot to toPlot.
            return {
                { x = fromPlot:GetX(), y = fromPlot:GetY(), moves = 100 },
                { x = toPlot:GetX(), y = toPlot:GetY(), moves = 100 },
            }
        end,
        legTurns = 1,
    })
    local status = Waypoints.queuedActionStatus()
    T.eq(#status.chunks, 1, "one merged chunk")
    T.eq(status.chunks[1].kind, "move", "still a move chunk")
    T.eq(#status.chunks[1].segments, 2, "two segments")
    T.eq(status.chunks[1].turns, 2, "summed turns across merged legs")
end

-- Mixed queue (rare in practice but possible): a ROUTE_TO followed by
-- a MOVE_TO produces two chunks in order. The renderer will join them
-- with the same "then" used between segments and append "arrive" once.
function M.test_compute_mixed_queue_produces_two_chunks()
    local plots = {
        ["0,0"] = fakePlot(0, 0),
        ["1,0"] = fakePlot(1, 0),
        ["3,0"] = fakePlot(3, 0),
        ["5,0"] = fakePlot(5, 0),
    }
    setupCompute({
        plots = plots,
        unitX = 0,
        unitY = 0,
        queue = {
            { mission = 2, data1 = 1, data2 = 0, flags = 0 },
            { mission = 1, data1 = 5, data2 = 0, flags = 0 },
        },
        bestBuildRoute = function()
            return 0, 100
        end,
        getBuildRoutePath = function(fx, fy, tx, ty)
            return {
                { x = fx, y = fy },
                { x = tx, y = ty },
            }
        end,
        computePath = function(fromPlot, toPlot)
            return {
                { x = fromPlot:GetX(), y = fromPlot:GetY(), moves = 100 },
                { x = toPlot:GetX(), y = toPlot:GetY(), moves = 100 },
            }
        end,
        legTurns = 1,
    })
    local status = Waypoints.queuedActionStatus()
    T.eq(#status.chunks, 2, "two chunks for mixed queue")
    T.eq(status.chunks[1].kind, "route", "first chunk is route (from MISSION_ROUTE_TO)")
    T.eq(status.chunks[1].routeName, "road", "route name")
    T.eq(status.chunks[2].kind, "move", "second chunk is move (from MISSION_MOVE_TO)")
end

-- Multi-leg queue where leg 1's route path is entirely already roaded:
-- leg 1 produces no chunk (no work to do) but leg 2's segments must
-- still be measured from leg 1's destination, not the stale prior
-- anchor. Without anchor advancement on the empty-stops branch, leg 2's
-- direction would point from the wrong origin.
function M.test_compute_route_leg_with_no_stops_advances_anchor_for_next_leg()
    local plots = {
        ["0,0"] = fakePlot(0, 0),
        -- Leg 1's whole path is already at-tier (routeType=0).
        ["1,0"] = fakePlot(1, 0, { routeType = 0 }),
        ["2,0"] = fakePlot(2, 0, { routeType = 0 }),
        ["4,0"] = fakePlot(4, 0),
    }
    setupCompute({
        plots = plots,
        unitX = 0,
        unitY = 0,
        queue = {
            { mission = 2, data1 = 2, data2 = 0, flags = 0 },
            { mission = 1, data1 = 4, data2 = 0, flags = 0 },
        },
        bestBuildRoute = function()
            return 0, 100
        end,
        getBuildRoutePath = function(fx, fy, tx, ty)
            return {
                { x = fx, y = fy },
                { x = 1, y = 0 },
                { x = tx, y = ty },
            }
        end,
        computePath = function(fromPlot, toPlot)
            return {
                { x = fromPlot:GetX(), y = fromPlot:GetY(), moves = 100 },
                { x = toPlot:GetX(), y = toPlot:GetY(), moves = 100 },
            }
        end,
        legTurns = 1,
    })
    local status = Waypoints.queuedActionStatus()
    -- Leg 1 contributed no chunk. Leg 2 is the only chunk; its segment
    -- is measured from leg 1's destination (2, 0), not from the unit's
    -- original anchor (0, 0). Direction (2,0) -> (4,0) is "2e", not
    -- "4e".
    T.eq(#status.chunks, 1, "one chunk for the surviving leg")
    T.eq(status.chunks[1].kind, "move", "second leg is a move")
    T.eq(status.chunks[1].segments[1], "2e", "anchor advanced past empty-stops route leg")
end

-- Route-to leg's flat waypoint list (the scanner / cursor view) must
-- match the route-build stops the chunk segments describe -- not the
-- movement pathfinder's turn-end stops. Both views should agree on
-- which plots are "stops on this queue" so the scanner doesn't show
-- extra tiles the speech rung skipped.
function M.test_compute_route_to_waypoints_match_route_build_stops()
    local plots = {
        ["0,0"] = fakePlot(0, 0),
        ["1,0"] = fakePlot(1, 0),
        ["2,0"] = fakePlot(2, 0),
        ["3,0"] = fakePlot(3, 0),
    }
    setupCompute({
        plots = plots,
        unitX = 0,
        unitY = 0,
        queue = { { mission = 2, data1 = 3, data2 = 0, flags = 0 } },
        bestBuildRoute = function()
            return 0, 100
        end,
        getBuildRoutePath = function()
            return {
                { x = 0, y = 0 },
                { x = 1, y = 0 },
                { x = 2, y = 0 },
                { x = 3, y = 0 },
            }
        end,
    })
    -- Three build stops along the path (path[1] is the unit's plot,
    -- always skipped). Waypoints.list should list those exactly --
    -- no extras from a movement pathfinder.
    local wps = Waypoints.list()
    T.eq(#wps, 3, "three route-build stops")
    T.eq(wps[1].x, 1, "wp 1 x")
    T.eq(wps[2].x, 2, "wp 2 x")
    T.eq(wps[3].x, 3, "wp 3 x")
end

-- Walked-through tile (existing route at target tier) doesn't appear
-- as a scanner waypoint either -- the scanner shows only the plots the
-- worker will actually stop on to work.
function M.test_compute_route_to_waypoints_skip_walked_through_tile()
    local plots = {
        ["0,0"] = fakePlot(0, 0),
        ["1,0"] = fakePlot(1, 0, { routeType = 0 }),
        ["2,0"] = fakePlot(2, 0),
        ["3,0"] = fakePlot(3, 0),
    }
    setupCompute({
        plots = plots,
        unitX = 0,
        unitY = 0,
        queue = { { mission = 2, data1 = 3, data2 = 0, flags = 0 } },
        bestBuildRoute = function()
            return 0, 100
        end,
        getBuildRoutePath = function()
            return {
                { x = 0, y = 0 },
                { x = 1, y = 0 },
                { x = 2, y = 0 },
                { x = 3, y = 0 },
            }
        end,
    })
    local wps = Waypoints.list()
    T.eq(#wps, 2, "only real build stops")
    T.eq(wps[1].x, 2, "first real build at x=2")
    T.eq(wps[2].x, 3, "second real build at x=3")
end

-- Route finder returns no path (e.g. blocked by water): fall back to a
-- move chunk for the leg so the player still hears the path rather
-- than getting silence.
function M.test_compute_route_to_falls_back_to_move_chunk_when_buildroute_fails()
    local plots = {
        ["0,0"] = fakePlot(0, 0),
        ["3,0"] = fakePlot(3, 0),
    }
    setupCompute({
        plots = plots,
        unitX = 0,
        unitY = 0,
        queue = { { mission = 2, data1 = 3, data2 = 0, flags = 0 } },
        bestBuildRoute = function()
            return 0, 100
        end,
        getBuildRoutePath = function()
            return {}
        end,
        computePath = function()
            return {
                { x = 0, y = 0, moves = 100 },
                { x = 3, y = 0, moves = 100 },
            }
        end,
        legTurns = 2,
    })
    local status = Waypoints.queuedActionStatus()
    T.eq(#status.chunks, 1, "one chunk")
    T.eq(status.chunks[1].kind, "move", "fell back to move chunk")
    T.eq(status.chunks[1].turns, 2, "movement-path turn count on fallback")
end

return M
