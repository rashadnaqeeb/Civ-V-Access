-- The EngineData port: the single place the mod reads engine-sensitive
-- values and calls engine-extension (fork-added) bindings. The rest of the
-- mod reads the game directly; only the handful of points that actually
-- differ between engines route through here. This file is the VANILLA
-- (Brave New World) implementation -- every body is the call the mod made
-- inline before the port existed, so routing a call site through it changes
-- nothing on vanilla. A future engine adapter (e.g. Vox Populi) ships its
-- own CivVAccess_EngineData.lua in this file's place, with bodies that read
-- that engine's getters; the rest of the mod is unaffected because it only
-- ever sees these function names.
--
-- Two categories live here, added as call sites migrate onto the port:
--   * Drift reads -- getters whose VALUE or signature differs across
--     engines (combat damage, happiness, tourism, the trade resource
--     count). Plain passthroughs on vanilla.
--   * Extension bindings -- Lua methods the stock engine does not expose
--     and our C++ fork adds (mission queue, pathfinder, line of sight,
--     build-route finder). Gated on forkPresent() so a build without the
--     fork DLL degrades to a safe value and logs, instead of throwing a
--     method-not-found error that the engine swallows per listener and
--     silently kills the whole read.
--
-- No state is held here -- every function re-reads its handles, per the
-- never-cache rule. Published as civvaccess_shared.modules.EngineData so
-- Contexts other than InGame (Popups, CityView, WorldView) reach the same
-- implementation.

EngineData = {}

-- Is the engine fork DLL deployed? The fork registers several Game-level
-- bindings; if those resolve, the Unit / Plot fork bindings resolve too,
-- so the Game methods are the canary. A vanilla-DLL deploy (deploy.ps1
-- -SkipEngine, or a machine never deployed against) makes every extension
-- binding degrade rather than throw. This is the capability source the
-- Boot probe logs from and the binding wrappers gate on.
function EngineData.forkPresent()
    return Game ~= nil
        and Game.GetBuildRoutePath ~= nil
        and Game.GetCycleUnits ~= nil
        and Game.GetClosestSearchedPlot ~= nil
end

-- Drift read: bidirectional melee damage for a unit-vs-unit attack.
-- Returns (damage to defender, damage to attacker). Vanilla has no single
-- call for this, so it synthesizes both sides from two GetCombatDamage
-- calls, folding fire-support damage into the attacker's input and onto the
-- defender's output exactly as EnemyUnitPanel does. VP replaces this with a
-- single GetMeleeCombatDamage that returns both sides at once, which is why
-- the seam is shaped as "give me both numbers for this matchup" rather than
-- exposing GetCombatDamage directly.
function EngineData.meleeDamage(attacker, defender, attackStrength, defenseStrength, supportDamage)
    local toDefender = attacker:GetCombatDamage(
        attackStrength,
        defenseStrength,
        attacker:GetDamage() + supportDamage,
        false,
        false,
        false
    )
    local toAttacker = defender:GetCombatDamage(
        defenseStrength,
        attackStrength,
        defender:GetDamage(),
        false,
        false,
        false
    ) + supportDamage
    return toDefender, toAttacker
end

-- Drift read: bidirectional melee damage for a unit-vs-city attack. Returns
-- (damage to city, damage to attacker). Both numbers come from the
-- attacker's GetCombatDamage with the city flags set -- defender-is-city
-- for the outgoing hit, attacker-is-city for the city's counter, with the
-- city supplying its own current damage for the counter. VP collapses this
-- into GetMeleeCombatDamageCity.
function EngineData.cityMeleeDamage(attacker, city, attackStrength, cityStrength, supportDamage)
    local toCity =
        attacker:GetCombatDamage(attackStrength, cityStrength, attacker:GetDamage() + supportDamage, false, false, true)
    local toAttacker = attacker:GetCombatDamage(cityStrength, attackStrength, city:GetDamage(), false, true, false)
        + supportDamage
    return toCity, toAttacker
end

-- Drift read: a defender's maximum defense strength on a plot against an
-- attacker. VP inserted a from-plot parameter into the signature, so the
-- seam carries the attacker (whose plot the VP body passes); the vanilla
-- body ignores it. bFromRangedAttack distinguishes the melee caller (false)
-- from the ranged caller (true).
function EngineData.maxDefenseStrength(defender, toPlot, attacker, bFromRangedAttack)
    return defender:GetMaxDefenseStrength(toPlot, attacker, bFromRangedAttack)
end

-- Drift read: the defense modifier a plot grants a defender. VP inserted a
-- bIgnoreFeature parameter ahead of bHelp; the vanilla body uses the
-- three-argument form. bHelp=true is the tooltip variant (includes terrain
-- + feature + improvement components).
function EngineData.plotDefenseModifier(plot, attackerTeam, bIgnoreBuilding, bHelp)
    return plot:DefenseModifier(attackerTeam, bIgnoreBuilding, bHelp)
