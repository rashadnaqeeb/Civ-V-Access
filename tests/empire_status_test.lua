-- EmpireStatus readout composition tests. Each test scripts the engine
-- surfaces the relevant readout queries (active player, active research,
-- happiness flags, golden age state, etc.) and asserts the composed line
-- against the exact spoken string. The seven readout functions are pure
-- formatters re-exposed via EmpireStatus._<name>Line for test access.
--
-- Game text keys we depend on for the formatted result. Mod-authored
-- TXT_KEY_CIVVACCESS_STATUS_* keys come from the production strings file
-- (loaded by run.lua), so their templates are the ones the player hears
-- in-game. The two engine keys (TP_TURN_COUNTER, TIME_AD/BC) we mirror
-- here so the assertion matches what Locale.ConvertTextKey returns.

local T = require("support")
local M = {}

local GAME_TEXT = {
    ["TXT_KEY_TP_TURN_COUNTER"] = "Turn: {1_Nim}",
    ["TXT_KEY_TIME_AD"] = "{1_Date} AD",
    ["TXT_KEY_TIME_BC"] = "{1_Date} BC",
    -- Tech / resource Description fields are TXT_KEY_TECH_MINING etc; the
    -- test scripts feed the descriptions directly as the keys, so a passthrough
    -- in Locale.ConvertTextKey is sufficient.
}

local activePlayer
local team
local resources
local resourceUsage
local researchTech
local researchTurns
local lastTech
local techDescriptions
local options
local goldData
local happyData
local goldenAgeData
local faithData
local cultureData
local tourismRate
local otherPlayers
local influenceLevels

