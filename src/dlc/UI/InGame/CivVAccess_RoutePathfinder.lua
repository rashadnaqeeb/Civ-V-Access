-- Lua port of the engine's BuildRouteFinder for MISSION_ROUTE_TO preview.
-- Engine (vanilla CvUnit::UnitPathTo with bBuildingRoute=true) routes via
-- GC.GetBuildRouteFinder, NOT the unit's movement pathfinder. The cost
-- and validity functions live in CvAStar.cpp:2493-2596 (BuildRouteCost,
-- BuildRouteValid). This module mirrors them so we can preview the tile
-- count and total build-turn count a worker's auto-route will incur.
--
-- Differences from the engine, accepted as harmless:
--   * BuilderAIScratchPad: an AI per-turn flag tagging tiles already
--     planned for road-building this turn, applies a 0.5x cost discount
--     in the engine. Not exposed to Lua and only meaningful to the AI's
--     own builder plans, so a human player issuing route-to never sees
--     the discount fire on tiles relevant to them.
--   * eRoute encoding: the engine packs a route type into the upper byte
--     of iFlags so a "matching route" branch can return cost 1 instead
--     of 10. The vanilla call site (UnitPathTo) passes only the player
--     id, leaving the upper byte zero and reducing eRoute to NO_ROUTE,
--     so the matching-route branch never fires for player-driven
--     missions. We don't model it.

RoutePathfinder = {}

local NEIGHBOR_DIRS = {
    DirectionTypes.DIRECTION_NORTHEAST,
    DirectionTypes.DIRECTION_EAST,
    DirectionTypes.DIRECTION_SOUTHEAST,
    DirectionTypes.DIRECTION_SOUTHWEST,
    DirectionTypes.DIRECTION_WEST,
    DirectionTypes.DIRECTION_NORTHWEST,
}

-- Engine constants from CvAStar.h:40-43.
local EXISTING_ROUTE_WEIGHT = 10
local NO_ROUTE_BASE = 1500

-- Safety cap. Same rationale as Pathfinder.MAX_EXPANSIONS: bail with
-- "unreachable" rather than block the speech pipeline on a pathological
-- search frontier.
local MAX_EXPANSIONS = 4000

-- ===== Binary min-heap, keyed by item.f =====

local function heapPush(h, item)
    h[#h + 1] = item
    local i = #h
    while i > 1 do
        local parent = math.floor(i / 2)
        if h[parent].f > h[i].f then
            h[parent], h[i] = h[i], h[parent]
            i = parent
        else
            break
        end
    end
end

local function heapPop(h)
    local n = #h
    if n == 0 then
        return nil
    end
    local top = h[1]
    if n == 1 then
        h[1] = nil
        return top
    end
    h[1] = h[n]
    h[n] = nil
    n = n - 1
    local i = 1
    while true do
        local l = 2 * i
        local r = 2 * i + 1
        local smallest = i
        if l <= n and h[l].f < h[smallest].f then
            smallest = l
        end
        if r <= n and h[r].f < h[smallest].f then
            smallest = r
        end
        if smallest == i then
            break
        end
        h[smallest], h[i] = h[i], h[smallest]
        i = smallest
    end
    return top
end

-- ===== Per-search context =====

-- Pick the build the engine will queue per tile. GetBestBuildRouteForRoadTo
-- iterates GameInfo.Builds, picks the row with the highest Routes.Value
-- the unit canBuild on the plot, and returns its build id. Vanilla road
-- and railroad have no terrain restriction beyond the BuildRouteValid gates,
-- so the picker collapses to "highest-tier route the player has tech for."
-- We resolve that once at search start and reuse it: the player's tech
-- doesn't change mid-preview.
local function pickBuild(player, team)
    local bestValue = -1
    local bestBuild = nil
    local bestRoute = nil
    if GameInfo == nil or GameInfo.Builds == nil then
        return nil, nil, nil
    end
    for buildRow in GameInfo.Builds() do
        local routeName = buildRow.RouteType
        if routeName ~= nil and routeName ~= "NONE" then
            local routeId = GameInfoTypes and GameInfoTypes[routeName]
            if routeId ~= nil then
                local routeRow = GameInfo.Routes[routeId]
                if routeRow ~= nil then
                    local prereq = buildRow.PrereqTech
                    local hasTech = true
                    if prereq ~= nil and prereq ~= "NONE" then
                        local techId = GameInfoTypes and GameInfoTypes[prereq]
                        if techId == nil or team == nil or not team:IsHasTech(techId) then
                            hasTech = false
                        end
                    end
                    if hasTech then
                        local value = routeRow.Value or 0
                        if value > bestValue then
                            bestValue = value
                            bestBuild = buildRow.ID
                            bestRoute = routeId
                        end
                    end
                end
            end
        end
    end
    return bestBuild, bestRoute, bestValue
end

local function buildCtx(unit)
    local ctx = {}
    ctx.unit = unit
    ctx.team = unit:GetTeam()
    ctx.player = unit:GetOwner()
    ctx.isDebug = Game.IsDebugMode()
    ctx.pTeam = Teams[ctx.team]
    ctx.activePlayer = Game.GetActivePlayer()

    local buildId, routeId, routeValue = pickBuild(ctx.player, ctx.pTeam)
    ctx.buildId = buildId
    ctx.routeId = routeId
    ctx.routeValue = routeValue or -1

    -- The worker contributes their full work rate to every tile they
    -- haven't yet started. The base-game tooltip pattern (UnitPanel.lua
    -- buildActionTooltip) zeroes the extra-rate ONLY when the displayed
    -- plot matches the worker's current in-progress build, to avoid
    -- double-counting a rate already baked into the plot's progress.
    -- Below in plotBuildTurns we apply that zero just to the start plot
    -- when relevant; ctx.extraRate is the rate for fresh tiles.
    if buildId ~= nil then
        ctx.extraRate = unit:WorkRate(true, buildId)
    else
        ctx.extraRate = 0
    end
    return ctx
