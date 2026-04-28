-- Pure formatters that turn a unit (and action payloads) into speech.
-- No event registration, no listeners, no state -- every call re-reads
-- the unit so stale speech can't leak through a cached format.
--
-- The selection / info functions own the shape of "what the player hears
-- about a unit." UnitControl's UnitSelectionChanged handler calls
-- selection() with the pre-move cursor coords so the direction prefix
-- ("3e, 2se warrior ...") lets the user keep their spatial orientation
-- even when the camera jumps to a newly-activated unit mid-turn.
--
-- Status cascade mirrors base-game UnitList.lua:147-200, which is the
-- canonical ordering across every vanilla / Expansion2 build:
--     garrisoned -> automated -> healing -> alert -> fortified ->
--     sleeping -> building -> queued move. Embarkation is a name prefix
--     (compound phrase "embarked warrior"), not a status rung. "queued
--     move" is mod-added: base UnitList has no rung for a unit mid-
--     execution on a multi-turn mission because the sighted cue is the
--     on-map path line. For a selectable player unit that falls through
--     to this rung, the engine mission is MISSION_MOVE_TO / ROUTE_TO
--     (build missions get caught by the build rung; one-shot missions
--     resolve within the turn). With waypoints computed by WaypointsCore
--     we can name the destination as a direction prefix ("3e 2se") and
--     the total turn count; bare "queued move" is the fallback when the
--     queue's path-bearing legs all fail to resolve a path.

UnitSpeech = {}

-- Always the civ-adjective form ("Roman Warrior"), even for the active
-- player's own units, mirroring PlotSectionUnits.unitDescription. Civ
-- identity is what disambiguates units of identical type across players,
-- and the alternative GetNickName placeholder ("Player N" / profile
-- name) leaks the user's own name into every announcement of their own
-- unit. Returns "" when the owner can't be resolved so callers fall back
-- to their existing empty-name handling.
local function unitName(unit)
    local owner = Players[unit:GetOwner()]
    if owner == nil then
        return ""
    end
    return Text.format(
        "TXT_KEY_PLOTROLL_UNIT_DESCRIPTION_CIV",
        owner:GetCivilizationAdjectiveKey(),
        unit:GetNameKey()
    )
end

-- Base name with the "embarked" compound prefix when the unit is at sea.
-- Both selection() and info() decorate the same way; the prefix only
-- fires when the name itself resolves so a degenerate GameInfo miss
-- can't leave a dangling "embarked " with nothing behind it.
local function nameWithEmbarked(unit)
    local name = unitName(unit)
    if name == "" then
        return ""
    end
    if unit:IsEmbarked() then
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_EMBARKED_PREFIX") .. " " .. name
    end
    return name
end

local function movesFraction(unit)
    local denom = GameDefines.MOVE_DENOMINATOR
    local cur = math.floor(unit:MovesLeft() / denom)
    local maxMoves = math.floor(unit:MaxMoves() / denom)
    return Text.format("TXT_KEY_CIVVACCESS_UNIT_MOVES_FRACTION", cur, maxMoves)
end

-- Aircraft replacement for the moves fraction. Each aircraft action
-- (strike, rebase, sweep) ends in CvUnit::finishMoves so the MovesLeft
-- value is a degenerate "has acted this turn" binary, not a movement
-- budget -- base UnitPanel.lua's DOMAIN_AIR branch drops the fraction
-- and shows strike range instead, with the strike+rebase pair in the
-- tooltip. We mirror that: speak both reach values directly. Rebase
-- range is read live from GameDefines.AIR_UNIT_REBASE_RANGE_MULTIPLIER
-- (engine default 200) rather than hardcoded so a mod that changes the
-- define would still announce the correct number.
local function airRangeToken(unit)
    local strike = unit:Range()
    local rebase = math.floor(strike * GameDefines.AIR_UNIT_REBASE_RANGE_MULTIPLIER / 100)
    return Text.format("TXT_KEY_CIVVACCESS_UNIT_AIR_RANGE", strike, rebase)
end

local function isAir(unit)
    return unit:GetDomainType() == DomainTypes.DOMAIN_AIR
end

local function reachToken(unit)
    if isAir(unit) then
        return airRangeToken(unit)
    end
    return movesFraction(unit)
end

local function hpFraction(unit)
    local maxHP = GameDefines.MAX_HIT_POINTS
    return Text.format("TXT_KEY_CIVVACCESS_UNIT_HP_FRACTION", maxHP - unit:GetDamage(), maxHP)
end

local function isFriendly(unit)
    return unit:GetTeam() == Game.GetActiveTeam()
end

-- "Done for the turn" signal for friendly aircraft. With the moves
-- fraction dropped from the aircraft readout, the user has no other
-- way to hear that a fighter / bomber has used its action this turn.
-- Strike / rebase / sweep all end in CvUnit::finishMoves so MovesLeft
-- == 0 is the reliable check. Interception is still possible from this
-- state, but the player can't initiate anything else, which matches
-- what "out of moves" conveys.
local function airOutOfMovesToken(unit)
    if not isAir(unit) or not isFriendly(unit) then
        return ""
    end
    if unit:MovesLeft() > 0 then
        return ""
    end
    return Text.key("TXT_KEY_CIVVACCESS_UNIT_OUT_OF_MOVES")
end

-- IsOutOfAttacks returns true once the unit has used its per-turn attack
-- budget (1 by default; 2 with Blitz). Civilians have a 0-attack budget,
-- so the engine returns true for them too -- gate on IsCombatUnit so we
-- don't speak "out of attacks" on a Settler. The MovesLeft > 0 gate
-- suppresses the redundant case: every attack consumes moves, so a
-- 0-moves unit can't attack regardless of its attack budget, and the
-- moves fraction already conveys that. The token is only actionable
-- when moves remain -- the user can reposition but not strike.
local function isOutOfAttacks(unit)
    return unit:IsCombatUnit() and unit:MovesLeft() > 0 and unit:IsOutOfAttacks()
end

