-- The EngineData port: the single place the mod reads engine-sensitive
-- values and calls engine-extension (fork-added) bindings. This file is the
-- VOX POPULI implementation -- same function set and contracts as the
-- vanilla src/dlc/UI/InGame/CivVAccess_EngineData.lua (the parity suite
-- asserts the sets match), with bodies that read VP's getters. The CP/VP
-- deploys (deploy.ps1 -State vp / -State cp) ship this copy in place of the
-- vanilla one; both share the include stem,
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
-- Returns (damage to defender, damage to attacker), MELEE ONLY -- the
-- caller adds volleyDamage onto the spoken damage-to-defender itself.
-- VP's GetMeleeCombatDamage(strength, opponentStrength, includeRand,
-- otherUnit, extraDefenderDamage) returns both sides in one call.
--
-- Two pre-resolved damages, one per direction (see the vanilla file):
--   supportDamage  defensive fire support already dealt TO THE ATTACKER.
--                  VP disables that mechanic by default
--                  (FIRE_SUPPORT_DISABLED=1, GetFireSupportUnit returns
--                  nil) so the caller's value is 0 in practice, but a DB
--                  re-enable keeps this correct: it lands on the
--                  attacker's incoming total.
--   volleyDamage   the attacker's own opening volley already dealt TO THE
--                  DEFENDER (ranged support fire). Crosses as
--                  extraDefenderDamage, the same argument VP's own
--                  EnemyUnitPanel passes, so the mutual-kill correction
--                  sees the wounded defender.
function EngineData.meleeDamage(attacker, defender, attackStrength, defenseStrength, supportDamage, volleyDamage)
    local toDefender, toAttacker =
        attacker:GetMeleeCombatDamage(attackStrength, defenseStrength, false, defender, volleyDamage)
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
-- assumeVolleyDamage is the attacker's pre-melee volley: VP's strength
-- math scales with damage, so the engine takes it as
-- iAssumeExtraDamage and answers with the strength of the
-- already-wounded defender the melee will face -- the same fifth
-- argument VP's own EnemyUnitPanel passes. nil for the ranged caller,
-- where no volley precedes the strike.
function EngineData.maxDefenseStrength(defender, toPlot, attacker, bFromRangedAttack, assumeVolleyDamage)
    return defender:GetMaxDefenseStrength(
        toPlot,
        attacker,
        attacker:GetPlot(),
        bFromRangedAttack,
        assumeVolleyDamage or 0
    )
end

-- Drift read: the defense modifier a plot grants a defender. VP inserted
-- bIgnoreFeature at position 3 ahead of bHelp; passing false keeps feature
-- modifiers included, matching the vanilla three-argument call.
function EngineData.plotDefenseModifier(plot, attackerTeam, bIgnoreBuilding, bHelp)
    return plot:DefenseModifier(attackerTeam, bIgnoreBuilding, false, bHelp)
end

-- Drift read: the "defends near capital" combat modifier (see the vanilla
-- file for the contract). VP dropped the unit-level CapitalDefenseModifier
-- and CapitalDefenseFalloff bindings and rolled the value, the distance
-- walk, and the falloff clamp into one binding that takes the battle plot.
function EngineData.capitalDefenseModifier(unit)
    local plot = Map.GetPlot(unit:GetX(), unit:GetY())
    return unit:GetCombatModifierFromCapitalDistance(plot)
end

-- Drift read: LekMod's "combat bonus versus a different ideology" modifier
-- (see the LekMod file for the contract). VP has no such modifier, so this
-- is inert; the combat-preview enumerator skips a 0.
function EngineData.ideologyCombatModifier(_unit, _otherUnit)
    return 0
end

-- Drift read: LekMod's tourism-influence combat modifier. Inert on VP.
function EngineData.tourismInfluenceCombatModifier(_unit, _otherUnit)
    return 0
end

-- Drift read: LekMod's ranged-defense combat modifier for a defending unit.
-- Inert on VP.
function EngineData.rangedDefenseModifier(_unit)
    return 0
end

-- Is the Vox Populi balance mode on? VP guts the vanilla happiness model
-- only under MOD_BALANCE_VP; a Community-Patch-only session (balance off)
-- keeps the vanilla signed-surplus semantics. Same gate the vendor UIs use.
local function balanceVP()
    return Game.IsCustomModOption ~= nil and Game.IsCustomModOption("BALANCE_VP")
end

-- Drift read: the player's golden-age points gained per turn (see the
-- vanilla file for the contract). VP's TopPanel composes it from the four GAP
-- sources (three flat plus the times-100 city GAP); floored to a whole rate
-- for display, matching the panel.
function EngineData.goldenAgePerTurn(player)
    -- The GAP sources compose a real golden-age rate only under MOD_BALANCE_VP.
    -- With VP balance off (Community-Patch-only) GetHappinessForGAP returns
    -- excess happiness instead (CvPlayer.cpp), so the composed value would be a
    -- wrong number; surface no rate there, as vanilla and the surplus model do.
    if not balanceVP() then
        return nil
    end
    local times100 = (player:GetHappinessForGAP() + player:GetGAPFromReligion() + player:GetGAPFromTraits()) * 100
        + player:GetGAPFromCitiesTimes100()
    return math.floor(times100 / 100)
