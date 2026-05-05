-- Empire-status readouts. Bare T/R/G/H/F/P/I speak one-line headlines drawn
-- from the engine's TopPanel readouts plus adjacent surfaces (TechPanel for
-- active research, CultureOverview for the influential-civ count). Shift +
-- R/G/H/F/P/I read the additive content of the corresponding TopPanel
-- tooltip, skipping segments the bare key already covered. Shift+T is
-- intentionally absent: the bare T already speaks the Maya long-form date,
-- which is the only thing CurrentDate's tooltip would have added.
--
-- Composition rules per bare readout:
--   T - turn and date; appends unit-supply over-cap when the maintenance mod
--       is non-zero (the panel's UnitSupplyString icon), then strategic-
--       resource shortages (GetNumResourceAvailable < 0) as a per-resource
--       "no <name>" list. Shortages live on T because they bear on the
--       turn-level question of what units can still be built this turn.
--   R - turns-to-completion plus tech name plus science per turn. Falls back
--       to a no-research / just-finished branch when GetCurrentResearch is
--       -1, mirroring TechPanel's eRecentTech display.
--   G - GPT plus total plus trade-route slot count.
--   H - empire happiness (happy / unhappy / very unhappy), the count of
--       luxuries currently providing happiness (any resource with
--       GetHappinessFromLuxury > 0), then golden-age state, whether active
--       (turns remaining) or progressing (current of threshold).
--   F - faith per turn and total.
--   P - culture per turn and turns-to-next-policy (computed from
--       GetNextPolicyCost / GetJONSCulture / GetTotalJONSCulturePerTurn).
--   I - tourism per turn plus influential-civ count. Names the denominator
--       (e.g. "5 of 7 civs") only when within two of victory; otherwise
--       speaks the raw count.
--
-- Detail readouts mirror the engine *TipHandler functions in TopPanel.lua
-- segment for segment, reusing engine TXT_KEY_TP_* keys verbatim so the
-- spoken text matches what sighted players see in the tooltip. The only
-- segments dropped are the headline duplicates: TXT_KEY_TP_SCIENCE for R,
-- TXT_KEY_TP_AVAILABLE_GOLD plus TXT_KEY_TP_TOTAL_INCOME for G, the total
-- happiness plus golden-age headline lines for H, TXT_KEY_TP_FAITH_ACCUMULATED
-- for F, TXT_KEY_NEXT_POLICY_TURN_LABEL for P, and the within-reach
-- TOURISM_TOOLTIP_3 only when bare I would have spoken the same X-of-Y
-- phrasing. Section breaks (engine [NEWLINE][NEWLINE]) become ". " and item
-- breaks ([NEWLINE]) become ", " so the screen reader gets a sentence cue
-- between source / expense / trailer blocks instead of a comma run-on.
--
-- All readouts honour the engine's "off" game options (NO_SCIENCE,
-- NO_HAPPINESS, NO_RELIGION, NO_POLICIES). Each function is a pure formatter
-- that re-queries the engine on every call - no caching, per project rule.

EmpireStatus = {}

local MOD_NONE = 0
local MOD_SHIFT = 1

-- Section label keys for newDetail.section() transitions where the
-- engine's first item doesn't already anchor the topic. TXT_KEY_HELP and
-- TXT_KEY_EO_INCOME are engine-provided; the rest are mod-authored.
local LABEL_HELP = "TXT_KEY_HELP"
local LABEL_INCOME = "TXT_KEY_EO_INCOME"
local LABEL_GOLDEN_AGE = "TXT_KEY_CIVVACCESS_SECTION_GOLDEN_AGE"
local LABEL_RELIGIONS = "TXT_KEY_CIVVACCESS_SECTION_RELIGIONS"
local LABEL_GREAT_PEOPLE = "TXT_KEY_CIVVACCESS_SECTION_GREAT_PEOPLE"
local LABEL_INFLUENCE = "TXT_KEY_CIVVACCESS_SECTION_INFLUENCE"

local speak = SpeechPipeline.speakInterrupt

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

