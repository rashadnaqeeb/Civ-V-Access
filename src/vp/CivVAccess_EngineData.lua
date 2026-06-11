-- The EngineData port: the single place the mod reads engine-sensitive
-- values and calls engine-extension (fork-added) bindings. This file is the
-- VOX POPULI implementation -- same function set and contracts as the
-- vanilla src/dlc/UI/InGame/CivVAccess_EngineData.lua (the parity suite
-- asserts the sets match), with bodies that read VP's getters. deploy-vp.ps1
-- ships this copy in place of the vanilla one; both share the include stem,
-- so call sites are identical and never know which engine they run on.
--
-- Engine facts the bodies below rely on, verified against the
-- Community-Patch-DLL clone at Release-5.3.1:
--   * GetCombatDamage is stubbed to 0 (CvLuaUnit.cpp:1185); the live calls
--     are GetMeleeCombatDamage / GetMeleeCombatDamageCity, dual-return.
--   * GetMaxDefenseStrength takes a from-plot at arg 3 (CvLuaUnit.cpp:3199);
--     Plot:DefenseModifier takes bIgnoreFeature at arg 3 (CvLuaPlot.cpp:809).
--   * Player:GetTourism is times-100 (VP's TopPanel floors /100).
--   * Deal:GetNumResource is unregistered; the count comes from
--     Player:GetNumResourceAvailable.
--   * The unit pathfinder is exposed as Unit:GeneratePath(plot, maxTurns) /
--     GetActivePath / GetWaypointPath / GeneratePathToNextWaypoint
--     (CvLuaUnit.cpp:772-943). Nodes are {X, Y, RemainingMovement, Turn,
--     Flags, Invisible, AdjInvisible}; Turn is 0-based (start node turns=0,
--     CvAStar.cpp NodeAddedToPath), where the vanilla convention this seam
--     speaks is 1-based (1 = arrives this turn) -- every conversion adds 1.
--     None of these bindings accept pathfinder flags, so path intents are
--     validated but cannot be applied (see generatePath).
--   * Plot:CanSeePlot(target, team, range, facingDirection) is the stock
--     line-of-sight surface (CvLuaPlot.cpp:2149); no fork binding needed.
--   * The mission-queue / build-route / cycler / league bindings are
--     fork-added under their vanilla names, so those bodies stay the
--     vanilla calls, still forkPresent-gated.
--
-- No state is held here beyond the last-pathed plot handle getPath needs
-- (see the comment there) -- every function re-reads its handles, per the
-- never-cache rule. Published as civvaccess_shared.modules.EngineData so
-- Contexts other than InGame (Popups, CityView, WorldView) reach the same
-- implementation.

EngineData = {}

-- Is the engine fork DLL deployed? The fork registers several Game-level
-- bindings; if those resolve, the Unit / Plot / League fork bindings
-- resolve too, so the Game methods are the canary. A stock-VP deploy (no
-- fork DLL) makes every extension binding degrade rather than throw. This
-- is the capability source the Boot probe logs from and the binding
-- wrappers gate on.
function EngineData.forkPresent()
    return Game ~= nil
        and Game.GetBuildRoutePath ~= nil
        and Game.GetCycleUnits ~= nil
        and Game.GetClosestSearchedPlot ~= nil
end

-- Drift read: bidirectional melee damage for a unit-vs-unit attack.
-- Returns (damage to defender, damage to attacker). VP's
-- GetMeleeCombatDamage(strength, opponentStrength, includeRand, otherUnit,
-- extraDefenderDamage) returns both sides in one call. supportDamage is
-- pre-resolved defensive fire support against the ATTACKER (vanilla
-- mechanic); VP disables that mechanic by default (FIRE_SUPPORT_DISABLED=1,
-- GetFireSupportUnit returns nil) so the caller's value is 0 in practice,
-- but a DB re-enable keeps this correct: it lands on the attacker's
-- incoming total, same as the vanilla body. The extraDefenderDamage slot
-- (damage already inflicted on the DEFENDER, used by VP's own preview for
-- attacker-side ranged support fire) stays 0 -- that mechanic is not
-- modeled by this seam's callers yet; see the port plan's phase 2 notes.
function EngineData.meleeDamage(attacker, defender, attackStrength, defenseStrength, supportDamage)
    local toDefender, toAttacker = attacker:GetMeleeCombatDamage(attackStrength, defenseStrength, false, defender, 0)
    return toDefender, toAttacker + supportDamage
end

-- Drift read: bidirectional melee damage for a unit-vs-city attack. Returns
-- (damage to city, damage to attacker). VP's GetMeleeCombatDamageCity reads
-- the city's own strength internally, so the seam's cityStrength argument
-- (which the caller still speaks as the city's combat strength) does not
-- cross into the call. supportDamage handling matches meleeDamage.
function EngineData.cityMeleeDamage(attacker, city, attackStrength, cityStrength, supportDamage)
    local toCity, toAttacker = attacker:GetMeleeCombatDamageCity(attackStrength, city, false)
    return toCity, toAttacker + supportDamage
end

-- Drift read: a defender's maximum defense strength on a plot against an
-- attacker. VP inserted a from-plot parameter at position 3; the attacker's
-- current plot is the from-plot for every caller (melee and ranged
-- previews both attack from where the attacker stands).
function EngineData.maxDefenseStrength(defender, toPlot, attacker, bFromRangedAttack)
    return defender:GetMaxDefenseStrength(toPlot, attacker, attacker:GetPlot(), bFromRangedAttack)
end

-- Drift read: the defense modifier a plot grants a defender. VP inserted
-- bIgnoreFeature at position 3 ahead of bHelp; passing false keeps feature
-- modifiers included, matching the vanilla three-argument call.
function EngineData.plotDefenseModifier(plot, attackerTeam, bIgnoreBuilding, bHelp)
    return plot:DefenseModifier(attackerTeam, bIgnoreBuilding, false, bHelp)
end

-- ===== Happiness reads: PRE-REBUILD PASSTHROUGHS =====
-- VP guts the vanilla happiness surface: GetExcessHappiness is a 0-100
-- approval percentage (not a signed surplus), and the per-source getters
-- below return hardcoded 0 under MOD_BALANCE_VP (CvPlayer.cpp:20590-22146).
-- These passthroughs return what VP's engine actually answers, which is NOT
-- what the vanilla-shaped consumers (H-key readout, Economic Overview
-- happiness tab, golden-age detail, Culture Overview / Demographics
-- approval) were written to speak. The empire-happiness presentation
-- rebuild -- a pending design session in the VP port plan -- replaces both
-- these seams and their consumers against VP's citizen-needs surface.
-- Until then no VP deploy ships speech from these readouts; the parity
-- suite keeps the function set aligned in the meantime.

function EngineData.excessHappiness(player)
    return player:GetExcessHappiness()
end

function EngineData.happinessFromBuildings(player)
    return player:GetHappinessFromBuildings()
end

function EngineData.happinessFromPolicies(player)
    return player:GetHappinessFromPolicies()
end

function EngineData.unhappinessFromCityCount(player)
    return player:GetUnhappinessFromCityCount()
end

function EngineData.unhappinessFromCapturedCityCount(player)
    return player:GetUnhappinessFromCapturedCityCount()
end

function EngineData.unhappinessFromCityPopulation(player)
    return player:GetUnhappinessFromCityPopulation()
end

function EngineData.unhappinessFromCity(player, city)
    return player:GetUnhappinessFromCityForUI(city)
end

-- ===== End pre-rebuild passthroughs =====

-- Drift read: the player's tourism output per turn. VP's getter is
-- times-100; floor /100 mirrors VP's own TopPanel display
-- (FormatIntegerTimes100), so the spoken rate matches the screen.
function EngineData.tourism(player)
    return math.floor(player:GetTourism() / 100)
end

-- Drift read: a city's base tourism (engine times-100 on both engines; the
-- consumer divides). Plain passthrough, kept on the seam because it shares
-- the drift surface with the player-level getter.
function EngineData.baseTourism(city)
    return city:GetBaseTourism()
end

-- Drift read: how many of a resource a player can put into a deal. VP does
-- not register Deal:GetNumResource; the count comes from the player's
-- available stock instead (include-imports true, the same call the
-- offering drawer makes for the player-side stock). The deal handle stays
-- in the signature for the vanilla body's sake and is unused here.
function EngineData.dealResourceCount(deal, playerId, resType)
    return Players[playerId]:GetNumResourceAvailable(resType, true)
end

-- Drift read: the engine's pick for the unit that would defend a plot
-- (CvPlot::getBestDefender) -- the same pick combat resolution uses.
-- Options are named because the positional signature drifts; VP's binding
-- is (owner, attackingPlayer, attacker, bTestAtWar, bIgnoreVisibility,
-- bTestCanMove) -- the vanilla potential-enemy slot is repurposed as
-- bIgnoreVisibility, and VP's engine has no potential-enemy test at all.
-- opts:
--   testAtWar          only at-war (or barbarian) defenders count
--   testPotentialEnemy on vanilla this bottoms out in the Firaxis
--                      isPotentialEnemy stub (always false), dropping every
--                      defender, and the caller is tuned to exactly that;
--                      VP has no equivalent slot, so the contract is
--                      honored directly: no defender
--   noncombatAllowed   civilians count as defenders. Fork contract: the
--                      fork's binding takes bNoncombatAllowed as method
--                      arg 7 (the engine's getBestDefender already carries
--                      it; only the Lua surface lacks it). A stock VP DLL
--                      reads 6 args and ignores the extras -- civilians
--                      are missed, the same degradation as a stock vanilla
--                      DLL.
-- Every mod call site leaves the unit-owner filter off (-1) and
-- bTestCanMove off, so neither crosses the seam. attacker may be nil.
function EngineData.bestDefender(plot, attackingPlayer, attacker, opts)
    if opts.testPotentialEnemy then
        return nil
    end
    return plot:GetBestDefender(
        -1,
        attackingPlayer,
        attacker,
        opts.testAtWar and 1 or 0,
        0,
        0,
        opts.noncombatAllowed and 1 or 0
    )
end

-- Pathfinder intents: the seam vocabulary for path relaxations. Callers
-- pass named intents ({ declareWar = true }, ...) and the translation to
-- this engine's flag bits happens here, so no engine bit mask crosses the
-- seam in either direction. The values mirror VP's CvUnit.h MOVEFLAG
-- enum; keep in sync with it. A 0 entry is a name the seam vocabulary
-- carries but VP's pathfinder has no flag for:
--   declareWar      VP has no declare-war pathfinder flag (war legality is
--                   not a path concern there)
--   forceDestValid  the fork replaces the force-valid exploration search
--                   with the closest-reachable binding (GetPlotsInReach),
--                   so no flag exists or is needed
local MOVE_INTENT_BITS = {
    noEnemyTerritory = 0x0400, -- MOVEFLAG_NO_ENEMY_TERRITORY
    ignoreStacking = 0x0010, -- MOVEFLAG_IGNORE_STACKING_SELF
    ignoreDanger = 0x0100, -- MOVEFLAG_IGNORE_DANGER
    throughEnemy = 0x2000000, -- MOVEFLAG_IGNORE_ENEMIES
    maximizeExplore = 0x0800, -- MOVEFLAG_MAXIMIZE_EXPLORE
    declareWar = 0,
    forceDestValid = 0,
}

-- Intents table -> engine flag bits. A misspelled intent name would
-- otherwise run a strict search under the guise of a relaxation, so an
-- unknown name crashes (and reaches Lua.log) instead. VP's stock path
-- bindings accept no flags argument, so the bits are currently
-- validation-only (see generatePath / computePath); the translation stays
-- real so a future binding that does take flags gets correct values.
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

-- Engine mission-flags value -> intents table. Decodes the flags VP's
-- engine stores on queued missions into the same named vocabulary the
-- vanilla seam produces, so cross-seam consumers (queue signatures, leg
-- re-pricing) read identical shapes on both engines. Zero entries are
-- skipped: they have no bit to test (and flags % 0 is nan in Lua 5.1).
local function intentsFromMoveFlags(flags)
    local intents = {}
    for name, bit in pairs(MOVE_INTENT_BITS) do
        if bit ~= 0 and flags % (bit * 2) >= bit then
            intents[name] = true
        end
    end
    return intents
end

-- Logs (debug level) when a caller asked for path relaxations this
-- engine's bindings cannot apply. Not a warn: the limitation is a known,
-- accepted property of VP's stock pathfinder surface (the plan's phase 2
-- notes), and the discriminative-retry preview passes intents on every
-- failed path, so warn would drown real warnings. Returns nothing; the
-- value of the call is the name validation inside bitsFromIntents.
local function noteUnappliedIntents(scope, intents)
    if bitsFromIntents(intents) ~= 0 then
        Log.debug(scope .. ": VP path bindings take no flags; intents not applied")
    end
