-- EngineData port tests. Most drift reads are covered where they are
-- consumed (combat in the unit-speech suite, happiness in the empire-status
-- suite, and so on); this suite owns the behavior unique to the port
-- itself: graceful degradation of fork-added bindings when the engine fork
-- DLL is absent, the case that silenced the tile read on a stock engine. It
-- also covers the trade resource-count drift read directly, since the trade
-- Available drawer has no consumer suite to exercise it through.

local T = require("support")
local M = {}

-- Run fn with the global Game shaped so EngineData.forkPresent() reports
-- the fork present or absent, restoring Game afterward even on failure.
local function withFork(present, fn)
    local savedGame = Game
    if present then
        Game = {
            GetBuildRoutePath = function() end,
            GetCycleUnits = function() end,
            GetClosestSearchedPlot = function() end,
        }
    else
        Game = {}
    end
    local ok, err = pcall(fn)
    Game = savedGame
    if not ok then
        error(err, 0)
    end
end

-- Mission-queue entries cross the seam with the engine's movement flags
-- decoded into the named-intent vocabulary; the raw bit mask must not
-- leak. 0x24 is declare-war (0x20) plus ignore-stacking (0x04).
function M.test_mission_queue_decodes_flags_into_intents()
    withFork(true, function()
        local unit = {
            GetMissionQueue = function()
                return {
                    { mission = 1, data1 = 3, data2 = 4, flags = 0x24, pushTurn = 7 },
                    { mission = 2, data1 = 0, data2 = 0, flags = 0, pushTurn = 8 },
                    -- The automation flag set CvHomelandAI pushes for an
                    -- automated explorer: noEnemyTerritory (0x02) +
                    -- ignoreDanger (0x08) + maximizeExplore (0x80).
                    { mission = 1, data1 = 5, data2 = 6, flags = 0x8A, pushTurn = 9 },
                }
            end,
        }
        local queue = EngineData.missionQueue(unit)
        T.eq(#queue, 3)
        T.eq(queue[1].mission, 1)
        T.eq(queue[1].data1, 3)
        T.eq(queue[1].data2, 4)
        T.eq(queue[1].pushTurn, 7)
        T.truthy(queue[1].intents.declareWar, "0x20 must decode to declareWar")
        T.truthy(queue[1].intents.ignoreStacking, "0x04 must decode to ignoreStacking")
        T.falsy(queue[1].intents.throughEnemy, "unset bit must not decode")
        T.eq(queue[1].flags, nil, "raw engine flags must not cross the seam")
        T.eq(next(queue[2].intents), nil, "flags 0 must decode to empty intents")
        T.truthy(queue[3].intents.noEnemyTerritory, "0x02 must decode to noEnemyTerritory")
        T.truthy(queue[3].intents.ignoreDanger, "0x08 must decode to ignoreDanger")
        T.truthy(queue[3].intents.maximizeExplore, "0x80 must decode to maximizeExplore")
        T.falsy(queue[3].intents.declareWar, "unset bit must not decode")
    end)
end

-- Round trip: an automated unit's decoded mission intents re-encode to
-- the exact bits the engine stored, so the waypoint re-pricing runs the
-- pathfinder with the same flags the engine's own plan used. Losing a
-- bit here makes the spoken path diverge from the unit's real route
-- (ignoreDanger loss turns legal legs into "no path").
function M.test_mission_intents_round_trip_through_compute_path()
    withFork(true, function()
        local unit = {
            GetMissionQueue = function()
                return { { mission = 1, data1 = 5, data2 = 6, flags = 0x8A, pushTurn = 9 } }
            end,
            ComputePath = function(_, _from, _to, flags, _fresh)
                return { flags }, true, 1
            end,
        }
        local queue = EngineData.missionQueue(unit)
        local nodes = EngineData.computePath(unit, "a", "b", queue[1].intents, false)
        T.eq(nodes[1], 0x8A, "decoded intents must re-encode to the stored engine bits")
    end)
end

function M.test_mission_queue_degrades_to_empty_when_fork_absent()
    withFork(false, function()
        local savedWarn = Log.warn
        local warned = false
        Log.warn = function()
            warned = true
        end
        local unit = {
            GetMissionQueue = function()
                error("binding must not be called when the fork is absent")
            end,
        }
        local ok, result = pcall(EngineData.missionQueue, unit)
        Log.warn = savedWarn
        T.truthy(ok, "absent fork must not throw: " .. tostring(result))
        T.eq(#result, 0)
        T.truthy(warned, "absent fork must log a warning")
    end)
end

-- The pathfinder seams translate named intents to this engine's flag
-- bits. Pins the bit values (a wrong bit silently runs the wrong
-- relaxation, the silent-value class) and the no-intents form, which
-- must omit the flags argument entirely so the binding's default
-- applies.
function M.test_generate_path_translates_intents_to_engine_bits()
    withFork(true, function()
        local calls = {}
        local unit = {
            GeneratePath = function(_, _plot, flags)
                calls[#calls + 1] = { flags = flags, argCount = flags ~= nil and 2 or 1 }
                return true
            end,
        }
        EngineData.generatePath(unit, "plot")
        EngineData.generatePath(unit, "plot", { declareWar = true })
        EngineData.generatePath(unit, "plot", { ignoreStacking = true, throughEnemy = true })
        EngineData.generatePath(unit, "plot", { forceDestValid = true })
        T.eq(calls[1].flags, nil, "no intents must omit the flags argument")
        T.eq(calls[2].flags, 0x20, "declareWar bit")
        T.eq(calls[3].flags, 0x14, "ignoreStacking + throughEnemy bits")
        T.eq(calls[4].flags, 0x20000000, "forceDestValid bit")
    end)
end

-- A misspelled intent name would silently run a strict search where the
-- caller asked for a relaxation; the seam must crash instead.
function M.test_generate_path_rejects_unknown_intent_names()
    withFork(true, function()
        local unit = {
            GeneratePath = function()
                error("binding must not be called for an unknown intent")
            end,
        }
        local ok, err = pcall(EngineData.generatePath, unit, "plot", { declareWarr = true })
        T.falsy(ok, "unknown intent must raise")
        T.truthy(tostring(err):find("declareWarr", 1, true), "error must name the bad intent")
    end)
end

function M.test_compute_path_translates_intents_with_zero_default()
    withFork(true, function()
        local seenFlags, seenFresh
        local unit = {
            ComputePath = function(_, _from, _to, flags, freshTurn)
                seenFlags, seenFresh = flags, freshTurn
                return {}, true, 1
            end,
        }
        EngineData.computePath(unit, "a", "b", nil, true)
        T.eq(seenFlags, 0, "nil intents must become flags 0")
        T.eq(seenFresh, true)
        EngineData.computePath(unit, "a", "b", { declareWar = true }, false)
        T.eq(seenFlags, 0x20, "declareWar bit")
        T.eq(seenFresh, false)
    end)
end

-- bestDefender translates named options into the engine's positional
-- booleans. Pins every position: a swapped or shifted argument returns a
-- plausible-but-wrong defender with nothing crashing -- exactly the
-- silent-value drift the seam exists to prevent.
function M.test_best_defender_translates_named_options_positionally()
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
    local got = EngineData.bestDefender(plot, 3, "actor", { testAtWar = true, noncombatAllowed = true })
    T.eq(got, "defender")
    T.eq(seen.owner, -1, "owner filter stays off")
    T.eq(seen.attackingPlayer, 3)
    T.eq(seen.attacker, "actor")
    T.eq(seen.atWar, 1)
    T.eq(seen.potentialEnemy, 0)
    T.eq(seen.canMove, 0, "bTestCanMove stays off")
    T.eq(seen.noncombat, 1)
    EngineData.bestDefender(plot, 5, nil, { testPotentialEnemy = true })
    T.eq(seen.atWar, 0)
    T.eq(seen.potentialEnemy, 1)
    T.eq(seen.noncombat, 0)
end

function M.test_can_move_or_attack_into_passes_declare_war_and_destination()
    withFork(true, function()
        local seen
        local unit = {
            CanMoveOrAttackInto = function(_, plot, declareWar, destination)
                seen = { plot = plot, declareWar = declareWar, destination = destination }
                return false
            end,
        }
        T.eq(EngineData.canMoveOrAttackInto(unit, "plot"), false)
        T.eq(seen.plot, "plot")
        T.eq(seen.declareWar, 1)
        T.eq(seen.destination, 1)
    end)
end

-- Degrade rule: never impose a false "can't attack" constraint when the
-- gate can't run (stock DLLs discard the binding's result).
function M.test_can_move_or_attack_into_degrades_to_allow_when_fork_absent()
    withFork(false, function()
        local savedWarn = Log.warn
        local warned = false
        Log.warn = function()
            warned = true
        end
        local unit = {
            CanMoveOrAttackInto = function()
                error("binding must not be called when the fork is absent")
            end,
        }
        local ok, result = pcall(EngineData.canMoveOrAttackInto, unit, "plot")
        Log.warn = savedWarn
        T.truthy(ok, "absent fork must not throw: " .. tostring(result))
        T.eq(result, true, "absent fork must degrade to allow")
        T.truthy(warned, "absent fork must log a warning")
    end)
end

function M.test_cycle_units_degrades_to_empty_list_when_fork_absent()
    withFork(false, function()
        local savedWarn = Log.warn
        local warned = false
        Log.warn = function()
            warned = true
        end
        local ok, result = pcall(EngineData.cycleUnits)
        Log.warn = savedWarn
        T.truthy(ok, "absent fork must not throw: " .. tostring(result))
        T.eq(#result, 0)
        T.truthy(warned, "absent fork must log a warning")
    end)
end

function M.test_cycle_units_passes_through_when_fork_present()
    withFork(true, function()
        Game.GetCycleUnits = function()
            return { 11, 12 }
        end
        T.eq(#EngineData.cycleUnits(), 2)
    end)
end

-- The three member-detail strings come back in a fixed order; a swap
-- would speak the knowledge breakdown as the delegation line.
function M.test_league_member_details_returns_sections_in_order()
    withFork(true, function()
        local league = {
            GetMemberDelegationDetails = function(_, member, observer)
                return "D" .. member .. ":" .. observer
            end,
            GetMemberKnowledgeDetails = function(_, member, observer)
                return "K" .. member .. ":" .. observer
            end,
            GetMemberVoteOpinionDetails = function(_, member, observer)
                return "V" .. member .. ":" .. observer
            end,
        }
        local delegation, knowledge, voteOpinion = EngineData.leagueMemberDetails(league, 2, 0)
        T.eq(delegation, "D2:0")
        T.eq(knowledge, "K2:0")
        T.eq(voteOpinion, "V2:0")
    end)
end

function M.test_league_member_details_degrades_to_empty_strings_when_fork_absent()
    withFork(false, function()
        local savedWarn = Log.warn
        local warned = false
        Log.warn = function()
            warned = true
        end
        local league = {
            GetMemberDelegationDetails = function()
                error("binding must not be called when the fork is absent")
            end,
        }
        local ok, delegation, knowledge, voteOpinion = pcall(EngineData.leagueMemberDetails, league, 2, 0)
        Log.warn = savedWarn
        T.truthy(ok, "absent fork must not throw: " .. tostring(delegation))
        T.eq(delegation, "")
        T.eq(knowledge, "")
        T.eq(voteOpinion, "")
        T.truthy(warned, "absent fork must log a warning")
    end)
end

-- Trade resource count: the vanilla body is a deal-scoped getter taking
-- (playerId, resourceType). Pins the argument order and pass-through so a
-- regression that swaps player and resource (which would silently report
-- the wrong tradeable count) fails here.
function M.test_deal_resource_count_passes_player_and_resource_through()
    local seen
    local deal = {
        GetNumResource = function(_, playerId, resType)
            seen = { playerId = playerId, resType = resType }
            return 5
        end,
    }
    T.eq(EngineData.dealResourceCount(deal, 3, 7), 5)
    T.eq(seen.playerId, 3)
    T.eq(seen.resType, 7)
end

return M
