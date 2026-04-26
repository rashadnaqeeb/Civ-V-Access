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
--     resolve within the turn). Lua exposes ACTIVITY_MISSION but not
--     the mission type or destination, so we can label it "move" but
--     not name where.

UnitSpeech = {}

local function unitName(unit)
    local t = unit:GetUnitType()
    local row = GameInfo.Units[t]
    if row == nil then
        return ""
    end
    return Text.key(row.Description)
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

local function hpFraction(unit)
    local maxHP = GameDefines.MAX_HIT_POINTS
    return Text.format("TXT_KEY_CIVVACCESS_UNIT_HP_FRACTION", maxHP - unit:GetDamage(), maxHP)
end

local function maxMovesCount(unit)
    return math.floor(unit:MaxMoves() / GameDefines.MOVE_DENOMINATOR)
end

local function isFriendly(unit)
    return unit:GetTeam() == Game.GetActiveTeam()
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
        return Text.key("TXT_KEY_CIVVACCESS_UNIT_STATUS_QUEUED")
    end
    return ""
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
    parts[#parts + 1] = movesFraction(unit)
    if unit:CanPromote() then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_UNIT_PROMOTION_AVAILABLE")
    end
    local status = statusToken(unit)
    if status ~= "" then
        parts[#parts + 1] = status
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
-- dump: embarked-prefixed name, combat, ranged + range, max moves,
-- status, level / xp, promotions, upgrade target + cost, HP. Visible
-- enemies get the subset sighted players can read off a foreign flag /
-- EnemyUnitPanel: embarked-prefixed name, combat, ranged (no range),
-- max moves, fortified only, promotions, HP. HP is the same exact
-- fraction for both -- sighted players get a numeric HP readout off
-- any unit's plot hover tooltip (PlotMouseoverInclude.lua), so there's
-- no parity reason to coarsen enemy HP into a band. Zero-valued strength
-- fields skip so melee units don't waste syllables on "0 ranged".
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
        if friendly then
            parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_RANGED_STRENGTH", ranged, unit:Range())
        else
            parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_RANGED_STRENGTH_ONLY", ranged)
        end
    end
    parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_MAX_MOVES", maxMovesCount(unit))
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
    parts[#parts + 1] = hpFraction(unit)
    return table.concat(parts, ", ")
end

-- Look up a combatant's display name from a (playerId, unitId) pair.
-- Public so UnitControl can resolve names at EndCombatSim event time
-- (units are still alive in the engine when the event fires) AND
-- snapshot the names at commit time for the quick-combat fallback path
-- (where the unit may be removed before the formatter runs).
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

    local row = GameInfo.Units[defender:GetUnitType()]
    local name = row ~= nil and Text.key(row.Description) or ""
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
    local bInterceptPossible = false
    local interceptors = 0
    if actor:GetDomainType() == DomainTypes.DOMAIN_AIR then
        theirDmg = defender:GetAirStrikeDefenseDamage(actor, false)
        interceptors = actor:GetInterceptorCount(targetPlot, defender, true, true)
        bInterceptPossible = true
    end

    local row = GameInfo.Units[defender:GetUnitType()]
    local name = row ~= nil and Text.key(row.Description) or ""
    local myStr = Locale.ToNumber(myStrength / 100, "#.##")
    local theirStr = Locale.ToNumber(theirStrength / 100, "#.##")
    local result = predictionLabel(actor, defender)

    local parts = { Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RANGED", name, myStr, theirStr, result, myDmg) }

    if theirDmg > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_RETALIATE", theirDmg)
    end
    if bInterceptPossible then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_INTERCEPT_POSSIBLE")
    end
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

-- Formats a combat outcome into "attacker <name> -N hp, defender <name>
-- -M hp[, <name> killed]". Caller pre-resolves the side names via
-- UnitSpeech.combatantName so the same formatter serves both the
-- EndCombatSim path (animations on; names looked up at event time) and
-- the snapshot fallback path (quick combat; names cached at commit time
-- because the unit may already be gone by the time the formatter runs).
-- args.attackerDamage / defenderDamage are damage dealt THIS combat;
-- FinalDamage is cumulative damage after combat (kill check uses it
-- against MaxHP). Caller doesn't subtract -- pass the per-combat delta.
function UnitSpeech.combatResult(args)
    local atkName = args.attackerName or ""
    local defName = args.defenderName or ""
    local atkDamage = args.attackerDamage
    local defDamage = args.defenderDamage
    local parts = {}
    if atkDamage > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_COMBAT_ATTACKER_DAMAGE", atkName, atkDamage)
    end
    if defDamage > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_COMBAT_DEFENDER_DAMAGE", defName, defDamage)
    end
    if args.attackerFinalDamage >= args.attackerMaxHP then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_COMBAT_KILLED", atkName)
    end
    if args.defenderFinalDamage >= args.defenderMaxHP then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_COMBAT_KILLED", defName)
    end
    return table.concat(parts, ", ")
end

-- "moved, N moves left" on clean arrival, or "stopped short, N turns
-- till arrival" / "stopped short" when the unit didn't reach the target
-- plot. targetX/Y are compared to the unit's live position -- if they
-- match, the path completed. turnsToArrival is supplied by the caller
-- after re-running Pathfinder from the stopped position; nil means no
-- estimate (unreachable or pathfinder bailed) and we fall back to the
-- bare phrasing. Direction narration is deferred; the caller already
-- spoke direction when the move was committed from the target-mode
-- cursor.
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