end

-- Drift read: a single city's golden-age points per turn. VP's per-city GAP
-- feeds the player-level GetGAPFromCitiesTimes100 total and is not a per-city
-- yield, so there is no per-city rate to surface; inert, matching the empire-
-- level rate VP already speaks. LekMod surfaces it as a real city yield.
function EngineData.cityGoldenAgePerTurn(_city)
    return nil
end

-- LekMod MP "soft prompt" intents -- a pending proposal vote / incoming deal
-- on the end-turn button (see the LekMod file). VP has no MP voting system, so
-- the reads report nothing pending and the opens are no-ops; the Turn module's
-- soft-prompt branch never fires.
function EngineData.pendingVoteProposalId()
    return -1
end

function EngineData.pendingDealSender()
    return -1
end

function EngineData.openVoteProposal(_id) end

function EngineData.openIncomingDeal(_sender) end

-- Drift read: the science needed to steal a tech via espionage (see the
-- LekMod file). VP steals a tech outright with no science cost, so this is nil
-- and the tech tree's steal-cost line never appears.
function EngineData.techStealCost(_player, _targetID, _techID)
    return nil
end

-- Drift read: the reason an owned resource can't be traded (see the LekMod
-- file). VP's trade screen drops untradeable resources rather than listing
-- them disabled, so this is nil and that behavior is unchanged.
function EngineData.resourceTradeBlockedReason(_deal, _fromPlayer, _toPlayer, _row)
    return nil
end

-- Drift read: the tech still needed to exploit a tile's resource (see the
-- vanilla file for the contract). VP replaced vanilla's TechCityTrade +
-- team-HasTech check with a per-player IsResourceImproveable gate and a
-- Resources.TechImproveable column (PlotMouseoverInclude), so this body
-- reads those; vanilla's TechCityTrade column is empty for the gate VP uses.
function EngineData.resourceUseTech(resourceRow)
    if Players[Game.GetActivePlayer()]:IsResourceImproveable(resourceRow.ID) then
        return nil
    end
    local techType = resourceRow.TechImproveable
    if techType == nil then
        return nil
    end
    local techId = GameInfoTypes[techType]
    if techId == nil or techId < 0 then
        return nil
    end
    local techRow = GameInfo.Technologies[techId]
    return techRow and techRow.Description or nil
end

-- Drift read: the empire happiness headline model (see the vanilla file
-- for the full contract). Under VP balance, GetExcessHappiness is the
-- approval percentage: happy citizens over unhappy citizens, capped and
-- halved, 100 when nobody is unhappy, 50 when they balance
-- (CvPlayer::CalculateNetHappiness). The citizen counts are the sums the
-- top panel displays next to it. state mirrors the top panel's six color
-- tiers: the three negative ones come from the engine's own state getters
-- (engine thresholds: unhappy below 50, very below 35, super below 20),
-- the three positive cuts (75 / 60) are mirrored from VP's TopPanel.lua,
-- which hardcodes them for its colors. In a balance-off (CP-only) session
-- the engine reverts to the signed-surplus model, so the summary does too.
function EngineData.happinessSummary(player)
    if not balanceVP() then
        local state = "happy"
        if player:IsEmpireVeryUnhappy() then
            state = "veryUnhappy"
        elseif player:IsEmpireUnhappy() then
            state = "unhappy"
        end
        return { mode = "surplus", value = player:GetExcessHappiness(), state = state }
    end
    local percent = player:GetExcessHappiness()
    local state
    if player:IsEmpireSuperUnhappy() then
        state = "superUnhappy"
    elseif player:IsEmpireVeryUnhappy() then
        state = "veryUnhappy"
    elseif player:IsEmpireUnhappy() then
        state = "unhappy"
    elseif percent >= 75 then
        state = "ecstatic"
    elseif percent >= 60 then
        state = "happy"
    else
        state = "content"
    end
    return {
        mode = "approval",
        value = percent,
        happyCitizens = player:GetHappinessFromCitizenNeeds(),
        unhappyCitizens = player:GetUnhappinessFromCitizenNeeds(),
        state = state,
    }
end

