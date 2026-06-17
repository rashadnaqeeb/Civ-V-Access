-- CityStats data-shaping tests. Covers each pure-data row builder and
-- the headline / one-line label functions: yieldRows (with food /
-- culture extras), happinessLine, religionRows, tradeRouteLabels,
-- resourceLines, defenseHeadline, defenseRows, demandRow. The wrapper
-- builders that wrap rows into BaseMenuItems.Group entries aren't
-- exercised here (their logic is just BaseMenuItems composition,
-- covered by the menu suite); the speech-shaping behavior lives in the
-- row functions.

local T = require("support")
local M = {}

-- ===== Plot stub =====
-- Implements only the methods CityStats reads from a plot during the
-- resource-line walk. Each plot carries a resource id (-1 = none), a
-- count, and the owning city handle (for the "is this plot mine?"
-- check).
local function mkPlot(opts)
    opts = opts or {}
    local p = {
        _resourceType = (opts.resourceType == nil) and -1 or opts.resourceType,
        _numResource = opts.numResource or 0,
        _plotCity = opts.plotCity,
    }
    function p:GetResourceType()
        return self._resourceType
    end
    function p:GetNumResource()
        return self._numResource
    end
    function p:GetPlotCity()
        return self._plotCity
    end
    return p
end

-- ===== City stub =====
-- Implements only the methods CityStats reads. opts overrides let each
-- test express the diffs it cares about; defaults model an own-team
-- city with full HP, no demand, no religion present, no trade routes,
-- no plots of interest.
local function mkCity(opts)
    opts = opts or {}
    local c = {
        _id = opts.id or 7,
        _owner = opts.owner or 0,
        _team = opts.team or 0,
        _strength = opts.strength or 2200,
        _rangedStrength = opts.rangedStrength,
        _damage = opts.damage or 0,
        _maxHitPoints = opts.maxHitPoints or 200,
        _yieldRateTimes100 = opts.yieldRateTimes100 or {},
        _foodDifference = opts.foodDifference or 3,
        _foodDifferenceTimes100 = (opts.foodDifferenceTimes100 == nil) and 300 or opts.foodDifferenceTimes100,
        _isFoodProduction = opts.isFoodProduction or false,
        _foodTurnsLeft = opts.foodTurnsLeft or 7,
        _food = opts.food or 12,
        _growthThreshold = opts.growthThreshold or 22,
        _yieldRate = opts.yieldRate or {},
        _productionDifferenceTimes100 = (opts.productionDifferenceTimes100 == nil) and 0
            or opts.productionDifferenceTimes100,
        _baseTourism = opts.baseTourism or 0,
        _cultureStored = opts.cultureStored or 4,
        _cultureThreshold = opts.cultureThreshold or 30,
        _culturePerTurn = opts.culturePerTurn or 0,
        _faithPerTurn = opts.faithPerTurn or 0,
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
        _plots = opts.plots or {},
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
    function c:GetStrengthValue(forRangeStrike)
        if forRangeStrike then
            return self._rangedStrength or self._strength
        end
        return self._strength
    end
    function c:GetDamage()
        return self._damage
    end
    function c:GetMaxHitPoints()
        return self._maxHitPoints
    end
    function c:GetYieldRateTimes100(yid)
        return self._yieldRateTimes100[yid] or 0
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
    function c:GetCurrentProductionDifferenceTimes100(_includeOverflow, _includeBonusFromCarryover)
        return self._productionDifferenceTimes100
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
    function c:GetFaithPerTurn()
        return self._faithPerTurn
    end
    function c:GetLocalHappiness()
        return self._localHappiness
    end
    -- Defined only when the test supplies fixture strings so cities in
    -- vanilla-path tests keep probing as vanilla (the production code
    -- feature-detects on method presence).
    if opts.happinessBreakdown ~= nil then
        function c:GetCityHappinessBreakdown()
            return opts.happinessBreakdown
        end
    end
    if opts.unhappinessBreakdown ~= nil then
        function c:GetCityUnhappinessBreakdown(includeMedian)
            self._unhappinessIncludeMedian = includeMedian
            return opts.unhappinessBreakdown
        end
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
    function c:IsHasResourceLocal(rid, _bTestVisible)
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
    function c:GetNumCityPlots()
        return #self._plots
    end
    function c:GetCityIndexPlot(i)
        -- Production code passes 0..GetNumCityPlots()-1; remap to 1-based.
        return self._plots[i + 1]
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
    TXT_KEY_CITYVIEW_WLTKD_COUNTER_UA_1 = "we love the empress day {1_Num} turns",
    TXT_KEY_CITYVIEW_WLTKD_COUNTER_UA_2 = "carnival {1_Num} turns",
}

