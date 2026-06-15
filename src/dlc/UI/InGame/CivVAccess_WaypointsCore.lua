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

-- Canonical string for an entry's path intents: sorted names, so two
-- reads of the same intents always serialize identically (pairs order
-- is not deterministic).
local function intentsSig(intents)
    local names = {}
    for name in pairs(intents) do
        names[#names + 1] = name
    end
    table.sort(names)
    return table.concat(names, ",")
end

-- Build a sig from the queue. Distinct queues hash to distinct strings;
-- two reads of an unchanged queue hash identically.
local function computeSig(queue)
    if #queue == 0 then
        return ""
    end
    local parts = {}
    for i, entry in ipairs(queue) do
        parts[i] = entry.mission .. ":" .. entry.data1 .. ":" .. entry.data2 .. ":" .. intentsSig(entry.intents)
    end
    return table.concat(parts, "|")
end

-- Per-tile build cost for a worker laying buildId on plot. Cities and
-- plots already at-or-above the target route tier are zero-cost. On the
-- worker's start plot the extra-rate goes to zero when getBuildTurnsLeft
-- already credits the on-plot worker, since feeding the rate in again would
-- double-count -- EngineData.onPlotWorkerCounted answers that per engine
-- (vanilla credits it only for the build the worker is mid-execution on; VP
-- credits any worker on the plot). Non-start plots carry no worker, so both
-- engines need the extra rate supplied. Mirrors the helper in
-- CivVAccess_UnitTargetMode.lua used by the route-to target-mode preview;
-- the math is the engine's, so the two callers want the same answer.
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
    if isStartPlot and EngineData.onPlotWorkerCounted(actorAlreadyOnBuild) then
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
    local routeId, buildId = EngineData.bestBuildRoute(unit, fromPlot)
    if routeId < 0 or buildId < 0 then
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
local function computeMovePath(unit, fromPlot, toPlot, intents, freshTurn)
    local nodes, success, legTurns = EngineData.computePath(unit, fromPlot, toPlot, intents, freshTurn)
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
--
-- includeOrigin adds the leg's origin tile (path[1]) to the turn total
-- without emitting it as a stop. The worker builds the tile it stands on
-- first when that tile needs the route (CvUnit::UnitRoadTo), so its build
-- time is real, but the player isn't navigated to where the worker
-- already is. Only the head leg sets this: a later leg's origin is a prior
-- leg's destination that leg already counted, so counting it again would
-- double up. The origin passes isStartPlot=true so the engine's auto-added
-- work rate for a worker mid-build there isn't double-counted; the
-- traversed tiles pass false (none of them is where the worker stands).
local function routeBuildStops(path, buildId, routeValue, extraRate, actorAlreadyOnBuild, includeOrigin)
    local stops = {}
    local turns = 0
    if includeOrigin and #path > 0 then
        local origin = Map.GetPlot(path[1].x, path[1].y)
        if origin ~= nil then
            turns = turns + plotBuildTurns(origin, buildId, routeValue, extraRate, actorAlreadyOnBuild, true)
        end
    end
    for i = 2, #path do
        local n = path[i]
        local plot = Map.GetPlot(n.x, n.y)
        if plot ~= nil then
            local pt = plotBuildTurns(plot, buildId, routeValue, extraRate, actorAlreadyOnBuild, false)
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
    -- Only the head leg starts at the unit's live position with its real
    -- remaining moves; every later leg begins at a prior waypoint the unit
    -- reaches on a future turn, so it is priced fresh (full moves) rather
    -- than inheriting moves already spent this turn.
    local firstLeg = true
    for _, entry in ipairs(queue) do
        local kind = kinds[entry.mission]
        if kind ~= nil then
            local toPlot = Map.GetPlot(entry.data1, entry.data2)
            if toPlot ~= nil then
                local moveLeg = computeMovePath(unit, fromPlot, toPlot, entry.intents, not firstLeg)
                if kind == MISSION_KIND_ROUTE then
                    local route = bestRouteForLeg(unit, fromPlot)
                    local path
                    if route ~= nil then
                        path = EngineData.buildRoutePath(
                            fromPlot:GetX(),
                            fromPlot:GetY(),
                            entry.data1,
                            entry.data2,
                            unit:GetOwner()
                        )
                    end
                    if route ~= nil and type(path) == "table" and #path > 0 then
                        local extraRate = unit:WorkRate(true, route.buildId)
                        local actorAlreadyOnBuild = unit:GetBuildType() == route.buildId
                        local stops, addedTurns = routeBuildStops(
                            path,
                            route.buildId,
                            route.routeValue,
                            extraRate,
                            actorAlreadyOnBuild,
                            firstLeg
                        )
                        if #stops > 0 then
                            local chunk = openChunk(MISSION_KIND_ROUTE, route.name)
                            prevX, prevY = emitSegments(chunk.segments, stops, prevX, prevY)
                            chunk.turns = chunk.turns + addedTurns
                            appendWaypointStops(stops)
                        else
                            -- Route leg with no navigable build stop (every
                            -- traversed tile is already at-or-above the
                            -- target tier). No chunk to open, no waypoints to
                            -- emit; any head-leg origin build time has
                            -- nowhere to attach since a chunk needs a segment
                            -- to be spoken. The anchor must still advance to
                            -- the leg destination so a subsequent leg
                            -- measures its segments from here instead of the
                            -- stale prior anchor.
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
                firstLeg = false
            end
        end
    end
    return out
end

-- Returns the cached snapshot for the active selected unit, recomputing
-- when the unit changed or the queue mutated. nil when no head selected
-- unit or the unit isn't owned by the active player (queued moves only
-- meaningful for the player's own units).
-- Snapshot ({ waypoints, chunks }) for an explicit unit, or nil when the
-- unit is nil or not owned by the active player (we never price a foreign
-- queue). The single-slot shared cache (civvaccess_shared.waypointsCache)
-- holds only the active selected unit: a cursor glance over some other
-- moving unit computes fresh each call so it can't evict the selected
-- unit's snapshot. compute() is parameterized purely by the unit handle
-- and runs the cache-safe ComputePath pathfinder, so pricing a
-- non-selected unit never disturbs its real movement.
local function snapshotFor(unit)
    if unit == nil then
        return nil
    end
    if unit:GetOwner() ~= Game.GetActivePlayer() then
        return nil
    end
    local queue = EngineData.missionQueue(unit)
    local head = UI.GetHeadSelectedUnit()
    if head == nil or head:GetID() ~= unit:GetID() then
        -- Non-selected unit: compute fresh, leave the cache untouched.
        return compute(unit, queue)
    end
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

local function activeSnapshot()
    return snapshotFor(UI.GetHeadSelectedUnit())
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

-- ===== All-units view =====
-- When the player turns off "show only selected unit waypoints", the
-- scanner lists every owned unit's queued stops and the cursor glance
-- names the units whose path crosses the current tile. Both read the
-- multi-unit snapshot below. It is a separate cache from the single-slot
-- selected-unit snapshot above: enumerating every unit on each cursor
-- step would re-price the whole army, so a global signature (each owned
-- unit's id, position, and queue sig) gates a recompute the same way the
-- single-unit sig does. Within a turn the player's queued units don't
-- move until they execute, so the signature holds and the passive glance
-- reads the cache; queuing a new order or a turn boundary busts it.

-- Spoken name for a waypoint's owning unit: the custom name if the player
-- renamed it (their disambiguation handle), otherwise the unit type. No
-- civ adjective -- every unit here is the active player's own, so "Roman"
-- would be redundant on every entry. GetNameKey returns only the type key
-- regardless of rename (see UnitSpeech.unitName), so the rename is read
-- separately via HasName / GetNameNoDesc.
local function unitDisplayName(unit)
    if unit:HasName() then
        return Text.key(unit:GetNameNoDesc())
    end
    return Text.key(unit:GetNameKey())
end

-- Public: live display name for an owned unit by ID. Re-queried at speech
-- time, never stored in the snapshot: a rename leaves the unit's id,
-- position, and queue untouched, so it does not bust the waypoint cache --
-- caching the name would speak the stale one until the unit next moved.
-- "" when the unit is gone (a freshly busted cache drops it anyway).
function Waypoints.unitName(unitID)
    local player = Players[Game.GetActivePlayer()]
    if player == nil then
        return ""
    end
    local unit = player:GetUnitByID(unitID)
    if unit == nil then
        return ""
    end
    return unitDisplayName(unit)
end

-- Cheap pass: the active player's units that carry a non-empty mission
-- queue, each paired with that queue. No pathfinder here -- this is the
-- enumeration the global signature is built from before deciding whether
-- a recompute is needed.
local function ownedQueuedUnits()
    local player = Players[Game.GetActivePlayer()]
    if player == nil then
        return {}
    end
    local out = {}
    for unit in player:Units() do
        local queue = EngineData.missionQueue(unit)
        if #queue > 0 then
            out[#out + 1] = { unit = unit, queue = queue }
        end
    end
    return out
end

local function allUnitsSig(entries)
    local parts = {}
    for i, e in ipairs(entries) do
        parts[i] = e.unit:GetID() .. ":" .. e.unit:GetX() .. ":" .. e.unit:GetY() .. ":" .. computeSig(e.queue)
    end
    return table.concat(parts, "||")
end

-- The multi-unit snapshot: one group per owned unit with at least one
-- queued stop, each { unitID, waypoints }. Cached on civvaccess_shared
-- keyed by the global signature; a miss re-prices every unit via compute()
-- -- the same cache-safe call the single-unit path uses, so the two views
-- agree on stop plots for any given unit. The unit's name is deliberately
-- not stored here -- it is resolved live via Waypoints.unitName so a rename
-- (which doesn't change the signature) takes effect immediately.
local function allUnitsGroups()
    local entries = ownedQueuedUnits()
    local sig = allUnitsSig(entries)
    local cache = civvaccess_shared.waypointsAllCache
    if cache ~= nil and cache.sig == sig then
        return cache.groups
    end
    local groups = {}
    for _, e in ipairs(entries) do
        local computed = compute(e.unit, e.queue)
        if #computed.waypoints > 0 then
            groups[#groups + 1] = {
                unitID = e.unit:GetID(),
                waypoints = computed.waypoints,
            }
        end
    end
    civvaccess_shared.waypointsAllCache = { sig = sig, groups = groups }
    return groups
end

-- Public: the multi-unit groups for the scanner's all-units waypoint
-- view. Each group is one navigable unit; its waypoints are the instances.
function Waypoints.allUnitsList()
    return allUnitsGroups()
end

-- Public: who stops on (x, y) across every owned unit's queue, split into
-- the selected unit's hit (carries index/total so the glance numbers it)
-- and the other units' hits (named, unnumbered). nil when no owned unit's
-- path crosses the tile. One hit per unit even if a reversal leg revisits
-- the plot, mirroring atXY's first-match behavior.
function Waypoints.atXYAll(x, y)
    local groups = allUnitsGroups()
    local head = UI.GetHeadSelectedUnit()
    local headID = head ~= nil and head:GetID() or nil
    local selected = nil
    local others = {}
    for _, g in ipairs(groups) do
        local total = #g.waypoints
        for i, wp in ipairs(g.waypoints) do
            if wp.x == x and wp.y == y then
                if g.unitID == headID then
                    selected = { index = i, total = total }
                else
                    others[#others + 1] = { unitName = Waypoints.unitName(g.unitID) }
                end
                break
            end
        end
    end
    if selected == nil and #others == 0 then
        return nil
    end
    return { selected = selected, others = others }
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
local function statusFromSnapshot(snap)
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

function Waypoints.queuedActionStatus()
    return statusFromSnapshot(activeSnapshot())
end

-- Public: queued-action chunks for an explicit unit -- the cursor-glance
-- path readout for a unit that isn't the selected one. Same shape and
-- empty-segment filtering as queuedActionStatus (which is the head-unit
-- case of this). nil for a nil / non-active-player unit or one with no
-- describable path-bearing legs, so the caller falls back to the bare
-- "queued move" rung.
function Waypoints.queuedActionStatusFor(unit)
    return statusFromSnapshot(snapshotFor(unit))
end

-- Public: total turns for `unit` to traverse its currently queued
-- move-like legs, chaining the pathfinder from each leg's destination,
-- or nil when the queue holds no reachable move leg (empty queue, a
-- non-path mission, an unreachable target, or the engine fork's
-- ComputePath binding absent). Takes an explicit unit and bypasses the
-- active-unit snapshot cache so callers can price an arbitrary owned
-- unit's arrival ETA without disturbing the selected unit's waypoint
-- snapshot. Route-to legs count walk time, not build time -- the
-- Military Overview caller reaches this only for units not currently
-- building, where "turns to arrive" is the meaningful number.
function Waypoints.queueTurns(unit)
    local queue = EngineData.missionQueue(unit)
    if #queue == 0 then
        return nil
    end
    local kinds = missionKinds()
    local fromPlot = unit:GetPlot()
    if fromPlot == nil then
        return nil
    end
    local total = 0
    local any = false
    -- Mirror compute()'s pricing: only the head leg keeps the unit's live
    -- remaining moves; later legs begin at a waypoint the unit reaches on a
    -- future turn and are priced fresh. Without this the F3 arrival ETA
    -- disagrees with the per-leg turn counts spoken from compute().
    local firstLeg = true
    for _, entry in ipairs(queue) do
        if kinds[entry.mission] ~= nil then
            local toPlot = Map.GetPlot(entry.data1, entry.data2)
            if toPlot ~= nil then
                local moveLeg = computeMovePath(unit, fromPlot, toPlot, entry.intents, not firstLeg)
                if moveLeg ~= nil then
                    total = total + moveLeg.turns
                    any = true
                end
                -- Chain from the leg's intended destination even when the
                -- pathfinder failed, mirroring compute(): the engine still
                -- anchors the next leg on toPlot.
                fromPlot = toPlot
                firstLeg = false
            end
        end
    end
    if not any then
        return nil
    end
    return total
end
