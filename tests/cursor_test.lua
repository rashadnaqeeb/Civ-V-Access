-- Tests for the hex-grid cursor: per-section logic, composer integration,
-- cursor state machine. Each test exercises one failure mode the others
-- don't cover; sections that exist only to call game APIs (terrain name
-- lookup, route name lookup) are covered by integration via the glance
-- composer rather than per-section.

local T = require("support")
local M = {}

local function setup()
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_UnitSpeech.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_RecommendationsCore.lua")
    -- WaypointsCore is referenced by PlotSections.waypoint, which the
    -- glance composer pulls in. atXY short-circuits on the polyfill's
    -- nil UI.GetHeadSelectedUnit so cursor tests that don't set up a
    -- selection see no waypoint tokens.
    dofile("src/dlc/UI/InGame/CivVAccess_WaypointsCore.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_PlotSectionsCore.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_PlotSectionUnits.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_PlotSectionRiver.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_PlotComposers.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_AudioCueMode.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_PlotAudio.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_CursorCore.lua")
    -- Cursor.activate delegates through CursorActivate.run; without the
    -- module loaded the activate-branch tests would hit a nil global.
    dofile("src/dlc/UI/InGame/CivVAccess_CursorActivate.lua")

    -- Reset audio stub and shared state so prior suites / cases don't leak
    -- cue handles or mode overrides into the cursor cases. Default the mode
    -- to MODE_SPEECH here so the pre-existing glance tests see the full
    -- speech output they expect; cases that exercise cue / cue-only override
    -- via AudioCueMode.setMode.
    audio._reset()
    civvaccess_shared.plotAudioHandles = nil
    civvaccess_shared.audioCueMode = AudioCueMode.MODE_SPEECH

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
    UI.GetHeadSelectedCity = function()
        return nil
    end
    UI.GetInterfaceMode = function()
        return InterfaceModeTypes.INTERFACEMODE_SELECTION
    end
    -- Recs gating: a sibling test that called installRecGlobals leaves
    -- UI.CanSelectionListWork / Found defined; cursor cases that don't
    -- explicitly opt into the rec section would otherwise hit
    -- Recommendations.workerPlots and try to call GetRecommendedWorkerPlots
    -- on a bare fakePlayer that has no such method.
    UI.CanSelectionListWork = nil
    UI.CanSelectionListFound = nil

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

-- ===== terrainShape cue-only filtering =====
-- ctx.cueOnly drops tokens the audio cue layer covers (terrain, mountain,
-- lake, non-wonder features) and keeps what has no audio representation
-- (hills, natural wonders).

function M.test_terrainShape_cueOnly_suppresses_base_terrain()
    setup()
    GameInfo.Terrains[1] = { Description = "Plains" }
    local p = T.fakePlot({ terrain = 1 })
    T.eq(
        #PlotSections.terrainShape.Read(p, { cueOnly = true }),
        0,
        "terrain name is carried by bed cue; must not speak in cue-only"
    )
end

function M.test_terrainShape_cueOnly_suppresses_mountain()
    setup()
    local p = T.fakePlot({ mountain = true })
    T.eq(
        #PlotSections.terrainShape.Read(p, { cueOnly = true }),
        0,
        "mountain has its own bed; must not speak in cue-only"
    )
end

function M.test_terrainShape_cueOnly_suppresses_lake()
    setup()
    local p = T.fakePlot({ lake = true })
    T.eq(
        #PlotSections.terrainShape.Read(p, { cueOnly = true }),
        0,
        "lake is covered by the water bed; must not speak in cue-only"
    )
end

function M.test_terrainShape_cueOnly_suppresses_non_wonder_feature()
    -- Every non-wonder feature maps to either a bed (jungle, marsh, ...)
    -- or a stinger (forest, fallout). None of them should speak in cue-only.
    setup()
    GameInfo.Terrains[1] = { Description = "Plains" }
    GameInfo.Features[6] = { Description = "Forest", Type = "FEATURE_FOREST" }
    local p = T.fakePlot({ terrain = 1, feature = 6 })
    T.eq(
        #PlotSections.terrainShape.Read(p, { cueOnly = true }),
        0,
        "feature name is carried by the stinger/bed; must not speak in cue-only"
    )
end

