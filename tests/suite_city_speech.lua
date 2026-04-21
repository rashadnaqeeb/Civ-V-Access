-- CitySpeech formatter tests. Covers the three cursor number keys
-- (identity + combat, development, politics) across ownership tiers
-- (own / team / visible enemy / unmet) and across the status flags
-- and city-state trait / friendship combinations the banner exposes.

local T = require("support")
local M = {}

-- Minimal city stub that implements every method CitySpeech reads.
-- Defaults produce a 6-pop own city, undamaged, not producing anything,
-- at zero food difference. opts overrides let each test express only
-- the diffs it cares about.
local function mkCity(opts)
    opts = opts or {}
    local c = {
        _owner = (opts.owner == nil) and 0 or opts.owner,
        _team = (opts.team == nil) and 0 or opts.team,
        _isCapital = opts.isCapital or false,
        _isRazing = opts.isRazing or false,
        _razingTurns = opts.razingTurns or 0,
        _isResistance = opts.isResistance or false,
        _resistanceTurns = opts.resistanceTurns or 0,
        _isBlockaded = opts.isBlockaded or false,
        _isPuppet = opts.isPuppet or false,
        _isOccupied = opts.isOccupied or false,
        _noOccupiedUnhappiness = opts.noOccupiedUnhappiness or false,
        _population = opts.population or 6,
        _strength = opts.strength or 2000,
        _damage = opts.damage or 0,
        _religion = (opts.religion == nil) and -1 or opts.religion,
        _garrisonedUnit = opts.garrisonedUnit,
        _canRangeStrikeNow = opts.canRangeStrikeNow or false,
        _productionKey = opts.productionKey,
        _production = opts.production or 0,
        _productionNeeded = opts.productionNeeded or 0,
        _productionTurnsLeft = opts.productionTurnsLeft or 0,
        _isProduction = (opts.isProduction ~= false),
        _isProductionProcess = opts.isProductionProcess or false,
        _productionDiffTimes100 = opts.productionDiffTimes100 or 1000,
        _yieldRate = opts.yieldRate or { [YieldTypes.YIELD_PRODUCTION] = 10, [YieldTypes.YIELD_FOOD] = 8 },
        _isFoodProduction = opts.isFoodProduction or false,
        _foodConsumption = opts.foodConsumption or 6,
        _foodDifference = opts.foodDifference or 3,
        _foodDifferenceTimes100 = (opts.foodDifferenceTimes100 == nil) and 300 or opts.foodDifferenceTimes100,
        _foodTurnsLeft = opts.foodTurnsLeft or 10,
        _food = opts.food or 12,
        _growthThreshold = opts.growthThreshold or 22,
        _originalOwner = (opts.originalOwner == nil) and 0 or opts.originalOwner,
        _x = opts.x or 5,
        _y = opts.y or 5,
    }
    function c:GetOwner()
        return self._owner
    end
    function c:GetTeam()
        return self._team
    end
    function c:IsCapital()
        return self._isCapital
    end
    function c:IsRazing()
        return self._isRazing
    end
    function c:GetRazingTurns()
        return self._razingTurns
    end
    function c:IsResistance()
        return self._isResistance
    end
    function c:GetResistanceTurns()
        return self._resistanceTurns
    end
    function c:IsBlockaded()
        return self._isBlockaded
    end
    function c:IsPuppet()
        return self._isPuppet
    end
    function c:IsOccupied()
        return self._isOccupied
    end
    function c:IsNoOccupiedUnhappiness()
        return self._noOccupiedUnhappiness
    end
    function c:GetPopulation()
        return self._population
    end
    function c:GetStrengthValue()
        return self._strength
    end
    function c:GetDamage()
        return self._damage
    end
    function c:GetReligiousMajority()
        return self._religion
    end
    function c:GetGarrisonedUnit()
        return self._garrisonedUnit
    end
    function c:CanRangeStrikeNow()
        return self._canRangeStrikeNow
    end
    function c:GetProductionNameKey()
        return self._productionKey
    end
    function c:GetProduction()
        return self._production
    end
    function c:GetProductionNeeded()
        return self._productionNeeded
    end
    function c:GetProductionTurnsLeft()
        return self._productionTurnsLeft
    end
    function c:IsProduction()
        return self._isProduction
    end
    function c:IsProductionProcess()
        return self._isProductionProcess
    end
    function c:GetCurrentProductionDifferenceTimes100(_a, _b)
        return self._productionDiffTimes100
    end
    function c:GetYieldRate(yid)
        return self._yieldRate[yid] or 0
    end
    function c:IsFoodProduction()
        return self._isFoodProduction
    end
    function c:FoodConsumption(_includeCivilians)
        return self._foodConsumption
    end
    function c:FoodDifference()
        return self._foodDifference
    end
    function c:FoodDifferenceTimes100()
        return self._foodDifferenceTimes100
    end
    function c:GetFoodTurnsLeft()
        return self._foodTurnsLeft
    end
    function c:GetFood()
        return self._food
    end
    function c:GrowthThreshold()
        return self._growthThreshold
    end
    function c:GetOriginalOwner()
        return self._originalOwner
    end
    function c:GetX()
        return self._x
    end
    function c:GetY()
        return self._y
    end
    return c
