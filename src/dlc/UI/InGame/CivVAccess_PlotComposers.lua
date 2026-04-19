-- Composers for the per-move glance and the on-demand W (economy) and X
-- (combat) detail keys. Each composer reads sections in a fixed order,
-- joins non-empty tokens with ", ", and returns a single speech string.
--
-- Visibility gating happens here, not in the sections themselves: a fogged
-- plot reads stale GetRevealed* data fine, but live data (units, yields,
-- build progress, ZoC) only makes sense when IsVisible. The per-move
-- composer also handles the "never revealed" short-circuit so unexplored
-- tiles don't leak any information at all.

PlotComposers = {}

local function readSection(section, plot, ctx, out)
    local tokens = section.Read(plot, ctx)
    for _, t in ipairs(tokens) do
        if t ~= nil and t ~= "" then out[#out + 1] = t end
    end
end

-- Per-move glance: terrain-shape facts that distinguish this hex from its
-- neighbors, in distinguishing-fact-first order. Units and city come first
-- because those are the most commonly important; geography sandwiches them.
-- The Cursor gates on IsRevealed before calling in; this composer only
-- handles the revealed-but-fogged distinction, prepending a "fog" marker so
-- the user knows the data is stale before hearing it.
function PlotComposers.glance(plot)
    local team, debug = Game.GetActiveTeam(), Game.IsDebugMode()
    local visible = plot:IsVisible(team, debug)
    local ctx = {}
    local tokens = {}
    if not visible then
        tokens[#tokens + 1] = Text.key("TXT_KEY_CIVVACCESS_FOG")
    end
    if visible then
        readSection(PlotSectionUnits, plot, ctx, tokens)
    end
    readSection(PlotSections.city,        plot, ctx, tokens)
    readSection(PlotSections.route,       plot, ctx, tokens)
    -- Feature runs before terrain so it can set ctx.suppressTerrain when
    -- it's a natural wonder or "special feature" (jungle / marsh / oasis /
    -- ice). Terrain reads ctx.suppressTerrain; plotType (mountain) sets it
    -- too. Feature runs before plotType so the "natural wonder over
    -- mountain" case still produces just the wonder name.
    readSection(PlotSections.feature,     plot, ctx, tokens)
    readSection(PlotSections.plotType,    plot, ctx, tokens)
    readSection(PlotSections.terrain,     plot, ctx, tokens)
    readSection(PlotSections.resource,    plot, ctx, tokens)
    readSection(PlotSections.improvement, plot, ctx, tokens)
    readSection(PlotSectionRiver, plot, ctx, tokens)
    return table.concat(tokens, ", ")
end

-- W: economy details. Yields are nonzero-only; the rest are simple flags.
local YIELD_KEYS = {
    { id = YieldTypes.YIELD_FOOD,       key = "TXT_KEY_CIVVACCESS_ICON_FOOD" },
    { id = YieldTypes.YIELD_PRODUCTION, key = "TXT_KEY_CIVVACCESS_ICON_PRODUCTION" },
    { id = YieldTypes.YIELD_GOLD,       key = "TXT_KEY_CIVVACCESS_ICON_GOLD" },
    { id = YieldTypes.YIELD_SCIENCE,    key = "TXT_KEY_CIVVACCESS_ICON_SCIENCE" },
    { id = YieldTypes.YIELD_CULTURE,    key = "TXT_KEY_CIVVACCESS_ICON_CULTURE" },
    { id = YieldTypes.YIELD_FAITH,      key = "TXT_KEY_CIVVACCESS_ICON_FAITH" },
}

local function readYields(plot, out)
    for _, y in ipairs(YIELD_KEYS) do
        local n = plot:CalculateYield(y.id, true)
        if n > 0 then
            out[#out + 1] = tostring(n) .. " " .. Text.key(y.key)
        end
    end
end

local function readBuildProgress(plot, out)
    local activePlayer = Game.GetActivePlayer()
    for buildInfo in GameInfo.Builds() do
        local turns = plot:GetBuildTurnsLeft(buildInfo.ID, activePlayer, 0, 0)
        -- Engine returns a sentinel large value when no build is in progress;
        -- PlotHelpManager filters with > 0 and < a large constant. Use the
        -- same shape: a real worker build has a positive small turn count.
        if turns ~= nil and turns > 0 and turns < 1000 then
            out[#out + 1] = Text.format("TXT_KEY_CIVVACCESS_BUILD_PROGRESS",
                Text.key(buildInfo.Description), turns)
        end
    end
end

function PlotComposers.economy(plot)
    local team, debug = Game.GetActiveTeam(), Game.IsDebugMode()
    if not plot:IsRevealed(team, debug) then
        return Text.key("TXT_KEY_CIVVACCESS_UNEXPLORED")
    end
    local visible = plot:IsVisible(team, debug)
    local out = {}
    if visible then
        readYields(plot, out)
    end
    if plot:IsFreshWater() then
        out[#out + 1] = Text.key("TXT_KEY_CIVVACCESS_FRESH_WATER")
    end
    if visible and plot:IsTradeRoute() then
        out[#out + 1] = Text.key("TXT_KEY_CIVVACCESS_TRADE_ROUTE")
    end
    local workingCity = plot:GetWorkingCity()
    if workingCity ~= nil then
        out[#out + 1] = Text.format("TXT_KEY_CIVVACCESS_WORKED_BY",
            workingCity:GetName())
    end
    if visible then
        readBuildProgress(plot, out)
    end
    return table.concat(out, ", ")
end

-- Civ V has no plot-level "is in ZoC" API; ZoC is a unit-side concept
-- (unit:GetNumEnemyUnitsAdjacent). From the cursor's perspective the
-- equivalent is: is this plot adjacent to a visible enemy combat unit?
-- Walk six neighbors and check.
local NEIGHBOR_DIRS = {
    DirectionTypes.DIRECTION_NORTHEAST,
    DirectionTypes.DIRECTION_EAST,
    DirectionTypes.DIRECTION_SOUTHEAST,
    DirectionTypes.DIRECTION_SOUTHWEST,
    DirectionTypes.DIRECTION_WEST,
    DirectionTypes.DIRECTION_NORTHWEST,
}

local function inEnemyZoC(plot, activeTeam, isDebug)
    local pTeam = Teams[activeTeam]
    for _, dir in ipairs(NEIGHBOR_DIRS) do
        local n = Map.PlotDirection(plot:GetX(), plot:GetY(), dir)
        if n ~= nil then
            local count = n:GetNumUnits()
            for i = 0, count - 1 do
                local u = n:GetUnit(i)
                if u ~= nil and not u:IsInvisible(activeTeam, isDebug)
                        and u:IsCombatUnit() then
                    local unitTeam = u:GetTeam()
                    if unitTeam ~= activeTeam and pTeam:IsAtWar(unitTeam) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- Dijkstra from the selected unit's plot to `target`. Costs are in internal
-- move-point units (GameDefines.MOVE_DENOMINATOR per tile on flat land);
-- the frontier is bounded by unit:MovesLeft() so we never explore further
-- than this turn can reach. plot:MovementCost handles embark, ZoC-end, road,
-- railroad, and territory-access rules because it's the same function the
-- engine's own pathfinder calls -- we inherit correctness by deferring.
-- Returns the integer cost to reach `target`, or nil if unreachable within
-- budget. No target → nil (callers guard). The intermediate / destination
-- distinction on CanMoveThrough vs CanMoveOrAttackInto matters because the
-- destination flag lets attacks land on already-at-war enemies.
local IMPASSABLE_SENTINEL = 1e8

local function pathCost(unit, target, budget)
    local startPlot = unit:GetPlot()
    if startPlot == nil then return nil end
    local tx, ty = target:GetX(), target:GetY()
    if startPlot:GetX() == tx and startPlot:GetY() == ty then return 0 end

    local width = Map.GetGridSize()
    local function key(p) return p:GetY() * width + p:GetX() end

    local visited = { [key(startPlot)] = 0 }
    local frontier = { { plot = startPlot, cost = 0 } }

    while #frontier > 0 do
        local minI, minCost = 1, frontier[1].cost
        for i = 2, #frontier do
            if frontier[i].cost < minCost then minI, minCost = i, frontier[i].cost end
        end
        local node = frontier[minI]
        table.remove(frontier, minI)

        if node.plot:GetX() == tx and node.plot:GetY() == ty then
            return node.cost
        end
        if node.cost > (visited[key(node.plot)] or IMPASSABLE_SENTINEL) then
            -- stale queue entry; a cheaper path already expanded this plot
        else
            for _, dir in ipairs(NEIGHBOR_DIRS) do
                local n = Map.PlotDirection(node.plot:GetX(), node.plot:GetY(), dir)
                if n ~= nil then
                    local isDestination = (n:GetX() == tx and n:GetY() == ty)
                    local canEnter
                    if isDestination then
                        canEnter = unit:CanMoveOrAttackInto(n, false, true)
                    else
                        canEnter = unit:CanMoveThrough(n)
                    end
                    if canEnter then
                        local movesRemaining = budget - node.cost
                        if movesRemaining < 0 then movesRemaining = 0 end
                        local step = n:MovementCost(unit, node.plot, movesRemaining)
                        if step >= 0 and step < IMPASSABLE_SENTINEL then
                            local newCost = node.cost + step
                            if newCost <= budget then
                                local k = key(n)
                                if visited[k] == nil or newCost < visited[k] then
                                    visited[k] = newCost
                                    frontier[#frontier + 1] = { plot = n, cost = newCost }
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function reachability(plot)
    local unit = UI.GetHeadSelectedUnit()
    if unit == nil then return nil end
    local unitPlot = unit:GetPlot()
    if unitPlot == nil then return nil end
    -- Cursor sitting on the unit is not an interesting reachability question;
    -- skip the slot so the user hears other combat facts uncluttered.
    if unitPlot:GetX() == plot:GetX() and unitPlot:GetY() == plot:GetY() then
        return nil
    end
    local cost = pathCost(unit, plot, unit:MovesLeft())
    if cost == nil then
        return Text.key("TXT_KEY_CIVVACCESS_OUT_OF_RANGE")
    end
    local denom = GameDefines.MOVE_DENOMINATOR or 60
    local moves = cost / denom
    local fmt
    if moves == math.floor(moves) then
        fmt = tostring(math.floor(moves))
    else
        fmt = string.format("%.1f", moves)
    end
    return Text.format("TXT_KEY_CIVVACCESS_MOVES_COST", fmt)
end

function PlotComposers.combat(plot)
    local team, debug = Game.GetActiveTeam(), Game.IsDebugMode()
    if not plot:IsRevealed(team, debug) then
        return Text.key("TXT_KEY_CIVVACCESS_UNEXPLORED")
    end
    local out = {}
    if plot:IsVisible(team, debug) and inEnemyZoC(plot, team, debug) then
        out[#out + 1] = Text.key("TXT_KEY_CIVVACCESS_ZONE_OF_CONTROL")
    end
    -- DefenseModifier(eAttackerTeam, bIgnoreBuilding, bHelp) returns the
    -- percent bonus a defender on this plot would receive. bHelp=true puts
    -- it in tooltip mode (includes terrain + feature + improvement bonuses
    -- the player would see). Pass the active team as the attacker so we
    -- get our perspective on what defenders here would gain.
    local def = plot:DefenseModifier(team, false, true)
    if def ~= 0 then
        out[#out + 1] = Text.format("TXT_KEY_CIVVACCESS_DEFENSE_MOD", def)
    end
    local reach = reachability(plot)
    if reach ~= nil then out[#out + 1] = reach end
    return table.concat(out, ", ")
end
