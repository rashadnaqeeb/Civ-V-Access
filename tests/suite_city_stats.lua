-- CityStats data-shaping tests. Covers each pure-data row builder:
-- yieldRows, growthRows, cultureRows, happinessRows, religionRows,
-- tradeRows, resourceRows, defenseRows, demandRow. The wrapper builders
-- that wrap rows into BaseMenuItems.Group entries aren't exercised here
-- (their logic is just BaseMenuItems composition, covered by the menu
-- suite); the speech-shaping behavior lives in the row functions.

local T = require("support")
local M = {}

-- ===== City stub =====
-- Implements only the methods CityStats reads. opts overrides let each
-- test express the diffs it cares about; defaults model an own-team
-- city with full HP, no demand, no religion present, no trade routes.
local function mkCity(opts)
    opts = opts or {}
    local c = {
        _id = opts.id or 7,
        _owner = opts.owner or 0,
        _team = opts.team or 0,
        _x = opts.x or 5,
        _y = opts.y or 5,
        _population = opts.population or 8,
        _strength = opts.strength or 2200,
        _damage = opts.damage or 0,
        _foodDifference = opts.foodDifference or 3,
        _foodDifferenceTimes100 = (opts.foodDifferenceTimes100 == nil) and 300 or opts.foodDifferenceTimes100,
        _isFoodProduction = opts.isFoodProduction or false,
        _foodTurnsLeft = opts.foodTurnsLeft or 7,
        _food = opts.food or 12,
        _growthThreshold = opts.growthThreshold or 22,
        _yieldRate = opts.yieldRate or {},
        _baseTourism = opts.baseTourism or 0,
        _cultureStored = opts.cultureStored or 4,
        _cultureThreshold = opts.cultureThreshold or 30,
        _culturePerTurn = opts.culturePerTurn or 0,
        _localHappiness = opts.localHappiness or 0,
        _religiousMajority = (opts.religiousMajority == nil) and -1 or opts.religiousMajority,
        _followers = opts.followers or {},
        _pressure = opts.pressure or {},
        _holyCity = opts.holyCity or {},
        _resourceLocal = opts.resourceLocal or {},
        _hasBuilding = opts.hasBuilding or {},
        _garrisonedUnit = opts.garrisonedUnit,
        _resourceDemandedTrue = (opts.resourceDemandedTrue == nil) and -1 or opts.resourceDemandedTrue,
        _resourceDemanded = (opts.resourceDemanded == nil) and -1 or opts.resourceDemanded,
        _wltkdCounter = opts.wltkdCounter or 0,
    }
    function c:GetID()
        return self._id
    end
    function c:GetOwner()
        return self._owner
    end
    function c:GetTeam()
        return self._team
    end
    function c:GetX()
        return self._x
    end
    function c:GetY()
        return self._y
    end
    function c:GetPopulation()
        return self._population
    end
    function c:GetStrengthValue()
        return self._strength
    end
    function c:GetDamage()
        return self._damage
    end
    function c:FoodDifference()
        return self._foodDifference
    end
    function c:FoodDifferenceTimes100()
        return self._foodDifferenceTimes100
    end
    function c:IsFoodProduction()
        return self._isFoodProduction
    end
    function c:GetFoodTurnsLeft()
        return self._foodTurnsLeft
    end
    function c:GetFood()
        return self._food
    end
    function c:GrowthThreshold()
        return self._growthThreshold
    end
    function c:GetYieldRate(yid)
        return self._yieldRate[yid] or 0
    end
    function c:GetBaseTourism()
        return self._baseTourism
    end
    function c:GetJONSCultureStored()
        return self._cultureStored
    end
    function c:GetJONSCultureThreshold()
        return self._cultureThreshold
    end
    function c:GetJONSCulturePerTurn()
        return self._culturePerTurn
    end
    function c:GetLocalHappiness()
        return self._localHappiness
    end
    function c:GetReligiousMajority()
        return self._religiousMajority
    end
    function c:GetNumFollowers(rid)
        return self._followers[rid] or 0
    end
    function c:GetPressurePerTurn(rid)
        return self._pressure[rid] or 0
    end
    function c:IsHolyCityForReligion(rid)
        return self._holyCity[rid] or false
    end
    function c:IsHasResourceLocal(rid)
        return self._resourceLocal[rid] or false
    end
    function c:IsHasBuilding(bid)
        return self._hasBuilding[bid] or false
    end
    function c:GetGarrisonedUnit()
        return self._garrisonedUnit
    end
    function c:GetResourceDemanded(includeFutureCycles)
        if includeFutureCycles then
            return self._resourceDemandedTrue
        end
        return self._resourceDemanded
    end
    function c:GetWeLoveTheKingDayCounter()
        return self._wltkdCounter
    end
    return c
