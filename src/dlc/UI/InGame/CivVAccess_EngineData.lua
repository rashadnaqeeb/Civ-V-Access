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
-- Returns (damage to defender, damage to attacker), MELEE ONLY -- the
-- caller adds volleyDamage onto the spoken damage-to-defender itself.
-- Vanilla has no single call for this, so it synthesizes both sides from
-- two GetCombatDamage calls. VP replaces this with a single
-- GetMeleeCombatDamage that returns both sides at once, which is why the
-- seam is shaped as "give me both numbers for this matchup" rather than
-- exposing GetCombatDamage directly.
--
-- Two pre-resolved damages feed the melee math, one per direction:
--   supportDamage  defensive fire support already dealt TO THE ATTACKER
--                  (the defender's adjacent ranged ally fires first).
--                  Folds into the attacker's current-damage input -- on
--                  this engine wounds scale damage output -- and onto the
--                  attacker's incoming total, exactly as EnemyUnitPanel
--                  does.
--   volleyDamage   the attacker's own opening volley already dealt TO THE
--                  DEFENDER (ranged support fire, the Impi spear throw;
--                  the engine resolves it as a ranged attack before the
--                  melee, CvUnitCombat.cpp:2855). Folds into the
--                  defender's current-damage input so the counterattack
--                  comes from the wounded defender the melee will
--                  actually face.
function EngineData.meleeDamage(attacker, defender, attackStrength, defenseStrength, supportDamage, volleyDamage)
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
        defender:GetDamage() + volleyDamage,
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
-- from the ranged caller (true). assumeVolleyDamage is the attacker's
-- pre-melee volley (see meleeDamage): VP's strength math scales with
-- damage, so its body assumes the volley already landed; on this engine
-- strength does not scale with wounds (the volley enters the melee math
-- through meleeDamage's current-damage inputs instead), so the parameter
-- is correctly unused here.
function EngineData.maxDefenseStrength(defender, toPlot, attacker, bFromRangedAttack, assumeVolleyDamage)
    return defender:GetMaxDefenseStrength(toPlot, attacker, bFromRangedAttack)
end

-- Drift read: the defense modifier a plot grants a defender. VP inserted a
-- bIgnoreFeature parameter ahead of bHelp; the vanilla body uses the
-- three-argument form. bHelp=true is the tooltip variant (includes terrain
-- + feature + improvement components).
function EngineData.plotDefenseModifier(plot, attackerTeam, bIgnoreBuilding, bHelp)
    return plot:DefenseModifier(attackerTeam, bIgnoreBuilding, bHelp)
end

-- Drift read: the "defends near capital" combat modifier for a unit fighting
-- at its own plot, distance falloff already folded in. Vanilla exposes the
-- raw promotion value (CapitalDefenseModifier) plus the per-hex falloff
-- (CapitalDefenseFalloff) and the caller walks the distance from the
-- capital; VP dropped both unit bindings and rolled the whole computation
-- into GetCombatModifierFromCapitalDistance(plot). Returns the modifier (0
-- when the unit has no capital-defense promotion or no capital).
function EngineData.capitalDefenseModifier(unit)
    local capDef = unit:CapitalDefenseModifier()
    if capDef <= 0 then
        return 0
    end
    local cap = Players[unit:GetOwner()]:GetCapitalCity()
    if cap == nil then
        return 0
    end
    local dist = Map.PlotDistance(cap:GetX(), cap:GetY(), unit:GetX(), unit:GetY())
    capDef = capDef + dist * unit:CapitalDefenseFalloff()
    if capDef <= 0 then
        return 0
    end
    return capDef
end

-- Drift read: LekMod's "combat bonus versus a different ideology" modifier
-- (see the LekMod file for the contract). Vanilla has no such modifier, so
-- this is inert; the combat-preview enumerator skips a 0.
function EngineData.ideologyCombatModifier(_unit, _otherUnit)
    return 0
end

-- Drift read: LekMod's tourism-influence combat modifier. Inert on vanilla.
function EngineData.tourismInfluenceCombatModifier(_unit, _otherUnit)
    return 0
end

-- Drift read: LekMod's ranged-defense combat modifier for a defending unit.
-- Inert on vanilla.
function EngineData.rangedDefenseModifier(_unit)
    return 0
end

-- Drift read: the player's golden-age points gained per turn, for the
-- empire-status golden-age progress line. Vanilla does not surface a GAP
-- rate (the progress line speaks the meter only), so this returns nil and the
-- caller adds no rate clause. VP and LekMod return a whole rate (which the
-- caller signs and speaks); VP's can be 0, LekMod's can be negative.
function EngineData.goldenAgePerTurn(_player)
    return nil
end

-- Drift read: a single city's golden-age points per turn. Vanilla has no
-- golden-age-points yield, so this is inert; the city per-turn readout skips
-- a nil. LekMod surfaces it as a real city yield.
function EngineData.cityGoldenAgePerTurn(_city)
    return nil
end

-- LekMod MP "soft prompt" intents -- a pending proposal vote / incoming deal
-- on the end-turn button (see the LekMod file). Vanilla has no MP voting
-- system, so the reads report nothing pending and the opens are no-ops; the
-- Turn module's soft-prompt branch never fires.
function EngineData.pendingVoteProposalId()
    return -1
end

function EngineData.pendingDealSender()
    return -1
end

function EngineData.openVoteProposal(_id) end

function EngineData.openIncomingDeal(_sender) end

-- Drift read: the science needed to steal a tech via espionage (see the
-- LekMod file). Vanilla steals a tech outright with no science cost, so this
-- is nil and the tech tree's steal-cost line never appears.
function EngineData.techStealCost(_player, _targetID, _techID)
    return nil
end

-- Drift read: the reason an owned resource can't be traded (see the LekMod
-- file). Vanilla's trade screen drops untradeable resources rather than
-- listing them disabled, so this is nil and that behavior is unchanged.
function EngineData.resourceTradeBlockedReason(_deal, _fromPlayer, _toPlayer, _row)
    return nil
end

-- Drift read: the tech the active player still needs before a tile's
-- resource can be exploited, as the tech's Description text-key (the game
-- key resolves the arg as another text key, so the key is passed, not the
-- resolved name). Returns nil when the resource is already usable or gates
-- on no tech. Vanilla keys off Resources.TechCityTrade and a team HasTech
-- check (PlotMouseoverInclude); VP added a per-player IsResourceImproveable
-- gate and a Resources.TechImproveable column, so its body reads those.
function EngineData.resourceUseTech(resourceRow)
    local techType = resourceRow.TechCityTrade
    if techType == nil then
        return nil
    end
    local techId = GameInfoTypes[techType]
    if techId == nil or techId < 0 then
        return nil
    end
    if Teams[Game.GetActiveTeam()]:GetTeamTechs():HasTech(techId) then
        return nil
    end
    local techRow = GameInfo.Technologies[techId]
    return techRow and techRow.Description or nil
