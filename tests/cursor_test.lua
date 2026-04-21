-- Tests for the hex-grid cursor: per-section logic, composer integration,
-- cursor state machine. Each test exercises one failure mode the others
-- don't cover; sections that exist only to call game APIs (terrain name
-- lookup, route name lookup) are covered by integration via the glance
-- composer rather than per-section.

local T = require("support")
local M = {}

local function setup()
    dofile("src/dlc/UI/InGame/CivVAccess_PlotSectionsCore.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_PlotSectionUnits.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_PlotSectionRiver.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_PlotComposers.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_Cursor.lua")

    Game.GetActivePlayer = function()
        return 0
    end
    Game.GetActiveTeam = function()
        return 0
    end
    Game.IsDebugMode = function()
        return false
    end

    -- Wipe per-test scenario tables so fixtures from a prior test don't leak.
    Players = {}
    Teams = { [0] = T.fakeTeam() }
    GameInfo = {}
    GameInfo.Terrains = {}
    GameInfo.Features = {}
    GameInfo.Resources = {}
    GameInfo.Improvements = {}
    GameInfo.Routes = {}
    GameInfo.Builds = function()
        return function()
            return nil
        end
    end
    GameInfo.Technologies = {}

    -- Default Map: tests that need neighbor lookups (river, ZoC) override
    -- PlotDirection per-test.
    Map.PlotDirection = function()
        return nil
    end
    Map.GetPlot = function()
        return nil
    end
    Map.IsWrapX = function()
        return false
    end

    UI.LookAt = function(_plot, _flag) end
    UI.GetHeadSelectedUnit = function()
        return nil
    end

    Cursor._reset()
end

-- ===== Owner identity =====

function M.test_owner_identity_unclaimed()
    setup()
    local p = T.fakePlot({ owner = -1 })
    local spoken, id = PlotSections.ownerIdentity(p)
    T.eq(spoken, "unclaimed")
    T.eq(id, "unclaimed")
end

function M.test_owner_identity_civ_uses_short_description()
    setup()
    Players[3] = T.fakePlayer({ shortDesc = "Arabia", adj = "Arabian" })
    local p = T.fakePlot({ owner = 3 })
    local spoken, id = PlotSections.ownerIdentity(p)
    T.eq(spoken, "Arabia")
    T.eq(id, "civ:3")
end

function M.test_owner_identity_city_shares_territory_identity_of_owning_civ()
    -- A city tile owned by civ N must produce the same identity token as a
    -- non-city tile owned by civ N, so stepping civ-tile -> city-tile-of-
    -- same-civ doesn't re-fire the cursor's owner prefix. The City section
    -- in the glance announces the city banner; the prefix is for civ-border
    -- crossings, and walking into one of your civ's own cities is not one.
    setup()
    local city = T.fakeCity({ name = "Rome", owner = 3, id = 7 })
    Players[3] = T.fakePlayer({ shortDesc = "Arabia", adj = "Roman" })
    local cityPlot = T.fakePlot({ owner = 3, isCity = true, city = city })
    local territoryPlot = T.fakePlot({ owner = 3 })
    local _, idCity = PlotSections.ownerIdentity(cityPlot)
    local _, idTerritory = PlotSections.ownerIdentity(territoryPlot)
    T.eq(idCity, idTerritory, "city tile and territory tile of the same civ must share identity")
    T.eq(idCity, "civ:3")
end

-- ===== City section =====

