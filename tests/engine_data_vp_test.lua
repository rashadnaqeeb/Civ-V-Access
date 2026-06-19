-- VP EngineData port tests. Two jobs:
--   * Parity: the vanilla and VP CivVAccess_EngineData.lua must define the
--     identical function set, so a seam added to one and forgotten in the
--     other fails here instead of failing at speech time on the other
--     engine (the port plan's phase 2 harness requirement).
--   * VP bodies: pin the conversions the VP file performs -- node shape
--     remap, 0-based-to-1-based turn offset, VP move-flag bit values,
--     times-100 tourism, positional argument orders. Every one is a
--     silent-value failure if wrong: nothing crashes, a spoken number or
--     defender pick is just wrong on VP.
--
-- Each test loads the file under test into a fresh environment (setfenv)
-- whose reads fall through to _G, so engine stubs (Game, Map, Players) are
-- installed per-sandbox without touching the suite-wide globals run.lua
-- owns.

local T = require("support")
local M = {}

local VANILLA_PATH = "src/dlc/UI/InGame/CivVAccess_EngineData.lua"
local VP_PATH = "src/vp/CivVAccess_EngineData.lua"

-- Load one EngineData implementation in an isolated environment. Returns
-- (EngineData table, env) -- assigning env.Game / env.Map / env.Players /
-- env.Log shadows the corresponding global for the loaded module only.
local function loadSeam(path)
    local env = setmetatable({}, { __index = _G })
    local chunk = assert(loadfile(path))
    setfenv(chunk, env)
    chunk()
    return env.EngineData, env
end

-- VP module with the fork canary present, so fork-gated bodies run.
local function loadVPWithFork()
    local vp, env = loadSeam(VP_PATH)
    env.Game = {
        GetBuildRoutePath = function() end,
        GetCycleUnits = function() end,
        GetClosestSearchedPlot = function() end,
        IsDebugMode = function()
            return false
        end,
    }
    return vp, env
end

function M.test_vanilla_and_vp_define_identical_function_sets()
    local vanilla = loadSeam(VANILLA_PATH)
    local vp = loadSeam(VP_PATH)
    local missing, extra = {}, {}
    for name, value in pairs(vanilla) do
        if type(value) == "function" and type(vp[name]) ~= "function" then
            missing[#missing + 1] = name
        end
    end
    for name, value in pairs(vp) do
        if type(value) == "function" and type(vanilla[name]) ~= "function" then
            extra[#extra + 1] = name
        end
    end
    table.sort(missing)
    table.sort(extra)
    T.eq(table.concat(missing, ","), "", "seam functions missing from the VP implementation")
    T.eq(table.concat(extra, ","), "", "seam functions only in the VP implementation")
end

function M.test_vp_golden_age_rate_gated_on_balance_mode()
    -- The GAP getters compose a real rate only under MOD_BALANCE_VP; with VP
    -- balance off (Community-Patch-only) GetHappinessForGAP returns excess
    -- happiness instead, so the seam must report no rate there rather than a
    -- wrong number.
    local vp, env = loadSeam(VP_PATH)
    local balanceOn = false
    env.Game = {
        IsCustomModOption = function(opt)
            return opt == "BALANCE_VP" and balanceOn
        end,
    }
    local player = {
        GetHappinessForGAP = function()
            return 7
        end,
        GetGAPFromReligion = function()
            return 2
        end,
        GetGAPFromTraits = function()
            return 1
        end,
        GetGAPFromCitiesTimes100 = function()
            return 350
        end,
    }
    T.eq(vp.goldenAgePerTurn(player), nil, "no rate with VP balance off (would be a wrong number)")
    balanceOn = true
    -- (7 + 2 + 1) * 100 + 350 = 1350, floored /100 = 13.
    T.eq(vp.goldenAgePerTurn(player), 13, "floored GAP rate with VP balance on")
end

-- A VP-shaped pathfinder node array: engine field names, 0-based turns.
local function vpNodes()
    return {
        { X = 1, Y = 2, RemainingMovement = 60, Turn = 0 },
        { X = 2, Y = 2, RemainingMovement = 0, Turn = 0 },
        { X = 3, Y = 3, RemainingMovement = 90, Turn = 1 },
    }
end

-- Stub map where the plot at (3,3) is unrevealed, to pin that revealed
-- comes from a live IsRevealed re-query (VP's Invisible field is current
-- visibility, not revealedness -- using it would truncate spoken routes
-- at fogged-but-explored tiles).
local function installMapStub(env)
    env.Map = {
        GetPlot = function(x, y)
            return {
                IsRevealed = function()
                    return not (x == 3 and y == 3)
                end,
            }
        end,
    }
end

function M.test_vp_compute_path_converts_nodes_to_canonical_shape()
    local vp, env = loadVPWithFork()
    installMapStub(env)
    local unit = {
        GetID = function()
            return 7
        end,
        GetX = function()
            return 1
        end,
        GetY = function()
            return 2
        end,
        GetTeam = function()
            return 0
        end,
        GeneratePathWithFlags = function()
            return vpNodes()
        end,
    }
    local fromPlot = {
        GetX = function()
            return 1
        end,
        GetY = function()
            return 2
        end,
    }
    local nodes, success, legTurns = vp.computePath(unit, fromPlot, "target", nil, false)
    T.truthy(success)
    T.eq(legTurns, 2, "VP 0-based destination turn 1 must speak as 2 (1 = this turn)")
    T.eq(#nodes, 3)
    T.eq(nodes[1].x, 1)
    T.eq(nodes[1].y, 2)
    T.eq(nodes[1].moves, 60, "RemainingMovement must cross as moves")
    T.eq(nodes[1].turn, 1, "VP turn 0 must convert to 1")
    T.eq(nodes[3].turn, 2)
    T.truthy(nodes[1].revealed)
    T.falsy(nodes[3].revealed, "revealed must come from the live IsRevealed re-query")
    T.eq(nodes[1].X, nil, "VP field names must not leak across the seam")
end

function M.test_vp_generate_path_returns_ok_and_one_based_turns()
    local vp, _env = loadVPWithFork()
    local unit = {
        GetID = function()
            return 7
        end,
        GetOwner = function()
            return 0
        end,
        GeneratePathWithFlags = function(_, _plot, flags)
            T.eq(flags, 0, "a plain generatePath must run a STRICT search (no flags), matching real moves")
            return vpNodes()
        end,
    }
    local ok, turns = vp.generatePath(unit, "plot")
    T.truthy(ok)
    T.eq(turns, 2, "destination Turn 1 (0-based) must report as 2")
end

-- A destination the unit reaches by spending all its movement this turn is
-- a TC_UI stop node: VP's binding already adds the end-of-turn +1, so its
-- raw Turn is 1 (0-based 0 plus the TC_UI bump) with RemainingMovement 0.
-- The seam must NOT add a second +1 -- the move arrives THIS turn, so it
-- reports 1, matching the vanilla fork. A flat +1 would say 2 turns for the
-- commonest move there is (a unit walking its full distance in open
-- terrain), which is exactly how the spoken turn counts drift from reality.
local function stopNodeDestPath()
    return {
        { X = 1, Y = 2, RemainingMovement = 60, Turn = 0 },
        { X = 2, Y = 3, RemainingMovement = 0, Turn = 1 },
    }
end

function M.test_vp_stop_node_destination_arrives_this_turn()
    local vp, env = loadVPWithFork()
    installMapStub(env)
    local unit = {
        GetID = function()
            return 7
        end,
        GetOwner = function()
            return 0
        end,
        GetX = function()
            return 1
        end,
        GetY = function()
            return 2
        end,
        GetTeam = function()
            return 0
        end,
        GeneratePathWithFlags = function()
            return stopNodeDestPath()
        end,
    }
    local ok, turns = vp.generatePath(unit, "plot")
    T.truthy(ok)
    T.eq(turns, 1, "a move that exhausts movement on arrival still arrives this turn (1, not 2)")

    local fromPlot = {
        GetX = function()
            return 1
        end,
        GetY = function()
            return 2
        end,
    }
    local nodes, success, legTurns = vp.computePath(unit, fromPlot, "target", nil, false)
    T.truthy(success)
    T.eq(legTurns, 1, "computePath must not double-count the stop-node end-of-turn either")
    T.eq(nodes[2].turn, 1, "the stop-node destination's per-node turn is 1, not 2")
    T.eq(nodes[1].turn, 1, "an in-turn node (movement left) still converts 0 -> 1")
end

function M.test_vp_generate_path_reports_unreachable_on_empty_node_table()
    local vp, _env = loadVPWithFork()
    local unit = {
        GetID = function()
            return 7
        end,
        GetOwner = function()
            return 0
        end,
        GeneratePathWithFlags = function()
            return {}
        end,
    }
    T.falsy(vp.generatePath(unit, "plot"), "empty VP path table means unreachable")
end

-- The whole point of the fork binding: a relaxation intent reaches the
-- pathfinder as a real flag, so a STRICT search (flags 0, matching a manual
-- move) and single relaxations are both expressible. ignoreStacking is
-- MOVEFLAG_IGNORE_STACKING_SELF (0x0010); declareWar maps to
-- MOVEFLAG_IGNORE_RIGHT_OF_PASSAGE (0x80000), VP's closed-borders recovery;
-- throughEnemy is MOVEFLAG_IGNORE_ENEMIES (0x2000000).
function M.test_vp_generate_path_applies_relaxation_flags()
    local vp, _env = loadVPWithFork()
    local seenFlags = {}
    local unit = {
        GetID = function()
            return 7
        end,
        GetOwner = function()
            return 0
        end,
        GeneratePathWithFlags = function(_, _plot, flags)
            seenFlags[#seenFlags + 1] = flags
            return vpNodes()
        end,
    }
    vp.generatePath(unit, "plot")
    vp.generatePath(unit, "plot", { ignoreStacking = true })
    vp.generatePath(unit, "plot", { declareWar = true })
    vp.generatePath(unit, "plot", { throughEnemy = true })
    T.eq(seenFlags[1], 0, "strict search passes no flags")
    T.eq(seenFlags[2], 0x0010, "ignoreStacking -> MOVEFLAG_IGNORE_STACKING_SELF")
    T.eq(seenFlags[3], 0x80000, "declareWar -> MOVEFLAG_IGNORE_RIGHT_OF_PASSAGE")
    T.eq(seenFlags[4], 0x2000000, "throughEnemy -> MOVEFLAG_IGNORE_ENEMIES")
end

-- Without the fork DLL there is no flag-aware binding, so generatePath
-- falls back to stock VP GeneratePath (takes maxTurns, not flags, and
-- hardcodes own-unit stacking relaxation). It still returns a turn count;
-- the relaxation simply can't apply, which it logs at debug.
function M.test_vp_generate_path_without_fork_falls_back_to_stock()
    local vp, env = loadSeam(VP_PATH)
    env.Game = {} -- present but missing the fork canaries -> forkPresent() false
    local stockMaxTurns = nil
    local noted = false
    env.Log = {
        debug = function()
            noted = true
        end,
        warn = function() end,
    }
    local unit = {
        GetID = function()
            return 7
        end,
        GetOwner = function()
            return 0
        end,
        GeneratePath = function(_, _plot, maxTurns)
            stockMaxTurns = maxTurns
            return vpNodes()
        end,
    }
    local ok, turns = vp.generatePath(unit, "plot", { ignoreStacking = true })
    T.truthy(ok)
    T.eq(turns, 2, "fallback still reports the turn count")
    T.truthy(stockMaxTurns ~= nil and stockMaxTurns > 9000, "stock fallback passes unlimited maxTurns")
    T.truthy(noted, "an unappliable relaxation on stock VP is logged")
end

function M.test_vp_get_path_reruns_last_generate_target()
    local vp, env = loadVPWithFork()
    installMapStub(env)
    local pathed = {}
    local unit = {
        GetID = function()
            return 7
        end,
        GetOwner = function()
            return 0
        end,
        GetTeam = function()
            return 0
        end,
        GeneratePathWithFlags = function(_, plot)
            pathed[#pathed + 1] = plot
            return vpNodes()
        end,
    }
    vp.generatePath(unit, "target-plot")
    local nodes = vp.getPath(unit)
    T.eq(#pathed, 2, "getPath must re-run the search (VP has no cached-path readback)")
    T.eq(pathed[2], "target-plot", "getPath must re-use the last generatePath plot handle")
    T.eq(nodes[2].moves, 0)
end

function M.test_vp_get_path_degrades_without_prior_generate()
    local vp, env = loadVPWithFork()
    local warned = false
    env.Log = {
        warn = function()
            warned = true
        end,
    }
    local unit = {
        GetID = function()
            return 99
        end,
        GeneratePathWithFlags = function()
            error("must not path without a prior generatePath target")
        end,
    }
    local nodes = vp.getPath(unit)
    T.eq(#nodes, 0)
    T.truthy(warned, "contract misuse must log")
end

-- The VP fork binding has no pathfinder state to read the searched unit
-- back from (the vanilla binding does), so the seam must pass the unit of
-- its last generatePath as extra args for the fork's reach query. A wrong
-- unit here silently answers "got as far as X" for some other unit's
-- mobility.
function M.test_vp_closest_searched_plot_passes_last_generated_unit()
    local vp, env = loadVPWithFork()
    local captured = nil
    env.Game.GetClosestSearchedPlot = function(tx, ty, owner, unitID)
        captured = { tx = tx, ty = ty, owner = owner, unitID = unitID }
        return 4, 5, 6
    end
    local unit = {
        GetID = function()
            return 7
        end,
        GetOwner = function()
            return 3
        end,
        GeneratePathWithFlags = function()
            return {}
        end,
    }
    vp.generatePath(unit, "plot")
    local x, y, dist = vp.closestSearchedPlot(10, 11)
    T.eq(x, 4)
    T.eq(y, 5)
    T.eq(dist, 6)
    T.eq(captured.tx, 10)
    T.eq(captured.ty, 11)
    T.eq(captured.owner, 3, "owner must come from the last generatePath unit")
    T.eq(captured.unitID, 7, "unit id must come from the last generatePath unit")
end

function M.test_vp_closest_searched_plot_degrades_without_prior_generate()
    local vp, env = loadVPWithFork()
    local warned = false
    env.Log = {
        warn = function()
            warned = true
        end,
    }
    T.eq(vp.closestSearchedPlot(1, 2), nil)
    T.truthy(warned, "contract misuse must log")
end

-- The waypoint-leg slice: GetWaypointPath concatenates per-leg node lists,
-- each leg starting at the prior leg's destination; the consecutive
-- duplicate coordinate is the boundary. Asking for the second leg must
-- return exactly its nodes with leg-local 1-based turns.
function M.test_vp_compute_path_slices_queued_leg_from_waypoint_path()
    local vp, env = loadVPWithFork()
    installMapStub(env)
    local unit = {
        GetID = function()
            return 7
        end,
        GetX = function()
            return 0
        end,
        GetY = function()
            return 0
        end,
        GetTeam = function()
            return 0
        end,
        LastMissionPlot = function()
            return {
                GetX = function()
                    return 9
                end,
                GetY = function()
                    return 9
                end,
            }
        end,
        GetWaypointPath = function()
            return {
                -- leg 1: (0,0) -> (5,5)
                { X = 0, Y = 0, RemainingMovement = 60, Turn = 0 },
                { X = 5, Y = 5, RemainingMovement = 0, Turn = 0 },
                -- leg 2: (5,5) -> (9,9); starts at leg 1's destination
                { X = 5, Y = 5, RemainingMovement = 60, Turn = 0 },
                { X = 9, Y = 9, RemainingMovement = 30, Turn = 1 },
            }
        end,
    }
    local fromPlot = {
        GetX = function()
            return 5
        end,
        GetY = function()
            return 5
        end,
    }
    local toPlot = {
        GetX = function()
            return 9
        end,
        GetY = function()
            return 9
        end,
    }
    local nodes, success, legTurns = vp.computePath(unit, fromPlot, toPlot, nil, true)
    T.truthy(success)
    T.eq(#nodes, 2, "the slice must contain only the second leg")
    T.eq(nodes[1].x, 5)
    T.eq(nodes[2].x, 9)
    T.eq(legTurns, 2)
end

function M.test_vp_compute_path_uses_next_waypoint_binding_from_queue_tail()
    local vp, env = loadVPWithFork()
    installMapStub(env)
    local unit = {
        GetID = function()
            return 7
        end,
        GetX = function()
            return 0
        end,
        GetY = function()
            return 0
        end,
        GetTeam = function()
            return 0
        end,
        LastMissionPlot = function()
            return {
                GetX = function()
                    return 1
                end,
                GetY = function()
                    return 2
                end,
            }
        end,
        GeneratePathToNextWaypoint = function(_, toPlot)
            T.eq(toPlot, "cursor-plot")
            return vpNodes()
        end,
    }
    local fromPlot = {
        GetX = function()
            return 1
        end,
        GetY = function()
            return 2
        end,
    }
    local nodes, success, legTurns = vp.computePath(unit, fromPlot, "cursor-plot", nil, true)
    T.truthy(success)
    T.eq(#nodes, 3)
    T.eq(legTurns, 2)
end

function M.test_vp_compute_path_rejects_unknown_intent_names()
    local vp, _env = loadVPWithFork()
    local unit = {
        GetX = function()
            return 0
        end,
        GetY = function()
            return 0
        end,
    }
    local fromPlot = {
        GetX = function()
            return 0
        end,
        GetY = function()
            return 0
        end,
    }
    local ok, err = pcall(vp.computePath, unit, fromPlot, "target", { declareWarr = true }, false)
    T.falsy(ok, "unknown intent must raise on VP too")
    T.truthy(tostring(err):find("declareWarr", 1, true), "error must name the bad intent")
end

-- Mission flags decode with VP's MOVEFLAG bit values (CvUnit.h), which
-- differ from vanilla's: a vanilla bit table here would decode VP's
-- automation flags into garbage intents and re-price queued legs wrongly.
function M.test_vp_mission_queue_decodes_vp_flag_bits()
    local vp, _env = loadVPWithFork()
    local unit = {
        GetMissionQueue = function()
            return {
                -- VP automation set: NO_ENEMY_TERRITORY (0x0400) +
                -- IGNORE_DANGER (0x0100) + MAXIMIZE_EXPLORE (0x0800)
                { mission = 1, data1 = 3, data2 = 4, flags = 0x0D00, pushTurn = 7 },
                { mission = 2, data1 = 0, data2 = 0, flags = 0x2000000, pushTurn = 8 },
                -- An unrelated VP flag (MOVEFLAG_APPROX_TARGET_RING1) must
                -- decode to no intent rather than a false positive.
                { mission = 3, data1 = 0, data2 = 0, flags = 0x8000, pushTurn = 9 },
            }
        end,
    }
    local queue = vp.missionQueue(unit)
    T.truthy(queue[1].intents.noEnemyTerritory, "0x0400 must decode to noEnemyTerritory")
    T.truthy(queue[1].intents.ignoreDanger, "0x0100 must decode to ignoreDanger")
    T.truthy(queue[1].intents.maximizeExplore, "0x0800 must decode to maximizeExplore")
    T.falsy(queue[1].intents.ignoreStacking, "unset bit must not decode")
    T.truthy(queue[2].intents.throughEnemy, "0x2000000 must decode to throughEnemy")
    T.eq(queue[1].flags, nil, "raw engine flags must not cross the seam")
    T.eq(next(queue[3].intents), nil, "unmapped VP flags must decode to empty intents")
end

function M.test_vp_melee_damage_dual_return_support_and_volley()
    local vp, _env = loadVPWithFork()
    local seen
    local attacker = {
        GetMeleeCombatDamage = function(_, strength, opponentStrength, includeRand, otherUnit, extraDefenderDamage)
            seen = {
                strength = strength,
                opponentStrength = opponentStrength,
                includeRand = includeRand,
                otherUnit = otherUnit,
                extraDefenderDamage = extraDefenderDamage,
            }
            return 31, 17
        end,
    }
    local toDefender, toAttacker = vp.meleeDamage(attacker, "defender", 500, 400, 9, 6)
    T.eq(toDefender, 31, "melee-only; the caller adds the volley itself")
    T.eq(toAttacker, 26, "support fire damage lands on the attacker's incoming total")
    T.eq(seen.strength, 500)
    T.eq(seen.opponentStrength, 400)
    T.eq(seen.includeRand, false, "previews must be deterministic")
    T.eq(seen.otherUnit, "defender")
    T.eq(seen.extraDefenderDamage, 6, "the volley crosses as VP's extraDefenderDamage")
end

function M.test_vp_city_melee_damage_passes_city_not_strength()
    local vp, _env = loadVPWithFork()
    local seen
    local attacker = {
        GetMeleeCombatDamageCity = function(_, strength, city, includeRand)
            seen = { strength = strength, city = city, includeRand = includeRand }
            return 40, 12
        end,
    }
    local toCity, toAttacker = vp.cityMeleeDamage(attacker, "city", 700, 600, 5)
    T.eq(toCity, 40)
    T.eq(toAttacker, 17)
    T.eq(seen.strength, 700)
    T.eq(seen.city, "city", "VP reads the city's strength internally; the handle crosses, not the number")
    T.eq(seen.includeRand, false)
end

function M.test_vp_max_defense_strength_inserts_from_plot_and_volley()
    local vp, _env = loadVPWithFork()
    local seen
    local defender = {
        GetMaxDefenseStrength = function(_, toPlot, attacker, fromPlot, fromRanged, assumeExtraDamage)
            seen = {
                toPlot = toPlot,
                attacker = attacker,
                fromPlot = fromPlot,
                fromRanged = fromRanged,
                assumeExtraDamage = assumeExtraDamage,
            }
            return 999
        end,
    }
    local attacker = {
        GetPlot = function()
            return "attacker-plot"
        end,
    }
    T.eq(vp.maxDefenseStrength(defender, "to-plot", attacker, true), 999)
    T.eq(seen.toPlot, "to-plot")
    T.eq(seen.attacker, attacker)
    T.eq(seen.fromPlot, "attacker-plot", "VP's inserted from-plot must be the attacker's plot")
    T.eq(seen.fromRanged, true)
    T.eq(seen.assumeExtraDamage, 0, "no volley defaults to 0, not nil")
    vp.maxDefenseStrength(defender, "to-plot", attacker, false, 25)
    T.eq(seen.assumeExtraDamage, 25, "the volley crosses as VP's assume-extra-damage")
end

function M.test_vp_plot_defense_modifier_inserts_ignore_feature_false()
    local vp, _env = loadVPWithFork()
    local seen
    local plot = {
        DefenseModifier = function(_, team, ignoreBuilding, ignoreFeature, help)
            seen = { team = team, ignoreBuilding = ignoreBuilding, ignoreFeature = ignoreFeature, help = help }
            return 25
        end,
    }
    T.eq(vp.plotDefenseModifier(plot, 3, false, true), 25)
    T.eq(seen.team, 3)
    T.eq(seen.ignoreBuilding, false)
    T.eq(seen.ignoreFeature, false, "feature modifiers must stay included")
    T.eq(seen.help, true)
end

-- VP dropped the unit-level CapitalDefenseModifier / CapitalDefenseFalloff
-- bindings (a nil-call crash in the melee preview, killing the whole combat
-- readout) and rolled the value + distance walk + falloff clamp into one
-- binding that takes the battle plot.
function M.test_vp_capital_defense_modifier_uses_combined_binding()
    local vp, env = loadVPWithFork()
    local sentinelPlot = {}
    env.Map = {
        GetPlot = function(x, y)
            T.eq(x, 5)
            T.eq(y, 7)
            return sentinelPlot
        end,
    }
    local unit = {
        GetX = function()
            return 5
        end,
        GetY = function()
            return 7
        end,
        GetCombatModifierFromCapitalDistance = function(_, plot)
            T.eq(plot, sentinelPlot, "VP evaluates at the unit's own plot")
            return 15
        end,
        CapitalDefenseModifier = function()
            error("VP must not read the dropped unit binding")
        end,
    }
    T.eq(vp.capitalDefenseModifier(unit), 15)
end

-- Vanilla walks the distance from the capital and applies the per-hex
-- falloff itself; a negative falloff that drives the bonus to zero or below
-- yields no modifier (the caller's nonzero guard then skips the line).
function M.test_vanilla_capital_defense_modifier_walks_distance_falloff()
    local vanilla, env = loadSeam(VANILLA_PATH)
    env.Players = {
        [3] = {
            GetCapitalCity = function()
                return {
                    GetX = function()
                        return 0
                    end,
                    GetY = function()
                        return 0
                    end,
                }
            end,
        },
    }
    env.Map = {
        PlotDistance = function()
            return 4
        end,
    }
    local function unitWith(base, falloff)
        return {
            GetOwner = function()
                return 3
            end,
            GetX = function()
                return 2
            end,
            GetY = function()
                return 2
            end,
            CapitalDefenseModifier = function()
                return base
            end,
            CapitalDefenseFalloff = function()
                return falloff
            end,
        }
    end
    T.eq(vanilla.capitalDefenseModifier(unitWith(50, -5)), 30, "50 + 4 * -5")
    T.eq(vanilla.capitalDefenseModifier(unitWith(10, -5)), 0, "falloff drives it non-positive")
    T.eq(
        vanilla.capitalDefenseModifier({
            CapitalDefenseModifier = function()
                return 0
            end,
        }),
        0,
        "no capital-defense promotion short-circuits before the capital lookup"
    )
end

-- The Soldiers demographic multiplier is the drift: VP scales sqrt(might)
-- by 5000 where vanilla uses 2000. A wrong constant here speaks an absolute
-- 2.5x off VP's screen (rank unaffected), a silent-value failure.
function M.test_vp_army_demographic_uses_vp_multiplier()
    local vp = loadVPWithFork()
    local player = {
        GetMilitaryMight = function()
            return 100
        end,
    }
    T.eq(vp.armyDemographic(player), math.sqrt(100) * 5000)
    local vanilla = loadSeam(VANILLA_PATH)
    T.eq(vanilla.armyDemographic(player), math.sqrt(100) * 2000, "vanilla keeps the 2000 multiplier")
end

-- VP keys the Military Overview promotion indicator off the raw XP
-- threshold, not CanPromote (which also gates on move/combat state).
function M.test_vp_unit_promotion_ready_uses_xp_threshold()
    local vp = loadVPWithFork()
    local unit = {
        CanPromote = function()
            error("VP must not consult CanPromote for the indicator")
        end,
        GetExperience = function()
            return 30
        end,
        ExperienceNeeded = function()
            return 30
        end,
    }
    T.truthy(vp.unitPromotionReady(unit), "XP at threshold is promotion-ready on VP")
    local vanilla = loadSeam(VANILLA_PATH)
    local vanillaUnit = {
        CanPromote = function()
            return false
        end,
        GetExperience = function()
            error("vanilla must consult CanPromote, not the XP threshold")
        end,
    }
    T.falsy(vanilla.unitPromotionReady(vanillaUnit), "vanilla keys off CanPromote")
end

-- VP's Supply Use counts only units that draw supply; vanilla counts all.
function M.test_vp_supply_used_counts_supply_drawing_units()
    local vp = loadVPWithFork()
    local player = {
        GetNumUnitsToSupply = function()
            return 18
        end,
        GetNumUnits = function()
            error("VP must use GetNumUnitsToSupply for supply use")
        end,
    }
    T.eq(vp.supplyUsed(player), 18)
    local vanilla = loadSeam(VANILLA_PATH)
    T.eq(
        vanilla.supplyUsed({
            GetNumUnits = function()
                return 25
            end,
        }),
        25,
        "vanilla counts every unit"
    )
end

-- Vanilla bills unit supply as its own gold-breakdown line; VP folds it into
-- unit maintenance and deprecated the getter (a raw call errors), so the VP
-- body returns 0 without touching it and the supply line drops.
function M.test_vp_unit_supply_cost_is_zero_and_skips_deprecated_getter()
    local vp = loadVPWithFork()
    T.eq(
        vp.unitSupplyCost({
            CalculateUnitSupply = function()
                error("VP deprecated CalculateUnitSupply; the seam must not call it")
            end,
        }),
        0
    )
    local vanilla = loadSeam(VANILLA_PATH)
    T.eq(
        vanilla.unitSupplyCost({
            CalculateUnitSupply = function()
                return 7
            end,
        }),
        7,
        "vanilla bills supply separately"
    )
end

-- VP's getBuildTurnsLeft already credits any worker on the plot, so the
-- prospective "if you start this" estimate must pass no extra rate; vanilla
-- only credits the build the unit is already doing, so it feeds the worker's
-- own rate in. Feeding it on VP would double-count and halve the turns.
function M.test_vp_build_turns_if_started_omits_extra_rate()
    local vp = loadVPWithFork()
    local captured
    local plot = {
        GetBuildTurnsLeft = function(_self, _build, _player, iNow, iThen)
            captured = { now = iNow, then_ = iThen }
            return 4
        end,
    }
    local unit = {
        GetBuildType = function()
            return -1
        end,
        WorkRate = function()
            error("VP must not feed the work rate as the extra build rate")
        end,
    }
    T.eq(vp.buildTurnsIfStarted(unit, plot, 7, 0), 4)
    T.eq(captured.now, 0, "VP passes no extra now-rate")
    T.eq(captured.then_, 0, "VP passes no extra then-rate")

    local vanilla = loadSeam(VANILLA_PATH)
    local vCaptured
    local vPlot = {
        GetBuildTurnsLeft = function(_self, _build, _player, iNow, iThen)
            vCaptured = { now = iNow, then_ = iThen }
            return 4
        end,
    }
    local vUnit = {
        GetBuildType = function()
            return -1
        end,
        WorkRate = function()
            return 200
        end,
    }
    vanilla.buildTurnsIfStarted(vUnit, vPlot, 7, 0)
    T.eq(vCaptured.now, 200, "vanilla feeds the worker's rate as the extra now-rate")
    T.eq(vCaptured.then_, 200, "vanilla feeds the worker's rate as the extra then-rate")
end

-- VP's getBuildTurnsLeft rounds up and never reports 0 for an in-progress
-- build, so VP drops vanilla's display +1 (a build finishing end-of-turn
-- reads as 1 rather than 0 on vanilla).
function M.test_vp_active_build_turns_drops_display_plus_one()
    local vp = loadVPWithFork()
    local plot = {
        GetBuildTurnsLeft = function()
            return 4
        end,
    }
    T.eq(vp.activeBuildTurns(plot, 7, 0), 4, "VP returns the bare engine count")
    local vanilla = loadSeam(VANILLA_PATH)
    T.eq(vanilla.activeBuildTurns(plot, 7, 0), 5, "vanilla adds the display +1")
end

-- The route-path preview drops the supplied extra rate on the worker's start
-- plot only when getBuildTurnsLeft already credits the on-plot worker. VP
-- credits any worker on the plot (so always drop it); vanilla credits it only
-- when the worker is already performing that build.
function M.test_vp_on_plot_worker_counted_is_unconditional()
    local vp = loadVPWithFork()
    T.truthy(vp.onPlotWorkerCounted(false), "VP counts an on-plot worker even when not already on this build")
    T.truthy(vp.onPlotWorkerCounted(true), "VP counts an on-plot worker that is already on this build")
    local vanilla = loadSeam(VANILLA_PATH)
    T.falsy(vanilla.onPlotWorkerCounted(false), "vanilla credits only the build the worker is performing")
    T.truthy(vanilla.onPlotWorkerCounted(true), "vanilla credits the worker already on this build")
end

-- VP transfers religion control with the holy city, so the religion a
-- player "has" for the overview is the owned one (GetOwnedReligion), not
-- the founded one; pantheon-or-below collapses to -1.
function M.test_vp_owned_religion_uses_owned_not_founded()
    local vp, env = loadVPWithFork()
    env.ReligionTypes = { RELIGION_PANTHEON = 0 }
    local owner = {
        GetOwnedReligion = function()
            return 3
        end,
        HasCreatedReligion = function()
            error("VP must read owned religion, not founded")
        end,
    }
    T.eq(vp.ownedReligion(owner), 3)
    local pantheonOnly = {
        GetOwnedReligion = function()
            return 0
        end,
    }
    T.eq(vp.ownedReligion(pantheonOnly), -1, "pantheon-or-below collapses to none")
    local vanilla = loadSeam(VANILLA_PATH)
    T.eq(
        vanilla.ownedReligion({
            HasCreatedReligion = function()
                return true
            end,
            GetReligionCreatedByPlayer = function()
                return 5
            end,
        }),
        5,
        "vanilla reads the founded religion"
    )
    T.eq(
        vanilla.ownedReligion({
            HasCreatedReligion = function()
                return false
            end,
        }),
        -1
    )
end

-- The holy-city lookup is founder-keyed on vanilla (controller is founder)
-- but ownership-agnostic (-1) on VP, where the controller may not be the
-- founder.
function M.test_vp_holy_city_lookup_ignores_founder()
    local vp, env = loadVPWithFork()
    local seen
    env.Game.GetHolyCityForReligion = function(eReligion, ePlayer)
        seen = { eReligion = eReligion, ePlayer = ePlayer }
        return "holy-city"
    end
    local controller = {
        GetID = function()
            return 4
        end,
    }
    T.eq(vp.holyCityForReligion(7, controller), "holy-city")
    T.eq(seen.ePlayer, -1, "VP must look up the religion regardless of founder")
    local vanilla, venv = loadSeam(VANILLA_PATH)
    venv.Game = {
        GetHolyCityForReligion = function(_eReligion, ePlayer)
            seen = { ePlayer = ePlayer }
            return "vc"
        end,
    }
    vanilla.holyCityForReligion(7, controller)
    T.eq(seen.ePlayer, 4, "vanilla keys the lookup on the controlling (founder) player")
end

function M.test_vp_tourism_floors_times_100()
    local vp, _env = loadVPWithFork()
    local player = {
        GetTourism = function()
            return 1234
        end,
    }
    T.eq(vp.tourism(player), 12, "times-100 tourism must floor to the displayed rate")
end

-- VP's GetBaseTourism is times-100 (getYieldRateTimes100) where vanilla's is
-- already a plain rate. The seam must hide that divergence so both consumers
-- read a plain rate; a passthrough on both sides reads 100x low on vanilla.
function M.test_vp_base_tourism_floors_times_100()
    local vp, _env = loadVPWithFork()
    local city = {
        GetBaseTourism = function()
            return 1234
        end,
    }
    T.eq(vp.baseTourism(city), 12, "VP base tourism must floor the times-100 getter")
end

function M.test_vanilla_base_tourism_passes_plain_rate()
    local vanilla = loadSeam(VANILLA_PATH)
    local city = {
        GetBaseTourism = function()
            return 12
        end,
    }
    T.eq(vanilla.baseTourism(city), 12, "vanilla base tourism is already a plain rate")
end

-- VP deleted GetCultureFromSpecialist (a nil-call crash in the specialist
-- tooltip) and folded specialist culture into the YIELD_CULTURE yield the
-- caller's yield loop already counts; the VP body must return 0 without
-- touching the removed binding. Vanilla still reads the separate getter.
function M.test_vp_culture_from_specialist_returns_zero_to_avoid_double_count()
    local vp, _env = loadVPWithFork()
    local city = {
        GetCultureFromSpecialist = function()
            error("VP must not call the removed GetCultureFromSpecialist binding")
        end,
    }
    T.eq(vp.cultureFromSpecialist(city, 2), 0)
    local vanilla = loadSeam(VANILLA_PATH)
    T.eq(
        vanilla.cultureFromSpecialist({
            GetCultureFromSpecialist = function(_, specID)
                T.eq(specID, 2, "vanilla forwards the specialist id")
                return 3
            end,
        }, 2),
        3,
        "vanilla reads the separate specialist-culture getter"
    )
end

-- VP gates the resource "requires tech" hint on the per-player
-- IsResourceImproveable check and names the tech from the VP-only
-- TechImproveable column, not vanilla's TechCityTrade (empty for this gate
-- on VP). Already-improveable resources report nil.
function M.test_vp_resource_use_tech_uses_improveable_gate_and_column()
    local vp, env = loadVPWithFork()
    env.Game.GetActivePlayer = function()
        return 0
    end
    env.GameInfoTypes = { TECH_MINING = 5 }
    env.GameInfo = { Technologies = { [5] = { Description = "TXT_KEY_TECH_MINING" } } }
    env.Players = {
        [0] = {
            IsResourceImproveable = function(_, id)
                T.eq(id, 9, "VP passes the resource id to the improveable gate")
                return false
            end,
        },
    }
    T.eq(
        vp.resourceUseTech({ ID = 9, TechImproveable = "TECH_MINING", TechCityTrade = "TECH_UNKNOWN" }),
        "TXT_KEY_TECH_MINING",
        "VP names the tech from TechImproveable, ignoring TechCityTrade"
    )
    env.Players[0].IsResourceImproveable = function()
        return true
    end
    T.eq(vp.resourceUseTech({ ID = 9, TechImproveable = "TECH_MINING" }), nil, "already improveable reports nil")
end

-- Vanilla keys the hint off TechCityTrade and a team HasTech check.
function M.test_vanilla_resource_use_tech_reads_city_trade_and_team_tech()
    local vanilla, env = loadSeam(VANILLA_PATH)
    env.Game = {
        GetActiveTeam = function()
            return 0
        end,
    }
    env.GameInfoTypes = { TECH_TRADE = 5 }
    env.GameInfo = { Technologies = { [5] = { Description = "TXT_KEY_TECH_TRADE" } } }
    local hasTech = false
    env.Teams = {
        [0] = {
            GetTeamTechs = function()
                return {
                    HasTech = function(_, id)
                        T.eq(id, 5)
                        return hasTech
                    end,
                }
            end,
        },
    }
    T.eq(vanilla.resourceUseTech({ ID = 9, TechCityTrade = "TECH_TRADE" }), "TXT_KEY_TECH_TRADE", "team lacks the tech")
    hasTech = true
    T.eq(vanilla.resourceUseTech({ ID = 9, TechCityTrade = "TECH_TRADE" }), nil, "team has the tech")
    T.eq(vanilla.resourceUseTech({ ID = 9 }), nil, "no TechCityTrade column reports nil")
end

function M.test_vp_influence_tourism_per_turn_includes_instant_and_floors()
    local vp, _env = loadVPWithFork()
    local player = {
        GetInfluencePerTurn = function()
            error("VP must use the instant-inclusive getter, not GetInfluencePerTurn")
        end,
        GetTourismPerTurnIncludingInstantTimes100 = function(_, targetID)
            return targetID == 5 and 1234 or 0
        end,
    }
    T.eq(
        vp.influenceTourismPerTurn(player, 5),
        12,
        "VP per-turn tourism must include instant tourism and floor the times-100 rate"
    )
end

function M.test_vp_deal_resource_count_reads_player_stock()
    local vp, env = loadVPWithFork()
    local seen
    env.Players = {
        [3] = {
            GetNumResourceAvailable = function(_, resType, includeImport)
                seen = { resType = resType, includeImport = includeImport }
                return 4
            end,
        },
    }
    local deal = {
        GetNumResource = function()
            error("Deal:GetNumResource is unregistered in VP; must not be called")
        end,
    }
    T.eq(vp.dealResourceCount(deal, 3, 7), 4)
    T.eq(seen.resType, 7)
    T.eq(seen.includeImport, true)
end

function M.test_vp_best_defender_positional_args_and_potential_enemy_contract()
    local vp, _env = loadVPWithFork()
    local seen
    local plot = {
        GetBestDefender = function(_, owner, attackingPlayer, attacker, atWar, ignoreVisibility, canMove, noncombat)
            seen = {
                owner = owner,
                attackingPlayer = attackingPlayer,
                attacker = attacker,
                atWar = atWar,
                ignoreVisibility = ignoreVisibility,
                canMove = canMove,
                noncombat = noncombat,
            }
            return "defender"
        end,
    }
    local got = vp.bestDefender(plot, 3, "actor", { testAtWar = true, noncombatAllowed = true })
    T.eq(got, "defender")
    T.eq(seen.owner, -1, "owner filter stays off")
    T.eq(seen.attackingPlayer, 3)
    T.eq(seen.attacker, "actor")
    T.eq(seen.atWar, 1)
    T.eq(seen.ignoreVisibility, 0, "VP's repurposed slot must stay off")
    T.eq(seen.canMove, 0, "bTestCanMove stays off")
    T.eq(seen.noncombat, 1, "fork's noncombat extension at method arg 7")
    -- testPotentialEnemy honors the vanilla stub contract directly: no
    -- defender, and the engine is never asked.
    seen = nil
    T.eq(vp.bestDefender(plot, 3, nil, { testPotentialEnemy = true }), nil)
    T.eq(seen, nil, "potential-enemy queries must not reach the engine on VP")
end

-- Player stub for happinessSummary: engine-state getters plus the
-- citizen-needs surface, all overridable per test.
local function summaryPlayer(opts)
    return {
        GetExcessHappiness = function()
            return opts.excess or 0
        end,
        IsEmpireUnhappy = function()
            return opts.unhappy or false
        end,
        IsEmpireVeryUnhappy = function()
            return opts.veryUnhappy or false
        end,
        IsEmpireSuperUnhappy = function()
            return opts.superUnhappy or false
        end,
        GetHappinessFromCitizenNeeds = function()
            return opts.happyCitizens or 0
        end,
        GetUnhappinessFromCitizenNeeds = function()
            return opts.unhappyCitizens or 0
        end,
    }
end

-- VP module with the balance mode on, so the approval-model branches run.
local function loadVPWithBalance()
    local vp, env = loadVPWithFork()
    env.Game.IsCustomModOption = function(option)
        return option == "BALANCE_VP"
    end
    return vp, env
end

function M.test_vp_happiness_summary_approval_model_fields()
    local vp, _env = loadVPWithBalance()
    local s = vp.happinessSummary(summaryPlayer({ excess = 62, happyCitizens = 40, unhappyCitizens = 13 }))
    T.eq(s.mode, "approval")
    T.eq(s.value, 62)
    T.eq(s.happyCitizens, 40)
    T.eq(s.unhappyCitizens, 13)
    T.eq(s.state, "happy", "62 falls in the 60-75 tier")
end

-- The tier cuts mirror VP's top-panel colors; a drifted boundary speaks
-- the wrong mood word with nothing crashing.
function M.test_vp_happiness_summary_tier_boundaries()
    local vp, _env = loadVPWithBalance()
    T.eq(vp.happinessSummary(summaryPlayer({ excess = 75 })).state, "ecstatic")
    T.eq(vp.happinessSummary(summaryPlayer({ excess = 74 })).state, "happy")
    T.eq(vp.happinessSummary(summaryPlayer({ excess = 60 })).state, "happy")
    T.eq(vp.happinessSummary(summaryPlayer({ excess = 59 })).state, "content")
    -- Below 50 the engine-state getters own the verdict, not the percent.
    T.eq(vp.happinessSummary(summaryPlayer({ excess = 49, unhappy = true })).state, "unhappy")
    T.eq(vp.happinessSummary(summaryPlayer({ excess = 30, unhappy = true, veryUnhappy = true })).state, "veryUnhappy")
    T.eq(
        vp.happinessSummary(summaryPlayer({ excess = 10, unhappy = true, veryUnhappy = true, superUnhappy = true })).state,
        "superUnhappy"
    )
end

-- A Community-Patch-only session (balance off) keeps the vanilla
-- signed-surplus model; the summary must report it as such or every
-- consumer would format a surplus as a percent.
function M.test_vp_happiness_summary_surplus_shape_when_balance_off()
    local vp, _env = loadVPWithFork()
    local s = vp.happinessSummary(summaryPlayer({ excess = -7, unhappy = true }))
    T.eq(s.mode, "surplus")
    T.eq(s.value, -7)
    T.eq(s.state, "unhappy")
    T.eq(s.happyCitizens, nil, "citizen counts are an approval-model field")
end

-- The vanilla-model breakdown getters have no VP-balance answer; a call
-- there is a consumer that failed to branch, and it must crash with a
-- breadcrumb instead of speaking a fabricated 0.
function M.test_vp_vanilla_model_getters_error_under_balance()
    local vp, _env = loadVPWithBalance()
    local player = {
        GetHappinessFromBuildings = function()
            return 0
        end,
    }
    local ok, err = pcall(vp.happinessFromBuildings, player)
    T.falsy(ok, "vanilla-model getter must raise under VP balance")
    T.truthy(tostring(err):find("happinessSummary", 1, true), "error must point at the mode branch")
end

function M.test_vp_vanilla_model_getters_pass_through_when_balance_off()
    local vp, _env = loadVPWithFork()
    local player = {
        GetUnhappinessFromCityCount = function()
            return 350
        end,
    }
    T.eq(vp.unhappinessFromCityCount(player), 350)
end

-- Vassalage is VP-only: the vanilla body returns the empty model (no
-- vassalage system), the VP body reads the Team bindings and scans for the
-- serving teams. A wrong master/tenure mislabels the Diplomatic Overview;
-- a wrong scan drops a third-party vassal from the foreign-relations cell.
function M.test_vp_vassal_info_reads_team_bindings_and_scans_vassals()
    local vp, env = loadVPWithFork()
    env.GameDefines = { MAX_CIV_PLAYERS = 4 }
    -- Teams 0 and 3 serve team 1; the scan must find exactly those.
    local function teamStub(id)
        return {
            GetID = function()
                return id
            end,
            IsVassal = function(_, otherId)
                return (id == 0 or id == 3) and otherId == 1
            end,
        }
    end
    env.Teams = { [0] = teamStub(0), [1] = teamStub(1), [2] = teamStub(2), [3] = teamStub(3) }
    -- Team 1 serves master team 2 for 9 turns and holds two vassals.
    local team = {
        GetMaster = function()
            return 2
        end,
        IsVassalOfSomeone = function()
            return true
        end,
        -- Zero-arg binding (CvTeam::GetNumTurnsIsVassal); returns the team's
        -- own stored vassal duration regardless of any passed argument.
        GetNumTurnsIsVassal = function()
            return 9
        end,
        GetNumVassals = function()
            return 2
        end,
        GetID = function()
            return 1
        end,
    }
    local info = vp.vassalInfo(team)
    T.truthy(info.isVassal)
    T.eq(info.master, 2)
    T.eq(info.tenure, 9, "tenure is the team's own stored vassal duration")
    T.eq(info.numVassals, 2)
    T.eq(#info.vassals, 2, "the scan must find both serving teams")
    T.eq(info.vassals[1], 0)
    T.eq(info.vassals[2], 3)
end

function M.test_vp_vassal_info_free_team_has_no_master()
    local vp, env = loadVPWithFork()
    env.GameDefines = { MAX_CIV_PLAYERS = 4 }
    env.Teams = {}
    local freeTeam = {
        GetMaster = function()
            return -1
        end,
        IsVassalOfSomeone = function()
            return false
        end,
        GetNumTurnsIsVassal = function()
            error("a free team has no tenure to read")
        end,
        GetNumVassals = function()
            return 0
        end,
        GetID = function()
            return 2
        end,
    }
    local info = vp.vassalInfo(freeTeam)
    T.falsy(info.isVassal)
    T.eq(info.master, nil, "GetMaster -1 maps to nil")
    T.eq(info.tenure, 0)
    T.eq(#info.vassals, 0)
end

-- observerViewPlayer repoints the read-only tech view in a CP-only observer
-- session. The three branches each carry a distinct silent-value failure mode.
function M.test_vp_observer_view_player_uses_ui_override()
    local vp, env = loadVPWithFork()
    env.Game.GetActivePlayer = function()
        return 7
    end
    env.Game.GetObserverUIOverridePlayer = function()
        return 3
    end
    env.Players = { [7] = {
        IsObserver = function()
            return true
        end,
    } }
    T.eq(vp.observerViewPlayer(), 3, "observer view repoints to the UI-override player")
end

function M.test_vp_observer_view_player_nil_when_not_observer()
    local vp, env = loadVPWithFork()
    env.Game.GetActivePlayer = function()
        return 7
    end
    env.Game.GetObserverUIOverridePlayer = function()
        error("must not query the override for a real active player")
    end
    env.Players = { [7] = {
        IsObserver = function()
            return false
        end,
    } }
    T.eq(vp.observerViewPlayer(), nil, "a real active player needs no repoint")
end

function M.test_vp_observer_view_player_nil_in_auto_cycle()
    local vp, env = loadVPWithFork()
    env.Game.GetActivePlayer = function()
        return 7
    end
    env.Game.GetObserverUIOverridePlayer = function()
        return -1
    end
    env.Players = { [7] = {
        IsObserver = function()
            return true
        end,
    } }
    T.eq(vp.observerViewPlayer(), nil, "auto-cycle observer (override -1) has no stateless shown player")
end

-- Domination credit is the canonical control metric: VP redirects a vassal's
-- or city-state ally's capital to the master/ally, vanilla credits the
-- current owner. A wrong getter mis-attributes who is winning the game.
function M.test_vp_domination_controller_uses_redirect_getter()
    local vp = loadVPWithFork()
    local city = {
        GetOwnerForDominationVictory = function()
            return 5
        end,
        GetOwner = function()
            error("VP must use the domination-redirect getter")
        end,
    }
    T.eq(vp.dominationController(city), 5)
    local vanilla = loadSeam(VANILLA_PATH)
    T.eq(
        vanilla.dominationController({
            GetOwner = function()
                return 2
            end,
        }),
        2,
        "vanilla credits the current owner"
    )
end

-- Embassy ownership: an embassy in city-state land belongs to the major civ
-- that built it, not the city-state plot owner. The builder field is only
-- meaningful when the improvement is an embassy, so a non-embassy plot must
-- return nil (else the consumer would tag every citadel / fort with a builder
-- suffix). Vanilla has no embassies, so its body returns nil unconditionally.
function M.test_vp_embassy_owner_returns_builder_when_embassy()
    local vp = loadSeam(VP_PATH)
    local plot = {
        IsImprovementEmbassy = function()
            return true
        end,
        GetPlayerThatBuiltImprovement = function()
            return 4
        end,
    }
    T.eq(vp.embassyOwner(plot), 4)
end

function M.test_vp_embassy_owner_nil_when_not_embassy()
    local vp = loadSeam(VP_PATH)
    local plot = {
        IsImprovementEmbassy = function()
            return false
        end,
        GetPlayerThatBuiltImprovement = function()
            error("must not read the builder when the improvement is not an embassy")
        end,
    }
    T.eq(vp.embassyOwner(plot), nil)
end

function M.test_vanilla_embassy_owner_always_nil()
    local vanilla = loadSeam(VANILLA_PATH)
    T.eq(vanilla.embassyOwner({}), nil, "vanilla has no embassies")
end

-- War score: VP reads GetWarScore from `player`'s perspective toward
-- `otherPlayerId` (positive when player is winning) so the foreign-relations
-- "at war with" line can fill VP's two-argument TXT_KEY_AT_WAR_WITH. The
-- perspective (player asks about otherPlayerId, not the reverse) is the
-- silent-failure risk -- a swapped pair would speak the wrong side's score.
-- Vanilla's key takes only the enemy name, so its body returns nil and the
-- caller passes no score.
function M.test_vp_war_score_reads_from_player_perspective()
    local vp = loadSeam(VP_PATH)
    local seen = {}
    local player = {
        GetWarScore = function(_self, otherId)
            seen.otherId = otherId
            return 37
        end,
    }
    T.eq(vp.warScore(player, 3), 37)
    T.eq(seen.otherId, 3, "VP must query the score against the passed other player")
end

function M.test_vanilla_war_score_always_nil()
    local vanilla = loadSeam(VANILLA_PATH)
    T.eq(vanilla.warScore({}, 3), nil, "vanilla has no war-score concept")
end

-- The vanilla body has no vassalage system, so it returns the empty model
-- regardless of the team handle; every consumer's vassalage branch is inert.
function M.test_vanilla_vassal_info_is_empty()
    local vanilla = loadSeam(VANILLA_PATH)
    local info = vanilla.vassalInfo({})
    T.falsy(info.isVassal)
    T.eq(info.master, nil)
    T.eq(info.tenure, 0)
    T.eq(info.numVassals, 0)
    T.eq(#info.vassals, 0)
end

-- Historic Events is a VP-only screen, so the vanilla seam reports no support
-- and returns nil -- the wrapper never builds the tab on vanilla.
function M.test_vanilla_historic_events_unsupported()
    local vanilla = loadSeam(VANILLA_PATH)
    T.eq(vanilla.supportsHistoricEvents(), false)
    T.eq(vanilla.historicEvents({}), nil)
end

-- The VP body mirrors RefreshHistoricEvents: an event-category row for each
-- HistoricEventType with positive tourism (zero-tourism categories dropped),
-- and the two trade pseudo-types fanned out to one row per active trade route
-- whose destination is a met major, keyed on the origin city. Culture and
-- tourism per turn floor their times-100 getters.
function M.test_vp_historic_events_builds_event_and_trade_rows()
    local vp, env = loadVPWithFork()
    env.DomainTypes = { DOMAIN_LAND = 0, DOMAIN_SEA = 1 }
    env.GameInfo = {
        HistoricEventTypes = function()
            local rows = {
                { ID = 1, Type = "HISTORIC_EVENT_WONDER" },
                { ID = 2, Type = "HISTORIC_EVENT_GOLDEN_AGE" },
                { ID = 3, Type = "HISTORIC_EVENT_TRADE_LAND" },
                { ID = 4, Type = "HISTORIC_EVENT_TRADE_SEA" },
            }
            local i = 0
            return function()
                i = i + 1
                return rows[i]
            end
        end,
    }
    -- ToID 1 and 2 are met majors; 3 is a minor (its routes are dropped).
    env.Players = {
        [0] = {
            IsMinorCiv = function()
                return false
            end,
        },
        [1] = {
            IsMinorCiv = function()
                return false
            end,
        },
        [2] = {
            IsMinorCiv = function()
                return false
            end,
        },
        [3] = {
            IsMinorCiv = function()
                return true
            end,
        },
    }
    local fromCity = {
        GetName = function()
            return "Rome"
        end,
        GetID = function()
            return 100
        end,
    }
    local player = {
        GetNumHistoricEvents = function()
            return 9
        end,
        GetTotalJONSCulturePerTurnTimes100 = function()
            return 1234
        end,
        GetTourism = function()
            return 8888
        end,
        GetHistoricEventTourism = function(_, id, cityID)
            if id == 1 then
                return 50
            end -- wonder
            if id == 2 then
                return 0
            end -- golden age (dropped)
            if id == 3 then
                return cityID == 100 and 12 or 0
            end -- land trade
            if id == 4 then
                return cityID == 100 and 7 or 0
            end -- sea trade
            return 0
        end,
        GetTradeRoutes = function()
            return {
                { FromID = 0, ToID = 1, Domain = 0, FromCity = fromCity, ToCityName = "Berlin" },
                { FromID = 0, ToID = 2, Domain = 1, FromCity = fromCity, ToCityName = "Tokyo" },
                { FromID = 0, ToID = 3, Domain = 0, FromCity = fromCity, ToCityName = "Geneva" },
                { FromID = 0, ToID = 0, Domain = 0, FromCity = fromCity, ToCityName = "Rome" },
            }
        end,
    }
    local model = vp.historicEvents(player)
    T.eq(model.totalEvents, 9)
    T.eq(model.culturePerTurn, 12, "floor(1234/100)")
    T.eq(model.tourismPerTurn, 88, "floor(8888/100)")
    T.eq(#model.rows, 3, "wonder + one land route + one sea route; minor and self routes dropped")

    T.eq(model.rows[1].kind, "event")
    T.eq(model.rows[1].typeKey, "HISTORIC_EVENT_WONDER")
    T.eq(model.rows[1].tourism, 50)

    T.eq(model.rows[2].kind, "trade")
    T.eq(model.rows[2].domain, "land")
    T.eq(model.rows[2].fromCity, "Rome")
    T.eq(model.rows[2].toCity, "Berlin")
    T.eq(model.rows[2].tourism, 12)

    T.eq(model.rows[3].kind, "trade")
    T.eq(model.rows[3].domain, "sea")
    T.eq(model.rows[3].toCity, "Tokyo")
    T.eq(model.rows[3].tourism, 7)
end

function M.test_vp_has_line_of_sight_defeats_range_and_facing_gates()
    local vp, _env = loadVPWithFork()
    local seen
    local plot = {
        CanSeePlot = function(_, target, team, range, facing, seeThrough)
            seen = { target = target, team = team, range = range, facing = facing, seeThrough = seeThrough }
            return true
        end,
    }
    T.eq(vp.hasLineOfSight(plot, "target", 2), true)
    T.eq(seen.target, "target")
    T.eq(seen.team, 2)
    T.truthy(seen.range > 9000, "range must be generous enough to defeat the distance gate")
    T.eq(seen.facing, -1, "NO_DIRECTION short-circuits the facing gate")
    T.eq(seen.seeThrough, 0, "no attacker means no see-through")
end

-- VP gates ranged LoS on the attacker's see-through stat; the prefix must
-- pass it to canSeePlot or a see-through unit's strikeable tiles read as
-- "unseen". A nil attacker (city ranged strike) passes 0.
function M.test_vp_has_line_of_sight_passes_attacker_see_through()
    local vp, _env = loadVPWithFork()
    local seen
    local plot = {
        CanSeePlot = function(_, _target, _team, _range, _facing, seeThrough)
            seen = seeThrough
            return true
        end,
    }
    local attacker = {
        GetSeeThrough = function()
            return 2
        end,
    }
    vp.hasLineOfSight(plot, "target", 2, attacker)
    T.eq(seen, 2, "the attacker's see-through reaches canSeePlot")
end

function M.test_vp_building_investments_enabled_reads_custom_mod_option()
    local vp, env = loadSeam(VP_PATH)
    env.Game = {
        IsCustomModOption = function(name)
            return name == "BALANCE_BUILDING_INVESTMENTS"
        end,
    }
    T.eq(vp.buildingInvestmentsEnabled(), true, "VP reports building investments enabled")
end

function M.test_vp_building_invested_reads_investment_binding()
    local vp = loadSeam(VP_PATH)
    local city = {
        GetBuildingInvestment = function(_, id)
            -- VP returns the post-investment production needed (positive) once
            -- invested, 0 otherwise.
            return id == 7 and 120 or 0
        end,
    }
    T.eq(vp.buildingInvested(city, 7), true, "positive investment reads as invested")
    T.eq(vp.buildingInvested(city, 3), false, "zero investment reads as not invested")
end

return M