end

-- Helpers for building player / team / game fixtures a test cares about.
-- The active player is id 0 / team 0; foreign civs live at higher ids.
local function setup()
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_CitySpeech.lua")

    Game = Game or {}
    Game.GetActivePlayer = function()
        return 0
    end
    Game.GetActiveTeam = function()
        return 0
    end

    Players = {}
    Teams = {}
    -- Own team / own player default fixtures. Tests that need more
    -- distinctive players (minor civ, at-war enemy) overwrite slots.
    Players[0] = {
        _isMinor = false,
        IsMinorCiv = function(self)
            return self._isMinor
        end,
        IsAllies = function()
            return false
        end,
        IsFriends = function()
            return false
        end,
        GetEspionageSpies = function()
            return {}
        end,
        GetWarmongerPreviewString = function()
            return ""
        end,
        GetLiberationPreviewString = function()
            return ""
        end,
    }
    Teams[0] = {
        _hasMet = { [0] = true },
        _atWar = {},
        _permanentWarPeace = {},
        IsHasMet = function(self, other)
            return self._hasMet[other] or false
        end,
        IsAtWar = function(self, other)
            return self._atWar[other] or false
        end,
        IsPermanentWarPeace = function(self, other)
            return self._permanentWarPeace[other] or false
        end,
    }

    GameInfo = GameInfo or {}
    GameInfo.Units = {}
    GameInfo.Religions = {}
    GameInfo.MinorCivilizations = {}
    GameInfo.MinorCivTraits = {}
    YieldTypes = YieldTypes
        or {
            YIELD_FOOD = 0,
            YIELD_PRODUCTION = 1,
        }
    GameDefines = GameDefines or {}
    GameDefines.MAX_CITY_HIT_POINTS = 200
end

-- Builds an enemy team the active player has met but is at peace with.
local function installForeignMajor(teamId, ownerId, opts)
    opts = opts or {}
    Players[ownerId] = {
        _isMinor = false,
        IsMinorCiv = function(self)
            return self._isMinor
        end,
        GetWarmongerPreviewString = function()
            return opts.warmonger or ""
        end,
        GetLiberationPreviewString = function()
            return opts.liberation or ""
        end,
    }
    Teams[teamId] = {
        IsAtWar = function()
            return opts.atWar or false
        end,
        IsHasMet = function()
            return opts.met ~= false
        end,
        IsPermanentWarPeace = function()
            return false
        end,
    }
    -- Active team's met-map sees this foreign team.
    Teams[0]._hasMet[teamId] = (opts.met ~= false)
    Teams[0]._atWar[teamId] = opts.atWar or false
end

local function installMinorCiv(teamId, ownerId, traitType, opts)
    opts = opts or {}
    GameInfo.MinorCivilizations[42] = { MinorCivTrait = "MINOR_CIV_TRAIT_MILITARISTIC_ROW" }
    GameInfo.MinorCivilizations[traitType.minorType or 42] = { MinorCivTrait = traitType.traitRow or "MINOR_CIV_TRAIT_MILITARISTIC_ROW" }
    GameInfo.MinorCivTraits[traitType.traitRow or "MINOR_CIV_TRAIT_MILITARISTIC_ROW"] = { Type = traitType.type }
    Players[ownerId] = {
        _isMinor = true,
        _isAllies = opts.allies or false,
        _isFriends = opts.friends or false,
        _minorType = traitType.minorType or 42,
        IsMinorCiv = function(self)
            return self._isMinor
        end,
        IsAllies = function(self, _p)
            return self._isAllies
        end,
        IsFriends = function(self, _p)
            return self._isFriends
        end,
        GetMinorCivType = function(self)
            return self._minorType
        end,
    }
    Teams[teamId] = {
        IsAtWar = function()
            return opts.atWar or false
        end,
        IsHasMet = function()
            return true
        end,
        IsPermanentWarPeace = function()
            return opts.permanentWar or false
        end,
    }
    Teams[0]._hasMet[teamId] = true
    Teams[0]._atWar[teamId] = opts.atWar or false
    Teams[0]._permanentWarPeace[teamId] = opts.permanentWar or false
