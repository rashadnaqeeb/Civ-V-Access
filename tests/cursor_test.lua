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

    Game.GetActivePlayer = function() return 0 end
    Game.GetActiveTeam   = function() return 0 end
    Game.IsDebugMode     = function() return false end

    -- Wipe per-test scenario tables so fixtures from a prior test don't leak.
    Players  = {}
    Teams    = { [0] = T.fakeTeam() }
    GameInfo = {}
    GameInfo.Terrains     = {}
    GameInfo.Features     = {}
    GameInfo.Resources    = {}
    GameInfo.Improvements = {}
    GameInfo.Routes       = {}
    GameInfo.Builds       = function() return function() return nil end end
    GameInfo.Technologies = {}

    -- Default Map: tests that need neighbor lookups (river, ZoC) override
    -- PlotDirection per-test.
    Map.PlotDirection = function() return nil end
    Map.GetPlot       = function() return nil end
    Map.IsWrapX       = function() return false end

    UI.LookAt            = function(_plot, _flag) end
    UI.GetHeadSelectedUnit = function() return nil end

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

function M.test_owner_identity_city_distinguishes_from_territory()
    setup()
    local city = T.fakeCity({ name = "Rome", owner = 3, id = 7 })
    Players[3] = T.fakePlayer({ adj = "Roman" })
    local p = T.fakePlot({ owner = 3, isCity = true, city = city })
    local spoken, id = PlotSections.ownerIdentity(p)
    -- TXT_KEY_CITY_OF substitutes adjective then name; format string from the
    -- engine is "{1_Adj} {2_Name}" or similar -- our Locale stub returns the
    -- raw key untouched when the engine string isn't loaded, so we can't
    -- assert exact wording here. We CAN assert the diff token differs from
    -- the bare-territory form, which is the whole point.
    local _, idCiv = PlotSections.ownerIdentity(T.fakePlot({ owner = 3 }))
    T.truthy(id ~= idCiv, "city identity must differ from territory identity")
    T.eq(id, "city:7")
    T.truthy(spoken ~= "" and spoken ~= nil)
end

-- ===== City section =====

