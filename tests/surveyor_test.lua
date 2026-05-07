-- Surveyor: per-scope logic, radius state, and the unexplored suffix.
-- HexGeom's plotsInRange inclusion math is covered in hexgeom_test; this
-- suite exercises the scope formatting and ordering layered on top.

local T = require("support")
local M = {}

local function setup()
    dofile("src/dlc/UI/InGame/CivVAccess_PlotSectionsCore.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_PlotSectionUnits.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_PlotSectionRiver.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_PlotComposers.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_CursorCore.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_SurveyorStrings_en_US.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_SurveyorCore.lua")

    Game.GetActivePlayer = function()
        return 0
    end
    Game.GetActiveTeam = function()
        return 0
    end
    Game.IsDebugMode = function()
        return false
    end

    Players = {}
    Teams = { [0] = T.fakeTeam() }
    GameInfo = {}
    GameInfo.Terrains = {}
    GameInfo.Features = {}
    GameInfo.Resources = {}
    GameInfo.Improvements = {}
    GameInfo.Routes = {}
    GameInfo.Units = {}

    Map.PlotDirection = function()
        return nil
    end
    Map.GetPlot = function()
        return nil
    end
    Map.IsWrapX = function()
        return false
    end

    UI.LookAt = function() end
    UI.GetHeadSelectedUnit = function()
        return nil
    end

    Cursor._reset()
    SurveyorCore._reset()
end

-- Build a revealed grid of plots over (-halfWidth..halfWidth)^2.
-- `configure(col, row)` is called for each plot to optionally mutate the
-- fakePlot fixture; return the fixture or nil to keep the default.
local function installGrid(halfWidth, configure)
    local plots = {}
    for col = -halfWidth, halfWidth do
        plots[col] = {}
        for row = -halfWidth, halfWidth do
            local p = T.fakePlot({ x = col, y = row })
            if configure ~= nil then
                local override = configure(col, row, p)
                if override ~= nil then
                    p = override
                end
            end
            plots[col][row] = p
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

-- Place the cursor at (0, 0) against the installed grid. Uses Cursor.init
-- via a stubbed selected unit so Surveyor's cursorPos() sees it.
local function initCursorAtOrigin(plots)
    local start = plots[0][0]
    local unit = T.fakeUnit({})
    unit._plot = start
    UI.GetHeadSelectedUnit = function()
        return unit
    end
    Cursor.init()
end

-- ===== Radius state =====

function M.test_radius_initializes_to_one_and_grow_speaks_two()
    setup()
    local out = SurveyorCore.grow()
    T.truthy(out:find("radius 2", 1, true), "first grow must speak radius 2: " .. out)
    T.truthy(not out:find("max", 1, true), "radius 2 must not carry max flag: " .. out)
end

function M.test_radius_grow_clamps_at_five_and_speaks_max()
    setup()
    local last
    for _ = 1, 10 do
        last = SurveyorCore.grow()
    end
    T.truthy(last:find("radius 5", 1, true), "radius must clamp at 5: " .. last)
    T.truthy(last:find("max", 1, true), "clamped grow must speak max: " .. last)
end

function M.test_radius_shrink_clamps_at_one_and_speaks_min()
    setup()
    local last
    for _ = 1, 10 do
        last = SurveyorCore.shrink()
    end
    T.truthy(last:find("radius 1", 1, true), "radius must clamp at 1: " .. last)
    T.truthy(last:find("min", 1, true), "clamped shrink must speak min: " .. last)
end

-- ===== Yields =====

function M.test_yields_sums_non_zero_across_radius()
    setup()
    local plots = installGrid(2, function(_, _, p)
        p._yields = { [YieldTypes.YIELD_FOOD] = 2, [YieldTypes.YIELD_PRODUCTION] = 1 }
        return p
    end)
    initCursorAtOrigin(plots)
    local out = SurveyorCore.yields()
    -- r=1 is 7 plots, so 14 food and 7 production.
    T.truthy(out:find("14 food", 1, true), "expected summed food: " .. out)
    T.truthy(out:find("7 production", 1, true), "expected summed production: " .. out)
    T.truthy(not out:find("gold", 1, true), "zero-yield must be omitted: " .. out)
end

function M.test_yields_empty_fallback_when_every_plot_is_zero()
    setup()
    local plots = installGrid(2)
    initCursorAtOrigin(plots)
    local out = SurveyorCore.yields()
    T.truthy(out:find("no yields in range", 1, true), "empty fallback expected: " .. out)
end

-- ===== Resources =====