end

-- ===== Unmet =====

function M.test_identity_speaks_unmet_for_unmet_city()
    setup()
    -- Foreign team the active team has not met.
    Teams[5] = {
        IsAtWar = function()
            return false
        end,
        IsHasMet = function()
            return false
        end,
        IsPermanentWarPeace = function()
            return false
        end,
    }
    Players[5] = { IsMinorCiv = function()
        return false
    end }
    local city = mkCity({ owner = 5, team = 5 })
    T.eq(CitySpeech.identity(city), "unmet")
end

function M.test_development_speaks_unmet_for_unmet_city()
    setup()
    Teams[5] = { IsHasMet = function()
        return false
    end, IsAtWar = function()
        return false
    end, IsPermanentWarPeace = function()
        return false
    end }
    Players[5] = { IsMinorCiv = function()
        return false
    end }
    local city = mkCity({ owner = 5, team = 5 })
    T.eq(CitySpeech.development(city), "unmet")
end

function M.test_politics_speaks_unmet_for_unmet_city()
    setup()
    Teams[5] = { IsHasMet = function()
        return false
    end, IsAtWar = function()
        return false
    end, IsPermanentWarPeace = function()
        return false
    end }
    Players[5] = { IsMinorCiv = function()
        return false
    end }
    local city = mkCity({ owner = 5, team = 5 })
    T.eq(CitySpeech.politics(city), "unmet")
end

-- ===== Identity: capital marker =====

function M.test_identity_major_capital_speaks_capital_token()
    setup()
    local city = mkCity({ isCapital = true })
    local out = CitySpeech.identity(city)
    T.truthy(out:find("capital", 1, true), "major capital must speak 'capital': " .. out)
end

function M.test_identity_city_state_capital_does_not_speak_capital_token()
    -- City-states have exactly one city and it's trivially their capital;
    -- the banner suppresses the glyph via `not owner:IsMinorCiv()`. Mirror
    -- that so minor-civ cities don't fire the redundant token.
    setup()
    installMinorCiv(1, 1, { type = "MINOR_CIV_TRAIT_MILITARISTIC" })
    local city = mkCity({ owner = 1, team = 1, isCapital = true })
    local out = CitySpeech.identity(city)
    T.falsy(out:find("capital", 1, true), "city-state must not speak 'capital': " .. out)
end

-- ===== Identity: can attack =====

function M.test_identity_can_attack_prepends_on_own_city_with_strike_ready()
    setup()
    local city = mkCity({ canRangeStrikeNow = true })
    local out = CitySpeech.identity(city)
    T.truthy(out:find("^can attack"), "can-attack must lead own-city readout: " .. out)
end

function M.test_identity_can_attack_not_spoken_on_enemy_city()
    setup()
    installForeignMajor(5, 5)
    local city = mkCity({ owner = 5, team = 5, canRangeStrikeNow = true })
    local out = CitySpeech.identity(city)
    T.falsy(out:find("can attack", 1, true), "enemies' range-strike readiness is irrelevant to us: " .. out)
end

-- ===== Identity: city-state trait + friendship =====

function M.test_identity_city_state_speaks_trait_and_friendship_tier()
    setup()
    installMinorCiv(1, 1, { type = "MINOR_CIV_TRAIT_MARITIME" }, { allies = true })
    local city = mkCity({ owner = 1, team = 1 })
    local out = CitySpeech.identity(city)
    T.truthy(out:find("maritime", 1, true), "trait expected: " .. out)
    T.truthy(out:find("ally", 1, true), "friendship tier expected: " .. out)
end

function M.test_identity_city_state_friend_tier()
    setup()
    installMinorCiv(1, 1, { type = "MINOR_CIV_TRAIT_CULTURED" }, { friends = true })
    local city = mkCity({ owner = 1, team = 1 })
    T.truthy(CitySpeech.identity(city):find("friend", 1, true), "friend tier expected")