function M.test_city_section_skips_non_city()
    setup()
    local p = T.fakePlot({ isCity = false })
    T.eq(#PlotSections.city.Read(p, {}), 0)
end

-- ===== Terrain / feature / plotType suppression =====

function M.test_terrain_suppressed_by_natural_wonder_feature()
    setup()
    GameInfo.Terrains[1] = { Description = "Plains" }
    GameInfo.Features[5] = { Description = "Mt. Fuji", Type = "FEATURE_FUJI", NaturalWonder = true }
    local p = T.fakePlot({ terrain = 1, feature = 5 })
    local ctx = {}
    local feat = PlotSections.feature.Read(p, ctx)
    T.eq(feat[1], "Mt. Fuji")
    T.truthy(ctx.suppressTerrain, "natural wonder must set suppressTerrain")
    T.eq(#PlotSections.terrain.Read(p, ctx), 0)
end

function M.test_terrain_suppressed_by_special_feature_jungle()
    setup()
    GameInfo.Terrains[1] = { Description = "Plains" }
    GameInfo.Features[2] = { Description = "Jungle", Type = "FEATURE_JUNGLE" }
    local p = T.fakePlot({ terrain = 1, feature = 2 })
    local ctx = {}
    local feat = PlotSections.feature.Read(p, ctx)
    T.eq(feat[1], "Jungle")
    T.truthy(ctx.suppressTerrain, "FEATURE_JUNGLE is special; terrain must be suppressed")
end

function M.test_plotType_mountain_suppresses_terrain_and_announces_self()
    setup()
    GameInfo.Terrains[6] = { Description = "Snow" }
    local p = T.fakePlot({ terrain = 6, mountain = true })
    local ctx = {}
    local pt = PlotSections.plotType.Read(p, ctx)
    T.eq(pt[1], "mountain")
    T.truthy(ctx.suppressTerrain)
end

function M.test_plotType_flat_emits_nothing()
    setup()
    local p = T.fakePlot({})  -- not hills, not mountain
    T.eq(#PlotSections.plotType.Read(p, {}), 0)
end

function M.test_plotType_hills_does_not_suppress_terrain()
    setup()
    GameInfo.Terrains[1] = { Description = "Plains" }
    local p = T.fakePlot({ terrain = 1, hills = true })
    local ctx = {}
    PlotSections.plotType.Read(p, ctx)
    -- Terrain still readable: hills are an overlay, not a replacement.
    T.eq(PlotSections.terrain.Read(p, ctx)[1], "Plains")
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
    local land    = T.fakeUnit({ owner = 0, nameKey = "Warrior", domain = DomainTypes.DOMAIN_LAND })
    local cargo   = T.fakeUnit({ owner = 0, nameKey = "Settler", cargo = true })
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
    Players[0] = T.fakePlayer({ adj = "Roman", shortDesc = "Rome", nick = "Player 1" })
    local warrior = T.fakeUnit({ owner = 0, nameKey = "Warrior" })
    local p = T.fakePlot({ units = { warrior } })
    local s = PlotSectionUnits.Read(p, {})[1]
    T.truthy(not s:find("TXT_KEY_MULTIPLAYER", 1, true),
        "must not use the multiplayer template: " .. s)
    T.truthy(not s:find("Player 1", 1, true),
        "must not leak the local nickname into the announcement: " .. s)
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
    Map.PlotDirection = function() return nil end  -- no neighbors
    local p = T.fakePlot({ neOfRiver = true })
    T.eq(PlotSectionRiver.Read(p, {})[1], "river ne")
end

function M.test_river_neighbor_sourced_edge()
    setup()
    -- E edge of self == W edge of east neighbor.
    local east = T.fakePlot({ wOfRiver = true })
    Map.PlotDirection = function(_, _, dir)
        if dir == DirectionTypes.DIRECTION_EAST then return east end
        return nil
    end
    local p = T.fakePlot({})
    T.eq(PlotSectionRiver.Read(p, {})[1], "river e")
end

function M.test_river_all_six_collapses()
    setup()
    -- Force every neighbor to provide its share: E, SE, SW.
    local function rivered(method)
        local n = T.fakePlot({})
        n[method] = true
        n["Is" .. method] = function(self) return true end
        return n
    end
    -- Every direction returns a neighbor whose "river-our-edge" flag is true.
    Map.PlotDirection = function(_, _, dir)
        if dir == DirectionTypes.DIRECTION_EAST      then return T.fakePlot({ wOfRiver  = true }) end
        if dir == DirectionTypes.DIRECTION_SOUTHEAST then return T.fakePlot({ nwOfRiver = true }) end
        if dir == DirectionTypes.DIRECTION_SOUTHWEST then return T.fakePlot({ neOfRiver = true }) end
        return nil
    end
    local p = T.fakePlot({ wOfRiver = true, nwOfRiver = true, neOfRiver = true })
    T.eq(PlotSectionRiver.Read(p, {})[1], "river all sides")
end

function M.test_river_edges_in_clockwise_order_from_ne()
    setup()
    -- Edges: NE (self), E (neighbor), SW (neighbor), W (self), but not NW.
    Map.PlotDirection = function(_, _, dir)
        if dir == DirectionTypes.DIRECTION_EAST      then return T.fakePlot({ wOfRiver  = true }) end
        if dir == DirectionTypes.DIRECTION_SOUTHWEST then return T.fakePlot({ neOfRiver = true }) end
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
    local p = T.fakePlot({ revealed = true, visible = false, terrain = 1,
                           units = { enemy } })
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

function M.test_economy_yields_skip_zeros_and_visible_only()
    setup()
    local yields = { [YieldTypes.YIELD_FOOD] = 2, [YieldTypes.YIELD_PRODUCTION] = 0,
                     [YieldTypes.YIELD_GOLD] = 1 }
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

function M.test_economy_trade_route_only_when_visible()
    setup()
    local fogged = T.fakePlot({ visible = false, tradeRoute = true })
    T.truthy(not PlotComposers.economy(fogged):find("trade route", 1, true),
        "trade route must not leak through fog")
end

function M.test_economy_working_city_only_when_visible()
    -- GetWorkingCity returns live state; on a fogged tile it would leak
    -- current worker assignment. Must be gated on visible.
    setup()
    local city = T.fakeCity({ name = "Rome" })
    local fogged = T.fakePlot({ visible = false, workingCity = city })
    T.truthy(not PlotComposers.economy(fogged):find("Rome", 1, true),
        "working city must not leak through fog")
end

function M.test_combat_defense_modifier_announced()
    setup()
    local p = T.fakePlot({ defenseMod = 50 })
    T.truthy(PlotComposers.combat(p):find("50 percent defense", 1, true))
end

function M.test_combat_defense_modifier_gated_on_visible()
    -- DefenseModifier's improvement component is live; gate on visible so
    -- fogged tiles don't leak current fort/citadel state.
    setup()
    local fogged = T.fakePlot({ visible = false, defenseMod = 50 })
    T.truthy(not PlotComposers.combat(fogged):find("percent defense", 1, true),
        "defense modifier must not leak through fog")
end

function M.test_combat_zone_of_control_when_enemy_combat_unit_adjacent()
    setup()
    Players[1] = T.fakePlayer({ adj = "Mongolian", team = 1 })
    Teams[0] = T.fakeTeam({ atWar = { [1] = true } })
    local enemy = T.fakeUnit({ owner = 1, team = 1, combat = true })
    local east  = T.fakePlot({ units = { enemy } })
    Map.PlotDirection = function(_, _, dir)
        if dir == DirectionTypes.DIRECTION_EAST then return east end
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
    T.truthy(not PlotComposers.combat(p):find("zone of control", 1, true),
        "civilian unit must not project ZoC")
end

-- ===== Cursor =====

local function placeCursorAt(plot)
    Map.GetPlot = function(x, y) if x == plot:GetX() and y == plot:GetY() then return plot end end
    UI.GetHeadSelectedUnit = function()
        return T.fakeUnit({ _plot = plot })
    end
    -- The fake unit needs GetPlot returning the plot; T.fakeUnit's GetPlot
    -- reads self._plot, set by setting the field directly.
end

function M.test_cursor_init_uses_selected_unit_plot()
    setup()
    local p = T.fakePlot({ x = 5, y = 7 })
    Map.GetPlot = function(x, y) if x == 5 and y == 7 then return p end end
    local unit = T.fakeUnit({})
    unit._plot = p
    UI.GetHeadSelectedUnit = function() return unit end
    Cursor.init()
    -- Move a step that returns nil neighbor → "edge of map", proving we
    -- did initialize at p (otherwise move would fail with "before init").
    Map.PlotDirection = function() return nil end
    T.eq(Cursor.move(DirectionTypes.DIRECTION_EAST), "edge of map")
end

function M.test_cursor_init_falls_back_to_capital_when_no_unit_selected()
    setup()
    local capPlot = T.fakePlot({ x = 10, y = 10 })
    local capCity = T.fakeCity({ plot = capPlot })
    Players[0] = T.fakePlayer({ capital = capCity })
    Map.GetPlot = function(x, y) if x == 10 and y == 10 then return capPlot end end
    UI.GetHeadSelectedUnit = function() return nil end
    Cursor.init()
    Map.PlotDirection = function() return nil end
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
    Map.GetPlot = function(x, y) return plotByXY[x .. "," .. y] end
    Map.PlotDirection = function(x, y, dir)
        if dir == DirectionTypes.DIRECTION_EAST then return plotByXY[(x + 1) .. "," .. y] end
        return nil
    end
    UI.GetHeadSelectedUnit = function()
        local u = T.fakeUnit({}); u._plot = start; return u
    end
    Cursor.init()  -- on start (unclaimed)
    local first  = Cursor.move(DirectionTypes.DIRECTION_EAST)  -- onto Arabia
    local second = Cursor.move(DirectionTypes.DIRECTION_EAST)  -- still Arabia
    T.truthy(first:find("Arabia", 1, true), "first entry must speak owner: " .. first)
    T.truthy(not second:find("Arabia", 1, true), "second move within Arabia must suppress prefix: " .. second)
    T.truthy(second:find("Plains", 1, true), "second move still describes the tile: " .. second)
end

function M.test_cursor_move_emits_edge_of_map_at_boundary()
    setup()
    local start = T.fakePlot({ x = 0, y = 0 })
    Map.GetPlot = function(x, y) if x == 0 and y == 0 then return start end end
    Map.PlotDirection = function() return nil end
    local unit = T.fakeUnit({}); unit._plot = start
    UI.GetHeadSelectedUnit = function() return unit end
    Cursor.init()
    T.eq(Cursor.move(DirectionTypes.DIRECTION_WEST), "edge of map")
end

function M.test_cursor_orient_at_capital()
    setup()
    local cap = T.fakePlot({ x = 4, y = 4 })
    Players[0] = T.fakePlayer({ capital = T.fakeCity({ plot = cap }) })
    Map.GetPlot = function(x, y) if x == 4 and y == 4 then return cap end end
    local unit = T.fakeUnit({}); unit._plot = cap
    UI.GetHeadSelectedUnit = function() return unit end
    Cursor.init()
    T.eq(Cursor.orient(), "capital")
end

function M.test_cursor_orient_pure_east_axis()
    setup()
    local cap   = T.fakePlot({ x = 0, y = 0 })
    local east3 = T.fakePlot({ x = 3, y = 0 })
    Players[0] = T.fakePlayer({ capital = T.fakeCity({ plot = cap }) })
    Map.GetPlot = function(x, y)
        if x == 0 and y == 0 then return cap end
        if x == 3 and y == 0 then return east3 end
    end
    local unit = T.fakeUnit({}); unit._plot = east3
    UI.GetHeadSelectedUnit = function() return unit end
    Cursor.init()
    T.eq(Cursor.orient(), "3e")
end

function M.test_cursor_orient_two_axis_decomposition_preserves_clockwise_from_e_order()
    setup()
    -- Place cursor at (col, row) such that delta from origin requires both
    -- E and NE components. From the design: 4 east + 5 northeast reads
    -- "4e, 5ne". In Civ V's odd-row offset, NE on a row leaves col
    -- unchanged (even-row source) or +1 (odd-row source); both translate
    -- to axial Δq = 0, Δr = +1. So 4 east + 5 NE → axial Δq = +4, Δr = +5.
    -- Convert axial back to offset: row = 5; col = q + (r - r%2)/2 = 4 + 2 = 6.
    local cap = T.fakePlot({ x = 0, y = 0 })
    local cur = T.fakePlot({ x = 6, y = 5 })
    Players[0] = T.fakePlayer({ capital = T.fakeCity({ plot = cap }) })
    Map.GetPlot = function(x, y)
        if x == 0 and y == 0 then return cap end
        if x == 6 and y == 5 then return cur end
    end
    local unit = T.fakeUnit({}); unit._plot = cur
    UI.GetHeadSelectedUnit = function() return unit end
    Cursor.init()
    T.eq(Cursor.orient(), "4e, 5ne")
end

function M.test_cursor_recenter_no_unit_selected_speaks_message_and_does_not_move()
    setup()
    local start = T.fakePlot({ x = 0, y = 0 })
    Map.GetPlot = function(x, y) if x == 0 and y == 0 then return start end end
    -- Init via capital so init succeeds without a selected unit.
    Players[0] = T.fakePlayer({ capital = T.fakeCity({ plot = start }) })
    Cursor.init()
    UI.GetHeadSelectedUnit = function() return nil end
    T.eq(Cursor.recenter(), "no unit selected")
end

function M.test_cursor_move_onto_unexplored_speaks_unexplored_every_step()
    setup()
    GameInfo.Terrains[1] = { Description = "Plains" }
    local start  = T.fakePlot({ x = 0, y = 0, terrain = 1 })
    local u1     = T.fakePlot({ x = 1, y = 0, revealed = false })
    local u2     = T.fakePlot({ x = 2, y = 0, revealed = false })
    local plotByXY = { ["0,0"] = start, ["1,0"] = u1, ["2,0"] = u2 }
    Map.GetPlot = function(x, y) return plotByXY[x .. "," .. y] end
    Map.PlotDirection = function(x, y, dir)
        if dir == DirectionTypes.DIRECTION_EAST then return plotByXY[(x + 1) .. "," .. y] end
        return nil
    end
    local u = T.fakeUnit({}); u._plot = start
    UI.GetHeadSelectedUnit = function() return u end
    Cursor.init()
    -- Both consecutive unexplored moves must speak: silence across a fog-of-
    -- war block leaves the user with no signal that the cursor moved at all.
    local first  = Cursor.move(DirectionTypes.DIRECTION_EAST)
    local second = Cursor.move(DirectionTypes.DIRECTION_EAST)
    T.truthy(first:lower():find("unexplored", 1, true),
        "first unexplored step must speak unexplored: " .. first)
    T.truthy(second:lower():find("unexplored", 1, true),
        "second unexplored step must also speak unexplored: " .. second)
end

function M.test_cursor_move_onto_fogged_tile_injects_fog_marker()
    setup()
    GameInfo.Terrains[1] = { Description = "Plains" }
    local start  = T.fakePlot({ x = 0, y = 0, terrain = 1 })
    local fogged = T.fakePlot({ x = 1, y = 0, revealed = true, visible = false,
                                terrain = 1 })
    local plotByXY = { ["0,0"] = start, ["1,0"] = fogged }
    Map.GetPlot = function(x, y) return plotByXY[x .. "," .. y] end
    Map.PlotDirection = function(x, y, dir)
        if dir == DirectionTypes.DIRECTION_EAST then return plotByXY[(x + 1) .. "," .. y] end
        return nil
    end
    local u = T.fakeUnit({}); u._plot = start
    UI.GetHeadSelectedUnit = function() return u end
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
    local a     = T.fakePlot({ x = 1, y = 0, terrain = 1, owner = -1 })
    local b     = T.fakePlot({ x = 2, y = 0, revealed = false })
    local c     = T.fakePlot({ x = 3, y = 0, terrain = 1, owner = -1 })
    local plotByXY = { ["0,0"] = start, ["1,0"] = a, ["2,0"] = b, ["3,0"] = c }
    Map.GetPlot = function(x, y) return plotByXY[x .. "," .. y] end
    Map.PlotDirection = function(x, y, dir)
        if dir == DirectionTypes.DIRECTION_EAST then return plotByXY[(x + 1) .. "," .. y] end
        return nil
    end
    local u = T.fakeUnit({}); u._plot = start
    UI.GetHeadSelectedUnit = function() return u end
    Cursor.init()
    local first = Cursor.move(DirectionTypes.DIRECTION_EAST)  -- onto a: "unclaimed. Plains."
    T.truthy(first:find("unclaimed", 1, true), "first move must announce owner: " .. first)
    local second = Cursor.move(DirectionTypes.DIRECTION_EAST)  -- onto b (unexplored)
    T.truthy(second:lower():find("unexplored", 1, true),
        "unexplored step must speak unexplored: " .. second)
    local third = Cursor.move(DirectionTypes.DIRECTION_EAST)  -- onto c
    T.truthy(not third:find("unclaimed", 1, true),
        "crossing unexplored must not retrigger the owner prefix: " .. third)
end

-- ===== Combat tile movement cost =====

function M.test_combat_tile_cost_flat_terrain_is_one_move()
    setup()
    GameInfo.Terrains[1] = { Description = "Plains", Movement = 1 }
    local p = T.fakePlot({ terrain = 1 })
    T.truthy(PlotComposers.combat(p):find("1 moves", 1, true),
        "flat terrain should read '1 moves'")
end

function M.test_combat_tile_cost_hills_adds_one()
    setup()
    GameInfo.Terrains[1] = { Description = "Plains", Movement = 1 }
    local p = T.fakePlot({ terrain = 1, hills = true })
    T.truthy(PlotComposers.combat(p):find("2 moves", 1, true),
        "hills should add 1 to terrain cost")
end

function M.test_combat_tile_cost_feature_overrides_terrain()
    setup()
    GameInfo.Terrains[1] = { Description = "Plains", Movement = 1 }
    GameInfo.Features[3] = { Description = "Marsh", Type = "FEATURE_MARSH", Movement = 3 }
    local p = T.fakePlot({ terrain = 1, feature = 3 })
    T.truthy(PlotComposers.combat(p):find("3 moves", 1, true),
        "feature with nonzero Movement must override terrain cost")
end

function M.test_combat_tile_cost_zero_feature_movement_does_not_override()
    setup()
    GameInfo.Terrains[1] = { Description = "Plains", Movement = 1 }
    -- Lake / River pseudo-features have Movement = 0 (or absent), meaning the
    -- terrain cost stands.
    GameInfo.Features[9] = { Description = "Lake", Type = "FEATURE_LAKE", Movement = 0 }
    local p = T.fakePlot({ terrain = 1, feature = 9 })
    T.truthy(PlotComposers.combat(p):find("1 moves", 1, true),
        "feature with Movement=0 should leave terrain cost unchanged")
end

function M.test_combat_tile_cost_mountain_is_impassable()
    setup()
    local p = T.fakePlot({ mountain = true })
    local out = PlotComposers.combat(p)
    T.truthy(out:lower():find("impassable", 1, true),
        "mountain should read impassable: " .. out)
    T.truthy(not out:find("moves", 1, true),
        "mountain must not also report a move count: " .. out)
end

return M