local function setup()
    Locale.ConvertTextKey = function(key, ...)
        local template = GAME_TEXT[key] or key
        local args = { ... }
        if #args == 0 then
            return template
        end
        return (
            template:gsub("{(%d+)_[^}]*}", function(n)
                local v = args[tonumber(n)]
                if v == nil then
                    return ""
                end
                return tostring(v)
            end)
        )
    end

    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_EmpireStatus.lua")

    options = {}
    goldData = { gold = 0, rate = 0, used = 0, avail = 0 }
    happyData = { excess = 0, unhappy = false, veryUnhappy = false }
    goldenAgeData = { turns = 0, meter = 0, threshold = 100 }
    faithData = { faith = 0, rate = 0 }
    cultureData = { culture = 0, cost = 0, rate = 0 }
    tourismRate = 0
    otherPlayers = {}
    influenceLevels = {}
    resources = {}
    resourceUsage = {}
    researchTech = -1
    researchTurns = 0
    lastTech = -1
    techDescriptions = {}

    Game.GetActivePlayer = function()
        return 0
    end
    Game.GetGameTurn = function()
        return 47
    end
    Game.GetGameTurnYear = function()
        return 1620
    end
    Game.IsOption = function(opt)
        return options[opt] == true
    end
    Game.GetResourceUsageType = function(id)
        return resourceUsage[id] or 0
    end

    GameOptionTypes = {
        GAMEOPTION_NO_SCIENCE = 1,
        GAMEOPTION_NO_HAPPINESS = 2,
        GAMEOPTION_NO_RELIGION = 3,
        GAMEOPTION_NO_POLICIES = 4,
    }
    ResourceUsageTypes = {
        RESOURCEUSAGE_BONUS = 0,
        RESOURCEUSAGE_STRATEGIC = 1,
        RESOURCEUSAGE_LUXURY = 2,
    }
    InfluenceLevelTypes = {
        NO_INFLUENCE_LEVEL = -1,
        INFLUENCE_LEVEL_UNKNOWN = 0,
        INFLUENCE_LEVEL_EXOTIC = 1,
        INFLUENCE_LEVEL_FAMILIAR = 2,
        INFLUENCE_LEVEL_POPULAR = 3,
        INFLUENCE_LEVEL_INFLUENTIAL = 4,
        INFLUENCE_LEVEL_DOMINANT = 5,
    }
    GameDefines = GameDefines or {}
    GameDefines.MAX_CIV_PLAYERS = 8

    -- Resource catalog driver: GameInfo.Resources() iterates whatever the
    -- test sets up via the resources table. Each entry is a row with the
    -- shape the production code reads (ID, Description, TechReveal).
    GameInfo = GameInfo or {}
    GameInfo.Resources = function()
        local i = 0
        return function()
            i = i + 1
            return resources[i]
        end
    end
    GameInfo.Technologies = setmetatable({}, {
        __index = function(_, k)
            return techDescriptions[k]
        end,
    })
    GameInfoTypes = setmetatable({}, {
        -- Map TechReveal string keys to integer ids; a missing key returns
        -- nil (production code treats nil reveal as "no tech gate").
        __index = function(_, _k)
            return nil
        end,
    })

    team = {
        GetTeamTechs = function(self)
            return self
        end,
        HasTech = function(_, _id)
            return true
        end,
        GetLastTechAcquired = function()
            return lastTech
        end,
    }
    Teams = { [0] = team }

    activePlayer = {
        GetTeam = function()
            return 0
        end,
        IsUsingMayaCalendar = function()
            return false
        end,
        GetUnitProductionMaintenanceMod = function()
            return 0
        end,
        GetNumUnitsOutOfSupply = function()
            return 0
        end,
        GetCurrentResearch = function()
            return researchTech
        end,
        GetResearchTurnsLeft = function(_, _, _)
            return researchTurns
        end,
        GetScience = function()
            return researchTurns > 0 and 12 or 0
        end,
        GetGold = function()
            return goldData.gold
        end,
        CalculateGoldRate = function()
            return goldData.rate
        end,
        GetNumInternationalTradeRoutesUsed = function()
            return goldData.used
        end,
        GetNumInternationalTradeRoutesAvailable = function()
            return goldData.avail
        end,
        GetNumResourceAvailable = function(_, id, _)
            for _, r in ipairs(resources) do
                if r.ID == id then
                    return r.Available or 0
                end
            end
            return 0
        end,
        GetHappinessFromLuxury = function(_, id)
            for _, r in ipairs(resources) do
                if r.ID == id then
                    return r.HappinessFromLuxury or 0
                end
            end
            return 0
        end,
        GetExcessHappiness = function()
            return happyData.excess
        end,
        IsEmpireUnhappy = function()
            return happyData.unhappy
        end,
        IsEmpireVeryUnhappy = function()
            return happyData.veryUnhappy
        end,
        GetGoldenAgeTurns = function()
            return goldenAgeData.turns
        end,
        GetGoldenAgeProgressMeter = function()
            return goldenAgeData.meter
        end,
        GetGoldenAgeProgressThreshold = function()
            return goldenAgeData.threshold
        end,
        GetFaith = function()
            return faithData.faith
        end,
        GetTotalFaithPerTurn = function()
            return faithData.rate
        end,
        GetJONSCulture = function()
            return cultureData.culture
        end,
        GetNextPolicyCost = function()
            return cultureData.cost
        end,
        GetTotalJONSCulturePerTurn = function()
            return cultureData.rate
        end,
        GetTourism = function()
            return tourismRate
        end,
        GetInfluenceLevel = function(_, otherID)
            return influenceLevels[otherID] or InfluenceLevelTypes.NO_INFLUENCE_LEVEL
        end,
    }
    -- Production code reads Players[id] without a method receiver; assign
    -- the script as a plain table.
    Players = {}
    Players[0] = activePlayer
    for i = 1, 7 do
        local data = otherPlayers[i] or {}
        Players[i] = {
            IsAlive = function()
                return data.alive ~= false
            end,
            IsMinorCiv = function()
                return data.minor == true
            end,
        }
    end
end

-- Helper to reset Players[i] driver after edit-time changes to otherPlayers,
-- since Players[i] closures captured a reference to the per-i `data` table at
-- setup() time. Tests that mutate otherPlayers post-setup should call this.
local function refreshPlayers()
    for i = 1, 7 do
        local data = otherPlayers[i] or {}
        Players[i] = {
            IsAlive = function()
                return data.alive ~= false
            end,
            IsMinorCiv = function()
                return data.minor == true
            end,
        }
    end
end

-- Turn line --------------------------------------------------------------