end

function M.test_identity_city_state_war_tier_overrides_friends()
    setup()
    -- A city-state at war with you is still accessible here; the war
    -- check must win over friends/allies since the tiers are mutually
    -- exclusive at runtime. This asserts the ordering defensively.
    installMinorCiv(1, 1, { type = "MINOR_CIV_TRAIT_MERCANTILE" }, { atWar = true, friends = true })
    local city = mkCity({ owner = 1, team = 1 })
    local out = CitySpeech.identity(city)
    T.truthy(out:find(", war,", 1, true) or out:find(", war$"), "war tier must win over friends: " .. out)
end

function M.test_identity_city_state_permanent_war_tier_leads()
    setup()
    installMinorCiv(1, 1, { type = "MINOR_CIV_TRAIT_RELIGIOUS" }, { atWar = true, permanentWar = true })
    local city = mkCity({ owner = 1, team = 1 })
    local out = CitySpeech.identity(city)
    T.truthy(out:find("permanent war", 1, true), "permanent-war tier must be distinct: " .. out)
end

function M.test_identity_city_state_neutral_default()
    setup()
    installMinorCiv(1, 1, { type = "MINOR_CIV_TRAIT_MILITARISTIC" })
    local city = mkCity({ owner = 1, team = 1 })
    T.truthy(CitySpeech.identity(city):find("neutral", 1, true), "neutral default expected")
end

-- ===== Identity: status flags =====

function M.test_identity_razing_speaks_turns_remaining()
    setup()
    local city = mkCity({ isRazing = true, razingTurns = 3 })
    T.truthy(CitySpeech.identity(city):find("razing 3 turns", 1, true), "razing-with-turns expected")
end

function M.test_identity_resistance_speaks_turns_remaining()
    setup()
    local city = mkCity({ isResistance = true, resistanceTurns = 2 })
    T.truthy(CitySpeech.identity(city):find("resistance 2 turns", 1, true), "resistance-with-turns expected")
end

function M.test_identity_occupied_gated_on_no_occupied_unhappiness()
    -- Captured cities that annex as capitals suppress the occupied icon
    -- (via IsNoOccupiedUnhappiness). Match that so we don't overstate.
    setup()
    local c1 = mkCity({ isOccupied = true, noOccupiedUnhappiness = false })
    T.truthy(CitySpeech.identity(c1):find("occupied", 1, true), "occupied expected when unhappiness applies")
    setup()
    local c2 = mkCity({ isOccupied = true, noOccupiedUnhappiness = true })
    T.falsy(CitySpeech.identity(c2):find("occupied", 1, true), "no occupied token when unhappiness suppressed")
end

function M.test_identity_puppet_and_blockaded_flags()
    setup()
    local city = mkCity({ isPuppet = true, isBlockaded = true })
    local out = CitySpeech.identity(city)
    T.truthy(out:find("puppet", 1, true), "puppet flag expected: " .. out)
    T.truthy(out:find("blockaded", 1, true), "blockaded flag expected: " .. out)
end

function M.test_identity_status_flag_order_razing_resistance_occupied_puppet_blockaded()
    -- Cascade ordering matches CityBannerManager's icon stack. Single
    -- test so a reorder regresses loudly; the per-flag tests still
    -- guard the individual tokens.
    setup()
    local city = mkCity({
        isRazing = true,
        razingTurns = 1,
        isResistance = true,
        resistanceTurns = 2,
        isOccupied = true,
        isPuppet = true,
        isBlockaded = true,
    })
    local out = CitySpeech.identity(city)
    local iRaze = out:find("razing", 1, true)
    local iRes = out:find("resistance", 1, true)
    local iOcc = out:find("occupied", 1, true)
    local iPup = out:find("puppet", 1, true)
    local iBlk = out:find("blockaded", 1, true)
    T.truthy(iRaze and iRes and iOcc and iPup and iBlk, "all flags must be present: " .. out)
    T.truthy(iRaze < iRes and iRes < iOcc and iOcc < iPup and iPup < iBlk, "cascade order wrong: " .. out)
end

-- ===== Identity: pop / defense / HP =====

function M.test_identity_population_and_defense_tokens()
    setup()
    local city = mkCity({ population = 8, strength = 2200 })
    local out = CitySpeech.identity(city)
    T.truthy(out:find("8 population", 1, true), "pop expected: " .. out)
    T.truthy(out:find("22 defense", 1, true), "defense expected (strength/100): " .. out)
