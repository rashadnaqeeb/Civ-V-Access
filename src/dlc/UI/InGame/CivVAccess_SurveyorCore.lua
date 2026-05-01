-- Surveyor: "what's within N tiles of my cursor." Sits alongside Cursor
-- ("what's on this tile") and Scanner ("where is X"). Each Shift-letter
-- key answers one scope question against the current cursor position and
-- the shared radius on civvaccess_shared.surveyorRadius.
--
-- No per-scope caching; every read re-queries live engine state so a
-- radius 5 sweep after a unit move reflects the new positions. HexGeom
-- does the cube-coord iteration and splits the revealed / unexplored
-- buckets; this module layers filters and formatting on top.
--
-- Boot.lua loads the strings file before this one so Text.key lookups at
-- module load time resolve, but every user-facing lookup happens inside
-- a scope function — load-time lookups here would bind to whichever
-- locale loaded first and miss later re-includes on Context re-entry.

SurveyorCore = {}

local MOD_SHIFT = 1

local MIN_RADIUS = 1
local MAX_RADIUS = 5

-- Yield id / TXT_KEY pairs in the canonical speech order the cursor's W
-- (economy) uses. Stays in sync with PlotComposers.YIELD_KEYS by design;
-- a future yield reorder lands in both places.
local YIELD_ORDER = {
    { id = YieldTypes.YIELD_FOOD, key = "TXT_KEY_CIVVACCESS_ICON_FOOD" },
    { id = YieldTypes.YIELD_PRODUCTION, key = "TXT_KEY_CIVVACCESS_ICON_PRODUCTION" },
    { id = YieldTypes.YIELD_GOLD, key = "TXT_KEY_CIVVACCESS_ICON_GOLD" },
    { id = YieldTypes.YIELD_SCIENCE, key = "TXT_KEY_CIVVACCESS_ICON_SCIENCE" },
    { id = YieldTypes.YIELD_CULTURE, key = "TXT_KEY_CIVVACCESS_ICON_CULTURE" },
    { id = YieldTypes.YIELD_FAITH, key = "TXT_KEY_CIVVACCESS_ICON_FAITH" },
}

-- ===== Radius state =====
civvaccess_shared = civvaccess_shared or {}

local function getRadius()
    local r = civvaccess_shared.surveyorRadius
    if type(r) ~= "number" then
        r = MIN_RADIUS
        civvaccess_shared.surveyorRadius = r
    end
    return r
end

local function setRadius(r)
    if r < MIN_RADIUS then
        r = MIN_RADIUS
    elseif r > MAX_RADIUS then
        r = MAX_RADIUS
    end
    civvaccess_shared.surveyorRadius = r
    return r
end

-- ===== Scope helpers =====
local function cursorPos()
    local cx, cy = Cursor.position()
    if cx == nil then
        Log.warn("Surveyor: cursor not initialized")
        return nil, nil
    end
    return cx, cy
end

local function appendUnexplored(body, unexplored)
    if unexplored == nil or unexplored <= 0 then
        return body
    end
    local suffix = Text.formatPlural("TXT_KEY_CIVVACCESS_SURVEYOR_UNEXPLORED_SUFFIX", unexplored, unexplored)
    if body == nil or body == "" then
        return suffix
    end
    return body .. ". " .. suffix
end