function M.test_turn_basic_ad()
    setup()
    T.eq(EmpireStatus._turnLine(), "Turn: 47, 1620 AD")
end

function M.test_turn_basic_bc()
    setup()
    Game.GetGameTurnYear = function()
        return -2400
    end
    T.eq(EmpireStatus._turnLine(), "Turn: 47, 2400 BC")
end

function M.test_turn_appends_supply_when_over_cap()
    setup()
    -- Non-zero maintenance mod is the same condition the panel uses to
    -- show its UnitSupplyString icon. When set, append the over-count.
    activePlayer.GetUnitProductionMaintenanceMod = function()
        return 5
    end
    activePlayer.GetNumUnitsOutOfSupply = function()
        return 3
    end
    T.eq(EmpireStatus._turnLine(), "Turn: 47, 1620 AD, 3 over unit cap")
end

function M.test_turn_appends_strategic_shortages()
    -- Shortages live on the bare T line so the player learns about supply
    -- problems with the same key that says how much time is left. Two
    -- strategic resources short, plus a non-strategic that should be
    -- ignored, plus a strategic in surplus that should also be ignored.
    setup()
    resources = {
        { ID = 1, Description = "iron", Available = -2 },
        { ID = 2, Description = "horses", Available = -1 },
        { ID = 3, Description = "wheat", Available = -5 },
        { ID = 4, Description = "coal", Available = 3 },
    }
    resourceUsage[1] = ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC
    resourceUsage[2] = ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC
    resourceUsage[3] = ResourceUsageTypes.RESOURCEUSAGE_BONUS
    resourceUsage[4] = ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC
    T.eq(EmpireStatus._turnLine(), "Turn: 47, 1620 AD, no iron, no horses")
end

-- Research line ----------------------------------------------------------

function M.test_research_active_speaks_turns_tech_and_rate()
    setup()
    researchTech = 5
    researchTurns = 5
    -- GameInfo.Technologies[id] in production reads .Description, then
    -- routes the value through Locale.ConvertTextKey. Pass-through Locale
    -- in setup means the description string lands verbatim in the line.
    techDescriptions[5] = { Description = "Mining" }
    T.eq(EmpireStatus._researchLine(), "5 turns to Mining, science +12")
end

function M.test_research_just_finished_speaks_recent_tech()
    setup()
    researchTech = -1
    lastTech = 5
    researchTurns = 0
    techDescriptions[5] = { Description = "Mining" }
    T.eq(EmpireStatus._researchLine(), "Mining done, science +0")
end

function M.test_research_none_chosen_speaks_no_research()
    setup()
    researchTech = -1
    lastTech = -1
    T.eq(EmpireStatus._researchLine(), "No research, science +0")
end

function M.test_research_off_when_option_set()
    setup()
    options[GameOptionTypes.GAMEOPTION_NO_SCIENCE] = true
    T.eq(EmpireStatus._researchLine(), "Science off")
end

-- Gold line --------------------------------------------------------------

function M.test_gold_positive_rate_speaks_gpt_first()
    setup()
    goldData = { gold = 250, rate = 12, used = 1, avail = 3 }
    T.eq(EmpireStatus._goldLine(), "+12 gold, 250 total, 1 of 3 trade routes")
end

function M.test_gold_negative_rate_speaks_minus_prefix()
    setup()
    goldData = { gold = 47, rate = -5, used = 1, avail = 3 }
    T.eq(EmpireStatus._goldLine(), "minus 5 gold, 47 total, 1 of 3 trade routes")
end

function M.test_gold_does_not_speak_strategic_shortages()
    -- Shortages used to ride on G; they now live on T. The G readout
    -- speaks only the gold/trade-routes headline regardless of supply.
    setup()
    goldData = { gold = 250, rate = 12, used = 1, avail = 3 }
    resources = {
        { ID = 1, Description = "iron", Available = -2 },
        { ID = 2, Description = "horses", Available = -1 },
    }
    resourceUsage[1] = ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC
    resourceUsage[2] = ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC
    T.eq(EmpireStatus._goldLine(), "+12 gold, 250 total, 1 of 3 trade routes")
end