end

-- Drift read: the player's net happiness surplus. On vanilla this is a
-- signed integer (positive = happy, negative = unhappy). Consumers treat it
-- as a signed surplus: the H-key readout, the golden-age detail, the
-- Culture Overview cell, and the Demographics approval formula
-- (60 + excess*3).
--
-- KNOWN COARSENING CANDIDATE FOR VP. Routing this getter is necessary but
-- not sufficient on Vox Populi: VP redefines GetExcessHappiness as a 0-to-100
-- approval percentage where 50 is neutral, not a signed surplus, so every
-- consumer that interprets the number is wrong for VP no matter how clean
-- the getter call is. When VP is onboarded this seam must coarsen -- return
-- a model (the number plus whether it is an approval or a surplus, plus the
-- breakdown) and have the readouts format from that model. Deferred until VP
-- forces it; flagged here so the VP work does not rediscover it. The same
-- caveat applies to the unhappiness-component reads below, which VP zeroes
-- under its citizen-needs model.
function EngineData.excessHappiness(player)
    return player:GetExcessHappiness()
end

-- Drift read: happiness contributed by buildings. VP returns a hardcoded 0
-- (its happiness lives in the citizen-needs model), so this seam is where a
-- VP adapter would source the equivalent value.
function EngineData.happinessFromBuildings(player)
    return player:GetHappinessFromBuildings()
end

-- Drift read: happiness contributed by social policies. VP returns 0 (see
-- happinessFromBuildings).
function EngineData.happinessFromPolicies(player)
    return player:GetHappinessFromPolicies()
end

-- Drift read: unhappiness from the number of cities (engine times-100). VP
-- returns 0 under its citizen-needs guard.
function EngineData.unhappinessFromCityCount(player)
    return player:GetUnhappinessFromCityCount()
end

-- Drift read: unhappiness from captured cities (engine times-100). VP
-- returns 0.
function EngineData.unhappinessFromCapturedCityCount(player)
    return player:GetUnhappinessFromCapturedCityCount()
end

-- Drift read: unhappiness from city population (engine times-100). VP
-- returns 0.
function EngineData.unhappinessFromCityPopulation(player)
    return player:GetUnhappinessFromCityPopulation()
end

-- Drift read: a single city's unhappiness contribution for UI (engine
-- times-100). A player method that takes the city. VP returns 0 under its
-- citizen-needs guard.
function EngineData.unhappinessFromCity(player, city)
    return player:GetUnhappinessFromCityForUI(city)
end

-- Drift read: the player's tourism output per turn. VP returns a times-100
-- value where vanilla returns the plain rate, so a VP adapter divides by
-- 100 here and every consumer keeps reading a plain rate.
function EngineData.tourism(player)
    return player:GetTourism()
end

-- Drift read: a city's base tourism (engine times-100 on both engines; the
-- consumer divides). VP shares the times-100 convention, so this is a plain
-- passthrough; it lives here because it is on the same drift surface as the
-- player-level tourism getter.
function EngineData.baseTourism(city)
    return city:GetBaseTourism()
end

-- Drift read: how many of a resource a player can put into a deal. VP does
-- not register Deal:GetNumResource, so on VP the bare call throws and the
-- trade Available drawer's resource sub-group silently vanishes. A VP
-- adapter sources the count from Players[playerId]:GetNumResourceAvailable(
-- resType, true) instead -- the same call the offering drawer already makes
-- for the player-side stock. The vanilla body keeps the deal-scoped getter.
function EngineData.dealResourceCount(deal, playerId, resType)
    return deal:GetNumResource(playerId, resType)
end

-- Drift read: the engine's pick for the unit that would defend a plot
-- (CvPlot::getBestDefender) -- the same pick combat resolution uses.
-- Options are named because the positional signature drifts: VP inserts a
-- pIgnoreUnit parameter and repurposes the potential-enemy slot as
-- bIgnoreVisibility, so a positional vanilla call would silently return
-- wrong defenders there. opts:
--   testAtWar          only at-war (or barbarian) defenders count
--   testPotentialEnemy widen the war test to would-be-at-war rivals. On
--                      this engine the gate bottoms out in the Firaxis
--                      isPotentialEnemy stub (always false), so true
--                      drops every defender; the caller that sets it
--                      wants that exact engine behavior preserved
--   noncombatAllowed   civilians count as defenders (engine-fork 7th
--                      arg; a stock DLL ignores it and misses civilians)
-- Every mod call site leaves the unit-owner filter off (-1) and
-- bTestCanMove off, so neither crosses the seam. attacker may be nil.
function EngineData.bestDefender(plot, attackingPlayer, attacker, opts)
    return plot:GetBestDefender(
        -1,
        attackingPlayer,
        attacker,
        opts.testAtWar and 1 or 0,
        opts.testPotentialEnemy and 1 or 0,
        0,
        opts.noncombatAllowed and 1 or 0
    )
