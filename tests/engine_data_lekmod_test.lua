-- LekMod EngineData port tests. Two jobs:
--   * Parity: the vanilla and LekMod CivVAccess_EngineData.lua must define the
--     identical function set, so a seam added to one and forgotten in the
--     other fails here instead of failing at speech time on the other engine
--     (the same guard engine_data_vp_test enforces for VP).
--   * LekMod bodies match vanilla on the high-divergence reads. LekMod does
--     not diverge from vanilla on any drift read (verified: vanilla signed-
--     surplus happiness, display-scale getters, a purely additive binding
--     surface), so its bodies ARE the vanilla calls. These tests pin exactly
--     the points where VP diverges hardest -- the happiness model, tourism
--     scale, the bestDefender signature -- so a future edit that accidentally
--     gives the LekMod seam VP semantics (a silent-value failure, nothing
--     crashes) is caught here.
--
-- Each test loads the file under test into a fresh environment (setfenv)
-- whose reads fall through to _G, matching engine_data_vp_test.

local T = require("support")
local M = {}

local VANILLA_PATH = "src/dlc/UI/InGame/CivVAccess_EngineData.lua"
local LEKMOD_PATH = "src/lekmod/CivVAccess_EngineData.lua"

local function loadSeam(path)
    local env = setmetatable({}, { __index = _G })
    local chunk = assert(loadfile(path))
    setfenv(chunk, env)
    chunk()
    return env.EngineData, env
end

