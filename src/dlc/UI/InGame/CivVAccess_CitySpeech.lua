-- Pure formatters that turn a city handle into speech for the three
-- cursor number keys (1 identity + combat, 2 development, 3 politics).
-- No event registration, no listeners, no state -- every call re-reads
-- the city so stale speech can't leak through a cached format.
--
-- Output shape deliberately mirrors what a sighted player sees on the
-- BNW CityBannerManager for the relevant ownership tier: met cities
-- expose identity and combat fields unconditionally, team banners add
-- production / growth / garrison, warmonger and liberation previews
-- piggy-back on the engine's own preview strings (spoken in full so
-- the player can audit consequences before attacking). Unmet cities
-- stop at the one-word "unmet" token, matching the banner tooltip.

CitySpeech = {}

local function activePlayerId()
    return Game.GetActivePlayer()
end

local function activeTeamId()
    return Game.GetActiveTeam()
end

local function isTeam(city)
    return city:GetTeam() == activeTeamId()
end

local function isOwn(city)
    return city:GetOwner() == activePlayerId()
end

local function isMet(city)
    return Teams[activeTeamId()]:IsHasMet(city:GetTeam())
end

-- Minor civ trait -> short mod-authored token. MinorCivTraits.Type
-- values are stable across vanilla / G&K / BNW so a direct map is safer
-- than parsing the TraitIcon atlas string.
local TRAIT_TOKEN = {
    MINOR_CIV_TRAIT_CULTURED = "TXT_KEY_CIVVACCESS_CITY_CS_CULTURED",
    MINOR_CIV_TRAIT_MILITARISTIC = "TXT_KEY_CIVVACCESS_CITY_CS_MILITARISTIC",
    MINOR_CIV_TRAIT_MARITIME = "TXT_KEY_CIVVACCESS_CITY_CS_MARITIME",
    MINOR_CIV_TRAIT_MERCANTILE = "TXT_KEY_CIVVACCESS_CITY_CS_MERCANTILE",
    MINOR_CIV_TRAIT_RELIGIOUS = "TXT_KEY_CIVVACCESS_CITY_CS_RELIGIOUS",
}

local function cityStateTraitKey(player)
    local minorType = player:GetMinorCivType()
    local minor = GameInfo.MinorCivilizations[minorType]
    if minor == nil then
        Log.warn("CitySpeech: unknown MinorCivType " .. tostring(minorType))
        return nil
    end
    local traitRow = GameInfo.MinorCivTraits[minor.MinorCivTrait]
    if traitRow == nil then
        Log.warn("CitySpeech: unknown MinorCivTrait " .. tostring(minor.MinorCivTrait))
        return nil
    end
    return TRAIT_TOKEN[traitRow.Type]
end

-- Friendship tier with the active major. Ordering matches the engine's
-- own checks: permanent war first (the flag can coexist with normal war
-- or peace), then active war, then allied / friends, default neutral.
local function friendshipTierKey(city)
    local minorTeam = city:GetTeam()
    local activeTeam = activeTeamId()
    if Teams[activeTeam]:IsPermanentWarPeace(minorTeam) then
        return "TXT_KEY_CIVVACCESS_CITY_CS_PERMANENT_WAR"
    end
    if Teams[activeTeam]:IsAtWar(minorTeam) then
        return "TXT_KEY_CIVVACCESS_CITY_CS_WAR"
    end
    local minorPlayer = Players[city:GetOwner()]
    local active = activePlayerId()
    if minorPlayer:IsAllies(active) then
        return "TXT_KEY_CIVVACCESS_CITY_CS_ALLY"
    end
    if minorPlayer:IsFriends(active) then
        return "TXT_KEY_CIVVACCESS_CITY_CS_FRIEND"
    end
    return "TXT_KEY_CIVVACCESS_CITY_CS_NEUTRAL"
end

-- Status flag cascade. Order mirrors CityBannerManager's icon stack so
-- the most urgent state (razing on a timer) leads, and the quieter
-- flags (blockaded) trail. IsOccupied ANDs against IsNoOccupiedUnhappiness
-- because the banner suppresses the occupied icon on annexed-as-capital
-- cities; same rule here to avoid speaking an icon the sighted player
-- doesn't see.
function CitySpeech.statusTokens(city)
    local parts = {}
    if city:IsRazing() then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITY_RAZING", city:GetRazingTurns())
    end
    if city:IsResistance() then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITY_RESISTANCE", city:GetResistanceTurns())
    end
    if city:IsOccupied() and not city:IsNoOccupiedUnhappiness() then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_CITY_OCCUPIED")
    end
    if city:IsPuppet() then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_CITY_PUPPET")
    end
    if city:IsBlockaded() then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_CITY_BLOCKADED")
    end
    return parts
