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

-- Tile-level movement cost from terrain / feature / plotType data alone:
-- a feature with nonzero Movement overrides the terrain cost (forest=2,
-- jungle=2, marsh=3 in the shipped data); hills otherwise add 1; mountain
-- reads as impassable. Returns (cost, impassable). Unit-dependent rules
-- (embark, ZoC-end, road bypass, territory access) are deliberately out
-- of scope: the engine's plot-side bindings (Plot:MovementCost,
-- Unit:CanMoveThrough, Unit:CanMoveOrAttackInto) have no callsites in any
-- shipped game Lua and access-violated CvGameCore_Expansion2 when invoked
-- from this Context.
local function tileMoveCost(plot)
    if plot:IsMountain() then return nil, true end
    local fid = plot:GetFeatureType()
    if fid >= 0 then
        local frow = GameInfo.Features[fid]
        if frow and frow.Movement and frow.Movement > 0 then
            return frow.Movement, false
        end
    end
    local cost = 1
    local tid = plot:GetTerrainType()
    if tid >= 0 then
        local trow = GameInfo.Terrains[tid]
        if trow and trow.Movement then cost = trow.Movement end
    end
    if plot:IsHills() then cost = cost + 1 end
    return cost, false
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
    local cost, impassable = tileMoveCost(plot)
    if impassable then
        out[#out + 1] = Text.key("TXT_KEY_PEDIA_IMPASSABLE")
    elseif cost ~= nil then
        out[#out + 1] = Text.format("TXT_KEY_CIVVACCESS_MOVES_COST", cost)
    end
    return table.concat(out, ", ")
end