function M.test_resources_bucket_and_sort_by_count()
    setup()
    GameInfo.Resources[4] = { Description = "Iron" }
    GameInfo.Resources[7] = { Description = "Wheat" }
    -- Two iron plots (qty 2 each) and one wheat plot (qty 1): iron 4,
    -- wheat 1. Sorted descending by count.
    local plots = installGrid(2, function(col, row, p)
        if col == 0 and row == 0 then
            p._resource = 4
            p._resourceQty = 2
        elseif col == 1 and row == 0 then
            p._resource = 4
            p._resourceQty = 2
        elseif col == -1 and row == 0 then
            p._resource = 7
            p._resourceQty = 1
        end
        return p
    end)
    initCursorAtOrigin(plots)
    local out = SurveyorCore.resources()
    local ironPos = out:find("4 Iron", 1, true)
    local wheatPos = out:find("1 Wheat", 1, true)
    T.truthy(ironPos, "expected '4 Iron': " .. out)
    T.truthy(wheatPos, "expected '1 Wheat': " .. out)
    T.truthy(ironPos < wheatPos, "iron (count 4) must sort before wheat (count 1): " .. out)
end

function M.test_resources_empty_fallback_when_none_revealed()
    setup()
    local plots = installGrid(2)
    initCursorAtOrigin(plots)
    local out = SurveyorCore.resources()
    T.truthy(out:find("no resources in range", 1, true), "empty fallback expected: " .. out)
end

-- ===== Terrain =====

function M.test_terrain_buckets_forest_on_tundra_as_two_tokens()
    -- Forest on tundra is the double-token case: the terrainShape section
    -- emits ["Forest", "Tundra"] so the bucket total can exceed the plot
    -- count. Surveyor must aggregate both tokens separately.
    setup()
    GameInfo.Terrains[3] = { Description = "Tundra" }
    GameInfo.Features[6] = { Description = "Forest", Type = "FEATURE_FOREST" }
    local plots = installGrid(1, function(_, _, p)
        p._terrain = 3
        p._feature = 6
        return p
    end)
    initCursorAtOrigin(plots)
    local out = SurveyorCore.terrain()
    -- r=1 is 7 plots, each contributes "Forest" + "Tundra".
    T.truthy(out:find("7 Forest", 1, true), "forest must be counted: " .. out)
    T.truthy(out:find("7 Tundra", 1, true), "tundra must be counted alongside forest: " .. out)
end

function M.test_terrain_sorts_by_count_descending()
    setup()
    GameInfo.Terrains[1] = { Description = "Plains" }
    GameInfo.Terrains[2] = { Description = "Desert" }
    -- 5 plains, 2 desert inside radius 1 (7 plots total).
    local plots = installGrid(1, function(col, row, p)
        if col == -1 and row == 0 then
            p._terrain = 2
        elseif col == 0 and row == -1 then
            p._terrain = 2
        else
            p._terrain = 1
        end
        return p
    end)
    initCursorAtOrigin(plots)
    local out = SurveyorCore.terrain()
    local plainsPos = out:find("Plains", 1, true)
    local desertPos = out:find("Desert", 1, true)
    T.truthy(plainsPos and desertPos, "both tokens expected: " .. out)
    T.truthy(plainsPos < desertPos, "descending-by-count ordering: " .. out)
end

-- ===== Own units =====

function M.test_own_units_lists_with_direction()
    setup()
    Players[0] = T.fakePlayer({ adj = "Roman" })
    GameInfo.Units[42] = { Description = "Warrior" }
    local warrior = T.fakeUnit({ owner = 0, unitType = 42 })
    local plots = installGrid(2, function(col, row, p)
        if col == 1 and row == 0 then
            p._units = { warrior }
        end
        return p
    end)
    initCursorAtOrigin(plots)
    local out = SurveyorCore.ownUnits()
    T.truthy(out:find("Warrior", 1, true), "unit name must appear: " .. out)
    T.truthy(out:find("1e", 1, true), "direction 1e must appear for (1,0): " .. out)
end

