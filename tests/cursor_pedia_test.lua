-- CursorPedia enumeration tests. Exercises _buildEntries against fake
-- plots, units, and city contents to confirm: (1) everything with a pedia
-- article at the cursor plot is listed, (2) dedup collapses same-pedia
-- entries (four fighters on a carrier produce a single Fighter row),
-- (3) units foreign / cargo are still surfaced (you can look up an enemy
-- Warrior's stats even though you can't select it), (4) invisible / fogged
-- units and unrevealed resources / improvements / routes are filtered,
-- (5) only world wonders appear from the city on the tile (not national
-- or team wonders), (6) unrevealed plots produce zero entries, and
-- (7) a bare revealed plot always has at least the terrain row (so the
-- single-entry auto-open answers "what terrain is this?" without a
-- picker). BaseMenu push / Events.SearchForPediaEntry are production-side
-- concerns covered by the handler_stack / civilopedia suites; this one
-- is just about the entry list.

local T = require("support")
local M = {}

local function setup()
    -- Silence missing-TXT_KEY warnings so the runner output stays clean;
    -- the fake GameInfo rows carry unregistered TXT_KEY_UNIT_* strings
    -- that Text.key would otherwise log on every pedia-name resolution.
    Log = Log or {}
    Log.warn = function() end
    Log.error = function() end
    Log.info = function() end
    Log.debug = function() end

    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_CursorPedia.lua")

    Game.GetActivePlayer = function()
        return 0
    end
    Game.GetActiveTeam = function()
        return 0
    end
    Game.IsDebugMode = function()
        return false
    end

    -- Reset GameInfo tables per-suite so earlier cases don't leak rows
    -- into later ones. Tests populate the entries they need.
    GameInfo = {}
    GameInfo.Units = {}
    GameInfo.Improvements = {}
    GameInfo.Resources = {}
    GameInfo.Features = {}
    GameInfo.Terrains = {}
    GameInfo.Routes = {}
    GameInfo.BuildingClasses = {}
    GameInfo.FakeFeatures = {}
    local buildingRows = {}
    GameInfo.Buildings = function()
        local i = 0
        return function()
            i = i + 1
            return buildingRows[i]
        end
    end
    GameInfo._setBuildings = function(rows)
        buildingRows = rows
    end
end