end

-- Pathfinder intents: the seam vocabulary for path relaxations. Callers
-- pass named intents ({ declareWar = true }, ...) and the translation to
-- this engine's flag bits happens here, so no engine bit mask crosses
-- the seam in either direction. The values mirror CvDefines.h's
-- PATHFINDER FLAGS plus the fork's force-dest-valid extension
-- (CvAStar.h); keep in sync with those.
local MOVE_INTENT_BITS = {
    noEnemyTerritory = 0x00000002, -- refuse steps through at-war territory
    ignoreStacking = 0x00000004, -- own same-type unit may block
    ignoreDanger = 0x00000008, -- path through endangered plots (automation moves)
    throughEnemy = 0x00000010, -- ignore at-war foreign units in path
    declareWar = 0x00000020, -- allow steps that would declare war
    maximizeExplore = 0x00000080, -- bias the route toward unrevealed tiles
    forceDestValid = 0x20000000, -- fork: accept any destination (exploration search)
}

-- Intents table -> engine flag bits. A misspelled intent name would
-- otherwise run a strict search under the guise of a relaxation, so an
-- unknown name crashes (and reaches Lua.log) instead.
local function bitsFromIntents(intents)
    local bits = 0
    for name, on in pairs(intents) do
        local bit = MOVE_INTENT_BITS[name]
        if bit == nil then
            error("EngineData: unknown path intent '" .. tostring(name) .. "'")
        end
        if on then
            bits = bits + bit
        end
    end
    return bits
end

-- Engine mission-flags value -> intents table. The vocabulary covers
-- every flag the engine stores on an active player's queued missions:
-- manual orders push flags 0 (CvGame::selectionListMove and every other
-- UI sender), and CvHomelandAI moves automated units with ignoreDanger /
-- noEnemyTerritory / maximizeExplore. Dropping a stored flag here would
-- make the waypoint re-pricing diverge from the engine's actual plan --
-- ignoreDanger in particular gates PathValid for automated units, so
-- losing it turns a legal queued leg into "no path" and silently drops
-- it from speech.
local function intentsFromMoveFlags(flags)
    local intents = {}
    for name, bit in pairs(MOVE_INTENT_BITS) do
        if flags % (bit * 2) >= bit then
            intents[name] = true
        end
    end
    return intents
end