function M.test_terrainShape_cueOnly_keeps_hills()
    -- Hills have no audio representation in v1.
    setup()
    GameInfo.Terrains[1] = { Description = "Plains" }
    local p = T.fakePlot({ terrain = 1, hills = true })
    local out = PlotSections.terrainShape.Read(p, { cueOnly = true })
    T.eq(#out, 1)
    T.eq(out[1], "hills")
end

function M.test_terrainShape_cueOnly_keeps_natural_wonder()
    -- The palette has no wonder sound, so identity must speak.
    setup()
    GameInfo.Terrains[6] = { Description = "Snow" }
    GameInfo.Features[5] = { Description = "Mt. Fuji", Type = "FEATURE_FUJI", NaturalWonder = true }
    local p = T.fakePlot({ terrain = 6, feature = 5, mountain = true })
    local out = PlotSections.terrainShape.Read(p, { cueOnly = true })
    T.eq(#out, 1)
    T.eq(out[1], "Mt. Fuji")
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

function M.test_units_fortified_enemy_surfaces_status()
    -- Foreign fortify shows a shield-shaped flag to sighted players, so
    -- the cursor's plot readout must name the status.
    setup()
    Players[0] = T.fakePlayer({ adj = "Roman" })
    Players[1] = T.fakePlayer({ adj = "Arabian" })
    local hostile = T.fakeUnit({ owner = 1, team = 1, nameKey = "Warrior", fortifyTurns = 3 })
    local p = T.fakePlot({ units = { hostile } })
    local s = PlotSectionUnits.Read(p, {})[1]
    T.truthy(s:find("TXT_KEY_UNIT_STATUS_FORTIFIED", 1, true), "enemy fortified must surface: " .. tostring(s))
end

function M.test_units_sleeping_enemy_omits_status()
    -- Sleep / alert / heal / automate / build don't render on a foreign
    -- unit flag; mirror the sighted view and keep silence.
    setup()
    Players[0] = T.fakePlayer({ adj = "Roman" })
    Players[1] = T.fakePlayer({ adj = "Arabian" })
    local hostile = T.fakeUnit({
        owner = 1,
        team = 1,
        nameKey = "Warrior",
        activity = ActivityTypes.ACTIVITY_SLEEP,
    })
    local p = T.fakePlot({ units = { hostile } })
    local s = PlotSectionUnits.Read(p, {})[1]
    T.truthy(not s:find("SLEEP", 1, true), "sleep not visible on foreign flag: " .. tostring(s))
end

function M.test_units_embarked_prefix()
    -- Embarked status is visible to sighted players from the boat-shaped
    -- unit flag, regardless of ownership; surface it as a leading prefix
    -- so the player hears "embarked Arabian Warrior" before HP / status.
    setup()
    Players[0] = T.fakePlayer({ adj = "Roman" })
    local atSea = T.fakeUnit({ owner = 0, nameKey = "Warrior", embarked = true })
    local p = T.fakePlot({ units = { atSea } })
    local s = PlotSectionUnits.Read(p, {})[1]
    T.truthy(s:sub(1, 9) == "embarked ", "embarked prefix must lead the segment: " .. tostring(s))
end

function M.test_units_friendly_sleep_surfaces_status()
    -- Own-unit sleep shows in the UnitList panel; cursor plot readout
    -- mirrors that by speaking the deeper-rung token for friendlies.
    setup()
    Players[0] = T.fakePlayer({ adj = "Roman" })
    local sleeper = T.fakeUnit({
        owner = 0,
        team = 0,
        nameKey = "Warrior",
        activity = ActivityTypes.ACTIVITY_SLEEP,
    })
    local p = T.fakePlot({ units = { sleeper } })
    local s = PlotSectionUnits.Read(p, {})[1]
    T.truthy(s:find("TXT_KEY_MISSION_SLEEP", 1, true), "friendly sleep must surface: " .. tostring(s))
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

function M.test_economy_barren_tile_speaks_no_yield()
    -- Empty-yield tile with no other economy flags would return ""
    -- and speak(...) is a no-op on empty strings, so W would produce
    -- silence and the player would suspect a broken key. Guard by
    -- speaking the engine's "No Yield" string instead.
    setup()
    local p = T.fakePlot({ revealed = true })
    local out = PlotComposers.economy(p)
    T.truthy(out ~= "", "barren tile must not produce silence")
    T.truthy(
        out:lower():find("no_yield", 1, true) or out:lower():find("no yield", 1, true),
        "barren tile should announce the engine's No Yield key: " .. out
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

function M.test_combat_includes_route_name()
    setup()
    GameInfo.Terrains[1] = { Description = "Plains", Movement = 1 }
    GameInfo.Routes[1] = { Description = "Road" }
    local p = T.fakePlot({ terrain = 1, route = 1 })
    T.truthy(
        PlotComposers.combat(p):find("Road", 1, true),
        "combat composer must name the route so the on-demand answer is not just the unmodified tile cost"
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

-- ===== AudioCueMode gating of announceForMove =====
-- Three modes: speech-only (current behavior), speech+cue (both fire),
-- cue-only (silence except for natural wonders + unexplored). The audio
-- stub from run.lua captures cue calls so tests can distinguish cue-emitted
-- from cue-suppressed moves; PlotAudio.loadAll runs in setupModeMove so
-- emit has handles to dispatch with.
local function setupModeMove(mode)
    setup()
    GameInfo.Terrains[1] = { Type = "TERRAIN_GRASS", Description = "Plains" }
    local start = T.fakePlot({ x = 0, y = 0, terrain = 1 })
    local dest = T.fakePlot({ x = 1, y = 0, terrain = 1 })
    local byXY = { ["0,0"] = start, ["1,0"] = dest }
    Map.GetPlot = function(x, y)
        return byXY[x .. "," .. y]
    end
    Map.PlotDirection = function(x, y, dir)
        if dir == DirectionTypes.DIRECTION_EAST then
            return byXY[(x + 1) .. "," .. y]
        end
        return nil
    end
    local seed = T.fakeUnit({})
    seed._plot = start
    UI.GetHeadSelectedUnit = function()
        return seed
    end
    Cursor.init()
    PlotAudio.loadAll()
    AudioCueMode.setMode(mode)
    audio._reset()
    return start, dest
end

local function hasOp(calls, op)
    for _, c in ipairs(calls) do
        if c.op == op then
            return true
        end
    end
    return false
end

function M.test_speech_mode_move_produces_no_audio_calls()
    -- MODE_SPEECH preserves the mod's original behavior for users who
    -- don't want audio cues. Not even cancel_all fires, to avoid touching
    -- the mixer when audio is off entirely.
    setupModeMove(AudioCueMode.MODE_SPEECH)
    local out = Cursor.move(DirectionTypes.DIRECTION_EAST)
    T.eq(#audio._calls, 0, "speech mode must not touch audio")
    T.truthy(out:find("Plains", 1, true), "speech mode still speaks the glance: " .. out)
end

function M.test_speech_plus_cue_mode_fires_both()
    -- MODE_SPEECH_PLUS_CUE: audio cue layered under normal speech. The
    -- default mode once config lands; verify cue dispatch and speech text
    -- both present on the same move.
    setupModeMove(AudioCueMode.MODE_SPEECH_PLUS_CUE)
    local out = Cursor.move(DirectionTypes.DIRECTION_EAST)
    T.truthy(hasOp(audio._calls, "cancel_all"), "cue must cancel prior audio on move")
    T.truthy(hasOp(audio._calls, "play"), "cue must play a bed")
    T.truthy(out:find("Plains", 1, true), "speech still fires in speech+cue: " .. out)
end

function M.test_cue_only_mode_suppresses_terrain_name_in_speech()
    -- Cue-only: the base terrain name is already carried by the bed cue
    -- and must not speak. The glance still runs (so hills, units, owner
    -- prefix, resources, etc. still speak) -- just with the sound-covered
    -- tokens filtered out.
    setupModeMove(AudioCueMode.MODE_CUE_ONLY)
    local out = Cursor.move(DirectionTypes.DIRECTION_EAST)
    T.truthy(hasOp(audio._calls, "play"), "cue must still play in cue-only")
    T.truthy(not out:find("Plains", 1, true), "terrain name must be suppressed in cue-only: " .. out)
end

function M.test_cue_only_mode_keeps_hills_in_speech()
    -- Hills have no audio representation in the v1 palette, so they must
    -- still speak even in cue-only.
    setup()
    GameInfo.Terrains[1] = { Type = "TERRAIN_GRASS", Description = "Plains" }
    local start = T.fakePlot({ x = 0, y = 0, terrain = 1 })
    local dest = T.fakePlot({ x = 1, y = 0, terrain = 1, hills = true })
    local byXY = { ["0,0"] = start, ["1,0"] = dest }
    Map.GetPlot = function(x, y)
        return byXY[x .. "," .. y]
    end
    Map.PlotDirection = function(x, y, dir)
        if dir == DirectionTypes.DIRECTION_EAST then
            return byXY[(x + 1) .. "," .. y]
        end
        return nil
    end
    local seed = T.fakeUnit({})
    seed._plot = start
    UI.GetHeadSelectedUnit = function()
        return seed
    end
    Cursor.init()
    PlotAudio.loadAll()
    AudioCueMode.setMode(AudioCueMode.MODE_CUE_ONLY)

    local out = Cursor.move(DirectionTypes.DIRECTION_EAST)
    T.truthy(out:find("hills", 1, true), "hills must speak in cue-only: " .. out)
    T.truthy(not out:find("Plains", 1, true), "terrain still suppressed: " .. out)
end

function M.test_cue_only_mode_keeps_units_in_speech()
    -- Units have no audio representation; the whole point of moving the
    -- cursor onto an enemy tile is to hear who's there. Assert on the HP
    -- suffix -- it's outside the engine's unit-name template (which the
    -- test harness can't expand) and only appears when a unit spoke.
    setup()
    Players[0] = T.fakePlayer({ adj = "Roman" })
    GameInfo.Terrains[1] = { Type = "TERRAIN_GRASS", Description = "Plains" }
    local start = T.fakePlot({ x = 0, y = 0, terrain = 1 })
    local damaged = T.fakeUnit({ owner = 0, nameKey = "Warrior", damage = 40 })
    local dest = T.fakePlot({ x = 1, y = 0, terrain = 1, units = { damaged } })
    local byXY = { ["0,0"] = start, ["1,0"] = dest }
    Map.GetPlot = function(x, y)
        return byXY[x .. "," .. y]
    end
    Map.PlotDirection = function(x, y, dir)
        if dir == DirectionTypes.DIRECTION_EAST then
            return byXY[(x + 1) .. "," .. y]
        end
        return nil
    end
    local seed = T.fakeUnit({})
    seed._plot = start
    UI.GetHeadSelectedUnit = function()
        return seed
    end
    Cursor.init()
    PlotAudio.loadAll()
    AudioCueMode.setMode(AudioCueMode.MODE_CUE_ONLY)

    local out = Cursor.move(DirectionTypes.DIRECTION_EAST)
    T.truthy(out:find("60 hp", 1, true), "unit must still speak in cue-only: " .. out)
end

function M.test_cue_only_mode_speaks_natural_wonder()
    -- Natural wonders are the sole speech exception in cue-only: the cue
    -- palette has no wonder bed, so identity must ride on speech or the
    -- player won't know which wonder they found.
    setup()
    GameInfo.Terrains[1] = { Type = "TERRAIN_GRASS", Description = "Plains" }
    GameInfo.Features[9] = { Type = "FEATURE_FUJI", Description = "Mt. Fuji", NaturalWonder = true }
    local start = T.fakePlot({ x = 0, y = 0, terrain = 1 })
    local wonder = T.fakePlot({ x = 1, y = 0, terrain = 1, feature = 9, mountain = true })
    local byXY = { ["0,0"] = start, ["1,0"] = wonder }
    Map.GetPlot = function(x, y)
        return byXY[x .. "," .. y]
    end
    Map.PlotDirection = function(x, y, dir)
        if dir == DirectionTypes.DIRECTION_EAST then
            return byXY[(x + 1) .. "," .. y]
        end
        return nil
    end
    local seed = T.fakeUnit({})
    seed._plot = start
    UI.GetHeadSelectedUnit = function()
        return seed
    end
    Cursor.init()
    PlotAudio.loadAll()
    AudioCueMode.setMode(AudioCueMode.MODE_CUE_ONLY)
    audio._reset()

    local out = Cursor.move(DirectionTypes.DIRECTION_EAST)
    T.truthy(out:find("Mt. Fuji", 1, true), "cue-only must speak wonder identity: " .. out)
end

function M.test_cue_only_mode_speaks_unexplored()
    -- Unexplored tiles have no audio representation in the v1 palette, so
    -- speech fires regardless of mode; silence would be ambiguous with a
    -- broken cue pipeline.
    setup()
    local start = T.fakePlot({ x = 0, y = 0 })
    local fogged = T.fakePlot({ x = 1, y = 0, revealed = false })
    local byXY = { ["0,0"] = start, ["1,0"] = fogged }
    Map.GetPlot = function(x, y)
        return byXY[x .. "," .. y]
    end
    Map.PlotDirection = function(x, y, dir)
        if dir == DirectionTypes.DIRECTION_EAST then
            return byXY[(x + 1) .. "," .. y]
        end
        return nil
    end
    local seed = T.fakeUnit({})
    seed._plot = start
    UI.GetHeadSelectedUnit = function()
        return seed
    end
    Cursor.init()
    PlotAudio.loadAll()
    AudioCueMode.setMode(AudioCueMode.MODE_CUE_ONLY)
    audio._reset()

    local out = Cursor.move(DirectionTypes.DIRECTION_EAST)
    T.truthy(out:lower():find("unexplored", 1, true), "unexplored must speak regardless of mode: " .. out)
end

-- ===== Recommendation section =====

-- installRecGlobals / installRecPlayer are shared fixtures from
-- tests/support.lua; aliased locally so the call sites stay terse
-- and match the scanner suite's naming.
local installRecGlobals = T.installRecGlobals
local installRecPlayer = T.installRecPlayer

function M.test_recommendation_section_silent_without_globals()
    -- Recommendations.allowed() reads OptionsManager.IsNoTileRecommendations,
    -- which is not in the polyfill and only shows up in tests that install
    -- it explicitly. When missing (every pre-existing cursor glance test),
    -- allowed() returns false and the section stays silent. This is what
    -- keeps the recommendation section from perturbing any of the older
    -- glance cases; without it, every fixture would need a nil-OptionsManager
    -- carve-out.
    setup()
    local p = T.fakePlot({ x = 0, y = 0, revealed = true, visible = true })
    T.eq(#PlotSections.recommendation.Read(p), 0)
end

function M.test_recommendation_section_silent_when_options_hide()
    setup()
    installRecGlobals({ canFound = true, hideRecs = true })
    installRecPlayer({ numCities = 1, settlerPlots = { T.fakePlot({ x = 0, y = 0 }) } })
    local p = T.fakePlot({ x = 0, y = 0, revealed = true, visible = true })
    T.eq(#PlotSections.recommendation.Read(p), 0, "IsNoTileRecommendations must suppress the section")
end

function M.test_recommendation_section_silent_without_first_city()
    setup()
    installRecGlobals({ canFound = true })
    installRecPlayer({ numCities = 0, settlerPlots = { T.fakePlot({ x = 0, y = 0 }) } })
    local p = T.fakePlot({ x = 0, y = 0, revealed = true, visible = true })
    T.eq(#PlotSections.recommendation.Read(p), 0, "settler recs suppressed before the first city")
end

function M.test_recommendation_section_silent_on_unrecommended_plot()
    setup()
    installRecGlobals({ canFound = true })
    installRecPlayer({
        numCities = 1,
        settlerPlots = { T.fakePlot({ x = 7, y = 7 }) },
    })
    local p = T.fakePlot({ x = 0, y = 0, revealed = true, visible = true })
    T.eq(#PlotSections.recommendation.Read(p), 0, "plot not in rec list must stay silent")
end

function M.test_recommendation_section_silent_when_plot_unfoundable()
    -- Defensive: a rec plot that's become unfoundable since the list
    -- was produced. Mirrors GenericWorldAnchor.lua's CanFound guard.
    setup()
    installRecGlobals({ canFound = true })
    local p = T.fakePlot({ x = 0, y = 0, revealed = true, visible = true })
    installRecPlayer({
        numCities = 1,
        settlerPlots = { p },
        cantFoundAt = { { 0, 0 } },
    })
    T.eq(#PlotSections.recommendation.Read(p), 0)
end

function M.test_recommendation_settler_prefix_and_reason_tokens()
    -- Two-token output: prefix + reason. Composer joins with ", "
    -- so the final glance reads "recommendation: City site, <tooltip>".
    -- Food path fires when no nearby resources and food/plot > 1.2.
    setup()
    installRecGlobals({ canFound = true })
    local target = T.fakePlot({ x = 0, y = 0, revealed = true, visible = true })
    installRecPlayer({ numCities = 1, settlerPlots = { target } })
    -- 5x5 area of grass plots, each yielding 2 food. Average per plot
    -- = 2.0 > the 1.2 threshold, so the FOOD key fires.
    Map.GetPlotXY = function(_, _, _, _)
        local fp = T.fakePlot({ yields = { [YieldTypes.YIELD_FOOD] = 2 }, owner = -1 })
        -- Not owned, no resource, so the resource branches are no-ops.
        function fp:IsOwned()
            return false
        end
        return fp
    end
    Map.PlotDistance = function(x1, y1, x2, y2)
        return math.max(math.abs(x1 - x2), math.abs(y1 - y2))
    end
    local tokens = PlotSections.recommendation.Read(target)
    T.eq(#tokens, 2)
    T.truthy(tokens[1]:find("recommendation", 1, true), "first token carries the prefix: " .. tokens[1])
    T.truthy(tokens[1]:find("City site", 1, true), "first token carries the settler name: " .. tokens[1])
    T.eq(tokens[2], "TXT_KEY_RECOMMEND_SETTLER_FOOD", "food path picks the food reason key")
end

function M.test_recommendation_settler_luxury_beats_food()
    -- Luxury ranks ahead of any yield category in HandleSettlerRecommendation's
    -- priority ladder. We mirror that exactly -- if the priority changes,
    -- we'd silently drift from the game's tooltip text.
    setup()
    installRecGlobals({ canFound = true })
    local target = T.fakePlot({ x = 0, y = 0, revealed = true, visible = true })
    local player = installRecPlayer({ numCities = 1, settlerPlots = { target } })
    player._resources = { [50] = 0 } -- luxury resource the player doesn't have yet
    Game.GetResourceUsageType = function(resId)
        if resId == 50 then
            return ResourceUsageTypes.RESOURCEUSAGE_LUXURY
        end
        return ResourceUsageTypes.RESOURCEUSAGE_BONUS
    end
    Map.GetPlotXY = function(_, _, dx, dy)
        local fp = T.fakePlot({ yields = { [YieldTypes.YIELD_FOOD] = 5 } })
        function fp:IsOwned()
            return false
        end
        -- Put a luxury on one neighbour only; food yields are high everywhere.
        if dx == 1 and dy == 0 then
            fp._resource = 50
        end
        return fp
    end
    Map.PlotDistance = function(x1, y1, x2, y2)
        return math.max(math.abs(x1 - x2), math.abs(y1 - y2))
    end
    local tokens = PlotSections.recommendation.Read(target)
    T.eq(tokens[2], "TXT_KEY_RECOMMEND_SETTLER_LUXURIES", "luxury must beat food even with high food yield")
end

function M.test_recommendation_worker_emits_build_name_and_reason()
    setup()
    installRecGlobals({ canWork = true })
    GameInfo.Builds = {
        [7] = { Description = "TXT_KEY_BUILD_FARM" },
    }
    local target = T.fakePlot({ x = 2, y = 2, revealed = true, visible = true })
    installRecPlayer({
        numCities = 1,
        workerRecs = { { plot = target, buildType = 7 } },
    })
    -- No resource on plot, no custom Recommendation, so the yield
    -- delta branch runs. Food delta +1 triggers the FOOD_REC key.
    function target:CalculateYield(y)
        return 0
    end
    function target:GetYieldWithBuild(_build, y, _path, _player)
        if y == YieldTypes.YIELD_FOOD then
            return 1
        end
        return 0
    end
    local tokens = PlotSections.recommendation.Read(target)
    T.eq(#tokens, 2)
    T.truthy(tokens[1]:find("TXT_KEY_BUILD_FARM", 1, true), "worker name is the build's Description: " .. tokens[1])
    T.eq(tokens[2], "TXT_KEY_BUILD_FOOD_REC")
end

function M.test_recommendation_worker_strategic_resource_beats_yield()
    -- Plot-resource hookup ranks ahead of the yield-delta tail in
    -- HandleWorkerRecommendation's ladder: a strategic on the plot
    -- always wins, regardless of what food/prod/gold the build adds.
    setup()
    installRecGlobals({ canWork = true })
    GameInfo.Builds = {
        [7] = { Description = "TXT_KEY_BUILD_MINE" },
    }
    GameInfo.Resources = {
        [30] = { ResourceUsage = ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC },
    }
    local target = T.fakePlot({
        x = 2,
        y = 2,
        revealed = true,
        visible = true,
        resource = 30,
    })
    function target:CalculateYield()
        return 0
    end
    function target:GetYieldWithBuild()
        return 5 -- would otherwise trigger a yield-delta key
    end
    installRecPlayer({
        numCities = 1,
        workerRecs = { { plot = target, buildType = 7 } },
    })
    local tokens = PlotSections.recommendation.Read(target)
    T.eq(tokens[2], "TXT_KEY_RECOMMEND_WORKER_STRATEGIC", "strategic-on-plot must beat the yield-delta tail")
end

function M.test_recommendation_worker_fires_when_settler_cant_found()
    -- Regression: a plot that appears in BOTH rec lists (a mixed
    -- Settler+Worker stack is selected) used to silently swallow the
    -- worker announcement once the settler's CanFound turned false --
    -- the settler branch early-returned {} instead of falling through.
    -- The fallthrough must now reach the worker path.
    setup()
    installRecGlobals({ canFound = true, canWork = true })
    GameInfo.Builds = { [7] = { Description = "TXT_KEY_BUILD_FARM" } }
    local target = T.fakePlot({ x = 0, y = 0, revealed = true, visible = true })
    function target:CalculateYield()
        return 0
    end
    function target:GetYieldWithBuild(_build, y, _path, _player)
        if y == YieldTypes.YIELD_FOOD then
            return 1
        end
        return 0
    end
    installRecPlayer({
        numCities = 1,
        settlerPlots = { target },
        workerRecs = { { plot = target, buildType = 7 } },
        cantFoundAt = { { 0, 0 } }, -- settler side is gated out
    })
    local tokens = PlotSections.recommendation.Read(target)
    T.eq(#tokens, 2, "worker rec must survive the settler's CanFound=false gate")
    T.truthy(tokens[1]:find("TXT_KEY_BUILD_FARM", 1, true), "expected build name in prefix: " .. tokens[1])
    T.eq(tokens[2], "TXT_KEY_BUILD_FOOD_REC")
end

function M.test_recommendation_section_wires_into_glance()
    -- End-to-end: a recommendation on the cursor's plot produces a
    -- glance string that contains the prefix. Protects against a future
    -- edit that drops the readSection(PlotSections.recommendation, ...)
    -- line from PlotComposers.glance.
    setup()
    installRecGlobals({ canFound = true })
    GameInfo.Terrains = { [1] = { Description = "Plains" } }
    local target = T.fakePlot({ x = 0, y = 0, revealed = true, visible = true, terrain = 1 })
    installRecPlayer({ numCities = 1, settlerPlots = { target } })
    Game.GetResourceUsageType = function()
        return ResourceUsageTypes.RESOURCEUSAGE_BONUS
    end
    Map.GetPlotXY = function()
        return nil -- zero-plot area produces no yield categories; only the prefix fires
    end
    Map.PlotDistance = function(x1, y1, x2, y2)
        return math.max(math.abs(x1 - x2), math.abs(y1 - y2))
    end
    local out = PlotComposers.glance(target)
    T.truthy(out:find("recommendation", 1, true), "glance must include the recommendation prefix: " .. out)
    T.truthy(out:find("City site", 1, true), "glance must include the rec name: " .. out)
end

-- ===== Cursor.activate (Enter) =====
-- Mirrors the ownership fork in vanilla BNW's OnBannerClick:
-- own city opens city screen (or annex popup for an annexable puppet),
-- met minor opens city screen, met major opens diplomacy with the
-- turn-active guard, unmet foreign / non-city is silent. One test per
-- branch; each catches a distinct regression.

local activateCalls

local function primeCursor(plot)
    local x, y = plot:GetX(), plot:GetY()
    UI.GetHeadSelectedUnit = function()
        return {
            GetPlot = function()
                return plot
            end,
        }
    end
    Map.GetPlot = function(qx, qy)
        if qx == x and qy == y then
            return plot
        end
    end
    Cursor._reset()
    Cursor.init()
end

local function installActivateStubs()
    activateCalls = {}
    UI.DoSelectCityAtPlot = function(plot)
        activateCalls[#activateCalls + 1] = { op = "select", plot = plot }
    end
    UI.SetRepeatActionPlayer = function(id)
        activateCalls[#activateCalls + 1] = { op = "repeat", id = id }
    end
    UI.ChangeStartDiploRepeatCount = function(n)
        activateCalls[#activateCalls + 1] = { op = "count", n = n }
    end
    Events.SerialEventGameMessagePopup = function(info)
        activateCalls[#activateCalls + 1] = { op = "popup", info = info }
    end
    -- CursorActivate composes its city entry label via CitySpeech.identity
    -- before dispatching. The existing activate suite asserts only on
    -- engine-call side effects, so a passthrough stub is enough.
    CitySpeech = {
        identity = function(_)
            return ""
        end,
    }
    Events.OpenPlayerDealScreenEvent = function(id)
        activateCalls[#activateCalls + 1] = { op = "deal", id = id }
    end
    Game.IsProcessingMessages = function()
        return false
    end
    ButtonPopupTypes = { BUTTONPOPUP_ANNEX_CITY = 42 }
end

-- T.fakeCity / T.fakePlayer omit the activate-specific methods; extend
-- them inline here so the shared fixtures aren't cluttered with branches
-- only this feature exercises.
local function makeCity(opts)
    local c = T.fakeCity(opts)
    c._isPuppet = opts.puppet or false
    function c:IsPuppet()
        return self._isPuppet
    end
    return c
end

local function makePlayer(opts)
    local p = T.fakePlayer(opts)
    p._mayNotAnnex = opts.mayNotAnnex or false
    p._isHuman = opts.isHuman or false
    p._isTurnActive = (opts.isTurnActive ~= false)
    function p:MayNotAnnex()
        return self._mayNotAnnex
    end
    function p:IsHuman()
        return self._isHuman
    end
    function p:IsTurnActive()
        return self._isTurnActive
    end
    function p:DoBeginDiploWithHuman()
        activateCalls[#activateCalls + 1] = { op = "diplo", player = self }
    end
    return p
end

function M.test_activate_silent_on_non_city_plot()
    setup()
    installActivateStubs()
    local plot = T.fakePlot({ x = 3, y = 4, isCity = false })
    primeCursor(plot)
    Cursor.activate()
    T.eq(#activateCalls, 0, "non-city plot should not fire any engine call")
end

function M.test_activate_own_city_opens_city_screen()
    setup()
    installActivateStubs()
    Game.GetActivePlayer = function()
        return 0
    end
    local city = makeCity({ owner = 0, id = 7, puppet = false })
    local plot = T.fakePlot({ x = 0, y = 0, isCity = true, city = city, owner = 0 })
    Players[0] = makePlayer({})
    primeCursor(plot)
    Cursor.activate()
    T.eq(#activateCalls, 1)
    T.eq(activateCalls[1].op, "select")
    T.eq(activateCalls[1].plot, plot)
end

function M.test_activate_own_puppet_fires_annex_popup()
    setup()
    installActivateStubs()
    Game.GetActivePlayer = function()
        return 0
    end
    local city = makeCity({ owner = 0, id = 11, puppet = true })
    local plot = T.fakePlot({ x = 0, y = 0, isCity = true, city = city, owner = 0 })
    Players[0] = makePlayer({ mayNotAnnex = false })
    primeCursor(plot)
    Cursor.activate()
    T.eq(#activateCalls, 1)
    T.eq(activateCalls[1].op, "popup")
    T.eq(activateCalls[1].info.Type, 42)
    T.eq(activateCalls[1].info.Data1, 11)
end

function M.test_activate_own_puppet_with_may_not_annex_opens_city_screen()
    -- Venice-style civ: owns puppets but can't annex. Activation must
    -- open the (read-only) city screen rather than an unusable popup.
    setup()
    installActivateStubs()
    Game.GetActivePlayer = function()
        return 0
    end
    local city = makeCity({ owner = 0, id = 11, puppet = true })
    local plot = T.fakePlot({ x = 0, y = 0, isCity = true, city = city, owner = 0 })
    Players[0] = makePlayer({ mayNotAnnex = true })
    primeCursor(plot)
    Cursor.activate()
    T.eq(#activateCalls, 1)
    T.eq(activateCalls[1].op, "select")
end

function M.test_activate_unmet_foreign_is_silent()
    setup()
    installActivateStubs()
    Game.GetActivePlayer = function()
        return 0
    end
    Game.GetActiveTeam = function()
        return 0
    end
    Teams[0] = T.fakeTeam({ hasMet = {} })
    Players[1] = makePlayer({ team = 1 })
    local city = makeCity({ owner = 1 })
    local plot = T.fakePlot({ x = 0, y = 0, isCity = true, city = city, owner = 1 })
    primeCursor(plot)
    Cursor.activate()
    T.eq(#activateCalls, 0, "unmet foreign city should be silent")
end

function M.test_activate_met_minor_opens_city_screen()
    setup()
    installActivateStubs()
    Game.GetActivePlayer = function()
        return 0
    end
    Game.GetActiveTeam = function()
        return 0
    end
    Teams[0] = T.fakeTeam({ hasMet = { [1] = true } })
    Players[1] = makePlayer({ team = 1, isMinor = true })
    local city = makeCity({ owner = 1 })
    local plot = T.fakePlot({ x = 0, y = 0, isCity = true, city = city, owner = 1 })
    primeCursor(plot)
    Cursor.activate()
    T.eq(#activateCalls, 1)
    T.eq(activateCalls[1].op, "select")
end

function M.test_activate_met_major_ai_opens_diplomacy()
    setup()
    installActivateStubs()
    Game.GetActivePlayer = function()
        return 0
    end
    Game.GetActiveTeam = function()
        return 0
    end
    Teams[0] = T.fakeTeam({ hasMet = { [1] = true } })
    Players[0] = makePlayer({ team = 0, isTurnActive = true })
    local target = makePlayer({ team = 1, isMinor = false, isHuman = false })
    Players[1] = target
    local city = makeCity({ owner = 1 })
    local plot = T.fakePlot({ x = 0, y = 0, isCity = true, city = city, owner = 1 })
    primeCursor(plot)
    Cursor.activate()
    T.eq(#activateCalls, 3, "expected SetRepeatActionPlayer + ChangeStartDiploRepeatCount + DoBeginDiploWithHuman")
    T.eq(activateCalls[1].op, "repeat")
    T.eq(activateCalls[1].id, 1)
    T.eq(activateCalls[2].op, "count")
    T.eq(activateCalls[2].n, 1)
    T.eq(activateCalls[3].op, "diplo")
    T.eq(activateCalls[3].player, target)
end

function M.test_activate_met_major_human_opens_deal_screen()
    setup()
    installActivateStubs()
    Game.GetActivePlayer = function()
        return 0
    end
    Game.GetActiveTeam = function()
        return 0
    end
    Teams[0] = T.fakeTeam({ hasMet = { [1] = true } })
    Players[0] = makePlayer({ team = 0, isTurnActive = true })
    Players[1] = makePlayer({ team = 1, isMinor = false, isHuman = true })
    local city = makeCity({ owner = 1 })
    local plot = T.fakePlot({ x = 0, y = 0, isCity = true, city = city, owner = 1 })
    primeCursor(plot)
    Cursor.activate()
    T.eq(#activateCalls, 1)
    T.eq(activateCalls[1].op, "deal")
    T.eq(activateCalls[1].id, 1)
end

-- ===== Targetability prefix in ranged interface modes =====
-- The cursor prepends "unseen, " or "out of range, " to its move announcement
-- while UI.GetInterfaceMode() is one of the three ranged modes, mirroring the
-- Bombardment.lua red-overlay / arrow visuals sighted players read.

-- Builds a strip of revealed plain tiles east of (0,0). The attacker's plot
-- at (0,0) carries the canSeePlot stub since CursorCore queries LoS via
-- attackerPlot:CanSeePlot(target, ...) -- the engine's API is on the source
-- plot, not the target. losBlocked=true makes every CanSeePlot from the
-- attacker plot return false (uniform geometric obstruction). foggedAt is
-- a list of x coordinates whose east-strip plots should be revealed-but-
-- fogged so the targetability prefix's IsVisible gate can be exercised.
local function setupRangedScene(opts)
    setup()
    Players[0] = T.fakePlayer({ team = 0 })
    GameInfo.Terrains[1] = { Description = "Plains" }
    local attackerPlot = T.fakePlot({
        x = 0, y = 0, terrain = 1,
        canSeePlot = function(_t, _team, _range, _dir)
            if opts.losBlocked then
                return false
            end
            return true
        end,
    })
    local plotByXY = { ["0,0"] = attackerPlot }
    local fogged = {}
    for _, x in ipairs(opts.foggedAt or {}) do
        fogged[x] = true
    end
    local maxX = opts.maxX or 3
    for x = 1, maxX do
        plotByXY[x .. ",0"] = T.fakePlot({
            x = x, y = 0,
            terrain = (opts.featureless and -1) or 1,
            visible = not fogged[x],
            revealed = true,
        })
    end
    Map.GetPlot = function(x, y)
        return plotByXY[x .. "," .. y]
    end
    Map.PlotDirection = function(x, y, dir)
        if dir == DirectionTypes.DIRECTION_EAST then
            return plotByXY[(x + 1) .. "," .. y]
        end
        return nil
    end
    Map.PlotDistance = function(x1, y1, x2, y2)
        return math.max(math.abs(x1 - x2), math.abs(y1 - y2))
    end
    UI.GetInterfaceMode = function()
        return opts.mode or InterfaceModeTypes.INTERFACEMODE_SELECTION
    end
    return attackerPlot
end

local function selectArcher(attackerPlot, opts)
    opts = opts or {}
    local archer = T.fakeUnit({ range = opts.range or 2, domain = opts.domain or DomainTypes.DOMAIN_LAND })
    archer._plot = attackerPlot
    UI.GetHeadSelectedUnit = function()
        return archer
    end
    Cursor.init()
    return archer
end

function M.test_targetability_unseen_when_los_blocked()
    local attackerPlot = setupRangedScene({
        mode = InterfaceModeTypes.INTERFACEMODE_RANGE_ATTACK,
        losBlocked = true,
    })
    selectArcher(attackerPlot)
    Cursor.move(DirectionTypes.DIRECTION_EAST) -- (1,0): in range, LoS blocked
    local out = Cursor.move(DirectionTypes.DIRECTION_EAST) -- (2,0): in range, LoS blocked
    T.truthy(out:find("unseen", 1, true), "LoS-blocked tile must speak unseen prefix: " .. out)
    T.truthy(not out:find("out of range", 1, true), "must not double-tag with out of range: " .. out)
end

function M.test_targetability_out_of_range_when_in_los_but_far()
    local attackerPlot = setupRangedScene({
        mode = InterfaceModeTypes.INTERFACEMODE_RANGE_ATTACK,
        losBlocked = false,
        maxX = 3,
    })
    selectArcher(attackerPlot, { range = 2 })
    Cursor.move(DirectionTypes.DIRECTION_EAST) -- (1,0): distance 1, in range
    Cursor.move(DirectionTypes.DIRECTION_EAST) -- (2,0): distance 2, in range
    local out = Cursor.move(DirectionTypes.DIRECTION_EAST) -- (3,0): distance 3 > range 2
    T.truthy(out:find("out of range", 1, true), "far in-LoS tile must speak out of range: " .. out)
    T.truthy(not out:find("unseen", 1, true), "must not tag unseen when LoS is clear: " .. out)
end

function M.test_targetability_no_prefix_when_in_los_and_in_range()
    local attackerPlot = setupRangedScene({
        mode = InterfaceModeTypes.INTERFACEMODE_RANGE_ATTACK,
        losBlocked = false,
    })
    selectArcher(attackerPlot)
    Cursor.move(DirectionTypes.DIRECTION_EAST)
    local out = Cursor.move(DirectionTypes.DIRECTION_EAST) -- (2,0): in LoS, in range
    T.truthy(not out:find("unseen", 1, true), "in-LoS in-range tile must not speak unseen: " .. out)
    T.truthy(not out:find("out of range", 1, true), "in-range tile must not speak out of range: " .. out)
end

function M.test_targetability_air_unit_skips_los_check()
    -- Air units bypass LoS via IsRangeAttackIgnoreLOS / DOMAIN_AIR -- a tile
    -- with geometric LoS blocked must still NOT prefix "unseen" for an air
    -- attacker. Distance is in range, so no prefix at all.
    local attackerPlot = setupRangedScene({
        mode = InterfaceModeTypes.INTERFACEMODE_AIRSTRIKE,
        losBlocked = true,
    })
    selectArcher(attackerPlot, { range = 8, domain = DomainTypes.DOMAIN_AIR })
    Cursor.move(DirectionTypes.DIRECTION_EAST)
    local out = Cursor.move(DirectionTypes.DIRECTION_EAST)
    T.truthy(not out:find("unseen", 1, true), "air attacker must not flag LoS-blocked tile as unseen: " .. out)
end

function M.test_targetability_no_prefix_when_not_in_ranged_mode()
    local attackerPlot = setupRangedScene({
        mode = InterfaceModeTypes.INTERFACEMODE_SELECTION,
        losBlocked = true,
    })
    selectArcher(attackerPlot)
    Cursor.move(DirectionTypes.DIRECTION_EAST)
    local out = Cursor.move(DirectionTypes.DIRECTION_EAST)
    T.truthy(not out:find("unseen", 1, true), "selection mode must not speak targetability: " .. out)
    T.truthy(not out:find("out of range", 1, true), "selection mode must not speak targetability: " .. out)
end

function M.test_targetability_skips_attackers_own_plot()
    -- Cursor on the attacker's tile: distance 0, trivially in range, LoS to
    -- self is true. No prefix even in ranged mode. Exercised via jumpTo so
    -- the cursor lands on (0,0) without needing a same-direction move.
    local attackerPlot = setupRangedScene({
        mode = InterfaceModeTypes.INTERFACEMODE_RANGE_ATTACK,
        losBlocked = true, -- would prefix unseen on any other plot
    })
    selectArcher(attackerPlot)
    Cursor.move(DirectionTypes.DIRECTION_EAST) -- step away first
    local out = Cursor.jumpTo(0, 0) -- jump back onto attacker plot
    T.truthy(not out:find("unseen", 1, true), "attacker own plot must not speak unseen: " .. out)
    T.truthy(not out:find("out of range", 1, true), "attacker own plot must not speak out of range: " .. out)
end

function M.test_targetability_skips_fogged_plot()
    -- A revealed-but-fogged tile already gets a "fog" marker from the glance
    -- composer; the targetability prefix must defer rather than double-tag.
    local attackerPlot = setupRangedScene({
        mode = InterfaceModeTypes.INTERFACEMODE_RANGE_ATTACK,
        losBlocked = true, -- would normally trigger unseen
        foggedAt = { 1 },
    })
    selectArcher(attackerPlot)
    local out = Cursor.move(DirectionTypes.DIRECTION_EAST)
    T.truthy(not out:find("unseen", 1, true), "fogged tile must defer to fog marker, not double-tag: " .. out)
end

function M.test_targetability_speaks_prefix_alone_on_featureless_plot()
    -- Empty-glance regression: a plot with no terrain / units / city / route
    -- (open ocean is the realistic case) yields glance = "" from the
    -- composer. If the owner identity is also stable, the targetability
    -- prefix is the only signal the player would otherwise hear -- it must
    -- not be silently dropped along with the empty glance.
    local attackerPlot = setupRangedScene({
        mode = InterfaceModeTypes.INTERFACEMODE_RANGE_ATTACK,
        losBlocked = true,
        featureless = true,
    })
    selectArcher(attackerPlot)
    Cursor.move(DirectionTypes.DIRECTION_EAST) -- (1,0): primes _lastOwnerIdentity
    local out = Cursor.move(DirectionTypes.DIRECTION_EAST) -- (2,0): same owner, empty glance
    T.truthy(out:find("unseen", 1, true), "featureless plot in ranged mode must still speak prefix: '" .. out .. "'")
end

function M.test_targetability_city_ranged_mode_uses_city_attacker()
    -- INTERFACEMODE_CITY_RANGE_ATTACK: attacker is the head-selected city,
    -- not a unit. LoS blocked from city plot must speak unseen.
    setup()
    Players[0] = T.fakePlayer({ team = 0 })
    GameInfo.Terrains[1] = { Description = "Plains" }
    local cityPlot = T.fakePlot({
        x = 0, y = 0, terrain = 1,
        canSeePlot = function()
            return false
        end,
    })
    local rome = T.fakeCity({ owner = 0, plot = cityPlot, range = 2 })
    cityPlot._city = rome
    cityPlot._isCity = true
    local stepPlot = T.fakePlot({ x = 1, y = 0, terrain = 1 })
    local targetPlot = T.fakePlot({ x = 2, y = 0, terrain = 1 })
    local plotByXY = { ["0,0"] = cityPlot, ["1,0"] = stepPlot, ["2,0"] = targetPlot }
    Map.GetPlot = function(x, y)
        return plotByXY[x .. "," .. y]
    end
    Map.PlotDirection = function(x, y, dir)
        if dir == DirectionTypes.DIRECTION_EAST then
            return plotByXY[(x + 1) .. "," .. y]
        end
        return nil
    end
    Map.PlotDistance = function(x1, y1, x2, y2)
        return math.max(math.abs(x1 - x2), math.abs(y1 - y2))
    end
    UI.GetInterfaceMode = function()
        return InterfaceModeTypes.INTERFACEMODE_CITY_RANGE_ATTACK
    end
    UI.GetHeadSelectedUnit = function()
        return nil
    end
    UI.GetHeadSelectedCity = function()
        return rome
    end
    -- Cursor.init falls back to the active player's capital when no unit
    -- is selected; wire Rome up as the capital so init lands on city plot.
    Players[0]._capital = rome
    Cursor.init()
    Cursor.move(DirectionTypes.DIRECTION_EAST) -- (1,0)
    local out = Cursor.move(DirectionTypes.DIRECTION_EAST) -- (2,0)
    T.truthy(out:find("unseen", 1, true), "city ranged mode with LoS-blocked target must speak unseen: " .. out)
end

function M.test_activate_major_out_of_turn_is_silent()
    setup()
    installActivateStubs()
    Game.GetActivePlayer = function()
        return 0
    end
    Game.GetActiveTeam = function()
        return 0
    end
    Teams[0] = T.fakeTeam({ hasMet = { [1] = true } })
    Players[0] = makePlayer({ team = 0, isTurnActive = false })
    Players[1] = makePlayer({ team = 1, isMinor = false, isHuman = false })
    local city = makeCity({ owner = 1 })
    local plot = T.fakePlot({ x = 0, y = 0, isCity = true, city = city, owner = 1 })
    primeCursor(plot)
    Cursor.activate()
    T.eq(#activateCalls, 0, "out-of-turn activation on major civ city must not fire diplo")
end

return M