end

function M.test_identity_team_city_speaks_hp_fraction()
    setup()
    local city = mkCity({ damage = 50 })
    T.truthy(CitySpeech.identity(city):find("150 of 200 hp", 1, true), "team HP fraction expected")
end

function M.test_identity_enemy_city_speaks_hp_full()
    setup()
    installForeignMajor(5, 5)
    local city = mkCity({ owner = 5, team = 5, damage = 0 })
    T.truthy(CitySpeech.identity(city):find("hp full", 1, true), "full HP speaks 'hp full'")
end

function M.test_identity_enemy_city_hp_band_matches_thresholds()
    setup()
    installForeignMajor(5, 5)
    -- 140 / 200 = 0.7 > 0.66 -> green
    local green = mkCity({ owner = 5, team = 5, damage = 60 })
    T.truthy(CitySpeech.identity(green):find("hp green", 1, true), "green band at 70%")
    -- 120 / 200 = 0.6 -> yellow
    setup()
    installForeignMajor(5, 5)
    local yellow = mkCity({ owner = 5, team = 5, damage = 80 })
    T.truthy(CitySpeech.identity(yellow):find("hp yellow", 1, true), "yellow band at 60%")
    -- 60 / 200 = 0.3 -> red
    setup()
    installForeignMajor(5, 5)
    local red = mkCity({ owner = 5, team = 5, damage = 140 })
    T.truthy(CitySpeech.identity(red):find("hp red", 1, true), "red band at 30%")
end

function M.test_identity_team_city_speaks_garrison_name()
    setup()
    GameInfo.Units[100] = { Description = "Swordsman" }
    local garrison = { GetUnitType = function()
        return 100
    end }
    local city = mkCity({ garrisonedUnit = garrison })
    T.truthy(CitySpeech.identity(city):find("garrisoned Swordsman", 1, true), "garrison name expected")
end

function M.test_identity_enemy_city_omits_garrison()
    -- Other-banner XML has no GarrisonFrame control, so the banner
    -- doesn't leak the defender identity. Mirror that in speech.
    setup()
    installForeignMajor(5, 5)
    GameInfo.Units[100] = { Description = "Swordsman" }
    local garrison = { GetUnitType = function()
        return 100
    end }
    local city = mkCity({ owner = 5, team = 5, garrisonedUnit = garrison })
    T.falsy(CitySpeech.identity(city):find("garrisoned", 1, true), "enemy garrison must not be spoken")
end

-- ===== Development =====

function M.test_development_returns_not_visible_on_enemy_city()
    setup()
    installForeignMajor(5, 5)
    local city = mkCity({ owner = 5, team = 5 })
    T.eq(CitySpeech.development(city), "not visible")
end

function M.test_development_producing_item_with_turns()
    setup()
    local city = mkCity({
        productionKey = "TXT_KEY_UNIT_SWORDSMAN",
        productionTurnsLeft = 4,
        production = 45,
        productionNeeded = 90,
    })
    local out = CitySpeech.development(city)
    T.truthy(out:find("producing", 1, true), "producing prefix: " .. out)
    T.truthy(out:find("4 turns", 1, true), "turns left: " .. out)
    T.truthy(out:find("45 of 90 production", 1, true), "progress fraction: " .. out)
end

function M.test_development_not_producing_when_empty_key()
    setup()
    local city = mkCity({ productionKey = "", productionNeeded = 0 })
    T.truthy(CitySpeech.development(city):find("not producing", 1, true), "empty production key -> not producing")
end

function M.test_development_stopped_growing_when_food_diff_zero()
    setup()
    local city = mkCity({ foodDifferenceTimes100 = 0, foodDifference = 0 })
    T.truthy(CitySpeech.development(city):find("stopped growing", 1, true), "stopped growing expected")
end

function M.test_development_starving_when_food_diff_negative()
    setup()
    local city = mkCity({ foodDifferenceTimes100 = -200, foodDifference = -2 })
    local out = CitySpeech.development(city)
    T.truthy(out:find("starving", 1, true), "starving expected: " .. out)
    T.truthy(out:find("losing 2 per turn", 1, true), "food loss rate expected: " .. out)
end