end

-- VP node array ({X, Y, RemainingMovement, Turn, ...}) -> the seam's
-- canonical node shape ({x, y, moves, turn, flags, revealed}). moves is in
-- MOVE_DENOMINATOR 60ths on both engines. turn converts from VP's 0-based
-- arrival turn to the seam's 1-based convention (1 = arrives this turn).
-- flags is 0 (VP's binding has no per-node flags; no consumer reads it).
-- revealed re-queries CvPlot:IsRevealed for the unit's team at conversion
-- time -- the same answer the pathfinder just used for its costs. VP's
-- Invisible field is NOT that answer (it is current visibility; a
-- revealed-but-fogged tile would wrongly read as unexplored and truncate
-- the spoken route).
local function convertNodes(unit, vpNodes)
    local team = unit:GetTeam()
    local debugMode = Game.IsDebugMode()
    local out = {}
    for i, n in ipairs(vpNodes) do
        out[i] = {
            x = n.X,
            y = n.Y,
            moves = n.RemainingMovement,
            turn = n.Turn + 1,
            flags = 0,
            revealed = Map.GetPlot(n.X, n.Y):IsRevealed(team, debugMode),
        }
    end
    return out
end

-- INT_MAX, the maxTurns VP's own GetActivePath passes its pathfinder; any
-- reachable plot is within it.
local UNLIMITED_TURNS = 2147483647

-- The (unit, plot) pair of the most recent generatePath call, so getPath
-- can re-run the same search -- VP has no "read back the cached path"
-- binding. This is a plot HANDLE plus a unit id, not copied game state:
-- getPath re-runs the pathfinder live on every call, so the answer is
-- always current (the vanilla engine's own m_kLastPath cache is what this
-- stands in for, and re-running is strictly fresher).
local lastGenerated = nil

-- Extension binding seam: runs the engine pathfinder from the unit's
-- position, returning (ok, pathTurns). On VP this is the stock
-- Unit:GeneratePath, no fork needed. intents are validated but cannot be
-- applied (no flags argument); note VP's binding hardcodes
-- MOVEFLAG_IGNORE_STACKING_SELF, so own-unit stacking never blocks a
-- preview path here.
function EngineData.generatePath(unit, plot, intents)
    if intents ~= nil then
        noteUnappliedIntents("EngineData.generatePath", intents)
    end
    lastGenerated = { unitID = unit:GetID(), plot = plot }
    local nodes = unit:GeneratePath(plot, UNLIMITED_TURNS)
    if #nodes == 0 then
        return false
    end
    return true, nodes[#nodes].Turn + 1
end

-- Extension binding seam: the node array of the last path generatePath
-- produced for this unit. VP cannot read a cached path back, so the body
-- re-runs the same search live (see lastGenerated). Empty array when no
-- prior generatePath matches the unit -- a contract misuse worth a log,
-- since the vanilla body would have returned the engine's cached nodes.
function EngineData.getPath(unit)
    if lastGenerated == nil or lastGenerated.unitID ~= unit:GetID() then
        Log.warn("EngineData.getPath: no prior generatePath for this unit")
        return {}
    end
    return convertNodes(unit, unit:GeneratePath(lastGenerated.plot, UNLIMITED_TURNS))
end

-- Splits GetWaypointPath's concatenated node array back into per-leg node
-- lists. Each queued leg's nodes start at the prior leg's destination, so
-- a consecutive duplicate coordinate marks a leg boundary. A leg the
-- pathfinder failed (zero nodes) leaves no boundary, merging its
-- neighbors into one unmatchable pseudo-leg -- the slice lookup then
-- reports failure for those legs, which is the safe direction.
local function waypointLegs(unit)
    local all = unit:GetWaypointPath()
    local legs = {}
    local current = {}
    for _, n in ipairs(all) do
        local prev = current[#current]
        if prev ~= nil and n.X == prev.X and n.Y == prev.Y then
            legs[#legs + 1] = current
            current = {}
        end
        current[#current + 1] = n
    end
    if #current > 0 then
        legs[#legs + 1] = current
    end
    return legs
end

-- Extension binding seam: a one-shot path between two plots, returning
-- (nodes, success, legTurns). VP has no arbitrary-endpoints binding, so
-- the body picks the stock surface that covers the caller's case:
--   * fromPlot is the unit's current plot -> GeneratePath (the head leg
--     of a queue walk, and any plain two-plot ask from the unit's tile).
--   * fromPlot is the queue's final destination -> GeneratePathToNextWaypoint
--     (the Shift+Enter append preview: last waypoint to the cursor; runs on
--     every cursor move, so it is checked before the full-queue slice
--     below). No queued leg can START at the final destination, so this
--     never shadows a slice match -- and for the one degenerate overlap (a
--     revisiting queue whose middle leg starts on the final plot) both
--     branches run the identical per-leg pathfinder.
--   * (fromPlot, toPlot) is a queued mission leg -> the matching slice of
--     GetWaypointPath. The whole queue re-paths per call, so walking an
--     n-leg queue costs n GetWaypointPath runs -- fine at real queue
--     sizes, noted in case a pathological queue ever shows up in profiling.
-- Anything else fails with a log; no stock binding paths between two
-- arbitrary off-unit plots. freshTurn cannot be honored -- VP prices every
-- leg from the unit's current moves (the plan's accepted loss; spoken turn
-- counts on later legs may run one high mid-turn). intents are validated
-- but cannot be applied.
function EngineData.computePath(unit, fromPlot, toPlot, intents, freshTurn)
    if intents ~= nil then
        noteUnappliedIntents("EngineData.computePath", intents)
    end
    local fx, fy = fromPlot:GetX(), fromPlot:GetY()
    if fx == unit:GetX() and fy == unit:GetY() then
        local nodes = unit:GeneratePath(toPlot, UNLIMITED_TURNS)
        if #nodes == 0 then
            return {}, false, 0
        end
        return convertNodes(unit, nodes), true, nodes[#nodes].Turn + 1
    end
    local lastMission = unit:LastMissionPlot()
    if lastMission ~= nil and lastMission:GetX() == fx and lastMission:GetY() == fy then
        local nodes = unit:GeneratePathToNextWaypoint(toPlot) or {}
        if #nodes == 0 then
            return {}, false, 0
        end
        return convertNodes(unit, nodes), true, nodes[#nodes].Turn + 1
    end
    local tx, ty = toPlot:GetX(), toPlot:GetY()
    for _, leg in ipairs(waypointLegs(unit)) do
        local first, last = leg[1], leg[#leg]
        if first.X == fx and first.Y == fy and last.X == tx and last.Y == ty then
            return convertNodes(unit, leg), true, last.Turn + 1
        end
    end
    Log.warn("EngineData.computePath: no VP binding paths from (" .. fx .. "," .. fy .. ") for this unit")
    return {}, false, 0
end

-- Extension binding: Unit:GetMissionQueue (the unit's queued missions),
-- fork-added under the vanilla name. Entries carry mission / data1 /
-- data2 / pushTurn straight from the engine, plus intents -- the entry's
-- movement flags decoded into the pathfinder-intent vocabulary (the raw
-- engine bit mask does not leave the seam). Degrades to an empty queue so
-- callers measuring #queue see "no queued missions" and keep going.
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

-- Extension binding: Unit:GetBestBuildRoute(plot), fork-added under the
-- vanilla name. Returns (routeId, buildId); degrades to the engine's
-- no-route sentinel (-1, -1) so callers gating on routeId >= 0 treat the
-- plot as un-routeable.
function EngineData.bestBuildRoute(unit, plot)
    if not EngineData.forkPresent() then
        Log.warn("EngineData.bestBuildRoute: engine fork absent")
        return -1, -1
    end
    return unit:GetBestBuildRoute(plot)
end

-- Extension binding: Game.GetBuildRoutePath(fx, fy, tx, ty, owner),
-- fork-added under the vanilla name. Degrades to an empty array so callers
-- reading #path see no route.
function EngineData.buildRoutePath(fx, fy, tx, ty, owner)
    if not EngineData.forkPresent() then
        Log.warn("EngineData.buildRoutePath: engine fork absent")
        return {}
    end
    return Game.GetBuildRoutePath(fx, fy, tx, ty, owner)
end

-- Extension binding: Game.GetClosestSearchedPlot(tx, ty), fork-added under
-- the vanilla name (on VP the fork wraps GetPlotsInReach rather than a
-- closed-list walk, same contract). After an exploration search, the
-- closest reachable tile to the target, returning (x, y, distance).
-- Degrades to nil.
function EngineData.closestSearchedPlot(tx, ty)
    if not EngineData.forkPresent() then
        Log.warn("EngineData.closestSearchedPlot: engine fork absent")
        return nil
    end
    return Game.GetClosestSearchedPlot(tx, ty)
end

-- Whether the terrain visibility ray between two plots is unblocked. On VP
-- this is pure Lua over the stock Plot:CanSeePlot -- a generous range
-- defeats its distance gate (the binding adds 1 internally;
-- CvLuaPlot.cpp:2149) and facing NO_DIRECTION (-1) short-circuits its
-- facing gate -- so it needs no fork and never degrades.
function EngineData.hasLineOfSight(plot, targetPlot, team)
    return plot:CanSeePlot(targetPlot, team, 10000, -1)
end

-- Extension binding: whether the unit could enter the target plot as a
-- destination -- by plain move or by attacking what's there -- declaring
-- war if that's what entry takes. VP's stock binding exists but its
-- declare-war argument is commented out, so a bare call answers without
-- war handling; the fork restores it (plus the pretend-correct-embark
-- extension) under the same call shape. Degrades to true: when the check
-- can't run, never impose a false "can't attack" constraint.
function EngineData.canMoveOrAttackInto(unit, targetPlot)
    if not EngineData.forkPresent() then
        Log.warn("EngineData.canMoveOrAttackInto: engine fork absent")
        return true
    end
    return unit:CanMoveOrAttackInto(targetPlot, 1, 1)
end

-- Extension binding: Game.GetCycleUnits(), fork-added under the vanilla
-- name -- the engine unit cycler's active-player unit-ID list without the
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
-- seen by an observer, fork-added under the vanilla names. Returns
-- (delegation, knowledge, voteOpinion), each an engine-built localized
-- breakdown string, empty when the engine has nothing to report. Degrades
-- to three empty strings, which the League overview drill already skips
-- as empty sections.
function EngineData.leagueMemberDetails(league, memberId, observerId)
    if not EngineData.forkPresent() then
        Log.warn("EngineData.leagueMemberDetails: engine fork absent")
        return "", "", ""
    end
    return league:GetMemberDelegationDetails(memberId, observerId),
        league:GetMemberKnowledgeDetails(memberId, observerId),
        league:GetMemberVoteOpinionDetails(memberId, observerId)
end
