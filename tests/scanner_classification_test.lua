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
    function u:IsTrade()
        return opts.trade or false
    end
    function u:GetTeam()
        return opts.team or 0
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
    function u:GetReligion()
        return opts.religion or ReligionTypes.NO_RELIGION
    end
    function u:HasName()
        return opts.personalName ~= nil and opts.personalName ~= ""
    end
    function u:GetNameNoDesc()
        return opts.personalName or ""
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
    Players[playerId] = T.fakePlayer({
        alive = true,
        barb = opts.barb,
        team = opts.team or 0,
        units = unitList,
        adj = opts.adjKey or "TXT_KEY_CIV_ADJECTIVE_FIXTURE",
    })
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
    -- Four players: active (own), teammate (same team, different player),
    -- peace, war. Each owns one combat unit. All four categories should
    -- appear with the correct sub.
    setup()
    loadUnitsBackend()
    GameInfo.UnitCombatInfos = { [1] = { Type = "UNITCOMBAT_MELEE" } }
    GameInfo.Units = { [42] = { Description = "TXT_KEY_UNIT_WARRIOR" } }
    Teams[0] = T.fakeTeam({ atWar = { [2] = true } })
    local p1 = makePlotAt(0, 0, 0)
    local p2 = makePlotAt(1, 0, 1)
    local p3 = makePlotAt(2, 0, 2)
    local p4 = makePlotAt(3, 0, 3)
    installPlayer(0, { makeUnit({ id = 10, owner = 0, combatId = 1, plot = p1 }) }, { team = 0 })
    installPlayer(1, { makeUnit({ id = 11, owner = 1, combatId = 1, plot = p2 }) }, { team = 1 })
    installPlayer(2, { makeUnit({ id = 12, owner = 2, combatId = 1, plot = p3 }) }, { team = 2 })
    installPlayer(3, { makeUnit({ id = 13, owner = 3, combatId = 1, plot = p4 }) }, { team = 0 })
    mapFromPlots({ p1, p2, p3, p4 })
    local out = runUnitsScan()
    local byCat = {}
    for _, e in ipairs(out) do
        byCat[e.category] = true
    end
    T.truthy(byCat["units_my"], "own unit must go to units_my")
    T.truthy(byCat["units_teammate"], "same-team different-player unit must go to units_teammate")
    T.truthy(byCat["units_neutral"], "peace unit must go to units_neutral")
    T.truthy(byCat["units_enemy"], "war unit must go to units_enemy")
end