function M.test_city_section_skips_non_city()
    setup()
    local p = T.fakePlot({ isCity = false })
    T.eq(#PlotSections.city.Read(p, {}), 0)
end

-- ===== Terrain shape (combined feature / hills / terrain) =====

function M.test_terrainShape_natural_wonder_overrides_hills_mountain_and_terrain()
    -- Natural wonders describe the tile fully; placement rewrites the core
    -- tile (most NWs set ChangeCoreTileToMountain) so hearing "mountain"
    -- after the wonder name is noise. Same goes for any terrain or hills
    -- token that would otherwise tag along.
    setup()
    GameInfo.Terrains[6] = { Description = "Snow" }
    GameInfo.Features[5] = { Description = "Mt. Fuji", Type = "FEATURE_FUJI", NaturalWonder = true }
    local p = T.fakePlot({ terrain = 6, feature = 5, hills = true, mountain = true })
    local out = PlotSections.terrainShape.Read(p, {})
    T.eq(#out, 1, "wonder must suppress every other token: got " .. table.concat(out, ", "))
    T.eq(out[1], "Mt. Fuji")
end

function M.test_terrainShape_mountain_without_wonder_speaks_alone()
    -- Mountain plot not under a natural wonder: the underlying terrain
    -- (often snow/tundra) isn't the distinguishing fact.
    setup()
    GameInfo.Terrains[6] = { Description = "Snow" }
    local p = T.fakePlot({ terrain = 6, mountain = true })
    local out = PlotSections.terrainShape.Read(p, {})
    T.eq(#out, 1, "mountain suppresses terrain: got " .. table.concat(out, ", "))
    T.eq(out[1], "mountain")
end

function M.test_terrainShape_single_terrain_feature_suppresses_terrain()
    -- FEATURE_JUNGLE is gated to one terrain in Feature_TerrainBooleans
    -- (grass in G&K/BNW, plains in base) so speaking the terrain is
    -- redundant no matter which UISkin is active.
    setup()
    GameInfo.Terrains[1] = { Description = "Plains" }
    GameInfo.Features[2] = { Description = "Jungle", Type = "FEATURE_JUNGLE" }
    local p = T.fakePlot({ terrain = 1, feature = 2 })
    local out = PlotSections.terrainShape.Read(p, {})
    T.eq(#out, 1, "single-terrain feature suppresses terrain: got " .. table.concat(out, ", "))
    T.eq(out[1], "Jungle")
end

function M.test_terrainShape_multi_terrain_feature_keeps_terrain()
    -- FEATURE_FOREST spans grass / plains / tundra; the terrain word is the
    -- distinguishing fact between "forest on tundra" (defensive, cold-
    -- gameplay) and "forest on plains" (lumber-mill-ready).
    setup()
    GameInfo.Terrains[3] = { Description = "Tundra" }
    GameInfo.Features[6] = { Description = "Forest", Type = "FEATURE_FOREST" }
    local p = T.fakePlot({ terrain = 3, feature = 6 })
    local out = PlotSections.terrainShape.Read(p, {})
    T.eq(table.concat(out, ", "), "Forest, Tundra")
end

function M.test_terrainShape_ice_suppresses_terrain_despite_being_multi_terrain()
    -- ICE is defined over coast + ocean, so by the data rule it'd read as
    -- multi-terrain. Policy override suppresses anyway because both read
    -- as impassable and the player can't act on the distinction.
    setup()
    GameInfo.Terrains[4] = { Description = "Ocean" }
    GameInfo.Features[1] = { Description = "Ice", Type = "FEATURE_ICE" }
    local p = T.fakePlot({ terrain = 4, feature = 1 })
    local out = PlotSections.terrainShape.Read(p, {})
    T.eq(#out, 1, "ice must suppress terrain by policy: got " .. table.concat(out, ", "))
    T.eq(out[1], "Ice")
end

function M.test_terrainShape_hills_keeps_terrain_and_adds_hills_token()
    -- Hills are an overlay, not a replacement: terrain still speaks, and
    -- hills announces because defense and move-cost effects are separate
    -- from the feature-vs-terrain redundancy we're collapsing.
    setup()
    GameInfo.Terrains[1] = { Description = "Plains" }
    local p = T.fakePlot({ terrain = 1, hills = true })
    local out = PlotSections.terrainShape.Read(p, {})
    T.eq(table.concat(out, ", "), "hills, Plains")
end

function M.test_terrainShape_single_terrain_feature_on_hills_keeps_hills()
    -- Jungle is the only single-terrain feature that can land on hills
    -- (marsh / oasis / flood plains are RequiresFlatlands). Suppressing
    -- terrain must not also drop hills -- defensive / movement effects
    -- are independent of the feature name.
    setup()
    GameInfo.Features[2] = { Description = "Jungle", Type = "FEATURE_JUNGLE" }
    local p = T.fakePlot({ feature = 2, hills = true })
    local out = PlotSections.terrainShape.Read(p, {})
    T.eq(table.concat(out, ", "), "Jungle, hills")
end

function M.test_terrainShape_lake_speaks_alone()
    -- Lake is its own first branch: terrain underneath (coast) is never
    -- useful info for a lake tile.
    setup()
    GameInfo.Terrains[5] = { Description = "Coast" }
    local p = T.fakePlot({ lake = true, terrain = 5 })
    local out = PlotSections.terrainShape.Read(p, {})
    T.eq(#out, 1)
    T.eq(out[1], "lake")
end

-- ===== Resource section =====

function M.test_resource_quantity_prefix_when_greater_than_one()
    setup()
    GameInfo.Resources[4] = { Description = "Iron" }
    local p = T.fakePlot({ resource = 4, resourceQty = 3 })
    T.eq(PlotSections.resource.Read(p, {})[1], "3 Iron")
end

function M.test_resource_no_quantity_prefix_when_one()
    setup()
    GameInfo.Resources[4] = { Description = "Iron" }
    local p = T.fakePlot({ resource = 4, resourceQty = 1 })
    T.eq(PlotSections.resource.Read(p, {})[1], "Iron")
end

-- ===== Improvement / route pillaged =====

function M.test_improvement_pillaged_suffix()
    setup()
    GameInfo.Improvements[2] = { Description = "Farm" }
    local p = T.fakePlot({ improvement = 2, improvementPillaged = true })
    T.eq(PlotSections.improvement.Read(p, {})[1], "Farm pillaged")
end

function M.test_route_pillaged_suffix()
    setup()
    GameInfo.Routes[1] = { Description = "Road" }
    local p = T.fakePlot({ route = 1, routePillaged = true })
    T.eq(PlotSections.route.Read(p, {})[1], "Road pillaged")
end

-- ===== Units section =====

function M.test_units_invisible_filter()
    setup()
    Players[0] = T.fakePlayer({ adj = "Roman" })
    local visible = T.fakeUnit({ owner = 0, nameKey = "Warrior" })
    local cloaked = T.fakeUnit({ owner = 0, nameKey = "Submarine", invisible = true })
    local p = T.fakePlot({ units = { visible, cloaked } })
    local out = PlotSectionUnits.Read(p, {})
    T.eq(#out, 1, "invisible unit must be filtered out")
end

function M.test_units_skips_cargo_and_air()
    setup()
    Players[0] = T.fakePlayer({ adj = "Roman" })
    local land = T.fakeUnit({ owner = 0, nameKey = "Warrior", domain = DomainTypes.DOMAIN_LAND })
    local cargo = T.fakeUnit({ owner = 0, nameKey = "Settler", cargo = true })
    local fighter = T.fakeUnit({ owner = 0, nameKey = "Fighter", domain = DomainTypes.DOMAIN_AIR })
    local p = T.fakePlot({ units = { land, cargo, fighter } })
    local out = PlotSectionUnits.Read(p, {})
    T.eq(#out, 1, "only the non-cargo non-air unit should announce")
end

function M.test_units_never_use_multiplayer_template()
    -- The engine returns a non-empty nickname even in singleplayer ("Player
    -- 1" / profile name), so the MULTIPLAYER_UNIT_TT path would prepend the
    -- local player's name to their own unit every step. Always use the civ
    -- adjective form instead.
    setup()
    Players[0] = T.fakePlayer({ adj = "Roman", shortDesc = "Rome" })
    local warrior = T.fakeUnit({ owner = 0, nameKey = "Warrior" })
    local p = T.fakePlot({ units = { warrior } })
    local s = PlotSectionUnits.Read(p, {})[1]
    T.truthy(not s:find("TXT_KEY_MULTIPLAYER", 1, true), "must not use the multiplayer template: " .. s)
    -- fakePlayer has no GetNickName, so any production regression that
    -- reintroduces the multiplayer branch will crash here rather than
    -- silently leaking a profile name.
end

function M.test_units_hp_suffix_when_damaged()
    setup()
    Players[0] = T.fakePlayer({ adj = "Roman" })
    local damaged = T.fakeUnit({ owner = 0, nameKey = "Warrior", damage = 40 })
    local p = T.fakePlot({ units = { damaged } })
    local s = PlotSectionUnits.Read(p, {})[1]
    T.truthy(s:find("60 hp", 1, true), "expected '60 hp' in: " .. tostring(s))
end

-- ===== River edges =====

function M.test_river_self_edge_only()
    setup()
    Map.PlotDirection = function()
        return nil
    end -- no neighbors
    local p = T.fakePlot({ neOfRiver = true })
    T.eq(PlotSectionRiver.Read(p, {})[1], "river ne")
end

function M.test_river_neighbor_sourced_edge()
    setup()
    -- E edge of self == W edge of east neighbor.
    local east = T.fakePlot({ wOfRiver = true })
    Map.PlotDirection = function(_, _, dir)
        if dir == DirectionTypes.DIRECTION_EAST then
            return east
        end
        return nil
    end
    local p = T.fakePlot({})
    T.eq(PlotSectionRiver.Read(p, {})[1], "river e")
end

function M.test_river_all_six_collapses()
    setup()
    -- Force every neighbor to provide its share: E, SE, SW.
    Map.PlotDirection = function(_, _, dir)
        if dir == DirectionTypes.DIRECTION_EAST then
            return T.fakePlot({ wOfRiver = true })
        end
        if dir == DirectionTypes.DIRECTION_SOUTHEAST then
            return T.fakePlot({ nwOfRiver = true })
        end
        if dir == DirectionTypes.DIRECTION_SOUTHWEST then
            return T.fakePlot({ neOfRiver = true })
        end
        return nil
    end
    local p = T.fakePlot({ wOfRiver = true, nwOfRiver = true, neOfRiver = true })
    T.eq(PlotSectionRiver.Read(p, {})[1], "river all sides")
end

function M.test_river_edges_in_clockwise_order_from_ne()
    setup()
    -- Edges: NE (self), E (neighbor), SW (neighbor), W (self), but not NW.
    Map.PlotDirection = function(_, _, dir)
        if dir == DirectionTypes.DIRECTION_EAST then
            return T.fakePlot({ wOfRiver = true })
        end
        if dir == DirectionTypes.DIRECTION_SOUTHWEST then
            return T.fakePlot({ neOfRiver = true })
        end
        return nil
    end
    local p = T.fakePlot({ neOfRiver = true, wOfRiver = true })
    -- Output order is fixed: ne, e, se, sw, w, nw -- skipping absent edges.
    T.eq(PlotSectionRiver.Read(p, {})[1], "river ne e sw w")
end

-- ===== Composer integration =====

function M.test_glance_fog_marker_and_no_units_when_fogged()
    setup()
    Players[0] = T.fakePlayer({ adj = "Roman" })
    GameInfo.Terrains[1] = { Description = "Plains" }
    local enemy = T.fakeUnit({ owner = 0, nameKey = "Warrior" })
    local p = T.fakePlot({ revealed = true, visible = false, terrain = 1, units = { enemy } })
    local out = PlotComposers.glance(p)
    T.truthy(not out:find("Warrior", 1, true), "fogged plot must not leak unit info: " .. out)
    T.truthy(out:find("Plains", 1, true), "fogged plot still reads stale terrain: " .. out)
    T.truthy(out:find("fog", 1, true), "fogged plot must be marked with 'fog' token: " .. out)
    -- Fog marker goes first so the user hears "data is stale" before the data.
    T.truthy(out:sub(1, 3) == "fog", "fog token must lead the glance: " .. out)
end

function M.test_glance_visible_omits_fog_marker()
    setup()
    GameInfo.Terrains[1] = { Description = "Plains" }
    local p = T.fakePlot({ revealed = true, visible = true, terrain = 1 })
    local out = PlotComposers.glance(p)
    T.truthy(not out:find("fog", 1, true), "visible plot must not carry a fog marker: " .. out)
end

function M.test_economy_yields_skip_zeros()
    setup()
    local yields = { [YieldTypes.YIELD_FOOD] = 2, [YieldTypes.YIELD_PRODUCTION] = 0, [YieldTypes.YIELD_GOLD] = 1 }
    local p = T.fakePlot({ yields = yields })
    local out = PlotComposers.economy(p)
    T.truthy(out:find("2 food", 1, true), "missing food yield in: " .. out)
    T.truthy(out:find("1 gold", 1, true), "missing gold yield in: " .. out)
    T.truthy(not out:find("production", 1, true), "zero production should be omitted: " .. out)
end

function M.test_economy_fresh_water_flag()
    setup()
    local p = T.fakePlot({ freshWater = true })
    T.truthy(PlotComposers.economy(p):find("fresh water", 1, true))
end

function M.test_economy_reports_trade_route_on_fogged_revealed_tile()
    -- Matches base PlotHelpManager: economy detail runs under IsRevealed,
    -- not IsVisible. Fogged-but-revealed plot still reports trade route.
    setup()
    local fogged = T.fakePlot({ revealed = true, visible = false, tradeRoute = true })
    T.truthy(
        PlotComposers.economy(fogged):find("trade route", 1, true),
        "trade route should be announced on fogged revealed tiles (matches base)"
    )
end

function M.test_economy_reports_working_city_on_fogged_revealed_tile()
    setup()
    local city = T.fakeCity({ name = "Rome" })
    local fogged = T.fakePlot({ revealed = true, visible = false, workingCity = city })
    T.truthy(
        PlotComposers.economy(fogged):find("Rome", 1, true),
        "working city should be announced on fogged revealed tiles (matches base)"
    )
end

function M.test_combat_defense_modifier_announced()
    setup()
    local p = T.fakePlot({ defenseMod = 50 })
    T.truthy(PlotComposers.combat(p):find("50 percent defense", 1, true))
end

function M.test_combat_defense_modifier_announced_on_fogged_revealed_tile()
    -- Matches base PlotHelpManager: combat details run under IsRevealed,
    -- not IsVisible. Fogged-but-revealed plot still reports the defense
    -- bonus using live state.
    setup()
    local fogged = T.fakePlot({ revealed = true, visible = false, defenseMod = 50 })
    T.truthy(
        PlotComposers.combat(fogged):find("50 percent defense", 1, true),
        "defense modifier should be announced on fogged revealed tiles (matches base)"
    )
end

function M.test_combat_zone_of_control_when_enemy_combat_unit_adjacent()
    setup()
    Players[1] = T.fakePlayer({ adj = "Mongolian", team = 1 })
    Teams[0] = T.fakeTeam({ atWar = { [1] = true } })
    local enemy = T.fakeUnit({ owner = 1, team = 1, combat = true })
    local east = T.fakePlot({ units = { enemy } })
    Map.PlotDirection = function(_, _, dir)
        if dir == DirectionTypes.DIRECTION_EAST then
            return east
        end
        return nil
    end
    local p = T.fakePlot({})
    T.truthy(PlotComposers.combat(p):find("zone of control", 1, true))
end

function M.test_combat_no_zoc_when_enemy_is_civilian()
    setup()
    Players[1] = T.fakePlayer({ team = 1 })
    Teams[0] = T.fakeTeam({ atWar = { [1] = true } })
    local civilian = T.fakeUnit({ owner = 1, team = 1, combat = false })
    Map.PlotDirection = function(_, _, dir)
        if dir == DirectionTypes.DIRECTION_EAST then
            return T.fakePlot({ units = { civilian } })
        end
        return nil
    end
    local p = T.fakePlot({})
    T.truthy(not PlotComposers.combat(p):find("zone of control", 1, true), "civilian unit must not project ZoC")
end

function M.test_combat_no_zoc_on_fogged_plot_even_with_adjacent_enemy()
    -- ZoC needs live sight of the neighbor: an enemy behind fog can't
    -- project ZoC the player knows about. Composer must suppress the
    -- announcement on revealed-but-not-visible plots even when the
    -- neighbor scan would otherwise trip.
    setup()
    Players[1] = T.fakePlayer({ adj = "Mongolian", team = 1 })
    Teams[0] = T.fakeTeam({ atWar = { [1] = true } })
    local enemy = T.fakeUnit({ owner = 1, team = 1, combat = true })
    local east = T.fakePlot({ units = { enemy } })
    Map.PlotDirection = function(_, _, dir)
        if dir == DirectionTypes.DIRECTION_EAST then
            return east
        end
        return nil
    end
    local fogged = T.fakePlot({ revealed = true, visible = false })
    T.truthy(
        not PlotComposers.combat(fogged):find("zone of control", 1, true),
        "ZoC must be suppressed on fogged plots even with an adjacent enemy"
    )
end

-- ===== Cursor =====

function M.test_cursor_init_uses_selected_unit_plot()
    setup()
    local p = T.fakePlot({ x = 5, y = 7 })
    Map.GetPlot = function(x, y)
        if x == 5 and y == 7 then
            return p
        end
    end
    local unit = T.fakeUnit({})
    unit._plot = p
    UI.GetHeadSelectedUnit = function()
        return unit
    end
    Cursor.init()
    -- Move a step that returns nil neighbor → "edge of map", proving we
    -- did initialize at p (otherwise move would fail with "before init").
    Map.PlotDirection = function()
        return nil
    end
    T.eq(Cursor.move(DirectionTypes.DIRECTION_EAST), "edge of map")
end

function M.test_cursor_init_falls_back_to_capital_when_no_unit_selected()
    setup()
    local capPlot = T.fakePlot({ x = 10, y = 10 })
    local capCity = T.fakeCity({ plot = capPlot })
    Players[0] = T.fakePlayer({ capital = capCity })
    Map.GetPlot = function(x, y)
        if x == 10 and y == 10 then
            return capPlot
        end
    end
    UI.GetHeadSelectedUnit = function()
        return nil
    end
    Cursor.init()
    Map.PlotDirection = function()
        return nil
    end
    T.eq(Cursor.move(DirectionTypes.DIRECTION_EAST), "edge of map")
end

function M.test_cursor_move_owner_prefix_fires_once_within_same_civ()
    setup()
    Players[3] = T.fakePlayer({ shortDesc = "Arabia", adj = "Arabian" })
    GameInfo.Terrains[1] = { Description = "Plains" }
    local start = T.fakePlot({ x = 0, y = 0, owner = -1, terrain = 1 })
    local arab1 = T.fakePlot({ x = 1, y = 0, owner = 3, terrain = 1 })
    local arab2 = T.fakePlot({ x = 2, y = 0, owner = 3, terrain = 1 })
    local plotByXY = { ["0,0"] = start, ["1,0"] = arab1, ["2,0"] = arab2 }
    Map.GetPlot = function(x, y)
        return plotByXY[x .. "," .. y]
    end
    Map.PlotDirection = function(x, y, dir)
        if dir == DirectionTypes.DIRECTION_EAST then
            return plotByXY[(x + 1) .. "," .. y]
        end
        return nil
    end
    UI.GetHeadSelectedUnit = function()
        local u = T.fakeUnit({})
        u._plot = start
        return u
    end
    Cursor.init() -- on start (unclaimed)
    local first = Cursor.move(DirectionTypes.DIRECTION_EAST) -- onto Arabia
    local second = Cursor.move(DirectionTypes.DIRECTION_EAST) -- still Arabia
    T.truthy(first:find("Arabia", 1, true), "first entry must speak owner: " .. first)
    T.truthy(not second:find("Arabia", 1, true), "second move within Arabia must suppress prefix: " .. second)
    T.truthy(second:find("Plains", 1, true), "second move still describes the tile: " .. second)
end

function M.test_cursor_move_into_city_of_same_civ_does_not_refire_owner_prefix()
    -- Walking civ-tile -> city-tile-of-same-civ must not re-speak any
    -- border-crossing prefix; we never left the civ. The City section in
    -- the glance still names the city, but exactly once -- the regression
    -- this guards against is the owner-prefix and the City section both
    -- emitting the city banner on entry, leaving the user hearing it
    -- twice in a row.
    setup()
    Players[3] = T.fakePlayer({ shortDesc = "Arabia", adj = "Arabian" })
    GameInfo.Terrains[1] = { Description = "Plains" }
    local start = T.fakePlot({ x = 0, y = 0, owner = -1, terrain = 1 })
    local territory = T.fakePlot({ x = 1, y = 0, owner = 3, terrain = 1 })
    local rome = T.fakeCity({ name = "Rome", owner = 3, id = 7 })
    local cityPlot = T.fakePlot({ x = 2, y = 0, owner = 3, terrain = 1, isCity = true, city = rome })
    local plotByXY = { ["0,0"] = start, ["1,0"] = territory, ["2,0"] = cityPlot }
    Map.GetPlot = function(x, y)
        return plotByXY[x .. "," .. y]
    end
    Map.PlotDirection = function(x, y, dir)
        if dir == DirectionTypes.DIRECTION_EAST then
            return plotByXY[(x + 1) .. "," .. y]
        end
        return nil
    end
    local u = T.fakeUnit({})
    u._plot = start
    UI.GetHeadSelectedUnit = function()
        return u
    end
    Cursor.init()
    local first = Cursor.move(DirectionTypes.DIRECTION_EAST) -- onto territory: prefix "Arabia"
    T.truthy(first:find("Arabia", 1, true), "first crossing into Arabia must speak the prefix: " .. first)
    local second = Cursor.move(DirectionTypes.DIRECTION_EAST) -- onto Rome (same civ)
    -- The city banner expands to TXT_KEY_CITY_OF in the test stub (the
    -- engine string is not loaded), so its presence is unambiguous and
    -- countable. Old behavior emitted it twice (prefix + glance section);
    -- new behavior emits it once, from the glance section only.
    local _, count = second:gsub("TXT_KEY_CITY_OF", "")
    T.eq(count, 1, "city banner must announce exactly once on entry: " .. second)
end

function M.test_cursor_move_emits_edge_of_map_at_boundary()
    setup()
    local start = T.fakePlot({ x = 0, y = 0 })
    Map.GetPlot = function(x, y)
        if x == 0 and y == 0 then
            return start
        end
    end
    Map.PlotDirection = function()
        return nil
    end
    local unit = T.fakeUnit({})
    unit._plot = start
    UI.GetHeadSelectedUnit = function()
        return unit
    end
    Cursor.init()
    T.eq(Cursor.move(DirectionTypes.DIRECTION_WEST), "edge of map")
end

function M.test_cursor_orient_at_capital()
    setup()
    local cap = T.fakePlot({ x = 4, y = 4 })
    Players[0] = T.fakePlayer({ capital = T.fakeCity({ plot = cap }) })
    Map.GetPlot = function(x, y)
        if x == 4 and y == 4 then
            return cap
        end
    end
    local unit = T.fakeUnit({})
    unit._plot = cap
    UI.GetHeadSelectedUnit = function()
        return unit
    end
    Cursor.init()
    T.eq(Cursor.orient(), "capital")
end

function M.test_cursor_orient_pure_east_axis()
    setup()
    local cap = T.fakePlot({ x = 0, y = 0 })
    local east3 = T.fakePlot({ x = 3, y = 0 })
    Players[0] = T.fakePlayer({ capital = T.fakeCity({ plot = cap }) })
    Map.GetPlot = function(x, y)
        if x == 0 and y == 0 then
            return cap
        end
        if x == 3 and y == 0 then
            return east3
        end
    end
    local unit = T.fakeUnit({})
    unit._plot = east3
    UI.GetHeadSelectedUnit = function()
        return unit
    end
    Cursor.init()
    -- Cursor is 3 east of capital, so to reach the capital the user
    -- travels 3 west.
    T.eq(Cursor.orient(), "3w")
end

function M.test_cursor_orient_two_axis_decomposition_preserves_clockwise_from_e_order()
    setup()
    -- Place cursor at (col, row) such that the delta from cursor to
    -- capital requires two non-adjacent direction components. Cursor is
    -- 4 east + 5 NE of the capital, so capital is 4 west + 5 SW of the
    -- cursor. OUTPUT_ORDER sorts clockwise from E, so SW comes before W
    -- in the spoken form.
    local cap = T.fakePlot({ x = 0, y = 0 })
    local cur = T.fakePlot({ x = 6, y = 5 })
    Players[0] = T.fakePlayer({ capital = T.fakeCity({ plot = cap }) })
    Map.GetPlot = function(x, y)
        if x == 0 and y == 0 then
            return cap
        end
        if x == 6 and y == 5 then
            return cur
        end
    end
    local unit = T.fakeUnit({})
    unit._plot = cur
    UI.GetHeadSelectedUnit = function()
        return unit
    end
    Cursor.init()
    T.eq(Cursor.orient(), "5sw, 4w")
end

function M.test_cursor_move_onto_unexplored_speaks_unexplored_every_step()
    setup()
    GameInfo.Terrains[1] = { Description = "Plains" }
    local start = T.fakePlot({ x = 0, y = 0, terrain = 1 })
    local u1 = T.fakePlot({ x = 1, y = 0, revealed = false })
    local u2 = T.fakePlot({ x = 2, y = 0, revealed = false })
    local plotByXY = { ["0,0"] = start, ["1,0"] = u1, ["2,0"] = u2 }
    Map.GetPlot = function(x, y)
        return plotByXY[x .. "," .. y]
    end
    Map.PlotDirection = function(x, y, dir)
        if dir == DirectionTypes.DIRECTION_EAST then
            return plotByXY[(x + 1) .. "," .. y]
        end
        return nil
    end
    local u = T.fakeUnit({})
    u._plot = start
    UI.GetHeadSelectedUnit = function()
        return u
    end
    Cursor.init()
    -- Both consecutive unexplored moves must speak: silence across a fog-of-
    -- war block leaves the user with no signal that the cursor moved at all.
    local first = Cursor.move(DirectionTypes.DIRECTION_EAST)
    local second = Cursor.move(DirectionTypes.DIRECTION_EAST)
    T.truthy(first:lower():find("unexplored", 1, true), "first unexplored step must speak unexplored: " .. first)
    T.truthy(
        second:lower():find("unexplored", 1, true),
        "second unexplored step must also speak unexplored: " .. second
    )
end

function M.test_cursor_move_onto_fogged_tile_injects_fog_marker()
    setup()
    GameInfo.Terrains[1] = { Description = "Plains" }
    local start = T.fakePlot({ x = 0, y = 0, terrain = 1 })
    local fogged = T.fakePlot({ x = 1, y = 0, revealed = true, visible = false, terrain = 1 })
    local plotByXY = { ["0,0"] = start, ["1,0"] = fogged }
    Map.GetPlot = function(x, y)
        return plotByXY[x .. "," .. y]
    end
    Map.PlotDirection = function(x, y, dir)
        if dir == DirectionTypes.DIRECTION_EAST then
            return plotByXY[(x + 1) .. "," .. y]
        end
        return nil
    end
    local u = T.fakeUnit({})
    u._plot = start
    UI.GetHeadSelectedUnit = function()
        return u
    end
    Cursor.init()
    local out = Cursor.move(DirectionTypes.DIRECTION_EAST)
    T.truthy(out:find("fog", 1, true), "fogged move must include 'fog' token: " .. out)
    T.truthy(out:find("Plains", 1, true), "fogged move still reads stale terrain: " .. out)
end

function M.test_cursor_owner_diff_does_not_fire_across_unexplored_gap()
    -- Move pattern: unclaimed-a (fires owner prefix) → unexplored (speaks
    -- "unexplored" but does not touch the owner-identity diff) → unclaimed-c.
    -- The third tile must NOT re-fire the owner prefix because identity is
    -- still "unclaimed" from the first move; unexplored is a visibility
    -- state, not an ownership state.
    setup()
    GameInfo.Terrains[1] = { Description = "Plains" }
    local start = T.fakePlot({ x = 0, y = 0, terrain = 1, owner = -1 })
    local a = T.fakePlot({ x = 1, y = 0, terrain = 1, owner = -1 })
    local b = T.fakePlot({ x = 2, y = 0, revealed = false })
    local c = T.fakePlot({ x = 3, y = 0, terrain = 1, owner = -1 })
    local plotByXY = { ["0,0"] = start, ["1,0"] = a, ["2,0"] = b, ["3,0"] = c }
    Map.GetPlot = function(x, y)
        return plotByXY[x .. "," .. y]
    end
    Map.PlotDirection = function(x, y, dir)
        if dir == DirectionTypes.DIRECTION_EAST then
            return plotByXY[(x + 1) .. "," .. y]
        end
        return nil
    end
    local u = T.fakeUnit({})
    u._plot = start
    UI.GetHeadSelectedUnit = function()
        return u
    end
    Cursor.init()
    local first = Cursor.move(DirectionTypes.DIRECTION_EAST) -- onto a: "unclaimed. Plains."
    T.truthy(first:find("unclaimed", 1, true), "first move must announce owner: " .. first)
    local second = Cursor.move(DirectionTypes.DIRECTION_EAST) -- onto b (unexplored)
    T.truthy(second:lower():find("unexplored", 1, true), "unexplored step must speak unexplored: " .. second)
    local third = Cursor.move(DirectionTypes.DIRECTION_EAST) -- onto c
    T.truthy(not third:find("unclaimed", 1, true), "crossing unexplored must not retrigger the owner prefix: " .. third)
end

-- ===== Combat tile movement cost =====

function M.test_combat_tile_cost_flat_terrain_is_one_move()
    setup()
    GameInfo.Terrains[1] = { Description = "Plains", Movement = 1 }
    local p = T.fakePlot({ terrain = 1 })
    T.truthy(PlotComposers.combat(p):find("1 moves", 1, true), "flat terrain should read '1 moves'")
end

function M.test_combat_tile_cost_hills_adds_one()
    setup()
    GameInfo.Terrains[1] = { Description = "Plains", Movement = 1 }
    local p = T.fakePlot({ terrain = 1, hills = true })
    T.truthy(PlotComposers.combat(p):find("2 moves", 1, true), "hills should add 1 to terrain cost")
end

function M.test_combat_tile_cost_feature_overrides_terrain()
    setup()
    GameInfo.Terrains[1] = { Description = "Plains", Movement = 1 }
    GameInfo.Features[3] = { Description = "Marsh", Type = "FEATURE_MARSH", Movement = 3 }
    local p = T.fakePlot({ terrain = 1, feature = 3 })
    T.truthy(
        PlotComposers.combat(p):find("3 moves", 1, true),
        "feature with nonzero Movement must override terrain cost"
    )
end

function M.test_combat_tile_cost_zero_feature_movement_does_not_override()
    setup()
    GameInfo.Terrains[1] = { Description = "Plains", Movement = 1 }
    -- Lake / River pseudo-features have Movement = 0 (or absent), meaning the
    -- terrain cost stands.
    GameInfo.Features[9] = { Description = "Lake", Type = "FEATURE_LAKE", Movement = 0 }
    local p = T.fakePlot({ terrain = 1, feature = 9 })
    T.truthy(
        PlotComposers.combat(p):find("1 moves", 1, true),
        "feature with Movement=0 should leave terrain cost unchanged"
    )
end

function M.test_combat_tile_cost_mountain_is_impassable()
    setup()
    local p = T.fakePlot({ mountain = true })
    local out = PlotComposers.combat(p)
    T.truthy(out:lower():find("impassable", 1, true), "mountain should read impassable: " .. out)
    T.truthy(not out:find("moves", 1, true), "mountain must not also report a move count: " .. out)
end

-- ===== Unit-at-tile (S key) =====
-- Covers Cursor.unitAtTile's priority logic. Stubs UnitSpeech so the
-- test decouples from its formatter and just observes which unit the
-- cursor hands over. Sets Cursor up via init() with a fake selected
-- unit so `_x` / `_y` are populated for plotHere.
local function setupUnitAtTile(unitsOnTile)
    setup()
    UnitSpeech = {
        info = function(u)
            return "info:" .. tostring(u and u._tag or "nil")
        end,
    }
    local plot = T.fakePlot({ x = 5, y = 5, units = unitsOnTile })
    Map.GetPlot = function(x, y)
        if x == 5 and y == 5 then
            return plot
        end
    end
    local seed = T.fakeUnit({})
    seed._plot = plot
    UI.GetHeadSelectedUnit = function()
        return seed
    end
    Cursor.init()
    return plot
end

function M.test_cursor_unit_at_tile_prefers_military_over_civilian()
    local civ = T.fakeUnit({ combat = false })
    civ._tag = "civ"
    local mil = T.fakeUnit({ combat = true })
    mil._tag = "mil"
    setupUnitAtTile({ civ, mil })
    T.eq(Cursor.unitAtTile(), "info:mil")
end

function M.test_cursor_unit_at_tile_falls_back_to_civilian_when_no_military()
    local civ = T.fakeUnit({ combat = false })
    civ._tag = "civ"
    setupUnitAtTile({ civ })
    T.eq(Cursor.unitAtTile(), "info:civ")
end

function M.test_cursor_unit_at_tile_speaks_no_units_when_empty()
    setupUnitAtTile({})
    T.eq(Cursor.unitAtTile(), "no units")
end

function M.test_cursor_unit_at_tile_skips_invisible_cargo_and_air()
    local invisible = T.fakeUnit({ combat = true, invisible = true })
    invisible._tag = "invisible"
    local cargo = T.fakeUnit({ combat = true, cargo = true })
    cargo._tag = "cargo"
    local air = T.fakeUnit({ combat = true, domain = DomainTypes.DOMAIN_AIR })
    air._tag = "air"
    local visible = T.fakeUnit({ combat = false })
    visible._tag = "visible_civ"
    setupUnitAtTile({ invisible, cargo, air, visible })
    T.eq(Cursor.unitAtTile(), "info:visible_civ", "filter should skip invisible/cargo/air")
end

-- ===== City info keys (1 / 2 / 3) =====
-- Verify the "no city here" fallback and the delegation to CitySpeech;
-- the CitySpeech module's own logic is covered in suite_city_speech.
local function setupCityGlue(plot)
    setup()
    CitySpeech = {
        identity = function()
            return "CITY_IDENTITY"
        end,
        development = function()
            return "CITY_DEV"
        end,
        politics = function()
            return "CITY_POL"
        end,
    }
    Map.GetPlot = function(x, y)
        if x == plot:GetX() and y == plot:GetY() then
            return plot
        end
    end
    local seed = T.fakeUnit({})
    seed._plot = plot
    UI.GetHeadSelectedUnit = function()
        return seed
    end
    Cursor.init()
end

function M.test_cursor_city_identity_speaks_no_city_on_non_city_tile()
    setupCityGlue(T.fakePlot({ x = 0, y = 0, isCity = false }))
    T.eq(Cursor.cityIdentity(), "no city here")
    T.eq(Cursor.cityDevelopment(), "no city here")
    T.eq(Cursor.cityPolitics(), "no city here")
end

function M.test_cursor_city_info_keys_delegate_to_city_speech()
    local city = T.fakeCity({ name = "Rome", owner = 0, id = 7 })
    setupCityGlue(T.fakePlot({ x = 0, y = 0, isCity = true, city = city }))
    T.eq(Cursor.cityIdentity(), "CITY_IDENTITY")
    T.eq(Cursor.cityDevelopment(), "CITY_DEV")
    T.eq(Cursor.cityPolitics(), "CITY_POL")
end

return M
