-- Shared wrapper around the engine's InfoTooltipInclude helpers
-- (GetHelpTextForBuilding / Unit / Project) so the chooser, the queue,
-- and the in-city built-buildings/wonders surfaces all surface the same
-- live contributions read against a city. Three callers, one place to
-- keep the cost-mode / prefix-strip logic.
--
-- The engine helpers ship with quirks each caller would otherwise have
-- to handle on its own:
--
-- * GetHelpTextForUnit and GetHelpTextForProject always prepend
--   "<UPPERCASE_NAME>[NEWLINE]----------------[NEWLINE]" with no
--   exclusion flag. Every caller already speaks the localized name as
--   the head of its label, so we strip the helper's name+separator
--   prefix to avoid speaking the name twice.
-- * GetHelpTextForBuilding takes flags but bExcludeHeader=true skips
--   cost AND maintenance together. Built-building / queue surfaces want
--   maintenance without cost; we pass bExcludeHeader=true and
--   re-synthesize the maintenance line ourselves.
-- * Units / Projects emit the cost line as the first content chunk
--   after the prefix, separated from the next line by [NEWLINE]. When a
--   caller wants to drop cost we strip everything up to and including
--   the first [NEWLINE]. When Cost == 0 there's no cost line at all but
--   the helper still emits a leading [NEWLINE] before the next section,
--   so the same strip is a harmless no-op (eats the separator only).
--
-- Engine globals (GetHelpTextForBuilding / Unit / Project,
-- Locale.ConvertTextKey, GameInfo) are guarded so the module can be
-- dofiled by offline tests without immediately exploding -- callers in
-- the in-game contexts always have InfoTooltipInclude loaded by the
-- vendor file we override.

ProductionHelpText = {}

local function stripNamePrefix(s)
    -- "<NAME>[NEWLINE]----------------[NEWLINE]<rest>" -> "<rest>".
    -- The dash run is the engine's section separator (16 dashes),
    -- which the speech-side TextFilter strips from anywhere in
    -- runtime; doing it here too lets the caller see clean intermediate
    -- text without depending on the filter pass.
    return (s:gsub("^[^%[]*%[NEWLINE%]%-%-%-%-+%[NEWLINE%]", ""))
end

local function dropFirstChunk(s)
    -- Drop everything up to and including the first [NEWLINE] token.
    -- Used to strip the cost line from Unit / Project helper output;
    -- when the cost line is absent the leading [NEWLINE] before the
    -- next section is consumed instead, which is harmless (it was
    -- only a separator).
    return (s:gsub("^[^%[]*%[NEWLINE%]", "", 1))
end