end

-- ===== Validity (CvAStar.cpp:2537-2596 BuildRouteValid) =====

-- The minor-civ MINOR_CIV_QUEST_ROUTE branch is omitted: it's a niche
-- carve-out (a city-state has actively quested for a route from this
-- specific player) that we'd need extra GameInfoTypes lookups to model
-- and that would only mis-bias the preview when the player is auto-
-- routing into a quest-giving city-state's land. The engine's behavior
-- in that case is to permit the route into their territory; ours is to
-- reject it. The player can still issue the mission and the engine will
-- carry it out; only the preview is conservative.
local function isValid(plot, ctx)
    if not ctx.isDebug and not plot:IsRevealed(ctx.team, ctx.isDebug) then
        return false
    end
    if plot:IsWater() then
        return false
    end
    if plot:IsImpassable() or plot:IsMountain() then
        return false
    end
    local owner = plot:GetOwner()
    if owner ~= -1 and owner ~= nil and owner ~= ctx.player then
        if not plot:IsFriendlyTerritory(ctx.player) then
            return false
        end
    end
    return true
end

-- ===== Cost (CvAStar.cpp:2493-2533 BuildRouteCost) =====

local function tileMovementCost(plot)
    local fid = plot:GetFeatureType()
    if fid >= 0 then
        local frow = GameInfo.Features[fid]
        if frow ~= nil and frow.Movement ~= nil then
            return frow.Movement
        end
    end
    local tid = plot:GetTerrainType()
    if tid >= 0 then
        local trow = GameInfo.Terrains[tid]
        if trow ~= nil and trow.Movement ~= nil then
            return trow.Movement
        end
    end
    return 1
end

local function stepCost(plot)
    local existing = plot:GetRouteType()
    if existing >= 0 then
        return EXISTING_ROUTE_WEIGHT
    end
    local moveCost = tileMovementCost(plot)
    -- (movementCost + 1) is always > 0 for non-negative move costs, so the
    -- engine's `if(iMovementCost + 1 != 0)` guard always reassigns.
    return math.floor(NO_ROUTE_BASE / 2 + NO_ROUTE_BASE / (moveCost + 1))
end

-- Exposed for unit tests; production callers go through the A* search.
RoutePathfinder._stepCost = stepCost

-- ===== Per-tile build turn lookup =====

-- Mirrors the engine's GetBestBuildRouteForRoadTo decision: cities count
-- as their own connection node so a road on a city plot is unnecessary,
-- and a plot already routed at or above the target tier is skipped.
-- Otherwise GetBuildTurnsLeft returns the per-tile turn count under the
-- worker's contribution rate. `isStartPlot` zeroes the extra-rate when
-- the worker is currently mid-build of this same route on their own
-- plot, matching the engine's no-double-count tooltip pattern.
local function plotBuildTurns(plot, ctx, isStartPlot)
    if ctx.buildId == nil then
        return 0
    end
    if plot:IsCity() then
        return 0
    end
    local existing = plot:GetRouteType()
    if existing >= 0 then
        local existingRow = GameInfo.Routes[existing]
        if existingRow ~= nil then
            local existingValue = existingRow.Value or 0
            if existingValue >= ctx.routeValue then
                return 0
            end
        end
    end
    local extra = ctx.extraRate
    if isStartPlot and ctx.unit:GetBuildType() == ctx.buildId then
        extra = 0
    end
    return plot:GetBuildTurnsLeft(ctx.buildId, ctx.activePlayer, extra, extra)
