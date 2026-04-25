-- Empire-status readouts bound to bare T/R/G/H/F/P/I in baseline. Each key
-- speaks one composed line drawing from the engine's TopPanel readouts plus
-- adjacent surfaces (TechPanel for the active research, CultureOverview for
-- the influential-civ count). The baseline already swallows bare letters via
-- capturesAllInput, so no engine binding is being suppressed beyond the unit-
-- mission keys baseline already discards.
--
-- Composition rules per readout:
--   T - turn and date; appends unit-supply over-cap when the maintenance mod
--       is non-zero (the panel's UnitSupplyString icon).
--   R - turns-to-completion plus tech name plus science per turn. Falls back
--       to a no-research / just-finished branch when GetCurrentResearch is
--       -1, mirroring TechPanel's eRecentTech display.
--   G - GPT plus total plus trade-route slot count, with strategic-resource
--       shortages (GetNumResourceAvailable < 0) appended as a per-resource
--       "no <name>" list.
--   H - empire happiness (happy / unhappy / very unhappy) followed always by
--       golden-age state, whether active (turns remaining) or progressing
--       (current of threshold).
--   F - faith per turn and total.
--   P - culture per turn and turns-to-next-policy (computed from
--       GetNextPolicyCost / GetJONSCulture / GetTotalJONSCulturePerTurn).
--   I - tourism per turn plus influential-civ count. Names the denominator
--       (e.g. "5 of 7 civs") only when within two of victory; otherwise
--       speaks the raw count.
--
-- All readouts honour the engine's "off" game options (NO_SCIENCE,
-- NO_HAPPINESS, NO_RELIGION, NO_POLICIES). Each function is a pure formatter
-- that re-queries the engine on every call - no caching, per project rule.

EmpireStatus = {}

local MOD_NONE = 0

local function speak(s)
    if s == nil or s == "" then
        return
    end
    SpeechPipeline.speakInterrupt(s)
end

-- Concatenate non-empty trailing clauses with ", ". Used by every readout
-- that may suffix the headline with conditional context.
local function joinClauses(...)
    local parts = {}
    for i = 1, select("#", ...) do
        local v = select(i, ...)
        if v ~= nil and v ~= "" then
            parts[#parts + 1] = v
        end
    end
    return table.concat(parts, ", ")
end

-- Unit-supply over-cap clause. Empty when the maintenance mod is zero,
-- which is the same condition the panel uses to hide its UnitSupplyString
-- icon. Surfaces only as a trailing clause on the turn line.
local function supplyClause(player)
    if player:GetUnitProductionMaintenanceMod() == 0 then
        return nil
    end
    local over = player:GetNumUnitsOutOfSupply()
    return Text.format("TXT_KEY_CIVVACCESS_STATUS_SUPPLY_OVER", over)
end

-- Turn and date. Reuses the Turn-module path (TXT_KEY_TP_TURN_COUNTER plus
-- TXT_KEY_TIME_BC / TXT_KEY_TIME_AD) so the spoken format matches what
-- Turn.lua emits at ActivePlayerTurnStart - one consistent calendar shape
-- across every surface that speaks the date.
local function turnLine()
    local turn = Locale.ConvertTextKey("TXT_KEY_TP_TURN_COUNTER", Game.GetGameTurn())
    local year = Game.GetGameTurnYear()
    local dateKey
    if year < 0 then
        dateKey = "TXT_KEY_TIME_BC"
    else
        dateKey = "TXT_KEY_TIME_AD"
    end
    local date = Locale.ConvertTextKey(dateKey, math.abs(year))

    local player = Players[Game.GetActivePlayer()]
    -- Maya calendar (Dlc_06 Babylon -> Maya scenario civ). Speak the long
    -- form because the screen shows a glyph, and the tooltip is the
    -- spoken-out long form of the date.
    if player:IsUsingMayaCalendar() then
        local maya = player:GetMayaCalendarString()
        return joinClauses(turn, date, maya, supplyClause(player))
    end
    return joinClauses(turn, date, supplyClause(player))
end

-- Research: TechPanel's "what am I researching" merged with TopPanel's
-- science rate. Mirrors TechPanel.OnTechPanelUpdated's three-state cascade
-- (current research / just-finished / nothing chosen) so the spoken line
-- describes the same state the visible tech-panel icon does.
local function researchLine()
    if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_SCIENCE) then
        return Text.key("TXT_KEY_CIVVACCESS_STATUS_RESEARCH_OFF")
    end
    local player = Players[Game.GetActivePlayer()]
    local rate = player:GetScience()
    local currentTech = player:GetCurrentResearch()
    if currentTech ~= -1 then
        local turns = player:GetResearchTurnsLeft(currentTech, true)
        local techInfo = GameInfo.Technologies[currentTech]
        local techName = Locale.ConvertTextKey(techInfo.Description)
        return Text.format("TXT_KEY_CIVVACCESS_STATUS_RESEARCH_ACTIVE", turns, techName, rate)
    end
    local team = Teams[player:GetTeam()]
    local lastTech = team:GetTeamTechs():GetLastTechAcquired()
    if lastTech ~= -1 then
        local techInfo = GameInfo.Technologies[lastTech]
        local techName = Locale.ConvertTextKey(techInfo.Description)
        return Text.format("TXT_KEY_CIVVACCESS_STATUS_RESEARCH_DONE", techName, rate)
    end
    return Text.format("TXT_KEY_CIVVACCESS_STATUS_RESEARCH_NONE", rate)