-- Strategic-resource shortage list. A resource is short when
-- GetNumResourceAvailable returns negative (using more than we have, e.g.
-- units built before a luxury swap, or a city losing the source). We only
-- name the resource - not the deficit number - because the player checks
-- shortage state to decide whether to act, not to do arithmetic in their
-- head. Trailing clause on the turn line so the player learns about
-- supply problems with the same key that says how much time is left.
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
                    names[#names + 1] =
                        Text.format("TXT_KEY_CIVVACCESS_STATUS_SHORTAGE_ITEM", Text.key(resource.Description))
                end
            end
        end
    end
    if #names == 0 then
        return nil
    end
    return table.concat(names, ", ")
end

-- Turn and date. Reuses the Turn-module path (TXT_KEY_TP_TURN_COUNTER plus
-- TXT_KEY_TIME_BC / TXT_KEY_TIME_AD) so the spoken format matches what
-- Turn.lua emits at ActivePlayerTurnStart - one consistent calendar shape
-- across every surface that speaks the date.
local function turnLine()
    local turn = Text.format("TXT_KEY_TP_TURN_COUNTER", Game.GetGameTurn())
    local year = Game.GetGameTurnYear()
    local dateKey
    if year < 0 then
        dateKey = "TXT_KEY_TIME_BC"
    else
        dateKey = "TXT_KEY_TIME_AD"
    end
    local date = Text.format(dateKey, math.abs(year))

    local player = Players[Game.GetActivePlayer()]
    -- Maya calendar (Dlc_06 Babylon -> Maya scenario civ). Speak the long
    -- form because the screen shows a glyph, and the tooltip is the
    -- spoken-out long form of the date.
    if player:IsUsingMayaCalendar() then
        local maya = player:GetMayaCalendarString()
        return joinClauses(turn, date, maya, supplyClause(player), shortageClause(player))
    end
    return joinClauses(turn, date, supplyClause(player), shortageClause(player))
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
        local techName = Text.key(techInfo.Description)
        return Text.formatPlural("TXT_KEY_CIVVACCESS_STATUS_RESEARCH_ACTIVE", turns, turns, techName, rate)
    end
    local team = Teams[player:GetTeam()]
    local lastTech = team:GetTeamTechs():GetLastTechAcquired()
    if lastTech ~= -1 then
        local techInfo = GameInfo.Technologies[lastTech]
        local techName = Text.key(techInfo.Description)
        return Text.format("TXT_KEY_CIVVACCESS_STATUS_RESEARCH_DONE", techName, rate)
    end
    return Text.format("TXT_KEY_CIVVACCESS_STATUS_RESEARCH_NONE", rate)
end

-- Gold: GPT, total, trade-route slot use. The panel's negative-GPT visual
-- cue (red text) becomes the "minus" prefix in
-- TXT_KEY_CIVVACCESS_STATUS_GOLD_NEGATIVE so the sign is the first word.
-- Strategic-resource shortages live on the bare T line (turnLine) instead
-- of here, since they bear on what units can be built this turn.
local function goldLine()
    local player = Players[Game.GetActivePlayer()]
    local total = player:GetGold()
    local rate = player:CalculateGoldRate()
    local used = player:GetNumInternationalTradeRoutesUsed()
    local avail = player:GetNumInternationalTradeRoutesAvailable()
    if rate < 0 then
        return Text.formatPlural("TXT_KEY_CIVVACCESS_STATUS_GOLD_NEGATIVE", avail, -rate, total, used, avail)
    end
    return Text.formatPlural("TXT_KEY_CIVVACCESS_STATUS_GOLD_POSITIVE", avail, rate, total, used, avail)
end

-- Happiness with golden age always trailing. User asked for fixed ordering
-- so the player's ear locks onto the same shape every press, regardless of
-- whether a golden age is currently running.
local function goldenAgeClause(player)
    local turns = player:GetGoldenAgeTurns()
    if turns > 0 then
        return Text.formatPlural("TXT_KEY_CIVVACCESS_STATUS_GA_ACTIVE", turns, turns)
    end
    local cur = player:GetGoldenAgeProgressMeter()
    local threshold = player:GetGoldenAgeProgressThreshold()
    return Text.format("TXT_KEY_CIVVACCESS_STATUS_GA_PROGRESS", cur, threshold)
end

-- Per-luxury inventory: name + total copies for every luxury currently
-- providing happiness. Filters by GetHappinessFromLuxury > 0 so we list
-- only luxuries actually contributing (excludes lost sources, traded-
-- away inventory, unconnected resources). GetNumResourceAvailable with
-- include-imports=true reports total copies the player has access to,
-- which is the "how many do I have" reading. Empty when no luxuries
-- are connected so the headline doesn't grow a trailing clause.
local function luxuryInventoryClause(player)
    local items = {}
    for resource in GameInfo.Resources() do
        if player:GetHappinessFromLuxury(resource.ID) > 0 then
            local count = player:GetNumResourceAvailable(resource.ID, true)
            items[#items + 1] =
                Text.format("TXT_KEY_CIVVACCESS_STATUS_LUXURY_INVENTORY_ITEM", Text.key(resource.Description), count)
        end
    end
    if #items == 0 then
        return nil
    end
    return table.concat(items, ", ")
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
    return joinClauses(happinessClause, goldenAgeClause(player), luxuryInventoryClause(player))
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
    return Text.formatPlural("TXT_KEY_CIVVACCESS_STATUS_POLICY", turns, rate, turns)
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
        return Text.formatPlural("TXT_KEY_CIVVACCESS_STATUS_TOURISM_WITHIN_REACH", total, rate, count, total)
    end
    return Text.formatPlural("TXT_KEY_CIVVACCESS_STATUS_TOURISM_INFLUENTIAL", count, rate, count)
end

-- Detail builder. Items are joined with ", " inside a section, sections
-- with ". " between them. Pass a label to section() to prefix the next
-- non-empty section with "{Label}: " so the listener hears an explicit
-- topic transition; sections whose first item is already a topic-labeled
-- engine sentence (e.g. TXT_KEY_TP_UNHAPPINESS_TOTAL leads with "X total
-- Unhappiness from all sources") leave the label unset and rely on the
-- engine's own anchor. Empty sections are pruned so a conditional block
-- leaves no orphan delimiter.
local function newDetail()
    local sections = { { items = {}, label = nil } }
    local self = {}
    function self.section(label)
        local cur = sections[#sections]
        if #cur.items > 0 then
            sections[#sections + 1] = { items = {}, label = label }
        else
            cur.label = label
        end
    end
    function self.add(s)
        if s == nil or s == "" then
            return
        end
        local cur = sections[#sections]
        cur.items[#cur.items + 1] = s
    end
    -- Engine TXT_KEY_TP_* strings end in their own punctuation - most in
    -- ".", a few in ":". Stripping it here lets the joiners (", " between
    -- items, ". " between sections) read cleanly; otherwise we produce
    -- ".," and ".." runs in the spoken stream.
    local function trimTail(s)
        return (s:gsub("[%s%.;:]+$", ""))
    end
    function self.compose()
        local parts = {}
        for _, sec in ipairs(sections) do
            if #sec.items > 0 then
                local cleaned = {}
                for _, item in ipairs(sec.items) do
                    local t = trimTail(item)
                    if t ~= "" then
                        cleaned[#cleaned + 1] = t
                    end
                end
                local body = table.concat(cleaned, ", ")
                if sec.label ~= nil and sec.label ~= "" then
                    parts[#parts + 1] = sec.label .. ": " .. body
                else
                    parts[#parts + 1] = body
                end
            end
        end
        return table.concat(parts, ". ")
    end
    return self
end

local function noBasicHelp()
    return OptionsManager ~= nil and OptionsManager.IsNoBasicHelp ~= nil and OptionsManager.IsNoBasicHelp()
end

-- Anarchy prefix. Engine handlers prepend this above the headline; bare keys
-- never speak it, so it is purely additive on Shift readouts.
local function anarchyPrefix(player)
    if not player:IsAnarchy() then
        return nil
    end
    return Text.format("TXT_KEY_TP_ANARCHY", player:GetAnarchyNumTurns())
end

-- Research detail. Mirrors ScienceTipHandler: skip TXT_KEY_TP_SCIENCE (the
-- rate already in bare R) and keep every per-source breakdown plus the
-- TECH_CITY_COST basic-help trailer. Section order matches the engine.
local function researchDetail()
    if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_SCIENCE) then
        return ""
    end
    local player = Players[Game.GetActivePlayer()]
    local d = newDetail()
    d.add(anarchyPrefix(player))
    d.section()

    local fromBudgetDeficit = player:GetScienceFromBudgetDeficitTimes100()
    if fromBudgetDeficit ~= 0 then
        d.add(Text.format("TXT_KEY_TP_SCIENCE_FROM_BUDGET_DEFICIT", fromBudgetDeficit / 100))
    end
    local fromCities = player:GetScienceFromCitiesTimes100(true)
    if fromCities ~= 0 then
        d.add(Text.format("TXT_KEY_TP_SCIENCE_FROM_CITIES", fromCities / 100))
    end
    local fromTrade = player:GetScienceFromCitiesTimes100(false) - fromCities
    if fromTrade ~= 0 then
        d.add(Text.format("TXT_KEY_TP_SCIENCE_FROM_ITR", fromTrade / 100))
    end
    local fromOthers = player:GetScienceFromOtherPlayersTimes100()
    if fromOthers ~= 0 then
        d.add(Text.format("TXT_KEY_TP_SCIENCE_FROM_MINORS", fromOthers / 100))
    end
    local fromHappiness = player:GetScienceFromHappinessTimes100()
    if fromHappiness ~= 0 then
        d.add(Text.format("TXT_KEY_TP_SCIENCE_FROM_HAPPINESS", fromHappiness / 100))
    end
    local fromRAs = player:GetScienceFromResearchAgreementsTimes100()
    if fromRAs ~= 0 then
        d.add(Text.format("TXT_KEY_TP_SCIENCE_FROM_RESEARCH_AGREEMENTS", fromRAs / 100))
    end

    if not noBasicHelp() then
        d.section(Text.key(LABEL_HELP))
        -- TXT_KEY_TP_TECH_CITY_COST is a one-sentence explainer that
        -- carries one data value (the percent). Short mod-authored form
        -- delivers the data without the rules wrapper.
        d.add(Text.format("TXT_KEY_CIVVACCESS_STATUS_TECH_CITY_COST", Game.GetNumCitiesTechCostMod()))
    end
    return d.compose()
end

-- Gold detail. Mirrors GoldTipHandler: skip TXT_KEY_TP_AVAILABLE_GOLD (the
-- treasury, in bare G) and TXT_KEY_TP_TOTAL_INCOME (the GPT, in bare G);
-- keep the per-source income breakdown, the expense block, the
-- LOSING_SCIENCE_FROM_DEFICIT warning when applicable, and the basic-help
-- trailer.
local function goldDetail()
    local player = Players[Game.GetActivePlayer()]
    local d = newDetail()
    d.add(anarchyPrefix(player))

    local fromOthers = player:GetGoldPerTurnFromDiplomacy()
    local toOthers = 0
    if fromOthers < 0 then
        toOthers = -fromOthers
        fromOthers = 0
    end
    local fromReligion = player:GetGoldPerTurnFromReligion()
    local tradeRouteGold = (player:GetGoldFromCitiesTimes100() - player:GetGoldFromCitiesMinusTradeRoutesTimes100())
        / 100
    local fromCities = player:GetGoldFromCitiesMinusTradeRoutesTimes100() / 100
    local cityConnectionGold = player:GetCityConnectionGoldTimes100() / 100
    local traitGold = player:GetGoldPerTurnFromTraits()

    d.section(Text.key(LABEL_INCOME))
    d.add(Text.format("TXT_KEY_TP_CITY_OUTPUT", fromCities))
    d.add(Text.format("TXT_KEY_TP_GOLD_FROM_CITY_CONNECTIONS", math.floor(cityConnectionGold)))
    d.add(Text.format("TXT_KEY_TP_GOLD_FROM_ITR", math.floor(tradeRouteGold)))
    if math.floor(traitGold) > 0 then
        d.add(Text.format("TXT_KEY_TP_GOLD_FROM_TRAITS", math.floor(traitGold)))
    end
    if fromOthers > 0 then
        d.add(Text.format("TXT_KEY_TP_GOLD_FROM_OTHERS", fromOthers))
    end
    if fromReligion > 0 then
        d.add(Text.format("TXT_KEY_TP_GOLD_FROM_RELIGION", fromReligion))
    end

    local unitCost = player:CalculateUnitCost()
    local unitSupply = player:CalculateUnitSupply()
    local buildingMaint = player:GetBuildingGoldMaintenance()
    local improvementMaint = player:GetImprovementGoldMaintenance()
    local totalExpenses = unitCost + unitSupply + buildingMaint + improvementMaint + toOthers

    d.section()
    d.add(Text.format("TXT_KEY_TP_TOTAL_EXPENSES", totalExpenses))
    if unitCost ~= 0 then
        d.add(Text.format("TXT_KEY_TP_UNIT_MAINT", unitCost))
    end
    if unitSupply ~= 0 then
        d.add(Text.format("TXT_KEY_TP_GOLD_UNIT_SUPPLY", unitSupply))
    end
    if buildingMaint ~= 0 then
        d.add(Text.format("TXT_KEY_TP_GOLD_BUILDING_MAINT", buildingMaint))
    end
    if improvementMaint ~= 0 then
        d.add(Text.format("TXT_KEY_TP_GOLD_TILE_MAINT", improvementMaint))
    end
    if toOthers > 0 then
        d.add(Text.format("TXT_KEY_TP_GOLD_TO_OTHERS", toOthers))
    end

    local fTotalIncome = fromCities + fromOthers + cityConnectionGold + fromReligion + tradeRouteGold + traitGold
    if fTotalIncome + player:GetGold() < 0 then
        d.section()
        d.add(Text.key("TXT_KEY_TP_LOSING_SCIENCE_FROM_DEFICIT"))
    end

    if not noBasicHelp() then
        d.section(Text.key(LABEL_HELP))
        d.add(Text.key("TXT_KEY_TP_GOLD_EXPLANATION"))
    end
    return d.compose()
end

-- Per-luxury-resource breakdown for happinessDetail's resources line.
-- Mirrors HappinessTipHandler's GameInfo.Resources iteration verbatim,
-- including the variety bonus, the per-luxury extra, and the catch-all
-- misc bucket.
local function happinessResourceItems(player, resourcesHappiness, extraLuxuryHappiness)
    local items = {}
    local baseFromResources = 0
    local numHappinessResources = 0
    for resource in GameInfo.Resources() do
        local h = player:GetHappinessFromLuxury(resource.ID)
        if h > 0 then
            items[#items + 1] = "+"
                .. Text.format("TXT_KEY_TP_HAPPINESS_EACH_RESOURCE", h, resource.IconString, resource.Description)
            numHappinessResources = numHappinessResources + 1
            baseFromResources = baseFromResources + h
        end
    end
    local fromVariety = player:GetHappinessFromResourceVariety()
    if fromVariety > 0 then
        items[#items + 1] = "+" .. Text.format("TXT_KEY_TP_HAPPINESS_RESOURCE_VARIETY", fromVariety)
    end
    if extraLuxuryHappiness >= 1 then
        items[#items + 1] = "+"
            .. Text.format("TXT_KEY_TP_HAPPINESS_EXTRA_PER_RESOURCE", extraLuxuryHappiness, numHappinessResources)
    end
    local misc = resourcesHappiness - baseFromResources - fromVariety - (extraLuxuryHappiness * numHappinessResources)
    if misc > 0 then
        items[#items + 1] = "+" .. Text.format("TXT_KEY_TP_HAPPINESS_OTHER_SOURCES", misc)
    end
    return items
end

-- Golden-age portion of happinessDetail. Mirrors GoldenAgeTipHandler: skip
-- the headline (NOW or PROGRESS line) and keep the addition / loss line, the
-- effect description, and the Brazil carnival modifier when active.
local function goldenAgeDetailSegments(player, d)
    if player:GetGoldenAgeTurns() <= 0 then
        local excessHappy = player:GetExcessHappiness()
        if excessHappy >= 0 then
            d.add(Text.format("TXT_KEY_TP_GOLDEN_AGE_ADDITION", excessHappy))
        else
            d.add(Text.format("TXT_KEY_TP_GOLDEN_AGE_LOSS", -excessHappy))
        end
    end
    -- The engine renders TXT_KEY_TP_GOLDEN_AGE_EFFECT unconditionally;
    -- it's pure rules explainer with no current-state data, so for our
    -- experienced listeners we gate it the same way the dedicated
    -- *_EXPLANATION trailers are gated.
    if not noBasicHelp() then
        d.section()
        if player:IsGoldenAgeCultureBonusDisabled() then
            d.add(Text.key("TXT_KEY_TP_GOLDEN_AGE_EFFECT_NO_CULTURE"))
        else
            d.add(Text.key("TXT_KEY_TP_GOLDEN_AGE_EFFECT"))
        end
    end
    if player:GetGoldenAgeTurns() > 0 and player:GetGoldenAgeTourismModifier() > 0 then
        d.section()
        d.add(Text.key("TXT_KEY_TP_CARNIVAL_EFFECT"))
    end
end

-- Happiness detail. Mirrors HappinessTipHandler then folds in
-- GoldenAgeTipHandler at the end (since bare H reads both happiness and
-- golden-age headlines, the detail extends both). Skips total happiness /
-- unhappiness lines and the golden-age NOW / PROGRESS lines; keeps the
-- VERY_UNHAPPY warning, the source / unhappiness breakdowns, the basic-help
-- trailer, and the golden-age addition / effect / carnival lines.
local function happinessDetail()
    if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_HAPPINESS) then
        return ""
    end
    local player = Players[Game.GetActivePlayer()]
    local d = newDetail()

    if player:IsEmpireVeryUnhappy() then
        if player:IsEmpireSuperUnhappy() then
            d.add(Text.key("TXT_KEY_TP_EMPIRE_SUPER_UNHAPPY"))
            d.section()
        end
        d.add(Text.key("TXT_KEY_TP_EMPIRE_VERY_UNHAPPY"))
    elseif player:IsEmpireUnhappy() then
        d.add(Text.key("TXT_KEY_TP_EMPIRE_UNHAPPY"))
    end

    local policiesHappiness = player:GetHappinessFromPolicies()
    local resourcesHappiness = player:GetHappinessFromResources()
    local extraLuxuryHappiness = player:GetExtraHappinessPerLuxury()
    local cityHappiness = player:GetHappinessFromCities()
    local buildingHappiness = player:GetHappinessFromBuildings()
    local tradeRouteHappiness = player:GetHappinessFromTradeRoutes()
    local religionHappiness = player:GetHappinessFromReligion()
    local naturalWonderHappiness = player:GetHappinessFromNaturalWonders()
    local extraHappinessPerCity = player:GetExtraHappinessPerCity() * player:GetNumCities()
    local minorCivHappiness = player:GetHappinessFromMinorCivs()
    local leagueHappiness = player:GetHappinessFromLeagues()
    local handicapHappiness = player:GetHappiness()
        - policiesHappiness
        - resourcesHappiness
        - cityHappiness
        - buildingHappiness
        - tradeRouteHappiness
        - religionHappiness
        - naturalWonderHappiness
        - minorCivHappiness
        - extraHappinessPerCity
        - leagueHappiness
    local totalHappiness = policiesHappiness
        + resourcesHappiness
        + cityHappiness
        + buildingHappiness
        + minorCivHappiness
        + handicapHappiness
        + tradeRouteHappiness
        + religionHappiness
        + naturalWonderHappiness
        + extraHappinessPerCity
        + leagueHappiness

    d.section()
    d.add(Text.format("TXT_KEY_TP_HAPPINESS_SOURCES", totalHappiness))
    d.add(Text.format("TXT_KEY_TP_HAPPINESS_FROM_RESOURCES", resourcesHappiness))
    for _, item in ipairs(happinessResourceItems(player, resourcesHappiness, extraLuxuryHappiness)) do
        d.add(item)
    end
    d.add(Text.format("TXT_KEY_TP_HAPPINESS_CITIES", cityHappiness))
    if policiesHappiness >= 0 then
        d.add(Text.format("TXT_KEY_TP_HAPPINESS_POLICIES", policiesHappiness))
    end
    d.add(Text.format("TXT_KEY_TP_HAPPINESS_BUILDINGS", buildingHappiness))
    if tradeRouteHappiness ~= 0 then
        d.add(Text.format("TXT_KEY_TP_HAPPINESS_CONNECTED_CITIES", tradeRouteHappiness))
    end
    if religionHappiness ~= 0 then
        d.add(Text.format("TXT_KEY_TP_HAPPINESS_STATE_RELIGION", religionHappiness))
    end
    if naturalWonderHappiness ~= 0 then
        d.add(Text.format("TXT_KEY_TP_HAPPINESS_NATURAL_WONDERS", naturalWonderHappiness))
    end
    if extraHappinessPerCity ~= 0 then
        d.add(Text.format("TXT_KEY_TP_HAPPINESS_CITY_COUNT", extraHappinessPerCity))
    end
    if minorCivHappiness ~= 0 then
        d.add(Text.format("TXT_KEY_TP_HAPPINESS_CITY_STATE_FRIENDSHIP", minorCivHappiness))
    end
    if leagueHappiness ~= 0 then
        d.add(Text.format("TXT_KEY_TP_HAPPINESS_LEAGUES", leagueHappiness))
    end
    d.add(Text.format("TXT_KEY_TP_HAPPINESS_DIFFICULTY_LEVEL", handicapHappiness))

    local totalUnhappiness = player:GetUnhappiness()
    local fromUnits = Locale.ToNumber(player:GetUnhappinessFromUnits() / 100, "#.##")
    local fromCityCount = Locale.ToNumber(player:GetUnhappinessFromCityCount() / 100, "#.##")
    local fromCapturedCities = Locale.ToNumber(player:GetUnhappinessFromCapturedCityCount() / 100, "#.##")
    local fromPuppets = player:GetUnhappinessFromPuppetCityPopulation()
    local fromSpecialists = player:GetUnhappinessFromCitySpecialists()
    local popOnly = player:GetUnhappinessFromCityPopulation() - fromSpecialists - fromPuppets
    local fromPop = Locale.ToNumber(popOnly / 100, "#.##")
    local fromOccupied = Locale.ToNumber(player:GetUnhappinessFromOccupiedCities() / 100, "#.##")
    local publicOpinion = player:GetUnhappinessFromPublicOpinion()

    d.section()
    d.add(Text.format("TXT_KEY_TP_UNHAPPINESS_TOTAL", totalUnhappiness))
    d.add(Text.format("TXT_KEY_TP_UNHAPPINESS_CITY_COUNT", fromCityCount))
    if fromCapturedCities ~= "0" then
        d.add(Text.format("TXT_KEY_TP_UNHAPPINESS_CAPTURED_CITY_COUNT", fromCapturedCities))
    end
    d.add(Text.format("TXT_KEY_TP_UNHAPPINESS_POPULATION", fromPop))
    if fromPuppets > 0 then
        d.add(Text.format("TXT_KEY_TP_UNHAPPINESS_PUPPET_CITIES", fromPuppets / 100))
    end
    if fromSpecialists > 0 then
        d.add(Text.format("TXT_KEY_TP_UNHAPPINESS_SPECIALISTS", fromSpecialists / 100))
    end
    if fromOccupied ~= "0" then
        d.add(Text.format("TXT_KEY_TP_UNHAPPINESS_OCCUPIED_POPULATION", fromOccupied))
    end
    if fromUnits ~= "0" then
        d.add(Text.format("TXT_KEY_TP_UNHAPPINESS_UNITS", fromUnits))
    end
    if policiesHappiness < 0 then
        d.add(Text.format("TXT_KEY_TP_HAPPINESS_POLICIES", policiesHappiness))
    end
    if publicOpinion > 0 then
        d.add(Text.format("TXT_KEY_TP_UNHAPPINESS_PUBLIC_OPINION", publicOpinion))
    end

    if not noBasicHelp() then
        d.section(Text.key(LABEL_HELP))
        d.add(Text.key("TXT_KEY_TP_HAPPINESS_EXPLANATION"))
    end

    -- Golden-age portion. Bare H reads the GA headline (active turns or
    -- progress meter); the detail extends with the addition / loss line and
    -- the effect description.
    d.section(Text.key(LABEL_GOLDEN_AGE))
    goldenAgeDetailSegments(player, d)
    return d.compose()
end

-- Faith detail. Mirrors FaithTipHandler: skip TXT_KEY_TP_FAITH_ACCUMULATED
-- (the total, in bare F) and keep per-source faith breakdown, prophet /
-- pantheon / religion-count info, and the industrial-era great-person list.
local function faithDetail()
    if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION) then
        return ""
    end
    local player = Players[Game.GetActivePlayer()]
    local d = newDetail()
    d.add(anarchyPrefix(player))
    d.section()

    local fromCities = player:GetFaithPerTurnFromCities()
    if fromCities ~= 0 then
        d.add(Text.format("TXT_KEY_TP_FAITH_FROM_CITIES", fromCities))
    end
    local fromMinors = player:GetFaithPerTurnFromMinorCivs()
    if fromMinors ~= 0 then
        d.add(Text.format("TXT_KEY_TP_FAITH_FROM_MINORS", fromMinors))
    end
    local fromReligion = player:GetFaithPerTurnFromReligion()
    if fromReligion ~= 0 then
        d.add(Text.format("TXT_KEY_TP_FAITH_FROM_RELIGION", fromReligion))
    end

    d.section(Text.key(LABEL_RELIGIONS))
    if player:HasCreatedPantheon() then
        if
            (Game.GetNumReligionsStillToFound() > 0 or player:HasCreatedReligion())
            and player:GetCurrentEra() < GameInfo.Eras["ERA_INDUSTRIAL"].ID
        then
            -- TXT_KEY_TP_FAITH_NEXT_PROPHET phrases as "{N} Faith is
            -- minimum required for your next chance at a Great Prophet".
            -- Same family as the next-pantheon line; data is the value.
            d.add(Text.format("TXT_KEY_CIVVACCESS_STATUS_FAITH_NEXT_PROPHET", player:GetMinimumFaithNextGreatProphet()))
        end
    else
        if player:CanCreatePantheon(false) then
            -- TXT_KEY_TP_FAITH_NEXT_PANTHEON bakes the data ("X faith") into
            -- the same key as a long rules explainer ("If you wish to found
            -- a pantheon, you must do it before there is an Enhanced
            -- Religion..."). Use a mod-authored short form so the listener
            -- gets the number without the lecture.
            d.add(Text.format("TXT_KEY_CIVVACCESS_STATUS_FAITH_NEXT_PANTHEON", Game.GetMinimumFaithNextPantheon()))
        else
            -- Engine TXT_KEY_TP_FAITH_PANTHEONS_LOCKED is a four-sentence
            -- rules paragraph with no live data. Mirror the pantheon-faith
            -- branch and use a short mod-authored form.
            d.add(Text.key("TXT_KEY_CIVVACCESS_STATUS_FAITH_PANTHEONS_LOCKED"))
        end
    end

    local stillToFound = Game.GetNumReligionsStillToFound()
    if stillToFound < 0 then
        stillToFound = 0
    end
    d.add(Text.format("TXT_KEY_TP_FAITH_RELIGIONS_LEFT", stillToFound))

    if player:GetCurrentEra() >= GameInfo.Eras["ERA_INDUSTRIAL"].ID then
        d.section(Text.key(LABEL_GREAT_PEOPLE))
        d.add(Text.format("TXT_KEY_TP_FAITH_NEXT_GREAT_PERSON", player:GetMinimumFaithNextGreatProphet()))
        local capital = player:GetCapitalCity()
        local anyFound = false
        if capital ~= nil then
            for info in GameInfo.Units({ Special = "SPECIALUNIT_PEOPLE" }) do
                local faithCost = capital:GetUnitFaithPurchaseCost(info.ID, true)
                if
                    faithCost > 0
                    and player:IsCanPurchaseAnyCity(false, true, info.ID, -1, YieldTypes.YIELD_FAITH)
                    and player:DoesUnitPassFaithPurchaseCheck(info.ID)
                then
                    d.add(Text.key(info.Description))
                    anyFound = true
                end
            end
        end
        if not anyFound then
            d.add(Text.key("TXT_KEY_RO_YR_NO_GREAT_PEOPLE"))
        end
    end
    return d.compose()
end

-- Policy detail. Mirrors CultureTipHandler: skip TXT_KEY_NEXT_POLICY_TURN_LABEL
-- (turns, in bare P) and keep CULTURE_ACCUMULATED + CULTURE_NEXT_POLICY (the
-- stored-vs-cost numbers, additive), per-source culture breakdown, and the
-- TP_CULTURE_CITY_COST trailer. Anarchy short-circuits the source breakdown
-- the same way the engine does.
local function policyDetail()
    if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_POLICIES) then
        return ""
    end
    local player = Players[Game.GetActivePlayer()]
    local d = newDetail()
    d.add(anarchyPrefix(player))

    if not noBasicHelp() then
        d.section()
        d.add(Text.format("TXT_KEY_TP_CULTURE_ACCUMULATED", player:GetJONSCulture()))
        if player:GetNextPolicyCost() > 0 then
            d.add(Text.format("TXT_KEY_TP_CULTURE_NEXT_POLICY", player:GetNextPolicyCost()))
        end
    end

    if player:IsAnarchy() then
        return d.compose()
    end

    d.section()
    local cultureForFree = player:GetJONSCulturePerTurnForFree()
    if cultureForFree ~= 0 then
        d.add(Text.format("TXT_KEY_TP_CULTURE_FOR_FREE", cultureForFree))
    end
    local fromCities = player:GetJONSCulturePerTurnFromCities()
    if fromCities ~= 0 then
        d.add(Text.format("TXT_KEY_TP_CULTURE_FROM_CITIES", fromCities))
    end
    local fromHappiness = player:GetJONSCulturePerTurnFromExcessHappiness()
    if fromHappiness ~= 0 then
        d.add(Text.format("TXT_KEY_TP_CULTURE_FROM_HAPPINESS", fromHappiness))
    end
    local fromTraits = player:GetJONSCulturePerTurnFromTraits()
    if fromTraits ~= 0 then
        d.add(Text.format("TXT_KEY_TP_CULTURE_FROM_TRAITS", fromTraits))
    end
    local fromMinors = player:GetCulturePerTurnFromMinorCivs()
    if fromMinors ~= 0 then
        d.add(Text.format("TXT_KEY_TP_CULTURE_FROM_MINORS", fromMinors))
    end
    local fromReligion = player:GetCulturePerTurnFromReligion()
    if fromReligion ~= 0 then
        d.add(Text.format("TXT_KEY_TP_CULTURE_FROM_RELIGION", fromReligion))
    end
    local fromBonusTurns = player:GetCulturePerTurnFromBonusTurns()
    if fromBonusTurns ~= 0 then
        d.add(Text.format("TXT_KEY_TP_CULTURE_FROM_BONUS_TURNS", fromBonusTurns, player:GetCultureBonusTurns()))
    end
    local fromGoldenAge = player:GetTotalJONSCulturePerTurn()
        - cultureForFree
        - fromCities
        - fromHappiness
        - fromMinors
        - fromReligion
        - fromTraits
        - fromBonusTurns
    if fromGoldenAge ~= 0 then
        d.add(Text.format("TXT_KEY_TP_CULTURE_FROM_GOLDEN_AGE", fromGoldenAge))
    end

    if not noBasicHelp() then
        d.section(Text.key(LABEL_HELP))
        -- TXT_KEY_TP_CULTURE_CITY_COST adds a "don't expand too much!"
        -- exclamation alongside the data percent. Mirror the tech-cost
        -- short form: data only, no rules nudge.
        d.add(Text.format("TXT_KEY_CIVVACCESS_STATUS_POLICY_CITY_COST", Game.GetNumCitiesPolicyCostMod()))
    end
    return d.compose()
end

-- Tourism detail. Mirrors TourismTipHandler: keep TOOLTIP_1 (great works
-- count) and TOOLTIP_2 (empty slots), since neither is in bare I. TOOLTIP_3
-- (influential of total) is gated by both PreGame.IsVictory(VICTORY_CULTURAL)
-- AND the bare I within-reach branch having already spoken the same X-of-Y;
-- we drop it only when the bare key already said it.
local function tourismDetail()
    local activeID = Game.GetActivePlayer()
    local player = Players[activeID]
    local totalGreatWorks = player:GetNumGreatWorks()
    local totalSlots = player:GetNumGreatWorkSlots()

    local d = newDetail()
    d.add(Text.format("TXT_KEY_TOP_PANEL_TOURISM_TOOLTIP_1", totalGreatWorks))
    d.add(Text.format("TXT_KEY_TOP_PANEL_TOURISM_TOOLTIP_2", totalSlots - totalGreatWorks))

    local cultureVictory = GameInfo.Victories["VICTORY_CULTURAL"]
    if cultureVictory ~= nil and PreGame.IsVictory(cultureVictory.ID) then
        local count, total = influentialStats(player, activeID)
        local bareSpokeXofY = count > 0 and (total - count <= 2)
        if not bareSpokeXofY then
            local numInfluential = player:GetNumCivsInfluentialOn()
            local numToBe = player:GetNumCivsToBeInfluentialOn()
            local szText = Text.format("TXT_KEY_CO_VICTORY_INFLUENTIAL_OF", numInfluential, numToBe)
            d.section(Text.key(LABEL_INFLUENCE))
            d.add(Text.format("TXT_KEY_TOP_PANEL_TOURISM_TOOLTIP_3", szText))
        end
    end
    return d.compose()
end

local bind = HandlerStack.bind

-- One row per binding. The bare-letter / Shift+letter pair for each metric
-- reads as a unit in the help list (T then R + Shift+R then G + Shift+G ...);
-- Shift+T is intentionally absent because the bare T already includes the
-- Maya long-form date that CurrentDate's tooltip would have added.
local function getMetrics()
    return {
        { key = Keys.T, mod = MOD_NONE, fn = turnLine, desc = "Turn and date", helpSuffix = "TURN" },
        {
            key = Keys.R,
            mod = MOD_NONE,
            fn = researchLine,
            desc = "Current research and science",
            helpSuffix = "RESEARCH",
        },
        {
            key = Keys.R,
            mod = MOD_SHIFT,
            fn = researchDetail,
            desc = "Research breakdown",
            helpSuffix = "RESEARCH_DETAIL",
        },
        { key = Keys.G, mod = MOD_NONE, fn = goldLine, desc = "Gold, trade routes, shortages", helpSuffix = "GOLD" },
        { key = Keys.G, mod = MOD_SHIFT, fn = goldDetail, desc = "Gold breakdown", helpSuffix = "GOLD_DETAIL" },
        {
            key = Keys.H,
            mod = MOD_NONE,
            fn = happinessLine,
            desc = "Happiness and golden age",
            helpSuffix = "HAPPINESS",
        },
        {
            key = Keys.H,
            mod = MOD_SHIFT,
            fn = happinessDetail,
            desc = "Happiness and golden age breakdown",
            helpSuffix = "HAPPINESS_DETAIL",
        },
        { key = Keys.F, mod = MOD_NONE, fn = faithLine, desc = "Faith", helpSuffix = "FAITH" },
        { key = Keys.F, mod = MOD_SHIFT, fn = faithDetail, desc = "Faith breakdown", helpSuffix = "FAITH_DETAIL" },
        { key = Keys.P, mod = MOD_NONE, fn = policyLine, desc = "Culture and policy timing", helpSuffix = "POLICY" },
        { key = Keys.P, mod = MOD_SHIFT, fn = policyDetail, desc = "Culture breakdown", helpSuffix = "POLICY_DETAIL" },
        {
            key = Keys.I,
            mod = MOD_NONE,
            fn = tourismLine,
            desc = "Tourism and influential civs",
            helpSuffix = "TOURISM",
        },
        {
            key = Keys.I,
            mod = MOD_SHIFT,
            fn = tourismDetail,
            desc = "Tourism breakdown",
            helpSuffix = "TOURISM_DETAIL",
        },
    }
end

function EmpireStatus.getBindings()
    local bindings = {}
    local helpEntries = {}
    for _, m in ipairs(getMetrics()) do
        bindings[#bindings + 1] = bind(m.key, m.mod, function()
            speak(m.fn())
        end, m.desc)
        helpEntries[#helpEntries + 1] = {
            keyLabel = "TXT_KEY_CIVVACCESS_STATUS_HELP_KEY_" .. m.helpSuffix,
            description = "TXT_KEY_CIVVACCESS_STATUS_HELP_DESC_" .. m.helpSuffix,
        }
    end
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
EmpireStatus._researchDetail = researchDetail
EmpireStatus._goldDetail = goldDetail
EmpireStatus._happinessDetail = happinessDetail
EmpireStatus._faithDetail = faithDetail
EmpireStatus._policyDetail = policyDetail
EmpireStatus._tourismDetail = tourismDetail