-- Returns the first matching status token (localized string), or "".
-- Friendly units run the full cascade from base UnitList.lua so e.g. a
-- garrisoned unit sitting on fortify turns speaks "garrison" -- the more
-- specific rung wins. Enemies surface fortified only, mirroring
-- UnitFlagManager's flag-texture cascade: the shield-shaped fortify flag
-- is the one status rung sighted players can read off a foreign unit;
-- sleep / alert / heal / automate / build only render in the owning
-- player's UnitList panel.
local function statusToken(unit)
    if not isFriendly(unit) then
        if unit:GetFortifyTurns() > 0 then
            return Text.key("TXT_KEY_UNIT_STATUS_FORTIFIED")
        end
        return ""
    end
    if unit:IsGarrisoned() then
        return Text.key("TXT_KEY_MISSION_GARRISON")
    end
    if unit:IsAutomated() then
        if unit:IsWork() then
            return Text.key("TXT_KEY_ACTION_AUTOMATE_BUILD")
        end
        if unit:IsTrade() then
            return Text.key("TXT_KEY_ACTION_AUTOMATE_TRADE")
        end
        return Text.key("TXT_KEY_ACTION_AUTOMATE_EXPLORE")
    end
    local activity = unit:GetActivityType()
    if activity == ActivityTypes.ACTIVITY_HEAL then
        return Text.key("TXT_KEY_MISSION_HEAL")
    end
    if activity == ActivityTypes.ACTIVITY_SENTRY then
        return Text.key("TXT_KEY_MISSION_ALERT")
    end
    if unit:GetFortifyTurns() > 0 then
        return Text.key("TXT_KEY_UNIT_STATUS_FORTIFIED")
    end
    if activity == ActivityTypes.ACTIVITY_SLEEP then
        return Text.key("TXT_KEY_MISSION_SLEEP")
    end
    local buildType = unit:GetBuildType()
    if buildType ~= -1 then
        local buildRow = GameInfo.Builds[buildType]
        if buildRow == nil then
            Log.warn("UnitSpeech: GetBuildType returned unknown id " .. tostring(buildType))
            return ""
        end
        -- Engine adds +1 to turns-left (see UnitPanel.lua:392) so a
        -- build finishing at end-of-turn reads as 1 rather than 0.
        local turns = unit:GetPlot():GetBuildTurnsLeft(buildType, Game.GetActivePlayer(), 0, 0) + 1
        return Text.format("TXT_KEY_CIVVACCESS_UNIT_STATUS_BUILDING", Text.key(buildRow.Description), turns)
    end
    if activity == ActivityTypes.ACTIVITY_MISSION then
        -- Waypoints.finalAndTurns reads the cached queue waypoints for
        -- the active selected unit. statusToken is also called from
        -- PlotSectionUnits against arbitrary units on the cursor plot;
        -- the cache only matches the head-selected unit, so an unselected
        -- friendly mid-mission falls through to the bare queued rung.
        local head = UI.GetHeadSelectedUnit()
        if head ~= nil and head:GetID() == unit:GetID() then
            local fin = Waypoints.finalAndTurns()
            if fin ~= nil then
                local dir = HexGeom.directionString(unit:GetX(), unit:GetY(), fin.x, fin.y)
                if dir ~= "" then
                    return Text.format("TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED_TO", dir, fin.turns)
                end
            end
        end
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED")
    end
    return ""
end

-- Counts cargo aircraft sitting on a carrier. Mirrors UnitFlagManager's
-- UpdateCargo iteration: walks plot:GetNumUnits, keeping units with
-- IsCargo and a matching transport id. No extra IsInvisible filter --
-- the engine's plot enumeration already gates by what the active player
-- can see, and base game's cargo dropdown does no further filtering, so
-- our announcement matches what a sighted player hears.
local function cargoAircraftCount(carrier)
    local plot = carrier:GetPlot()
    local count = 0
    local n = plot:GetNumUnits()
    local carrierId = carrier:GetID()
    for i = 0, n - 1 do
        local u = plot:GetUnit(i)
        if u ~= nil and u:IsCargo() then
            local transport = u:GetTransportUnit()
            if transport ~= nil and transport:GetID() == carrierId then
                count = count + 1
            end
        end
    end
    return count
end

-- Public: "X/Y aircraft" for a unit with cargo capacity, or "" when the
-- unit can't carry aircraft. Always speaks when capacity > 0 so empty
-- carriers still announce 0/3 -- the user wants to know capacity even
-- when nothing is loaded.
function UnitSpeech.cargoAircraftToken(unit)
    local capacity = unit:CargoSpace()
    if capacity <= 0 then
        return ""
    end
    local count = cargoAircraftCount(unit)
    return Text.format("TXT_KEY_CIVVACCESS_AIRCRAFT_COUNT", count, capacity)
end

-- City air capacity: BASE_CITY_AIR_STACKING + sum of AirModifier across
-- buildings the city has. Mirrors CvCity::GetMaxAirUnits exactly: the
-- engine seeds m_iMaxAirUnits to the base define on construction and
-- adjusts via ChangeMaxAirUnits(pBuildingInfo->GetAirModifier() * iChange)
-- whenever a building is gained or lost (CvCity.cpp:5901). No other
-- source of variation in vanilla / G&K / BNW.
local function cityMaxAir(city)
    local total = GameDefines.BASE_CITY_AIR_STACKING
    for row in GameInfo.Buildings() do
        local mod = row.AirModifier
        if mod ~= nil and mod ~= 0 and city:IsHasBuilding(row.ID) then
            total = total + mod
        end
    end
    return total
end

-- Counts DOMAIN_AIR units on a city plot. Matches UpdateCityCargo's
-- iteration in UnitFlagManager: every air unit on the tile counts,
-- including cargo of a docked carrier -- base game's city flag uses the
-- same flat domain check and we mirror it for parity.
local function cityAircraftCount(plot)
    local count = 0
    local n = plot:GetNumUnits()
    for i = 0, n - 1 do
        local u = plot:GetUnit(i)
        if u ~= nil and u:GetDomainType() == DomainTypes.DOMAIN_AIR then
            count = count + 1
        end
    end
    return count
end

-- Public: "X/Y aircraft" for a city plot when at least one aircraft is
-- stationed; "" otherwise. The X > 0 gate is intentional: most cities
-- have no aircraft and announcing 0/6 on every city tile would be spam.
function UnitSpeech.cityAircraftToken(plot)
    if not plot:IsCity() then
        return ""
    end
    local count = cityAircraftCount(plot)
    if count == 0 then
        return ""
    end
    local capacity = cityMaxAir(plot:GetPlotCity())
    return Text.format("TXT_KEY_CIVVACCESS_AIRCRAFT_COUNT", count, capacity)
end

