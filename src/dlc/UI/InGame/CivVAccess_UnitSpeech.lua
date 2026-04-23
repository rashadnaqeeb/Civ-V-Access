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
--     sleeping -> building. Embarkation is a name prefix (compound
--     phrase "embarked warrior"), not a status rung.

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

-- Enemy HP: band color rather than exact fraction, matching what a
-- sighted player reads off the unit flag's health bar. Thresholds mirror
-- UnitFlagManager.lua:412 (> 0.66 green, > 0.33 yellow, else red). 100%
-- hides the bar in-game; we speak "full" so the info line always closes
-- with an HP slot and the user knows silence isn't the answer.
local function hpColorKey(unit)
    local maxHP = GameDefines.MAX_HIT_POINTS
    local hp = maxHP - unit:GetDamage()
    if hp >= maxHP then
        return "TXT_KEY_CIVVACCESS_UNIT_HP_FULL"
    end
    local pct = hp / maxHP
    if pct > 0.66 then
        return "TXT_KEY_CIVVACCESS_UNIT_HP_GREEN"
    end
    if pct > 0.33 then
        return "TXT_KEY_CIVVACCESS_UNIT_HP_YELLOW"
    end
    return "TXT_KEY_CIVVACCESS_UNIT_HP_RED"
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
-- status, level / xp, promotions, upgrade target + cost, exact HP
-- fraction. Visible enemies get the subset sighted players can read off
-- a foreign flag / EnemyUnitPanel: embarked-prefixed name, combat,
-- ranged (no range), max moves, fortified only, promotions, HP as a
-- color band. Zero-valued strength fields skip so melee units don't
-- waste syllables on "0 ranged". Upgrade is gated on
-- CanUpgradeRightNow(true) -- the bOnlyTestVisible arg skips transient
-- conditions (territory, gold, resources, ...) so a tech-unlocked
-- upgrade still speaks for a unit in enemy land the player may want
-- to bring home; tech-locked targets stay silent so we don't spam an
-- unactionable cost. HP stays the final token.
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
    if friendly and unit:CanUpgradeRightNow(true) then
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
    if friendly then
        parts[#parts + 1] = hpFraction(unit)
    else
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_HP_COLOR", Text.key(hpColorKey(unit)))
    end
    return table.concat(parts, ", ")
end

-- Formats an Events.EndCombatSim payload into "attacker <name> -N hp,
-- defender <name> -M hp[, <name> killed]". Lookups use Players[] +
-- GameInfo.Units for the per-side unit name so civilian observers hear
-- the owner adjective too. The caller (UnitControl) decides whether
-- to pump this at all -- this formatter doesn't filter by player.
local function sideName(playerId, unitId)
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
-- VSUnit branch: GetMaxAttackStrength / GetMaxDefenseStrength +
-- bidirectional GetCombatDamage. Returns "" when either side's
-- strength resolves to 0 (caller speaks its own "no target" fallback).
function UnitSpeech.meleePreview(actor, defender, targetPlot)
    local myStrength = actor:GetMaxAttackStrength(actor:GetPlot(), targetPlot, defender)
    local theirStrength = defender:GetMaxDefenseStrength(targetPlot, actor)
    if myStrength <= 0 or theirStrength <= 0 then
        return ""
    end
    local myDmg = actor:GetCombatDamage(myStrength, theirStrength, actor:GetDamage(), false, false, false)
    local theirDmg = defender:GetCombatDamage(theirStrength, myStrength, defender:GetDamage(), false, false, false)
    local row = GameInfo.Units[defender:GetUnitType()]
    local name = row ~= nil and Text.key(row.Description) or ""
    return Text.format("TXT_KEY_CIVVACCESS_UNIT_PREVIEW_ATTACK", name, myStrength, theirStrength, theirDmg, myDmg)
end

function UnitSpeech.combatResult(args)
    local atkName = sideName(args.attackerPlayer, args.attackerUnit)
    local defName = sideName(args.defenderPlayer, args.defenderUnit)
    local atkDamage = args.attackerFinalDamage - args.attackerInitialDamage
    local defDamage = args.defenderFinalDamage - args.defenderInitialDamage
    local maxHP = GameDefines.MAX_HIT_POINTS
    local parts = {}
    if atkDamage > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_COMBAT_ATTACKER_DAMAGE", atkName, atkDamage)
    end
    if defDamage > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_COMBAT_DEFENDER_DAMAGE", defName, defDamage)
    end
    if args.attackerFinalDamage >= maxHP then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_COMBAT_KILLED", atkName)
    end
    if args.defenderFinalDamage >= maxHP then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_COMBAT_KILLED", defName)
    end
    return table.concat(parts, ", ")
end

-- "moved, N moves left" on clean arrival, "stopped short, 0 moves" when
-- the unit didn't reach the target plot. targetX/Y are compared to the
-- unit's live position -- if they match, the path completed. Direction
-- narration is deferred; the caller already spoke direction when the
-- move was committed from the target-mode cursor.
function UnitSpeech.moveResult(unit, targetX, targetY)
    if unit:GetX() == targetX and unit:GetY() == targetY then
        local movesLeft = math.floor(unit:MovesLeft() / GameDefines.MOVE_DENOMINATOR)
        return Text.format("TXT_KEY_CIVVACCESS_UNIT_MOVED_TO", movesLeft)
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