function M.test_own_units_orders_by_cube_distance_then_cw_rank()
    setup()
    Players[0] = T.fakePlayer({ adj = "Roman" })
    GameInfo.Units[42] = { Description = "Warrior" }
    GameInfo.Units[43] = { Description = "Scout" }
    GameInfo.Units[44] = { Description = "Archer" }
    -- Three units: Warrior at (1,0) dist 1 rank E=1; Scout at (0,1) dist
    -- 1 rank NE=6; Archer at (2,0) dist 2. Expected order: Warrior,
    -- Scout, Archer.
    local warrior = T.fakeUnit({ owner = 0, unitType = 42 })
    local scout = T.fakeUnit({ owner = 0, unitType = 43 })
    local archer = T.fakeUnit({ owner = 0, unitType = 44 })
    local plots = installGrid(3, function(col, row, p)
        if col == 1 and row == 0 then
            p._units = { warrior }
        elseif col == 0 and row == 1 then
            p._units = { scout }
        elseif col == 2 and row == 0 then
            p._units = { archer }
        end
        return p
    end)
    initCursorAtOrigin(plots)
    -- Bump the default radius (1) up to 2 so the ring-2 Archer is in range.
    SurveyorCore.grow()
    local out = SurveyorCore.ownUnits()
    local w = out:find("Warrior", 1, true)
    local s = out:find("Scout", 1, true)
    local a = out:find("Archer", 1, true)
    T.truthy(w and s and a, "all three units expected: " .. out)
    T.truthy(w < s, "Warrior (E, rank 1) must precede Scout (NE, rank 6): " .. out)
    T.truthy(s < a, "ring-1 units must precede ring-2 Archer: " .. out)
end

function M.test_own_units_empty_fallback()
    setup()
    local plots = installGrid(2)
    initCursorAtOrigin(plots)
    local out = SurveyorCore.ownUnits()
    T.truthy(out:find("no own units in range", 1, true), "empty fallback expected: " .. out)
end

function M.test_own_units_picks_up_trade_unit_on_fogged_plot()
    -- Trade units skip changeAdjacentSight in the engine (canChangeVisibility
    -- returns false for non-default map layers), so a player's own caravan
    -- can sit on a fogged plot. The Surveyor's own-units scope already
    -- iterates GetLayerUnit(-1) without an IsVisible gate, so trade units
    -- should appear naturally; pin that behaviour.
    setup()
    Players[0] = T.fakePlayer({ adj = "Roman" })
    GameInfo.Units[60] = { Description = "Caravan" }
    local caravan = T.fakeUnit({ owner = 0, team = 0, unitType = 60, trade = true })
    local plots = installGrid(2, function(col, row, p)
        if col == 1 and row == 0 then
            p._isVisible = false
            p._units = { caravan }
        end
        return p
    end)
    initCursorAtOrigin(plots)
    local out = SurveyorCore.ownUnits()
    T.truthy(out:find("Caravan", 1, true), "own caravan must surface on fogged plot: " .. out)
end

-- ===== Enemy units =====

function M.test_enemy_units_filters_invisible_and_requires_visible_plot()
    setup()
    Players[0] = T.fakePlayer({ adj = "Roman" })
    Players[1] = T.fakePlayer({ adj = "Mongolian", team = 1 })
    Teams[0] = T.fakeTeam({ atWar = { [1] = true } })
    GameInfo.Units[42] = { Description = "Horseman" }
    GameInfo.Units[43] = { Description = "Submarine" }
    local horseman = T.fakeUnit({ owner = 1, team = 1, unitType = 42 })
    local submarine = T.fakeUnit({ owner = 1, team = 1, unitType = 43, invisible = true })
    local plots = installGrid(2, function(col, row, p)
        if col == 1 and row == 0 then
            p._units = { horseman, submarine }
        elseif col == -1 and row == 0 then
            -- fogged plot with an enemy — must NOT be reported
            p._isVisible = false
            p._units = { T.fakeUnit({ owner = 1, team = 1, unitType = 42 }) }
        end
        return p
    end)
    initCursorAtOrigin(plots)
    local out = SurveyorCore.enemyUnits()
    T.truthy(out:find("Mongolian Horseman", 1, true), "visible horseman must appear with civ adj: " .. out)
    T.truthy(not out:find("Submarine", 1, true), "invisible unit must be filtered: " .. out)
    -- Fogged plot's horseman must also be filtered. Count "Horseman"
    -- occurrences: expect exactly 1 from the visible plot.
    local count = 0
    for _ in out:gmatch("Horseman") do
        count = count + 1
    end
    T.eq(count, 1, "fogged enemies must not be listed: " .. out)
end

function M.test_enemy_units_empty_fallback()
    setup()
    local plots = installGrid(2)
    initCursorAtOrigin(plots)
    local out = SurveyorCore.enemyUnits()
    T.truthy(out:find("no enemy units in range", 1, true), "empty fallback expected: " .. out)
end

-- ===== Cities =====