function M.test_lekmod_and_vanilla_define_identical_function_sets()
    local vanilla = loadSeam(VANILLA_PATH)
    local lekmod = loadSeam(LEKMOD_PATH)
    local missing, extra = {}, {}
    for name, value in pairs(vanilla) do
        if type(value) == "function" and type(lekmod[name]) ~= "function" then
            missing[#missing + 1] = name
        end
    end
    for name, value in pairs(lekmod) do
        if type(value) == "function" and type(vanilla[name]) ~= "function" then
            extra[#extra + 1] = name
        end
    end
    table.sort(missing)
    table.sort(extra)
    T.eq(table.concat(missing, ","), "", "seam functions missing from the LekMod implementation")
    T.eq(table.concat(extra, ","), "", "seam functions only in the LekMod implementation")
end

-- LekMod's fork canaries are the same Game bindings as vanilla (we ported the
-- same additions under their vanilla names), so forkPresent must key off them.
function M.test_lekmod_fork_present_checks_the_same_game_canaries()
    local lekmod, env = loadSeam(LEKMOD_PATH)
    env.Game = {
        GetBuildRoutePath = function() end,
        GetCycleUnits = function() end,
        GetClosestSearchedPlot = function() end,
    }
    T.truthy(lekmod.forkPresent(), "all three fork Game bindings present -> fork present")
    env.Game.GetClosestSearchedPlot = nil
    T.falsy(lekmod.forkPresent(), "a missing fork binding -> fork absent (degrade, do not throw)")
end

-- Happiness on LekMod is the vanilla signed surplus, NOT VP's 0-100 approval
-- percent. A consumer formatting an approval percent as a surplus (or vice
-- versa) is the canonical silent-value failure the happinessSummary model
-- exists to prevent.
function M.test_lekmod_happiness_summary_is_surplus_model()
    local lekmod = loadSeam(LEKMOD_PATH)
    local player = {
        GetExcessHappiness = function()
            return -7
        end,
        IsEmpireUnhappy = function()
            return true
        end,
        IsEmpireVeryUnhappy = function()
            return false
        end,
    }
    local s = lekmod.happinessSummary(player)
    T.eq(s.mode, "surplus", "LekMod happiness must report the signed-surplus model")
    T.eq(s.value, -7, "value is the raw signed surplus")
    T.eq(s.state, "unhappy")
    T.eq(s.happyCitizens, nil, "citizen counts are a VP approval-model field, absent on LekMod")
end

-- Vanilla-model happiness breakdown getters pass straight through on LekMod
-- (VP hardcodes these to 0 / errors under its citizen-needs model).
function M.test_lekmod_happiness_breakdown_passes_through()
    local lekmod = loadSeam(LEKMOD_PATH)
    T.eq(
        lekmod.unhappinessFromCityCount({
            GetUnhappinessFromCityCount = function()
                return 350
            end,
        }),
        350
    )
end

-- LekMod's bare getters return display scale, so tourism passes through
-- unscaled. VP divides a times-100 getter by 100; that body here would read
-- 100x low.
function M.test_lekmod_tourism_passes_through_unscaled()
    local lekmod = loadSeam(LEKMOD_PATH)
    T.eq(
        lekmod.tourism({
            GetTourism = function()
                return 1234
            end,
        }),
        1234,
        "LekMod tourism is already a plain rate, no times-100 division"
    )
    T.eq(
        lekmod.baseTourism({
            GetBaseTourism = function()
                return 12
            end,
        }),
        12,
        "base tourism is already a plain rate too"
    )
end

-- bestDefender keeps the vanilla positional signature on LekMod (purely
-- additive binding surface). VP inserts a pIgnoreUnit arg and repurposes the
-- potential-enemy slot as bIgnoreVisibility; that arg order here would pick
-- the wrong defender.
function M.test_lekmod_best_defender_uses_vanilla_positional_signature()
    local lekmod = loadSeam(LEKMOD_PATH)
    local seen
    local plot = {
        GetBestDefender = function(_, owner, attackingPlayer, attacker, atWar, potentialEnemy, canMove, noncombat)
            seen = {
                owner = owner,
                attackingPlayer = attackingPlayer,
                attacker = attacker,
                atWar = atWar,
                potentialEnemy = potentialEnemy,
                canMove = canMove,
                noncombat = noncombat,
            }
            return "defender"
        end,
    }
    local got = lekmod.bestDefender(plot, 3, "actor", { testAtWar = true, noncombatAllowed = true })
    T.eq(got, "defender")
    T.eq(seen.owner, -1, "owner filter off")
    T.eq(seen.attackingPlayer, 3)
    T.eq(seen.attacker, "actor")
    T.eq(seen.atWar, 1)
    T.eq(seen.potentialEnemy, 0, "vanilla potential-enemy slot at arg 5, off")
    T.eq(seen.canMove, 0, "bTestCanMove off at arg 6")
    T.eq(seen.noncombat, 1, "fork noncombat extension at arg 7")
end

-- LekMod's extra combat-preview modifiers compute on LekMod and are inert
-- (0) on vanilla, so the combat-preview enumerator skips them off-engine. A
-- raw call to any of these on vanilla would throw (the bindings are unbound),
-- which is exactly why they route through the seam.
function M.test_lekmod_combat_modifiers_compute_vanilla_inert()
    local lekmod = loadSeam(LEKMOD_PATH)
    local vanilla = loadSeam(VANILLA_PATH)

    -- Build two units whose owners sit in different ideologies so the
    -- ideology gate opens. _G.Players is read inside the seam body.
    local prevPlayers = _G.Players
    _G.Players = {
        [0] = {
            GetLateGamePolicyTree = function()
                return 1
            end,
        },
        [1] = {
            GetLateGamePolicyTree = function()
                return 2
            end,
        },
    }
    local me = {
        GetOwner = function()
            return 0
        end,
        GetCombatBonusVsDifferentIdeologyModifier = function()
            return 25
        end,
        GetTourismInfluenceCombatModifier = function()
            return 10
        end,
        RangedDefenseModifier = function()
            return 33
        end,
    }
    local them = {
        GetOwner = function()
            return 1
        end,
    }

    T.eq(lekmod.ideologyCombatModifier(me, them), 25, "ideology bonus shows when ideologies differ")
    T.eq(lekmod.tourismInfluenceCombatModifier(me, them), 10, "tourism-influence modifier passes through")
    T.eq(lekmod.rangedDefenseModifier(me), 33, "ranged-defense modifier passes through")

    -- Same ideology -> gate closes, no bonus.
    _G.Players[1].GetLateGamePolicyTree = function()
        return 1
    end
    T.eq(lekmod.ideologyCombatModifier(me, them), 0, "ideology bonus suppressed when ideologies match")

    -- Vanilla bodies are inert regardless of arguments.
    T.eq(vanilla.ideologyCombatModifier(me, them), 0, "vanilla has no ideology combat modifier")
    T.eq(vanilla.tourismInfluenceCombatModifier(me, them), 0, "vanilla has no tourism-influence modifier")
    T.eq(vanilla.rangedDefenseModifier(me), 0, "vanilla has no ranged-defense modifier")

    _G.Players = prevPlayers
end

-- Golden-age points per turn: LekMod surfaces a rate (its
-- GetTotalGoldenAgePointsInEmpire feeds the GA meter each turn, and can be
-- negative); vanilla surfaces no rate, so the headline drops the clause.
function M.test_lekmod_golden_age_per_turn()
    local lekmod = loadSeam(LEKMOD_PATH)
    local vanilla = loadSeam(VANILLA_PATH)
    T.eq(
        lekmod.goldenAgePerTurn({
            GetTotalGoldenAgePointsInEmpire = function()
                return 14
            end,
        }),
        14,
        "LekMod GAP per turn is the empire-total getter"
    )
    T.eq(
        lekmod.goldenAgePerTurn({
            GetTotalGoldenAgePointsInEmpire = function()
                return -3
            end,
        }),
        -3,
        "LekMod GAP per turn can be negative"
    )
    T.eq(lekmod.goldenAgePerTurn({}), nil, "no binding (stock engine) -> nil, the rate clause drops")
    T.eq(vanilla.goldenAgePerTurn({}), nil, "vanilla surfaces no GAP rate")

    -- City-level GAP: a real city yield on LekMod (probed via YieldTypes),
    -- nil on vanilla where the yield type does not exist.
    local prevYields = _G.YieldTypes
    _G.YieldTypes = { YIELD_GOLDEN_AGE_POINTS = 99 }
    local city = {
        GetYieldRate = function(_, y)
            return y == 99 and 7 or 0
        end,
    }
    T.eq(lekmod.cityGoldenAgePerTurn(city), 7, "LekMod city GAP reads the golden-age yield rate")
    _G.YieldTypes = {}
    T.eq(lekmod.cityGoldenAgePerTurn(city), nil, "no golden-age yield type -> nil")
    T.eq(vanilla.cityGoldenAgePerTurn(city), nil, "vanilla has no city GAP yield")
    _G.YieldTypes = prevYields
end

-- LekMod MP soft-prompt reads: pendingVoteProposalId scans recent proposals
-- for one the active player can still vote on; pendingDealSender returns the
-- first incoming-deal sender. Both -1 on vanilla (no MP voting system).
function M.test_lekmod_soft_prompt_reads()
    local lekmod = loadSeam(LEKMOD_PATH)
    local vanilla = loadSeam(VANILLA_PATH)

    local prevGame, prevDefines = _G.Game, _G.GameDefines
    _G.GameDefines = { MAX_MAJOR_CIVS = 22 }
    -- Proposal 7 is open, the active player is eligible and has not voted.
    _G.Game = {
        GetActivePlayer = function()
            return 0
        end,
        GetLastProposalID = function()
            return 7
        end,
        GetProposalStatus = function(id)
            return id == 7 and 0 or 1
        end,
        GetProposalVoterEligibility = function(id, _p)
            return id == 7
        end,
        GetProposalVoterHasVoted = function(_id, _p)
            return false
        end,
        GetPendingIncomingDealSenders = function(_me, _bool)
            return { 3, 5 }
        end,
    }
    T.eq(lekmod.pendingVoteProposalId(), 7, "finds the open, unvoted, eligible proposal")
    T.eq(lekmod.pendingDealSender(), 3, "first incoming-deal sender")

    -- Already voted -> nothing pending.
    _G.Game.GetProposalVoterHasVoted = function()
        return true
    end
    T.eq(lekmod.pendingVoteProposalId(), -1, "voted proposals are not pending")

    _G.Game.GetPendingIncomingDealSenders = function()
        return {}
    end
    T.eq(lekmod.pendingDealSender(), -1, "no senders -> -1")

    T.eq(vanilla.pendingVoteProposalId(), -1, "vanilla has no MP voting system")
    T.eq(vanilla.pendingDealSender(), -1, "vanilla has no incoming-deal soft prompt")

    _G.Game, _G.GameDefines = prevGame, prevDefines
end

-- Tech-steal cost: LekMod charges science to steal a tech; vanilla steals
-- outright (nil, so the steal-cost line drops).
function M.test_lekmod_tech_steal_cost()
    local lekmod = loadSeam(LEKMOD_PATH)
    local vanilla = loadSeam(VANILLA_PATH)
    local player = {
        ScienceToStealAmount = function(_, target, tech)
            return target * 100 + tech
        end,
    }
    T.eq(lekmod.techStealCost(player, 2, 5), 205, "LekMod returns the science steal cost")
    T.eq(lekmod.techStealCost({}, 2, 5), nil, "no binding -> nil")
    T.eq(vanilla.techStealCost(player, 2, 5), nil, "vanilla steals outright, no cost")
end

-- Resource-trade blocked reason: LekMod returns a one-line reason for an
-- owned-but-untradeable resource (luxury the partner owns / embargo /
-- unresearched strategic); vanilla returns nil so the row stays dropped.
function M.test_lekmod_resource_trade_blocked_reason()
    local lekmod = loadSeam(LEKMOD_PATH)
    local vanilla = loadSeam(VANILLA_PATH)
    local prevGameInfo = _G.GameInfo
    _G.GameInfo = { Technologies = { [4] = { Description = "TXT_KEY_TECH_X" } } }

    -- The seam returns the reason's text key (plus an optional format arg); the
    -- caller resolves it through Text, so raw text never crosses the seam.

    -- Luxury the partner already owns.
    local deal = {
        IsLuxuryTradeTargetAlreadyHasResource = function()
            return true
        end,
    }
    T.eq(
        lekmod.resourceTradeBlockedReason(deal, 0, 1, { ResourceUsage = 2, ID = 9 }),
        "TXT_KEY_DIPLO_ITEM_PLAYER_ALREADY_OWNS_ONE_LINE",
        "luxury partner already owns"
    )
    -- Luxury under embargo (binding says not-already-owned).
    deal.IsLuxuryTradeTargetAlreadyHasResource = function()
        return false
    end
    T.eq(
        lekmod.resourceTradeBlockedReason(deal, 0, 1, { ResourceUsage = 2, ID = 9 }),
        "TXT_KEY_DIPLO_ITEM_EMBARGOED_ONE_LINE",
        "luxury embargoed"
    )
    -- Strategic neither side has researched: key plus the reveal tech's
    -- Description as the format arg.
    local stratKey, stratArg = lekmod.resourceTradeBlockedReason(deal, 0, 1, { ResourceUsage = 1, TechReveal = 4 })
    T.eq(stratKey, "TXT_KEY_DIPLO_ITEM_BOTH_HAVE_NOT_REASEARCHED_ONE_LINE", "strategic not researched reason key")
    T.eq(stratArg, "TXT_KEY_TECH_X", "strategic reason names the reveal tech")
    T.eq(
        vanilla.resourceTradeBlockedReason(deal, 0, 1, { ResourceUsage = 2, ID = 9 }),
        nil,
        "vanilla drops untradeable"
    )

    _G.GameInfo = prevGameInfo
end

-- VP-only features stay inert on LekMod, exactly as on vanilla: vassalage,
-- war score, embassies, historic events, building investments have no LekMod
-- equivalent, so their bodies must return the no-support answer.
function M.test_lekmod_vp_only_features_are_inert()
    local lekmod = loadSeam(LEKMOD_PATH)
    T.eq(lekmod.warScore({}, 3), nil, "no war-score concept")
    T.eq(lekmod.embassyOwner({}), nil, "no embassies")
    T.eq(lekmod.supportsHistoricEvents(), false)
    T.eq(lekmod.buildingInvestmentsEnabled(), false)
    local v = lekmod.vassalInfo({})
    T.falsy(v.isVassal, "no vassalage system")
    T.eq(#v.vassals, 0)
end

-- Unit supply limit: vanilla (and VP) enforce it, so the Military Overview
-- speaks its use/cap preamble; LekMod removes the limit in data
-- (ProductionFreeUnits=99999 on every handicap), so its body reports the limit
-- absent and the preamble drops rather than speaking a ~100000 cap.
function M.test_lekmod_supply_limit_absent()
    local lekmod = loadSeam(LEKMOD_PATH)
    local vanilla = loadSeam(VANILLA_PATH)
    T.eq(lekmod.supplyLimited(), false, "LekMod removes the unit supply limit")
    T.eq(vanilla.supplyLimited(), true, "vanilla enforces the unit supply limit")
end

-- ===== v35 combat predictor ==========================================
--
-- LekMod v35 moved prediction onto CvGame, resignatured the strength
-- getters around the whole matchup, and deleted GetMaxRangedCombatStrength.
-- The failure these pin is silent and severe: the old argument order feeds
-- a plot where the engine reads a unit, and the Lua instance layer does no
-- type check, so the engine reinterpret-casts whatever it is handed.

local function mkPrediction(attackerCurrent, attackerFinal, defenderCurrent, defenderFinal)
    return {
        Attacker = { CurrentDamage = attackerCurrent, FinalDamage = attackerFinal },
        Defender = { CurrentDamage = defenderCurrent, FinalDamage = defenderFinal },
    }
end

function M.test_lekmod_melee_damage_carries_pre_resolved_damage_into_the_predictor()
    local lekmod, env = loadSeam(LEKMOD_PATH)
    local seen
    env.Game = {
        GetCombatDamage = function(atk, atkCity, def, defCity, interceptor, plot, ranged, bombing, sweep, aX, dX)
            seen = {
                attacker = atk,
                attackerCity = atkCity,
                defender = def,
                defenderCity = defCity,
                interceptor = interceptor,
                plot = plot,
                ranged = ranged,
                bombing = bombing,
                sweep = sweep,
                attackerExtra = aX,
                defenderExtra = dX,
            }
            return mkPrediction(10, 34, 20, 51)
        end,
    }
    local toDefender, toAttacker = lekmod.meleeDamage("atk", "def", 500, 400, 9, 6, "plot")
    T.eq(toDefender, 31, "damage dealt is the final-minus-current delta, melee only")
    T.eq(toAttacker, 33, "24 from the melee plus the 9 fire support already taken")
    T.eq(seen.attacker, "atk")
    T.eq(seen.defender, "def", "the defender rides the defender-unit slot")
    T.eq(seen.attackerCity, nil)
    T.eq(seen.defenderCity, nil)
    T.eq(seen.plot, "plot", "the predictor takes the matchup, so the plot must cross")
    T.eq(seen.ranged, false)
    T.eq(seen.attackerExtra, 9, "fire support wounds the attacker before it swings")
    T.eq(seen.defenderExtra, 6, "the volley wounds the defender before it counterattacks")
end

-- The city rides the defender-CITY slot. In the unit slot the predictor
-- would scale the city's counterattack by the attacking unit's wounds --
-- the "cities do not do less damage when wounded" rule that v35's rewrite
-- dropped from the old per-unit call.
function M.test_lekmod_city_melee_damage_uses_the_defender_city_slot()
    local lekmod, env = loadSeam(LEKMOD_PATH)
    local seen
    env.Game = {
        GetCombatDamage = function(atk, atkCity, def, defCity, _interceptor, plot, _r, _b, _s, aX, dX)
            seen = {
                attacker = atk,
                attackerCity = atkCity,
                defender = def,
                defenderCity = defCity,
                plot = plot,
                attackerExtra = aX,
                defenderExtra = dX,
            }
            return mkPrediction(0, 12, 30, 70)
        end,
    }
    local toCity, toAttacker = lekmod.cityMeleeDamage("atk", "city", 700, 600, 5, "plot")
    T.eq(toCity, 40)
    T.eq(toAttacker, 17, "12 from the city plus the 5 fire support already taken")
    T.eq(seen.defenderCity, "city")
    T.eq(seen.defender, nil, "a city in the unit slot would weaken with the attacker's wounds")
    T.eq(seen.attackerCity, nil)
    T.eq(seen.defenderExtra, 0, "a city takes no pre-melee volley")
end

function M.test_lekmod_max_attack_strength_matches_the_v35_argument_order()
    local lekmod = loadSeam(LEKMOD_PATH)
    local seen
    local attacker = {
        GetMaxAttackStrength = function(_, toPlot, def, defCity, interceptor, ranged, bombing, sweep, fromPlot)
            seen = {
                toPlot = toPlot,
                defender = def,
                defenderCity = defCity,
                interceptor = interceptor,
                ranged = ranged,
                bombing = bombing,
                sweep = sweep,
                fromPlot = fromPlot,
            }
            return 815
        end,
        GetMaxRangedCombatStrength = function()
            error("GetMaxRangedCombatStrength is not registered on v35")
        end,
    }
    T.eq(lekmod.maxAttackStrength(attacker, "from", "to", "def", nil, false), 815)
    T.eq(seen.toPlot, "to", "the target plot leads on v35, where vanilla leads with the from-plot")
    T.eq(seen.defender, "def")
    T.eq(seen.fromPlot, "from", "the from-plot moved to the tail")
    T.eq(seen.ranged, false)

    lekmod.maxAttackStrength(attacker, nil, "to", nil, "city", true)
    T.eq(seen.defenderCity, "city")
    T.eq(seen.ranged, true, "the ranged answer is the same call with the flag set")
end

-- v35's GetMaxDefenseStrength reads the matchup and already picks the
-- embarked / ranged / melee number, so the vanilla resolution chain must
-- not run here -- its two getters are stubbed to fail if it does.
function M.test_lekmod_ranged_defense_strength_is_one_matchup_call()
    local lekmod = loadSeam(LEKMOD_PATH)
    local seen
    local defender = {
        GetMaxDefenseStrength = function(_, toPlot, atk, atkCity, interceptor, ranged, bombing, sweep)
            seen = {
                toPlot = toPlot,
                attacker = atk,
                attackerCity = atkCity,
                interceptor = interceptor,
                ranged = ranged,
                bombing = bombing,
                sweep = sweep,
            }
            return 640
        end,
        IsEmbarked = function()
            error("the v35 defense call resolves embarkation itself")
        end,
        GetMaxRangedCombatStrength = function()
            error("GetMaxRangedCombatStrength is not registered on v35")
        end,
    }
    T.eq(lekmod.rangedDefenseStrength(defender, "atk", "to"), 640)
    T.eq(seen.toPlot, "to")
    T.eq(seen.attacker, "atk")
    T.eq(seen.attackerCity, nil, "the attacker-city slot opens up between the attacker and the flags")
    T.eq(seen.ranged, true)
    T.eq(seen.bombing, false)
end

-- ===== Shallows =======================================================

function M.test_lekmod_plot_allows_walk_water_probes_the_binding()
    local lekmod = loadSeam(LEKMOD_PATH)
    local bridged = {
        IsAllowsWalkWater = function()
            return true
        end,
    }
    T.truthy(lekmod.plotAllowsWalkWater(bridged), "a walk-water improvement makes the water crossable")
    T.falsy(lekmod.plotAllowsWalkWater({}), "a stock DLL lacks the binding; degrade, do not throw")
end

-- A pontoon bridge carries a route without the plot holding one, which is
-- what the tile read has to name; pillaging it takes the route away while
-- the improvement itself still reads the same.
function M.test_lekmod_plot_route_type_reads_an_improvement_that_acts_as_a_route()
    local lekmod, env = loadSeam(LEKMOD_PATH)
    env.GameInfoTypes = { ROUTE_ROAD = 0, ROUTE_RAILROAD = 1 }
    env.GameInfo = {
        Improvements = {
            [7] = { ActsAsRoute = true, ActsAsRouteTech = "TECH_ENGINEERING", ActsAsRailroadTech = "TECH_RAILROAD" },
            [8] = { ActsAsRoute = false },
        },
        Technologies = {
            TECH_ENGINEERING = { ID = 40 },
            TECH_RAILROAD = { ID = 60 },
        },
    }
    local known = {}
    env.Teams = {
        [1] = {
            GetTeamTechs = function()
                return {
                    HasTech = function(_, id)
                        return known[id] == true
                    end,
                }
            end,
        },
    }
    local function mkPlot(opts)
        return {
            GetRevealedRouteType = function()
                return opts.route or -1
            end,
            GetRevealedImprovementType = function()
                return opts.improvement or -1
            end,
            IsVisible = function()
                return opts.visible ~= false
            end,
            IsImprovementPillaged = function()
                return opts.pillaged or false
            end,
        }
    end

    T.eq(lekmod.plotRouteType(mkPlot({ improvement = 7 }), 1, false), -1, "no tech yet, so the bridge carries nothing")
    known[40] = true
    T.eq(lekmod.plotRouteType(mkPlot({ improvement = 7 }), 1, false), 0, "the route tech makes it a road")
    known[60] = true
    T.eq(lekmod.plotRouteType(mkPlot({ improvement = 7 }), 1, false), 1, "the railroad tech upgrades it")
    T.eq(
        lekmod.plotRouteType(mkPlot({ improvement = 7, pillaged = true }), 1, false),
        -1,
        "a pillaged bridge carries no route"
    )
    T.eq(lekmod.plotRouteType(mkPlot({ improvement = 8 }), 1, false), -1, "an ordinary improvement is not a route")
    T.eq(lekmod.plotRouteType(mkPlot({ route = 3, improvement = 7 }), 1, false), 3, "a real route on the plot wins")
end

-- ===== City-state personalities =======================================

-- LekMod keeps the four-value C++ enum for save compatibility and moves the
-- real ten-personality set into a data table, so GetPersonality returns a row
-- index. Comparing it against the enum constants -- what every other engine
-- needs -- drops the six added past them.
function M.test_lekmod_minor_personality_comes_from_the_data_table()
    local lekmod, env = loadSeam(LEKMOD_PATH)
    env.GameInfo = {
        Minor_Civ_Personalities = {
            [0] = { Description = "TXT_KEY_CITY_STATE_PERSONALITY_FRIENDLY" },
            [7] = { Description = "TXT_KEY_CITY_STATE_PERSONALITY_PIRATE_REPUBLIC" },
        },
    }
    local personality = 7
    env.Players = {
        [3] = {
            GetPersonality = function()
                return personality
            end,
        },
    }
    T.eq(
        lekmod.minorPersonalityTextKey(3),
        "TXT_KEY_CITY_STATE_PERSONALITY_PIRATE_REPUBLIC",
        "a personality past the enum's four must still name itself"
    )
    personality = 0
    T.eq(
        lekmod.minorPersonalityTextKey(3),
        "TXT_KEY_CITY_STATE_PERSONALITY_FRIENDLY",
        "the table is the source of truth for the original four too"
    )
end

return M
