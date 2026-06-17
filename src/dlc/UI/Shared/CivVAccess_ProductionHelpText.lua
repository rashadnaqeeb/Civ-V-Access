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

-- Some BNW rows ship with a Strategy paragraph but no Help field, so the
-- engine helper output has no prose tail. Append the entry's Strategy as
-- a fallback so the chooser / queue / built-buildings surface still has
-- a descriptive paragraph for those entries. Skipped when Help is set
-- (Help carries gameplay rules and wins for the entries that have it).
-- Skipped when Strategy resolves to empty / its key is unregistered, so
-- an unresolved key never reaches Tolk and gets spelled out.
local function applyStrategyFallback(body, info)
    if info.Help ~= nil and info.Help ~= "" then
        return body
    end
    local stratKey = info.Strategy
    if stratKey == nil or stratKey == "" then
        return body
    end
    local strategy = Text.keyOrNil(stratKey)
    if strategy == nil or strategy == "" then
        return body
    end
    if body == "" then
        return strategy
    end
    -- Match the engine helper's stats / prose separator so the speech
    -- pipeline treats the appended paragraph the same way it treats a
    -- native Help section.
    return body .. "[NEWLINE]----------------[NEWLINE]" .. strategy
end

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

-- VP / Community Patch present? VP rewrote InfoTooltipInclude with reordered
-- signatures and a different output shape, so the helpers below branch on
-- it. Guarded so the module still dofiles offline (Game absent), where the
-- vanilla path is exercised.
local function isCP()
    return Game ~= nil and Game.IsCustomModOption ~= nil
end

-- Drop VP's leading tooltip section (the header block: name and/or cost and
-- stat lines), keeping the body. VP joins sections with a dashed separator
-- line ("[NEWLINE]----------------[NEWLINE]"); the cost-free surfaces want
-- everything after the first one. A single-section output (no body) is
-- returned unchanged.
local function dropHeaderSection(s)
    local _, sepEnd = s:find("%[NEWLINE%]%-%-%-%-+%[NEWLINE%]")
    if sepEnd == nil then
        return s
    end
    return s:sub(sepEnd + 1)
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
    local body
    if includeCost then
        -- bExcludeName at arg 2 on both engines; the trailing city is the
        -- pCity slot on VP (CityView precedent) and an ignored extra on
        -- vanilla. Full cost + maintenance header is what the chooser wants.
        body = GetHelpTextForBuilding(building.ID, true, false, false, city) or ""
    else
        -- Cost-free surfaces (built buildings, queued slots) want maintenance
        -- without the cost line. Vanilla skips both via bExcludeHeader (arg 3)
        -- and we re-synthesize maintenance. VP dropped that flag (arg 3 is
        -- ignored), so the same call would leave cost + maintenance in and
        -- double the maintenance against the re-synth; use VP's
        -- bOnlyYieldsAndEffects (arg 8), which returns the effects with no
        -- cost and no stat lines, then re-synthesize maintenance the same way.
        if isCP() then
            body = GetHelpTextForBuilding(building.ID, true, nil, false, city, false, false, true) or ""
        else
            body = GetHelpTextForBuilding(building.ID, true, true, false, city) or ""
        end
        local mLine = maintenanceLine(building)
        if mLine ~= nil then
            body = (body == "") and mLine or (mLine .. "[NEWLINE]" .. body)
        end
    end
    return applyStrategyFallback(body, building)
end