-- Happiness line ---------------------------------------------------------

function M.test_happiness_happy_with_ga_progress()
    setup()
    happyData = { excess = 5, unhappy = false, veryUnhappy = false }
    goldenAgeData = { turns = 0, meter = 80, threshold = 200 }
    T.eq(EmpireStatus._happinessLine(), "+5 happiness, 80 of 200 to golden age")
end

function M.test_happiness_in_golden_age_still_leads_with_happiness()
    -- User-specified ordering: GA after happiness even when active, so the
    -- shape stays predictable across every press regardless of GA state.
    setup()
    happyData = { excess = 5, unhappy = false, veryUnhappy = false }
    goldenAgeData = { turns = 12, meter = 0, threshold = 200 }
    T.eq(EmpireStatus._happinessLine(), "+5 happiness, golden age for 12 turns")
end

function M.test_happiness_unhappy_speaks_negative_excess()
    -- IsEmpireUnhappy true / IsEmpireVeryUnhappy false. excess negative.
    setup()
    happyData = { excess = -3, unhappy = true, veryUnhappy = false }
    goldenAgeData = { turns = 0, meter = 80, threshold = 200 }
    T.eq(EmpireStatus._happinessLine(), "Unhappy minus 3, 80 of 200 to golden age")
end

function M.test_happiness_very_unhappy_uses_very_branch()
    setup()
    happyData = { excess = -12, unhappy = true, veryUnhappy = true }
    goldenAgeData = { turns = 0, meter = 0, threshold = 200 }
    T.eq(EmpireStatus._happinessLine(), "Very unhappy minus 12, 0 of 200 to golden age")
end

function M.test_happiness_off_when_option_set()
    setup()
    options[GameOptionTypes.GAMEOPTION_NO_HAPPINESS] = true
    T.eq(EmpireStatus._happinessLine(), "Happiness off")
end

function M.test_happiness_appends_per_luxury_inventory()
    -- Three luxuries set up: two providing happiness right now (gold,
    -- silk), one connected but no happiness this turn (ivory) -- the
    -- engine returns 0 for the third, so it doesn't count. The inventory
    -- list reports each contributing luxury with its copy count from
    -- GetNumResourceAvailable, and lands at the end of the line.
    setup()
    happyData = { excess = 5, unhappy = false, veryUnhappy = false }
    goldenAgeData = { turns = 0, meter = 0, threshold = 200 }
    resources = {
        { ID = 1, Description = "gold", HappinessFromLuxury = 4, Available = 2 },
        { ID = 2, Description = "silk", HappinessFromLuxury = 4, Available = 1 },
        { ID = 3, Description = "ivory", HappinessFromLuxury = 0, Available = 1 },
    }
    T.eq(EmpireStatus._happinessLine(), "+5 happiness, 0 of 200 to golden age, gold 2, silk 1")
end

function M.test_happiness_skips_inventory_when_no_luxuries()
    setup()
    happyData = { excess = 5, unhappy = false, veryUnhappy = false }
    goldenAgeData = { turns = 0, meter = 0, threshold = 200 }
    resources = {}
    T.eq(EmpireStatus._happinessLine(), "+5 happiness, 0 of 200 to golden age")
end

-- Faith line -------------------------------------------------------------

function M.test_faith_speaks_rate_and_total()
    setup()
    faithData = { faith = 23, rate = 4 }
    T.eq(EmpireStatus._faithLine(), "+4 faith, 23 total")
end

function M.test_faith_off_when_option_set()
    setup()
    options[GameOptionTypes.GAMEOPTION_NO_RELIGION] = true
    T.eq(EmpireStatus._faithLine(), "Religion off")
end

-- Policy line ------------------------------------------------------------

function M.test_policy_normal_computes_turns_to_next()
    -- needed = cost - stored = 85 - 60 = 25; rate = 8; ceil(25/8) = 4.
    setup()
    cultureData = { culture = 60, cost = 85, rate = 8 }
    T.eq(EmpireStatus._policyLine(), "+8 culture, 4 turns to policy")
end