-- The vanilla-model breakdown getters. Under VP balance these buckets do
-- not exist (the engine hardcodes them to 0 under MOD_BALANCE_VP), so a
-- call here is a consumer that failed to branch on happinessSummary().mode
-- -- a bug, not a data request. Crash with a named breadcrumb (reaches
-- Lua.log via the engine's per-listener catch) instead of speaking a
-- fabricated 0. In a balance-off session the engine keeps the vanilla
-- values and the consumers' surplus branches legitimately land here, so
-- the bodies pass through.
local function vanillaModelRead(name, fn)
    EngineData[name] = function(...)
        if balanceVP() then
            error("EngineData." .. name .. ": vanilla-model getter under VP balance; branch on happinessSummary().mode")
        end
        return fn(...)
    end
end

vanillaModelRead("happinessFromBuildings", function(player)
    return player:GetHappinessFromBuildings()
end)

vanillaModelRead("happinessFromPolicies", function(player)
    return player:GetHappinessFromPolicies()
end)

vanillaModelRead("unhappinessFromCityCount", function(player)
    return player:GetUnhappinessFromCityCount()
end)

vanillaModelRead("unhappinessFromCapturedCityCount", function(player)
    return player:GetUnhappinessFromCapturedCityCount()
end)

vanillaModelRead("unhappinessFromCityPopulation", function(player)
    return player:GetUnhappinessFromCityPopulation()
end)

vanillaModelRead("unhappinessFromCity", function(player, city)
    return player:GetUnhappinessFromCityForUI(city)
end)

-- Drift read: the Soldiers demographic value (Demographics screen). VP's
-- Demographics override scales sqrt(military might) by 5000 where vanilla
-- uses 2000; the multiplier is hardcoded in the vendor Lua, not gated on
-- BALANCE_VP, and a VP-state install ships that vendor copy, so the value
-- is 5000-scaled on both CP-only and full-VP sessions. Rank is unaffected;
-- only the spoken absolute drifts.
function EngineData.armyDemographic(player)
    return math.sqrt(player:GetMilitaryMight()) * 5000
end

-- Drift read: whether a unit should show the Military Overview's promotion
-- indicator. VP's panel keys it off the raw XP threshold (its
-- MilitaryOverview comments out CanPromote in favor of GetExperience >=
-- ExperienceNeeded), because CanPromote also gates on movement / combat
-- state and would hide the indicator for a unit that has the XP.
function EngineData.unitPromotionReady(unit)
    return unit:GetExperience() >= unit:ExperienceNeeded()
end

-- Drift read: the "supply used" count the Military Overview speaks against
-- the supply cap. VP's panel counts only units that draw supply
-- (GetNumUnitsToSupply), where vanilla counts every unit; the cap getter
-- (GetNumUnitsSupplied) is shared, so only the use side crosses here.
function EngineData.supplyUsed(player)
    return player:GetNumUnitsToSupply()
end

-- VP enforces the unit supply limit (its supply cap drives both the production
-- penalty and the per-unit gold), so the Military Overview keeps its use/cap
-- preamble. Only LekMod removes the limit; see its body.
function EngineData.supplyLimited()
    return true
end

-- Drift read: the unit-supply gold expense. VP folds supply into
-- CalculateUnitCost and deprecated CalculateUnitSupply (a raw call errors),
-- so there is no separate supply expense -- return 0 and the gold
-- breakdown's supply line drops, matching VP's own top panel.
function EngineData.unitSupplyCost(_player)
    return 0
end

-- Drift read: prospective turns for a worker to build buildID on its plot.
-- VP's getBuildTurnsLeft credits any worker standing on the plot, so the
-- on-plot worker is already counted; feeding its rate as the extra argument
-- (as vanilla must, since vanilla only credits the build the unit is already
-- doing) would double-count and halve the turns. Match VP's own UnitPanel
-- build-action tooltip: bare getBuildTurnsLeft, no extra rate.
function EngineData.buildTurnsIfStarted(_unit, plot, buildID, player)
    return plot:GetBuildTurnsLeft(buildID, player, 0, 0)
end

-- Drift read: turns remaining on the build a worker is currently performing.
-- VP's getBuildTurnsLeft rounds up and never reports 0 for an in-progress
-- build, so VP's UnitPanel drops vanilla's display +1. Match it: bare count.
function EngineData.activeBuildTurns(plot, buildID, player)
    return plot:GetBuildTurnsLeft(buildID, player, 0, 0)
end

-- Drift read: VP's getBuildTurnsLeft credits any worker on the plot toward
-- any build, so a worker on the plot is always already counted -- feeding its
-- rate in again (as the route-path preview does for the start plot) would
-- double-count. Vanilla credits it only for the build the worker is already
-- performing, so vanilla returns actorAlreadyOnBuild instead.
function EngineData.onPlotWorkerCounted(_actorAlreadyOnBuild)
    return true
end

-- Drift read: the real religion a player controls (Religion Overview), or
-- -1 for none. VP transfers religion control with the holy city, so the
-- answer is GetOwnedReligion (holy-city-keyed) rather than the founded
-- religion: a founded-then-lost religion drops, a conquered one appears.
-- GetOwnedReligion returns RELIGION_PANTHEON or below when the player owns
-- no real religion; the consumer handles pantheons on a separate branch,
-- so collapse those to -1 here.
function EngineData.ownedReligion(player)
    local eReligion = player:GetOwnedReligion()
    if eReligion > ReligionTypes.RELIGION_PANTHEON then
        return eReligion
    end
    return -1