local function sortedBucketByCountThenName(buckets)
    local entries = {}
    for name, n in pairs(buckets) do
        entries[#entries + 1] = { name = name, count = n }
    end
    table.sort(entries, function(a, b)
        if a.count ~= b.count then
            return a.count > b.count
        end
        return a.name < b.name
    end)
    return entries
end

local function formatBucketEntries(entries)
    local parts = {}
    for _, e in ipairs(entries) do
        parts[#parts + 1] = tostring(e.count) .. " " .. e.name
    end
    return table.concat(parts, ", ")
end

-- ===== Radius grow / shrink =====
local function speakRadius(r)
    if r <= MIN_RADIUS then
        return Text.format("TXT_KEY_CIVVACCESS_SURVEYOR_RADIUS_MIN", r)
    end
    if r >= MAX_RADIUS then
        return Text.format("TXT_KEY_CIVVACCESS_SURVEYOR_RADIUS_MAX", r)
    end
    return Text.format("TXT_KEY_CIVVACCESS_SURVEYOR_RADIUS", r)
end

function SurveyorCore.grow()
    return speakRadius(setRadius(getRadius() + 1))
end

function SurveyorCore.shrink()
    return speakRadius(setRadius(getRadius() - 1))
end

-- ===== Yields =====
function SurveyorCore.yields()
    local cx, cy = cursorPos()
    if cx == nil then
        return ""
    end
    local range = HexGeom.plotsInRange(cx, cy, getRadius())
    local totals = {}
    for _, y in ipairs(YIELD_ORDER) do
        totals[y.id] = 0
    end
    for _, plot in ipairs(range.plots) do
        for _, y in ipairs(YIELD_ORDER) do
            totals[y.id] = totals[y.id] + plot:CalculateYield(y.id, true)
        end
    end
    local parts = {}
    for _, y in ipairs(YIELD_ORDER) do
        local n = totals[y.id]
        if n > 0 then
            parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_YIELD_COUNT", n, Text.key(y.key))
        end
    end
    local body
    if #parts == 0 then
        body = Text.key("TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_YIELDS")
    else
        body = table.concat(parts, ", ")
    end
    return appendUnexplored(body, range.unexplored)
end

-- ===== Resources =====
-- Shares the tech-gated visibility check with PlotSections.resource.Read
-- (undiscovered strategic / luxury resources return -1 from
-- GetResourceType when the active team is passed), but reads the raw id
-- and quantity directly rather than calling Read: Read returns a
-- pre-formatted token list plus a tech-required note, and we need the
-- localized name and an integer count for bucketing / summing.
function SurveyorCore.resources()
    local cx, cy = cursorPos()
    if cx == nil then
        return ""
    end
    local range = HexGeom.plotsInRange(cx, cy, getRadius())
    local team = Game.GetActiveTeam()
    local buckets = {}
    for _, plot in ipairs(range.plots) do
        local id = plot:GetResourceType(team)
        if id ~= nil and id >= 0 then
            local row = GameInfo.Resources[id]
            if row ~= nil then
                local name = Text.key(row.Description)
                local qty = plot:GetNumResource()
                if qty == nil or qty < 1 then
                    qty = 1
                end
                buckets[name] = (buckets[name] or 0) + qty
            end
        end
    end
    local entries = sortedBucketByCountThenName(buckets)
    local body
    if #entries == 0 then
        body = Text.key("TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_RESOURCES")
    else
        body = formatBucketEntries(entries)
    end
    return appendUnexplored(body, range.unexplored)
end

-- ===== Terrain + features =====
-- Delegates to PlotSections.terrainShape.Read so all of the feature-
-- suppresses-terrain / mountain-dominates / natural-wonder-stands-alone
-- policy lives in one place. Bucket total can exceed plot count because
-- multi-terrain features contribute two tokens ("forest on tundra" -> 2).
function SurveyorCore.terrain()
    local cx, cy = cursorPos()
    if cx == nil then
        return ""
    end
    local range = HexGeom.plotsInRange(cx, cy, getRadius())
    local buckets = {}
    for _, plot in ipairs(range.plots) do
        local tokens = PlotSections.terrainShape.Read(plot)
        for _, tok in ipairs(tokens) do
            if tok ~= nil and tok ~= "" then
                buckets[tok] = (buckets[tok] or 0) + 1
            end
        end
    end
    local entries = sortedBucketByCountThenName(buckets)
    local body
    if #entries == 0 then
        body = Text.key("TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_TERRAIN")
    else
        body = formatBucketEntries(entries)
    end
    return appendUnexplored(body, range.unexplored)
end

-- ===== Instance scopes =====
-- Sort instances by cube-distance ascending, then CW-from-E direction
-- rank. Distance 0 (units at the cursor) sort before everything; within
-- a ring, E wins, then SE, SW, W, NW, NE.
local function distanceDirectionCompare(a, b)
    if a.dist ~= b.dist then
        return a.dist < b.dist
    end
    if a.rank ~= b.rank then
        return a.rank < b.rank
    end
    return a.label < b.label
end

-- Generic "label at direction, label at direction" formatter. Units use
-- "label, dir" with ". " between instances because a compound direction
-- contains commas and would merge with adjacent labels otherwise. Cities
-- use "label dir" with ", " because each city name is unique and the
-- terser form reads better.
local function formatInstances(instances, cx, cy, labelDirSep, instanceSep)
    table.sort(instances, distanceDirectionCompare)
    local parts = {}
    for _, inst in ipairs(instances) do
        local dir = HexGeom.directionString(cx, cy, inst.x, inst.y)
        if dir == "" then
            parts[#parts + 1] = inst.label
        else
            parts[#parts + 1] = inst.label .. labelDirSep .. dir
        end
    end
    return table.concat(parts, instanceSep)
end

local function formatUnitInstances(instances, cx, cy)
    return formatInstances(instances, cx, cy, ", ", ". ")
end

local function unitLabel(unit, prefixAdj)
    local row = GameInfo.Units[unit:GetUnitType()]
    local name = row ~= nil and Text.key(row.Description) or ""
    if prefixAdj == nil or prefixAdj == "" then
        return name
    end
    if name == "" then
        return prefixAdj
    end
    return prefixAdj .. " " .. name
end

function SurveyorCore.ownUnits()
    local cx, cy = cursorPos()
    if cx == nil then
        return ""
    end
    local range = HexGeom.plotsInRange(cx, cy, getRadius())
    local activePlayer = Game.GetActivePlayer()
    local instances = {}
    for _, plot in ipairs(range.plots) do
        local px, py = plot:GetX(), plot:GetY()
        local dist = HexGeom.cubeDistance(cx, cy, px, py)
        local rank = HexGeom.directionRank(cx, cy, px, py)
        for i = 0, plot:GetNumLayerUnits(-1) - 1 do
            local u = plot:GetLayerUnit(i, -1)
            if u ~= nil and u:GetOwner() == activePlayer then
                instances[#instances + 1] = {
                    x = px,
                    y = py,
                    dist = dist,
                    rank = rank,
                    label = unitLabel(u, nil),
                }
            end
        end
    end
    local body
    if #instances == 0 then
        body = Text.key("TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_OWN_UNITS")
    else
        body = formatUnitInstances(instances, cx, cy)
    end
    return appendUnexplored(body, range.unexplored)
end

function SurveyorCore.enemyUnits()
    local cx, cy = cursorPos()
    if cx == nil then
        return ""
    end
    local range = HexGeom.plotsInRange(cx, cy, getRadius())
    local activeTeam = Game.GetActiveTeam()
    local isDebug = Game.IsDebugMode()
    local activeTeamObj = Teams[activeTeam]
    local instances = {}
    for _, plot in ipairs(range.plots) do
        if plot:IsVisible(activeTeam, isDebug) then
            local px, py = plot:GetX(), plot:GetY()
            local dist = HexGeom.cubeDistance(cx, cy, px, py)
            local rank = HexGeom.directionRank(cx, cy, px, py)
            for i = 0, plot:GetNumLayerUnits(-1) - 1 do
                local u = plot:GetLayerUnit(i, -1)
                if u ~= nil and not u:IsInvisible(activeTeam, isDebug) then
                    local ownerId = u:GetOwner()
                    local owner = Players[ownerId]
                    if owner ~= nil then
                        local hostile = owner:IsBarbarian() or activeTeamObj:IsAtWar(owner:GetTeam())
                        if hostile then
                            local adj = Text.key(owner:GetCivilizationAdjectiveKey())
                            instances[#instances + 1] = {
                                x = px,
                                y = py,
                                dist = dist,
                                rank = rank,
                                label = unitLabel(u, adj),
                            }
                        end
                    end
                end
            end
        end
    end
    local body
    if #instances == 0 then
        body = Text.key("TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_ENEMY_UNITS")
    else
        body = formatUnitInstances(instances, cx, cy)
    end
    return appendUnexplored(body, range.unexplored)
end

-- ===== Cities =====
-- Flat closest-first listing, sorted by cube distance then CW-from-E
-- direction rank (shared with units via distanceDirectionCompare). No
-- diplomacy grouping: a blind player scanning for cities wants to know
-- which is nearest first, and grouping by hostility buries that signal
-- behind a category header.
function SurveyorCore.cities()
    local cx, cy = cursorPos()
    if cx == nil then
        return ""
    end
    local range = HexGeom.plotsInRange(cx, cy, getRadius())
    local instances = {}
    for _, plot in ipairs(range.plots) do
        if plot:IsCity() then
            local city = plot:GetPlotCity()
            if city ~= nil then
                local px, py = plot:GetX(), plot:GetY()
                instances[#instances + 1] = {
                    x = px,
                    y = py,
                    dist = HexGeom.cubeDistance(cx, cy, px, py),
                    rank = HexGeom.directionRank(cx, cy, px, py),
                    label = city:GetName(),
                }
            end
        end
    end
    local body
    if #instances == 0 then
        body = Text.key("TXT_KEY_CIVVACCESS_SURVEYOR_EMPTY_CITIES")
    else
        body = formatInstances(instances, cx, cy, " ", ", ")
    end
    return appendUnexplored(body, range.unexplored)
end

-- ===== Bindings =====
local speak = SpeechPipeline.speakInterrupt

local bind = HandlerStack.bind

function SurveyorCore.getBindings()
    local bindings = {
        bind(Keys.W, MOD_SHIFT, function()
            speak(SurveyorCore.grow())
        end, "Surveyor: grow radius"),
        bind(Keys.X, MOD_SHIFT, function()
            speak(SurveyorCore.shrink())
        end, "Surveyor: shrink radius"),
        bind(Keys.Q, MOD_SHIFT, function()
            speak(SurveyorCore.yields())
        end, "Surveyor: yields"),
        bind(Keys.A, MOD_SHIFT, function()
            speak(SurveyorCore.resources())
        end, "Surveyor: resources"),
        bind(Keys.Z, MOD_SHIFT, function()
            speak(SurveyorCore.terrain())
        end, "Surveyor: terrain"),
        bind(Keys.E, MOD_SHIFT, function()
            speak(SurveyorCore.ownUnits())
        end, "Surveyor: own units"),
        bind(Keys.D, MOD_SHIFT, function()
            speak(SurveyorCore.enemyUnits())
        end, "Surveyor: enemy units"),
        bind(Keys.C, MOD_SHIFT, function()
            speak(SurveyorCore.cities())
        end, "Surveyor: cities"),
    }
    local helpEntries = {
        {
            keyLabel = "TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_RADIUS",
            description = "TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_RADIUS",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_YIELDS",
            description = "TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_YIELDS",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_RESOURCES",
            description = "TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_RESOURCES",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_TERRAIN",
            description = "TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_TERRAIN",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_OWN_UNITS",
            description = "TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_OWN_UNITS",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_ENEMY_UNITS",
            description = "TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_ENEMY_UNITS",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_SURVEYOR_HELP_KEY_CITIES",
            description = "TXT_KEY_CIVVACCESS_SURVEYOR_HELP_DESC_CITIES",
        },
    }
    return { bindings = bindings, helpEntries = helpEntries }
end

-- Test seam.
function SurveyorCore._reset()
    civvaccess_shared.surveyorRadius = nil
end