function M.test_unit_teammate_carries_civ_adjective()
    -- Teammate units belong to a distinct civ from the active player's
    -- (same-team play pairs different civs). The civ adjective must lead
    -- the type word like for any non-own unit, so the user can tell
    -- whose forces they're cycling through within the teammate bucket.
    setup()
    loadUnitsBackend()
    GameInfo.UnitCombatInfos = { [1] = { Type = "UNITCOMBAT_MELEE" } }
    GameInfo.Units = { [42] = { Description = "Warrior" } }
    local plot = makePlotAt(0, 0, 0)
    installPlayer(0, {}, { team = 0 })
    installPlayer(
        1,
        { makeUnit({ id = 11, owner = 1, combatId = 1, plot = plot }) },
        { team = 0, adjKey = "TXT_KEY_CIV_ROME_ADJECTIVE" }
    )
    mapFromPlots({ plot })
    local origConvert = Locale.ConvertTextKey
    Locale.ConvertTextKey = function(key)
        if key == "TXT_KEY_CIV_ROME_ADJECTIVE" then
            return "Roman"
        end
        return origConvert and origConvert(key) or key
    end
    local out = runUnitsScan()
    Locale.ConvertTextKey = origConvert
    T.eq(#out, 1)
    T.eq(out[1].category, "units_teammate")
    T.eq(out[1].itemName, "Roman Warrior", "teammate unit must carry the civ adjective like any non-own unit")
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

function M.test_unit_religious_unit_surfaces_religion_in_own_item_name()
    -- Own missionaries / inquisitors / great prophets keep the bare
    -- description for the type word but prepend the religion stamp so
    -- captured units of a foreign religion don't collapse with bought
    -- units of the player's own religion in the scanner list.
    setup()
    loadUnitsBackend()
    GameInfo.Units = { [42] = { Description = "Missionary" } }
    Game.GetReligionName = function(_e)
        return "Buddhism"
    end
    local plot = makePlotAt(0, 0, 0)
    local missionary = makeUnit({ id = 1, owner = 0, combat = false, plot = plot, religion = 7 })
    installPlayer(0, { missionary }, { team = 0 })
    mapFromPlots({ plot })
    local out = runUnitsScan()
    T.eq(#out, 1)
    T.eq(out[1].category, "units_my")
    T.eq(out[1].itemName, "Buddhism Missionary", "religion must lead the type word for own religious units")
end

function M.test_unit_religious_unit_surfaces_religion_with_civ_for_other_player()
    -- Foreign religious units already carry the civ adjective for owner
    -- disambiguation; religion sits between the adjective and the type
    -- word so the form reads "Roman Buddhism Missionary".
    setup()
    loadUnitsBackend()
    GameInfo.Units = { [42] = { Description = "Missionary" } }
    Game.GetReligionName = function(_e)
        return "Buddhism"
    end
    Teams[0] = T.fakeTeam({ atWar = { [1] = true } })
    local plot = makePlotAt(0, 0, 0)
    installPlayer(0, {}, { team = 0 })
    installPlayer(
        1,
        { makeUnit({ id = 11, owner = 1, combat = false, plot = plot, religion = 7 }) },
        { team = 1, adjKey = "TXT_KEY_CIV_ROME_ADJECTIVE" }
    )
    mapFromPlots({ plot })
    local origConvert = Locale.ConvertTextKey
    Locale.ConvertTextKey = function(key)
        if key == "TXT_KEY_CIV_ROME_ADJECTIVE" then
            return "Roman"
        end
        return origConvert and origConvert(key) or key
    end
    local out = runUnitsScan()
    Locale.ConvertTextKey = origConvert
    T.eq(#out, 1)
    T.eq(out[1].category, "units_enemy")
    T.eq(
        out[1].itemName,
        "Roman Buddhism Missionary",
        "religion must sit between civ adj and type word for foreign religious units"
    )
end

function M.test_unit_named_unit_wraps_type_form_in_parens_for_own()
    -- A renamed own unit (Alt+N or great-general pool entry) keeps the
    -- bare type form for the parenthetical because units_my already
    -- disambiguates owner. Personal name leads so a search for the
    -- personal name lands at TypeAheadSearch tier 0.
    setup()
    loadUnitsBackend()
    GameInfo.UnitCombatInfos = {}
    GameInfo.Units = { [42] = { Description = "Great General" } }
    GameInfoTypes.SPECIALUNIT_PEOPLE = 1
    local plot = makePlotAt(0, 0, 0)
    local u = makeUnit({ id = 1, owner = 0, combat = false, specialUnit = 1, plot = plot, personalName = "Beowulf" })
    installPlayer(0, { u }, { team = 0 })
    mapFromPlots({ plot })
    local out = runUnitsScan()
    T.eq(#out, 1)
    T.eq(out[1].itemName, "Beowulf (Great General)", "personal name leads with type form in parens for own units")
end

function M.test_unit_named_unit_wraps_civ_typed_form_for_foreign()
    -- Foreign named units carry the civ adjective inside the parens; the
    -- personal name still leads so it remains the start-of-string search
    -- match.
    setup()
    loadUnitsBackend()
    GameInfo.UnitCombatInfos = {}
    GameInfo.Units = { [42] = { Description = "Great General" } }
    GameInfoTypes.SPECIALUNIT_PEOPLE = 1
    Teams[0] = T.fakeTeam({ atWar = { [1] = true } })
    local plot = makePlotAt(0, 0, 0)
    installPlayer(0, {}, { team = 0 })
    installPlayer(
        1,
        { makeUnit({ id = 1, owner = 1, combat = false, specialUnit = 1, plot = plot, personalName = "Tomyris" }) },
        { team = 1, adjKey = "TXT_KEY_CIV_PERSIA_ADJECTIVE" }
    )
    mapFromPlots({ plot })
    local origConvert = Locale.ConvertTextKey
    Locale.ConvertTextKey = function(key)
        if key == "TXT_KEY_CIV_PERSIA_ADJECTIVE" then
            return "Persian"
        end
        return origConvert and origConvert(key) or key
    end
    local out = runUnitsScan()
    Locale.ConvertTextKey = origConvert
    T.eq(#out, 1)
    T.eq(
        out[1].itemName,
        "Tomyris (Persian Great General)",
        "foreign named unit must wrap civ-prefixed type form in parens after the personal name"
    )
end

function M.test_unit_no_religion_keeps_bare_form()
    -- Non-religious units (and religious units with no stamp -- e.g. a
    -- prophet from a city without a real-religion majority) must keep the
    -- existing name shape unchanged.
    setup()
    loadUnitsBackend()
    GameInfo.UnitCombatInfos = { [1] = { Type = "UNITCOMBAT_MELEE" } }
    GameInfo.Units = { [42] = { Description = "Warrior" } }
    local plot = makePlotAt(0, 0, 0)
    installPlayer(0, { makeUnit({ id = 1, owner = 0, combatId = 1, plot = plot }) }, { team = 0 })
    mapFromPlots({ plot })
    local out = runUnitsScan()
    T.eq(#out, 1)
    T.eq(out[1].itemName, "Warrior", "non-religious unit name must be unchanged")
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

function M.test_unit_own_trade_unit_surfaces_on_fogged_plot()
    -- Trade units skip changeAdjacentSight in the engine (canChangeVisibility
    -- returns false for non-default map layers) so a player's own caravan can
    -- sit on a fogged plot. Sighted players still see the unit through the
    -- trade visuals system; the scanner mirrors that by accepting an own-team
    -- trade unit on a fogged-but-revealed plot.
    setup()
    loadUnitsBackend()
    GameInfo.Units = { [42] = { Description = "TXT_KEY_UNIT_CARAVAN" } }
    local fogged = makePlotAt(0, 0, 0, { revealed = true, visible = false })
    local caravan = makeUnit({
        id = 1,
        owner = 0,
        team = 0,
        combat = false,
        trade = true,
        plot = fogged,
    })
    installPlayer(0, { caravan }, { team = 0 })
    mapFromPlots({ fogged })
    local out = runUnitsScan()
    T.eq(#out, 1, "own-team trade unit must surface on fogged plot")
    T.eq(out[1].category, "units_my")
    T.eq(out[1].subcategory, "civilian", "trade units bucket as civilian (no combat strength)")
end

function M.test_unit_teammate_trade_unit_stays_hidden_on_fogged_plot()
    -- The trade-visuals layer is keyed on m_eOriginOwner (the route's
    -- player slot, not their team) in CvGameTrade::CreateVis, so a
    -- teammate's caravan on a plot fogged to the active team isn't
    -- rendered to the active player either. The fogged-plot carve-out
    -- is own-only, not active-team.
    setup()
    loadUnitsBackend()
    GameInfo.Units = { [42] = { Description = "TXT_KEY_UNIT_CARAVAN" } }
    local fogged = makePlotAt(0, 0, 0, { revealed = true, visible = false })
    local teammateCaravan = makeUnit({
        id = 1,
        owner = 1,
        team = 0,
        combat = false,
        trade = true,
        plot = fogged,
    })
    installPlayer(0, {}, { team = 0 })
    installPlayer(1, { teammateCaravan }, { team = 0 })
    mapFromPlots({ fogged })
    T.eq(#runUnitsScan(), 0, "teammate trade unit must stay hidden on fogged plot")
end

function M.test_unit_enemy_trade_unit_stays_hidden_on_fogged_plot()
    -- Carve-out is own-team only. An enemy caravan on a fogged plot would
    -- leak their trade route to a player who can't see it; the engine
    -- deliberately withholds that, so we must too.
    setup()
    loadUnitsBackend()
    GameInfo.Units = { [42] = { Description = "TXT_KEY_UNIT_CARAVAN" } }
    Teams[0] = T.fakeTeam({ atWar = { [1] = true } })
    local fogged = makePlotAt(0, 0, 0, { revealed = true, visible = false })
    local enemyCaravan = makeUnit({
        id = 1,
        owner = 1,
        team = 1,
        combat = false,
        trade = true,
        plot = fogged,
    })
    installPlayer(1, { enemyCaravan }, { team = 1 })
    mapFromPlots({ fogged })
    T.eq(#runUnitsScan(), 0, "enemy trade unit must stay hidden on fogged plot")
end

function M.test_unit_validate_entry_keeps_own_trade_unit_on_fogged_plot()
    -- Mirror Scan's carve-out so an own-team trade unit doesn't get pruned
    -- on the next ValidateEntry pass after walking onto a fogged plot.
    setup()
    loadUnitsBackend()
    GameInfo.Units = { [42] = { Description = "TXT_KEY_UNIT_CARAVAN" } }
    local fogged = makePlotAt(0, 0, 0, { revealed = true, visible = false })
    local caravan = makeUnit({
        id = 1,
        owner = 0,
        team = 0,
        combat = false,
        trade = true,
        plot = fogged,
    })
    installPlayer(0, { caravan }, { team = 0 })
    mapFromPlots({ fogged })
    local entries = runUnitsScan()
    T.eq(#entries, 1, "scan precondition: one trade-unit entry")
    T.truthy(
        ScannerBackendUnits.ValidateEntry(entries[1], nil),
        "ValidateEntry must keep own-team trade units on fogged plots"
    )
end

-- ===== Cities backend =====

local function loadCitiesBackend()
    loadModule("src/dlc/UI/InGame/CivVAccess_ScannerBackendCities.lua")
end

-- Build a city fixture rich enough for ScannerBackendCities.Scan, which
-- reads city:Plot, city:GetID, city:GetNameKey via Text.key. fakeCity
-- doesn't supply GetNameKey, so wrap it.
local function makeCity(opts)
    local plot = opts.plot
    local c = T.fakeCity({ owner = opts.owner, id = opts.id })
    c._plot = plot
    function c:Plot()
        return self._plot
    end
    function c:GetNameKey()
        return opts.nameKey or "TXT_KEY_CITY_NAME"
    end
    return c
end

-- Install a player owning one city. `minor` flips IsMinorCiv. team
-- defaults to playerId so each player sits on its own team unless the
-- caller pins them together.
local function installCityOwner(playerId, opts)
    opts = opts or {}
    Players[playerId] = T.fakePlayer({
        team = opts.team or playerId,
        cities = { opts.city },
        isMinor = opts.minor or false,
    })
end

function M.test_city_minor_civ_routes_to_city_states_at_peace()
    -- The headline change: a city-state we've met but aren't at war with
    -- must land in the new city_states sub, not in neutral with the major
    -- peers.
    setup()
    loadCitiesBackend()
    Teams[0] = T.fakeTeam({ hasMet = { [22] = true } })
    local plot = makePlotAt(0, 0, 0, { isCity = true })
    local city = makeCity({ owner = 22, id = 1, plot = plot })
    plot._city = city
    installCityOwner(22, { city = city, team = 22, minor = true })
    mapFromPlots({ plot })
    local out = ScannerBackendCities.Scan(0, 0)
    T.eq(#out, 1)
    T.eq(out[1].subcategory, "city_states", "minor-civ city must bucket under city_states")
end

function M.test_city_teammate_routes_to_teammate()
    -- Same-team-but-different-player owners route into `teammate` so
    -- cycling through My Cities isn't padded with cities you can't manage.
    -- The activePlayer == ownerId branch must NOT fire (that's the user
    -- themselves), and the activeTeam == ownerTeamId branch is what
    -- catches teammates.
    setup()
    loadCitiesBackend()
    Teams[0] = T.fakeTeam({ hasMet = { [1] = true } })
    local plot = makePlotAt(0, 0, 0, { isCity = true })
    local city = makeCity({ owner = 1, id = 1, plot = plot })
    plot._city = city
    installCityOwner(1, { city = city, team = 0, minor = false })
    mapFromPlots({ plot })
    local out = ScannerBackendCities.Scan(0, 0)
    T.eq(#out, 1)
    T.eq(out[1].subcategory, "teammate", "same-team different-player city must bucket under teammate, not my")
end

function M.test_city_minor_civ_at_war_routes_to_enemy()
    -- At-war city-states are something the user is acting against, so
    -- they bucket with hostile major civs in `enemy` rather than the
    -- city_states list (which is reserved for peaceful minor civs).
    setup()
    loadCitiesBackend()
    Teams[0] = T.fakeTeam({ hasMet = { [22] = true }, atWar = { [22] = true } })
    local plot = makePlotAt(0, 0, 0, { isCity = true })
    local city = makeCity({ owner = 22, id = 1, plot = plot })
    plot._city = city
    installCityOwner(22, { city = city, team = 22, minor = true })
    mapFromPlots({ plot })
    local out = ScannerBackendCities.Scan(0, 0)
    T.eq(#out, 1)
    T.eq(out[1].subcategory, "enemy", "city-state at war must move to enemy alongside hostile major civs")
end

function M.test_city_major_peer_at_peace_stays_in_neutral()
    -- Regression guard for the negative direction: a major peer at peace
    -- must not get swept into city_states. The minor-civ check is the
    -- only thing routing into city_states.
    setup()
    loadCitiesBackend()
    Teams[0] = T.fakeTeam({ hasMet = { [1] = true } })
    local plot = makePlotAt(0, 0, 0, { isCity = true })
    local city = makeCity({ owner = 1, id = 1, plot = plot })
    plot._city = city
    installCityOwner(1, { city = city, team = 1, minor = false })
    mapFromPlots({ plot })
    local out = ScannerBackendCities.Scan(0, 0)
    T.eq(#out, 1)
    T.eq(out[1].subcategory, "neutral")
end

function M.test_city_major_peer_at_war_stays_in_enemy()
    setup()
    loadCitiesBackend()
    Teams[0] = T.fakeTeam({ hasMet = { [1] = true }, atWar = { [1] = true } })
    local plot = makePlotAt(0, 0, 0, { isCity = true })
    local city = makeCity({ owner = 1, id = 1, plot = plot })
    plot._city = city
    installCityOwner(1, { city = city, team = 1, minor = false })
    mapFromPlots({ plot })
    local out = ScannerBackendCities.Scan(0, 0)
    T.eq(#out, 1)
    T.eq(out[1].subcategory, "enemy")
end

function M.test_city_unmet_civ_with_revealed_plot_still_surfaces()
    -- Goody-hut map reveal exposes plots via setRevealed without ever
    -- calling kTeam.meet on the plot owner's team. A foreign city sitting
    -- inside that reveal must still appear in the scanner -- the cursor
    -- already announces its civ name from plot:GetRevealedOwner and a
    -- sighted player sees the owner's border colour and city banner, so
    -- gating on IsHasMet would hide a city both other channels surface.
    setup()
    loadCitiesBackend()
    Teams[0] = T.fakeTeam({ hasMet = {} })
    local plot = makePlotAt(0, 0, 0, { isCity = true })
    local city = makeCity({ owner = 1, id = 1, plot = plot })
    plot._city = city
    installCityOwner(1, { city = city, team = 1, minor = false })
    mapFromPlots({ plot })
    local out = ScannerBackendCities.Scan(0, 0)
    T.eq(#out, 1, "unmet civ's revealed city must still surface in the scanner")
    T.eq(out[1].subcategory, "neutral")
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

local function impPlot(x, y, idx, impId, owner, pillaged, visible)
    local opts = { improvement = impId, owner = owner, improvementPillaged = pillaged }
    if visible == false then
        opts.visible = false
    end
    local p = makePlotAt(x, y, idx, opts)
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

function M.test_improvement_pillaged_mine_routes_to_my_pillaged()
    -- Repair-list carve-out: a pillaged improvement owned by the active
    -- player must move out of `my` into `my_pillaged` so `my` reads as
    -- productive improvements only.
    setup()
    loadImprovementsBackend()
    GameInfoTypes.IMPROVEMENT_BARBARIAN_CAMP = -1
    GameInfoTypes.IMPROVEMENT_GOODY_HUT = -1
    GameInfo.Improvements = {
        [5] = { Description = "TXT_KEY_IMPROVEMENT_FARM" },
    }
    local function mkTeamPlayer(teamId)
        local p = { _team = teamId }
        function p:GetTeam()
            return self._team
        end
        return p
    end
    Players[0] = mkTeamPlayer(0)
    local pillagedMine = impPlot(0, 0, 0, 5, 0, true)
    local healthyMine = impPlot(1, 0, 1, 5, 0, false)
    mapFromPlots({ pillagedMine, healthyMine })
    local out = ScannerBackendImprovements.Scan(0, 0)
    local subByPlot = {}
    for _, e in ipairs(out) do
        subByPlot[e.plotIndex] = e.subcategory
    end
    T.eq(subByPlot[0], "my_pillaged", "pillaged improvement of mine must land in my_pillaged")
    T.eq(subByPlot[1], "my", "healthy improvement of mine must stay in my")
end

function M.test_improvement_pillaged_enemy_stays_in_enemy()
    -- Repair list is player-scoped; enemy/neutral pillaged improvements
    -- stay in their owner sub so we don't carve a parallel pillaged
    -- bucket the user can't act on.
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
    Players[2] = mkTeamPlayer(2)
    local pillagedEnemy = impPlot(0, 0, 0, 5, 2, true)
    mapFromPlots({ pillagedEnemy })
    local out = ScannerBackendImprovements.Scan(0, 0)
    T.eq(#out, 1)
    T.eq(out[1].subcategory, "enemy", "pillaged enemy improvement must stay in enemy, not move to my_pillaged")
end

function M.test_improvement_teammate_routes_to_teammate()
    -- Same-team-but-different-player owners route into `teammate` so
    -- the `my` bucket reads as tiles you actually own and can act on.
    setup()
    loadImprovementsBackend()
    GameInfoTypes.IMPROVEMENT_BARBARIAN_CAMP = -1
    GameInfoTypes.IMPROVEMENT_GOODY_HUT = -1
    GameInfo.Improvements = {
        [5] = { Description = "TXT_KEY_IMPROVEMENT_FARM" },
    }
    local function mkTeamPlayer(teamId)
        local p = { _team = teamId }
        function p:GetTeam()
            return self._team
        end
        return p
    end
    Players[0] = mkTeamPlayer(0)
    Players[1] = mkTeamPlayer(0)
    local healthyTeammate = impPlot(0, 0, 0, 5, 1, false)
    mapFromPlots({ healthyTeammate })
    local out = ScannerBackendImprovements.Scan(0, 0)
    T.eq(#out, 1)
    T.eq(out[1].subcategory, "teammate", "healthy teammate-owned improvement must bucket under teammate")
end

function M.test_improvement_pillaged_teammate_stays_in_teammate()
    -- Workers can only repair improvements on tiles you own outright,
    -- not on a teammate's tile. There's no parallel `teammate_pillaged`
    -- repair-list bucket -- pillaged teammate tiles stay in `teammate`.
    setup()
    loadImprovementsBackend()
    GameInfoTypes.IMPROVEMENT_BARBARIAN_CAMP = -1
    GameInfoTypes.IMPROVEMENT_GOODY_HUT = -1
    GameInfo.Improvements = {
        [5] = { Description = "TXT_KEY_IMPROVEMENT_FARM" },
    }
    local function mkTeamPlayer(teamId)
        local p = { _team = teamId }
        function p:GetTeam()
            return self._team
        end
        return p
    end
    Players[0] = mkTeamPlayer(0)
    -- Player 1 is on the active team (team 0) but not the active player.
    Players[1] = mkTeamPlayer(0)
    local pillagedTeammate = impPlot(0, 0, 0, 5, 1, true)
    mapFromPlots({ pillagedTeammate })
    local out = ScannerBackendImprovements.Scan(0, 0)
    T.eq(#out, 1)
    T.eq(out[1].subcategory, "teammate", "teammate pillaged improvement must stay in teammate, not move to my_pillaged")
end

function M.test_improvement_pillaged_mine_on_fogged_plot_stays_in_my()
    -- IsImprovementPillaged reads server truth and would leak the
    -- pillage state of a tile that has gone under fog since the player
    -- last saw it. The visibility gate routes such tiles by last-seen
    -- state -- a healthy farm stays in `my` until the player sees the
    -- pillage themselves.
    setup()
    loadImprovementsBackend()
    GameInfoTypes.IMPROVEMENT_BARBARIAN_CAMP = -1
    GameInfoTypes.IMPROVEMENT_GOODY_HUT = -1
    GameInfo.Improvements = {
        [5] = { Description = "TXT_KEY_IMPROVEMENT_FARM" },
    }
    local function mkTeamPlayer(teamId)
        local p = { _team = teamId }
        function p:GetTeam()
            return self._team
        end
        return p
    end
    Players[0] = mkTeamPlayer(0)
    local fogged = impPlot(0, 0, 0, 5, 0, true, false)
    mapFromPlots({ fogged })
    local out = ScannerBackendImprovements.Scan(0, 0)
    T.eq(#out, 1)
    T.eq(out[1].subcategory, "my", "pillaged-but-fogged improvement must not leak via my_pillaged")
end

function M.test_improvement_pillaged_unowned_stays_in_neutral()
    -- A no-man's-land fort that has been pillaged must stay in neutral
    -- (RevealedOwner == -1 short-circuits before the pillaged check).
    setup()
    loadImprovementsBackend()
    GameInfoTypes.IMPROVEMENT_BARBARIAN_CAMP = -1
    GameInfoTypes.IMPROVEMENT_GOODY_HUT = -1
    GameInfo.Improvements = {
        [9] = { Description = "TXT_KEY_IMPROVEMENT_FORT" },
    }
    local fort = impPlot(0, 0, 0, 9, -1, true)
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

function M.test_terrain_lake_emits_lake_not_coast()
    -- A lake plot uses the TERRAIN_COAST row but plot:IsLake() is true.
    -- The scanner must mirror the game's plot tooltip and the cursor's
    -- terrain readout, both of which say "lake" rather than letting the
    -- terrain row leak through as "coast".
    setup()
    loadTerrainBackend()
    GameInfo.Terrains = { [4] = { Description = "TXT_KEY_TERRAIN_COAST" } }
    GameInfo.Features = {}
    local plot = makePlotAt(0, 0, 0, { terrain = 4, lake = true, water = true })
    mapFromPlots({ plot })
    local bySub = subsFromEntries(ScannerBackendTerrain.Scan(0, 0))
    T.truthy(bySub.base, "lake plot must still emit a base entry")
    T.eq(#bySub.base, 1)
    T.eq(
        bySub.base[1].itemName,
        Text.key("TXT_KEY_CIVVACCESS_LAKE"),
        "lake plot must surface as lake, not the coast terrain row"
    )
    T.eq(bySub.base[1].data.isLake, true)
end

function M.test_terrain_validate_lake_state_change_invalidates()
    -- Lakes and coast share the terrain row, so the only signal that a
    -- prior lake entry has gone stale (or vice versa) is plot:IsLake().
    -- Validation must consult it or a coast plot that just got reclassified
    -- as a lake would keep speaking "coast" until the next snapshot.
    setup()
    loadTerrainBackend()
    local plot = makePlotAt(0, 0, 0, { terrain = 4, lake = false, water = true })
    mapFromPlots({ plot })
    local staleLakeEntry = {
        plotIndex = 0,
        backend = ScannerBackendTerrain,
        data = { kind = "base", terrainId = 4, isLake = true },
        category = "terrain",
        subcategory = "base",
        itemName = "TXT_KEY_CIVVACCESS_LAKE",
        sortKey = 0,
    }
    T.falsy(
        ScannerBackendTerrain.ValidateEntry(staleLakeEntry, nil),
        "a lake entry whose plot is no longer a lake must invalidate"
    )
end

function M.test_terrain_freshwater_plot_emits_under_freshwater()
    setup()
    loadTerrainBackend()
    GameInfo.Terrains = { [1] = { Description = "TXT_KEY_TERRAIN_GRASS" } }
    GameInfo.Features = {}
    local plot = makePlotAt(0, 0, 0, { terrain = 1, freshWater = true })
    mapFromPlots({ plot })
    local bySub = subsFromEntries(ScannerBackendTerrain.Scan(0, 0))
    T.truthy(bySub.base, "base entry still fires alongside freshwater")
    T.truthy(bySub.freshwater, "freshwater entry must fire on a freshwater plot")
    T.eq(bySub.freshwater[1].data.kind, "freshwater")
end

function M.test_terrain_non_freshwater_plot_emits_no_freshwater()
    setup()
    loadTerrainBackend()
    GameInfo.Terrains = { [1] = { Description = "TXT_KEY_TERRAIN_GRASS" } }
    GameInfo.Features = {}
    local plot = makePlotAt(0, 0, 0, { terrain = 1 })
    mapFromPlots({ plot })
    local bySub = subsFromEntries(ScannerBackendTerrain.Scan(0, 0))
    T.falsy(bySub.freshwater, "dry plot must not emit a freshwater entry")
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

function M.test_terrain_validate_freshwater_goes_stale_when_river_lost()
    -- IsFreshWater can flip false mid-game: a worker chops an adjacent
    -- oasis or a tile that was riverside via an upstream lake gets the
    -- lake terraformed (mods only, but the backend handles the case
    -- the same way feature removal is handled).
    setup()
    loadTerrainBackend()
    local dry = makePlotAt(0, 0, 0, { freshWater = false })
    mapFromPlots({ dry })
    local staleEntry = {
        plotIndex = 0,
        backend = ScannerBackendTerrain,
        data = { kind = "freshwater" },
        category = "terrain",
        subcategory = "freshwater",
        itemName = "x",
        sortKey = 0,
    }
    T.falsy(
        ScannerBackendTerrain.ValidateEntry(staleEntry, nil),
        "freshwater entry must invalidate once IsFreshWater goes false"
    )
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

-- ===== Recommendations backend =====

local function loadRecommendationsBackend()
    loadModule("src/dlc/UI/InGame/CivVAccess_RecommendationsCore.lua")
    loadModule("src/dlc/UI/InGame/CivVAccess_ScannerBackendRecommendations.lua")
end

-- installRecGlobals / installRecPlayer live on T in tests/support.lua;
-- shared with the cursor suite. Local aliases keep this file's call
-- sites terse.
local installRecGlobals = T.installRecGlobals
local installRecPlayer = T.installRecPlayer

function M.test_recs_empty_when_options_hide()
    setup()
    loadRecommendationsBackend()
    installRecGlobals({ canFound = true, hideRecs = true })
    installRecPlayer({ numCities = 1, settlerPlots = { makePlotAt(0, 0, 0) } })
    mapFromPlots({ makePlotAt(0, 0, 0) })
    T.eq(#ScannerBackendRecommendations.Scan(0, 0), 0, "IsNoTileRecommendations must zero the output")
end

function M.test_recs_empty_when_no_selection()
    setup()
    loadRecommendationsBackend()
    installRecGlobals({ canFound = false, canWork = false })
    installRecPlayer({ numCities = 3, settlerPlots = { makePlotAt(0, 0, 0) } })
    mapFromPlots({ makePlotAt(0, 0, 0) })
    T.eq(
        #ScannerBackendRecommendations.Scan(0, 0),
        0,
        "without a Founder or Worker selected, the backend must emit nothing"
    )
end

function M.test_recs_settler_needs_first_city()
    -- Engine suppresses the settler anchors until the player founds
    -- their first city, on the theory that turn-1 Settler placement is
    -- self-evident and recs would just spam. We must match.
    setup()
    loadRecommendationsBackend()
    installRecGlobals({ canFound = true })
    installRecPlayer({ numCities = 0, settlerPlots = { makePlotAt(0, 0, 0) } })
    mapFromPlots({ makePlotAt(0, 0, 0) })
    T.eq(#ScannerBackendRecommendations.Scan(0, 0), 0, "settler recs must stay silent before the first city")
end

function M.test_recs_settler_emits_city_site_entries()
    setup()
    loadRecommendationsBackend()
    installRecGlobals({ canFound = true })
    local p1 = makePlotAt(3, 4, 0)
    local p2 = makePlotAt(5, 6, 1)
    installRecPlayer({ numCities = 1, settlerPlots = { p1, p2 } })
    mapFromPlots({ p1, p2 })
    local out = ScannerBackendRecommendations.Scan(0, 0)
    T.eq(#out, 2)
    T.eq(out[1].category, "recommendations")
    T.eq(out[1].subcategory, "all", "all-direct emission: entries target the implicit `all` sub")
    T.eq(out[1].itemName, "City site", "settler itemName resolves through Text.key to 'City site'")
    T.eq(out[1].data.kind, "settler")
    T.eq(out[1].plotIndex, 0)
    T.eq(out[2].plotIndex, 1)
end

function M.test_recs_settler_skips_unfoundable_plots()
    -- Mirrors HandleSettlerRecommendation's CanFound guard: if the rec
    -- list still mentions a plot that's no longer foundable (e.g. a
    -- rival just dropped a city nearby), we drop it silently -- the
    -- engine does exactly this.
    setup()
    loadRecommendationsBackend()
    installRecGlobals({ canFound = true })
    local p1 = makePlotAt(3, 4, 0)
    local p2 = makePlotAt(5, 6, 1)
    installRecPlayer({
        numCities = 1,
        settlerPlots = { p1, p2 },
        cantFoundAt = { { 5, 6 } },
    })
    mapFromPlots({ p1, p2 })
    local out = ScannerBackendRecommendations.Scan(0, 0)
    T.eq(#out, 1)
    T.eq(out[1].plotIndex, 0)
end

function M.test_recs_worker_emits_build_description()
    setup()
    loadRecommendationsBackend()
    installRecGlobals({ canFound = false, canWork = true })
    GameInfo.Builds = {
        [7] = { Description = "TXT_KEY_BUILD_FARM" },
        [11] = { Description = "TXT_KEY_BUILD_MINE" },
    }
    local p1 = makePlotAt(2, 2, 0)
    local p2 = makePlotAt(3, 3, 1)
    installRecPlayer({
        numCities = 2,
        workerRecs = {
            { plot = p1, buildType = 7 },
            { plot = p2, buildType = 11 },
        },
    })
    mapFromPlots({ p1, p2 })
    local out = ScannerBackendRecommendations.Scan(0, 0)
    T.eq(#out, 2)
    local byBuild = {}
    for _, e in ipairs(out) do
        byBuild[e.data.buildType] = e
    end
    T.eq(
        byBuild[7].itemName,
        "TXT_KEY_BUILD_FARM",
        "worker itemName must be GameInfo.Builds[buildType].Description via Text.key"
    )
    T.eq(byBuild[11].itemName, "TXT_KEY_BUILD_MINE")
    T.eq(byBuild[7].data.kind, "worker")
    T.eq(byBuild[7].subcategory, "all")
end

function M.test_recs_validate_drops_when_selection_lost()
    -- Unit deselection flips CanSelectionListFound off mid-snapshot;
    -- every queued entry must invalidate and prune away.
    setup()
    loadRecommendationsBackend()
    installRecGlobals({ canFound = true })
    local p = makePlotAt(3, 4, 0)
    installRecPlayer({ numCities = 1, settlerPlots = { p } })
    mapFromPlots({ p })
    local entries = ScannerBackendRecommendations.Scan(0, 0)
    T.eq(#entries, 1)
    -- Now simulate the deselect.
    UI.CanSelectionListFound = function()
        return false
    end
    T.falsy(
        ScannerBackendRecommendations.ValidateEntry(entries[1], nil),
        "entry must invalidate once CanSelectionListFound returns false"
    )
end

function M.test_recs_validate_drops_when_plot_leaves_list()
    -- A settler rec can disappear from the engine's list even while
    -- the unit stays selected (strategic reassessment, new info after
    -- exploration). ValidateEntry has to catch that by checking fresh
    -- list membership, not just CanFound.
    setup()
    loadRecommendationsBackend()
    installRecGlobals({ canFound = true })
    local p = makePlotAt(3, 4, 0)
    local player = installRecPlayer({ numCities = 1, settlerPlots = { p } })
    mapFromPlots({ p })
    local entries = ScannerBackendRecommendations.Scan(0, 0)
    T.eq(#entries, 1)
    player.GetRecommendedFoundCityPlots = function()
        return {}
    end
    T.falsy(
        ScannerBackendRecommendations.ValidateEntry(entries[1], nil),
        "entry must invalidate when the plot falls out of GetRecommendedFoundCityPlots"
    )
end

function M.test_recs_validate_worker_drops_on_build_change()
    -- A Farm rec on a plot that now recommends Pasture is stale even
    -- though the plot itself is still in the rec list. The equality
    -- check is on (plot, buildType) together, not plot alone.
    setup()
    loadRecommendationsBackend()
    installRecGlobals({ canFound = false, canWork = true })
    GameInfo.Builds = {
        [7] = { Description = "TXT_KEY_BUILD_FARM" },
        [12] = { Description = "TXT_KEY_BUILD_PASTURE" },
    }
    local p = makePlotAt(2, 2, 0)
    local player = installRecPlayer({ numCities = 2, workerRecs = { { plot = p, buildType = 7 } } })
    mapFromPlots({ p })
    local entries = ScannerBackendRecommendations.Scan(0, 0)
    T.eq(#entries, 1)
    player.GetRecommendedWorkerPlots = function()
        return { { plot = p, buildType = 12 } }
    end
    T.falsy(
        ScannerBackendRecommendations.ValidateEntry(entries[1], nil),
        "Farm entry must invalidate once the recommendation flips to a different build"
    )
end

function M.test_recs_validate_keeps_live_entry()
    setup()
    loadRecommendationsBackend()
    installRecGlobals({ canFound = true })
    local p = makePlotAt(3, 4, 0)
    installRecPlayer({ numCities = 1, settlerPlots = { p } })
    mapFromPlots({ p })
    local entries = ScannerBackendRecommendations.Scan(0, 0)
    T.truthy(
        ScannerBackendRecommendations.ValidateEntry(entries[1], nil),
        "a still-in-list, still-foundable settler entry must stay valid"
    )
end

-- ===== Worked tiles backend =====

local function loadWorkedTilesBackend()
    loadModule("src/dlc/UI/InGame/CivVAccess_ScannerBackendWorkedTiles.lua")
end

-- The backend needs civvaccess_shared (mapScope gate), UI.GetHeadSelectedCity,
-- YieldTypes, and a city/plot fixture richer than support.lua's fakeCity (we
-- need GetCityIndexPlot / GetNumCityPlots / IsWorkingPlot / GetX / GetY).
local function setupWorkedTiles()
    setup()
    -- YieldTypes must be defined before the backend is loaded -- the
    -- backend captures YIELD_KEYS = { { id = YieldTypes.YIELD_FOOD, ... }, ... }
    -- at file scope, so a later override doesn't reach the captured ids.
    YieldTypes = {
        YIELD_FOOD = 1,
        YIELD_PRODUCTION = 2,
        YIELD_GOLD = 3,
        YIELD_SCIENCE = 4,
        YIELD_CULTURE = 5,
        YIELD_FAITH = 6,
    }
    loadWorkedTilesBackend()
    civvaccess_shared = civvaccess_shared or {}
    -- Gate set by default; tests that probe the gate clear it before calling.
    civvaccess_shared.mapScope = function()
        return true
    end
    UI = UI or {}
end

-- yields is a YIELD_* -> int map; workingPlots is a list of plot refs the
-- city considers worked (city center is implicitly always worked unless
-- the test passes centerWorked = false).
local function workedTilesCity(opts)
    opts = opts or {}
    local plots = opts.plots or {}
    local working = {}
    for _, p in ipairs(opts.workingPlots or {}) do
        working[p] = true
    end
    local cityX = opts.cityX or 0
    local cityY = opts.cityY or 0
    local c = T.fakeCity({ owner = opts.owner or 0, id = opts.id or 1 })
    function c:GetX()
        return cityX
    end
    function c:GetY()
        return cityY
    end
    function c:GetNumCityPlots()
        return #plots
    end
    function c:GetCityIndexPlot(i)
        return plots[i + 1]
    end
    function c:IsWorkingPlot(p)
        if p:GetX() == cityX and p:GetY() == cityY then
            return opts.centerWorked ~= false
        end
        return working[p] or false
    end
    return c
end

local function plotWithYields(opts)
    return T.fakePlot({
        x = opts.x or 0,
        y = opts.y or 0,
        plotIndex = opts.plotIndex or 0,
        yields = opts.yields or {},
    })
end

function M.test_worked_tiles_empty_without_mapscope()
    -- The category only exists while CityView's Manage Territory sub is
    -- active, signalled by civvaccess_shared.mapScope being non-nil.
    setupWorkedTiles()
    civvaccess_shared.mapScope = nil
    UI.GetHeadSelectedCity = function()
        return workedTilesCity({
            plots = { plotWithYields({ x = 1, y = 0, plotIndex = 1, yields = { [1] = 2 } }) },
            workingPlots = {},
        })
    end
    T.eq(#ScannerBackendWorkedTiles.Scan(0, 0), 0)
end

function M.test_worked_tiles_empty_for_foreign_city()
    -- Vanilla CityView has no list-worked-tiles surface for foreign cities;
    -- mod must not synthesize one when the head-selected city is somebody
    -- else's (espionage / spy peek).
    setupWorkedTiles()
    local plot = plotWithYields({ x = 1, y = 0, plotIndex = 1, yields = { [1] = 2 } })
    UI.GetHeadSelectedCity = function()
        return workedTilesCity({ owner = 5, plots = { plot }, workingPlots = { plot } })
    end
    T.eq(#ScannerBackendWorkedTiles.Scan(0, 0), 0)
end

function M.test_worked_tiles_skips_city_center()
    -- IsWorkingPlot returns true for the city center (auto-worked) but the
    -- player never picks it; the backend must filter by coord match so the
    -- center never lands in the list.
    setupWorkedTiles()
    local center = plotWithYields({ x = 0, y = 0, plotIndex = 0, yields = { [1] = 5 } })
    local ring = plotWithYields({ x = 1, y = 0, plotIndex = 1, yields = { [1] = 2 } })
    UI.GetHeadSelectedCity = function()
        return workedTilesCity({ plots = { center, ring }, workingPlots = { center, ring } })
    end
    local out = ScannerBackendWorkedTiles.Scan(0, 0)
    T.eq(#out, 1)
    T.eq(out[1].plotIndex, 1)
end

function M.test_worked_tiles_label_drops_zero_yields()
    -- Item collapse depends on identical itemNames -- a tile that produces
    -- 2 food and 0 of everything else must label "2 food", not "2 food, 0
    -- production, 0 gold, ..." (which would also break collapse against
    -- another 2-food tile that happens to also produce something else).
    setupWorkedTiles()
    GameInfo = GameInfo or {}
    local plot = plotWithYields({ x = 1, y = 0, plotIndex = 1, yields = { [1] = 2, [2] = 0, [3] = 1 } })
    UI.GetHeadSelectedCity = function()
        return workedTilesCity({ plots = { plot }, workingPlots = { plot } })
    end
    local out = ScannerBackendWorkedTiles.Scan(0, 0)
    T.eq(#out, 1)
    -- The mod's CivVAccess_Strings table (pre-loaded into the test env from
    -- earlier suites in the run) supplies TXT_KEY_CIVVACCESS_YIELD_COUNT =
    -- "{1_Count} {2_Yield}", so the resolved label is "<n> <icon>" per
    -- non-zero yield, joined by ", ". A zero-yield slot must produce no
    -- segment at all.
    T.eq(out[1].itemName, "2 food, 1 gold")
end

function M.test_worked_tiles_validate_drops_unworked_plot()
    -- Reassignment scenario: a plot that was emitted as worked stops being
    -- worked. ValidateEntry must return false so ScannerSnap.pruneInstance
    -- can drop the entry on next visit. New entries don't appear here --
    -- that path needs a full rebuild, which the per-cycle rebuildAndLocate
    -- in ScannerNav already gives us.
    setupWorkedTiles()
    local plot = plotWithYields({ x = 1, y = 0, plotIndex = 1, yields = { [1] = 2 } })
    Map.GetPlotByIndex = function(i)
        if i == 1 then
            return plot
        end
        return nil
    end
    Players[0] = Players[0] or {}
    Players[0].GetCityByID = function(_self, _id)
        return workedTilesCity({ plots = { plot }, workingPlots = {} })
    end
    local entry = {
        plotIndex = 1,
        data = { cityOwner = 0, cityID = 1 },
    }
    T.falsy(ScannerBackendWorkedTiles.ValidateEntry(entry, nil))
end

function M.test_worked_tiles_validate_resolves_by_stored_city_not_head_selected()
    -- A snapshot built against city A must keep validating against city A
    -- even if the user has since switched the head-selected city to city B.
    -- ValidateEntry resolves through entry.data.cityOwner / cityID for
    -- exactly this reason; a regression that read UI.GetHeadSelectedCity()
    -- here would silently re-bucket city-A entries against city B's
    -- IsWorkingPlot table.
    setupWorkedTiles()
    local plot = plotWithYields({ x = 1, y = 0, plotIndex = 1, yields = { [1] = 2 } })
    Map.GetPlotByIndex = function(i)
        if i == 1 then
            return plot
        end
        return nil
    end
    -- City A is what the snapshot was built against and still works the plot.
    local cityA = workedTilesCity({ id = 1, plots = { plot }, workingPlots = { plot } })
    -- City B (now head-selected) does NOT work it. If validate looked at
    -- the head-selected city, it would (wrongly) return false and prune.
    local cityB = workedTilesCity({ id = 2, plots = { plot }, workingPlots = {} })
    UI.GetHeadSelectedCity = function()
        return cityB
    end
    Players[0] = Players[0] or {}
    Players[0].GetCityByID = function(_self, id)
        if id == 1 then
            return cityA
        end
        if id == 2 then
            return cityB
        end
        return nil
    end
    local entry = {
        plotIndex = 1,
        data = { cityOwner = 0, cityID = 1 },
    }
    T.truthy(
        ScannerBackendWorkedTiles.ValidateEntry(entry, nil),
        "must validate against stored city, not head-selected"
    )
end

return M