-- Builds the selection announce string.
function UnitSpeech.selection(unit, prevX, prevY)
    local parts = {}
    local cx, cy = unit:GetX(), unit:GetY()
    if prevX ~= nil and prevY ~= nil then
        local dir = HexGeom.directionString(prevX, prevY, cx, cy)
        if dir ~= "" then
            parts[#parts + 1] = dir
        end
    end
    local name = nameWithEmbarked(unit)
    if name ~= "" then
        parts[#parts + 1] = name
    end
    if unit:GetDamage() > 0 then
        parts[#parts + 1] = hpFraction(unit)
    end
    parts[#parts + 1] = reachToken(unit)
    local outOfMoves = airOutOfMovesToken(unit)
    if outOfMoves ~= "" then
        parts[#parts + 1] = outOfMoves
    end
    if isFriendly(unit) and isOutOfAttacks(unit) then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_UNIT_OUT_OF_ATTACKS")
    end
    if unit:CanPromote() then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_UNIT_PROMOTION_AVAILABLE")
    end
    local status = statusToken(unit)
    if status ~= "" then
        parts[#parts + 1] = status
    end
    local cargo = UnitSpeech.cargoAircraftToken(unit)
    if cargo ~= "" then
        parts[#parts + 1] = cargo
    end
    return table.concat(parts, ", ")
end

local function promotionList(unit)
    local names = {}
    for promo in GameInfo.UnitPromotions() do
        if unit:IsHasPromotion(promo.ID) then
            names[#names + 1] = Text.key(promo.Description)
        end
    end
    return names
end

-- Flat info dump scoped by unit ownership so blind players hear what
-- sighted players see on the unit flag and EnemyUnitPanel rather than
-- the full own-unit tooltip. Friendlies (own or same-team) get the deep
-- dump: embarked-prefixed name, combat, ranged + range, moves fraction,
-- out-of-attacks (when spent), status, level / xp, promotions, upgrade
-- target + cost, HP. Visible enemies get the subset sighted players can
-- read off a foreign flag / EnemyUnitPanel: embarked-prefixed name,
-- combat, ranged (no range), moves fraction, fortified only, promotions,
-- HP. HP is the same exact fraction for both -- sighted players get a
-- numeric HP readout off any unit's plot hover tooltip
-- (PlotMouseoverInclude.lua), so there's no parity reason to coarsen
-- enemy HP into a band. Zero-valued strength fields skip so melee units
-- don't waste syllables on "0 ranged". Out-of-attacks is friendly-only:
-- the engine flag is queryable for foreigners but isn't visible on a
-- sighted unit flag, so parity says we don't speak it for them.
-- Upgrade is gated on CanUpgradeRightNow(1) -- the bOnlyTestVisible arg
-- (engine wants a number, not a Lua boolean; passing `true` throws)
-- skips transient conditions (territory, gold, resources, ...) so a
-- tech-unlocked upgrade still speaks for a unit in enemy land the
-- player may want to bring home; tech-locked targets stay silent so we
-- don't spam an unactionable cost. HP stays the final token.
function UnitSpeech.info(unit)
    local parts = {}
    local friendly = isFriendly(unit)
    local name = nameWithEmbarked(unit)
    if name ~= "" then
        parts[#parts + 1] = name
    end
    local combat = unit:GetBaseCombatStrength()
    if combat > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_COMBAT_STRENGTH", combat)
    end
    local ranged = unit:GetBaseRangedCombatStrength()
    if ranged > 0 then
        -- Aircraft surface range alongside rebase range in the reach token
        -- below, so the strength line drops the embedded range to avoid
        -- speaking it twice.
        if friendly and not isAir(unit) then
            parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_RANGED_STRENGTH", ranged, unit:Range())
        else
            parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_RANGED_STRENGTH_ONLY", ranged)
        end
    end
    parts[#parts + 1] = reachToken(unit)
    local outOfMoves = airOutOfMovesToken(unit)
    if outOfMoves ~= "" then
        parts[#parts + 1] = outOfMoves
    end
    if friendly and isOutOfAttacks(unit) then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_UNIT_OUT_OF_ATTACKS")
    end
    local status = statusToken(unit)
    if status ~= "" then
        parts[#parts + 1] = status
    end
    if friendly and unit:IsCombatUnit() then
        parts[#parts + 1] = Text.format(
            "TXT_KEY_CIVVACCESS_UNIT_LEVEL_XP",
            unit:GetLevel(),
            unit:GetExperience(),
            unit:ExperienceNeeded()
        )
    end
    local promos = promotionList(unit)
    if #promos > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_PROMOTIONS_LABEL", table.concat(promos, ", "))
    end
    if friendly and unit:CanUpgradeRightNow(1) then
        local upgradeType = unit:GetUpgradeUnitType()
        if upgradeType ~= -1 then
            local upgradeRow = GameInfo.Units[upgradeType]
            if upgradeRow == nil then
                Log.warn("UnitSpeech.info: GetUpgradeUnitType returned unknown id " .. tostring(upgradeType))
            else
                parts[#parts + 1] = Text.format(
                    "TXT_KEY_CIVVACCESS_UNIT_UPGRADE",
                    Text.key(upgradeRow.Description),
                    unit:UpgradePrice(upgradeType)
                )
            end
        end
    end
    local cargo = UnitSpeech.cargoAircraftToken(unit)
    if cargo ~= "" then
        parts[#parts + 1] = cargo
    end
    parts[#parts + 1] = hpFraction(unit)
    return table.concat(parts, ", ")
end

-- Look up a combatant's display name from a (playerId, unitId) pair.
-- Public so UnitControl can resolve names from the engine fork's
-- CombatResolved hook payload, which carries IDs rather than handles
-- because the unit object may already be flagged for deferred kill
-- by the time the listener runs.
function UnitSpeech.combatantName(playerId, unitId)
    local player = Players[playerId]
    if player == nil then
        return ""
    end
    local unit = player:GetUnitByID(unitId)
    if unit == nil then
        return ""
    end
    return unitName(unit)
end

-- Pre-resolved city display name for combat speech. Same role as
-- combatantName but for city defenders.
function UnitSpeech.cityCombatantName(playerId, cityId)
    local player = Players[playerId]
    if player == nil then
        return ""
    end
    local city = player:GetCityByID(cityId)
    if city == nil then
        return ""
    end
    return city:GetName()
end

-- Bidirectional damage preview for a melee attack by `actor` into
-- `defender` on `targetPlot`. Clones base-game EnemyUnitPanel.lua's
-- VSUnit melee branch: GetMaxAttackStrength / GetMaxDefenseStrength +
-- bidirectional GetCombatDamage, plus every per-side modifier the
-- panel lists and the overall combat-prediction verdict. Returns ""
-- when either side's strength resolves to 0 (caller speaks its own
-- "no target" fallback).
local COMBAT_PREDICTION_KEYS = {
    [CombatPredictionTypes.COMBAT_PREDICTION_TOTAL_VICTORY] = "TXT_KEY_EUPANEL_TOTAL_VICTORY",
    [CombatPredictionTypes.COMBAT_PREDICTION_MAJOR_VICTORY] = "TXT_KEY_EUPANEL_MAJOR_VICTORY",
    [CombatPredictionTypes.COMBAT_PREDICTION_SMALL_VICTORY] = "TXT_KEY_EUPANEL_MINOR_VICTORY",
    [CombatPredictionTypes.COMBAT_PREDICTION_STALEMATE] = "TXT_KEY_EUPANEL_STALEMATE",
    [CombatPredictionTypes.COMBAT_PREDICTION_SMALL_DEFEAT] = "TXT_KEY_EUPANEL_MINOR_DEFEAT",
    [CombatPredictionTypes.COMBAT_PREDICTION_MAJOR_DEFEAT] = "TXT_KEY_EUPANEL_MAJOR_DEFEAT",
    [CombatPredictionTypes.COMBAT_PREDICTION_TOTAL_DEFEAT] = "TXT_KEY_EUPANEL_TOTAL_DEFEAT",
}

local function predictionLabel(actor, defender)
    local p = Game.GetCombatPrediction(actor, defender)
    local key = COMBAT_PREDICTION_KEYS[p] or "TXT_KEY_EUPANEL_STALEMATE"
    return Locale.ToLower(Text.key(key))
end

-- Format `value` as a signed-percent-plus-label mod entry. `value` is
-- an engine-native integer percent (e.g. 15 for +15%, -33 for -33%).
-- Label is a base-game TXT_KEY_EUPANEL_* resolved via Locale and then
-- run through TextFilter to drop [ICON_*] / [COLOR_*] markup. Skips
-- zero modifiers and labels that resolve to empty after filtering.
local function pushMod(list, value, key, ...)
    if value == nil or value == 0 then
        return
    end
    local label = TextFilter.filter(Text.format(key, ...))
    if label == "" then
        return
    end
    if value > 0 then
        list[#list + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOD_POS", value, label)
    else
        list[#list + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MOD_NEG", -value, label)
    end
end

-- Attacker-side modifiers. Mirrors EnemyUnitPanel.lua:832-1249 branch
-- for branch. `bRanged` gates the melee-only branches (river / amphib /
-- flanking) and the ranged-only ones (GetRangedAttackModifier and the
-- open/rough ranged terrain bonuses). The base panel has one latent bug:
-- its friendly-territory check at line 939 passes an undefined local
-- `c` -- we pass the attacker's player id so the friendly-lands
-- attacker bonuses actually surface when they apply.
local function attackerMods(actor, defender, targetPlot, bRanged)
    local mods = {}
    local myPlayerId = actor:GetOwner()
    local theirPlayerId = defender:GetOwner()
    local myPlayer = Players[myPlayerId]
    local theirPlayer = Players[theirPlayerId]
    local fromPlot = actor:GetPlot()

    if not bRanged then
        if not actor:IsRiverCrossingNoPenalty() and fromPlot:IsRiverCrossingToPlot(targetPlot) then
            pushMod(mods, GameDefines.RIVER_ATTACK_MODIFIER, "TXT_KEY_EUPANEL_ATTACK_OVER_RIVER")
        end
        if
            not actor:IsAmphib()
            and not targetPlot:IsWater()
            and fromPlot:IsWater()
            and actor:GetDomainType() == DomainTypes.DOMAIN_LAND
        then
            pushMod(mods, GameDefines.AMPHIB_ATTACK_MODIFIER, "TXT_KEY_EUPANEL_AMPHIBIOUS_ATTACK")
        end
    end

    if actor:IsNearGreatGeneral() then
        local bonus = myPlayer:GetGreatGeneralCombatBonus() + myPlayer:GetTraitGreatGeneralExtraBonus()
        local key = actor:GetDomainType() == DomainTypes.DOMAIN_LAND and "TXT_KEY_EUPANEL_GG_NEAR"
            or "TXT_KEY_EUPANEL_GA_NEAR"
        pushMod(mods, bonus, key)
        if actor:IsIgnoreGreatGeneralBenefit() then
            pushMod(mods, -bonus, "TXT_KEY_EUPANEL_IGG")
        end
    end
    if actor:GetGreatGeneralCombatModifier() ~= 0 and actor:IsStackedGreatGeneral() then
        pushMod(mods, actor:GetGreatGeneralCombatModifier(), "TXT_KEY_EUPANEL_GG_STACKED")
    end
    pushMod(mods, actor:GetReverseGreatGeneralModifier(), "TXT_KEY_EUPANEL_REVERSE_GG_NEAR")
    pushMod(mods, actor:GetNearbyImprovementModifier(), "TXT_KEY_EUPANEL_IMPROVEMENT_NEAR")

    local attackTurns = myPlayer:GetAttackBonusTurns()
    if attackTurns > 0 then
        pushMod(mods, GameDefines.POLICY_ATTACK_BONUS_MOD, "TXT_KEY_EUPANEL_POLICY_ATTACK_BONUS", attackTurns)
    end

    if not bRanged then
        local adjFriends = defender:GetNumEnemyUnitsAdjacent(actor)
        if adjFriends > 0 then
            local flank = adjFriends * GameDefines.BONUS_PER_ADJACENT_FRIEND
            local flankMod = actor:FlankAttackModifier()
            if flankMod ~= 0 then
                flank = math.floor(flank * (100 + flankMod) / 100)
            end
            pushMod(mods, flank, "TXT_KEY_EUPANEL_FLANKING_BONUS")
        end
    end

    pushMod(mods, actor:GetExtraCombatPercent(), "TXT_KEY_EUPANEL_EXTRA_PERCENT")

    if targetPlot:IsFriendlyTerritory(myPlayerId) then
        pushMod(mods, actor:GetFriendlyLandsModifier(), "TXT_KEY_EUPANEL_FIGHT_AT_HOME_BONUS")
        pushMod(mods, actor:GetFriendlyLandsAttackModifier(), "TXT_KEY_EUPANEL_ATTACK_IN_FRIEND_LANDS")
        pushMod(
            mods,
            myPlayer:GetFoundedReligionFriendlyCityCombatMod(targetPlot),
            "TXT_KEY_EUPANEL_FRIENDLY_CITY_BELIEF_BONUS"
        )
    end

    if targetPlot:GetOwner() == myPlayerId then
        local techBonus = myPlayer:GetCombatBonusVsHigherTech()
        if techBonus ~= 0 and defender:IsHigherTechThan(actor:GetUnitType()) then
            pushMod(mods, techBonus, "TXT_KEY_EUPANEL_TRAIT_LOW_TECH_BONUS")
        end
    end

    local sizeBonus = myPlayer:GetCombatBonusVsLargerCiv()
    if sizeBonus ~= 0 and defender:IsLargerCivThan(actor) then
        pushMod(mods, sizeBonus, "TXT_KEY_EUPANEL_TRAIT_SMALL_SIZE_BONUS")
    end

    local capDef = actor:CapitalDefenseModifier()
    if capDef > 0 then
        local cap = myPlayer:GetCapitalCity()
        if cap ~= nil then
            local dist = Map.PlotDistance(cap:GetX(), cap:GetY(), actor:GetX(), actor:GetY())
            capDef = capDef + dist * actor:CapitalDefenseFalloff()
            if capDef > 0 then
                pushMod(mods, capDef, "TXT_KEY_EUPANEL_CAPITAL_DEFENSE_BONUS")
            end
        end
    end

    if not targetPlot:IsFriendlyTerritory(myPlayerId) then
        pushMod(mods, actor:GetOutsideFriendlyLandsModifier(), "TXT_KEY_EUPANEL_OUTSIDE_HOME_BONUS")
        pushMod(
            mods,
            myPlayer:GetFoundedReligionEnemyCityCombatMod(targetPlot),
            "TXT_KEY_EUPANEL_ENEMY_CITY_BELIEF_BONUS"
        )
    end

    local unhappy = actor:GetUnhappinessCombatPenalty()
    if unhappy ~= 0 then
        local key = myPlayer:IsEmpireVeryUnhappy() and "TXT_KEY_EUPANEL_EMPIRE_VERY_UNHAPPY_PENALTY"
            or "TXT_KEY_EUPANEL_EMPIRE_UNHAPPY_PENALTY"
        pushMod(mods, unhappy, key)
    end
    pushMod(mods, actor:GetStrategicResourceCombatPenalty(), "TXT_KEY_EUPANEL_STRATEGIC_RESOURCE")

    local adj = actor:GetAdjacentModifier()
    if adj ~= 0 and actor:IsFriendlyUnitAdjacent(true) then
        pushMod(mods, adj, "TXT_KEY_EUPANEL_ADJACENT_FRIEND_UNIT_BONUS")
    end
    pushMod(mods, actor:GetAttackModifier(), "TXT_KEY_EUPANEL_ATTACK_MOD_BONUS")

    local theirClass = defender:GetUnitClassType()
    local theirClassDesc = Text.key(GameInfo.UnitClasses[theirClass].Description)
    pushMod(mods, actor:GetUnitClassModifier(theirClass), "TXT_KEY_EUPANEL_BONUS_VS_CLASS", theirClassDesc)
    pushMod(mods, actor:UnitClassAttackModifier(theirClass), "TXT_KEY_EUPANEL_BONUS_VS_CLASS", theirClassDesc)
    if defender:GetUnitCombatType() ~= -1 then
        local combatDesc = Text.key(GameInfo.UnitCombatInfos[defender:GetUnitCombatType()].Description)
        pushMod(
            mods,
            actor:UnitCombatModifier(defender:GetUnitCombatType()),
            "TXT_KEY_EUPANEL_BONUS_VS_CLASS",
            combatDesc
        )
    end
    pushMod(mods, actor:DomainModifier(defender:GetDomainType()), "TXT_KEY_EUPANEL_BONUS_VS_DOMAIN")

    if defender:GetFortifyTurns() > 0 then
        pushMod(mods, actor:AttackFortifiedModifier(), "TXT_KEY_EUPANEL_BONUS_VS_FORT_UNITS")
    end
    if defender:GetDamage() > 0 then
        pushMod(mods, actor:AttackWoundedModifier(), "TXT_KEY_EUPANEL_BONUS_VS_WOUND_UNITS")
    end
    if targetPlot:IsHills() then
        pushMod(mods, actor:HillsAttackModifier(), "TXT_KEY_EUPANEL_HILL_ATTACK_BONUS")
    end
    if targetPlot:IsOpenGround() then
        pushMod(mods, actor:OpenAttackModifier(), "TXT_KEY_EUPANEL_OPEN_TERRAIN_BONUS")
        if bRanged then
            pushMod(mods, actor:OpenRangedAttackModifier(), "TXT_KEY_EUPANEL_OPEN_TERRAIN_RANGE_BONUS")
        end
    end
    if bRanged then
        pushMod(mods, actor:GetRangedAttackModifier(), "TXT_KEY_EUPANEL_RANGED_ATTACK_MODIFIER")
    end
    if targetPlot:IsRoughGround() then
        pushMod(mods, actor:RoughAttackModifier(), "TXT_KEY_EUPANEL_ROUGH_TERRAIN_BONUS")
        if bRanged then
            pushMod(mods, actor:RoughRangedAttackModifier(), "TXT_KEY_EUPANEL_ROUGH_TERRAIN_RANGED_BONUS")
        end
    end

    local featureType = targetPlot:GetFeatureType()
    if featureType ~= -1 then
        local featureDesc = Text.key(GameInfo.Features[featureType].Description)
        pushMod(mods, actor:FeatureAttackModifier(featureType), "TXT_KEY_EUPANEL_ATTACK_INTO_BONUS", featureDesc)
    else
        local terrainType = targetPlot:GetTerrainType()
        local terrainDesc = Text.key(GameInfo.Terrains[terrainType].Description)
        pushMod(mods, actor:TerrainAttackModifier(terrainType), "TXT_KEY_EUPANEL_ATTACK_INTO_BONUS", terrainDesc)
        if targetPlot:IsHills() then
            local hillId = GameInfo.Terrains.TERRAIN_HILL.ID
            local hillDesc = Text.key(GameInfo.Terrains.TERRAIN_HILL.Description)
            pushMod(mods, actor:TerrainAttackModifier(hillId), "TXT_KEY_EUPANEL_ATTACK_INTO_BONUS", hillDesc)
        end
    end

    if defender:IsBarbarian() then
        local barb = GameInfo.HandicapInfos[Game:GetHandicapType()].BarbarianBonus + myPlayer:GetBarbarianCombatBonus()
        pushMod(mods, barb, "TXT_KEY_EUPANEL_VS_BARBARIANS_BONUS")
    end

    local goldenAge = myPlayer:GetTraitGoldenAgeCombatModifier()
    if goldenAge ~= 0 and myPlayer:IsGoldenAge() then
        pushMod(mods, goldenAge, "TXT_KEY_EUPANEL_BONUS_GOLDEN_AGE")
    end
    local csBonus = myPlayer:GetTraitCityStateCombatModifier()
    if csBonus ~= 0 and theirPlayer:IsMinorCiv() then
        pushMod(mods, csBonus, "TXT_KEY_EUPANEL_BONUS_CITY_STATE")
    end

    return mods
end

-- Defender-side modifiers. Mirrors EnemyUnitPanel.lua:1281-1639 melee
-- branch. Only runs when the defender is a combat unit; civilian-only
-- plots have no counter-strength to modify.
local function defenderMods(actor, defender, targetPlot)
    if not defender:IsCombatUnit() then
        return {}
    end
    local mods = {}
    local theirPlayerId = defender:GetOwner()
    local theirPlayer = Players[theirPlayerId]

    local unhappy = defender:GetUnhappinessCombatPenalty()
    if unhappy ~= 0 then
        local key = theirPlayer:IsEmpireVeryUnhappy() and "TXT_KEY_EUPANEL_EMPIRE_VERY_UNHAPPY_PENALTY"
            or "TXT_KEY_EUPANEL_EMPIRE_UNHAPPY_PENALTY"
        pushMod(mods, unhappy, key)
    end
    pushMod(mods, defender:GetStrategicResourceCombatPenalty(), "TXT_KEY_EUPANEL_STRATEGIC_RESOURCE")

    local adj = defender:GetAdjacentModifier()
    if adj ~= 0 and defender:IsFriendlyUnitAdjacent(true) then
        pushMod(mods, adj, "TXT_KEY_EUPANEL_ADJACENT_FRIEND_UNIT_BONUS")
    end

    local plotDef = targetPlot:DefenseModifier(defender:GetTeam(), false, false)
    if plotDef < 0 or not defender:NoDefensiveBonus() then
        pushMod(mods, plotDef, "TXT_KEY_EUPANEL_TERRAIN_MODIFIER")
    end
    pushMod(mods, defender:FortifyModifier(), "TXT_KEY_EUPANEL_FORTIFICATION_BONUS")

    if defender:IsNearGreatGeneral() then
        local bonus = theirPlayer:GetGreatGeneralCombatBonus() + theirPlayer:GetTraitGreatGeneralExtraBonus()
        local key = defender:GetDomainType() == DomainTypes.DOMAIN_LAND and "TXT_KEY_EUPANEL_GG_NEAR"
            or "TXT_KEY_EUPANEL_GA_NEAR"
        pushMod(mods, bonus, key)
        if defender:IsIgnoreGreatGeneralBenefit() then
            pushMod(mods, -bonus, "TXT_KEY_EUPANEL_IGG")
        end
    end
    if defender:GetGreatGeneralCombatModifier() ~= 0 and defender:IsStackedGreatGeneral() then
        pushMod(mods, defender:GetGreatGeneralCombatModifier(), "TXT_KEY_EUPANEL_GG_STACKED")
    end
    pushMod(mods, defender:GetReverseGreatGeneralModifier(), "TXT_KEY_EUPANEL_REVERSE_GG_NEAR")
    pushMod(mods, defender:GetNearbyImprovementModifier(), "TXT_KEY_EUPANEL_IMPROVEMENT_NEAR")

    local adjEnemies = actor:GetNumEnemyUnitsAdjacent(defender)
    if adjEnemies > 0 then
        pushMod(mods, adjEnemies * GameDefines.BONUS_PER_ADJACENT_FRIEND, "TXT_KEY_EUPANEL_FLANKING_BONUS")
    end

    pushMod(mods, defender:GetExtraCombatPercent(), "TXT_KEY_EUPANEL_EXTRA_PERCENT")

    if targetPlot:IsFriendlyTerritory(theirPlayerId) then
        pushMod(mods, defender:GetFriendlyLandsModifier(), "TXT_KEY_EUPANEL_FIGHT_AT_HOME_BONUS")
        pushMod(
            mods,
            theirPlayer:GetFoundedReligionFriendlyCityCombatMod(targetPlot),
            "TXT_KEY_EUPANEL_FRIENDLY_CITY_BELIEF_BONUS"
        )
    end
    if not targetPlot:IsFriendlyTerritory(theirPlayerId) then
        pushMod(mods, defender:GetOutsideFriendlyLandsModifier(), "TXT_KEY_EUPANEL_OUTSIDE_HOME_BONUS")
        pushMod(
            mods,
            theirPlayer:GetFoundedReligionEnemyCityCombatMod(targetPlot),
            "TXT_KEY_EUPANEL_ENEMY_CITY_BELIEF_BONUS"
        )
    end

    pushMod(mods, defender:GetDefenseModifier(), "TXT_KEY_EUPANEL_DEFENSE_BONUS")

    local myClass = actor:GetUnitClassType()
    local myClassDesc = Text.key(GameInfo.UnitClasses[myClass].Description)
    pushMod(mods, defender:UnitClassDefenseModifier(myClass), "TXT_KEY_EUPANEL_BONUS_VS_CLASS", myClassDesc)
    if actor:GetUnitCombatType() ~= -1 then
        local combatDesc = Text.key(GameInfo.UnitCombatInfos[actor:GetUnitCombatType()].Description)
        pushMod(
            mods,
            defender:UnitCombatModifier(actor:GetUnitCombatType()),
            "TXT_KEY_EUPANEL_BONUS_VS_CLASS",
            combatDesc
        )
    end
    pushMod(mods, defender:DomainModifier(actor:GetDomainType()), "TXT_KEY_EUPANEL_BONUS_VS_DOMAIN")

    if targetPlot:IsHills() then
        pushMod(mods, defender:HillsDefenseModifier(), "TXT_KEY_EUPANEL_HILL_DEFENSE_BONUS")
    end
    if targetPlot:IsOpenGround() then
        pushMod(mods, defender:OpenDefenseModifier(), "TXT_KEY_EUPANEL_OPEN_TERRAIN_DEF_BONUS")
    end
    if targetPlot:IsRoughGround() then
        pushMod(mods, defender:RoughDefenseModifier(), "TXT_KEY_EUPANEL_ROUGH_TERRAIN_DEF_BONUS")
    end

    if targetPlot:GetOwner() == theirPlayerId then
        local techBonus = theirPlayer:GetCombatBonusVsHigherTech()
        if techBonus ~= 0 and actor:IsHigherTechThan(defender:GetUnitType()) then
            pushMod(mods, techBonus, "TXT_KEY_EUPANEL_TRAIT_LOW_TECH_BONUS")
        end
    end
    local sizeBonus = theirPlayer:GetCombatBonusVsLargerCiv()
    if sizeBonus ~= 0 and actor:IsLargerCivThan(defender) then
        pushMod(mods, sizeBonus, "TXT_KEY_EUPANEL_TRAIT_SMALL_SIZE_BONUS")
    end

    local capDef = defender:CapitalDefenseModifier()
    if capDef > 0 then
        local cap = theirPlayer:GetCapitalCity()
        if cap ~= nil then
            local dist = Map.PlotDistance(cap:GetX(), cap:GetY(), defender:GetX(), defender:GetY())
            capDef = capDef + dist * defender:CapitalDefenseFalloff()
            if capDef > 0 then
                pushMod(mods, capDef, "TXT_KEY_EUPANEL_CAPITAL_DEFENSE_BONUS")
            end
        end
    end

    local featureType = targetPlot:GetFeatureType()
    if featureType ~= -1 then
        local featureDesc = Text.key(GameInfo.Features[featureType].Description)
        pushMod(
            mods,
            defender:FeatureDefenseModifier(featureType),
            "TXT_KEY_EUPANEL_BONUS_DEFENSE_TERRAIN",
            featureDesc
        )
    else
        local terrainType = targetPlot:GetTerrainType()
        local terrainDesc = Text.key(GameInfo.Terrains[terrainType].Description)
        pushMod(
            mods,
            defender:TerrainDefenseModifier(terrainType),
            "TXT_KEY_EUPANEL_BONUS_DEFENSE_TERRAIN",
            terrainDesc
        )
        if targetPlot:IsHills() then
            local hillId = GameInfo.Terrains.TERRAIN_HILL.ID
            local hillDesc = Text.key(GameInfo.Terrains.TERRAIN_HILL.Description)
            pushMod(mods, defender:TerrainDefenseModifier(hillId), "TXT_KEY_EUPANEL_BONUS_DEFENSE_TERRAIN", hillDesc)
        end
    end

    local goldenAge = theirPlayer:GetTraitGoldenAgeCombatModifier()
    if goldenAge ~= 0 and theirPlayer:IsGoldenAge() then
        pushMod(mods, goldenAge, "TXT_KEY_EUPANEL_BONUS_GOLDEN_AGE")
    end

    return mods
end

function UnitSpeech.meleePreview(actor, defender, targetPlot)
    local support = actor:GetFireSupportUnit(defender:GetOwner(), targetPlot:GetX(), targetPlot:GetY())
    local supportDmg = 0
    if support ~= nil then
        supportDmg = support:GetRangeCombatDamage(actor, nil, false)
    end

    local myStrength = actor:GetMaxAttackStrength(actor:GetPlot(), targetPlot, defender)
    local theirStrength = defender:GetMaxDefenseStrength(targetPlot, actor)
    if myStrength <= 0 or theirStrength <= 0 then
        return ""
    end
    local myDmg = actor:GetCombatDamage(myStrength, theirStrength, actor:GetDamage() + supportDmg, false, false, false)
    local theirDmg = defender:GetCombatDamage(theirStrength, myStrength, defender:GetDamage(), false, false, false)
        + supportDmg

    local name = unitName(defender)
    local myStr = Locale.ToNumber(myStrength / 100, "#.##")
    local theirStr = Locale.ToNumber(theirStrength / 100, "#.##")
    local result = predictionLabel(actor, defender)

    local parts =
        { Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK", name, myStr, theirStr, result, theirDmg, myDmg) }

    if supportDmg > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_SUPPORT_FIRE", supportDmg)
    end
    local capture = actor:GetCaptureChance(defender)
    if capture > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_CAPTURE_CHANCE", capture)
    end

    local mine = attackerMods(actor, defender, targetPlot, false)
    if #mine > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MODS_MY", table.concat(mine, ", "))
    end
    local theirs = defenderMods(actor, defender, targetPlot)
    if #theirs > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MODS_THEIR", table.concat(theirs, ", "))
    end

    return table.concat(parts, ", ")
end

-- Ranged preview. Clones the bRanged branch of EnemyUnitPanel.lua's
-- UpdateCombatOddsUnitVsUnit: GetMaxRangedCombatStrength for the
-- attacker; for the defender, GetEmbarkedUnitDefense when embarked,
-- GetMaxRangedCombatStrength otherwise, falling back to
-- GetMaxDefenseStrength when the defender has no ranged strength /
-- is a sea unit / is a support-fire unit. Air attackers also preview
-- intercept damage and the visible interceptor count.
function UnitSpeech.rangedPreview(actor, defender, targetPlot)
    local myStrength = actor:GetMaxRangedCombatStrength(defender, nil, true, true)
    if myStrength <= 0 then
        return ""
    end
    local myDmg = actor:GetRangeCombatDamage(defender, nil, false)

    local theirStrength
    if defender:IsEmbarked() then
        theirStrength = defender:GetEmbarkedUnitDefense()
    else
        theirStrength = defender:GetMaxRangedCombatStrength(actor, nil, false, true)
    end
    if theirStrength == 0 or defender:GetDomainType() == DomainTypes.DOMAIN_SEA or defender:IsRangedSupportFire() then
        theirStrength = defender:GetMaxDefenseStrength(targetPlot, actor, true)
    end

    local theirDmg = 0
    local interceptors = 0
    if actor:GetDomainType() == DomainTypes.DOMAIN_AIR then
        theirDmg = defender:GetAirStrikeDefenseDamage(actor, false)
        interceptors = actor:GetInterceptorCount(targetPlot, defender, true, true)
    end

    local name = unitName(defender)
    local myStr = Locale.ToNumber(myStrength / 100, "#.##")
    local theirStr = Locale.ToNumber(theirStrength / 100, "#.##")
    local result = predictionLabel(actor, defender)

    local parts = { Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RANGED", name, myStr, theirStr, result, myDmg) }

    if theirDmg > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RETALIATE", theirDmg)
    end
    -- The base "Air Intercept Warning" line (TXT_KEY_EUPANEL_AIR_INTERCEPT_
    -- WARNING1+2 = "Interception by fighter or anti-air will boost damage")
    -- fires unconditionally for air strikes -- a class-mechanics note, not a
    -- per-strike threat. Compressed to terse speech ("intercept possible")
    -- it reads as a per-strike prediction and misleads. The visible
    -- interceptor count below is the materially per-strike signal; once a
    -- player understands air combat the class warning adds noise without
    -- information.
    if interceptors > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_INTERCEPTORS", interceptors)
    end

    local mine = attackerMods(actor, defender, targetPlot, true)
    if #mine > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MODS_MY", table.concat(mine, ", "))
    end
    local theirs = defenderMods(actor, defender, targetPlot)
    if #theirs > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_MODS_THEIR", table.concat(theirs, ", "))
    end

    return table.concat(parts, ", ")
end

-- Bidirectional damage preview for a melee attack by `actor` into a
-- `city`. Mirrors EnemyUnitPanel.lua's VS_City melee branch
-- (line ~309-352): GetMaxAttackStrength against a nil unit + city plot,
-- city's GetStrengthValue for defense, plus the bAttackerIsCity /
-- bDefenderIsCity boolean flags GetCombatDamage takes for unit-vs-city
-- combat math. Cities don't take fire-support hits (they are the
-- defender, not adjacent to one), but the attacker can if the city
-- has a friend nearby that fires support; mirrored from base.
function UnitSpeech.cityMeleePreview(actor, city, targetPlot)
    local fromPlot = actor:GetPlot()

    local fireSupport = actor:GetFireSupportUnit(city:GetOwner(), targetPlot:GetX(), targetPlot:GetY())
    local fireSupportDmg = 0
    if fireSupport ~= nil then
        fireSupportDmg = fireSupport:GetRangeCombatDamage(actor, nil, false)
    end

    local myStrength = actor:GetMaxAttackStrength(fromPlot, targetPlot, nil)
    local theirStrength = city:GetStrengthValue()
    if myStrength <= 0 or theirStrength <= 0 then
        return ""
    end
    local myDmg =
        actor:GetCombatDamage(myStrength, theirStrength, actor:GetDamage() + fireSupportDmg, false, false, true)
    local theirDmg = actor:GetCombatDamage(theirStrength, myStrength, city:GetDamage(), false, true, false)
        + fireSupportDmg

    local maxCityHP = city:GetMaxHitPoints()
    if myDmg > maxCityHP then
        myDmg = maxCityHP
    end
    local maxUnitHP = GameDefines.MAX_HIT_POINTS
    if theirDmg > maxUnitHP then
        theirDmg = maxUnitHP
    end

    local name = city:GetName()
    local myStr = Locale.ToNumber(myStrength / 100, "#.##")
    local theirStr = Locale.ToNumber(theirStrength / 100, "#.##")

    local parts = {
        Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK_CITY", name, myStr, theirStr, theirDmg, myDmg),
    }
    if fireSupportDmg > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_SUPPORT_FIRE", fireSupportDmg)
    end
    return table.concat(parts, ", ")
end

-- Ranged variant of cityMeleePreview. Mirrors the bRanged branch of
-- EnemyUnitPanel.lua's city block (line ~305): GetMaxRangedCombatStrength
-- + GetRangeCombatDamage against the city. Air attackers get the city's
-- defensive air strike damage and visible interceptor count. No
-- fire-support: cities aren't adjacent to a defender that would fire on
-- behalf of the city in a ranged exchange.
function UnitSpeech.cityRangedPreview(actor, city, targetPlot)
    local myStrength = actor:GetMaxRangedCombatStrength(nil, city, true, true)
    if myStrength <= 0 then
        return ""
    end
    local myDmg = actor:GetRangeCombatDamage(nil, city, false)

    local theirStrength = city:GetStrengthValue()
    local theirDmg = 0
    local interceptors = 0
    if actor:GetDomainType() == DomainTypes.DOMAIN_AIR then
        theirDmg = city:GetAirStrikeDefenseDamage(actor, false)
        interceptors = actor:GetInterceptorCount(targetPlot, nil, true, true)
    end

    local maxCityHP = city:GetMaxHitPoints()
    if myDmg > maxCityHP then
        myDmg = maxCityHP
    end

    local name = city:GetName()
    local myStr = Locale.ToNumber(myStrength / 100, "#.##")
    local theirStr = Locale.ToNumber(theirStrength / 100, "#.##")

    local parts = {
        Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RANGED_CITY", name, myStr, theirStr, myDmg),
    }
    if theirDmg > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RETALIATE", theirDmg)
    end
    -- See rangedPreview for why the unconditional "intercept possible" line
    -- is dropped: terse speech turns the base game's mechanics-class note
    -- into a misleading per-strike prediction.
    if interceptors > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_INTERCEPTORS", interceptors)
    end
    return table.concat(parts, ", ")
end

-- Formats a combat outcome into "attacker <name> -N hp, defender <name>
-- -M hp[, <name> killed]". Caller pre-resolves the side names via
-- UnitSpeech.combatantName / cityCombatantName so the formatter doesn't
-- have to re-look-up handles that may already be gone (a killed unit's
-- handle may be invalidated by deferred kill by the time the listener
-- runs). args.attackerDamage / defenderDamage are damage dealt THIS
-- combat; FinalDamage is cumulative damage after combat (kill check
-- uses it against MaxHP). Caller doesn't subtract -- pass the per-
-- combat delta.
function UnitSpeech.combatResult(args)
    local atkName = args.attackerName or ""
    local defName = args.defenderName or ""
    local atkDamage = args.attackerDamage
    local defDamage = args.defenderDamage
    local parts = {}
    -- Air sweep prepends a sweep-kind word ("interception" / "dogfight")
    -- so the user knows the result they're hearing came from a sweep
    -- they triggered, not a regular ranged attack. Engine-side combatKind:
    --   1 = sweep into ground AA (one-sided exchange)
    --   2 = sweep into another fighter (two-sided dogfight)
    --   nil / 0 = normal melee / ranged / air strike (no prefix)
    if args.combatKind == 1 then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_COMBAT_PREFIX_INTERCEPTION")
    elseif args.combatKind == 2 then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_COMBAT_PREFIX_DOGFIGHT")
    end
    -- Both sides always speak so the user hears who fought even when one
    -- side took no damage -- ranged attacks routinely leave the attacker
    -- untouched, and the prior "skip if zero" silently dropped the
    -- attacker from the readout.
    if atkDamage > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_COMBAT_ATTACKER_DAMAGE", atkName, atkDamage)
    else
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_COMBAT_ATTACKER_UNHURT", atkName)
    end
    if defDamage > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_COMBAT_DEFENDER_DAMAGE", defName, defDamage)
    else
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_COMBAT_DEFENDER_UNHURT", defName)
    end
    -- Intercept clause sits between the damage lines and the kill lines:
    -- it qualifies why the attacker took the damage we just reported, and
    -- precedes any kill announcement so a "Bomber killed" line still ends
    -- the readout. Caller passes nil when no intercept landed; we don't
    -- announce attempts that dealt 0 damage (matches base game).
    if args.interceptorName ~= nil and args.interceptorName ~= "" then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_COMBAT_INTERCEPTED_BY", args.interceptorName)
    end
    if args.attackerFinalDamage >= args.attackerMaxHP then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_COMBAT_KILLED", atkName)
    end
    if args.defenderFinalDamage >= args.defenderMaxHP then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_COMBAT_KILLED", defName)
    end
    return table.concat(parts, ", ")
end

-- Format a nuclear-strike result from the buffer the engine-fork hooks
-- populated. Sections (header, target, casualties, units, no-targets)
-- are elided when empty so an inert nuke and a city-only strike read
-- without dangling clauses. buf shape:
--   buf.launcherCivAdj   localized adjective string ("Roman")
--   buf.targetName       optional civ-tagged target city name
--   buf.cities           array of { displayName, hpDelta, popDelta, wasDestroyed }
--   buf.units            array of { displayName, hpDelta, killed }
-- Caller pre-resolves civ adjectives and unit / city display names at
-- hook-fire time -- destroyed cities still resolve before the engine's
-- pkCity->kill() runs, so the snapshot here is always live.
function UnitSpeech.nuclearStrikeResult(buf)
    local parts = {}
    parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_NUKE_HEADER", buf.launcherCivAdj or "")
    if buf.targetName ~= nil and buf.targetName ~= "" then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_NUKE_TARGET", buf.targetName)
    end
    local hasCities = buf.cities ~= nil and #buf.cities > 0
    local hasUnits = buf.units ~= nil and #buf.units > 0
    if hasCities then
        local cityParts = {}
        for _, c in ipairs(buf.cities) do
            local entry = Text.format("TXT_KEY_CIVVACCESS_NUKE_HP_ENTRY", c.displayName, c.hpDelta)
            if c.popDelta and c.popDelta > 0 then
                entry = entry .. " " .. Text.format("TXT_KEY_CIVVACCESS_NUKE_POP_DELTA", c.popDelta)
            end
            if c.wasDestroyed then
                entry = entry .. " " .. Text.key("TXT_KEY_CIVVACCESS_NUKE_DESTROYED")
            end
            cityParts[#cityParts + 1] = entry
        end
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_NUKE_CASUALTIES", table.concat(cityParts, ", "))
    end
    if hasUnits then
        local unitParts = {}
        for _, u in ipairs(buf.units) do
            local entry = Text.format("TXT_KEY_CIVVACCESS_NUKE_HP_ENTRY", u.displayName, u.hpDelta)
            if u.killed then
                entry = entry .. " " .. Text.key("TXT_KEY_CIVVACCESS_NUKE_KILLED")
            end
            unitParts[#unitParts + 1] = entry
        end
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_NUKE_UNITS", table.concat(unitParts, ", "))
    end
    if not hasCities and not hasUnits then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_NUKE_NO_TARGETS")
    end
    return table.concat(parts, ", ")
end

-- "moved, N moves left" on clean arrival, or "stopped short, N turns
-- till arrival" / "stopped short" when the unit didn't reach the target
-- plot. targetX/Y are compared to the unit's live position -- if they
-- match, the path completed. turnsToArrival is supplied by the caller
-- after re-running the engine pathfinder from the stopped position; nil
-- means no estimate (unreachable) and we fall back to the bare phrasing.
-- Direction narration is deferred; the caller already spoke direction
-- when the move was committed from the target-mode cursor.
function UnitSpeech.moveResult(unit, targetX, targetY, turnsToArrival)
    if unit:GetX() == targetX and unit:GetY() == targetY then
        local movesLeft = math.floor(unit:MovesLeft() / GameDefines.MOVE_DENOMINATOR)
        return Text.format("TXT_KEY_CIVVACCESS_UNIT_MOVED_TO", movesLeft)
    end
    if turnsToArrival ~= nil and turnsToArrival > 0 then
        return Text.format("TXT_KEY_CIVVACCESS_UNIT_STOPPED_SHORT_TURNS", turnsToArrival)
    end
    return Text.key("TXT_KEY_CIVVACCESS_UNIT_STOPPED_SHORT")
end

-- Self-plot action confirms. Dispatches off a normalized token rather
-- than GameInfoActions hashes so the menu can pass a symbolic name and
-- the formatter stays decoupled from engine hash churn. Returns "" for
-- tokens we don't own -- caller logs if that matters.
local CONFIRM_KEYS = {
    FORTIFY = "TXT_KEY_CIVVACCESS_UNIT_CONFIRM_FORTIFY",
    SLEEP = "TXT_KEY_CIVVACCESS_UNIT_CONFIRM_SLEEP",
    ALERT = "TXT_KEY_CIVVACCESS_UNIT_CONFIRM_ALERT",
    WAKE = "TXT_KEY_CIVVACCESS_UNIT_CONFIRM_WAKE",
    AUTOMATE = "TXT_KEY_CIVVACCESS_UNIT_CONFIRM_AUTOMATE",
    DISBAND = "TXT_KEY_CIVVACCESS_UNIT_CONFIRM_DISBAND",
    HEAL = "TXT_KEY_CIVVACCESS_UNIT_CONFIRM_HEAL",
    PILLAGE = "TXT_KEY_CIVVACCESS_UNIT_CONFIRM_PILLAGE",
    SKIP = "TXT_KEY_CIVVACCESS_UNIT_CONFIRM_SKIP",
    UPGRADE = "TXT_KEY_CIVVACCESS_UNIT_CONFIRM_UPGRADE",
    CANCEL = "TXT_KEY_CIVVACCESS_UNIT_CONFIRM_CANCEL",
}

function UnitSpeech.selfPlotConfirm(token, payload)
    if token == "BUILD_START" then
        return Text.format("TXT_KEY_CIVVACCESS_UNIT_CONFIRM_BUILD_START", payload.buildName)
    end
    if token == "PROMOTION" then
        return Text.format("TXT_KEY_CIVVACCESS_UNIT_CONFIRM_PROMOTION", payload.promotionName)
    end
    local key = CONFIRM_KEYS[token]
    if key == nil then
        return ""
    end
    return Text.key(key)
end

-- Exposed for PlotSectionUnits so the cursor plot readout can reuse the
-- same ownership-gated cascade (friendly: full, enemy: fortified only)
-- without duplicating the UnitList rung ordering.
UnitSpeech.statusToken = statusToken

-- Exposed so PlotSectionUnits can wrap its named-unit form ("Tomyris
-- (Persian Great General)") around the same civ-tagged base every other
-- speech path uses.
UnitSpeech.unitName = unitName
