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
        GeneratePath = function()
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
        GeneratePath = function(_, _plot, maxTurns)
            T.truthy(maxTurns ~= nil and maxTurns > 9000, "maxTurns must be effectively unlimited")
            return vpNodes()
        end,
    }
    local ok, turns = vp.generatePath(unit, "plot")
    T.truthy(ok)
    T.eq(turns, 2, "destination Turn 1 (0-based) must report as 2")
end

function M.test_vp_generate_path_reports_unreachable_on_empty_node_table()
    local vp, _env = loadVPWithFork()
    local unit = {
        GetID = function()
            return 7
        end,
        GeneratePath = function()
            return {}
        end,
    }
    T.falsy(vp.generatePath(unit, "plot"), "empty VP path table means unreachable")
end

function M.test_vp_get_path_reruns_last_generate_target()
    local vp, env = loadVPWithFork()
    installMapStub(env)
    local pathed = {}
    local unit = {
        GetID = function()
            return 7
        end,
        GetTeam = function()
            return 0
        end,
        GeneratePath = function(_, plot)
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
        GeneratePath = function()
            error("must not path without a prior generatePath target")
        end,
    }
    local nodes = vp.getPath(unit)
    T.eq(#nodes, 0)
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

function M.test_vp_melee_damage_dual_return_with_support_on_attacker()
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
    local toDefender, toAttacker = vp.meleeDamage(attacker, "defender", 500, 400, 9)
    T.eq(toDefender, 31)
    T.eq(toAttacker, 26, "support fire damage lands on the attacker's incoming total")
    T.eq(seen.strength, 500)
    T.eq(seen.opponentStrength, 400)
    T.eq(seen.includeRand, false, "previews must be deterministic")
    T.eq(seen.otherUnit, "defender")
    T.eq(seen.extraDefenderDamage, 0)
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

function M.test_vp_max_defense_strength_inserts_attacker_from_plot()
    local vp, _env = loadVPWithFork()
    local seen
    local defender = {
        GetMaxDefenseStrength = function(_, toPlot, attacker, fromPlot, fromRanged)
            seen = { toPlot = toPlot, attacker = attacker, fromPlot = fromPlot, fromRanged = fromRanged }
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

function M.test_vp_tourism_floors_times_100()
    local vp, _env = loadVPWithFork()
    local player = {
        GetTourism = function()
            return 1234
        end,
    }
    T.eq(vp.tourism(player), 12, "times-100 tourism must floor to the displayed rate")
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

function M.test_vp_has_line_of_sight_defeats_range_and_facing_gates()
    local vp, _env = loadVPWithFork()
    local seen
    local plot = {
        CanSeePlot = function(_, target, team, range, facing)
            seen = { target = target, team = team, range = range, facing = facing }
            return true
        end,
    }
    T.eq(vp.hasLineOfSight(plot, "target", 2), true)
    T.eq(seen.target, "target")
    T.eq(seen.team, 2)
    T.truthy(seen.range > 9000, "range must be generous enough to defeat the distance gate")
    T.eq(seen.facing, -1, "NO_DIRECTION short-circuits the facing gate")
end

return M