end

-- Drift read: the empire happiness headline, returned as a model rather
-- than a bare number because the headline METRIC differs by engine. Here
-- the number is a signed surplus; Vox Populi redefines the same getter
-- (GetExcessHappiness) as a 0-100 approval percentage, so a raw number
-- would invite the silent-value failure where a consumer formats one
-- metric as the other. Consumers (the H readout, golden-age detail,
-- Demographics approval, the Culture Overview cell, the Economic Overview
-- happiness tab) branch on mode:
--   mode "surplus": value is the signed happiness surplus.
--   mode "approval" (VP balance): value is the approval percent, and
--     happyCitizens / unhappyCitizens carry the empire citizen counts.
-- state is the spoken empire mood tier from the engine's own state
-- getters: "happy" / "unhappy" / "veryUnhappy" here (super-unhappy folds
-- into veryUnhappy, matching what the H readout always spoke); the VP
-- implementation widens the vocabulary to the six tiers its top panel
-- color-codes (ecstatic / happy / content / unhappy / veryUnhappy /
-- superUnhappy).
function EngineData.happinessSummary(player)
    local state = "happy"
    if player:IsEmpireVeryUnhappy() then
        state = "veryUnhappy"
    elseif player:IsEmpireUnhappy() then
        state = "unhappy"
    end
    return { mode = "surplus", value = player:GetExcessHappiness(), state = state }
end

-- The breakdown getters below answer vanilla-model questions (the
-- per-source buckets of the vanilla happiness system). Consumers reach
-- them only from a happinessSummary mode "surplus" branch; the VP
-- implementation errors loudly if one is called under the approval model,
-- where these buckets do not exist.

-- Drift read: happiness contributed by buildings. VP returns a hardcoded 0
-- (its happiness lives in the citizen-needs model).
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

