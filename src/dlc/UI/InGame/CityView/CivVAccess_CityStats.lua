-- City Stats drillable. The CityView hub item that pushes a sub-handler
-- whose items mix one-line summary entries with drillables that have
-- their own headline on the label. Categories that vanilla CityView
-- exposes per-city: yields (the seven yields, each a drillable into the
-- engine's tooltip breakdown -- food and culture rows additionally
-- carry their growth / next-tile-in tail on the headline), happiness
-- (one line: local + unhappiness), religion (drillable list, omitted
-- before any conversion), trade routes (drillable list, omitted with no
-- routes touching this city), local resources (drillable list with
-- per-resource counts), defense (drillable into the chain buildings
-- + garrison; strength + HP on the headline), and the WLTKD /
-- demanded-resource line (one line, omitted before any cycle).
--
-- Pure data layer: every entry point takes a city handle plus optional
-- collaborators (active player, the engine's tooltip helpers) and
-- returns either rows / a label / a Group. The wrapper in
-- CityViewAccess assembles the list and pushes the sub-handler. No
-- state is cached; every group is rebuilt on each Stats push, so a buy
-- / specialist change / route shift in another sub-handler that pops
-- back through Stats produces fresh numbers.

include("CivVAccess_TradeRouteRow")

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

-- The engine's GetFaithTooltip terminates its per-source bullets with
-- a "----------------" separator, then appends GetReligionTooltip --
-- the same per-religion-followers-and-pressure data the Religion
-- drillable already exposes one level up. Truncate at the separator
-- so the faith drill-in carries only the actual faith breakdown
-- (buildings / traits / terrain / policies / religion-yield) and
-- doesn't double-speak religion presence.
local function stripFaithReligionSuffix(text)
    if text == nil then
        return text
    end
    local cutAt = string.find(text, "----------------", 1, true)
    if cutAt == nil then
        return text
    end
    return string.sub(text, 1, cutAt - 1)
end

-- ===== Yields =====

-- The food row's headline rate (FoodDifference) is net per-turn growth, so
-- the extras tail skips a "+N per turn" clause and goes straight to
-- storage + ETA. The starving / stopped-growing branches mirror the
-- engine's display gating from CityBannerManager.lua: zero-or-positive
-- diff under IsFoodProduction reads as stopped (food piped into
-- production), strictly negative reads as starving, otherwise the
-- turns-to-grow countdown.
local function foodExtras(city)
    local parts = {}
    parts[#parts + 1] = Text.format(
        "TXT_KEY_CIVVACCESS_CITYSTATS_STORAGE_FRACTION",
        city:GetFood(),
        city:GrowthThreshold()
    )
    local foodDiff100 = city:FoodDifferenceTimes100()
    if city:IsFoodProduction() or foodDiff100 == 0 then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_CITY_STOPPED_GROWING")
    elseif foodDiff100 < 0 then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_CITY_STARVING")
    else
        local turns = city:GetFoodTurnsLeft()
        parts[#parts + 1] = Text.formatPlural("TXT_KEY_CIVVACCESS_CITY_GROWS_IN", turns, turns)
    end
    return table.concat(parts, ", ")
end

-- Culture's headline rate (GetJONSCulturePerTurn) is the per-turn rate, so
-- the extras tail goes storage + tile-ETA without re-stating per-turn.
-- Reuses CitySpeech.borderGrowthToken for the stalled / N-turns marker
-- so the wording stays consistent with hex-cursor spoken output.
local function cultureExtras(city)
    local parts = {}
    parts[#parts + 1] = Text.format(
        "TXT_KEY_CIVVACCESS_CITYSTATS_STORAGE_FRACTION",
        city:GetJONSCultureStored(),
        city:GetJONSCultureThreshold()
    )
    parts[#parts + 1] = CitySpeech.borderGrowthToken(city)
    return table.concat(parts, ", ")
end

-- The seven yields in preamble order. labelKey is the per-turn one-line
-- label; helperKey routes through yieldTooltipFn to the engine's
-- breakdown helper; rate returns the engine's per-turn value; extrasFn,
-- when present, returns the storage / ETA tail appended after the rate
-- ("food 5, 12 of 22, grows in 4 turns"). Tourism reads /100 because
-- the engine's GetBaseTourism returns the *100 form (matches what the
-- banner divides for display).
local YIELD_DEFS = {
    {
        labelKey = "TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_FOOD",
        helperKey = "FOOD",
        rate = function(c)
            return c:FoodDifference()
        end,
        extrasFn = foodExtras,
    },
    {
        -- Production headline matches what the engine displays in
        -- CityView (CityView.lua:1822: GetCurrentProductionDifference
        -- Times100(false, false) / 100). GetYieldRate(YIELD_PRODUCTION)
        -- is the pre-modifier base; using it would mismatch the visible
        -- top-bar number in cities with policy / building / process
        -- modifiers active.
        labelKey = "TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_PRODUCTION",
        helperKey = "PRODUCTION",
        rate = function(c)
            return math.floor(c:GetCurrentProductionDifferenceTimes100(false, false) / 100)
        end,
    },
    {
        labelKey = "TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_GOLD",
        helperKey = "GOLD",
        rate = function(c)
            return c:GetYieldRate(YieldTypes.YIELD_GOLD)
        end,
    },
    {
        labelKey = "TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_SCIENCE",
        helperKey = "SCIENCE",
        rate = function(c)
            return c:GetYieldRate(YieldTypes.YIELD_SCIENCE)
        end,
    },
    {
        labelKey = "TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_FAITH",
        helperKey = "FAITH",
        rate = function(c)
            return c:GetFaithPerTurn()
        end,
    },
    {
        labelKey = "TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_TOURISM",
        helperKey = "TOURISM",
        rate = function(c)
            return math.floor(c:GetBaseTourism() / 100)
        end,
    },
    {
        labelKey = "TXT_KEY_CIVVACCESS_CITYVIEW_YIELD_CULTURE",
        helperKey = "CULTURE",
        rate = function(c)
            return c:GetJONSCulturePerTurn()
        end,
        extrasFn = cultureExtras,
    },
}

function CityStats.yieldRows(city, helperFn)
    helperFn = helperFn or yieldTooltipFn
    local groups = {}
    for _, def in ipairs(YIELD_DEFS) do
        local rate = def.rate(city)
        local label = Text.format(def.labelKey, rate)
        if def.extrasFn ~= nil then
            label = label .. ", " .. def.extrasFn(city)
        end
        local fn = helperFn(def.helperKey)
        local breakdown = {}
        if fn ~= nil then
            local ok, raw = pcall(fn, city)
            if not ok then
                Log.error("CityStats yield tooltip '" .. def.helperKey .. "' failed: " .. tostring(raw))
            elseif raw ~= nil then
                if def.helperKey == "FAITH" then
                    raw = stripFaithReligionSuffix(raw)
                end
                breakdown = splitTooltipLines(raw)
            end
        end
        groups[#groups + 1] = { label = label, breakdown = breakdown }
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

-- ===== Happiness =====

-- One-line: per-city numbers that mirror what HappinessInfo.lua reads:
--   pCity:GetLocalHappiness()                  buildings local to this city
--   pPlayer:GetUnhappinessFromCityForUI(city)  the city's contribution to
--                                              empire unhappiness, *100
-- Empire-wide happiness lives in EmpireStatus; this entry is strictly
-- per-city.
function CityStats.happinessLine(city, player)
    local localValue = city:GetLocalHappiness()
    local unhappiness100 = player:GetUnhappinessFromCityForUI(city)
    local unhappiness = math.floor(unhappiness100 / 100)
    return Text.format("TXT_KEY_CIVVACCESS_CITYSTATS_HAPPINESS_LINE", localValue, unhappiness)
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
-- or ToCity matches this city by id, then formats each via the shared
-- TradeRouteRow.rowLabel so the wording matches the dedicated trade-
-- route overview screen ("{header}. you get {yields}. they get
-- {yields}. {turns} turns left."). isInbound is always false here:
-- player:GetTradeRoutes() returns only routes whose origin is this
-- player (CvLuaPlayer.cpp:4041), so the user's side is always the
-- origin side. Foreign incoming routes terminating at this city aren't
-- in this list -- the engine doesn't expose them on the active
-- player's accessor; the dedicated overview's With-You tab is the only
-- place to see them.
function CityStats.tradeRouteLabels(city, player)
    local labels = {}
    local cityId = city:GetID()
    local routes = player:GetTradeRoutes()
    if routes == nil then
        return labels
    end
    for _, route in ipairs(routes) do
        local fromMatch = route.FromCity ~= nil and route.FromCity:GetID() == cityId
        local toMatch = route.ToCity ~= nil and route.ToCity:GetID() == cityId
        if fromMatch or toMatch then
            labels[#labels + 1] = TradeRouteRow.rowLabel(route, false)
        end
    end
    return labels
end

-- ===== Resources =====

-- Walks the city's working-radius plots once. ResourceUsage filter:
-- 1 = strategic (gates units), 2 = luxury (happiness), 3 = bonus
-- (omitted -- bonus resources don't trade or feed empire-level
-- mechanics). Strategics lead the list because they gate units, then
-- luxes; both groups sorted alphabetically via Locale.Compare.
--
-- Counts come from plot:GetNumResource() summed over plots whose
-- resource is "local" to this city. The IsHasResourceLocal(rid, false)
-- guard rejects resources whose nearest linked city is a different one
-- of the player's cities (the engine attributes a single plot's count
-- to exactly one city). Edge case: when this city has the same
-- resource type linked via a plot it owns AND owns a separate plot of
-- the same type linked to a neighbor, the latter plot's count is
-- erroneously folded in. The engine's own m_paiNumResourcesLocal would
-- give the exact count; the Lua binding for it doesn't exist in
-- vanilla and the disproportion of copying CvCity.h+.cpp into the fork
-- for one accessor isn't worth it for an edge case.
local function compareLocale(a, b)
    return Locale.Compare(a, b) == -1
end

function CityStats.resourceLines(city)
    local strategicCounts = {}
    local luxCounts = {}
    local strategicNames = {}
    local luxNames = {}
    local cityId = city:GetID()
    local function accumulate(rid, count)
        local resourceInfo = GameInfo.Resources[rid]
        if resourceInfo == nil then
            return
        end
        local usage = resourceInfo.ResourceUsage
        if usage == ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC then
            strategicCounts[rid] = (strategicCounts[rid] or 0) + count
            strategicNames[rid] = Text.key(resourceInfo.Description)
        elseif usage == ResourceUsageTypes.RESOURCEUSAGE_LUXURY then
            luxCounts[rid] = (luxCounts[rid] or 0) + count
            luxNames[rid] = Text.key(resourceInfo.Description)
        end
    end
    for i = 0, city:GetNumCityPlots() - 1 do
        local plot = city:GetCityIndexPlot(i)
        if plot ~= nil then
            local rid = plot:GetResourceType()
            if rid ~= -1 then
                local owner = plot:GetPlotCity()
                if owner ~= nil and owner:GetID() == cityId and city:IsHasResourceLocal(rid, false) then
                    accumulate(rid, plot:GetNumResource())
                end
            end
        end
    end
    local function emit(counts, names, out)
        local ids = {}
        for rid in pairs(counts) do
            ids[#ids + 1] = rid
        end
        table.sort(ids, function(a, b)
            return compareLocale(names[a], names[b])
        end)
        for _, rid in ipairs(ids) do
            out[#out + 1] = Text.format(
                "TXT_KEY_CIVVACCESS_CITYSTATS_RESOURCE_LINE",
                names[rid],
                counts[rid]
            )
        end
    end
    local rows = {}
    emit(strategicCounts, strategicNames, rows)
    emit(luxCounts, luxNames, rows)
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

-- Headline label for the Defense drillable. Strength /100 matches the
-- engine's display scaling; HP fraction reads "(max - damage) of max".
-- Composes the strength + HP keys that PlotSection already speaks
-- elsewhere so the wording stays consistent across screens.
function CityStats.defenseHeadline(city)
    local strength = math.floor(city:GetStrengthValue() / 100)
    local maxHP = GameDefines.MAX_CITY_HIT_POINTS
    local strengthPart = Text.format("TXT_KEY_CIVVACCESS_CITY_DEFENSE", strength)
    local hpPart = Text.format("TXT_KEY_CIVVACCESS_CITY_HP_FRACTION", maxHP - city:GetDamage(), maxHP)
    return strengthPart .. ", " .. hpPart
end

-- Drill-in for the Defense group: chain buildings in upgrade order, then
-- the garrison line if a unit is stationed. Strength + HP live on the
-- group label, not in the drill-in.
function CityStats.defenseRows(city)
    local rows = {}
    for _, name in ipairs(defensiveBuildingNames(city)) do
        rows[#rows + 1] = name
    end
    local garrison = defenseGarrisonLabel(city)
    if garrison ~= nil then
        rows[#rows + 1] = garrison
    end
    return rows
end

-- ===== Demand / WLTKD =====

-- Same gating as the (now-retired) hub-level resourceDemandLabel: if no
-- demand cycle has started the row is omitted; once started, WLTKD
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

-- ===== Top-level assembly =====

-- Collect plain rows into a Group keyed by header. nil-returning
-- builders are filtered out so empty categories don't appear at all
-- (vs. appearing with a "no entries" leaf). Drillable but skipIfEmpty
-- when no rows.
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

local function buildDefenseGroup(city)
    local rows = CityStats.defenseRows(city)
    local items = {}
    for _, row in ipairs(rows) do
        items[#items + 1] = BaseMenuItems.Text({ labelText = row })
    end
    return BaseMenuItems.Group({
        labelText = CityStats.defenseHeadline(city),
        items = items,
        cached = false,
    })
end

-- Entry point. Returns the list of menu items for the Stats sub-handler
-- in display order. nil-returning builders are filtered out so empty
-- categories don't appear at all (vs. appearing with a "no entries"
-- leaf). Trade and Resources are mod-authored aggregations that
-- vanilla CityView does not expose. On a spy-screen view they would
-- leak intel beyond what a sighted player sees on the espionage panel,
-- so we drop them when the city isn't the active player's. Yields and
-- Defense are unconditional. Religion is unconditional in shape but
-- the inner builder returns an empty list when no religion is present
-- and we skip on empty. Happiness uses player:GetUnhappinessFromCity
-- ForUI(city), which only makes sense when player is the city's owner;
-- on a spy screen we drop it rather than swap to the foreign player's
-- handle (which would expose the foreign empire's per-city unhappiness
-- contribution -- intel beyond espionage). Pure ownership predicate --
-- viewing-mode-on-own (PuppetCityPopup peek, between-turn flips) is
-- still the user's own city, no intel concern.
local function isOwn(city)
    return city ~= nil and city:GetOwner() == Game.GetActivePlayer()
end

function CityStats.buildItems(city, player)
    local items = { buildYieldsGroup(city) }
    local function append(group)
        if group ~= nil then
            items[#items + 1] = group
        end
    end
    local own = isOwn(city)
    if own then
        items[#items + 1] = BaseMenuItems.Text({ labelText = CityStats.happinessLine(city, player) })
    end
    append(buildSimpleGroup("TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_RELIGION", CityStats.religionRows(city), true))
    if own then
        append(buildSimpleGroup(
            "TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_TRADE",
            CityStats.tradeRouteLabels(city, player),
            true
        ))
        append(buildSimpleGroup(
            "TXT_KEY_CIVVACCESS_CITYSTATS_GROUP_RESOURCES",
            CityStats.resourceLines(city),
            true
        ))
    end
    items[#items + 1] = buildDefenseGroup(city)
    local demand = CityStats.demandRow(city)
    if demand ~= nil then
        items[#items + 1] = BaseMenuItems.Text({ labelText = demand })
    end
    return items
end