end

-- Strategic-resource shortage list. A resource is short when
-- GetNumResourceAvailable returns negative (using more than we have, e.g.
-- units built before a luxury swap, or a city losing the source). We only
-- name the resource - not the deficit number - because the player checks
-- shortage state to decide whether to act, not to do arithmetic in their
-- head.
local function shortageClause(player)
    local team = Teams[player:GetTeam()]
    local teamTechs = team:GetTeamTechs()
    local names = {}
    for resource in GameInfo.Resources() do
        if Game.GetResourceUsageType(resource.ID) == ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC then
            local techReveal = GameInfoTypes[resource.TechReveal]
            if techReveal == nil or teamTechs:HasTech(techReveal) then
                local available = player:GetNumResourceAvailable(resource.ID, true)
                if available < 0 then
                    names[#names + 1] = Text.format("TXT_KEY_CIVVACCESS_STATUS_GOLD_SHORTAGE_ITEM", Locale.ConvertTextKey(resource.Description))
                end
            end
        end
    end
    if #names == 0 then
        return nil
    end
    return table.concat(names, ", ")
end

-- Gold: GPT, total, trade-route slot use, then strategic shortages. The
-- panel's negative-GPT visual cue (red text) becomes the "minus" prefix in
-- TXT_KEY_CIVVACCESS_STATUS_GOLD_NEGATIVE so the sign is the first word.
local function goldLine()
    local player = Players[Game.GetActivePlayer()]
    local total = player:GetGold()
    local rate = player:CalculateGoldRate()
    local used = player:GetNumInternationalTradeRoutesUsed()
    local avail = player:GetNumInternationalTradeRoutesAvailable()
    local headline
    if rate < 0 then
        headline = Text.format("TXT_KEY_CIVVACCESS_STATUS_GOLD_NEGATIVE", -rate, total, used, avail)
    else
        headline = Text.format("TXT_KEY_CIVVACCESS_STATUS_GOLD_POSITIVE", rate, total, used, avail)
    end
    return joinClauses(headline, shortageClause(player))
end

-- Happiness with golden age always trailing. User asked for fixed ordering
-- so the player's ear locks onto the same shape every press, regardless of
-- whether a golden age is currently running.
local function goldenAgeClause(player)
    local turns = player:GetGoldenAgeTurns()
    if turns > 0 then
        return Text.format("TXT_KEY_CIVVACCESS_STATUS_GA_ACTIVE", turns)
    end
    local cur = player:GetGoldenAgeProgressMeter()
    local threshold = player:GetGoldenAgeProgressThreshold()
    return Text.format("TXT_KEY_CIVVACCESS_STATUS_GA_PROGRESS", cur, threshold)
end

local function happinessLine()
    if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_HAPPINESS) then
        return Text.key("TXT_KEY_CIVVACCESS_STATUS_HAPPINESS_OFF")
    end
    local player = Players[Game.GetActivePlayer()]
    local excess = player:GetExcessHappiness()
    local happinessClause
    if player:IsEmpireVeryUnhappy() then
        happinessClause = Text.format("TXT_KEY_CIVVACCESS_STATUS_VERY_UNHAPPY", -excess)
    elseif player:IsEmpireUnhappy() then
        happinessClause = Text.format("TXT_KEY_CIVVACCESS_STATUS_UNHAPPY", -excess)
    else
        happinessClause = Text.format("TXT_KEY_CIVVACCESS_STATUS_HAPPY", excess)
    end
    return joinClauses(happinessClause, goldenAgeClause(player))
end

local function faithLine()
    if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION) then
        return Text.key("TXT_KEY_CIVVACCESS_STATUS_FAITH_OFF")
    end
    local player = Players[Game.GetActivePlayer()]
    return Text.format("TXT_KEY_CIVVACCESS_STATUS_FAITH", player:GetTotalFaithPerTurn(), player:GetFaith())
end

