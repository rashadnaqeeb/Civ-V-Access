-- Queued-movement waypoint computation, cached per selected unit. Drives
-- three consumers: the scanner's "waypoints" category, the plot-glance
-- "waypoint K of N" lead token, and UnitSpeech's queued-move status
-- rung. Same cache so all three see the same numbering for one
-- selection frame.
--
-- A waypoint is a plot where the unit STOPS on its queued path, not
-- every step it walks through. Two kinds of stops: (1) end-of-turn
-- plots, where the unit ran out of MP and pauses overnight before
-- resuming next turn; (2) leg destinations, the queue-entry
-- coordinates the user shift+entered. Sighted parity: the path-line's
-- turn-number badges land on exactly these plots, not on every step.
-- Detection signal is the pathfinder node's m_iData1 (MP remaining at
-- that node): m_iData1 == 0 means the unit ends a turn here. The
-- final node of each leg is always a waypoint regardless of MP, since
-- the unit pauses between queue entries.
--
-- The cache is keyed by (unitID, queueSig). queueSig is a string built
-- from the live mission queue; any mutation produces a different sig and
-- the next read recomputes. Engine doesn't fire a Lua event on queue
-- pop / push, so signature comparison is the only honest invalidation.
-- Scanner snapshot rebuilds and cursor moves trigger reads; pathfinder
-- runs only when the sig actually changed.

Waypoints = {}

-- Mission types that contribute path nodes. Other queue entries (build,
-- fortify, etc.) advance the queue without producing a path-traversal
-- between two plots, so we skip them when chaining legs.
local function pathBearingMissions()
    local t = GameInfoTypes or {}
    return {
        [t.MISSION_MOVE_TO or -1] = true,
        [t.MISSION_ROUTE_TO or -1] = true,
        [t.MISSION_MOVE_TO_UNIT or -1] = true,
        [t.MISSION_EMBARK or -1] = true,
        [t.MISSION_DISEMBARK or -1] = true,
        [t.MISSION_SWAP_UNITS or -1] = true,
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

-- Walk the queue, run ComputePath per leg starting from the previous
-- leg's destination (unit's current pos for leg 1), concatenate. Each
-- leg's first node is the leg's start (== prior leg's destination),
-- which we drop on append so each plot the unit steps onto is counted
-- exactly once.
local function compute(unit, queue)
    local out = { waypoints = {}, totalTurns = 0 }
    if #queue == 0 then
        return out
    end
    local pathBearing = pathBearingMissions()
    local fromPlot = unit:GetPlot()
    if fromPlot == nil then
        return out
    end
    for _, entry in ipairs(queue) do
        if pathBearing[entry.mission] then
            local toPlot = Map.GetPlot(entry.data1, entry.data2)
            if toPlot ~= nil then
                -- pcall guards against the vanilla DLL: ComputePath is a
                -- fork binding (CIVVACCESS in CvLuaUnit.cpp), absent in
                -- stock Expansion2 builds. Failure surfaces as empty
                -- waypoints, not a thrown error each cursor move.
                local ok, nodes, success, legTurns = pcall(unit.ComputePath, unit, fromPlot, toPlot, entry.flags)
                if not ok then
                    Log.warn("WaypointsCore: Unit:ComputePath threw " .. tostring(nodes) .. " (engine fork deployed?)")
                    return out
                end
                if success and type(nodes) == "table" and #nodes > 0 then
                    out.totalTurns = out.totalTurns + legTurns
                    -- nodes[1] is the leg's start (== fromPlot); drop it.
                    -- For nodes[2..#nodes], emit only stopping points:
                    -- a node where m_iData1 (moves remaining) is 0 is
                    -- a turn-end stop, and the final node of the leg is
                    -- always a stop (queue-entry destination, unit
                    -- pauses before the next leg). Intermediate steps
                    -- with MP to spare are walked through, not stopped
                    -- at, so they do not count as waypoints.
                    for i = 2, #nodes do
                        local n = nodes[i]
                        if i == #nodes or n.moves == 0 then
                            out.waypoints[#out.waypoints + 1] = { x = n.x, y = n.y }
                        end
                    end
                end
                -- Chain from the leg's intended destination regardless
                -- of pathfinder success: an unreachable leg still ends
                -- at toPlot in the engine's mission queue (the engine
                -- abandons the leg at execution time but the next leg
                -- is anchored on its declared destination). Stale start
                -- here would compound errors across legs.
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
    -- (unitID, unitX, unitY, sig) is the invalidation key. unitX/unitY
    -- handle the mid-leg case: a unit executing a multi-turn move keeps
    -- the same queue entry across turns (data1/data2 = leg destination
    -- both before and after the move), so sig alone wouldn't notice the
    -- unit has actually progressed. Without position in the key, the
    -- "from" plot of leg 1 stays cached at last turn's location and the
    -- direction prefix in the speech rung describes a stale path.
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
        totalTurns = computed.totalTurns,
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

-- Public: total turns across all queued legs for the active selected
-- unit. 0 when no selection / no queue.
function Waypoints.totalTurns()
    local snap = activeSnapshot()
    if snap == nil then
        return 0
    end
    return snap.totalTurns
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

-- Public: final waypoint coords + total turns, or nil when the queue
-- has no path-bearing legs. UnitSpeech.statusToken uses this for the
-- "queued move to {dir}, N turns" rung.
function Waypoints.finalAndTurns()
    local snap = activeSnapshot()
    if snap == nil or #snap.waypoints == 0 then
        return nil
    end
    local last = snap.waypoints[#snap.waypoints]
    return { x = last.x, y = last.y, turns = snap.totalTurns }
end