-- Convenience: extract the pediaName list from an entry array so assertions
-- read as "what articles are offered" without per-field boilerplate.
local function pediaNames(entries)
    local names = {}
    for _, e in ipairs(entries) do
        names[#names + 1] = e.pediaName
    end
    return names
end

local function eqList(actual, expected)
    T.eq(#actual, #expected, "list length")
    for i, v in ipairs(expected) do
        T.eq(actual[i], v, "list[" .. i .. "]")
    end
end

function M.test_unrevealed_plot_returns_empty()
    -- Guard: Ctrl+I on fog / unexplored must no-op. Pedia articles for
    -- terrain / features etc. are not secrets, but surfacing them on
    -- an unrevealed tile leaks "something is there" information the
    -- player hasn't earned via exploration.
    setup()
    GameInfo.Terrains[0] = { Description = "TXT_KEY_TERRAIN_GRASS" }
    local p = T.fakePlot({ revealed = false, terrain = 0 })
    T.eq(#CursorPedia._buildEntries(p), 0)
end

function M.test_bare_plot_returns_terrain_only()
    -- Minimum case: a revealed plot with no units / improvement / feature
    -- / route / resource. Terrain is always present so the picker gets
    -- exactly one row, which the run() auto-opens.
    setup()
    GameInfo.Terrains[0] = { Description = "TXT_KEY_TERRAIN_GRASS" }
    local p = T.fakePlot({ terrain = 0 })
    eqList(pediaNames(CursorPedia._buildEntries(p)), { "TXT_KEY_TERRAIN_GRASS" })
end

function M.test_dedup_four_same_type_units()
    -- The feature's headline case: a carrier with four fighters must
    -- produce a single Fighter pedia row, not four. Dedup key is the
    -- pediaName string itself (identical Description TXT_KEYs collapse).
    setup()
    GameInfo.Units[5] = { Description = "TXT_KEY_UNIT_FIGHTER" }
    GameInfo.Terrains[0] = { Description = "TXT_KEY_TERRAIN_OCEAN" }
    local f1 = T.fakeUnit({ unitType = 5 })
    local f2 = T.fakeUnit({ unitType = 5 })
    local f3 = T.fakeUnit({ unitType = 5 })
    local f4 = T.fakeUnit({ unitType = 5 })
    local p = T.fakePlot({ terrain = 0, units = { f1, f2, f3, f4 } })
    eqList(pediaNames(CursorPedia._buildEntries(p)), { "TXT_KEY_UNIT_FIGHTER", "TXT_KEY_TERRAIN_OCEAN" })
end

function M.test_mixed_unit_types_all_listed()
    -- Distinct unit types on the same plot each produce their own row;
    -- dedup only collapses same-pediaName entries.
    setup()
    GameInfo.Units[1] = { Description = "TXT_KEY_UNIT_WARRIOR" }
    GameInfo.Units[2] = { Description = "TXT_KEY_UNIT_ARCHER" }
    GameInfo.Terrains[0] = { Description = "TXT_KEY_TERRAIN_PLAINS" }
    local warrior = T.fakeUnit({ unitType = 1 })
    local archer = T.fakeUnit({ unitType = 2 })
    local p = T.fakePlot({ terrain = 0, units = { warrior, archer } })
    eqList(
        pediaNames(CursorPedia._buildEntries(p)),
        { "TXT_KEY_UNIT_WARRIOR", "TXT_KEY_UNIT_ARCHER", "TXT_KEY_TERRAIN_PLAINS" }
    )
end

function M.test_foreign_unit_surfaced()
    -- CursorActivate filters foreign units (you can't select them); the
    -- pedia picker does not, because knowing what a rival Warrior IS is
    -- exactly the question the key answers.
    setup()
    GameInfo.Units[1] = { Description = "TXT_KEY_UNIT_WARRIOR" }
    GameInfo.Terrains[0] = { Description = "TXT_KEY_TERRAIN_PLAINS" }
    local enemy = T.fakeUnit({ unitType = 1, owner = 1 })
    local p = T.fakePlot({ terrain = 0, units = { enemy } })
    eqList(pediaNames(CursorPedia._buildEntries(p)), { "TXT_KEY_UNIT_WARRIOR", "TXT_KEY_TERRAIN_PLAINS" })
end

function M.test_cargo_unit_surfaced()
    -- Cargo units (fighters in a carrier, embarked passengers) don't
    -- appear in the activate picker because they're not first-class
    -- selectable units, but their pedia articles are legitimate tile
    -- contents.
    setup()
    GameInfo.Units[5] = { Description = "TXT_KEY_UNIT_FIGHTER" }
    GameInfo.Terrains[0] = { Description = "TXT_KEY_TERRAIN_OCEAN" }
    local passenger = T.fakeUnit({ unitType = 5, cargo = true })
    local p = T.fakePlot({ terrain = 0, units = { passenger } })
    eqList(pediaNames(CursorPedia._buildEntries(p)), { "TXT_KEY_UNIT_FIGHTER", "TXT_KEY_TERRAIN_OCEAN" })
end

function M.test_invisible_unit_filtered()
    -- A stealth unit (sub, spy) or one on a plot currently fogged to the
    -- active team must not surface -- same IsInvisible gate the S key /
    -- activate picker use.
    setup()
    GameInfo.Units[7] = { Description = "TXT_KEY_UNIT_SUBMARINE" }
    GameInfo.Terrains[0] = { Description = "TXT_KEY_TERRAIN_OCEAN" }
    local sub = T.fakeUnit({ unitType = 7, invisible = true })
    local p = T.fakePlot({ terrain = 0, units = { sub } })
    eqList(pediaNames(CursorPedia._buildEntries(p)), { "TXT_KEY_TERRAIN_OCEAN" })
end

function M.test_improvement_listed()
    setup()
    GameInfo.Improvements[3] = { Description = "TXT_KEY_IMPROVEMENT_FARM" }
    GameInfo.Terrains[0] = { Description = "TXT_KEY_TERRAIN_PLAINS" }
    local p = T.fakePlot({ terrain = 0, improvement = 3 })
    eqList(pediaNames(CursorPedia._buildEntries(p)), { "TXT_KEY_IMPROVEMENT_FARM", "TXT_KEY_TERRAIN_PLAINS" })
end

function M.test_unrevealed_improvement_skipped()
    -- The plot reports -1 for revealed improvement when the active team
    -- hasn't seen the tile since the improvement was built. Nothing to
    -- surface.
    setup()
    GameInfo.Improvements[3] = { Description = "TXT_KEY_IMPROVEMENT_FARM" }
    GameInfo.Terrains[0] = { Description = "TXT_KEY_TERRAIN_PLAINS" }
    local p = T.fakePlot({ terrain = 0, improvement = -1 })
    eqList(pediaNames(CursorPedia._buildEntries(p)), { "TXT_KEY_TERRAIN_PLAINS" })
end

function M.test_resource_listed()
    setup()
    GameInfo.Resources[4] = { Description = "TXT_KEY_RESOURCE_IRON" }
    GameInfo.Terrains[0] = { Description = "TXT_KEY_TERRAIN_HILLS" }
    local p = T.fakePlot({ terrain = 0, resource = 4 })
    eqList(pediaNames(CursorPedia._buildEntries(p)), { "TXT_KEY_RESOURCE_IRON", "TXT_KEY_TERRAIN_HILLS" })
end

function M.test_hidden_resource_skipped()
    -- Strategic / luxury resources require a tech to become visible. The
    -- engine's plot:GetResourceType(team) returns -1 for hidden, so
    -- nothing leaks.
    setup()
    GameInfo.Resources[4] = { Description = "TXT_KEY_RESOURCE_IRON" }
    GameInfo.Terrains[0] = { Description = "TXT_KEY_TERRAIN_HILLS" }
    local p = T.fakePlot({ terrain = 0, resource = -1 })
    eqList(pediaNames(CursorPedia._buildEntries(p)), { "TXT_KEY_TERRAIN_HILLS" })
end

function M.test_feature_listed()
    setup()
    GameInfo.Features[2] = { Description = "TXT_KEY_FEATURE_FOREST" }
    GameInfo.Terrains[0] = { Description = "TXT_KEY_TERRAIN_PLAINS" }
    local p = T.fakePlot({ terrain = 0, feature = 2 })
    eqList(pediaNames(CursorPedia._buildEntries(p)), { "TXT_KEY_FEATURE_FOREST", "TXT_KEY_TERRAIN_PLAINS" })
end

function M.test_route_listed()
    setup()
    GameInfo.Routes[1] = { Description = "TXT_KEY_ROUTE_ROAD" }
    GameInfo.Terrains[0] = { Description = "TXT_KEY_TERRAIN_PLAINS" }
    local p = T.fakePlot({ terrain = 0, route = 1 })
    eqList(pediaNames(CursorPedia._buildEntries(p)), { "TXT_KEY_TERRAIN_PLAINS", "TXT_KEY_ROUTE_ROAD" })
end

function M.test_no_route_skipped()
    setup()
    GameInfo.Terrains[0] = { Description = "TXT_KEY_TERRAIN_PLAINS" }
    local p = T.fakePlot({ terrain = 0, route = -1 })
    eqList(pediaNames(CursorPedia._buildEntries(p)), { "TXT_KEY_TERRAIN_PLAINS" })
end

function M.test_city_world_wonder_listed()
    -- World wonders on the tile's city show up as pedia rows. National
    -- wonders (MaxPlayerInstances == 1) and team wonders (MaxTeamInstances
    -- > 0) do not -- scope decision per user: city screen's wonder list
    -- already covers those, and noise on every city tile would dominate
    -- the picker.
    setup()
    GameInfo.BuildingClasses.WORLD_WONDER_CLASS = { MaxGlobalInstances = 1, MaxPlayerInstances = -1, MaxTeamInstances = 0 }
    GameInfo._setBuildings({
        { ID = 100, BuildingClass = "WORLD_WONDER_CLASS", Description = "TXT_KEY_BUILDING_PYRAMIDS" },
    })
    GameInfo.Terrains[0] = { Description = "TXT_KEY_TERRAIN_PLAINS" }
    local city = T.fakeCity({ name = "Memphis" })
    function city:IsHasBuilding(id)
        return id == 100
    end
    local p = T.fakePlot({ terrain = 0, isCity = true, city = city })
    eqList(pediaNames(CursorPedia._buildEntries(p)), { "TXT_KEY_BUILDING_PYRAMIDS", "TXT_KEY_TERRAIN_PLAINS" })
end

function M.test_city_national_wonder_filtered()
    -- National wonder marker: MaxPlayerInstances == 1 but not a world
    -- wonder (MaxGlobalInstances == 0). Must not appear in the picker.
    setup()
    GameInfo.BuildingClasses.NATIONAL_WONDER_CLASS =
        { MaxGlobalInstances = 0, MaxPlayerInstances = 1, MaxTeamInstances = 0 }
    GameInfo._setBuildings({
        { ID = 200, BuildingClass = "NATIONAL_WONDER_CLASS", Description = "TXT_KEY_BUILDING_NATIONAL_EPIC" },
    })
    GameInfo.Terrains[0] = { Description = "TXT_KEY_TERRAIN_PLAINS" }
    local city = T.fakeCity({ name = "Memphis" })
    function city:IsHasBuilding(id)
        return id == 200
    end
    local p = T.fakePlot({ terrain = 0, isCity = true, city = city })
    eqList(pediaNames(CursorPedia._buildEntries(p)), { "TXT_KEY_TERRAIN_PLAINS" })
end

function M.test_city_not_built_wonder_filtered()
    -- GameInfo.Buildings enumerates every wonder in the game; only the
    -- ones actually built in the tile's city (IsHasBuilding true) should
    -- surface.
    setup()
    GameInfo.BuildingClasses.WORLD_WONDER_CLASS = { MaxGlobalInstances = 1, MaxPlayerInstances = -1, MaxTeamInstances = 0 }
    GameInfo._setBuildings({
        { ID = 100, BuildingClass = "WORLD_WONDER_CLASS", Description = "TXT_KEY_BUILDING_PYRAMIDS" },
        { ID = 101, BuildingClass = "WORLD_WONDER_CLASS", Description = "TXT_KEY_BUILDING_HANGING_GARDENS" },
    })
    GameInfo.Terrains[0] = { Description = "TXT_KEY_TERRAIN_PLAINS" }
    local city = T.fakeCity({ name = "Memphis" })
    function city:IsHasBuilding(id)
        return id == 101
    end
    local p = T.fakePlot({ terrain = 0, isCity = true, city = city })
    eqList(pediaNames(CursorPedia._buildEntries(p)), { "TXT_KEY_BUILDING_HANGING_GARDENS", "TXT_KEY_TERRAIN_PLAINS" })
end

function M.test_hills_adds_entry_with_underlying_terrain()
    -- A Plains Hills plot has terrain=Plains and plot type=HILLS. Both
    -- land as separate pedia entries; sighted players see "Plains Hills"
    -- and the two pedia articles are distinct.
    setup()
    GameInfo.Terrains[0] = { Description = "TXT_KEY_TERRAIN_PLAINS" }
    GameInfo.Terrains.TERRAIN_HILL = { Description = "TXT_KEY_TERRAIN_HILL" }
    local p = T.fakePlot({ terrain = 0, hills = true })
    eqList(pediaNames(CursorPedia._buildEntries(p)), { "TXT_KEY_TERRAIN_PLAINS", "TXT_KEY_TERRAIN_HILL" })
end

function M.test_mountain_collapses_with_terrain_via_dedup()
    -- Mountain plots carry terrain=TERRAIN_MOUNTAIN and IsMountain=true.
    -- Both branches look up the same Description TXT_KEY, so dedup
    -- collapses them to one row rather than speaking "Mountain,
    -- Mountain".
    setup()
    GameInfo.Terrains[0] = { Description = "TXT_KEY_TERRAIN_MOUNTAIN" }
    GameInfo.Terrains.TERRAIN_MOUNTAIN = { Description = "TXT_KEY_TERRAIN_MOUNTAIN" }
    local p = T.fakePlot({ terrain = 0, mountain = true })
    eqList(pediaNames(CursorPedia._buildEntries(p)), { "TXT_KEY_TERRAIN_MOUNTAIN" })
end

function M.test_river_adds_entry()
    setup()
    GameInfo.Terrains[0] = { Description = "TXT_KEY_TERRAIN_PLAINS" }
    GameInfo.FakeFeatures.FEATURE_RIVER = { Description = "TXT_KEY_CIV5_FEATURES_RIVER_TITLE" }
    local p = T.fakePlot({ terrain = 0, river = true })
    eqList(
        pediaNames(CursorPedia._buildEntries(p)),
        { "TXT_KEY_CIV5_FEATURES_RIVER_TITLE", "TXT_KEY_TERRAIN_PLAINS" }
    )
end

function M.test_lake_adds_entry()
    setup()
    GameInfo.Terrains[0] = { Description = "TXT_KEY_TERRAIN_COAST" }
    GameInfo.FakeFeatures.FEATURE_LAKE = { Description = "TXT_KEY_CIV5_FEATURES_LAKE_TITLE" }
    local p = T.fakePlot({ terrain = 0, lake = true })
    eqList(pediaNames(CursorPedia._buildEntries(p)), { "TXT_KEY_CIV5_FEATURES_LAKE_TITLE", "TXT_KEY_TERRAIN_COAST" })
end

function M.test_full_tile_composition()
    -- End-to-end: a revealed plot with a unit, an improvement, a resource,
    -- a feature, a terrain, and a route produces all six rows in the
    -- documented order (units first, then wonders, improvement, resource,
    -- feature, terrain, route).
    setup()
    GameInfo.Units[1] = { Description = "TXT_KEY_UNIT_WARRIOR" }
    GameInfo.Improvements[3] = { Description = "TXT_KEY_IMPROVEMENT_FARM" }
    GameInfo.Resources[4] = { Description = "TXT_KEY_RESOURCE_WHEAT" }
    GameInfo.Features[2] = { Description = "TXT_KEY_FEATURE_FOREST" }
    GameInfo.Terrains[0] = { Description = "TXT_KEY_TERRAIN_PLAINS" }
    GameInfo.Routes[1] = { Description = "TXT_KEY_ROUTE_ROAD" }
    local warrior = T.fakeUnit({ unitType = 1 })
    local p = T.fakePlot({
        terrain = 0,
        feature = 2,
        resource = 4,
        improvement = 3,
        route = 1,
        units = { warrior },
    })
    eqList(pediaNames(CursorPedia._buildEntries(p)), {
        "TXT_KEY_UNIT_WARRIOR",
        "TXT_KEY_IMPROVEMENT_FARM",
        "TXT_KEY_RESOURCE_WHEAT",
        "TXT_KEY_FEATURE_FOREST",
        "TXT_KEY_TERRAIN_PLAINS",
        "TXT_KEY_ROUTE_ROAD",
    })
end

return M
