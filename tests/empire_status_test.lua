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
    -- "You" label injected into the still-playing list for the local
    -- player. The base engine string is just "You"; we go through Text.key
    -- in production so the test needs the engine string registered.
    ["TXT_KEY_YOU"] = "You",
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
local currentEra
local eras
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
    T.installLocaleStrings(GAME_TEXT)

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
    -- Default to Classical so the era clause is non-empty in the common
    -- case; tests that depend on a specific era override after setup().
    currentEra = 1
    eras = {
        [0] = { Description = "Ancient Era" },
        [1] = { Description = "Classical Era" },
    }

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
    -- Single-player by default. MP turn-line tests override this and supply
    -- the per-player IsHuman / IsTurnActive / HasReceivedNetTurnComplete /
    -- GetNickName / IsObserver stubs plus Network.IsPlayerConnected.
    Game.IsNetworkMultiPlayer = function()
        return false
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
    GameDefines.MAX_MAJOR_CIVS = 8

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
    GameInfo.Eras = setmetatable({}, {
        __index = function(_, k)
            return eras[k]
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
        GetCurrentEra = function()
            return currentEra
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
        -- MP "still playing" scan reaches slot 0 too so the local player
        -- can be surfaced as "you". Defaults make self qualify only if
        -- IsNetworkMultiPlayer is also true (which the SP default rules
        -- out); MP tests override turnActive / ended via installMPSlots.
        IsHuman = function()
            return true
        end,
        IsAlive = function()
            return true
        end,
        IsObserver = function()
            return false
        end,
        IsTurnActive = function()
            return false
        end,
        HasReceivedNetTurnComplete = function()
            return false
        end,
        GetNickName = function()
            return ""
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

-- Multiplayer "still playing" clause -------------------------------------
--
-- Each scenario installs MP player slot stubs with shape:
--   { human, alive, observer, connected, turnActive, ended, nick }
-- The default for an unlisted slot is "empty observer" (not human, not
-- alive) so any slot not explicitly populated is filtered out. Slot 0
-- (local player) is populated too: the scan reaches it so the user can
-- be named as "you" when they themselves are still on the hook.

local function installMPSlots(slots)
    Game.IsNetworkMultiPlayer = function()
        return true
    end
    Network = Network or {}
    Network.IsPlayerConnected = function(id)
        if id == 0 then
            local s = slots[0]
            return s == nil or s.connected ~= false
        end
        local s = slots[id]
        return s ~= nil and s.connected ~= false
    end
    -- Layer the slot 0 overrides on top of activePlayer so the readout
    -- methods (GetGold etc.) the other lines need stay intact; only the
    -- MP-side IsTurnActive / HasReceivedNetTurnComplete change per test.
    local self0 = slots[0] or { turnActive = true, ended = false }
    activePlayer.IsTurnActive = function()
        return self0.turnActive == true
    end
    activePlayer.HasReceivedNetTurnComplete = function()
        return self0.ended == true
    end
    Players[0] = activePlayer
    for i = 1, GameDefines.MAX_MAJOR_CIVS - 1 do
        local s = slots[i] or {}
        Players[i] = {
            IsHuman = function()
                return s.human == true
            end,
            IsAlive = function()
                return s.alive == true
            end,
            IsObserver = function()
                return s.observer == true
            end,
            IsTurnActive = function()
                return s.turnActive == true
            end,
            HasReceivedNetTurnComplete = function()
                return s.ended == true
            end,
            GetNickName = function()
                return s.nick or ""
            end,
        }
    end
end

function M.test_turn_no_still_playing_clause_in_single_player()
    -- Default setup is SP (IsNetworkMultiPlayer false). Even if remote
    -- slots existed they'd be ignored - the gate fires first.
    setup()
    T.eq(EmpireStatus._turnLine(), "Turn: 47, 1620 AD")
end

function M.test_turn_still_playing_names_self_as_you()
    -- Local player is active and hasn't ended: "you" leads the list so
    -- the user notices they forgot to end their own turn.
    setup()
    installMPSlots({
        [0] = { turnActive = true, ended = false },
        [1] = { human = true, alive = true, connected = true, turnActive = true, ended = false, nick = "Alice" },
        [2] = { human = true, alive = true, connected = true, turnActive = true, ended = false, nick = "Bob" },
    })
    T.eq(EmpireStatus._turnLine(), "Turn: 47, 1620 AD, still playing: You, Alice, Bob")
end

function M.test_turn_still_playing_drops_self_once_local_has_ended()
    -- Self has clicked end turn; remote humans haven't. Self drops out
    -- and the clause names just the remotes still going.
    setup()
    installMPSlots({
        [0] = { turnActive = true, ended = true },
        [1] = { human = true, alive = true, connected = true, turnActive = true, ended = false, nick = "Alice" },
        [2] = { human = true, alive = true, connected = true, turnActive = true, ended = false, nick = "Bob" },
    })
    T.eq(EmpireStatus._turnLine(), "Turn: 47, 1620 AD, still playing: Alice, Bob")
end

function M.test_turn_still_playing_omits_humans_who_have_ended()
    setup()
    installMPSlots({
        [0] = { turnActive = true, ended = true },
        [1] = { human = true, alive = true, connected = true, turnActive = true, ended = true, nick = "Alice" },
        [2] = { human = true, alive = true, connected = true, turnActive = true, ended = false, nick = "Bob" },
    })
    T.eq(EmpireStatus._turnLine(), "Turn: 47, 1620 AD, still playing: Bob")
end

function M.test_turn_still_playing_omits_inactive_turn()
    -- Sequential MP shape: only the player whose turn is current has
    -- IsTurnActive true. Others in the queue are alive and unended but
    -- not yet active, so they shouldn't be named. Here Alice is current,
    -- self and Bob are queued (turnActive false) so neither appears.
    setup()
    installMPSlots({
        [0] = { turnActive = false, ended = false },
        [1] = { human = true, alive = true, connected = true, turnActive = true, ended = false, nick = "Alice" },
        [2] = { human = true, alive = true, connected = true, turnActive = false, ended = false, nick = "Bob" },
    })
    T.eq(EmpireStatus._turnLine(), "Turn: 47, 1620 AD, still playing: Alice")
end

function M.test_turn_still_playing_skips_ai_dead_observer_disconnected()
    setup()
    installMPSlots({
        [0] = { turnActive = true, ended = true },
        [1] = { human = false, alive = true, connected = false, turnActive = true, ended = false, nick = "AI Civ" },
        [2] = { human = true, alive = false, connected = true, turnActive = true, ended = false, nick = "DeadHuman" },
        [3] = {
            human = true,
            alive = true,
            observer = true,
            connected = true,
            turnActive = true,
            ended = false,
            nick = "Watcher",
        },
        [4] = { human = true, alive = true, connected = false, turnActive = true, ended = false, nick = "Dropped" },
        [5] = { human = true, alive = true, connected = true, turnActive = true, ended = false, nick = "Carol" },
    })
    T.eq(EmpireStatus._turnLine(), "Turn: 47, 1620 AD, still playing: Carol")
end

function M.test_turn_still_playing_omitted_when_no_one_left()
    -- All humans, self included, have ended their turn: clause drops
    -- entirely rather than becoming an empty "still playing: " label.
    setup()
    installMPSlots({
        [0] = { turnActive = true, ended = true },
        [1] = { human = true, alive = true, connected = true, turnActive = true, ended = true, nick = "Alice" },
        [2] = { human = true, alive = true, connected = true, turnActive = true, ended = true, nick = "Bob" },
    })
    T.eq(EmpireStatus._turnLine(), "Turn: 47, 1620 AD")
end

function M.test_turn_still_playing_only_self()
    -- Solo remaining: just the local player hasn't ended yet.
    setup()
    installMPSlots({
        [0] = { turnActive = true, ended = false },
        [1] = { human = true, alive = true, connected = true, turnActive = true, ended = true, nick = "Alice" },
    })
    T.eq(EmpireStatus._turnLine(), "Turn: 47, 1620 AD, still playing: You")
end

function M.test_turn_still_playing_includes_self_even_when_network_says_disconnected()
    -- Defensive: the self slot bypasses Network.IsPlayerConnected so a
    -- spurious false there can't drop the user from the list. The "did
    -- I forget to end" use case is the whole point of the clause and
    -- must not be silently silenced by a network-state edge case.
    setup()
    installMPSlots({
        [0] = { turnActive = true, ended = false, connected = false },
        [1] = { human = true, alive = true, connected = true, turnActive = true, ended = false, nick = "Alice" },
    })
    T.eq(EmpireStatus._turnLine(), "Turn: 47, 1620 AD, still playing: You, Alice")
end

function M.test_turn_still_playing_drops_remote_when_network_says_disconnected()
    -- Inverse of the above: for remote slots the network check is
    -- load-bearing (it rules out human slots whose original player
    -- dropped and are now AI-driven). A disconnected remote must not
    -- appear in the list even when their human flag is still set.
    setup()
    installMPSlots({
        [0] = { turnActive = true, ended = true },
        [1] = { human = true, alive = true, connected = false, turnActive = true, ended = false, nick = "Dropped" },
        [2] = { human = true, alive = true, connected = true, turnActive = true, ended = false, nick = "Alice" },
    })
    T.eq(EmpireStatus._turnLine(), "Turn: 47, 1620 AD, still playing: Alice")
end

-- Research line ----------------------------------------------------------

function M.test_research_active_speaks_turns_tech_rate_then_era()
    setup()
    researchTech = 5
    researchTurns = 5
    -- GameInfo.Technologies[id] in production reads .Description, then
    -- routes the value through Locale.ConvertTextKey. Pass-through Locale
    -- in setup means the description string lands verbatim in the line.
    techDescriptions[5] = { Description = "Mining" }
    T.eq(EmpireStatus._researchLine(), "5 turns to Mining, science +12, Classical Era")
end

function M.test_research_just_finished_speaks_recent_tech_then_era()
    setup()
    researchTech = -1
    lastTech = 5
    researchTurns = 0
    techDescriptions[5] = { Description = "Mining" }
    T.eq(EmpireStatus._researchLine(), "Mining done, science +0, Classical Era")
end

function M.test_research_none_chosen_speaks_no_research_then_era()
    setup()
    researchTech = -1
    lastTech = -1
    T.eq(EmpireStatus._researchLine(), "No research, science +0, Classical Era")
end

function M.test_research_off_omits_era_clause()
    setup()
    options[GameOptionTypes.GAMEOPTION_NO_SCIENCE] = true
    T.eq(EmpireStatus._researchLine(), "Science off")
end

function M.test_research_era_tracks_current_era()
    -- Sanity check the era trailer isn't pinned to Classical; switching the
    -- mocked era flips the trailing word so the engine's era-advance event
    -- actually surfaces to the bare R readout.
    setup()
    currentEra = 0
    researchTech = -1
    lastTech = -1
    T.eq(EmpireStatus._researchLine(), "No research, science +0, Ancient Era")
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
    T.eq(EmpireStatus._policyLine(), "+8 culture, 1 turn to policy")
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