end

-- Drift read: the holy city of a religion for a controlling player. VP
-- transfers control with the holy city, so the controller may not be the
-- founder; a founder-keyed lookup would miss. Pass NO_PLAYER (-1) to match
-- the religion regardless of founder, as VP's own overview does
-- (GetHolyCityForReligion(eReligion, -1)). The controller handle is unused
-- here, kept for the vanilla body's founder-keyed lookup.
function EngineData.holyCityForReligion(eReligion, controller)
    return Game.GetHolyCityForReligion(eReligion, -1)
end

-- Drift read: the player's tourism output per turn. VP's getter is
-- times-100; floor /100 mirrors VP's own TopPanel display
-- (FormatIntegerTimes100), so the spoken rate matches the screen.
function EngineData.tourism(player)
    return math.floor(player:GetTourism() / 100)
end

-- Drift read: a city's base tourism per turn, as a plain rate. VP's
-- GetBaseTourism returns getYieldRateTimes100(YIELD_TOURISM), so floor /100
-- to the displayed rate; vanilla's same-named getter is already plain. Same
-- divergence shape as the player-level tourism getter.
function EngineData.baseTourism(city)
    return math.floor(city:GetBaseTourism() / 100)
end

-- Drift read: specialist culture (see the vanilla file for the contract).
-- VP folded specialist culture into the standard yield system as a
-- YIELD_CULTURE yield-change and deleted GetCultureFromSpecialist, so the
-- caller's GameInfo.Yields() loop already counts it via
-- GetSpecialistYield(specID, YIELD_CULTURE). Returning it again here would
-- double-count, so the VP body contributes nothing.
function EngineData.cultureFromSpecialist(_city, _specID)
    return 0
end