function M.test_policy_rounds_up_fractional_turn()
    -- needed = 1, rate = 8; ceil(1/8) = 1, not 0.
    setup()
    cultureData = { culture = 84, cost = 85, rate = 8 }
    T.eq(EmpireStatus._policyLine(), "+8 culture, 1 turns to policy")
end

function M.test_policy_speaks_no_policies_left_when_cost_zero()
    -- All policies adopted: GetNextPolicyCost returns 0.
    setup()
    cultureData = { culture = 60, cost = 0, rate = 8 }
    T.eq(EmpireStatus._policyLine(), "+8 culture, no policies left")
end

function M.test_policy_speaks_stalled_when_zero_rate()
    -- Zero or negative culture per turn would compute to infinity turns;
    -- speak the raw progress instead so the rate=0 case is audible.
    setup()
    cultureData = { culture = 60, cost = 85, rate = 0 }
    T.eq(EmpireStatus._policyLine(), "no culture, 60 of 85 to next policy")
end

function M.test_policy_off_when_option_set()
    setup()
    options[GameOptionTypes.GAMEOPTION_NO_POLICIES] = true
    T.eq(EmpireStatus._policyLine(), "Policies off")
end

-- Tourism line -----------------------------------------------------------

function M.test_tourism_zero_influential_speaks_rate_only()
    setup()
    tourismRate = 5
    -- 7 other major civs, 0 at INFLUENTIAL.
    for i = 1, 7 do
        otherPlayers[i] = { alive = true, minor = false }
    end
    refreshPlayers()
    T.eq(EmpireStatus._tourismLine(), "+5 tourism")
end

function M.test_tourism_some_influential_speaks_count_only()
    -- 3 of 7 civs influential. Gap = 4, not within reach (>2), so just
    -- the count without denominator.
    setup()
    tourismRate = 5
    for i = 1, 7 do
        otherPlayers[i] = { alive = true, minor = false }
    end
    refreshPlayers()
    influenceLevels[1] = InfluenceLevelTypes.INFLUENCE_LEVEL_INFLUENTIAL
    influenceLevels[2] = InfluenceLevelTypes.INFLUENCE_LEVEL_DOMINANT
    influenceLevels[3] = InfluenceLevelTypes.INFLUENCE_LEVEL_INFLUENTIAL
    T.eq(EmpireStatus._tourismLine(), "+5 tourism, influential on 3 civs")
end

function M.test_tourism_within_reach_names_denominator()
    -- 5 of 7 civs influential. Gap = 2, within reach -- name the denominator.
    setup()
    tourismRate = 5
    for i = 1, 7 do
        otherPlayers[i] = { alive = true, minor = false }
    end
    refreshPlayers()
    for i = 1, 5 do
        influenceLevels[i] = InfluenceLevelTypes.INFLUENCE_LEVEL_INFLUENTIAL
    end
    T.eq(EmpireStatus._tourismLine(), "+5 tourism, influential on 5 of 7 civs")
end

function M.test_tourism_skips_dead_and_minor_civs()
    -- Mix alive / dead / minor across all 7 slots. Only alive non-minors
    -- count toward total. Slots 5-7 are explicitly dead so they don't
    -- inflate the denominator past the two alive non-minor civs (1 and 4).
    setup()
    tourismRate = 5
    otherPlayers[1] = { alive = true, minor = false }
    otherPlayers[2] = { alive = false, minor = false }
    otherPlayers[3] = { alive = true, minor = true }
    otherPlayers[4] = { alive = true, minor = false }
    otherPlayers[5] = { alive = false, minor = false }
    otherPlayers[6] = { alive = false, minor = false }
    otherPlayers[7] = { alive = false, minor = false }
    refreshPlayers()
    influenceLevels[1] = InfluenceLevelTypes.INFLUENCE_LEVEL_INFLUENTIAL
    influenceLevels[4] = InfluenceLevelTypes.INFLUENCE_LEVEL_INFLUENTIAL
    -- 2 alive non-minor civs, both influential. Gap=0, within reach.
    -- Denominator is the alive-non-minor count, not MAX_CIV_PLAYERS.
    T.eq(EmpireStatus._tourismLine(), "+5 tourism, influential on 2 of 2 civs")
end

return M
