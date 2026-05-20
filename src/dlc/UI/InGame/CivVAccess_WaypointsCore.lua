-- Queued-action waypoint and chunk computation, cached per selected unit.
-- Two views, one cache:
--   * waypoints (flat list of stop plots) feeds the scanner's "waypoints"
--     category, the plot-glance "waypoint K of N" lead token, and atXY
--     for cursor reads.
--   * chunks (per-leg dialect descriptions) feeds UnitSpeech's
--     queued-action status rung. Each chunk is one or more consecutive
--     same-kind legs in the queue: kind "move" for the movement
--     missions, kind "route" for MISSION_ROUTE_TO.
--
-- A waypoint is a plot where the unit STOPS on its queued path. The
-- meaning of "stop" depends on the leg's mission kind. Movement-style
-- legs (MISSION_MOVE_TO and friends) emit a stop at every end-of-turn
-- plot (the pathfinder node's m_iData1 == 0 means MP exhausted) plus
-- the leg's final node (the queue-entry destination). Route-to legs
-- emit a stop on every tile the worker pauses on to build a route
-- segment -- skipping tiles whose existing route already meets the
-- target tier, since the worker walks through those without working.
-- Scanner and speech see the same set of plots for any given queue
-- because both reuse this stop list.
--
-- Chunks describe the queue at a higher level than waypoints, in a
-- dialect appropriate for the leg's mission type. A move-like leg
-- (MISSION_MOVE_TO and friends) becomes a chunk with one segment per
-- waypoint, each a direction string from the prior stop to the new
-- stop, and turn count = pathfinder's reported turn count. A
-- MISSION_ROUTE_TO leg becomes a chunk with one segment per tile the
-- worker actually pauses on to build, with the BuildRouteFinder's path
-- and per-plot build turns (mirrors the route-to target-mode preview's
-- math). Tiles the worker walks through without building (their route
-- tier already meets the target) get their direction folded into the
-- next emitted segment instead of producing a no-op stop. Consecutive
-- same-kind legs merge into one chunk so a shift-queued run reads as
-- one announcement.
--
-- The cache is keyed by (unitID, unitX, unitY, sig). queueSig is built
-- from the live mission queue; any mutation produces a different sig
-- and the next read recomputes. unitX/unitY catch the mid-leg case
-- where the queue is unchanged but the unit progressed across a turn
-- boundary -- without position in the key the segment 1 anchor stays
-- at last turn's plot and every consumer measures from the wrong
-- place.

Waypoints = {}

local MISSION_KIND_MOVE = "move"
local MISSION_KIND_ROUTE = "route"

-- Mission type -> chunk kind, or nil for non-path-bearing missions.
-- ROUTE_TO is its own kind because the worker doesn't traverse the
-- queued path the same way a move does -- it stops to build on each
-- tile -- so the speech dialect and the underlying pathfinder both
-- differ.
local function missionKinds()
    local t = GameInfoTypes or {}
    return {
        [t.MISSION_MOVE_TO or -1] = MISSION_KIND_MOVE,
        [t.MISSION_MOVE_TO_UNIT or -1] = MISSION_KIND_MOVE,
        [t.MISSION_EMBARK or -1] = MISSION_KIND_MOVE,
        [t.MISSION_DISEMBARK or -1] = MISSION_KIND_MOVE,
        [t.MISSION_SWAP_UNITS or -1] = MISSION_KIND_MOVE,
        [t.MISSION_ROUTE_TO or -1] = MISSION_KIND_ROUTE,
    }
end

-- Build a sig from the queue. Distinct queues hash to distinct strings;
-- two reads of an unchanged queue hash identically.
local function computeSig(queue)
    if #queue == 0 then
        return ""
    end
    local parts = {}
    for i, entry in ipairs(queue) do
        parts[i] = entry.mission .. ":" .. entry.data1 .. ":" .. entry.data2 .. ":" .. entry.flags
    end
    return table.concat(parts, "|")
end

-- Per-tile build cost for a worker laying buildId on plot. Cities and
-- plots already at-or-above the target route tier are zero-cost. On the
-- worker's start plot the extra-rate goes to zero when the worker is
-- already mid-build of this same build: CvPlot::getBuildTurnsLeft walks
-- the plot's unit list and auto-adds the work rate of every unit whose
-- getBuildType() matches, so feeding it again would double-count.
-- Mirrors the helper in CivVAccess_UnitTargetMode.lua used by the
-- route-to target-mode preview; the math is the engine's, so the two
-- callers want the same answer.
local function plotBuildTurns(plot, buildId, routeValue, extraRate, actorAlreadyOnBuild, isStartPlot)
    if buildId == nil or plot:IsCity() then
        return 0
    end
    local existing = plot:GetRouteType()
    if existing >= 0 then
        local existingRow = GameInfo.Routes[existing]
        if existingRow ~= nil and (existingRow.Value or 0) >= routeValue then
            return 0
        end
    end
    local extra = extraRate
    if isStartPlot and actorAlreadyOnBuild then
        extra = 0
    end
    return plot:GetBuildTurnsLeft(buildId, plot:GetOwner(), extra, extra)
end

-- Resolve the localized lowercase route name for the worker's best
-- build on the given plot, along with the buildId / routeValue the
-- chunk needs to compute per-plot costs. nil when the worker can't
-- build any route here (e.g. embarked), which the caller surfaces as
-- "fall back to move dialect for this leg" so the player still hears
-- the path.
local function bestRouteForLeg(unit, fromPlot)
    local ok, routeId, buildId = pcall(unit.GetBestBuildRoute, unit, fromPlot)
    if not ok or routeId == nil or routeId < 0 or buildId == nil or buildId < 0 then
        return nil
    end
    local routeRow = GameInfo.Routes[routeId]
    if routeRow == nil then
        return nil
    end
    local raw = Text.key(routeRow.Description)
    local name
    if Locale and Locale.ToLower then
        name = Locale.ToLower(raw)
    else
        name = raw:lower()
    end
    return { name = name, buildId = buildId, routeValue = routeRow.Value or 0 }
end

-- Move-like leg: run the movement pathfinder. Returns { nodes, turns }
-- or nil. nodes[1] is the leg's start (== fromPlot); nodes[2..#nodes]
-- are the plots the unit will step onto.
local function computeMovePath(unit, fromPlot, toPlot, flags)
    -- pcall guards against the vanilla DLL: ComputePath is a fork
    -- binding (CIVVACCESS in CvLuaUnit.cpp), absent in stock Expansion2
    -- builds.
    local ok, nodes, success, legTurns = pcall(unit.ComputePath, unit, fromPlot, toPlot, flags)
    if not ok then
        Log.warn("WaypointsCore: Unit:ComputePath threw " .. tostring(nodes) .. " (engine fork deployed?)")
        return nil
    end
    if not success or type(nodes) ~= "table" or #nodes == 0 then
        return nil
    end
    return { nodes = nodes, turns = legTurns }
end

-- Stop nodes from a movement leg: turn-end plots (moves == 0) plus the
-- leg's final node. Skips nodes[1] (== fromPlot).
local function moveStops(nodes)
    local stops = {}
    for i = 2, #nodes do
        local n = nodes[i]
        if i == #nodes or n.moves == 0 then
            stops[#stops + 1] = n
        end
    end
    return stops
end

-- Direction-string segments from a list of stops, anchored on
-- (prevX, prevY) for the first segment and chaining forward. Zero-delta
-- segments are skipped (the anchor stays put so the next real segment
-- is measured from the last real stop). Returns the new anchor.
local function emitSegments(segments, stops, prevX, prevY)
    for _, stop in ipairs(stops) do
        local dir = HexGeom.directionString(prevX, prevY, stop.x, stop.y)
        if dir ~= "" then
            segments[#segments + 1] = dir
            prevX, prevY = stop.x, stop.y
        end
    end
    return prevX, prevY
end

-- Build-stop list for a route leg: tiles where plotBuildTurns > 0,
-- with their summed build turns. Walked-through tiles (already at
-- target tier) contribute no stop -- their direction folds into the
-- next emitted segment because the anchor only advances on real stops.
local function routeBuildStops(path, buildId, routeValue, extraRate, actorAlreadyOnBuild)
    local stops = {}
    local turns = 0
    for i = 2, #path do
        local n = path[i]
        local plot = Map.GetPlot(n.x, n.y)
        if plot ~= nil then
            local pt = plotBuildTurns(plot, buildId, routeValue, extraRate, actorAlreadyOnBuild, i == 1)
            if pt > 0 then
                stops[#stops + 1] = { x = n.x, y = n.y }
                turns = turns + pt
            end
        end
    end
    return stops, turns
end

-- Walk the queue producing both views: flat waypoints for scanner /
-- cursor consumers, and chunks for the speech rung. The two views
-- share the same anchor walk so segments and waypoints stay in lockstep
-- across legs. Route-to legs use the BuildRouteFinder for chunk
-- segments but reuse the movement pathfinder's nodes for waypoints, so
-- the scanner view of route-to queues is unchanged from before this
-- refactor (changing scanner semantics is a separate concern).
local function compute(unit, queue)
    local out = { waypoints = {}, chunks = {} }
    if #queue == 0 then
        return out
    end
    local kinds = missionKinds()
    local fromPlot = unit:GetPlot()
    if fromPlot == nil then
        return out
    end
    local prevX, prevY = unit:GetX(), unit:GetY()
    local currentChunk = nil
    local function openChunk(kind, routeName)
        if currentChunk ~= nil and currentChunk.kind == kind and currentChunk.routeName == routeName then
            return currentChunk
        end
        currentChunk = { kind = kind, segments = {}, turns = 0, routeName = routeName }
        out.chunks[#out.chunks + 1] = currentChunk
        return currentChunk
    end
    -- Each leg contributes both segments-for-chunks and stops-for-
    -- waypoints from the SAME pathfinder, so the scanner / cursor /
    -- atXY consumers see the same plots the speech rung describes. For
    -- move-like legs that's the movement pathfinder's turn-end stops;
    -- for route-to legs it's the BuildRouteFinder's build stops (tiles
    -- the worker will pause on to build).
    local function appendWaypointStops(stops)
        for _, stop in ipairs(stops) do
            out.waypoints[#out.waypoints + 1] = { x = stop.x, y = stop.y }
        end
    end
    for _, entry in ipairs(queue) do
        local kind = kinds[entry.mission]
        if kind ~= nil then
            local toPlot = Map.GetPlot(entry.data1, entry.data2)
            if toPlot ~= nil then
                local moveLeg = computeMovePath(unit, fromPlot, toPlot, entry.flags)
                if kind == MISSION_KIND_ROUTE then
                    local route = bestRouteForLeg(unit, fromPlot)
                    local rok, path
                    if route ~= nil then
                        rok, path = pcall(
                            Game.GetBuildRoutePath,
                            fromPlot:GetX(),
                            fromPlot:GetY(),
                            entry.data1,
                            entry.data2,
                            unit:GetOwner()
                        )
                    end
                    if route ~= nil and rok and type(path) == "table" and #path > 0 then
                        local extraRate = unit:WorkRate(true, route.buildId)
                        local actorAlreadyOnBuild = unit:GetBuildType() == route.buildId
                        local stops, addedTurns =
                            routeBuildStops(path, route.buildId, route.routeValue, extraRate, actorAlreadyOnBuild)
                        if #stops > 0 then
                            local chunk = openChunk(MISSION_KIND_ROUTE, route.name)
                            prevX, prevY = emitSegments(chunk.segments, stops, prevX, prevY)
                            chunk.turns = chunk.turns + addedTurns
                            appendWaypointStops(stops)
                        else
                            -- Route leg had a valid path but every tile is
                            -- already at-or-above the target tier. No
                            -- chunk to open, no waypoints to emit. The
                            -- anchor must still advance to the leg
                            -- destination so any subsequent leg measures
                            -- its segments from here instead of the stale
                            -- prior anchor.
                            prevX, prevY = entry.data1, entry.data2
                        end
                    elseif moveLeg ~= nil then
                        -- Route finder didn't produce a usable path; fall
                        -- back to a move chunk so the player still hears
                        -- the leg. Waypoints fall back to the movement
                        -- stops alongside.
                        local stops = moveStops(moveLeg.nodes)
                        local chunk = openChunk(MISSION_KIND_MOVE, nil)
                        prevX, prevY = emitSegments(chunk.segments, stops, prevX, prevY)
                        chunk.turns = chunk.turns + moveLeg.turns
                        appendWaypointStops(stops)
                    end
                elseif moveLeg ~= nil then
                    local stops = moveStops(moveLeg.nodes)
                    local chunk = openChunk(MISSION_KIND_MOVE, nil)
                    prevX, prevY = emitSegments(chunk.segments, stops, prevX, prevY)
                    chunk.turns = chunk.turns + moveLeg.turns
                    appendWaypointStops(stops)
                end
                -- Chain from the leg's intended destination regardless
                -- of pathfinder success: an unreachable leg still ends
                -- at toPlot in the engine's mission queue (the engine
                -- abandons execution but the next leg anchors on toPlot).
                fromPlot = toPlot
            end
        end
    end
    return out
end

-- Returns the cached snapshot for the active selected unit, recomputing
-- when the unit changed or the queue mutated. nil when no head selected
-- unit or the unit isn't owned by the active player (queued moves only
-- meaningful for the player's own units).
local function activeSnapshot()
    local unit = UI.GetHeadSelectedUnit()
    if unit == nil then
        return nil
    end
    if unit:GetOwner() ~= Game.GetActivePlayer() then
        return nil
    end
    local queue = unit:GetMissionQueue()
    local sig = computeSig(queue)
    local ux, uy = unit:GetX(), unit:GetY()
    local cache = civvaccess_shared.waypointsCache
    if
        cache ~= nil
        and cache.unitID == unit:GetID()
        and cache.unitX == ux
        and cache.unitY == uy
        and cache.sig == sig
    then
        return cache
    end
    local computed = compute(unit, queue)
    cache = {
        unitID = unit:GetID(),
        unitX = ux,
        unitY = uy,
        sig = sig,
        waypoints = computed.waypoints,
        chunks = computed.chunks,
    }
    civvaccess_shared.waypointsCache = cache
    return cache
end

-- Public: full waypoint list for the active selected unit. Empty list
-- when no selection / no queued legs / non-active-player unit.
function Waypoints.list()
    local snap = activeSnapshot()
    if snap == nil then
        return {}
    end
    return snap.waypoints
end

-- Public: { index, total } when (x, y) is a waypoint of the active
-- selected unit's queue, nil otherwise. Used by PlotSections.waypoint
-- for the cursor-glance tail and ScannerBackendWaypoints.ValidateEntry
-- for re-resolution against a fresh queue.
function Waypoints.atXY(x, y)
    local snap = activeSnapshot()
    if snap == nil then
        return nil
    end
    local total = #snap.waypoints
    for i, wp in ipairs(snap.waypoints) do
        if wp.x == x and wp.y == y then
            return { index = i, total = total }
        end
    end
    return nil
end

-- Public: { chunks = { { kind, segments, turns, routeName? }, ... } }
-- describing the queued action of the active selected unit. nil when
-- there's no head-selected unit, no path-bearing legs, or every chunk
-- ended up with no segments (every emitted stop coincided with the
-- anchor -- vanishingly rare but defended against so the speech rung
-- falls back to the bare queued rung instead of an empty announcement).
-- Each chunk's `kind` is "move" or "route"; "route" chunks carry a
-- localized `routeName` ("road", "railroad", or a modded route's name)
-- so the renderer can name it directly.
function Waypoints.queuedActionStatus()
    local snap = activeSnapshot()
    if snap == nil or #snap.chunks == 0 then
        return nil
    end
    for _, chunk in ipairs(snap.chunks) do
        if #chunk.segments == 0 then
            return nil
        end
    end
    return { chunks = snap.chunks }
end