end

local function mkPlayer(opts)
    opts = opts or {}
    local p = {
        _unhappinessFromCity = opts.unhappinessFromCity or 0,
        _tradeRoutes = opts.tradeRoutes or {},
    }
    function p:GetUnhappinessFromCityForUI()
        return self._unhappinessFromCity
    end
    function p:GetTradeRoutes()
        return self._tradeRoutes
    end
    return p
end

-- ===== Setup =====

-- Game-side TXT keys our code formats. The runner's Locale.ConvertTextKey
-- only substitutes positional {N_Tag} placeholders inside a format string;
-- bare engine keys carry no placeholder of their own, so handing them
-- straight to the runner yields the key string back unchanged. We swap in
-- a real template per game key here so the test can assert on the
-- substituted value.
local GAME_KEY_TEMPLATES = {
    TXT_KEY_CITYVIEW_WLTKD_COUNTER = "we love the king day {1_Num} turns",
    TXT_KEY_CITYVIEW_RESOURCE_DEMANDED = "demanded resource {1_Resource}",
}

local function setup()
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_CitySpeech.lua")
    dofile("src/dlc/UI/InGame/CityView/CivVAccess_CityStats.lua")

    -- Locale.Compare is nil under the runner's polyfill (it only stubs
    -- ConvertTextKey / Lookup). resourceRows sorts strategics and luxes
    -- alphabetically, so a Compare stub is required.
    Locale.Compare = function(a, b)
        if a == b then
            return 0
        end
        if a < b then
            return -1
        end
        return 1
    end

    -- Wrap the runner's ConvertTextKey so engine TXT keys map to real
    -- format strings before substitution. Idempotent: a re-setup() inside
    -- the same suite returns the wrapped fn untouched.
    if not Locale._cityStatsKeyWrap then
        local prev = Locale.ConvertTextKey
        Locale.ConvertTextKey = function(key, ...)
            local template = GAME_KEY_TEMPLATES[key]
            if template ~= nil then
                return prev(template, ...)
            end
            return prev(key, ...)
        end
        Locale._cityStatsKeyWrap = true
    end

    GameInfo = GameInfo or {}
    GameInfo.Religions = GameInfo.Religions or {}
    GameInfo.Resources = GameInfo.Resources or {}
    GameInfo.Buildings = GameInfo.Buildings or {}
    GameInfo.Units = GameInfo.Units or {}

    -- Iterating GameInfo.Religions() in production walks the engine's
    -- iterator. The test stub mirrors that: the table doubles as an
    -- iteration source via metatable __call (production uses
    -- "for r in GameInfo.Religions()") and as an id-keyed lookup
    -- ("GameInfo.Religions[id]").
    local function makeIterableTable(rows)
        local t = {}
        local idIndex = {}
        for _, row in ipairs(rows) do
            t[#t + 1] = row
            idIndex[row.ID] = row
        end
        setmetatable(t, {
            __call = function(self)
                local i = 0
                return function()
                    i = i + 1
                    return self[i]
                end
            end,
            __index = function(_, key)
                return idIndex[key]
            end,
        })
        return t
    end
    _G.makeIterableTable = makeIterableTable

    GameDefines = GameDefines or {}
    GameDefines.MAX_CITY_HIT_POINTS = 200
    GameDefines["RELIGION_MISSIONARY_PRESSURE_MULTIPLIER"] = 10

    YieldTypes = YieldTypes
        or {
            YIELD_FOOD = 0,
            YIELD_PRODUCTION = 1,
            YIELD_GOLD = 2,
            YIELD_SCIENCE = 3,
            YIELD_CULTURE = 4,
            YIELD_FAITH = 5,
        }
    DomainTypes = DomainTypes or { DOMAIN_LAND = 0, DOMAIN_SEA = 1 }
    ResourceUsageTypes = ResourceUsageTypes
        or {
            RESOURCEUSAGE_BONUS = 0,
            RESOURCEUSAGE_STRATEGIC = 1,
            RESOURCEUSAGE_LUXURY = 2,
        }
end

-- ===== Yields =====

function M.test_yields_speak_per_turn_for_seven_yields()
    setup()
    local city = mkCity({
        foodDifference = 5,
        yieldRate = {
            [YieldTypes.YIELD_PRODUCTION] = 12,
            [YieldTypes.YIELD_GOLD] = 8,
            [YieldTypes.YIELD_SCIENCE] = 14,
            [YieldTypes.YIELD_FAITH] = 3,
            [YieldTypes.YIELD_CULTURE] = 6,
        },
        baseTourism = 250,
    })
    -- No tooltip helpers wired so breakdown is empty; we're only testing
    -- the per-yield headers. Pass an explicit fn that returns nil.
    local rows = CityStats.yieldRows(city, function()
        return nil
    end)
    T.eq(#rows, 7)
    T.truthy(rows[1].label:find("food 5", 1, true), "food per-turn label")
    T.truthy(rows[2].label:find("production 12", 1, true), "production per-turn label")
    T.truthy(rows[3].label:find("gold 8", 1, true), "gold per-turn label")
    T.truthy(rows[4].label:find("science 14", 1, true), "science per-turn label")
    T.truthy(rows[5].label:find("faith 3", 1, true), "faith per-turn label")
    -- Tourism reads /100 to match the banner's integer display.
    T.truthy(rows[6].label:find("tourism 2", 1, true), "tourism scaled per-turn label")
    T.truthy(rows[7].label:find("culture 6", 1, true), "culture per-turn label")
end

function M.test_yields_drillin_splits_tooltip_on_newline_and_filters_markup()
    setup()
    local city = mkCity()
    local fn = function(_yieldKey)
        return function()
            return "[ICON_BULLET]2[ICON_FOOD] from terrain[NEWLINE][ICON_BULLET]3[ICON_FOOD] from buildings[NEWLINE]"
        end
    end
    local rows = CityStats.yieldRows(city, fn)
    -- Trailing [NEWLINE] produces an empty chunk that the splitter drops,
    -- so we expect exactly two rows in the breakdown (terrain, buildings).
    T.eq(#rows[1].breakdown, 2)
    T.truthy(rows[1].breakdown[1]:find("from terrain", 1, true))
    T.truthy(rows[1].breakdown[2]:find("from buildings", 1, true))
end

function M.test_yields_drillin_handles_helper_returning_nil()
    setup()
    local city = mkCity()
    local rows = CityStats.yieldRows(city, function()
        return nil
    end)
    -- All seven yields stay in the list with empty breakdown so the
    -- per-yield header still announces (the wrapper substitutes a
    -- "no breakdown" leaf at draw time).
    T.eq(#rows, 7)
    for _, row in ipairs(rows) do
        T.eq(#row.breakdown, 0)
    end
end

-- ===== Growth =====

function M.test_growth_speaks_progress_perturn_and_turns_to_grow()
    setup()
    local city = mkCity({ food = 12, growthThreshold = 22, foodDifference = 3, foodTurnsLeft = 4 })
    local rows = CityStats.growthRows(city)
    T.truthy(rows[1]:find("12", 1, true), "food progress numerator")
    T.truthy(rows[1]:find("22", 1, true), "food progress denominator")
    T.truthy(rows[2]:find("3", 1, true), "food per-turn")
    T.truthy(rows[3]:find("4", 1, true), "turns-to-grow")
end

function M.test_growth_speaks_starving_when_food_negative()
    setup()
    local city = mkCity({ foodDifference = -2, foodDifferenceTimes100 = -200 })
    local rows = CityStats.growthRows(city)
    -- The growth-headline row substitutes "starving" for the turn count.
    local last = rows[#rows]
    T.truthy(last:find("starving", 1, true), "starving headline expected")
end

function M.test_growth_speaks_stopped_growing_when_zero_diff()
    setup()
    local city = mkCity({ foodDifference = 0, foodDifferenceTimes100 = 0 })
    local rows = CityStats.growthRows(city)
    local last = rows[#rows]
    T.truthy(last:find("stopped growing", 1, true), "stopped-growing headline expected")
end

-- ===== Culture =====

function M.test_culture_speaks_progress_perturn_and_turns_to_tile()
    setup()
    local city = mkCity({ cultureStored = 5, cultureThreshold = 25, culturePerTurn = 4 })
    local rows = CityStats.cultureRows(city)
    T.truthy(rows[1]:find("5", 1, true), "culture stored")
    T.truthy(rows[1]:find("25", 1, true), "culture threshold")
    T.truthy(rows[2]:find("4", 1, true), "culture per-turn")
    -- (25 - 5) / 4 = 5 turns
    T.truthy(rows[3]:find("5", 1, true), "turns-to-next-tile")
end

function M.test_culture_speaks_stalled_when_no_culture_per_turn()
    setup()
    local city = mkCity({ culturePerTurn = 0 })
    local rows = CityStats.cultureRows(city)
    -- Last row swaps to the stalled marker rather than reading "next tile in 0".
    T.truthy(rows[#rows]:find("stalled", 1, true), "stalled marker expected")
end

-- ===== Happiness =====

function M.test_happiness_speaks_local_and_unhappiness()
    setup()
    local city = mkCity({ localHappiness = 6 })
    -- GetUnhappinessFromCityForUI returns *100 to match the engine's
    -- division pattern. 350 -> 3 unhappiness.
    local player = mkPlayer({ unhappinessFromCity = 350 })
    local rows = CityStats.happinessRows(city, player)
    T.eq(#rows, 2)
    T.truthy(rows[1]:find("local happiness 6", 1, true), "local happiness")
    T.truthy(rows[2]:find("unhappiness 3", 1, true), "unhappiness scaled to integer")
end

-- ===== Religion =====

function M.test_religion_skips_when_no_religions_present()
    setup()
    GameInfo.Religions = makeIterableTable({})
    local city = mkCity()
    local rows = CityStats.religionRows(city)
    T.eq(#rows, 0)
end

function M.test_religion_speaks_majority_first_then_others_with_followers()
    setup()
    GameInfo.Religions = makeIterableTable({
        { ID = 1, Description = "Christianity" },
        { ID = 2, Description = "Buddhism" },
        { ID = 3, Description = "Islam" },
    })
    local city = mkCity({
        religiousMajority = 2,
        followers = { [1] = 4, [2] = 9, [3] = 0 },
        pressure = { [1] = 50, [2] = 120, [3] = 0 },
    })
    local rows = CityStats.religionRows(city)
    -- Buddhism (majority) leads, then Christianity (4 followers). Islam
    -- has 0 followers and no holy-city flag, so it's omitted.
    T.eq(#rows, 2)
    T.truthy(rows[1]:find("Buddhism", 1, true), "majority leads")
    T.truthy(rows[1]:find("9 followers", 1, true), "majority follower count")
    -- Pressure 120 / 10 (multiplier) = 12.
    T.truthy(rows[1]:find("12", 1, true), "majority pressure scaled by multiplier")
    T.truthy(rows[2]:find("Christianity", 1, true), "second religion follows majority")
    T.truthy(rows[2]:find("4 followers", 1, true), "second religion follower count")
end

function M.test_religion_holy_city_inlines_into_majority_row()
    setup()
    GameInfo.Religions = makeIterableTable({
        { ID = 1, Description = "Christianity" },
    })
    local city = mkCity({
        religiousMajority = 1,
        followers = { [1] = 10 },
        pressure = { [1] = 80 },
        holyCity = { [1] = true },
    })
    local rows = CityStats.religionRows(city)
    T.eq(#rows, 1)
    T.truthy(rows[1]:find("holy city", 1, true), "holy city flag inlined")
    T.truthy(rows[1]:find("10 followers", 1, true), "followers still spoken")
end

-- ===== Trade =====

function M.test_trade_filters_routes_by_city_id_and_speaks_direction()
    setup()
    local city = mkCity({ id = 42 })
    local rome = {
        GetID = function()
            return 42
        end,
    }
    local berlin = {
        GetID = function()
            return 99
        end,
    }
    local madrid = {
        GetID = function()
            return 17
        end,
    }
    local player = mkPlayer({
        tradeRoutes = {
            -- Outgoing from this city to Berlin
            { FromCity = rome, ToCity = berlin, FromCityName = "Rome", ToCityName = "Berlin", Domain = 0 },
            -- Incoming from Madrid into this city (active player's own internal
            -- route landing here, not a foreign route)
            { FromCity = madrid, ToCity = rome, FromCityName = "Madrid", ToCityName = "Rome", Domain = 1 },
            -- Unrelated route between two other cities
            { FromCity = madrid, ToCity = berlin, FromCityName = "Madrid", ToCityName = "Berlin", Domain = 0 },
        },
    })
    local rows = CityStats.tradeRows(city, player)
    T.eq(#rows, 2)
    T.truthy(rows[1]:find("to Berlin", 1, true), "outgoing speaks 'to'")
    T.truthy(rows[1]:find("land", 1, true), "land domain")
    T.truthy(rows[2]:find("from Madrid", 1, true), "incoming speaks 'from'")
    T.truthy(rows[2]:find("sea", 1, true), "sea domain")
end

function M.test_trade_returns_empty_when_no_routes()
    setup()
    local city = mkCity({ id = 1 })
    local player = mkPlayer({ tradeRoutes = {} })
    T.eq(#CityStats.tradeRows(city, player), 0)
end

-- ===== Resources =====

function M.test_resources_skips_bonus_and_lists_strategics_then_luxes()
    setup()
    GameInfo.Resources = makeIterableTable({
        { ID = 1, Description = "Iron", ResourceUsage = ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC },
        { ID = 2, Description = "Wheat", ResourceUsage = ResourceUsageTypes.RESOURCEUSAGE_BONUS },
        { ID = 3, Description = "Silk", ResourceUsage = ResourceUsageTypes.RESOURCEUSAGE_LUXURY },
        { ID = 4, Description = "Horses", ResourceUsage = ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC },
    })
    local city = mkCity({ resourceLocal = { [1] = true, [2] = true, [3] = true, [4] = true } })
    local rows = CityStats.resourceRows(city)
    -- Bonus dropped; strategics first (Horses, Iron alphabetical), then luxes.
    T.eq(#rows, 3)
    T.truthy(rows[1]:find("Horses", 1, true), "first strategic alphabetical")
    T.truthy(rows[2]:find("Iron", 1, true), "second strategic")
    T.truthy(rows[3]:find("Silk", 1, true), "lux comes after strategics")
end

function M.test_resources_returns_empty_when_no_local_resources()
    setup()
    GameInfo.Resources = makeIterableTable({
        { ID = 1, Description = "Iron", ResourceUsage = ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC },
    })
    local city = mkCity({ resourceLocal = {} })
    T.eq(#CityStats.resourceRows(city), 0)
end

-- ===== Defense =====

function M.test_defense_speaks_strength_hp_and_chain_buildings_in_order()
    setup()
    GameInfo.Buildings = makeIterableTable({
        { ID = 11, Type = "BUILDING_WALLS", Description = "Walls" },
        { ID = 12, Type = "BUILDING_CASTLE", Description = "Castle" },
        { ID = 13, Type = "BUILDING_ARSENAL", Description = "Arsenal" },
        { ID = 14, Type = "BUILDING_MILITARY_BASE", Description = "Military Base" },
    })
    -- Override __index for type-keyed lookup so GameInfo.Buildings[type-string]
    -- returns the row (production code uses Type, not ID).
    setmetatable(GameInfo.Buildings, {
        __call = function(self)
            local i = 0
            return function()
                i = i + 1
                return self[i]
            end
        end,
        __index = function(_, key)
            for _, row in ipairs({
                { ID = 11, Type = "BUILDING_WALLS", Description = "Walls" },
                { ID = 12, Type = "BUILDING_CASTLE", Description = "Castle" },
                { ID = 13, Type = "BUILDING_ARSENAL", Description = "Arsenal" },
                { ID = 14, Type = "BUILDING_MILITARY_BASE", Description = "Military Base" },
            }) do
                if row.ID == key or row.Type == key then
                    return row
                end
            end
            return nil
        end,
    })
    local city = mkCity({
        strength = 3500,
        damage = 50,
        hasBuilding = { [11] = true, [13] = true },
    })
    local rows = CityStats.defenseRows(city)
    -- Strength /100 = 35, HP fraction 150 of 200, then Walls, then Arsenal
    -- (Castle skipped because not built; Military Base skipped because not
    -- built). Order is the chain order, not alphabetical.
    T.truthy(rows[1]:find("35", 1, true), "strength scaled /100")
    T.truthy(rows[2]:find("150", 1, true), "HP numerator")
    T.truthy(rows[2]:find("200", 1, true), "HP denominator")
    T.truthy(rows[3]:find("Walls", 1, true), "Walls before Arsenal")
    T.truthy(rows[4]:find("Arsenal", 1, true), "Arsenal after Walls")
end

function M.test_defense_omits_garrison_when_unmanned()
    setup()
    GameInfo.Buildings = makeIterableTable({})
    setmetatable(GameInfo.Buildings, {
        __call = function(self)
            local i = 0
            return function()
                i = i + 1
                return self[i]
            end
        end,
        __index = function()
            return nil
        end,
    })
    local city = mkCity()
    local rows = CityStats.defenseRows(city)
    for _, row in ipairs(rows) do
        T.falsy(row:find("garrisoned", 1, true), "garrison must not appear when unmanned")
    end
end

function M.test_defense_speaks_garrison_name_when_manned()
    setup()
    GameInfo.Buildings = makeIterableTable({})
    setmetatable(GameInfo.Buildings, {
        __call = function(self)
            local i = 0
            return function()
                i = i + 1
                return self[i]
            end
        end,
        __index = function()
            return nil
        end,
    })
    GameInfo.Units[100] = { Description = "Pikeman" }
    local garrison = {
        GetUnitType = function()
            return 100
        end,
    }
    local city = mkCity({ garrisonedUnit = garrison })
    local rows = CityStats.defenseRows(city)
    local last = rows[#rows]
    T.truthy(last:find("Pikeman", 1, true), "garrison unit name")
end

-- ===== Demand =====

function M.test_demand_omits_when_no_cycle_started()
    setup()
    local city = mkCity({ resourceDemandedTrue = -1 })
    T.truthy(CityStats.demandRow(city) == nil, "no demand row before cycle starts")
end

function M.test_demand_speaks_wltkd_counter_when_active()
    setup()
    local city = mkCity({ resourceDemandedTrue = 5, wltkdCounter = 12 })
    local row = CityStats.demandRow(city)
    T.truthy(row ~= nil, "demand row expected during WLTKD")
    T.truthy(row:find("12", 1, true), "WLTKD turn count present")
end

function M.test_demand_speaks_resource_when_no_active_wltkd()
    setup()
    GameInfo.Resources = makeIterableTable({
        { ID = 7, Description = "Citrus", ResourceUsage = ResourceUsageTypes.RESOURCEUSAGE_LUXURY },
    })
    local city = mkCity({ resourceDemandedTrue = 7, resourceDemanded = 7, wltkdCounter = 0 })
    local row = CityStats.demandRow(city)
    T.truthy(row ~= nil, "demand row expected when resource named")
    T.truthy(row:find("Citrus", 1, true), "demanded resource named")
end

return M