-- Extension binding: Unit:GetMissionQueue (the unit's queued missions).
-- Entries carry mission / data1 / data2 / pushTurn straight from the
-- engine, plus intents -- the entry's movement flags decoded into the
-- pathfinder-intent vocabulary (the raw engine bit mask does not leave
-- the seam). Absent on a non-fork DLL, where a bare call throws a
-- method-not-found error the engine swallows per listener -- which is
-- what silenced the whole tile read on a stock engine. Degrades to an
-- empty queue so callers measuring #queue see "no queued missions" and
-- keep going.
function EngineData.missionQueue(unit)
    if not EngineData.forkPresent() then
        Log.warn("EngineData.missionQueue: engine fork absent, returning empty queue")
        return {}
    end
    local queue = unit:GetMissionQueue()
    local out = {}
    for i, entry in ipairs(queue) do
        out[i] = {
            mission = entry.mission,
            data1 = entry.data1,
            data2 = entry.data2,
            pushTurn = entry.pushTurn,
            intents = intentsFromMoveFlags(entry.flags),
        }
    end
    return out
end

-- Extension binding: Unit:GeneratePath(plot [, flags]) -- runs the engine
-- pathfinder, returning (ok, pathTurns). intents is an optional table of
-- named path relaxations. Degrades to false so callers reading the
-- boolean treat the target as unreachable.
function EngineData.generatePath(unit, plot, intents)
    if not EngineData.forkPresent() then
        Log.warn("EngineData.generatePath: engine fork absent")
        return false
    end
    if intents ~= nil then
        return unit:GeneratePath(plot, bitsFromIntents(intents))
    end
    return unit:GeneratePath(plot)
end

-- Extension binding: Unit:GetPath() -- the node array of the last path the
-- pathfinder generated. Node fields (x, y, moves, turn) are part of this
-- seam: an engine whose binding names them differently remaps here so
-- callers keep reading our canonical fields. Degrades to an empty array.
function EngineData.getPath(unit)
    if not EngineData.forkPresent() then
        Log.warn("EngineData.getPath: engine fork absent")
        return {}
    end
    return unit:GetPath()
end

-- Extension binding: Unit:ComputePath(fromPlot, toPlot, flags, freshTurn) --
-- a one-shot path between two plots, returning (nodes, success, legTurns).
-- intents is an optional table of named path relaxations (a queued
-- mission entry's decoded intents thread back through here). Folds the
-- pcall WaypointsCore used to guard the stock-DLL case; the caller's
-- `not success` branch falls back to the move dialect. freshTurn seeds
-- the start node with the unit's full move allowance instead of its
-- current movesLeft, for pricing a leg that begins at a future waypoint.
function EngineData.computePath(unit, fromPlot, toPlot, intents, freshTurn)
    if not EngineData.forkPresent() then
        Log.warn("EngineData.computePath: engine fork absent")
        return nil, false, nil
    end
    local flags = 0
    if intents ~= nil then
        flags = bitsFromIntents(intents)
    end
    return unit:ComputePath(fromPlot, toPlot, flags, freshTurn)
end

-- Extension binding: Unit:GetBestBuildRoute(plot) -- the best route the
-- worker can build on a plot, returning (routeId, buildId). Degrades to the
-- engine's no-route sentinel (-1, -1) so callers gating on routeId >= 0
-- treat the plot as un-routeable.
function EngineData.bestBuildRoute(unit, plot)
    if not EngineData.forkPresent() then
        Log.warn("EngineData.bestBuildRoute: engine fork absent")
        return -1, -1
    end
    return unit:GetBestBuildRoute(plot)
end

-- Extension binding: Game.GetBuildRoutePath(fx, fy, tx, ty, owner) -- the
-- build-route finder's plot list between two tiles. Degrades to an empty
-- array so callers reading #path see no route.
function EngineData.buildRoutePath(fx, fy, tx, ty, owner)
    if not EngineData.forkPresent() then
        Log.warn("EngineData.buildRoutePath: engine fork absent")
        return {}
    end
    return Game.GetBuildRoutePath(fx, fy, tx, ty, owner)
end

-- Extension binding: Game.GetClosestSearchedPlot(tx, ty) -- after a
-- force-valid exploration search, the closest reached tile to the target,
-- returning (x, y, distance). Degrades to nil.
function EngineData.closestSearchedPlot(tx, ty)
    if not EngineData.forkPresent() then
        Log.warn("EngineData.closestSearchedPlot: engine fork absent")
        return nil
    end
    return Game.GetClosestSearchedPlot(tx, ty)
end

-- Extension binding: Plot:HasLineOfSight(targetPlot, team) -- whether the
-- terrain visibility ray is unblocked. Degrades to true: when the check
-- can't run, do not impose a false "no line of sight" constraint.
function EngineData.hasLineOfSight(plot, targetPlot, team)
    if not EngineData.forkPresent() then
        Log.warn("EngineData.hasLineOfSight: engine fork absent")
        return true
    end
    return plot:HasLineOfSight(targetPlot, team)
end

-- Extension binding: whether the unit could enter the target plot as a
-- destination -- by plain move or by attacking what's there -- declaring
-- war if that's what entry takes (CvUnit::canMoveOrAttackInto with the
-- declare-war and destination move flags). The binding exists on a stock
-- DLL but Firaxis discards its result, so a bare call reads false for
-- every plot; only the fork returns the real answer. Degrades to true,
-- per the hasLineOfSight rule: when the check can't run, never impose a
-- false "can't attack" constraint.
function EngineData.canMoveOrAttackInto(unit, targetPlot)
    if not EngineData.forkPresent() then
        Log.warn("EngineData.canMoveOrAttackInto: engine fork absent")
        return true
    end
    return unit:CanMoveOrAttackInto(targetPlot, 1, 1)
end

-- Extension binding: Game.GetCycleUnits() -- the engine unit cycler's
-- active-player unit-ID list (CvPlayer::GetUnitCycler) without the
-- ReadyToSelect filter. Degrades to an empty list, which the Ctrl+. /
-- Ctrl+, walk speaks as "no units".
function EngineData.cycleUnits()
    if not EngineData.forkPresent() then
        Log.warn("EngineData.cycleUnits: engine fork absent, returning empty list")
        return {}
    end
    return Game.GetCycleUnits()
end

-- Extension binding: the League member-detail strings for one member as
-- seen by an observer -- League:GetMemberDelegationDetails /
-- GetMemberKnowledgeDetails / GetMemberVoteOpinionDetails. Returns
-- (delegation, knowledge, voteOpinion), each an engine-built localized
-- breakdown string, empty when the engine has nothing to report.
-- Degrades to three empty strings, which the League overview drill
-- already skips as empty sections.
function EngineData.leagueMemberDetails(league, memberId, observerId)
    if not EngineData.forkPresent() then
        Log.warn("EngineData.leagueMemberDetails: engine fork absent")
        return "", "", ""
    end
    return league:GetMemberDelegationDetails(memberId, observerId),
        league:GetMemberKnowledgeDetails(memberId, observerId),
        league:GetMemberVoteOpinionDetails(memberId, observerId)
end
