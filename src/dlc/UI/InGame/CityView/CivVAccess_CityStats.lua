-- City Stats drillable. The CityView hub item that pushes a sub-handler
-- whose items are BaseMenuItems.Group instances, one per category. Each
-- group contains a flat list of Text rows, except Yields which goes one
-- level deeper (each yield drills into its source-breakdown lines from
-- the engine's Get<Yield>Tooltip output). The category set mirrors the
-- engine's per-city information: yields (with their tooltip drill-ins),
-- growth, culture progress, happiness, religion, trade routes, locally
-- accessible resources, defense, and the WLTKD / resource-demanded line.
--
-- Groups are skipped when they would expose nothing beyond a header --
-- religion before any conversion has happened, trade with no routes
-- touching this city, etc. -- so arrowing through Stats never lands on
-- a group whose drill-in is "no entries". Yields, Growth, Culture,
-- Happiness, and Defense always have content and are unconditional.
--
-- Pure data layer: every entry point takes a city handle plus optional
-- collaborators (active player, the engine's tooltip helpers) and
-- returns either a Group item or nil. The wrapper in CityViewAccess
-- assembles the list and pushes the sub-handler. No state is cached;
-- every group is rebuilt on each Stats push, so a buy / specialist
-- change / route shift in another sub-handler that pops back through
-- Stats produces fresh numbers.

CityStats = {}

-- Engine yield-tooltip helpers. Looked up via the running env at call
-- time so the test harness can substitute its own (the in-game seat
-- gets them via InfoTooltipInclude in the CityView Context's include
-- chain). Production has its own helper that adds modifier prose; the
-- six others share GetYieldTooltipHelper.
local function yieldTooltipFn(yieldKey)
    if yieldKey == "PRODUCTION" then
        return GetProductionTooltip
    elseif yieldKey == "FOOD" then
        return GetFoodTooltip
    elseif yieldKey == "GOLD" then
        return GetGoldTooltip
    elseif yieldKey == "SCIENCE" then
        return GetScienceTooltip
    elseif yieldKey == "CULTURE" then
        return GetCultureTooltip
    elseif yieldKey == "FAITH" then
        return GetFaithTooltip
    elseif yieldKey == "TOURISM" then
        return GetTourismTooltip
    end
    return nil
end

-- Split [NEWLINE]-delimited engine tooltip text into clean per-line speech.
-- TextFilter strips icon / color markup and collapses whitespace; the
-- per-chunk filter pass yields rows the user can arrow through one at a
-- time. Empty chunks (leading newlines, double-newlines) are dropped so
-- a screen-reader doesn't land on a silent item.
local function splitTooltipLines(text)
    if text == nil or text == "" then
        return {}
    end
    local rows = {}
    local cursor = 1
    while true do
        local s, e = string.find(text, "%[NEWLINE%]", cursor, false)
        local chunk
        if s == nil then
            chunk = string.sub(text, cursor)
        else
            chunk = string.sub(text, cursor, s - 1)
        end
        local filtered = TextFilter.filter(chunk)
        if filtered ~= nil and filtered ~= "" then
            rows[#rows + 1] = filtered
        end
        if s == nil then
            break
        end
        cursor = e + 1
    end
    return rows
end

-- Wrap a flat row list in a BaseMenuItems.Group with the given header.
-- Returns nil when skipIfEmpty is set and the row list is empty so the
-- top-level assembler can drop the category entirely (vs. landing the
-- user on a group whose drill-in is "no entries"). Yields keeps its own
-- builder because each yield row drills into a nested breakdown group.
local function buildSimpleGroup(groupKey, rows, skipIfEmpty)
    if skipIfEmpty and #rows == 0 then
        return nil
    end
    local items = {}
    for _, row in ipairs(rows) do
        items[#items + 1] = BaseMenuItems.Text({ labelText = row })
    end
    return BaseMenuItems.Group({
        labelText = Text.key(groupKey),
        items = items,
        cached = false,
    })
end

-- ===== Yields =====

-- The seven yields in preamble order. Each entry pairs a TXT_KEY for the
-- per-turn one-line label with the engine yield-id used by GetYieldRate
-- and the helper-fn key from yieldTooltipFn. Tourism is /100 because the
-- engine's GetBaseTourism returns the *100 form (matches what the banner
-- divides for display).
local YIELD_DEFS = {
    {
        labelKey = "TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_FOOD",
        groupKey = "TXT_KEY_CIVVACCESS_CITYSTATS_YIELD_FOOD",
        helperKey = "FOOD",
        rate = function(c)
            return c:FoodDifference()
        end,
    },
    {
        labelKey = "TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_PRODUCTION",
        groupKey = "TXT_KEY_CIVVACCESS_CITYSTATS_YIELD_PRODUCTION",
        helperKey = "PRODUCTION",
        rate = function(c)
            return c:GetYieldRate(YieldTypes.YIELD_PRODUCTION)
        end,
    },
    {
        labelKey = "TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_GOLD",
        groupKey = "TXT_KEY_CIVVACCESS_CITYSTATS_YIELD_GOLD",
        helperKey = "GOLD",
        rate = function(c)
            return c:GetYieldRate(YieldTypes.YIELD_GOLD)
        end,
    },
    {
        labelKey = "TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_SCIENCE",
        groupKey = "TXT_KEY_CIVVACCESS_CITYSTATS_YIELD_SCIENCE",
        helperKey = "SCIENCE",
        rate = function(c)
            return c:GetYieldRate(YieldTypes.YIELD_SCIENCE)
        end,
    },
    {
        labelKey = "TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_FAITH",
        groupKey = "TXT_KEY_CIVVACCESS_CITYSTATS_YIELD_FAITH",
        helperKey = "FAITH",
        rate = function(c)
            return c:GetYieldRate(YieldTypes.YIELD_FAITH)
        end,
    },
    {
        labelKey = "TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_TOURISM",
        groupKey = "TXT_KEY_CIVVACCESS_CITYSTATS_YIELD_TOURISM",
        helperKey = "TOURISM",
        rate = function(c)
            return math.floor(c:GetBaseTourism() / 100)
        end,
    },
    {
        labelKey = "TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_CULTURE",
        groupKey = "TXT_KEY_CIVVACCESS_CITYSTATS_YIELD_CULTURE",
        helperKey = "CULTURE",
        rate = function(c)
            return c:GetYieldRate(YieldTypes.YIELD_CULTURE)
        end,
    },
}

function CityStats.yieldRows(city, helperFn)
    helperFn = helperFn or yieldTooltipFn
    local groups = {}
    for _, def in ipairs(YIELD_DEFS) do
        local rate = def.rate(city)
        local headerLabel = Text.format(def.labelKey, rate)
        local fn = helperFn(def.helperKey)
        local breakdown = {}
        if fn ~= nil then
            local ok, raw = pcall(fn, city)
            if not ok then
                Log.error("CityStats yield tooltip '" .. def.helperKey .. "' failed: " .. tostring(raw))
            elseif raw ~= nil then
                breakdown = splitTooltipLines(raw)
            end
        end
        groups[#groups + 1] = { label = headerLabel, breakdown = breakdown }
    end
    return groups
end

local function buildYieldsGroup(city)
    local rows = CityStats.yieldRows(city)
    local items = {}
    for _, row in ipairs(rows) do
        local children = {}
        if #row.breakdown == 0 then
            children[#children + 1] = BaseMenuItems.Text({
                labelText = Text.key("TXT_KEY_CIVVACCESS_CITYSTATS_NO_BREAKDOWN"),
            })
        else
            for _, line in ipairs(row.breakdown) do
                children[#children + 1] = BaseMenuItems.Text({ labelText = line })
            end
        end
        items[#items + 1] = BaseMenuItems.Group({
            labelText = row.label,
            items = children,
            cached = false,
        })
    end
    return BaseMenuItems.Group({
        labelText = Text.key("TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_YIELDS"),
        items = items,
        cached = false,
    })
end

-- ===== Growth =====

function CityStats.growthRows(city)
    local rows = {}
    rows[#rows + 1] = Text.format("TXT_KEY_CIVVACCESS_CITY_FOOD_PROGRESS", city:GetFood(), city:GrowthThreshold())
    local foodDiff = city:FoodDifference()
    if foodDiff < 0 then
        rows[#rows + 1] = Text.format("TXT_KEY_CIVVACCESS_CITY_FOOD_LOSING", -foodDiff)
    else
        rows[#rows + 1] = Text.format("TXT_KEY_CIVVACCESS_CITY_FOOD_PER_TURN", foodDiff)
    end
    local foodDiff100 = city:FoodDifferenceTimes100()
    if city:IsFoodProduction() or foodDiff100 == 0 then
        rows[#rows + 1] = Text.key("TXT_KEY_CIVVACCESS_CITY_STOPPED_GROWING")
    elseif foodDiff100 < 0 then
        rows[#rows + 1] = Text.key("TXT_KEY_CIVVACCESS_CITY_STARVING")
    else
        local foodTurnsLeft = city:GetFoodTurnsLeft()
        rows[#rows + 1] = Text.formatPlural("TXT_KEY_CIVVACCESS_CITY_GROWS_IN", foodTurnsLeft, foodTurnsLeft)
    end
    return rows
end

-- ===== Culture =====

-- Stored / threshold / per-turn triple, then the next-tile countdown via
-- CitySpeech.borderGrowthToken (which collapses to a stalled marker when
-- per-turn culture is zero or negative).
function CityStats.cultureRows(city)
    local rows = {}
    rows[#rows + 1] = Text.format(
        "TXT_KEY_CIVVACCESS_CITYSTATS_CULTURE_PROGRESS",
        city:GetJONSCultureStored(),
        city:GetJONSCultureThreshold()
    )
    rows[#rows + 1] = Text.format("TXT_KEY_CIVVACCESS_CITYSTATS_CULTURE_PER_TURN", city:GetJONSCulturePerTurn())
    rows[#rows + 1] = CitySpeech.borderGrowthToken(city)
    return rows
end

-- ===== Happiness =====

-- Per-city numbers that mirror what HappinessInfo.lua reads:
--   pCity:GetLocalHappiness()                  buildings local to this city
--   pPlayer:GetUnhappinessFromCityForUI(city)  the city's contribution to
--                                              empire unhappiness, *100
-- Empire-wide happiness lives in EmpireStatus; this group is strictly
-- per-city.
function CityStats.happinessRows(city, player)
    local rows = {}
    local local_ = city:GetLocalHappiness()
    rows[#rows + 1] = Text.format("TXT_KEY_CIVVACCESS_CITYSTATS_HAPPINESS_LOCAL", local_)
    local unhappiness100 = player:GetUnhappinessFromCityForUI(city)
    local unhappiness = math.floor(unhappiness100 / 100)
    rows[#rows + 1] = Text.format("TXT_KEY_CIVVACCESS_CITYSTATS_HAPPINESS_UNHAPPINESS", unhappiness)
    return rows
end

-- ===== Religion =====

-- Mirrors GetReligionTooltip's iteration: the majority religion first if
-- present, then every other religion with non-zero followers in this city,
-- plus a holy-city flag in either pass when the city is the holy city
-- for that religion. Pressure division /MISSIONARY_PRESSURE_MULTIPLIER
-- matches the engine's display scaling so the number is the per-turn
-- pressure a sighted player sees on hover.
local function pressureToken(pressureRaw)
    local divisor = GameDefines["RELIGION_MISSIONARY_PRESSURE_MULTIPLIER"] or 1
    return math.floor(pressureRaw / divisor)
end

function CityStats.religionRows(city)
    local rows = {}
    local majority = city:GetReligiousMajority()
    local seen = {}
    local function pushRow(religionId)
        local religionInfo = GameInfo.Religions[religionId]
        if religionInfo == nil then
            Log.warn("CityStats: unknown religion id " .. tostring(religionId))
            return
        end
        local religionName = Text.key(religionInfo.Description)
        local followers = city:GetNumFollowers(religionId)
        local pressureRaw = city:GetPressurePerTurn(religionId)
        local pressure = pressureToken(pressureRaw)
        local label
        if city:IsHolyCityForReligion(religionId) then
            label = Text.formatPlural(
                "TXT_KEY_CIVVACCESS_CITYSTATS_RELIGION_HOLY_LINE",
                followers,
                religionName,
                followers,
                pressure
            )
        else
            label = Text.formatPlural(
                "TXT_KEY_CIVVACCESS_CITYSTATS_RELIGION_LINE",
                followers,
                religionName,
                followers,
                pressure
            )
        end
        rows[#rows + 1] = label
        seen[religionId] = true
    end
    if majority ~= nil and majority >= 0 then
        pushRow(majority)
    end
    for religion in GameInfo.Religions() do
        local rid = religion.ID
        if rid >= 0 and not seen[rid] and city:GetNumFollowers(rid) > 0 then
            pushRow(rid)
        end
    end
    return rows
end

-- ===== Trade =====

-- Filters the active player's GetTradeRoutes() to entries whose FromCity
-- or ToCity matches this city by id. Direction labels are "to" (outgoing)
-- and "from" (incoming-from-ours, return leg of an internal route or
-- another city's route landing here). Foreign routes terminating here
-- belong to other players' route lists and aren't reachable from the
-- active player; the engine's TradeRouteOverview shows the same scope.
local function tradeDirectionKey(route, cityId)
    if route.FromCity ~= nil and route.FromCity:GetID() == cityId then
        return "TXT_KEY_CIVVACCESS_CITYSTATS_TRADE_OUTGOING"
    end
    return "TXT_KEY_CIVVACCESS_CITYSTATS_TRADE_INCOMING"
end

local function tradeDomainKey(route)
    if route.Domain == DomainTypes.DOMAIN_SEA then
        return "TXT_KEY_CIVVACCESS_CITYSTATS_TRADE_DOMAIN_SEA"
    end
    return "TXT_KEY_CIVVACCESS_CITYSTATS_TRADE_DOMAIN_LAND"
end

function CityStats.tradeRows(city, player)
    local rows = {}
    local cityId = city:GetID()
    local routes = player:GetTradeRoutes()
    if routes == nil then
        return rows
    end
    for _, route in ipairs(routes) do
        local fromMatch = route.FromCity ~= nil and route.FromCity:GetID() == cityId
        local toMatch = route.ToCity ~= nil and route.ToCity:GetID() == cityId
        if fromMatch or toMatch then
            local partnerName
            if fromMatch then
                partnerName = route.ToCityName or ""
            else
                partnerName = route.FromCityName or ""
            end
            local label = Text.format(
                "TXT_KEY_CIVVACCESS_CITYSTATS_TRADE_ROUTE",
                Text.key(tradeDirectionKey(route, cityId)),
                partnerName,
                Text.key(tradeDomainKey(route))
            )
            rows[#rows + 1] = label
        end
    end
    return rows
end

-- ===== Resources =====

-- Walks GameInfo.Resources() once per push. ResourceUsage 1 = strategic,
-- 2 = luxury (3 = bonus, omitted because bonus resources don't yield
-- anything tradeable or empire-level). Strategics lead the list because
-- they gate units, then luxes alphabetically; both are presence-only
-- since the engine exposes per-city presence (IsHasResourceLocal) but
-- not per-city counts (GetNumResourceAvailable is player-scope).
local function compareLocale(a, b)
    return Locale.Compare(a, b) == -1
end

function CityStats.resourceRows(city)
    local strategics = {}
    local luxes = {}
    for resource in GameInfo.Resources() do
        local usage = resource.ResourceUsage
        if usage == ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC or usage == ResourceUsageTypes.RESOURCEUSAGE_LUXURY then
            local rid = resource.ID
            if city:IsHasResourceLocal(rid) then
                local name = Text.key(resource.Description)
                if usage == ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC then
                    strategics[#strategics + 1] = name
                else
                    luxes[#luxes + 1] = name
                end
            end
        end
    end
    table.sort(strategics, compareLocale)
    table.sort(luxes, compareLocale)
    local rows = {}
    for _, line in ipairs(strategics) do
        rows[#rows + 1] = line
    end
    for _, line in ipairs(luxes) do
        rows[#rows + 1] = line
    end
    return rows
end

-- ===== Defense =====

-- Defensive building chain in upgrade order. Sequenced rather than
-- alphabetical so the user hears the building tree in the order they
-- would have built it. Wonders that grant strength (Statue of Zeus, Great
-- Wall) reach the player through the Wonders sub-handler instead.
local DEFENSIVE_BUILDING_TYPES = {
    "BUILDING_WALLS",
    "BUILDING_CASTLE",
    "BUILDING_ARSENAL",
    "BUILDING_MILITARY_BASE",
}

local function defensiveBuildingNames(city)
    local names = {}
    for _, btype in ipairs(DEFENSIVE_BUILDING_TYPES) do
        local row = GameInfo.Buildings[btype]
        if row ~= nil and city:IsHasBuilding(row.ID) then
            names[#names + 1] = Text.key(row.Description)
        end
    end
    return names
end

local function defenseGarrisonLabel(city)
    local unit = city:GetGarrisonedUnit()
    if unit == nil then
        return nil
    end
    local row = GameInfo.Units[unit:GetUnitType()]
    if row == nil then
        Log.warn("CityStats: garrisoned unit with unknown type " .. tostring(unit:GetUnitType()))
        return nil
    end
    return Text.format("TXT_KEY_CIVVACCESS_CITY_GARRISON", Text.key(row.Description))
end

function CityStats.defenseRows(city)
    local rows = {}
    local strength = math.floor(city:GetStrengthValue() / 100)
    rows[#rows + 1] = Text.format("TXT_KEY_CIVVACCESS_CITY_DEFENSE", strength)
    local maxHP = GameDefines.MAX_CITY_HIT_POINTS
    rows[#rows + 1] = Text.format("TXT_KEY_CIVVACCESS_CITY_HP_FRACTION", maxHP - city:GetDamage(), maxHP)
    for _, name in ipairs(defensiveBuildingNames(city)) do
        rows[#rows + 1] = Text.format("TXT_KEY_CIVVACCESS_CITYSTATS_DEFENSE_BUILDING_LINE", name)
    end
    local garrison = defenseGarrisonLabel(city)
    if garrison ~= nil then
        rows[#rows + 1] = garrison
    end
    return rows
end

-- ===== Demand / WLTKD =====

-- Same gating as the (now-retired) hub-level resourceDemandLabel: if no
-- demand cycle has started the group is omitted; once started, WLTKD
-- counter wins when active, demanded resource otherwise.
function CityStats.demandRow(city)
    if city:GetResourceDemanded(true) == -1 then
        return nil
    end
    local turns = city:GetWeLoveTheKingDayCounter()
    if turns > 0 then
        return Text.format("TXT_KEY_CITYVIEW_WLTKD_COUNTER", turns)
    end
    local resourceInfo = GameInfo.Resources[city:GetResourceDemanded()]
    if resourceInfo == nil then
        return nil
    end
    return Text.format("TXT_KEY_CITYVIEW_RESOURCE_DEMANDED", Text.key(resourceInfo.Description))
end

local function buildDemandGroup(city)
    local row = CityStats.demandRow(city)
    if row == nil then
        return nil
    end
    return BaseMenuItems.Group({
        labelText = Text.key("TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_DEMAND"),
        items = { BaseMenuItems.Text({ labelText = row }) },
        cached = false,
    })
end

-- ===== Top-level assembly =====

-- Entry point. Returns the list of group items for the Stats sub-handler
-- in display order. nil-returning builders are filtered out so empty
-- categories don't appear at all (vs. appearing with a "no entries" leaf).
-- Trade and Resources are mod-authored aggregations that vanilla CityView
-- does not expose. On a spy-screen view they would leak intel beyond what
-- a sighted player sees on the espionage panel, so we drop them when the
-- city isn't the active player's. Yields, Growth, Culture, Happiness,
-- Religion, Defense, and the WLTKD line are all in vanilla CityView and
-- stay visible.
local function isActiveOwn(city)
    return city ~= nil and city:GetOwner() == Game.GetActivePlayer() and not UI.IsCityScreenViewingMode()
end

function CityStats.buildItems(city, player)
    local items = { buildYieldsGroup(city) }
    local function append(group)
        if group ~= nil then
            items[#items + 1] = group
        end
    end
    local own = isActiveOwn(city)
    append(buildSimpleGroup("TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_GROWTH", CityStats.growthRows(city)))
    append(buildSimpleGroup("TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_CULTURE", CityStats.cultureRows(city)))
    -- Happiness uses player:GetUnhappinessFromCityForUI(city), which only
    -- makes sense when player is the city's owner -- on a spy screen the
    -- active player's per-city unhappiness against a foreign city is a
    -- meaningless number. Drop the group entirely on foreign rather than
    -- swap to the foreign player's handle (which would expose the foreign
    -- empire's per-city unhappiness contribution -- intel beyond espionage).
    if own then
        append(buildSimpleGroup("TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_HAPPINESS", CityStats.happinessRows(city, player)))
    end
    append(buildSimpleGroup("TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_RELIGION", CityStats.religionRows(city), true))
    if own then
        append(buildSimpleGroup("TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_TRADE", CityStats.tradeRows(city, player), true))
        append(buildSimpleGroup("TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_RESOURCES", CityStats.resourceRows(city), true))
    end
    append(buildSimpleGroup("TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_DEFENSE", CityStats.defenseRows(city)))
    append(buildDemandGroup(city))
    return items
end