-- Drift read: the Soldiers demographic value (Demographics screen). Both
-- engines scale sqrt(military might) by a flavor constant the screen never
-- exposes; the multiplier differs (vanilla 2000, VP 5000), so the computed
-- value crosses the seam rather than the bare constant. Rank is unaffected
-- by the multiplier; the spoken absolute is what drifts.
function EngineData.armyDemographic(player)
    return math.sqrt(player:GetMilitaryMight()) * 2000
end

-- Drift read: whether a unit should show the Military Overview's promotion
-- indicator. Vanilla keys it off CanPromote() (the engine panel's own
-- choice); VP's panel keys it off the raw XP threshold instead, because its
-- CanPromote also gates on movement / combat state and would hide the
-- indicator for a unit that has the XP but cannot promote this instant.
function EngineData.unitPromotionReady(unit)
    return unit:CanPromote()
end

-- Drift read: the "supply used" count the Military Overview speaks against
-- the supply cap. Vanilla counts every unit (GetNumUnits); VP counts only
-- the units that draw supply (GetNumUnitsToSupply), matching its panel's
-- Supply Use cell.
function EngineData.supplyUsed(player)
    return player:GetNumUnits()
end

-- Drift read: the unit-supply gold expense the gold breakdown speaks as its
-- own line. Vanilla bills supply separately from unit maintenance, so it is
-- a distinct expense; VP folds supply into CalculateUnitCost and deprecated
-- the getter (a raw call errors), so the VP body returns 0 and the supply
-- line drops, matching VP's top-panel gold breakdown.
function EngineData.unitSupplyCost(player)
    return player:CalculateUnitSupply()
end

-- Drift read: turns for a worker to complete a build it is NOT yet
-- performing on its current plot -- the "if you start this" estimate the
-- unit action menu speaks. Vanilla's getBuildTurnsLeft only credits a unit's
-- work rate to the build it is actually doing, so the prospective estimate
-- has to feed the worker's own rate in as the extra-rate argument, matching
-- the engine's UnitPanel build-action tooltip. VP credits any worker on the
-- plot unconditionally, so feeding the rate again would double-count it and
-- halve the turns; its body passes no extra and lets the engine count the
-- on-plot worker, exactly as VP's UnitPanel does.
function EngineData.buildTurnsIfStarted(unit, plot, buildID, player)
    local extra = 0
    local current = unit:GetBuildType()
    if current == -1 or buildID ~= current then
        extra = unit:WorkRate(true, buildID)
    end
    return plot:GetBuildTurnsLeft(buildID, player, extra, extra)
end

-- Drift read: turns remaining on the build a worker is currently performing,
-- spoken in the unit's status line. Vanilla adds 1 to getBuildTurnsLeft so a
-- build finishing at end of turn reads as 1 rather than 0 (the engine's own
-- UnitPanel convention). VP's getBuildTurnsLeft rounds up and never reports 0
-- for an in-progress build, so VP's UnitPanel drops the +1; the VP body
-- matches and returns the bare count.
function EngineData.activeBuildTurns(plot, buildID, player)
    return plot:GetBuildTurnsLeft(buildID, player, 0, 0) + 1
end

-- Drift read: whether getBuildTurnsLeft already credits a worker standing on
-- the plot toward a build, which makes feeding the worker's rate in again --
-- as the route-path preview does for the worker's start plot -- a
-- double-count. Vanilla credits the on-plot worker only when it is already
-- performing that exact build, so the answer is actorAlreadyOnBuild. VP
-- credits any worker on the plot unconditionally, so its body returns true.
function EngineData.onPlotWorkerCounted(actorAlreadyOnBuild)
    return actorAlreadyOnBuild
end

-- Drift read: the real religion a player controls (Religion Overview), or
-- -1 for none. Vanilla has no religion transfer, so the founder always
-- controls: founded religion or nothing. VP transfers control with the
-- holy city, so a founded-then-lost religion drops here and a conquered
-- one appears -- GetOwnedReligion is the holy-city-keyed answer. Pantheons
-- are excluded (the consumer handles them on a separate, engine-common
-- branch); only a real religion id (or -1) crosses.
function EngineData.ownedReligion(player)
    if player:HasCreatedReligion() then
        return player:GetReligionCreatedByPlayer()
    end
    return -1
end

