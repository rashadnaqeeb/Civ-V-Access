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

local function moveDenominator()
    local d = GameDefines.MOVE_DENOMINATOR
    if d == nil or d == 0 then
        return 60
    end
    return d
end

local function movesFraction(unit)
    local denom = moveDenominator()
    local cur = math.floor((unit:MovesLeft() or 0) / denom)
    local maxMoves = math.floor((unit:MaxMoves() or 0) / denom)
    return Text.format("TXT_KEY_CIVVACCESS_UNIT_MOVES_FRACTION", cur, maxMoves)
end

local function hpFraction(unit)
    local maxHP = GameDefines.MAX_HIT_POINTS or 100
    local cur = maxHP - (unit:GetDamage() or 0)
    return Text.format("TXT_KEY_CIVVACCESS_UNIT_HP_FRACTION", cur, maxHP)
end

local function isBelowMaxHP(unit)
    return (unit:GetDamage() or 0) > 0
end

-- Returns the first matching status token (localized string), or "".
-- Order matches base UnitList.lua so e.g. a garrisoned unit sitting on
-- fortify turns speaks "garrison" -- the more specific rung wins.
local function statusToken(unit)
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
    if (unit:GetFortifyTurns() or 0) > 0 then
        return Text.key("TXT_KEY_UNIT_STATUS_FORTIFIED")
    end
    if activity == ActivityTypes.ACTIVITY_SLEEP then
        return Text.key("TXT_KEY_MISSION_SLEEP")
    end
    local buildType = unit:GetBuildType()
    if buildType ~= nil and buildType ~= -1 then
        local buildRow = GameInfo.Builds[buildType]
        if buildRow == nil then
            Log.warn("UnitSpeech: GetBuildType returned unknown id " .. tostring(buildType))
            return ""
        end
        local plot = unit:GetPlot()
        local turns = 0
        if plot ~= nil then
            -- Engine adds +1 to turns-left (see UnitPanel.lua:392) so a
            -- build finishing at end-of-turn reads as 1 rather than 0.
            turns = (plot:GetBuildTurnsLeft(buildType, Game.GetActivePlayer(), 0, 0) or 0) + 1
        end
        return Text.format("TXT_KEY_CIVVACCESS_UNIT_STATUS_BUILDING", Text.key(buildRow.Description), turns)
    end
    return ""
end

-- Builds the selection announce string. Returns "" only when the unit
-- has no name and no other speakable fact, which shouldn't happen for a
-- selectable unit but is defended against so an empty output doesn't
-- blast an "unknown" token through Tolk.
function UnitSpeech.selection(unit, prevX, prevY)
    if unit == nil then
        Log.warn("UnitSpeech.selection: nil unit")
        return ""
    end
    local parts = {}
    local cx, cy = unit:GetX(), unit:GetY()
    if prevX ~= nil and prevY ~= nil then
        local dir = HexGeom.directionString(prevX, prevY, cx, cy)
        if dir ~= "" then
            parts[#parts + 1] = dir
        end
    end
    local name = unitName(unit)
    if unit:IsEmbarked() then
        name = Text.key("TXT_KEY_CIVVACCESS_UNIT_EMBARKED_PREFIX") .. " " .. name
    end
    if name ~= "" then
        parts[#parts + 1] = name
    end
    if isBelowMaxHP(unit) then
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

-- Flat info dump per design: combat, ranged + range, level / xp,
-- promotions, upgrade target + cost, HP last. Zero-valued fields skip
-- rather than speaking "0 ranged" -- empty ranged strength on a melee
-- unit would waste syllables on every query.
function UnitSpeech.info(unit)
    if unit == nil then
        Log.warn("UnitSpeech.info: nil unit")
        return ""
    end
    local parts = {}
    parts[#parts + 1] = unitName(unit)
    local combat = unit:GetBaseCombatStrength() or 0
    if combat > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_COMBAT_STRENGTH", combat)
    end
    local ranged = unit:GetBaseRangedCombatStrength() or 0
    if ranged > 0 then
        local range = unit:Range() or 0
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_RANGED_STRENGTH", ranged, range)
    end
    if unit:IsCombatUnit() then
        local level = unit:GetLevel() or 0
        local xp = unit:GetExperience() or 0
        local xpNext = unit:ExperienceNeeded() or 0
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_LEVEL_XP", level, xp, xpNext)
    end
    local promos = promotionList(unit)
    if #promos > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_PROMOTIONS_LABEL", table.concat(promos, ", "))
    end
    local upgradeType = unit:GetUpgradeUnitType()
    if upgradeType ~= nil and upgradeType ~= -1 then
        local upgradeRow = GameInfo.Units[upgradeType]
        if upgradeRow ~= nil then
            local gold = unit:UpgradePrice(upgradeType) or 0
            parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_UPGRADE", Text.key(upgradeRow.Description), gold)
        else
            Log.warn("UnitSpeech.info: GetUpgradeUnitType returned unknown id " .. tostring(upgradeType))
        end
    end
    parts[#parts + 1] = hpFraction(unit)
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

function UnitSpeech.combatResult(args)
    if args == nil then
        Log.warn("UnitSpeech.combatResult: nil args")
        return ""
    end
    local atkName = sideName(args.attackerPlayer, args.attackerUnit)
    local defName = sideName(args.defenderPlayer, args.defenderUnit)
    local atkDamage = (args.attackerFinalDamage or 0) - (args.attackerInitialDamage or 0)
    local defDamage = (args.defenderFinalDamage or 0) - (args.defenderInitialDamage or 0)
    local maxHP = GameDefines.MAX_HIT_POINTS or 100
    local parts = {}
    if atkDamage > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_COMBAT_ATTACKER_DAMAGE", atkName, atkDamage)
    end
    if defDamage > 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_COMBAT_DEFENDER_DAMAGE", defName, defDamage)
    end
    if (args.attackerFinalDamage or 0) >= maxHP then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_COMBAT_KILLED", atkName)
    end
    if (args.defenderFinalDamage or 0) >= maxHP then
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
    if unit == nil then
        Log.warn("UnitSpeech.moveResult: nil unit")
        return ""
    end
    local cx, cy = unit:GetX(), unit:GetY()
    if cx == targetX and cy == targetY then
        local denom = moveDenominator()
        local movesLeft = math.floor((unit:MovesLeft() or 0) / denom)
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
    if token == nil then
        Log.warn("UnitSpeech.selfPlotConfirm: nil token")
        return ""
    end
    if token == "BUILD_START" then
        if payload == nil or payload.buildName == nil then
            Log.warn("UnitSpeech.selfPlotConfirm: BUILD_START missing buildName")
            return Text.key("TXT_KEY_CIVVACCESS_UNIT_CONFIRM_BUILD_START")
        end
        return Text.format("TXT_KEY_CIVVACCESS_UNIT_CONFIRM_BUILD_START", payload.buildName)
    end
    if token == "PROMOTION" then
        if payload == nil or payload.promotionName == nil then
            Log.warn("UnitSpeech.selfPlotConfirm: PROMOTION missing promotionName")
            return Text.key("TXT_KEY_CIVVACCESS_UNIT_CONFIRM_PROMOTION")
        end
        return Text.format("TXT_KEY_CIVVACCESS_UNIT_CONFIRM_PROMOTION", payload.promotionName)
    end
    local key = CONFIRM_KEYS[token]
    if key == nil then
        Log.warn("UnitSpeech.selfPlotConfirm: unknown token " .. tostring(token))
        return ""
    end
    return Text.key(key)
end