end

-- Trade-route connected indicator. Kept separate from statusTokens because
-- the banner surfaces connected via its own icon group, not the status
-- stack, so callers can sequence it independently of the razing / occupied
-- / blockaded chain. Cursor identity, CityView, and ChooseProduction
-- preambles all append it after the status tokens.
function CitySpeech.connectedToken(city)
    local owner = Players[city:GetOwner()]
    if owner ~= nil and not city:IsCapital() and owner:IsCapitalConnectedToCity(city) and not city:IsBlockaded() then
        return Text.key("TXT_KEY_CIVVACCESS_CITY_CONNECTED")
    end
    return nil
end

-- Growth line: stopped growing when food-production or zero net food,
-- starving when negative, else the turns-to-grow format key.
function CitySpeech.growthToken(city)
    local foodDiff100 = city:FoodDifferenceTimes100()
    if city:IsFoodProduction() or foodDiff100 == 0 then
        return Text.key("TXT_KEY_CIVVACCESS_CITY_STOPPED_GROWING")
    end
    if foodDiff100 < 0 then
        return Text.key("TXT_KEY_CIVVACCESS_CITY_STARVING")
    end
    return Text.format("TXT_KEY_CIVVACCESS_CITY_GROWS_IN", city:GetFoodTurnsLeft())
end

-- Short production token: name + turns-left, or "not producing" / process
-- form. Does NOT include the progress fraction that development() speaks;
-- callers who want that build it separately.
function CitySpeech.productionToken(city)
    local prodKey = city:GetProductionNameKey()
    if prodKey == nil or prodKey == "" then
        return Text.key("TXT_KEY_CIVVACCESS_CITY_NOT_PRODUCING")
    end
    if city:IsProductionProcess() then
        return Text.format("TXT_KEY_CIVVACCESS_CITY_PRODUCING_PROCESS", Text.key(prodKey))
    end
    local turnsLeft = 0
    if city:GetCurrentProductionDifferenceTimes100(false, false) > 0 then
        turnsLeft = city:GetProductionTurnsLeft()
    end
    return Text.format("TXT_KEY_CIVVACCESS_CITY_PRODUCING", Text.key(prodKey), turnsLeft)
end

-- Enemy city HP: band color rather than exact fraction, matching what
-- a sighted player reads off the banner's damage bar. Thresholds mirror
-- CityBannerManager.lua's 3-color health bar (same > 0.66 / > 0.33
-- cuts as UnitFlagManager). Full HP hides the bar in-game; we speak
-- "full" so the HP slot is always present.
local function cityHpColorKey(city)
    local maxHP = GameDefines.MAX_CITY_HIT_POINTS
    local hp = maxHP - city:GetDamage()
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

local function garrisonToken(city)
    local unit = city:GetGarrisonedUnit()
    if unit == nil then
        return nil
    end
    local row = GameInfo.Units[unit:GetUnitType()]
    if row == nil then
        Log.warn("CitySpeech: garrisoned unit with unknown type " .. tostring(unit:GetUnitType()))
        return nil
    end
    return Text.format("TXT_KEY_CIVVACCESS_CITY_GARRISON", Text.key(row.Description))
end