-- Drift read: the holy city of a religion as the Religion Overview looks
-- it up for a controlling player. Vanilla keys the lookup on the founder
-- (the controller is the founder), so it passes the controller's id. VP
-- transfers control, so the controller may not be the founder and a
-- founder-keyed lookup would miss; its body passes NO_PLAYER (-1) to match
-- the religion regardless of founder, exactly as VP's own overview does.
function EngineData.holyCityForReligion(eReligion, controller)
    return Game.GetHolyCityForReligion(eReligion, controller:GetID())
end

-- Drift read: the player's tourism output per turn. VP returns a times-100
-- value where vanilla returns the plain rate, so a VP adapter divides by
-- 100 here and every consumer keeps reading a plain rate.
function EngineData.tourism(player)
    return player:GetTourism()
end

-- Drift read: a city's base tourism per turn, as a plain rate. Vanilla's
-- GetBaseTourism is already a plain value (great works times the per-work
-- define plus modifiers), so this passes through; the VP body floors its
-- times-100 getter. Same divergence shape as the player-level tourism getter.
function EngineData.baseTourism(city)
    return city:GetBaseTourism()
end

-- Drift read: the culture one specialist of the given type yields in this
-- city, reported separately from the GameInfo.Yields() loop. Vanilla keeps
-- specialist culture in its own column (the Specialists.Culture path), so
-- GetSpecialistYield never returns it and the caller must add it here.
-- VP migrated specialist culture into the standard yield system, dropping
-- this getter entirely; there culture is a YIELD_CULTURE yield-change the
-- caller's yield loop already counts, so the VP body returns 0 to avoid
-- double-counting.
function EngineData.cultureFromSpecialist(city, specID)
    return city:GetCultureFromSpecialist(specID)
end

-- Drift read: a player's per-turn tourism directed at one rival -- the rate
-- the Culture Overview influence tab speaks. Vanilla exposes only
-- GetInfluencePerTurn, which already covers per-turn tourism toward that
-- player; VP's same getter omits instant tourism, so the VP body routes to an
-- instant-inclusive getter instead. Floored to a whole rate, matching the
-- screen.
function EngineData.influenceTourismPerTurn(player, targetID)
    return math.floor(player:GetInfluencePerTurn(targetID))
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
-- terrain visibility ray is unblocked. attacker is unused here -- vanilla
-- has no per-unit see-through for ranged line of sight; the VP body consumes
-- it to feed the unit's see-through into the ray. Degrades to true: when the
-- check can't run, do not impose a false "no line of sight" constraint.
function EngineData.hasLineOfSight(plot, targetPlot, team, _attacker)
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

-- Drift read: a player's war score against another player, for the
-- Diplomatic Overview's foreign-relations "at war with" line. Vox Populi
-- tracks a -100..100 war score (positive when `player` is winning) and bakes
-- it into the TXT_KEY_AT_WAR_WITH text as a second argument; vanilla (Brave
-- New World) has no war-score concept and its TXT_KEY_AT_WAR_WITH takes only
-- the enemy name, so this returns nil and the caller passes no score. GetWarScore
-- is a VP-only binding -- a bare call throws on the stock engine.
function EngineData.warScore(player, otherPlayerId)
    return nil
end

-- Drift read: a team's vassalage relationships (Diplomatic Overview, and
-- the dedicated Vassal Overview). Returned as a model because the underlying
-- bindings are VP-only -- vanilla (Brave New World) has no vassalage system,
-- so a raw call would error; this body returns the no-vassalage answer and
-- every consumer's vassalage branch is inert. The VP body reads the real
-- Team bindings.
--   isVassal    this team serves a master
--   master      the master's team id (nil when none)
--   tenure      turns this team has served its master (0 when free)
--   numVassals  how many teams serve this team
--   vassals     the serving teams' ids (empty when none)
function EngineData.vassalInfo(team)
    return { isVassal = false, master = nil, tenure = 0, numVassals = 0, vassals = {} }
end