end

-- ===== A* =====

-- Returns (result, nil) on success where result is { plots, tileCount,
-- buildTurns, buildId, routeId } or (nil, reason) on failure. plots is
-- the ordered list including both endpoints. tileCount is #plots minus
-- the unit's start plot (the road covers tiles the worker walks INTO).
-- buildTurns is the summed per-tile GetBuildTurnsLeft.
function RoutePathfinder.findPath(unit, toPlot)
    if unit == nil then
        return nil, "no_target"
    end
    if toPlot == nil then
        return nil, "no_target"
    end
    local fromPlot = unit:GetPlot()
    if fromPlot == nil then
        return nil, "no_target"
    end
    if fromPlot:GetPlotIndex() == toPlot:GetPlotIndex() then
        return nil, "same_plot"
    end

    local team = unit:GetTeam()
    local isDebug = Game.IsDebugMode()
    if not isDebug and not toPlot:IsRevealed(team, isDebug) then
        return nil, "unexplored"
    end

    local ctx = buildCtx(unit)
    if ctx.buildId == nil then
        return nil, "no_build"
    end

    -- Validity check on the destination up front so we can distinguish
    -- "destination itself is illegal" (foreign closed-borders city, water,
    -- mountain) from "destination is reachable but the path runs out."
    if not isValid(toPlot, ctx) then
        return nil, "unreachable"
    end

    local startIdx = fromPlot:GetPlotIndex()
    local goalIdx = toPlot:GetPlotIndex()
    local tx, ty = toPlot:GetX(), toPlot:GetY()

    local heap = {}
    local gScore = {}
    local cameFrom = {}

    gScore[startIdx] = 0
    heapPush(heap, {
        plot = fromPlot,
        plotIndex = startIdx,
        g = 0,
        f = 0,
    })

    -- Heuristic: hexDistance * EXISTING_ROUTE_WEIGHT. The minimum cost
    -- per step is 10 (existing route), so this is admissible (never
    -- overestimates). Tighter than h=0 without compromising correctness.
    local expansions = 0
    while #heap > 0 do
        local current = heapPop(heap)
        expansions = expansions + 1
        if expansions > MAX_EXPANSIONS then
            Log.warn("RoutePathfinder: hit expansion cap before reaching target; reporting as too_far")
            return nil, "too_far"
        end

        if current.plotIndex == goalIdx then
            local plots = { toPlot }
            local idx = goalIdx
            while cameFrom[idx] ~= nil do
                local prev = cameFrom[idx]
                plots[#plots + 1] = prev.plot
                idx = prev.plotIndex
            end
            -- Reverse so plots[1] is the start and plots[#plots] is the goal.
            local n = #plots
            for i = 1, math.floor(n / 2) do
                plots[i], plots[n - i + 1] = plots[n - i + 1], plots[i]
            end
            local buildTurns = 0
            for i = 1, #plots do
                buildTurns = buildTurns + plotBuildTurns(plots[i], ctx, i == 1)
            end
            return {
                plots = plots,
                tileCount = #plots - 1,
                buildTurns = buildTurns,
                buildId = ctx.buildId,
                routeId = ctx.routeId,
            },
                nil
        end

        if current.g <= (gScore[current.plotIndex] or math.huge) then
            local cx, cy = current.plot:GetX(), current.plot:GetY()
            for _, dir in ipairs(NEIGHBOR_DIRS) do
                local neighbor = Map.PlotDirection(cx, cy, dir)
                if neighbor ~= nil and isValid(neighbor, ctx) then
                    local cost = stepCost(neighbor)
                    local newG = current.g + cost
                    local nIdx = neighbor:GetPlotIndex()
                    if newG < (gScore[nIdx] or math.huge) then
                        gScore[nIdx] = newG
                        cameFrom[nIdx] = { plot = current.plot, plotIndex = current.plotIndex }
                        local h = HexGeom.cubeDistance(neighbor:GetX(), neighbor:GetY(), tx, ty) * EXISTING_ROUTE_WEIGHT
                        heapPush(heap, {
                            plot = neighbor,
                            plotIndex = nIdx,
                            g = newG,
                            f = newG + h,
                        })
                    end
                end
            end
        end
    end

    return nil, "unreachable"
end