-- ===== Key 1: identity + combat =====
function CitySpeech.identity(city)
    if not isMet(city) then
        return Text.key("TXT_KEY_CIVVACCESS_CITY_UNMET")
    end
    local parts = {}
    local owner = Players[city:GetOwner()]

    if isOwn(city) and city:CanRangeStrikeNow() then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_CITY_CAN_ATTACK")
    end

    if city:IsCapital() and not owner:IsMinorCiv() then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_AT_CAPITAL")
    end

    if owner:IsMinorCiv() then
        local traitKey = cityStateTraitKey(owner)
        if traitKey ~= nil then
            parts[#parts + 1] = Text.key(traitKey)
        end
        parts[#parts + 1] = Text.key(friendshipTierKey(city))
    end

    for _, t in ipairs(CitySpeech.statusTokens(city)) do
        parts[#parts + 1] = t
    end

    -- Connected indicator gates on team membership to mirror the banner's
    -- isActiveTeamCity gate (CityBannerManager.lua:252); for an enemy city
    -- the underlying IsCapitalConnectedToCity asks about the enemy's road
    -- network, not ours, so reading it on a non-team city would leak the
    -- wrong fact.
    if isTeam(city) then
        local connected = CitySpeech.connectedToken(city)
        if connected ~= nil then
            parts[#parts + 1] = connected
        end
    end

    parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITY_POPULATION", city:GetPopulation())
    parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITY_DEFENSE", math.floor(city:GetStrengthValue() / 100))

    if isTeam(city) then
        local maxHP = GameDefines.MAX_CITY_HIT_POINTS
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITY_HP_FRACTION", maxHP - city:GetDamage(), maxHP)
    else
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_UNIT_HP_COLOR", Text.key(cityHpColorKey(city)))
    end

    if isTeam(city) then
        local g = garrisonToken(city)
        if g ~= nil then
            parts[#parts + 1] = g
        end
    end

    return table.concat(parts, ", ")
end

-- ===== Key 2: development (production + growth, team only) =====
-- Food per-turn can be net positive or negative. FoodDifference rather
-- than FoodDifferenceTimes100 because we speak integers and the /100
-- precision is only for the banner's growth meter. Production per-turn
-- copies CityBannerManager's own IsFoodProduction branch (Settler-era
-- food conversion adds food-minus-consumption to production).
function CitySpeech.development(city)
    if not isMet(city) then
        return Text.key("TXT_KEY_CIVVACCESS_CITY_UNMET")
    end
    if not isTeam(city) then
        return Text.key("TXT_KEY_CIVVACCESS_CITY_DEVELOPMENT_NOT_VISIBLE")
    end
    local parts = {}

    -- Production branch: empty queue -> "not producing" with no progress
    -- fraction (GetProductionNeeded returns INT32_MAX as a sentinel when
    -- nothing is queued, so speaking it leaks a 2.1-billion number).
    -- Processes (Wealth/Research/etc.) are perpetual, so they skip turns
    -- and progress as well -- only the name carries meaning.
    local prodKey = city:GetProductionNameKey()
    if prodKey == nil or prodKey == "" then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_CITY_NOT_PRODUCING")
    elseif city:IsProductionProcess() then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITY_PRODUCING_PROCESS", Text.key(prodKey))
    else
        local turnsLeft = 0
        if city:GetCurrentProductionDifferenceTimes100(false, false) > 0 then
            turnsLeft = city:GetProductionTurnsLeft()
        end
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITY_PRODUCING", Text.key(prodKey), turnsLeft)
        parts[#parts + 1] =
            Text.format("TXT_KEY_CIVVACCESS_CITY_PRODUCTION_PROGRESS", city:GetProduction(), city:GetProductionNeeded())
    end

    local prodRate = city:GetYieldRate(YieldTypes.YIELD_PRODUCTION)
    if city:IsFoodProduction() then
        prodRate = prodRate + city:GetYieldRate(YieldTypes.YIELD_FOOD) - city:FoodConsumption(true)
    end
    parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITY_PRODUCTION_PER_TURN", prodRate)

    -- Food progress + per-turn first, growth timing last. Speaking
    -- "grows in N turns" before the food fraction buried the numbers that
    -- produced it; the turn count reads more naturally as a summary at
    -- the end of the food block.
    parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITY_FOOD_PROGRESS", city:GetFood(), city:GrowthThreshold())

    local foodDiff = city:FoodDifference()
    if foodDiff < 0 then
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITY_FOOD_LOSING", -foodDiff)
    else
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITY_FOOD_PER_TURN", foodDiff)
    end

    local foodDiff100 = city:FoodDifferenceTimes100()
    if city:IsFoodProduction() or foodDiff100 == 0 then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_CITY_STOPPED_GROWING")
    elseif foodDiff100 < 0 then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_CITY_STARVING")
    else
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITY_GROWS_IN", city:GetFoodTurnsLeft())
    end

    return table.concat(parts, ", ")
end

-- ===== Key 3: politics =====
-- Warmonger / liberation previews come back as pre-formatted engine
-- text with newlines and icon markup; the SpeechPipeline's TextFilter
-- stage strips those before Tolk, so the raw string is safe to return.
-- Religion and spy lookups are best-effort -- missing religion rows or
-- spy entries without a CityX/Y match just skip that token.
function CitySpeech.politics(city)
    if not isMet(city) then
        return Text.key("TXT_KEY_CIVVACCESS_CITY_UNMET")
    end
    local parts = {}
    local activeTeam = Teams[activeTeamId()]
    local ownerId = city:GetOwner()
    local cityPlayer = Players[ownerId]

    -- Warmonger / liberation previews are invoked on the city's own
    -- player with the owner id as the argument. That's what
    -- CityBannerManager.lua:215 does; the DLL method reads active-
    -- player standings internally regardless of the receiver.
    if activeTeam:IsAtWar(city:GetTeam()) then
        local warmonger = cityPlayer:GetWarmongerPreviewString(ownerId)
        if warmonger ~= nil and warmonger ~= "" then
            parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITY_WARMONGER_PREVIEW", warmonger)
        end
        if city:GetOriginalOwner() ~= ownerId then
            local liberation = cityPlayer:GetLiberationPreviewString(city:GetOriginalOwner())
            if liberation ~= nil and liberation ~= "" then
                parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITY_LIBERATION_PREVIEW", liberation)
            end
        end
    end

    local religion = city:GetReligiousMajority()
    if religion ~= nil and religion >= 0 then
        local row = GameInfo.Religions[religion]
        if row ~= nil then
            parts[#parts + 1] = Text.key(row.Description)
        else
            Log.warn("CitySpeech: unknown religion id " .. tostring(religion))
        end
    end

    local spies = Players[activePlayerId()]:GetEspionageSpies()
    if spies ~= nil then
        local cityX, cityY = city:GetX(), city:GetY()
        for _, v in ipairs(spies) do
            if v.CityX == cityX and v.CityY == cityY then
                local name = Text.key(v.Name)
                local rank = Text.key(v.Rank)
                if v.IsDiplomat then
                    parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITY_DIPLOMAT", name, rank)
                else
                    parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_CITY_SPY", name, rank)
                end
            end
        end
    end

    if #parts == 0 then
        return Text.key("TXT_KEY_CIVVACCESS_CITY_NO_POLITICS")
    end
    return table.concat(parts, ", ")
end

-- Damage preview for `city` ranged-attacking either a unit OR another
-- city. Pass exactly one of (defenderUnit, defenderCity) and leave the
-- other nil. Mirrors shipped EnemyUnitPanel.lua UpdateCombatOddsCityVsUnit
-- (line ~1684): City:RangeCombatDamage runs the engine's damage roll
-- (bIncludeRand=false for a deterministic preview matching what the
-- panel shows on hover); defender strength comes from
-- City:RangeCombatUnitDefense for unit defenders and the target city's
-- GetStrengthValue for city defenders. Damage is clamped to the
-- defender's max HP, matching the panel's clamp at line 1703.
--
-- Embeds the target's name (civ-adjective + unit name for unit defenders,
-- bare city name for city defenders) so the preview matches the shape of
-- UnitSpeech.rangedPreview's "{name}, {myStr} vs {theirStr}, ..." -- the
-- cursor's per-tile speech already gave the user the full unit info, so
-- the strike preview only needs to name what's being shot at.
function CitySpeech.rangedPreview(city, defenderUnit, defenderCity)
    local name, damage, theirStrength, maxHP
    if defenderUnit ~= nil then
        name = UnitSpeech.unitName(defenderUnit)
        damage = city:RangeCombatDamage(defenderUnit, nil, false)
        theirStrength = city:RangeCombatUnitDefense(defenderUnit)
        maxHP = defenderUnit:GetMaxHitPoints()
    elseif defenderCity ~= nil then
        name = defenderCity:GetName()
        damage = city:RangeCombatDamage(nil, defenderCity, false)
        theirStrength = defenderCity:GetStrengthValue()
        maxHP = defenderCity:GetMaxHitPoints()
    else
        return ""
    end
    if damage > maxHP then
        damage = maxHP
    end
    local myStr = Locale.ToNumber(city:GetStrengthValue() / 100, "#.##")
    local theirStr = Locale.ToNumber(theirStrength / 100, "#.##")
    return Text.format("TXT_KEY_CIVVACCESS_CITY_RANGED_PREVIEW", name, myStr, theirStr, damage)
end