-- Drift read: a player's per-turn tourism directed at one rival. VP's
-- GetInfluencePerTurn omits instant tourism and reads low; its own influence
-- screen uses GetTourismPerTurnIncludingInstantTimes100, so we match it. That
-- getter is VP-only (absent on vanilla) and times-100, so floor /100 to the
-- displayed rate.
function EngineData.influenceTourismPerTurn(player, targetID)
    return math.floor(player:GetTourismPerTurnIncludingInstantTimes100(targetID) / 100)
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
-- enum; keep in sync with it. The fork's GeneratePathWithFlags applies
-- these (generatePath / computePath head leg); stock VP without the fork
-- can't, so they degrade to validation-only there. A 0 entry is a name the
-- vocabulary carries but VP's pathfinder has no flag for:
--   declareWar      maps to MOVEFLAG_IGNORE_RIGHT_OF_PASSAGE -- VP plans war
--                   legality at execution, not in the pathfinder, but a
--                   closed-borders block is the same recovery (pretend we
--                   can enter everyone's territory), which is the cause the
--                   diagnostic reports
--   forceDestValid  the fork replaces the force-valid exploration search
--                   with the closest-reachable binding (GetPlotsInReach),
--                   so no flag exists or is needed
local MOVE_INTENT_BITS = {
    noEnemyTerritory = 0x0400, -- MOVEFLAG_NO_ENEMY_TERRITORY
    ignoreStacking = 0x0010, -- MOVEFLAG_IGNORE_STACKING_SELF
    ignoreDanger = 0x0100, -- MOVEFLAG_IGNORE_DANGER
    throughEnemy = 0x2000000, -- MOVEFLAG_IGNORE_ENEMIES
    maximizeExplore = 0x0800, -- MOVEFLAG_MAXIMIZE_EXPLORE
    declareWar = 0x80000, -- MOVEFLAG_IGNORE_RIGHT_OF_PASSAGE
    forceDestValid = 0,
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

-- Logs (debug level) when a caller asked for path relaxations the path
-- surface in play cannot apply -- the no-fork fallback (stock VP's bindings
-- take no flags) and the queued-leg branches of computePath (stock
-- GeneratePathToNextWaypoint / GetWaypointPath, no flag argument). Not a
-- warn: the limitation is a known, accepted property of those surfaces, and
-- the discriminative-retry preview passes intents on every failed path, so
-- warn would drown real warnings. Returns nothing; the value of the call is
-- the name validation inside bitsFromIntents.
local function noteUnappliedIntents(scope, intents)
    if bitsFromIntents(intents) ~= 0 then
        Log.debug(scope .. ": path surface takes no flags; intents not applied")
    end
end

-- A VP path node's TC_UI Turn value -> the seam's canonical 1-based turn
-- (1 = arrives this turn), matching the vanilla fork's m_iData2 exactly.
--
-- VP's pathfinder counts turns 0-based (origin node Turn 0), so converting
-- to the 1-based convention is normally +1. But every VP path binding
-- requests TC_UI mode, which already adds the end-of-turn +1 to any STOP
-- node -- a node the unit reaches with no movement left
-- (RemainingMovement == 0; CvAStar.cpp GetCurrentPath "if (eMode==TC_UI &&
-- moves == 0) turns++"). Adding our own +1 on top of that double-counts the
-- final turn whenever a move ends its turn on arrival -- the very common
-- "moved my full distance this turn" case, which would then read as 2 turns
-- instead of 1. So add 1 only when movement remains; a stop node already
-- carries the increment.
local function oneBasedTurn(node)
    if node.RemainingMovement == 0 then
        return node.Turn
    end
    return node.Turn + 1
end

-- VP node array ({X, Y, RemainingMovement, Turn, ...}) -> the seam's
-- canonical node shape ({x, y, moves, turn, flags, revealed}). moves is in
-- MOVE_DENOMINATOR 60ths on both engines. turn converts to the seam's
-- 1-based convention via oneBasedTurn (see there for the TC_UI stop-node
-- caveat). flags is 0 (VP's binding has no per-node flags; no consumer
-- reads it). revealed re-queries CvPlot:IsRevealed for the unit's team at
-- conversion time -- the same answer the pathfinder just used for its
-- costs. VP's Invisible field is NOT that answer (it is current visibility;
-- a revealed-but-fogged tile would wrongly read as unexplored and truncate
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
            turn = oneBasedTurn(n),
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

-- Runs the engine pathfinder from the unit's current plot with the given
-- flag mask, returning the raw VP node array. The fork's
-- GeneratePathWithFlags applies the flags with no hardcoded stacking
-- relaxation, so a strict (flags 0) search matches what the engine does
-- when the unit executes a manual move, and the diagnostics' single
-- relaxations actually bite. Without the fork, stock GeneratePath ignores
-- the flags (and hardcodes MOVEFLAG_IGNORE_STACKING_SELF), so the search
-- still runs but no relaxation applies -- the caller logs that via
-- noteUnappliedIntents, and strict reads as own-stacking-ignored.
local function pathFromUnit(unit, plot, flags)
    if EngineData.forkPresent() then
        return unit:GeneratePathWithFlags(plot, flags)
    end
    return unit:GeneratePath(plot, UNLIMITED_TURNS)
end

-- Extension binding seam: runs the engine pathfinder from the unit's
-- position, returning (ok, pathTurns). On a fork deploy the named intents
-- are applied as real pathfinder flags (strict by default); on stock VP
-- they degrade to validation-only (the binding takes no flags and hardcodes
-- own-unit stacking relaxation).
function EngineData.generatePath(unit, plot, intents)
    local flags = (intents ~= nil) and bitsFromIntents(intents) or 0
    if intents ~= nil and not EngineData.forkPresent() then
        noteUnappliedIntents("EngineData.generatePath", intents)
    end
    lastGenerated = { unitID = unit:GetID(), owner = unit:GetOwner(), plot = plot, flags = flags }
    local nodes = pathFromUnit(unit, plot, flags)
    if #nodes == 0 then
        return false
    end
    return true, oneBasedTurn(nodes[#nodes])
end

-- Extension binding seam: the node array of the last path generatePath
-- produced for this unit. VP cannot read a cached path back, so the body
-- re-runs the same search live -- with the same flags (see lastGenerated).
-- Empty array when no prior generatePath matches the unit -- a contract
-- misuse worth a log, since the vanilla body would have returned the
-- engine's cached nodes.
function EngineData.getPath(unit)
    if lastGenerated == nil or lastGenerated.unitID ~= unit:GetID() then
        Log.warn("EngineData.getPath: no prior generatePath for this unit")
        return {}
    end
    return convertNodes(unit, pathFromUnit(unit, lastGenerated.plot, lastGenerated.flags))
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
-- counts on later legs may run one high mid-turn). intents apply only on
-- the head-leg branch (the fork's flag-aware binding); the queued-leg
-- branches run stock bindings that take no flags.
function EngineData.computePath(unit, fromPlot, toPlot, intents, freshTurn)
    local flags = (intents ~= nil) and bitsFromIntents(intents) or 0
    local fx, fy = fromPlot:GetX(), fromPlot:GetY()
    if fx == unit:GetX() and fy == unit:GetY() then
        if intents ~= nil and not EngineData.forkPresent() then
            noteUnappliedIntents("EngineData.computePath", intents)
        end
        local nodes = pathFromUnit(unit, toPlot, flags)
        if #nodes == 0 then
            return {}, false, 0
        end
        return convertNodes(unit, nodes), true, oneBasedTurn(nodes[#nodes])
    end
    -- Queued-leg branches below run stock GeneratePathToNextWaypoint /
    -- GetWaypointPath, which take no flag argument, so any intents the
    -- mission carried cannot be applied here.
    if intents ~= nil then
        noteUnappliedIntents("EngineData.computePath", intents)
    end
    local lastMission = unit:LastMissionPlot()
    if lastMission ~= nil and lastMission:GetX() == fx and lastMission:GetY() == fy then
        local nodes = unit:GeneratePathToNextWaypoint(toPlot) or {}
        if #nodes == 0 then
            return {}, false, 0
        end
        return convertNodes(unit, nodes), true, oneBasedTurn(nodes[#nodes])
    end
    local tx, ty = toPlot:GetX(), toPlot:GetY()
    for _, leg in ipairs(waypointLegs(unit)) do
        local first, last = leg[1], leg[#leg]
        if first.X == fx and first.Y == fy and last.X == tx and last.Y == ty then
            return convertNodes(unit, leg), true, oneBasedTurn(last)
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

-- Extension binding: Game.GetClosestSearchedPlot, fork-added under the
-- vanilla name. After a failed generatePath, the closest reachable tile to
-- the target, returning (x, y, distance). On VP the fork wraps
-- GetPlotsInReach rather than a closed-list walk, and a reach query needs
-- the unit -- the vanilla binding reads it back out of the pathfinder
-- state, but VP's pathfinder keeps none, so the binding takes it as extra
-- args. The unit is lastGenerated's: the vanilla contract is "call
-- immediately after the failed generatePath", and that is exactly the
-- search lastGenerated records. Degrades to nil; called before any
-- generatePath is a contract misuse worth a log (the vanilla body would
-- have answered from pathfinder state).
function EngineData.closestSearchedPlot(tx, ty)
    if not EngineData.forkPresent() then
        Log.warn("EngineData.closestSearchedPlot: engine fork absent")
        return nil
    end
    if lastGenerated == nil then
        Log.warn("EngineData.closestSearchedPlot: no prior generatePath")
        return nil
    end
    return Game.GetClosestSearchedPlot(tx, ty, lastGenerated.owner, lastGenerated.unitID)
end

-- Whether the terrain visibility ray between two plots is unblocked. On VP
-- this is pure Lua over the stock Plot:CanSeePlot -- a generous range
-- defeats its distance gate (the binding adds 1 internally;
-- CvLuaPlot.cpp:2149) and facing NO_DIRECTION (-1) short-circuits its
-- facing gate -- so it needs no fork and never degrades.
--
-- VP's ranged-strike LoS feeds the attacker's see-through (a promotion stat
-- that lets a unit fire over blocking terrain) as canSeePlot's iSeeThrough
-- arg (CvUnit::canEverRangeStrikeAt). The prefix must pass it too, or a
-- see-through unit's legitimately strikeable tiles read back as "unseen".
-- Cities (nil attacker) have no see-through.
function EngineData.hasLineOfSight(plot, targetPlot, team, attacker)
    local seeThrough = attacker and attacker:GetSeeThrough() or 0
    return plot:CanSeePlot(targetPlot, team, 10000, -1, seeThrough)
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

-- Drift read: a player's war score against another player (see the vanilla
-- file for the contract). VP's GetWarScore returns a -100..100 value, positive
-- when `player` is winning the war, that the diplo overview bakes into
-- TXT_KEY_AT_WAR_WITH as a second argument. Returns 0 when the two are not at
-- war (GetWarScore's own guard), which the caller only reads inside an at-war
-- branch anyway.
function EngineData.warScore(player, otherPlayerId)
    return player:GetWarScore(otherPlayerId)
end

-- Drift read: a team's vassalage relationships (see the vanilla file for the
-- model contract). VP exposes the Team bindings vanilla lacks. master is nil
-- when GetMaster returns the no-master sentinel (-1). tenure is the turns
-- this team has served its master; GetNumTurnsIsVassal takes no argument and
-- returns the team's own stored duration (vassalage is 1:1, so the team's
-- master is unambiguous). vassals is built by scanning every team for one
-- that serves this one;
-- numVassals comes straight from the engine count. With vassalage disabled
-- the getters return the empty answer naturally, so no GAMEOPTION check is
-- needed.
function EngineData.vassalInfo(team)
    local masterId = team:GetMaster()
    if masterId == -1 then
        masterId = nil
    end
    local isVassal = team:IsVassalOfSomeone()
    local tenure = 0
    if isVassal and masterId ~= nil then
        tenure = team:GetNumTurnsIsVassal()
    end
    local thisId = team:GetID()
    local vassals = {}
    for iTeam = 0, GameDefines.MAX_CIV_PLAYERS - 1 do
        local t = Teams[iTeam]
        if t ~= nil and iTeam ~= thisId and t:IsVassal(thisId) then
            vassals[#vassals + 1] = iTeam
        end
    end
    return {
        isVassal = isVassal,
        master = masterId,
        tenure = tenure,
        numVassals = team:GetNumVassals(),
        vassals = vassals,
    }
end

-- Drift read: the player credited with a city's original capital for
-- domination victory. VP's GetOwnerForDominationVictory redirects a vassal's
-- held capital to its master and a city-state's capital to its major ally (or
-- the ally's master, CvCity.cpp:15535); vanilla credits the current owner.
function EngineData.dominationController(city)
    return city:GetOwnerForDominationVictory()
end

-- The major civ the observer UI is showing, or nil when not in an
-- observer-override view. Only the active-player-is-observer case applies (a
-- real active player needs no repoint); within it the UI-override player is the
-- shown civ. Returns nil in the auto-cycle case (override -1), where the shown
-- player is per-turn state the TopPanel tracks but no stateless getter exposes
-- -- the read-only tech view then falls back to its prior behavior, no worse
-- than before. See the vanilla file for why this exists.
function EngineData.observerViewPlayer()
    if not Players[Game.GetActivePlayer()]:IsObserver() then
        return nil
    end
    local override = Game:GetObserverUIOverridePlayer()
    if override ~= nil and override >= 0 then
        return override
    end
    return nil
end

-- Drift read: the major civ that built an embassy on this plot, distinct from
-- the city-state that owns the land. IsImprovementEmbassy is VP-only; when it
-- holds, GetPlayerThatBuiltImprovement (the same field vanilla uses for
-- citadel attribution) names the builder who holds the World Congress vote --
-- reassigned to a conqueror if the builder is defeated, so this is always the
-- current owner. Returns the builder id (possibly a defeated player) or nil
-- when the plot's improvement is not an embassy.
function EngineData.embassyOwner(plot)
    if not plot:IsImprovementEmbassy() then
        return nil
    end
    return plot:GetPlayerThatBuiltImprovement()
end

-- Capability probe: VP tracks historic events, so the Culture Overview's
-- Historic Events tab is built. See the vanilla file for the contract.
function EngineData.supportsHistoricEvents()
    return true
end

-- Drift read: the Historic Events tab model (see the vanilla file for the
-- shape). Mirrors VP's own RefreshHistoricEvents: every HistoricEventType the
-- player has earned tourism from becomes an event row; the two trade pseudo-
-- types fan out to one row per active trade route whose destination is a met
-- major (the FromCity-keyed tourism the engine credits the route). Culture and
-- tourism per turn are floored from the times-100 getters, matching VP's
-- header. The bindings (GetNumHistoricEvents, GetHistoricEventTourism) are
-- VP-only; this body is only reached on the VP path (supportsHistoricEvents).
function EngineData.historicEvents(player)
    local out = {
        totalEvents = player:GetNumHistoricEvents(),
        culturePerTurn = math.floor(player:GetTotalJONSCulturePerTurnTimes100() / 100),
        tourismPerTurn = math.floor(player:GetTourism() / 100),
        rows = {},
    }
    for row in GameInfo.HistoricEventTypes() do
        local isLand = row.Type == "HISTORIC_EVENT_TRADE_LAND"
        local isSea = row.Type == "HISTORIC_EVENT_TRADE_SEA"
        if isLand or isSea then
            local routes = player:GetTradeRoutes()
            if routes ~= nil then
                for _, v in ipairs(routes) do
                    local matchDomain = (isLand and v.Domain == DomainTypes.DOMAIN_LAND)
                        or (isSea and v.Domain == DomainTypes.DOMAIN_SEA)
                    if v.FromID ~= v.ToID and not Players[v.ToID]:IsMinorCiv() and matchDomain then
                        out.rows[#out.rows + 1] = {
                            kind = "trade",
                            domain = isLand and "land" or "sea",
                            fromCity = v.FromCity:GetName(),
                            toCity = v.ToCityName,
                            tourism = player:GetHistoricEventTourism(row.ID, v.FromCity:GetID()),
                        }
                    end
                end
            end
        elseif player:GetHistoricEventTourism(row.ID) > 0 then
            out.rows[#out.rows + 1] = {
                kind = "event",
                typeKey = row.Type,
                tourism = player:GetHistoricEventTourism(row.ID),
            }
        end
    end
    return out
end

-- Capability probe: VP's BALANCE_BUILDING_INVESTMENTS makes a Gold building
-- purchase an investment (a production-cost reduction) instead of an instant
-- completion. See the vanilla file for the full contract.
function EngineData.buildingInvestmentsEnabled()
    return Game.IsCustomModOption ~= nil and Game.IsCustomModOption("BALANCE_BUILDING_INVESTMENTS")
end

-- Drift read: whether a Gold investment is already applied to this building.
-- GetBuildingInvestment returns the post-investment production needed (always
-- positive) once invested and 0 otherwise, so a positive value doubles as the
-- "is invested" flag. VP-only binding; see the vanilla file for the contract.
function EngineData.buildingInvested(city, buildingID)
    return city:GetBuildingInvestment(buildingID) > 0
end

-- ============================================================================
-- Squads (Community Patch / Vox Populi only). The squad engine code ships in the
-- Community-Patch-DLL fork, gated on the SQUADS custom option that our DB layer
-- enables. State mutations (assign / remove / move / cancel / end-mode) dispatch
-- through the fork's synced command channel so every client applies them in
-- lockstep -- the multiplayer-correctness fix that makes the in-DLL reroute and
-- wake-all deterministic. Reads are live. squadsAvailable() is the capability
-- gate the whole Lua squad layer keys off; it is false on vanilla and LekMod, so
-- that layer never registers there. See docs/llm-docs/cp-vp-support.md.
-- ============================================================================

-- Capability probe: is the squads feature live this session? True only on a
-- Community-Patch-DLL deploy with the SQUADS option enabled (our DB layer turns
-- it on). The vanilla and LekMod bodies hardcode this false.
function EngineData.squadsAvailable()
    return Game ~= nil and Game.IsCustomModOption ~= nil and Game.IsCustomModOption("SQUADS")
end

-- Read: the unit's squad number, or -1 if it is in no squad. Live.
function EngineData.squadNumber(unit)
    return unit:GetSquadNumber()
end

-- Mutation (synced): assign the unit to a squad, via the fork command channel.
function EngineData.assignToSquad(unit, squadNumber)
    unit:AssignToSquad(squadNumber)
end

-- Mutation (synced): remove the unit from its squad.
function EngineData.removeFromSquad(unit)
    unit:RemoveFromSquad()
end

-- Read: the live list of unit handles in the given squad for this player.
-- Re-queried each call, never cached.
function EngineData.squadMembers(player, squadNumber)
    local members = {}
    for unit in player:UnitsInSquad(squadNumber) do
        members[#members + 1] = unit
    end
    return members
end

-- Mutation (synced): order the unit's squad to move to destPlot, spreading
-- members into rings around it. escort links non-combat units to a combat unit
-- on their start plot so they travel protected.
function EngineData.moveSquad(unit, destPlot, escort)
    unit:DoSquadMovement(destPlot, escort)
end

-- Read: turns until every member would finish moving to destPlot (the max over
-- members of each member's path-turn count to its assigned ring plot). 0 when
-- the squad is empty or no member can reach. Drives the move preview.
function EngineData.squadMovePreviewTurns(unit, destPlot)
    return unit:GetSquadMovementPreviewTurns(destPlot)
end

-- Read: is the squad currently mid-move (any member has an active move mission)?
-- The authoritative "is moving" signal -- the stored destination persists after
-- arrival in the alert/wake-each modes, so it is not a reliable substitute.
function EngineData.squadIsMoving(unit)
    return unit:IsSquadMoving()
end

-- Read: turns left on the in-progress squad move, recomputed live against the
-- stored destination. 0 when the squad is not moving.
function EngineData.squadTurnsRemaining(unit)
    return unit:GetSquadTurnsRemaining()
end

-- Mutation (synced): cancel the in-progress squad move -- clear the destination
-- on all members and stop their missions.
function EngineData.cancelSquadMove(unit)
    unit:CancelSquadMove()
end

-- Mutation (synced): set the squad's end-of-move behavior for every member
-- (0 sentry on arrival, 1 wake on arrival, 2 wake when all arrive).
function EngineData.setSquadEndMovementMode(unit, mode)
    unit:SetSquadEndMovementType(mode)
end

-- Read: is the unit bound into an escort / linked group, moving as one
-- protected stack? IsLinked is set on every member of a squad escort move
-- (combat units and the non-combat units they shield) and cleared on arrival.
-- Drives the per-unit "escorted" status token.
function EngineData.unitIsLinked(unit)
    return unit:IsLinked()
end

-- Read: the squad's committed move objective plot, or nil when none is set.
-- The destination is fanned to every member, so it reads off any member.
-- Drives the destination readout on the squad movement line. Guarded against a
-- fork DLL predating the GetSquadDestination binding so a stale deploy degrades
-- to no destination rather than erroring.
function EngineData.squadDestination(unit)
    if unit.GetSquadDestination == nil then
        return nil
    end
    return unit:GetSquadDestination()
end

-- Read: is the unit's squad set to wake only when the whole squad has arrived
-- (the engine's WAKE_ON_ALL_ARRIVED == 2 end-movement mode)? This is the
-- per-member value TryEndSquadMovement reads to decide whether an arrived
-- member holds for stragglers, so the holding token reads it directly instead
-- of the roster's squad-level intent (which can drift if the user-data store is
-- lost). Guarded against a fork DLL predating the GetSquadEndMovementType
-- binding so a stale deploy degrades to no holding token rather than erroring.
function EngineData.squadWaitsForAll(unit)
    if unit.GetSquadEndMovementType == nil then
        return false
    end
    return unit:GetSquadEndMovementType() == 2
end