function ProductionHelpText.unitHelp(city, unit, includeCost)
    if GetHelpTextForUnit == nil or unit == nil then
        return ""
    end
    local body
    if isCP() then
        -- VP added pCity (arg 3, for the city's live contributions) and
        -- bExcludeName (arg 4); excluding the name natively avoids the prefix
        -- strip. The cost-free surface peels VP's leading header section.
        body = GetHelpTextForUnit(unit.ID, false, city, true) or ""
        if not includeCost then
            body = dropHeaderSection(body)
        end
    else
        body = stripNamePrefix(GetHelpTextForUnit(unit.ID, false) or "")
        if not includeCost then
            body = dropFirstChunk(body)
        end
    end
    return applyStrategyFallback(body, unit)
end

function ProductionHelpText.projectHelp(city, project, includeCost)
    if GetHelpTextForProject == nil or project == nil then
        return ""
    end
    local body
    if isCP() then
        -- VP reordered the signature to (eProject, pCity, bGeneralInfo) and
        -- has no exclude-name flag, so pass the city for live contributions
        -- and peel the leading section: the name line for the cost view (cost
        -- and name share the header section, dropped one line), the whole
        -- header for the cost-free view.
        body = GetHelpTextForProject(project.ID, city, false) or ""
        if includeCost then
            body = dropFirstChunk(body)
        else
            body = dropHeaderSection(body)
        end
    else
        body = stripNamePrefix(GetHelpTextForProject(project.ID, false) or "")
        if not includeCost then
            body = dropFirstChunk(body)
        end
    end
    return applyStrategyFallback(body, project)
end

-- Resolves the active league and league-project id driven by a process,
-- or nil for ordinary processes (Wealth / Research), when leagues are
-- disabled, or when no project is active / complete. International
-- projects (World's Fair, International Games, ISS) are built by setting
-- a city to produce their Process; the live global progress and the
-- player's contribution hang off the league, not the process row.
-- Mirrors the lookup the engine's GetHelpTextForProcess does. Engine
-- globals are guarded so the module still dofiles offline.
local function leagueProjectFor(process)
    if process == nil then
        return nil
    end
    if Game == nil or Game.GetActiveLeague == nil or Game.IsOption == nil then
        return nil
    end
    if GameInfo == nil or GameInfo.LeagueProjects == nil then
        return nil
    end
    if Game.IsOption("GAMEOPTION_NO_LEAGUES") then
        return nil
    end
    local pLeague = Game.GetActiveLeague()
    if pLeague == nil then
        return nil
    end
    for row in GameInfo.LeagueProjects() do
        local proc = GameInfo.Processes[row.Process]
        if proc ~= nil and proc.ID == process.ID then
            local lpID = GameInfo.LeagueProjects[row.Type].ID
            if pLeague:IsProjectActive(lpID) or pLeague:IsProjectComplete(lpID) then
                return pLeague, lpID
            end
            return nil
        end
    end
    return nil
end

-- Ordinary processes have no engine-exposed contribution data (their
-- effect is a runtime conversion, not a stored set of yields), so we
-- surface the static prose Help / Strategy directly. Text.keyOrNil drops
-- unresolved keys (e.g. PROCESS_RESEARCH_HELP variants that some installs
-- ship without rows) so an unresolved key never reaches Tolk and gets
-- spelled out.
--
-- League-project processes additionally carry live status (global percent
-- complete, the player's contribution, reward tiers): we append the full
-- GetProjectDetails block after the prose, matching what the engine's
-- GetHelpTextForProcess shows a sighted player in the same tooltip.
function ProductionHelpText.processHelp(process)
    if process == nil then
        return ""
    end
    local help = (process.Help ~= nil and process.Help ~= "") and (Text.keyOrNil(process.Help) or "") or ""
    local body = applyStrategyFallback(help, process)
    local pLeague, lpID = leagueProjectFor(process)
    if pLeague ~= nil then
        local details = pLeague:GetProjectDetails(lpID, Game.GetActivePlayer())
        if details ~= nil and details ~= "" then
            body = (body == "") and details or (body .. "[NEWLINE][NEWLINE]" .. details)
        end
    end
    return body
end

-- Concise league-project status for the city banner ("2" key): the
-- engine's progress line (global percent complete + the active player's
-- contribution) without the reward-tier breakdown processHelp surfaces in
-- full. GetProjectDetails emits the progress line, then a blank line, then
-- the tiers, so we keep everything up to the first blank line. Returns nil
-- for ordinary processes and when no project is active.
function ProductionHelpText.leagueProgressFor(process)
    local pLeague, lpID = leagueProjectFor(process)
    if pLeague == nil then
        return nil
    end
    local details = pLeague:GetProjectDetails(lpID, Game.GetActivePlayer())
    if details == nil or details == "" then
        return nil
    end
    local sep = "[NEWLINE][NEWLINE]"
    local idx = details:find(sep, 1, true)
    if idx == nil then
        return details
    end
    return details:sub(1, idx - 1)
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

-- "(invested)" marker for a building the player has already invested Gold in
-- (Vox Populi only). VP attaches its own "(INVESTED)" tag to the building
-- name in the production tooltip, which we strip with the rest of the header,
-- so we re-add a concise spoken marker on the surfaces that name an
-- in-progress or buildable building (the production chooser, both production
-- queues). Returns "" on vanilla, on non-building orders, and on buildings
-- with no investment, so callers can append unconditionally. EngineData is
-- guarded so the module still dofiles offline.
function ProductionHelpText.investedTag(city, orderType, data1)
    if orderType ~= OrderTypes.ORDER_CONSTRUCT then
        return ""
    end
    if EngineData == nil or not EngineData.buildingInvestmentsEnabled() then
        return ""
    end
    if not EngineData.buildingInvested(city, data1) then
        return ""
    end
    return Text.key("TXT_KEY_CIVVACCESS_PROD_INVESTED")
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
