-- Per-backend bucket-decision tests. Each backend converts flag/enum
-- inputs (Domain, UnitCombat, ResourceUsage, owner stance, NaturalWonder,
-- goody-hut improvement constant) into a subcategory string; a silent
-- misbucket here is one of the few scanner bugs that no other suite
-- would catch because it still produces well-formed entries, just in
-- the wrong slot.

local T = require("support")
local M = {}

-- ===== Shared fixtures =====
local function resetScanner()
    ScannerCore = nil
    dofile("src/dlc/UI/InGame/CivVAccess_ScannerCore.lua")
end

local function loadModule(path)
    dofile(path)
end

local function mapFromPlots(plots)
    Map.GetNumPlots = function()
        return #plots
    end
    Map.GetPlotByIndex = function(i)
        return plots[i + 1]
    end
end

local function setup()
    resetScanner()
    Log.warn = function() end
    Log.error = function() end
    Players = {}
    Teams = { [0] = T.fakeTeam() }
    Game.GetActivePlayer = function()
        return 0
    end
    Game.GetActiveTeam = function()
        return 0
    end
    Game.IsDebugMode = function()
        return false
    end
    GameInfo = {}
    GameInfoTypes = {}
    Text = Text or {}
    Text.key = function(k)
        return k
    end
    Text.format = function(k)
        return k
    end
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
end

-- ===== Units backend =====

local function loadUnitsBackend()
    loadModule("src/dlc/UI/InGame/CivVAccess_ScannerBackendUnits.lua")
end

-- Build a unit fixture with enough surface to satisfy the backend's
-- classification path. `combatType` is the string used in GameInfo.UnitCombatInfos.
local function makeUnit(opts)
    opts = opts or {}
    local u = {}
    function u:GetID()
        return opts.id or 1
    end
    function u:GetOwner()
        return opts.owner or 0
    end
    function u:IsInvisible(_, _)
        return opts.invisible or false
    end
    function u:IsCombatUnit()
        return opts.combat ~= false
    end
    function u:GetDomainType()
        return opts.domain or DomainTypes.DOMAIN_LAND
    end
    function u:GetUnitCombatType()
        return opts.combatId or -1
    end
    function u:GetSpecialUnitType()
        return opts.specialUnit or -1
    end
    function u:GetUnitType()
        return opts.unitType or 42
    end
    function u:IsDead()
        return false
    end
    function u:GetPlot()
        return opts.plot
    end
    return u
end

local function makePlotAt(x, y, idx, opts)
    opts = opts or {}
    opts.x = x
    opts.y = y
    opts.plotIndex = idx
    return T.fakePlot(opts)
end

-- Install a Players table so a unit at the active player shows up in Scan.
local function installPlayer(playerId, unitList, opts)
    opts = opts or {}
    local p = {
        _alive = true,
        _barb = opts.barb or false,
        _team = opts.team or 0,
        _units = unitList,
    }
    function p:IsAlive()
        return self._alive
    end
    function p:IsBarbarian()
        return self._barb
    end
    function p:GetTeam()
        return self._team
    end
    function p:Units()
        local i = 0
        return function()
            i = i + 1
            return self._units[i]
        end
    end
    function p:GetUnitByID(id)
        for _, u in ipairs(self._units) do
            if u:GetID() == id then
                return u
            end
        end
        return nil
    end
    Players[playerId] = p
end

local function runUnitsScan()
    return ScannerBackendUnits.Scan(0, 0)
end