local function setup()
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_CitySpeech.lua")
    -- TradeRouteRow is included by CityStats in-game; the test runner's
    -- include() is a no-op, so dofile it here to populate the global.
    dofile("src/dlc/UI/InGame/Popups/CivVAccess_TradeRouteRow.lua")
    dofile("src/dlc/UI/InGame/CityView/CivVAccess_CityStats.lua")

    -- Locale.Compare is nil under the runner's polyfill (it only stubs
    -- ConvertTextKey / Lookup). resourceLines sorts strategics and luxes
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
    -- format strings before substitution. The runner resets ConvertTextKey
    -- to the base-game baseline before each case, so re-wrap whenever the
    -- current resolver isn't our wrapper (a fresh baseline); a repeat
    -- setup() within one case sees the wrapper already installed and leaves
    -- it untouched, so the wrap never stacks.
    if Locale.ConvertTextKey ~= Locale._cityStatsWrapped then
        local prev = Locale.ConvertTextKey
        Locale._cityStatsWrapped = function(key, ...)
            local template = GAME_KEY_TEMPLATES[key]
            if template ~= nil then
                return prev(template, ...)
            end
            return prev(key, ...)
        end
        Locale.ConvertTextKey = Locale._cityStatsWrapped
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
    -- ("GameInfo.Religions[id]"). Also wires Game.GetReligionName(id) to
    -- return the row's Description so the engine call CityStats makes for
    -- the player-facing name resolves to the same fixture string --
    -- production reads the player's custom religion name through that
    -- engine call rather than the default Description.
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
        Game.GetReligionName = function(rid)
            local row = idIndex[rid]
            return row and row.Description or ""
        end
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
        foodDifferenceTimes100 = 500,
        food = 12,
        growthThreshold = 22,
        foodTurnsLeft = 2,
        -- Production reads GetCurrentProductionDifferenceTimes100 (post
        -- modifiers, matches CityView's banner). 1250 -> 12.
        productionDifferenceTimes100 = 1250,
        yieldRate = {
            [YieldTypes.YIELD_GOLD] = 8,
            [YieldTypes.YIELD_SCIENCE] = 14,
        },
        baseTourism = 2,
        faithPerTurn = 3,
        cultureStored = 5,
        cultureThreshold = 25,
        culturePerTurn = 6,
    })
    local rows = CityStats.yieldRows(city, function()
        return nil
    end)
    T.eq(#rows, 7)
    -- Food row's headline includes the per-turn rate, then storage tail,
    -- then the grows-in countdown.
    T.truthy(rows[1].label:find("food +5", 1, true), "food per-turn label, signed for growth")
    T.truthy(rows[1].label:find("12 of 22", 1, true), "food storage tail")
    T.truthy(rows[1].label:find("2 turn", 1, true), "food turns-to-grow tail")
    T.truthy(rows[2].label:find("production 12", 1, true), "production per-turn label (post-modifiers)")
    T.truthy(rows[3].label:find("gold 8", 1, true), "gold per-turn label")
    T.truthy(rows[4].label:find("science 14", 1, true), "science per-turn label")
    T.truthy(rows[5].label:find("faith 3", 1, true), "faith per-turn label")
    -- Tourism comes from the EngineData seam as a plain rate (the vanilla
    -- body loaded here passes GetBaseTourism through; the VP body floors its
    -- times-100 getter, covered in the engine_data parity suite).
    T.truthy(rows[6].label:find("tourism 2", 1, true), "tourism per-turn label")
    -- Culture row's headline includes the per-turn rate, then storage,
    -- then the next-tile countdown ((25-5)/6 = ~4 turns ceiled).
    T.truthy(rows[7].label:find("culture +6", 1, true), "culture per-turn label, signed for growth")
    T.truthy(rows[7].label:find("5 of 25", 1, true), "culture storage tail")
    T.truthy(rows[7].label:find("next tile", 1, true), "culture next-tile tail")
end

function M.test_yields_food_label_starving_when_negative_diff()
    setup()
    local city = mkCity({
        foodDifference = -2,
        foodDifferenceTimes100 = -200,
        food = 12,
        growthThreshold = 22,
    })
    local rows = CityStats.yieldRows(city, function()
        return nil
    end)
    T.truthy(rows[1].label:find("food -2", 1, true), "negative food rate spoken on headline")
    T.truthy(rows[1].label:find("starving", 1, true), "starving marker in tail")
end

function M.test_yields_food_label_stopped_when_zero_diff()
    setup()
    local city = mkCity({
        foodDifference = 0,
        foodDifferenceTimes100 = 0,
        food = 12,
        growthThreshold = 22,
    })
    local rows = CityStats.yieldRows(city, function()
        return nil
    end)
    T.truthy(rows[1].label:find("food 0", 1, true), "zero food rate spoken on headline")
    T.truthy(rows[1].label:find("stopped growing", 1, true), "stopped-growing marker in tail")
end

function M.test_yields_food_label_stopped_when_food_production()
    setup()
    -- Wonder using food-as-production: positive raw food, but engine
    -- routes it into production so growth halts.
    local city = mkCity({
        foodDifference = 5,
        foodDifferenceTimes100 = 500,
        isFoodProduction = true,
    })
    local rows = CityStats.yieldRows(city, function()
        return nil
    end)
    T.truthy(rows[1].label:find("stopped growing", 1, true), "food-into-production halts growth")
end

function M.test_yields_culture_label_stalled_when_no_culture()
    setup()
    local city = mkCity({ culturePerTurn = 0, cultureStored = 5, cultureThreshold = 25 })
    local rows = CityStats.yieldRows(city, function()
        return nil
    end)
    T.truthy(rows[7].label:find("culture 0", 1, true), "zero culture rate spoken on headline")
    T.truthy(rows[7].label:find("stalled", 1, true), "stalled marker in culture tail")
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

function M.test_yields_faith_drillin_drops_religion_tooltip_suffix()
    setup()
    local city = mkCity()
    -- Mirror what GetFaithTooltip emits in the BNW source: per-source
    -- bullets joined with [NEWLINE], then a "----------------" separator,
    -- then the appended GetReligionTooltip. The strip pass should keep
    -- only the bullets and discard everything from the separator on.
    local fakeFaith = "[ICON_BULLET]2 from buildings[NEWLINE][ICON_BULLET]1 from terrain"
        .. "[NEWLINE]----------------[NEWLINE]Christianity, 5 followers, 8 pressure"
    local rows = CityStats.yieldRows(city, function(yieldKey)
        if yieldKey == "FAITH" then
            return function()
                return fakeFaith
            end
        end
        return nil
    end)
    -- Faith is row 5. Expect terrain + buildings only; no separator,
    -- no religion-tooltip lines.
    local faith = rows[5]
    T.eq(#faith.breakdown, 2)
    T.truthy(faith.breakdown[1]:find("from buildings", 1, true), "first faith source kept")
    T.truthy(faith.breakdown[2]:find("from terrain", 1, true), "second faith source kept")
    for _, line in ipairs(faith.breakdown) do
        T.falsy(line:find("Christianity", 1, true), "religion tooltip suffix must not leak in")
        T.falsy(line:find("----", 1, true), "separator line must not leak in")
    end
end

function M.test_yields_drillin_drops_engine_dash_separator()
    setup()
    local city = mkCity()
    -- GetYieldTooltip wraps the base / modifier sections of every
    -- non-faith yield breakdown with "----------------" rows
    -- ("[NEWLINE]----------------[NEWLINE]"). After splitting on
    -- [NEWLINE] each separator is its own chunk; the row filter must
    -- drop it so the user doesn't land on a row of dashes.
    local fakeBreakdown = "[ICON_BULLET]2 from terrain[NEWLINE]----------------"
        .. "[NEWLINE]base 2[NEWLINE]----------------[NEWLINE]total 4"
    local rows = CityStats.yieldRows(city, function(yieldKey)
        if yieldKey == "GOLD" then
            return function()
                return fakeBreakdown
            end
        end
        return nil
    end)
    local gold = rows[3]
    for _, line in ipairs(gold.breakdown) do
        T.falsy(line:find("----", 1, true), "dash separator must not leak in as a row")
    end
    T.eq(#gold.breakdown, 3)
end

function M.test_yields_drillin_handles_helper_returning_nil()
    setup()
    local city = mkCity()
    local rows = CityStats.yieldRows(city, function()
        return nil
    end)
    T.eq(#rows, 7)
    for _, row in ipairs(rows) do
        T.eq(#row.breakdown, 0)
    end
end

-- ===== Happiness =====

function M.test_happiness_line_speaks_local_and_unhappiness()
    setup()
    local city = mkCity({ localHappiness = 6 })
    -- GetUnhappinessFromCityForUI returns *100 to match the engine's
    -- division pattern. 350 -> 3 unhappiness.
    local player = mkPlayer({ unhappinessFromCity = 350 })
    local line = CityStats.happinessLine(city, player)
    T.truthy(line:find("local happiness 6", 1, true), "local happiness")
    T.truthy(line:find("unhappiness 3", 1, true), "unhappiness scaled to integer")
end

-- ===== Religion =====

function M.test_religion_skips_when_no_religions_present()
    setup()
    GameInfo.Religions = makeIterableTable({})
    local city = mkCity()
    T.eq(#CityStats.religionRows(city), 0)
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

-- Trade tests target the FILTERING done by tradeRouteLabels. The label
-- string is built by the shared TradeRouteRow.rowLabel which carries
-- its own broader formatting (city-state vs major civ, yield split
-- per side, religion-pressure naming) and would require a sprawl of
-- Game / Players / engine TXT_KEY fixtures to assert end-to-end. To
-- isolate the filtering, swap rowLabel for a deterministic stand-in
-- per test that returns a recognizable token; the production fn is
-- restored on the next setup().
local function swapRowLabel(stand_in)
    TradeRouteRow.rowLabel = stand_in
end

function M.test_trade_filters_by_origin_or_destination_city_id()
    setup()
    swapRowLabel(function(route)
        return "route:" .. route.FromCityName .. "->" .. route.ToCityName
    end)
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
            -- Incoming to this city from Madrid (one of our internal routes)
            { FromCity = madrid, ToCity = rome, FromCityName = "Madrid", ToCityName = "Rome", Domain = 1 },
            -- Unrelated route between two other cities
            { FromCity = madrid, ToCity = berlin, FromCityName = "Madrid", ToCityName = "Berlin", Domain = 0 },
        },
    })
    local labels = CityStats.tradeRouteLabels(city, player)
    T.eq(#labels, 2)
    T.eq(labels[1], "route:Rome->Berlin")
    T.eq(labels[2], "route:Madrid->Rome")
end

function M.test_trade_returns_empty_when_no_routes()
    setup()
    swapRowLabel(function()
        return "should-not-be-called"
    end)
    local city = mkCity({ id = 1 })
    local player = mkPlayer({ tradeRoutes = {} })
    T.eq(#CityStats.tradeRouteLabels(city, player), 0)
end

function M.test_trade_returns_empty_when_routes_accessor_returns_nil()
    setup()
    swapRowLabel(function()
        return "should-not-be-called"
    end)
    local city = mkCity({ id = 1 })
    -- Player whose GetTradeRoutes returns nil (engine sometimes returns
    -- nil before any trade unit has been built). tradeRouteLabels must
    -- short-circuit rather than crash on nil iteration.
    local player = mkPlayer()
    function player:GetTradeRoutes()
        return nil
    end
    T.eq(#CityStats.tradeRouteLabels(city, player), 0)
end

-- ===== Resources =====

-- Plots stubs let resourceLines walk the city's working radius. The
-- production code requires plot owner == this city AND
-- city:IsHasResourceLocal(rid) == true; tests model both gates.

function M.test_resources_walks_plots_and_includes_counts()
    setup()
    GameInfo.Resources = makeIterableTable({
        { ID = 1, Description = "Iron", ResourceUsage = ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC },
        { ID = 2, Description = "Wheat", ResourceUsage = ResourceUsageTypes.RESOURCEUSAGE_BONUS },
        { ID = 3, Description = "Silk", ResourceUsage = ResourceUsageTypes.RESOURCEUSAGE_LUXURY },
        { ID = 4, Description = "Horses", ResourceUsage = ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC },
    })
    local city
    city = mkCity({
        id = 7,
        resourceLocal = { [1] = true, [3] = true, [4] = true },
    })
    -- Plots owned by city 7 with assorted resources. Plot owner is set
    -- after the city is created so the back-reference resolves.
    city._plots = {
        mkPlot({ resourceType = 1, numResource = 2, plotCity = city }),
        mkPlot({ resourceType = 2, numResource = 1, plotCity = city }), -- Wheat (BONUS, dropped)
        mkPlot({ resourceType = 3, numResource = 1, plotCity = city }),
        mkPlot({ resourceType = 4, numResource = 4, plotCity = city }),
        mkPlot({ resourceType = -1, numResource = 0, plotCity = city }), -- empty plot
    }
    local rows = CityStats.resourceLines(city)
    -- Bonus dropped; strategics first (alphabetical: Horses, Iron), then luxes.
    T.eq(#rows, 3)
    T.truthy(rows[1]:find("Horses 4", 1, true), "first strategic with count")
    T.truthy(rows[2]:find("Iron 2", 1, true), "second strategic with count")
    T.truthy(rows[3]:find("Silk 1", 1, true), "lux with count of 1")
end

function M.test_resources_skips_plot_when_local_is_false()
    setup()
    GameInfo.Resources = makeIterableTable({
        { ID = 1, Description = "Iron", ResourceUsage = ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC },
    })
    local city
    city = mkCity({
        id = 7,
        resourceLocal = {}, -- iron present on a plot, but linked to a sibling city
    })
    city._plots = {
        mkPlot({ resourceType = 1, numResource = 3, plotCity = city }),
    }
    T.eq(#CityStats.resourceLines(city), 0)
end

function M.test_resources_skips_plot_when_owner_differs()
    setup()
    GameInfo.Resources = makeIterableTable({
        { ID = 1, Description = "Iron", ResourceUsage = ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC },
    })
    local city = mkCity({ id = 7, resourceLocal = { [1] = true } })
    -- Plot's plot-city is some OTHER city (id 99). resourceLines must
    -- skip plots whose owner isn't this city, even when the resource
    -- type is locally available via a different plot.
    local otherCity = {
        GetID = function()
            return 99
        end,
    }
    city._plots = {
        mkPlot({ resourceType = 1, numResource = 4, plotCity = otherCity }),
    }
    T.eq(#CityStats.resourceLines(city), 0)
end

function M.test_resources_returns_empty_when_no_plots()
    setup()
    GameInfo.Resources = makeIterableTable({})
    local city = mkCity()
    T.eq(#CityStats.resourceLines(city), 0)
end

-- ===== Defense =====

function M.test_defense_headline_speaks_strength_and_hp()
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
    local city = mkCity({ strength = 3500, damage = 50 })
    local headline = CityStats.defenseHeadline(city)
    -- Strength /100 = 35; HP fraction 150 of 200.
    T.truthy(headline:find("35 defense", 1, true), "strength scaled /100")
    T.truthy(headline:find("150 of 200", 1, true), "HP fraction")
end

function M.test_defense_drillin_lists_chain_buildings_and_garrison()
    setup()
    GameInfo.BuildingClasses = {}
    GameInfo.Buildings = makeIterableTable({
        { ID = 11, Type = "BUILDING_WALLS", Description = "Walls", Defense = 500 },
        { ID = 12, Type = "BUILDING_CASTLE", Description = "Castle", Defense = 700 },
        { ID = 13, Type = "BUILDING_ARSENAL", Description = "Arsenal", Defense = 900 },
        { ID = 14, Type = "BUILDING_MILITARY_BASE", Description = "Military Base", Defense = 1200 },
        { ID = 15, Type = "BUILDING_GRANARY", Description = "Granary" },
    })
    GameInfo.Units[100] = { Description = "Pikeman" }
    local garrison = {
        GetUnitType = function()
            return 100
        end,
    }
    local city = mkCity({
        hasBuilding = { [11] = true, [13] = true },
        garrisonedUnit = garrison,
    })
    local rows = CityStats.defenseRows(city)
    -- Walls, Arsenal (chain order, not alphabetical), then garrison line.
    T.eq(#rows, 3)
    T.truthy(rows[1]:find("Walls", 1, true), "Walls first in chain")
    T.truthy(rows[2]:find("Arsenal", 1, true), "Arsenal after Walls (Castle skipped)")
    T.truthy(rows[3]:find("Pikeman", 1, true), "garrison unit name last")
end

function M.test_defense_drillin_omits_garrison_when_unmanned()
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

-- ===== Demand =====

function M.test_defense_chain_is_schema_driven_and_excludes_wonders()
    setup()
    GameInfo.BuildingClasses = {
        BUILDINGCLASS_REGULAR = { MaxGlobalInstances = 0, MaxTeamInstances = 0, MaxPlayerInstances = 0 },
        BUILDINGCLASS_WONDER = { MaxGlobalInstances = 1, MaxTeamInstances = 0, MaxPlayerInstances = 0 },
    }
    GameInfo.Buildings = makeIterableTable({
        -- A unique replacement absent from any name list, a CP-style
        -- addition, and a strength-granting wonder that must stay out.
        {
            ID = 21,
            Type = "BUILDING_WALLS_OF_BABYLON",
            Description = "Walls of Babylon",
            Defense = 600,
            BuildingClass = "BUILDINGCLASS_REGULAR",
        },
        {
            ID = 22,
            Type = "BUILDING_BASTION_FORT",
            Description = "Bastion Fort",
            Defense = 1000,
            BuildingClass = "BUILDINGCLASS_REGULAR",
        },
        {
            ID = 23,
            Type = "BUILDING_RED_FORT",
            Description = "Red Fort",
            Defense = 600,
            BuildingClass = "BUILDINGCLASS_WONDER",
        },
    })
    local city = mkCity({ hasBuilding = { [21] = true, [22] = true, [23] = true } })
    local rows = CityStats.defenseRows(city)
    T.eq(#rows, 2)
    T.truthy(rows[1]:find("Walls of Babylon", 1, true), "unique replacement included, lower defense first")
    T.truthy(rows[2]:find("Bastion Fort", 1, true), "schema addition included")
    for _, row in ipairs(rows) do
        T.falsy(row:find("Red Fort", 1, true), "wonders stay in the Wonders group")
    end
end

function M.test_defense_headline_appends_ranged_strength_on_cp()
    setup()
    local city = mkCity({ strength = 3500, rangedStrength = 4200, damage = 0 })
    local vanillaHeadline = CityStats.defenseHeadline(city)
    T.falsy(vanillaHeadline:find("ranged strength", 1, true), "no ranged part on vanilla")
    Game.IsCustomModOption = function()
        return false
    end
    local ok, cpHeadline = pcall(CityStats.defenseHeadline, city)
    Game.IsCustomModOption = nil
    T.truthy(ok, "headline under CP: " .. tostring(cpHeadline))
    T.truthy(cpHeadline:find("42 ranged strength", 1, true), "ranged strength scaled /100 under CP")
end

-- ===== Happiness breakdown (VP balance) =====

function M.test_happiness_breakdown_rows_split_engine_string()
    setup()
    local city = mkCity({
        happinessBreakdown = "[ICON_HAPPINESS_1] From buildings: 4[NEWLINE]From policies: 2",
        unhappinessBreakdown = "Distress: 3[NEWLINE][NEWLINE]Poverty: 1",
    })
    local rows = CityStats.happinessBreakdownRows(city)
    T.eq(#rows, 2)
    T.truthy(rows[1]:find("From buildings: 4", 1, true), "first source line, icon stripped")
    T.eq(rows[2], "From policies: 2")
    local unhappyRows = CityStats.unhappinessBreakdownRows(city)
    T.eq(#unhappyRows, 2, "empty chunk from double newline dropped")
    T.eq(unhappyRows[1], "Distress: 3")
    T.truthy(city._unhappinessIncludeMedian == true, "median context requested, matching CP's city-screen tooltip")
end

-- ===== Culture under Community Patch =====

function M.test_culture_rate_keeps_fraction_and_border_lines_on_cp()
    setup()
    YieldTypes.YIELD_CULTURE_LOCAL = 20
    Game.IsCustomModOption = function()
        return false
    end
    GetBorderGrowthTooltip = function()
        return "Border growth from culture: 3[NEWLINE]Border growth from buildings: 2"
    end
    local city = mkCity({
        yieldRateTimes100 = { [YieldTypes.YIELD_CULTURE] = 450, [20] = 200 },
        cultureStored = 4,
        cultureThreshold = 30,
    })
    local ok, rows = pcall(CityStats.yieldRows, city, function()
        return nil
    end)
    Game.IsCustomModOption = nil
    GetBorderGrowthTooltip = nil
    YieldTypes.YIELD_CULTURE_LOCAL = nil
    T.truthy(ok, "yieldRows under CP: " .. tostring(rows))
    local culture = rows[#rows]
    T.truthy(culture.label:find("4.5", 1, true), "culture fraction kept under CP")
    -- Border growth: (30 - 4) / 2 = 13 turns, from the CULTURE_LOCAL rate,
    -- not the total culture yield.
    T.truthy(culture.label:find("13", 1, true), "tile ETA divides by the border-growth yield")
    T.eq(#culture.breakdown, 2)
    T.truthy(culture.breakdown[1]:find("Border growth from culture", 1, true), "border tooltip lines appended")
end

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

-- ===== Demand under Community Patch =====

local function withCP(fn)
    Game.IsCustomModOption = function()
        return false
    end
    local ok, err = pcall(fn)
    Game.IsCustomModOption = nil
    if not ok then
        error(err, 0)
    end
end

function M.test_demand_cp_speaks_ua_wltkd_variants()
    setup()
    withCP(function()
        Players = Players or {}
        Players[0] = {
            IsGPWLTKD = function()
                return true
            end,
            IsCarnaval = function()
                return false
            end,
        }
        -- No visible demand: the UA abilities run WLTKD without one, and
        -- CP still shows the counter.
        local city = mkCity({ owner = 0, resourceDemandedTrue = -1, wltkdCounter = 5 })
        local row = CityStats.demandRow(city)
        T.truthy(row ~= nil, "UA WLTKD row expected without a visible demand")
        T.truthy(row:find("empress", 1, true), "GP-UA counter text")
        Players[0].IsGPWLTKD = function()
            return false
        end
        Players[0].IsCarnaval = function()
            return true
        end
        row = CityStats.demandRow(city)
        T.truthy(row:find("carnival", 1, true), "Carnival counter text")
        Players[0].IsCarnaval = function()
            return false
        end
        row = CityStats.demandRow(city)
        T.truthy(row:find("king day", 1, true), "plain counter text without a UA")
        Players[0] = nil
    end)
end

function M.test_demand_cp_speaks_unknown_when_resource_masked()
    setup()
    withCP(function()
        Players = Players or {}
        Players[0] = {}
        -- Demanded resource exists (unmasked read) but its tech is
        -- unresearched (masked read is -1): CP shows a masked row where
        -- vanilla hides the box entirely.
        local city = mkCity({ owner = 0, resourceDemandedTrue = -1, resourceDemanded = 9, wltkdCounter = 0 })
        local row = CityStats.demandRow(city)
        T.truthy(row ~= nil, "masked demand row expected under CP")
        T.truthy(row:find("research", 1, true), "masked row names the research gate")
        Players[0] = nil
    end)
end

function M.test_demand_vanilla_still_hides_masked_resource()
    setup()
    local city = mkCity({ resourceDemandedTrue = -1, resourceDemanded = 9, wltkdCounter = 0 })
    T.truthy(CityStats.demandRow(city) == nil, "vanilla hides the box when the demand is masked")
end

return M