function M.test_cities_orders_closest_first_regardless_of_owner()
    setup()
    -- Two cities at ring 1 (Rome E, Karakorum W) and one at ring 2
    -- (Mecca NE-NE). Expect Rome first (E rank 1 beats W rank 4 at
    -- distance 1), then Karakorum, then Mecca at the outer ring. Owner
    -- identity must not influence ordering.
    local rome = T.fakeCity({ name = "Rome", owner = 0, id = 1 })
    local karakorum = T.fakeCity({ name = "Karakorum", owner = 1, id = 2 })
    local mecca = T.fakeCity({ name = "Mecca", owner = 2, id = 3 })
    local plots = installGrid(3, function(col, row, p)
        if col == 1 and row == 0 then
            p._isCity = true
            p._city = rome
        elseif col == -1 and row == 0 then
            p._isCity = true
            p._city = karakorum
        elseif col == 2 and row == 0 then
            p._isCity = true
            p._city = mecca
        end
        return p
    end)
    initCursorAtOrigin(plots)
    SurveyorCore.grow()
    local out = SurveyorCore.cities()
    local r = out:find("Rome", 1, true)
    local k = out:find("Karakorum", 1, true)
    local m = out:find("Mecca", 1, true)
    T.truthy(r and k and m, "all three city names expected: " .. out)
    T.truthy(r < k, "Rome (E, rank 1) must precede Karakorum (W, rank 4) at the same ring: " .. out)
    T.truthy(k < m, "ring-1 cities must precede ring-2 Mecca: " .. out)
    T.truthy(not out:find("friendly", 1, true), "no diplomacy grouping: " .. out)
    T.truthy(not out:find("hostile", 1, true), "no diplomacy grouping: " .. out)
    T.truthy(not out:find("neutral", 1, true), "no diplomacy grouping: " .. out)
end

function M.test_cities_empty_fallback()
    setup()
    local plots = installGrid(2)
    initCursorAtOrigin(plots)
    local out = SurveyorCore.cities()
    T.truthy(out:find("no cities in range", 1, true), "empty fallback expected: " .. out)
end

function M.test_cities_includes_barbarian_camps()
    setup()
    -- Camps share the cities scope (the hostile-settlement mental slot).
    -- Place a real city E at ring 1 and a camp W at ring 1; both must
    -- appear, ordered by the shared distance-then-direction comparator.
    GameInfoTypes.IMPROVEMENT_BARBARIAN_CAMP = 99
    local rome = T.fakeCity({ name = "Rome", owner = 0, id = 1 })
    local plots = installGrid(2, function(col, row, p)
        if col == 1 and row == 0 then
            p._isCity = true
            p._city = rome
        elseif col == -1 and row == 0 then
            p._improvement = 99
        end
        return p
    end)
    initCursorAtOrigin(plots)
    local out = SurveyorCore.cities()
    local r = out:find("Rome", 1, true)
    local c = out:find("BARBARIAN_CAMP", 1, true)
    T.truthy(r and c, "city and camp must both appear: " .. out)
    T.truthy(r < c, "Rome (E, rank 1) must precede camp (W, rank 4): " .. out)
end

-- ===== Unexplored suffix =====

function M.test_unexplored_suffix_appended_when_fogged_plots_in_range()
    setup()
    local plots = installGrid(1, function(col, row, p)
        if col == 1 and row == 0 then
            p._isRevealed = false
        end
        return p
    end)
    initCursorAtOrigin(plots)
    local out = SurveyorCore.yields()
    T.truthy(out:find("1 tile unexplored", 1, true), "unexplored suffix must reflect fogged count: " .. out)
end

function M.test_unexplored_suffix_appended_even_on_empty_scope()
    -- Empty-scope body + unexplored suffix is explicitly called out in
    -- the design: "no resources in range. 4 tiles unexplored." so the
    -- user knows the radius might contain more past the fog.
    setup()
    local plots = installGrid(1, function(_, _, p)
        p._isRevealed = false
        return p
    end)
    -- The center must be revealed so initCursorAtOrigin can place the
    -- cursor; override just that cell after the grid install.
    plots[0][0]._isRevealed = true
    initCursorAtOrigin(plots)
    local out = SurveyorCore.resources()
    T.truthy(out:find("no resources in range", 1, true), "empty fallback body: " .. out)
    T.truthy(out:find("tiles unexplored", 1, true), "unexplored suffix must still follow: " .. out)
end

function M.test_unexplored_suffix_suppressed_when_zero()
    setup()
    local plots = installGrid(2)
    initCursorAtOrigin(plots)
    local out = SurveyorCore.yields()
    T.truthy(not out:find("unexplored", 1, true), "no unexplored suffix when count is zero: " .. out)
end

return M