-- Drift read: the player credited with a city's original capital for
-- domination-victory accounting (VictoryProgress). Vanilla has no vassalage
-- or city-state capital redirection, so the current owner is the controller.
-- VP redirects a vassal's held capital up to its master and a city-state's
-- capital to its major ally (or the ally's master) via
-- GetOwnerForDominationVictory.
function EngineData.dominationController(city)
    return city:GetOwner()
end

-- The major civ the observer UI is currently showing, or nil when not in an
-- observer-override view. Used to repoint the read-only tech tree in a
-- Community-Patch-only observer session: CP's TopPanel tech button omits the
-- Data4/Data5 that VP's sets, so the popup carries no viewed-player id and the
-- engine's observer state is the only signal. GetObserverUIOverridePlayer is a
-- CP/VP binding unbound on the stock engine, so the vanilla body is always nil
-- (a vanilla observer's tech tree is unaffected; this only matters where CP's
-- button drops the id).
function EngineData.observerViewPlayer()
    return nil
end

-- Drift read: who owns an embassy improvement on this plot -- the builder
-- credited with the World Congress vote, which is distinct from the plot's
-- owner (the city-state whose land the embassy sits in). Returns the
-- builder's player id, or nil when the plot's improvement is not an embassy.
-- The id may name a player no longer in the game: an embassy is permanent and
-- outlives its builder's defeat until a conqueror inherits it, so callers
-- treat a missing Players[id] as the unknown-builder case (mirroring
-- PlotMouseoverInclude's unmet branch). Embassies are a Vox Populi feature --
-- IsImprovementEmbassy is unbound on the stock engine -- so the vanilla body
-- always returns nil and the embassy ownership suffix never appears in a
-- vanilla session.
function EngineData.embassyOwner(plot)
    return nil
end

-- Capability probe: does this engine track historic events (the Culture
-- Overview's VP-only Historic Events tab)? Player-independent so the tab can
-- be gated in at install time before a live player exists. Vanilla (Brave New
-- World) has no historic-events system.
function EngineData.supportsHistoricEvents()
    return false
end

-- Drift read: the model behind the Culture Overview Historic Events tab. The
-- getters (GetNumHistoricEvents, GetHistoricEventTourism) are VP-only, so the
-- vanilla body returns nil -- the tab is never built on vanilla (gated on
-- supportsHistoricEvents). The VP body assembles the full model. Shape:
--   totalEvents     count of historic events the player has triggered
--   culturePerTurn  player culture per turn (floored)
--   tourismPerTurn  player tourism per turn (floored)
--   rows            list of { kind = "event" | "trade", ... }:
--     event  { typeKey = HistoricEventTypes.Type, tourism = int }
--     trade  { domain = "land" | "sea", fromCity, toCity, tourism = int }
function EngineData.historicEvents(player)
    return nil
end

-- Capability probe: does this engine treat a Gold purchase of a building as
-- an INVESTMENT -- a partial production-cost reduction, the building still
-- has to be produced -- rather than an instant completion? Vox Populi's
-- BALANCE_BUILDING_INVESTMENTS turns every Gold building/wonder "purchase"
-- into an investment; vanilla (Brave New World) always completes the building
-- outright, so this is false and the invest-specific labeling and the
-- realized-reduction announcement never run in a vanilla session.
function EngineData.buildingInvestmentsEnabled()
    return false
end

-- Drift read: has a Gold investment already been applied to this building in
-- this city? Drives the "(invested)" marker VP shows on an in-progress build,
-- and the post-commit poll that waits for the investment to land before
-- announcing the reduction. GetBuildingInvestment is VP-only -- a bare call
-- throws on the stock engine -- so the vanilla body returns false and the
-- marker never appears.
function EngineData.buildingInvested(city, buildingID)
    return false
end

-- ============================================================================
-- Squads: a Community-Patch-DLL / Vox Populi feature only, absent on this engine.
-- squadsAvailable() is false here, so the whole Lua squad layer
-- (src/dlc/UI/InGame/CivVAccess_Squad*) never registers its hotkeys or menu.
-- These no-ops exist only to keep the function set identical across the engine
-- bodies (the parity suite asserts it) and to degrade safely if ever reached.
-- See the VP body for the real contracts.
-- ============================================================================

function EngineData.squadsAvailable()
    return false
end

function EngineData.squadNumber(_unit)
    return -1
end

function EngineData.assignToSquad(_unit, _squadNumber) end

function EngineData.removeFromSquad(_unit) end

function EngineData.squadMembers(_player, _squadNumber)
    return {}
end

function EngineData.moveSquad(_unit, _destPlot, _escort) end

function EngineData.squadMovePreviewTurns(_unit, _destPlot)
    return 0
end

function EngineData.squadIsMoving(_unit)
    return false
end

function EngineData.squadTurnsRemaining(_unit)
    return 0
end

function EngineData.cancelSquadMove(_unit) end

function EngineData.setSquadEndMovementMode(_unit, _mode) end