-- Per-building maintenance line, synthesized so callers can opt out of
-- the helper's full cost+maintenance header but still surface the gold
-- drain. Mirrors the helper's own emission at
-- InfoTooltipInclude.lua:139-144 (skip when nil/zero, format via the
-- engine's TXT_KEY_PRODUCTION_BUILDING_MAINTENANCE).
local function maintenanceLine(building)
    local m = building and building.GoldMaintenance or 0
    if m == 0 then
        return nil
    end
    return Text.format("TXT_KEY_PRODUCTION_BUILDING_MAINTENANCE", m)
end

-- Building contributions for the given city.
--
-- includeCost = true: pass through the helper's full header (cost,
-- league cost, maintenance). Used by the production chooser, where the
-- player is deciding whether to start the build.
--
-- includeCost = false: skip cost and league cost via bExcludeHeader,
-- re-synthesize maintenance, prepend it. Used by the in-city built-
-- buildings / wonders surface (cost is moot for an already-built
-- building) and by the queue (the queue surfaces production remaining
-- separately, computed against the slot's accumulated production).
function ProductionHelpText.buildingHelp(city, building, includeCost)
    if GetHelpTextForBuilding == nil or building == nil then
        return ""
    end
    if includeCost then
        return GetHelpTextForBuilding(building.ID, true, false, false, city) or ""
    end
    local body = GetHelpTextForBuilding(building.ID, true, true, false, city) or ""
    local mLine = maintenanceLine(building)
    if mLine == nil then
        return body
    end
    if body == "" then
        return mLine
    end
    return mLine .. "[NEWLINE]" .. body
end

function ProductionHelpText.unitHelp(_city, unit, includeCost)
    if GetHelpTextForUnit == nil or unit == nil then
        return ""
    end
    local body = stripNamePrefix(GetHelpTextForUnit(unit.ID, false) or "")
    if includeCost then
        return body
    end
    return dropFirstChunk(body)
end

function ProductionHelpText.projectHelp(_city, project, includeCost)
    if GetHelpTextForProject == nil or project == nil then
        return ""
    end
    local body = stripNamePrefix(GetHelpTextForProject(project.ID, false) or "")
    if includeCost then
        return body
    end
    return dropFirstChunk(body)
end

-- Processes have no engine-exposed contribution data (their effect is a
-- runtime conversion, not a stored set of yields), so we fall back to
-- the static prose Help. Text.keyOrNil drops unresolved keys (e.g.
-- PROCESS_RESEARCH_HELP variants that some installs ship without rows)
-- so an unresolved key never reaches Tolk and gets spelled out.
function ProductionHelpText.processHelp(process)
    if process == nil or process.Help == nil or process.Help == "" then
        return ""
    end
    return Text.keyOrNil(process.Help) or ""
end

-- "Production remaining: N" line for a queued or in-progress item.
-- Substitutes for the helper's "Cost: X" line on surfaces that surface
-- progress against the build (the in-city queue's slot-1 entry, the
-- chooser's view of the currently-building item).
--
-- When includeStored is true the city's accumulated production
-- (GetProductionTimes100) is subtracted from the item's full needed --
-- correct for any item that owns the city's production accumulator,
-- meaning the current slot-1 entry. When includeStored is false the
-- full needed is reported -- correct for queued slot 2+ entries that
-- haven't received any progress yet.
--
-- Returns nil for ORDER_MAINTAIN (processes don't accumulate progress)
-- or when needed resolves to zero (free items via FreeBuilding /
-- FreeUnit prereqs); callers can skip the trailer cleanly.
function ProductionHelpText.remainingLine(city, orderType, data1, includeStored)
    if orderType == OrderTypes.ORDER_MAINTAIN then
        return nil
    end
    local player = Players[city:GetOwner()]
    if player == nil then
        return nil
    end
    local needed
    if orderType == OrderTypes.ORDER_TRAIN then
        needed = player:GetUnitProductionNeeded(data1)
    elseif orderType == OrderTypes.ORDER_CONSTRUCT then
        needed = player:GetBuildingProductionNeeded(data1)
    elseif orderType == OrderTypes.ORDER_CREATE then
        needed = player:GetProjectProductionNeeded(data1)
    end
    if needed == nil or needed <= 0 then
        return nil
    end
    local stored = 0
    if includeStored then
        stored = math.floor((city:GetProductionTimes100() or 0) / 100)
    end
    local remaining = needed - stored
    if remaining < 0 then
        remaining = 0
    end
    return Text.format("TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMAINING", remaining)
end

-- Dispatch helper for callers that already know the orderType.
function ProductionHelpText.forOrder(city, orderType, data1, includeCost)
    if orderType == OrderTypes.ORDER_TRAIN then
        return ProductionHelpText.unitHelp(city, GameInfo.Units[data1], includeCost)
    elseif orderType == OrderTypes.ORDER_CONSTRUCT then
        return ProductionHelpText.buildingHelp(city, GameInfo.Buildings[data1], includeCost)
    elseif orderType == OrderTypes.ORDER_CREATE then
        return ProductionHelpText.projectHelp(city, GameInfo.Projects[data1], includeCost)
    elseif orderType == OrderTypes.ORDER_MAINTAIN then
        return ProductionHelpText.processHelp(GameInfo.Processes[data1])
    end
    return ""
end

return ProductionHelpText
