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
        if t ~= nil and t ~= "" then
            out[#out + 1] = t
        end
    end
end

-- Per-move glance: terrain-shape facts that distinguish this hex from its
-- neighbors, in distinguishing-fact-first order. Units and city come first
-- because those are the most commonly important; geography sandwiches them.
-- The Cursor gates on IsRevealed before calling in; this composer only
-- handles the revealed-but-fogged distinction, prepending a "fog" marker so
-- the user knows the data is stale before hearing it.
--
-- opts.cueOnly suppresses tokens the audio cue layer already carries: the
-- fog marker (fog wash covers it), the route section (road stinger covers
-- it), and base terrain / mountain / lake / non-wonder feature names
-- (terrain/feature beds cover those). Hills, wonders, units, resources,
-- improvements, rivers, and the city banner stay -- they have no audio
-- representation in the v1 palette and the user needs them as words.
function PlotComposers.glance(plot, opts)
    opts = opts or {}
    local cueOnly = opts.cueOnly or false
    local team, debug = Game.GetActiveTeam(), Game.IsDebugMode()
    local visible = plot:IsVisible(team, debug)
    local ctx = { cueOnly = cueOnly }
    local tokens = {}
    if not visible and not cueOnly then
        tokens[#tokens + 1] = Text.key("TXT_KEY_CIVVACCESS_FOG")
    end
    if visible then
        readSection(PlotSectionUnits, plot, ctx, tokens)
    end
    readSection(PlotSections.city, plot, ctx, tokens)
    if not cueOnly then
        readSection(PlotSections.route, plot, ctx, tokens)
    end
    readSection(PlotSections.terrainShape, plot, ctx, tokens)
    readSection(PlotSections.resource, plot, ctx, tokens)
    readSection(PlotSections.improvement, plot, ctx, tokens)
    readSection(PlotSectionRiver, plot, ctx, tokens)
    -- Recommendation tail: tells the user what the engine's anchor would
    -- say on this plot if they could see it. Last so it reads as a
    -- separate "btw, here's a suggestion" after the factual description.
    readSection(PlotSections.recommendation, plot, ctx, tokens)
    return table.concat(tokens, ", ")
end

-- W: economy details. Yields are nonzero-only; the rest are simple flags.
local YIELD_KEYS = {
    { id = YieldTypes.YIELD_FOOD, key = "TXT_KEY_CIVVACCESS_ICON_FOOD" },
    { id = YieldTypes.YIELD_PRODUCTION, key = "TXT_KEY_CIVVACCESS_ICON_PRODUCTION" },
    { id = YieldTypes.YIELD_GOLD, key = "TXT_KEY_CIVVACCESS_ICON_GOLD" },
    { id = YieldTypes.YIELD_SCIENCE, key = "TXT_KEY_CIVVACCESS_ICON_SCIENCE" },
    { id = YieldTypes.YIELD_CULTURE, key = "TXT_KEY_CIVVACCESS_ICON_CULTURE" },
    { id = YieldTypes.YIELD_FAITH, key = "TXT_KEY_CIVVACCESS_ICON_FAITH" },
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
            out[#out + 1] = Text.format("TXT_KEY_CIVVACCESS_BUILD_PROGRESS", Text.key(buildInfo.Description), turns)
        end
    end
end

-- Yields, trade route, worker builds, and working city all read live
-- state; the engine exposes no GetRevealedX variants. Base game's plot
-- tooltip (PlotHelpManager.lua) shows all of them on any IsRevealed plot
-- without an IsVisible gate, so a fogged tile reports current yields /
-- current trade route / current worker turns / current working city --
-- possibly stale relative to what the player last saw. Match the engine's
-- exposure rather than gate tighter: the game treats this as the
-- player's view of "what they remember," and our speech output should
-- surface the same facts a sighted player would see in the tooltip.
function PlotComposers.economy(plot, opts)
    opts = opts or {}
    local team, debug = Game.GetActiveTeam(), Game.IsDebugMode()
    if not plot:IsRevealed(team, debug) then
        return Text.key("TXT_KEY_CIVVACCESS_UNEXPLORED")
    end
    local out = {}
    readYields(plot, out)
    if plot:IsFreshWater() then
        out[#out + 1] = Text.key("TXT_KEY_CIVVACCESS_FRESH_WATER")
    end
    if plot:IsTradeRoute() then
        out[#out + 1] = Text.key("TXT_KEY_CIVVACCESS_TRADE_ROUTE")
    end
    local workingCity = plot:GetWorkingCity()
    if workingCity ~= nil then
        -- In CityView's hex sub the caller knows which city the user is
        -- managing, so the city name in "controlled by X" is noise unless X
        -- is a different city (rare split-ring case). Pass opts.contextCity
        -- to opt into the shorter form when they match.
        local ctx = opts.contextCity
        if ctx ~= nil and workingCity:GetID() == ctx:GetID() and workingCity:GetOwner() == ctx:GetOwner() then
            out[#out + 1] = Text.key("TXT_KEY_CIVVACCESS_CONTROLLED")
        else
            out[#out + 1] = Text.format("TXT_KEY_CIVVACCESS_CONTROLLED_BY", workingCity:GetName())
        end
    end
    readBuildProgress(plot, out)
    -- Barren tile (no yields, no fresh water, no trade route, no working
    -- city, no build in progress) would otherwise speak nothing and leave
    -- the player thinking the key broke. Fall back to the engine's own
    -- "No Yield" key so they get a definitive answer.
    if #out == 0 then
        return Text.key("TXT_KEY_PEDIA_NO_YIELD")
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
                if u ~= nil and not u:IsInvisible(activeTeam, isDebug) and u:IsCombatUnit() then
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
-- reads as impassable. Returns (cost, impassable). This is the on-demand
-- combat-info answer (PlotComposers.combat, the X key), which has no actor
-- to path from -- the player is asking "what does this hex cost in
-- general," not "what does it cost for unit U coming from plot F." Unit-
-- aware cost (embark, ZoC-end, road bypass, territory access, river-edge
-- bridges) requires the pair of plots and the unit, which the keyboard
-- cursor doesn't have here. Per-unit pathing is answered separately by
-- UnitTargetMode's move preview via the engine fork's Unit:GeneratePath.
local function tileMoveCost(plot)
    if plot:IsMountain() then
        return nil, true
    end
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
        if trow and trow.Movement then
            cost = trow.Movement
        end
    end
    if plot:IsHills() then
        cost = cost + 1
    end
    return cost, false
end

function PlotComposers.combat(plot)
    local team, debug = Game.GetActiveTeam(), Game.IsDebugMode()
    if not plot:IsRevealed(team, debug) then
        return Text.key("TXT_KEY_CIVVACCESS_UNEXPLORED")
    end
    local out = {}
    -- ZoC needs live sight of neighbors -- invisible adjacent units
    -- can't project ZoC the player knows about -- so this genuinely
    -- requires IsVisible, not a fog-leak policy choice.
    if plot:IsVisible(team, debug) and inEnemyZoC(plot, team, debug) then
        out[#out + 1] = Text.key("TXT_KEY_CIVVACCESS_ZONE_OF_CONTROL")
    end
    -- DefenseModifier(eAttackerTeam, bIgnoreBuilding, bHelp) returns the
    -- percent bonus a defender on this plot would receive. bHelp=true puts
    -- it in tooltip mode (includes terrain + feature + improvement bonuses
    -- the player would see). Pass the active team as the attacker so we
    -- get our perspective on what defenders here would gain. Reads live
    -- on fogged tiles (the improvement component can be stale), matching
    -- PlotHelpManager.lua's unguarded use.
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
    -- Route presence: the cost above is the unmodified tile cost; a road
    -- or railroad reduces it for a unit moving in from another routed
    -- tile. The actual reduced cost needs the from-plot, the unit, and
    -- the from-to river-edge bridge check (CvUnitMovement.cpp:74), none
    -- of which the keyboard cursor has. Naming the route keeps the
    -- on-demand combat answer honest. Duplicates the glance's route token
    -- intentionally so the X answer is self-contained.
    readSection(PlotSections.route, plot, {}, out)
    return table.concat(out, ", ")
end