-- Policy / culture: turns-to-next-policy is computed here rather than
-- spoken as a raw progress fraction because the player's actual question
-- is "how many turns until I can pick another". Math.ceil so a fractional
-- turn always rounds up - matches how the engine's tooltip rounds.
local function policyLine()
    if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_POLICIES) then
        return Text.key("TXT_KEY_CIVVACCESS_STATUS_POLICY_OFF")
    end
    local player = Players[Game.GetActivePlayer()]
    local rate = player:GetTotalJONSCulturePerTurn()
    local cost = player:GetNextPolicyCost()
    if cost <= 0 then
        return Text.format("TXT_KEY_CIVVACCESS_STATUS_POLICY_NONE_LEFT", rate)
    end
    local stored = player:GetJONSCulture()
    local needed = cost - stored
    if needed < 0 then
        needed = 0
    end
    local turns
    if rate <= 0 then
        -- No culture coming in. The engine displays "never" by hiding the
        -- counter; we say "no culture" so the rate=0 case is audible
        -- instead of speaking a misleading turn count.
        return Text.format("TXT_KEY_CIVVACCESS_STATUS_POLICY_STALLED", stored, cost)
    end
    turns = math.ceil(needed / rate)
    return Text.format("TXT_KEY_CIVVACCESS_STATUS_POLICY", rate, turns)
end

-- Influential-civ count for cultural-victory tracking. Iterates the major-
-- civ slots, filters to alive non-minor others, and counts those at
-- INFLUENCE_LEVEL_INFLUENTIAL or higher (Influential plus Dominant).
-- Within-reach threshold (gap <= 2) names the denominator so the player
-- hears the exact gap to a culture victory; below that it speaks a count
-- only.
local function influentialStats(player, activeID)
    local count = 0
    local total = 0
    for i = 0, GameDefines.MAX_CIV_PLAYERS - 1 do
        local other = Players[i]
        if other ~= nil and i ~= activeID and other:IsAlive() and not other:IsMinorCiv() then
            total = total + 1
            local lvl = player:GetInfluenceLevel(i)
            if lvl ~= nil and lvl >= InfluenceLevelTypes.INFLUENCE_LEVEL_INFLUENTIAL then
                count = count + 1
            end
        end
    end
    return count, total
end

local function tourismLine()
    local activeID = Game.GetActivePlayer()
    local player = Players[activeID]
    local rate = player:GetTourism()
    local count, total = influentialStats(player, activeID)
    if count == 0 then
        return Text.format("TXT_KEY_CIVVACCESS_STATUS_TOURISM", rate)
    end
    if total - count <= 2 then
        return Text.format("TXT_KEY_CIVVACCESS_STATUS_TOURISM_WITHIN_REACH", rate, count, total)
    end
    return Text.format("TXT_KEY_CIVVACCESS_STATUS_TOURISM_INFLUENTIAL", rate, count)
end

local bind = HandlerStack.bind

function EmpireStatus.getBindings()
    local bindings = {
        bind(Keys.T, MOD_NONE, function()
            speak(turnLine())
        end, "Turn and date"),
        bind(Keys.R, MOD_NONE, function()
            speak(researchLine())
        end, "Current research and science"),
        bind(Keys.G, MOD_NONE, function()
            speak(goldLine())
        end, "Gold, trade routes, shortages"),
        bind(Keys.H, MOD_NONE, function()
            speak(happinessLine())
        end, "Happiness and golden age"),
        bind(Keys.F, MOD_NONE, function()
            speak(faithLine())
        end, "Faith"),
        bind(Keys.P, MOD_NONE, function()
            speak(policyLine())
        end, "Culture and policy timing"),
        bind(Keys.I, MOD_NONE, function()
            speak(tourismLine())
        end, "Tourism and influential civs"),
    }
    local helpEntries = {
        {
            keyLabel = "TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TURN",
            description = "TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TURN",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_RESEARCH",
            description = "TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_RESEARCH",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_GOLD",
            description = "TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_GOLD",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_HAPPINESS",
            description = "TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_HAPPINESS",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_FAITH",
            description = "TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_FAITH",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_POLICY",
            description = "TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_POLICY",
        },
        {
            keyLabel = "TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_TOURISM",
            description = "TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_TOURISM",
        },
    }
    return { bindings = bindings, helpEntries = helpEntries }
end

-- Test seams. Each readout is a pure formatter - exposing them lets suites
-- assert the composed string against scripted Player / Game state without
-- routing through the bind closure.
EmpireStatus._turnLine = turnLine
EmpireStatus._researchLine = researchLine
EmpireStatus._goldLine = goldLine
EmpireStatus._happinessLine = happinessLine
EmpireStatus._faithLine = faithLine
EmpireStatus._policyLine = policyLine
EmpireStatus._tourismLine = tourismLine