local function classifyLandCombat(combatType, combatId)
    GameInfo.UnitCombatInfos = { [combatId] = { Type = combatType } }
    GameInfo.Units = { [42] = { Description = "TXT_KEY_UNIT_X" } }
    local plot = makePlotAt(0, 0, 0)
    local u = makeUnit({ combatId = combatId, domain = DomainTypes.DOMAIN_LAND, plot = plot })
    installPlayer(0, { u })
    Map.GetNumPlots = function()
        return 1
    end
    Map.GetPlotByIndex = function(i)
        return i == 0 and plot or nil
    end
    local out = runUnitsScan()
    T.eq(#out, 1, combatType .. " should produce one entry")
    return out[1].subcategory
end

function M.test_unit_role_melee_gun_armor_recon_all_melee()
    setup()
    loadUnitsBackend()
    T.eq(classifyLandCombat("UNITCOMBAT_MELEE", 1), "melee")
    setup()
    loadUnitsBackend()
    T.eq(classifyLandCombat("UNITCOMBAT_GUN", 2), "melee")
    setup()
    loadUnitsBackend()
    T.eq(classifyLandCombat("UNITCOMBAT_ARMOR", 3), "melee")
    setup()
    loadUnitsBackend()
    T.eq(classifyLandCombat("UNITCOMBAT_RECON", 4), "melee", "RECON folds into Melee for v1 per design section 2")
end

function M.test_unit_role_archer_is_ranged()
    setup()
    loadUnitsBackend()
    T.eq(classifyLandCombat("UNITCOMBAT_ARCHER", 5), "ranged")
end

function M.test_unit_role_siege()
    setup()
    loadUnitsBackend()
    T.eq(classifyLandCombat("UNITCOMBAT_SIEGE", 6), "siege")
end

function M.test_unit_role_mounted_and_helicopter_share_sub()
    setup()
    loadUnitsBackend()
    T.eq(classifyLandCombat("UNITCOMBAT_MOUNTED", 7), "mounted")
    setup()
    loadUnitsBackend()
    T.eq(classifyLandCombat("UNITCOMBAT_HELICOPTER", 8), "mounted")
end

function M.test_unit_role_naval_from_domain_not_combat()
    -- Naval sub keys off Domain so base + expansion combat-class splits
    -- (NAVALMELEE/NAVALRANGED/SUBMARINE/CARRIER) collapse into one bucket.
    setup()
    loadUnitsBackend()
    GameInfo.UnitCombatInfos = {}
    GameInfo.Units = { [42] = { Description = "TXT_KEY_UNIT_TRIREME" } }
    local plot = makePlotAt(0, 0, 0)
    local u = makeUnit({ domain = DomainTypes.DOMAIN_SEA, combatId = -1, plot = plot })
    installPlayer(0, { u })
    mapFromPlots({ plot })
    local out = runUnitsScan()
    T.eq(out[1].subcategory, "naval")
end

function M.test_unit_role_air_from_domain()
    setup()
    loadUnitsBackend()
    GameInfo.Units = { [42] = { Description = "TXT_KEY_UNIT_FIGHTER" } }
    local plot = makePlotAt(0, 0, 0)
    local u = makeUnit({ domain = DomainTypes.DOMAIN_AIR, plot = plot })
    installPlayer(0, { u })
    mapFromPlots({ plot })
    T.eq(runUnitsScan()[1].subcategory, "air")
end

function M.test_unit_role_civilian_when_not_combat()
    setup()
    loadUnitsBackend()
    GameInfo.Units = { [42] = { Description = "TXT_KEY_UNIT_WORKER" } }
    local plot = makePlotAt(0, 0, 0)
    local u = makeUnit({ combat = false, plot = plot })
    installPlayer(0, { u })
    mapFromPlots({ plot })
    T.eq(runUnitsScan()[1].subcategory, "civilian")
end

function M.test_unit_role_great_people_beats_civilian()
    -- Both match IsCombatUnit == false. Great People is more specific and
    -- must be checked first.
    setup()
    loadUnitsBackend()
    GameInfoTypes.SPECIALUNIT_PEOPLE = 1
    GameInfo.Units = { [42] = { Description = "TXT_KEY_UNIT_GREAT_SCIENTIST" } }
    local plot = makePlotAt(0, 0, 0)
    local u = makeUnit({ combat = false, specialUnit = 1, plot = plot })
    installPlayer(0, { u })
    mapFromPlots({ plot })
    T.eq(runUnitsScan()[1].subcategory, "great_people")
end

function M.test_unit_owner_category_routes_by_team_stance()
    -- Three players: active (own), peace, war. Each owns one combat unit.
    -- All three categories should appear with the correct sub.
    setup()
    loadUnitsBackend()
    GameInfo.UnitCombatInfos = { [1] = { Type = "UNITCOMBAT_MELEE" } }
    GameInfo.Units = { [42] = { Description = "TXT_KEY_UNIT_WARRIOR" } }
    Teams[0] = T.fakeTeam({ atWar = { [2] = true } })
    local p1 = makePlotAt(0, 0, 0)
    local p2 = makePlotAt(1, 0, 1)
    local p3 = makePlotAt(2, 0, 2)
    installPlayer(0, { makeUnit({ id = 10, owner = 0, combatId = 1, plot = p1 }) }, { team = 0 })
    installPlayer(1, { makeUnit({ id = 11, owner = 1, combatId = 1, plot = p2 }) }, { team = 1 })
    installPlayer(2, { makeUnit({ id = 12, owner = 2, combatId = 1, plot = p3 }) }, { team = 2 })
    mapFromPlots({ p1, p2, p3 })
    local out = runUnitsScan()
    local byCat = {}
    for _, e in ipairs(out) do
        byCat[e.category] = true
    end
    T.truthy(byCat["units_my"], "own unit must go to units_my")
    T.truthy(byCat["units_neutral"], "peace unit must go to units_neutral")
    T.truthy(byCat["units_enemy"], "war unit must go to units_enemy")
end

function M.test_unit_barbarian_routes_to_enemy_with_barbarians_sub()
    setup()
    loadUnitsBackend()
    GameInfo.UnitCombatInfos = { [1] = { Type = "UNITCOMBAT_MELEE" } }
    GameInfo.Units = { [42] = { Description = "TXT_KEY_UNIT_WARRIOR" } }
    local plot = makePlotAt(0, 0, 0)
    installPlayer(0, {}, { team = 0 }) -- active player, no units
    installPlayer(63, { makeUnit({ id = 99, owner = 63, combatId = 1, plot = plot }) }, { team = 63, barb = true })
    mapFromPlots({ plot })
    local out = runUnitsScan()
    T.eq(#out, 1)
    T.eq(out[1].category, "units_enemy")
    T.eq(out[1].subcategory, "barbarians", "barb units must land in the barbarians sub, not a role sub")
end

function M.test_unit_invisible_unit_excluded()
    -- The engine hides invisible enemy units from the active team; the
    -- scanner must not leak their presence.
    setup()
    loadUnitsBackend()
    GameInfo.UnitCombatInfos = { [1] = { Type = "UNITCOMBAT_MELEE" } }
    GameInfo.Units = { [42] = { Description = "TXT_KEY_UNIT_SUBMARINE" } }
    local plot = makePlotAt(0, 0, 0)
    Teams[0] = T.fakeTeam({ atWar = { [2] = true } })
    installPlayer(2, { makeUnit({ id = 77, owner = 2, combatId = 1, plot = plot, invisible = true }) }, { team = 2 })
    mapFromPlots({ plot })
    T.eq(#runUnitsScan(), 0, "invisible enemy unit must not appear in Scan output")
end

-- ===== Resources backend =====

local function loadResourcesBackend()
    loadModule("src/dlc/UI/InGame/CivVAccess_ScannerBackendResources.lua")
end

function M.test_resource_usage_to_subcategory()
    setup()
    loadResourcesBackend()
    GameInfo.Resources = {
        [1] = { Description = "TXT_KEY_RESOURCE_IRON", ResourceUsage = 1 },
        [2] = { Description = "TXT_KEY_RESOURCE_GOLD", ResourceUsage = 2 },
        [3] = { Description = "TXT_KEY_RESOURCE_WHEAT", ResourceUsage = 0 },
    }
    local p1 = makePlotAt(0, 0, 0, { resource = 1 })
    local p2 = makePlotAt(1, 0, 1, { resource = 2 })
    local p3 = makePlotAt(2, 0, 2, { resource = 3 })
    mapFromPlots({ p1, p2, p3 })
    local out = ScannerBackendResources.Scan(0, 0)
    T.eq(#out, 3)
    local bySub = {}
    for _, e in ipairs(out) do
        bySub[e.subcategory] = e
    end
    T.eq(bySub.strategic.data.resourceId, 1)
    T.eq(bySub.luxury.data.resourceId, 2)
    T.eq(bySub.bonus.data.resourceId, 3)
end

function M.test_resource_neg_one_skipped()
    -- -1 from GetResourceType is the tech gate (strategic present but
    -- reveal tech not researched yet, e.g. Iron before BW). Must skip.
    setup()
    loadResourcesBackend()
    GameInfo.Resources = {}
    local p = makePlotAt(0, 0, 0, { resource = -1 })
    mapFromPlots({ p })
    T.eq(#ScannerBackendResources.Scan(0, 0), 0)
end

function M.test_resource_unrevealed_plot_skipped()
    -- Fog-of-war gate is a separate plot:IsRevealed check, not folded
    -- into GetResourceType. Without this, the scanner enumerates every
    -- resource on the map regardless of exploration state.
    setup()
    loadResourcesBackend()
    GameInfo.Resources = {
        [1] = { Description = "TXT_KEY_RESOURCE_IRON", ResourceUsage = 1 },
    }
    local revealed = makePlotAt(0, 0, 0, { resource = 1, revealed = true })
    local hidden = makePlotAt(1, 0, 1, { resource = 1, revealed = false })
    mapFromPlots({ revealed, hidden })
    local out = ScannerBackendResources.Scan(0, 0)
    T.eq(#out, 1, "only the revealed plot should produce an entry")
    T.eq(out[1].plotIndex, 0)
end

-- ===== Improvements backend =====

local function loadImprovementsBackend()
    loadModule("src/dlc/UI/InGame/CivVAccess_ScannerBackendImprovements.lua")
end

local function impPlot(x, y, idx, impId, owner)
    local p = makePlotAt(x, y, idx, { improvement = impId, owner = owner })
    -- The backend calls plot:GetRevealedOwner(activeTeam, isDebug); fakePlot
    -- only stores _owner, so reuse that for both getters.
    function p:GetRevealedOwner()
        return self._owner
    end
    return p
end

function M.test_improvement_owner_routes_to_three_subs()
    setup()
    loadImprovementsBackend()
    GameInfoTypes.IMPROVEMENT_BARBARIAN_CAMP = -1
    GameInfoTypes.IMPROVEMENT_GOODY_HUT = -1
    GameInfo.Improvements = {
        [5] = { Description = "TXT_KEY_IMPROVEMENT_FARM" },
    }
    Teams[0] = T.fakeTeam({ atWar = { [2] = true } })
    local function mkTeamPlayer(teamId)
        local p = { _team = teamId }
        function p:GetTeam()
            return self._team
        end
        return p
    end
    Players[0] = mkTeamPlayer(0)
    Players[1] = mkTeamPlayer(1)
    Players[2] = mkTeamPlayer(2)
    local mine = impPlot(0, 0, 0, 5, 0)
    local neutral = impPlot(1, 0, 1, 5, 1)
    local enemy = impPlot(2, 0, 2, 5, 2)
    mapFromPlots({ mine, neutral, enemy })
    local out = ScannerBackendImprovements.Scan(0, 0)
    local byOwner = {}
    for _, e in ipairs(out) do
        byOwner[e.data.ownerId] = e.subcategory
    end
    T.eq(byOwner[0], "my")
    T.eq(byOwner[1], "neutral")
    T.eq(byOwner[2], "enemy")
end

function M.test_improvement_unowned_routes_neutral()
    -- Forts in no-man's-land have RevealedOwner == -1. Per design they
    -- land in Neutral so they still surface somewhere.
    setup()
    loadImprovementsBackend()
    GameInfoTypes.IMPROVEMENT_BARBARIAN_CAMP = -1
    GameInfoTypes.IMPROVEMENT_GOODY_HUT = -1
    GameInfo.Improvements = {
        [9] = { Description = "TXT_KEY_IMPROVEMENT_FORT" },
    }
    local fort = impPlot(0, 0, 0, 9, -1)
    mapFromPlots({ fort })
    local out = ScannerBackendImprovements.Scan(0, 0)
    T.eq(#out, 1)
    T.eq(out[1].subcategory, "neutral")
end

function M.test_improvement_skips_barb_camp_and_goody_hut()
    -- Those live under Cities / Special respectively.
    setup()
    loadImprovementsBackend()
    GameInfoTypes.IMPROVEMENT_BARBARIAN_CAMP = 11
    GameInfoTypes.IMPROVEMENT_GOODY_HUT = 12
    GameInfo.Improvements = {
        [11] = { Description = "TXT_KEY_IMPROVEMENT_BARBARIAN_CAMP" },
        [12] = { Description = "TXT_KEY_IMPROVEMENT_GOODY_HUT" },
    }
    local camp = impPlot(0, 0, 0, 11, -1)
    local hut = impPlot(1, 0, 1, 12, -1)
    mapFromPlots({ camp, hut })
    T.eq(#ScannerBackendImprovements.Scan(0, 0), 0, "camp/hut are someone else's turf and must not double-emit here")
end

-- ===== Special backend =====

local function loadSpecialBackend()
    loadModule("src/dlc/UI/InGame/CivVAccess_ScannerBackendSpecial.lua")
end

function M.test_special_natural_wonder_by_flag()
    setup()
    loadSpecialBackend()
    GameInfo.Features = {
        [3] = { Description = "TXT_KEY_FEATURE_FUJI", NaturalWonder = true },
        [4] = { Description = "TXT_KEY_FEATURE_JUNGLE", NaturalWonder = false },
    }
    -- Intentionally leave GameInfoTypes.IMPROVEMENT_GOODY_HUT unset so
    -- the goody-hut branch is short-circuited; both fixture plots default
    -- their improvement to -1, which would collide with a goody-hut id of
    -- -1 and produce spurious ancient-ruin entries.
    local nw = makePlotAt(0, 0, 0, { feature = 3 })
    local junk = makePlotAt(1, 0, 1, { feature = 4 })
    mapFromPlots({ nw, junk })
    local out = ScannerBackendSpecial.Scan(0, 0)
    T.eq(#out, 1, "only the NaturalWonder=true feature should emit")
    T.eq(out[1].subcategory, "natural_wonders")
    T.eq(out[1].data.featureId, 3)
end

function M.test_special_ancient_ruin_by_goody_hut_improvement()
    setup()
    loadSpecialBackend()
    GameInfo.Features = {}
    GameInfoTypes.IMPROVEMENT_GOODY_HUT = 7
    local ruin = makePlotAt(5, 5, 0, { improvement = 7 })
    mapFromPlots({ ruin })
    local out = ScannerBackendSpecial.Scan(0, 0)
    T.eq(#out, 1)
    T.eq(out[1].subcategory, "ancient_ruins")
end

function M.test_special_unrevealed_plots_skipped()
    -- Fog-of-war gate: a ruin behind fog would leak its existence if we
    -- emitted it.
    setup()
    loadSpecialBackend()
    GameInfo.Features = {}
    GameInfoTypes.IMPROVEMENT_GOODY_HUT = 7
    local hidden = makePlotAt(0, 0, 0, { improvement = 7, revealed = false })
    mapFromPlots({ hidden })
    T.eq(#ScannerBackendSpecial.Scan(0, 0), 0)
end

-- ===== Terrain backend =====

local function loadTerrainBackend()
    loadModule("src/dlc/UI/InGame/CivVAccess_ScannerBackendTerrain.lua")
end

local function subsFromEntries(entries)
    local bySub = {}
    for _, e in ipairs(entries) do
        bySub[e.subcategory] = bySub[e.subcategory] or {}
        bySub[e.subcategory][#bySub[e.subcategory] + 1] = e
    end
    return bySub
end

function M.test_terrain_plain_plot_emits_base_only()
    setup()
    loadTerrainBackend()
    GameInfo.Terrains = { [1] = { Description = "TXT_KEY_TERRAIN_GRASS" } }
    GameInfo.Features = {}
    local plot = makePlotAt(0, 0, 0, { terrain = 1 })
    mapFromPlots({ plot })
    local out = ScannerBackendTerrain.Scan(0, 0)
    T.eq(#out, 1, "grass plot with no feature and no elevation emits one base entry")
    T.eq(out[1].category, "terrain")
    T.eq(out[1].subcategory, "base")
    T.eq(out[1].data.terrainId, 1)
end

function M.test_terrain_feature_adds_feature_entry()
    setup()
    loadTerrainBackend()
    GameInfo.Terrains = { [1] = { Description = "TXT_KEY_TERRAIN_GRASS" } }
    GameInfo.Features = { [3] = { Description = "TXT_KEY_FEATURE_FOREST" } }
    local plot = makePlotAt(0, 0, 0, { terrain = 1, feature = 3 })
    mapFromPlots({ plot })
    local bySub = subsFromEntries(ScannerBackendTerrain.Scan(0, 0))
    T.truthy(bySub.base, "base entry must still fire")
    T.truthy(bySub.features, "feature entry must fire alongside base")
    T.eq(bySub.features[1].data.featureId, 3)
end

function M.test_terrain_hills_emit_elevation()
    setup()
    loadTerrainBackend()
    GameInfo.Terrains = { [1] = { Description = "TXT_KEY_TERRAIN_GRASS" } }
    GameInfo.Features = {}
    local plot = makePlotAt(0, 0, 0, { terrain = 1, hills = true })
    mapFromPlots({ plot })
    local bySub = subsFromEntries(ScannerBackendTerrain.Scan(0, 0))
    T.truthy(bySub.base, "hill still emits the underlying base terrain")
    T.truthy(bySub.elevation, "hill must emit under elevation")
    T.eq(bySub.elevation[1].data.kind, "hills")
end

function M.test_terrain_mountain_emits_elevation()
    setup()
    loadTerrainBackend()
    GameInfo.Terrains = { [7] = { Description = "TXT_KEY_TERRAIN_MOUNTAIN" } }
    GameInfo.Features = {}
    local plot = makePlotAt(0, 0, 0, { terrain = 7, mountain = true })
    mapFromPlots({ plot })
    local bySub = subsFromEntries(ScannerBackendTerrain.Scan(0, 0))
    -- Mountain plot has TERRAIN_MOUNTAIN, so base fires with that terrain row
    -- AND elevation fires as kind=mountain. The intentional double-list.
    T.truthy(bySub.base, "mountain plot's TERRAIN_MOUNTAIN row still emits under base")
    T.truthy(bySub.elevation, "mountain must emit under elevation")
    T.eq(bySub.elevation[1].data.kind, "mountain")
end

function M.test_terrain_forested_hill_triple_emits()
    -- A forested hill produces base (grass) + features (forest) + elevation
    -- (hills). This is the headline triple-list case from the design.
    setup()
    loadTerrainBackend()
    GameInfo.Terrains = { [1] = { Description = "TXT_KEY_TERRAIN_GRASS" } }
    GameInfo.Features = { [3] = { Description = "TXT_KEY_FEATURE_FOREST" } }
    local plot = makePlotAt(0, 0, 0, { terrain = 1, feature = 3, hills = true })
    mapFromPlots({ plot })
    local bySub = subsFromEntries(ScannerBackendTerrain.Scan(0, 0))
    T.truthy(bySub.base, "base fires")
    T.truthy(bySub.features, "features fires")
    T.truthy(bySub.elevation, "elevation fires")
    T.eq(#bySub.base, 1)
    T.eq(#bySub.features, 1)
    T.eq(#bySub.elevation, 1)
end

function M.test_terrain_validate_feature_goes_stale_when_chopped()
    -- A forest entry from an earlier snapshot must invalidate once a
    -- worker chops the forest. GetFeatureType returns -1 on a plot
    -- with no feature, so the equality check in ValidateEntry catches
    -- it. No other test exercises ValidateEntry on this backend, and
    -- feature removal (forest, marsh, fallout) is the plausible mid-
    -- snapshot drift this backend has to handle.
    setup()
    loadTerrainBackend()
    local plot = makePlotAt(0, 0, 0, { feature = -1 })
    mapFromPlots({ plot })
    local staleEntry = {
        plotIndex = 0,
        backend = ScannerBackendTerrain,
        data = { kind = "feature", featureId = 3 },
        category = "terrain",
        subcategory = "features",
        itemName = "TXT_KEY_FEATURE_FOREST",
        sortKey = 0,
    }
    T.falsy(ScannerBackendTerrain.ValidateEntry(staleEntry, nil), "chopped forest entry must fail validation")
end

function M.test_terrain_validate_returns_true_when_state_unchanged()
    -- Pin the happy path: a terrain / feature / elevation entry whose
    -- plot still matches keeps returning true across cycles, or every
    -- cursor step would silently prune live entries.
    setup()
    loadTerrainBackend()
    local plot = makePlotAt(0, 0, 0, { terrain = 1, feature = 3, hills = true })
    mapFromPlots({ plot })
    local function entry(kind, extra)
        local e = {
            plotIndex = 0,
            backend = ScannerBackendTerrain,
            data = { kind = kind },
            category = "terrain",
            subcategory = kind == "base" and "base" or (kind == "feature" and "features" or "elevation"),
            itemName = "x",
            sortKey = 0,
        }
        for k, v in pairs(extra or {}) do
            e.data[k] = v
        end
        return e
    end
    T.truthy(ScannerBackendTerrain.ValidateEntry(entry("base", { terrainId = 1 })))
    T.truthy(ScannerBackendTerrain.ValidateEntry(entry("feature", { featureId = 3 })))
    T.truthy(ScannerBackendTerrain.ValidateEntry(entry("hills")))
end

function M.test_terrain_unrevealed_plot_skipped()
    -- Fog-of-war gate: every other plot-iterating backend honours this
    -- and the terrain backend must too, or a player sees the entire map
    -- laid out as soon as any game starts.
    setup()
    loadTerrainBackend()
    GameInfo.Terrains = { [1] = { Description = "TXT_KEY_TERRAIN_GRASS" } }
    GameInfo.Features = {}
    local hidden = makePlotAt(0, 0, 0, { terrain = 1, revealed = false })
    mapFromPlots({ hidden })
    T.eq(#ScannerBackendTerrain.Scan(0, 0), 0, "nothing emits from a fogged plot")
end

return M