function M.test_development_grows_in_turns_normal_case()
    setup()
    local city = mkCity({ foodDifferenceTimes100 = 300, foodDifference = 3, foodTurnsLeft = 4 })
    local out = CitySpeech.development(city)
    T.truthy(out:find("grows in 4 turns", 1, true), "grows-in expected: " .. out)
    T.truthy(out:find("3 per turn", 1, true), "food per-turn expected: " .. out)
end

function M.test_development_includes_production_per_turn()
    setup()
    local city = mkCity({
        productionKey = "TXT_KEY_UNIT_WARRIOR",
        yieldRate = { [YieldTypes.YIELD_PRODUCTION] = 12, [YieldTypes.YIELD_FOOD] = 5 },
    })
    T.truthy(CitySpeech.development(city):find("12 per turn", 1, true), "production per-turn expected")
end

-- ===== Politics =====

function M.test_politics_speaks_no_info_when_peace_no_religion_no_spy()
    setup()
    local city = mkCity({ religion = -1 })
    T.eq(CitySpeech.politics(city), "no political information")
end

function M.test_politics_speaks_religion_when_majority_exists()
    setup()
    GameInfo.Religions[2] = { Description = "TXT_KEY_RELIGION_ISLAM" }
    local city = mkCity({ religion = 2 })
    T.truthy(CitySpeech.politics(city):find("TXT_KEY_RELIGION_ISLAM", 1, true), "religion descriptor expected")
end

function M.test_politics_speaks_warmonger_preview_when_at_war()
    setup()
    installForeignMajor(5, 5, { atWar = true, warmonger = "Severe warmonger penalty." })
    local city = mkCity({ owner = 5, team = 5, originalOwner = 5 })
    local out = CitySpeech.politics(city)
    T.truthy(out:find("warmonger preview", 1, true), "label expected: " .. out)
    T.truthy(out:find("Severe warmonger penalty", 1, true), "engine preview string expected: " .. out)
end

function M.test_politics_omits_liberation_when_original_owner_same()
    setup()
    installForeignMajor(5, 5, { atWar = true, warmonger = "W", liberation = "L" })
    local city = mkCity({ owner = 5, team = 5, originalOwner = 5 })
    T.falsy(CitySpeech.politics(city):find("liberation", 1, true), "no liberation when original owner unchanged")
end

function M.test_politics_speaks_liberation_when_original_differs()
    -- Captured city: currently owned by team 5 but originally founded
    -- by team 2 (a city-state). Liberation preview should fire.
    setup()
    installForeignMajor(5, 5, { atWar = true, warmonger = "W", liberation = "Liberate to restore Athens." })
    Players[2] = { IsMinorCiv = function()
        return true
    end }
    local city = mkCity({ owner = 5, team = 5, originalOwner = 2 })
    local out = CitySpeech.politics(city)
    T.truthy(out:find("liberation preview", 1, true), "liberation label expected: " .. out)
    T.truthy(out:find("Liberate to restore Athens", 1, true), "engine liberation string expected: " .. out)
end

function M.test_politics_speaks_spy_with_name_and_rank()
    setup()
    Players[0].GetEspionageSpies = function()
        return {
            { CityX = 5, CityY = 5, Name = "Carmen", Rank = "Agent", IsDiplomat = false },
        }
    end
    local city = mkCity({ x = 5, y = 5 })
    local out = CitySpeech.politics(city)
    T.truthy(out:find("spy Carmen, Agent", 1, true), "spy entry expected: " .. out)
end

function M.test_politics_distinguishes_diplomat_from_spy()
    setup()
    Players[0].GetEspionageSpies = function()
        return {
            { CityX = 5, CityY = 5, Name = "Smith", Rank = "Ambassador", IsDiplomat = true },
        }
    end
    local city = mkCity({ x = 5, y = 5 })
    local out = CitySpeech.politics(city)
    T.truthy(out:find("diplomat Smith, Ambassador", 1, true), "diplomat entry expected: " .. out)
    T.falsy(out:find("spy", 1, true), "spy label must not fire for a diplomat: " .. out)
end

function M.test_politics_skips_spy_on_wrong_tile()
    setup()
    Players[0].GetEspionageSpies = function()
        return {
            { CityX = 99, CityY = 99, Name = "Carmen", Rank = "Agent", IsDiplomat = false },
        }
    end
    local city = mkCity({ x = 5, y = 5 })
    T.eq(CitySpeech.politics(city), "no political information")
end

return M
