-- CitySpeech formatter tests. Covers the four cursor number keys
-- (identity + combat, development or city-state influence, religion,
-- diplomatic notes) across ownership tiers (own / team / visible enemy
-- / city-state / unmet) and across the status flags, religion presence,
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
        _followers = opts.followers or {},
        _pressure = opts.pressure or {},
        _tradeRoutes = opts.tradeRoutes or {},
        _holyCityFor = opts.holyCityFor or {},
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
    function c:GetNumFollowers(rid)
        return self._followers[rid] or 0
    end
    function c:GetPressurePerTurn(rid)
        return self._pressure[rid] or 0, self._tradeRoutes[rid] or 0
    end
    function c:IsHolyCityForReligion(rid)
        return self._holyCityFor[rid] or false
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
    -- Religion option default off; tests that exercise the disabled
    -- branch overwrite. Reset the table on every setup so flags from a
    -- prior test don't leak into the next.
    Game._options = {}
    Game.IsOption = function(opt)
        return Game._options[opt] or false
    end
    GameOptionTypes = GameOptionTypes or {}
    GameOptionTypes.GAMEOPTION_NO_RELIGION = "GAMEOPTION_NO_RELIGION"

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
        IsCapitalConnectedToCity = function()
            return false
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
    YieldTypes = YieldTypes or {
        YIELD_FOOD = 0,
        YIELD_PRODUCTION = 1,
    }
    GameDefines = GameDefines or {}
    GameDefines.MAX_CITY_HIT_POINTS = 200
    -- Religion pressure scaling and CS friendship thresholds. Numbers
    -- match the engine's published values so tests exercise realistic
    -- arithmetic; if the engine changes them we want the tests to keep
    -- using the engine's actual values via the GameDefines table at
    -- runtime, so suite_city_speech tests use these constants only as
    -- fixtures.
    GameDefines.RELIGION_MISSIONARY_PRESSURE_MULTIPLIER = 100
    GameDefines.FRIENDSHIP_THRESHOLD_FRIENDS = 30
    GameDefines.FRIENDSHIP_THRESHOLD_ALLIES = 60
end

-- GameInfo.Religions doubles as an id-keyed lookup ("GameInfo.Religions
-- [id]") and as a callable iterator ("for r in GameInfo.Religions()").
-- Religion-breakdown tests that exercise the iterator path replace the
-- plain table set up by setup() with this metatabled variant.
local function makeIterableTable(rows)
    local t = {}
    local idIndex = {}
    for _, row in ipairs(rows) do
        t[#t + 1] = row
        idIndex[row.ID] = row
    end
    setmetatable(t, {
        __call = function(self)
            local i = 0
            return function()
                i = i + 1
                return self[i]
            end
        end,
        __index = function(_, key)
            return idIndex[key]
        end,
    })
    return t
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
        GetCivilizationShortDescriptionKey = function()
            return opts.shortDescKey or "TXT_KEY_CIV_FOREIGN_SHORT"
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
    GameInfo.MinorCivilizations[traitType.minorType or 42] =
        { MinorCivTrait = traitType.traitRow or "MINOR_CIV_TRAIT_MILITARISTIC_ROW" }
    GameInfo.MinorCivTraits[traitType.traitRow or "MINOR_CIV_TRAIT_MILITARISTIC_ROW"] = { Type = traitType.type }
    Players[ownerId] = {
        _isMinor = true,
        _isAllies = opts.allies or false,
        _isFriends = opts.friends or false,
        _minorType = traitType.minorType or 42,
        _influence = opts.influence or 0,
        _influencePerTurnTimes100 = opts.influencePerTurnTimes100 or 0,
        _influenceAnchor = (opts.influenceAnchor == nil) and (opts.influence or 0) or opts.influenceAnchor,
        _canBully = opts.canBully or false,
        _shortDescKey = opts.shortDescKey or "TXT_KEY_CIV_MINOR_SHORT",
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
        GetMinorCivFriendshipWithMajor = function(self, _p)
            return self._influence
        end,
        GetFriendshipChangePerTurnTimes100 = function(self, _p)
            return self._influencePerTurnTimes100
        end,
        GetMinorCivFriendshipAnchorWithMajor = function(self, _p)
            return self._influenceAnchor
        end,
        CanMajorBullyGold = function(self, _p)
            return self._canBully
        end,
        GetCivilizationShortDescriptionKey = function(self)
            return self._shortDescKey
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
    Players[5] = {
        IsMinorCiv = function()
            return false
        end,
    }
    local city = mkCity({ owner = 5, team = 5 })
    T.eq(CitySpeech.identity(city), "unmet")
end

function M.test_development_speaks_unmet_for_unmet_city()
    setup()
    Teams[5] = {
        IsHasMet = function()
            return false
        end,
        IsAtWar = function()
            return false
        end,
        IsPermanentWarPeace = function()
            return false
        end,
    }
    Players[5] = {
        IsMinorCiv = function()
            return false
        end,
    }
    local city = mkCity({ owner = 5, team = 5 })
    T.eq(CitySpeech.development(city), "unmet")
end

function M.test_religion_speaks_unmet_for_unmet_city()
    setup()
    Teams[5] = {
        IsHasMet = function()
            return false
        end,
        IsAtWar = function()
            return false
        end,
        IsPermanentWarPeace = function()
            return false
        end,
    }
    Players[5] = {
        IsMinorCiv = function()
            return false
        end,
    }
    local city = mkCity({ owner = 5, team = 5 })
    T.eq(CitySpeech.religion(city), "unmet")
end

function M.test_diplomatic_speaks_unmet_for_unmet_city()
    setup()
    Teams[5] = {
        IsHasMet = function()
            return false
        end,
        IsAtWar = function()
            return false
        end,
        IsPermanentWarPeace = function()
            return false
        end,
    }
    Players[5] = {
        IsMinorCiv = function()
            return false
        end,
    }
    local city = mkCity({ owner = 5, team = 5 })
    T.eq(CitySpeech.diplomatic(city), "unmet")
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
    local garrison = {
        GetUnitType = function()
            return 100
        end,
    }
    local city = mkCity({ garrisonedUnit = garrison })
    T.truthy(CitySpeech.identity(city):find("garrisoned Swordsman", 1, true), "garrison name expected")
end

function M.test_identity_enemy_city_omits_garrison()
    -- Other-banner XML has no GarrisonFrame control, so the banner
    -- doesn't leak the defender identity. Mirror that in speech.
    setup()
    installForeignMajor(5, 5)
    GameInfo.Units[100] = { Description = "Swordsman" }
    local garrison = {
        GetUnitType = function()
            return 100
        end,
    }
    local city = mkCity({ owner = 5, team = 5, garrisonedUnit = garrison })
    T.falsy(CitySpeech.identity(city):find("garrisoned", 1, true), "enemy garrison must not be spoken")
end

function M.test_identity_team_non_capital_speaks_connected_when_route_home()
    setup()
    Players[0].IsCapitalConnectedToCity = function()
        return true
    end
    local city = mkCity({ isCapital = false })
    T.truthy(
        CitySpeech.identity(city):find("connected", 1, true),
        "connected token expected on team non-capital with route home"
    )
end

function M.test_identity_enemy_city_omits_connected_token()
    -- IsCapitalConnectedToCity on an enemy player asks about THEIR road
    -- network, not the active player's, so connected must not be spoken
    -- for non-team cities.
    setup()
    installForeignMajor(5, 5)
    Players[5].IsCapitalConnectedToCity = function()
        return true
    end
    local city = mkCity({ owner = 5, team = 5, isCapital = false })
    T.falsy(CitySpeech.identity(city):find("connected", 1, true), "enemy city must not speak connected")
end

-- ===== Development =====

function M.test_development_points_at_espionage_on_foreign_major_city()
    -- Foreign-major branch on key 2: the banner doesn't reveal production
    -- and a spy in the city alone doesn't change that. The hint string
    -- points at the Espionage Overview, where sighted players actually
    -- see what each foreign civ is producing.
    setup()
    installForeignMajor(5, 5)
    local city = mkCity({ owner = 5, team = 5 })
    local out = CitySpeech.development(city)
    T.truthy(out:find("hidden", 1, true), "hidden marker expected: " .. out)
    T.truthy(out:find("Espionage Overview", 1, true), "espionage hint expected: " .. out)
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
    -- GetProductionNeeded returns INT32_MAX as a sentinel when nothing is
    -- queued; the output must not leak that number as "0 of 2147483647".
    setup()
    local city = mkCity({ productionKey = "", productionNeeded = 2147483647, production = 0 })
    local out = CitySpeech.development(city)
    T.truthy(out:find("not producing", 1, true), "empty production key -> not producing: " .. out)
    T.falsy(out:find("production", 1, true), "no progress fraction when not producing: " .. out)
    T.falsy(out:find("2147483647", 1, true), "INT_MAX sentinel must not leak: " .. out)
end

function M.test_development_process_omits_turns_and_progress()
    -- Processes (Wealth / Research / etc.) are perpetual; their production
    -- name carries the signal and the absence of a turn count distinguishes
    -- them from buildable items. INT_MAX on productionNeeded mirrors what
    -- the engine returns for processes.
    setup()
    local city = mkCity({
        productionKey = "TXT_KEY_PROCESS_WEALTH",
        isProductionProcess = true,
        productionNeeded = 2147483647,
        production = 0,
    })
    local out = CitySpeech.development(city)
    -- Comma after the process name asserts the producing line has no
    -- turn count appended (the comma is the parts-join separator).
    T.truthy(out:find("producing TXT_KEY_PROCESS_WEALTH,", 1, true), "process name without turns: " .. out)
    T.falsy(out:find("production", 1, true), "no progress fraction for process: " .. out)
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

-- ===== Development: city-state branch (key 2 on a CS) =====

function M.test_development_on_city_state_speaks_influence_value()
    setup()
    installMinorCiv(
        1,
        1,
        { type = "MINOR_CIV_TRAIT_MILITARISTIC" },
        { influence = 25, influencePerTurnTimes100 = 0, influenceAnchor = 25 }
    )
    local city = mkCity({ owner = 1, team = 1 })
    local out = CitySpeech.development(city)
    T.truthy(out:find("+25 influence", 1, true), "influence value expected (signed): " .. out)
end

function M.test_development_on_city_state_speaks_per_turn_when_nonzero()
    setup()
    installMinorCiv(
        1,
        1,
        { type = "MINOR_CIV_TRAIT_MILITARISTIC" },
        { influence = 25, influencePerTurnTimes100 = 200, influenceAnchor = 25 }
    )
    local city = mkCity({ owner = 1, team = 1 })
    local out = CitySpeech.development(city)
    T.truthy(out:find("+2 per turn", 1, true), "per-turn rate expected: " .. out)
end

function M.test_development_on_city_state_omits_per_turn_when_zero()
    setup()
    installMinorCiv(
        1,
        1,
        { type = "MINOR_CIV_TRAIT_MILITARISTIC" },
        { influence = 25, influencePerTurnTimes100 = 0, influenceAnchor = 25 }
    )
    local city = mkCity({ owner = 1, team = 1 })
    T.falsy(CitySpeech.development(city):find("per turn", 1, true), "no per-turn token at zero rate")
end

function M.test_development_on_city_state_speaks_anchor_when_diverged()
    setup()
    installMinorCiv(
        1,
        1,
        { type = "MINOR_CIV_TRAIT_MILITARISTIC" },
        { influence = 35, influencePerTurnTimes100 = -100, influenceAnchor = 0 }
    )
    local city = mkCity({ owner = 1, team = 1 })
    T.truthy(CitySpeech.development(city):find("anchored to %+0"), "anchor expected when distinct from current")
end

function M.test_development_on_city_state_omits_anchor_when_equal()
    setup()
    installMinorCiv(
        1,
        1,
        { type = "MINOR_CIV_TRAIT_MILITARISTIC" },
        { influence = 0, influencePerTurnTimes100 = 0, influenceAnchor = 0 }
    )
    local city = mkCity({ owner = 1, team = 1 })
    T.falsy(CitySpeech.development(city):find("anchored", 1, true), "no anchor token when equal to current")
end

function M.test_development_on_city_state_speaks_friend_threshold_when_below()
    setup()
    -- Influence 10, friends threshold 30 -> 20 needed.
    installMinorCiv(
        1,
        1,
        { type = "MINOR_CIV_TRAIT_MILITARISTIC" },
        { influence = 10, influencePerTurnTimes100 = 0, influenceAnchor = 10 }
    )
    local city = mkCity({ owner = 1, team = 1 })
    T.truthy(CitySpeech.development(city):find("20 needed to become friends", 1, true), "friends gap expected")
end

function M.test_development_on_city_state_speaks_allies_threshold_when_between()
    setup()
    -- Influence 40, allies threshold 60 -> 20 needed.
    installMinorCiv(
        1,
        1,
        { type = "MINOR_CIV_TRAIT_MILITARISTIC" },
        { influence = 40, influencePerTurnTimes100 = 0, influenceAnchor = 40 }
    )
    local city = mkCity({ owner = 1, team = 1 })
    T.truthy(CitySpeech.development(city):find("20 needed to become allies", 1, true), "allies gap expected")
end

function M.test_development_on_city_state_speaks_bullyable_when_set()
    setup()
    installMinorCiv(
        1,
        1,
        { type = "MINOR_CIV_TRAIT_MILITARISTIC" },
        { influence = 0, influencePerTurnTimes100 = 0, influenceAnchor = 0, canBully = true }
    )
    local city = mkCity({ owner = 1, team = 1 })
    T.truthy(CitySpeech.development(city):find("bullyable", 1, true), "bullyable token expected")
end

-- ===== Religion =====

function M.test_religion_speaks_no_religion_present_when_no_followers()
    setup()
    GameInfo.Religions = makeIterableTable({})
    local city = mkCity({ religion = -1 })
    T.eq(CitySpeech.religion(city), "no religion present")
end

function M.test_religion_speaks_disabled_when_game_option_off()
    setup()
    Game._options.GAMEOPTION_NO_RELIGION = true
    local city = mkCity({ religion = -1 })
    T.truthy(CitySpeech.religion(city):find("Religion off", 1, true), "religion-off token expected")
end

function M.test_religion_speaks_majority_with_followers_and_pressure()
    setup()
    GameInfo.Religions = makeIterableTable({
        { ID = 2, Description = "TXT_KEY_RELIGION_ISLAM" },
    })
    local city = mkCity({
        religion = 2,
        followers = { [2] = 8 },
        pressure = { [2] = 600 },
    })
    local out = CitySpeech.religion(city)
    T.truthy(out:find("TXT_KEY_RELIGION_ISLAM", 1, true), "religion name expected: " .. out)
    T.truthy(out:find("8 followers", 1, true), "follower count expected: " .. out)
    T.truthy(out:find("6 pressure", 1, true), "pressure (raw / divisor) expected: " .. out)
end

function M.test_religion_marks_holy_city_when_set()
    setup()
    GameInfo.Religions = makeIterableTable({
        { ID = 1, Description = "TXT_KEY_RELIGION_BUDDHISM" },
    })
    local city = mkCity({
        religion = 1,
        followers = { [1] = 5 },
        pressure = { [1] = 0 },
        holyCityFor = { [1] = true },
    })
    T.truthy(CitySpeech.religion(city):find("holy city", 1, true), "holy-city marker expected")
end

function M.test_religion_includes_minority_religions_with_followers()
    setup()
    GameInfo.Religions = makeIterableTable({
        { ID = 1, Description = "TXT_KEY_RELIGION_BUDDHISM" },
        { ID = 2, Description = "TXT_KEY_RELIGION_ISLAM" },
    })
    -- Majority Islam (8); minority Buddhism (3) also present.
    local city = mkCity({
        religion = 2,
        followers = { [1] = 3, [2] = 8 },
        pressure = { [1] = 0, [2] = 200 },
    })
    local out = CitySpeech.religion(city)
    local iIslam = out:find("TXT_KEY_RELIGION_ISLAM", 1, true)
    local iBud = out:find("TXT_KEY_RELIGION_BUDDHISM", 1, true)
    T.truthy(iIslam and iBud, "both religions expected: " .. out)
    T.truthy(iIslam < iBud, "majority must lead, minority follows: " .. out)
end

function M.test_religion_sorts_by_follower_count_descending()
    -- Iteration order in GameInfo (Islam, Buddhism, Christianity) must
    -- not drive output order: the most-followed religion leads. Followers:
    -- Christianity 7, Islam 4, Buddhism 2.
    setup()
    GameInfo.Religions = makeIterableTable({
        { ID = 1, Description = "TXT_KEY_RELIGION_ISLAM" },
        { ID = 2, Description = "TXT_KEY_RELIGION_BUDDHISM" },
        { ID = 3, Description = "TXT_KEY_RELIGION_CHRISTIANITY" },
    })
    local city = mkCity({
        religion = 1,
        followers = { [1] = 4, [2] = 2, [3] = 7 },
        pressure = { [1] = 0, [2] = 0, [3] = 0 },
    })
    local out = CitySpeech.religion(city)
    local iChrist = out:find("TXT_KEY_RELIGION_CHRISTIANITY", 1, true)
    local iIslam = out:find("TXT_KEY_RELIGION_ISLAM", 1, true)
    local iBud = out:find("TXT_KEY_RELIGION_BUDDHISM", 1, true)
    T.truthy(iChrist and iIslam and iBud, "all three religions expected: " .. out)
    T.truthy(iChrist < iIslam, "highest count must lead: " .. out)
    T.truthy(iIslam < iBud, "second-highest before lowest: " .. out)
end

function M.test_religion_appends_trade_route_count_when_nonzero()
    setup()
    GameInfo.Religions = makeIterableTable({
        { ID = 2, Description = "TXT_KEY_RELIGION_ISLAM" },
    })
    local city = mkCity({
        religion = 2,
        followers = { [2] = 5 },
        pressure = { [2] = 300 },
        tradeRoutes = { [2] = 2 },
    })
    T.truthy(CitySpeech.religion(city):find("via 2 trade routes", 1, true), "trade-route fragment expected")
end

function M.test_religion_omits_trade_route_count_when_zero()
    setup()
    GameInfo.Religions = makeIterableTable({
        { ID = 2, Description = "TXT_KEY_RELIGION_ISLAM" },
    })
    local city = mkCity({
        religion = 2,
        followers = { [2] = 5 },
        pressure = { [2] = 300 },
        tradeRoutes = { [2] = 0 },
    })
    T.falsy(CitySpeech.religion(city):find("trade route", 1, true), "no trade-route fragment when zero")
end

-- ===== Diplomatic notes =====

function M.test_diplomatic_speaks_no_notes_when_nothing_to_surface()
    setup()
    local city = mkCity({})
    T.eq(CitySpeech.diplomatic(city), "no diplomatic notes")
end

function M.test_diplomatic_speaks_originally_cs_when_minor_was_founder()
    -- City currently owned by major team 5 but originally founded by
    -- city-state team 2. Persistent fact regardless of war state.
    setup()
    installForeignMajor(5, 5)
    Players[2] = {
        IsMinorCiv = function()
            return true
        end,
        GetCivilizationShortDescriptionKey = function()
            return "TXT_KEY_CIV_ATHENS_SHORT"
        end,
    }
    local city = mkCity({ owner = 5, team = 5, originalOwner = 2 })
    local out = CitySpeech.diplomatic(city)
    T.truthy(out:find("originally", 1, true), "originally label expected: " .. out)
    T.truthy(out:find("TXT_KEY_CIV_ATHENS_SHORT", 1, true), "founder name expected: " .. out)
end

function M.test_diplomatic_omits_originally_cs_when_owner_is_founder()
    -- City held by its original CS owner: no flip indicator.
    setup()
    installMinorCiv(2, 2, { type = "MINOR_CIV_TRAIT_CULTURED" })
    local city = mkCity({ owner = 2, team = 2, originalOwner = 2 })
    T.falsy(CitySpeech.diplomatic(city):find("originally", 1, true), "no originally token when held by founder")
end

function M.test_diplomatic_omits_originally_when_original_was_major()
    -- Different-major recapture is not surfaced -- the banner only paints
    -- the MinorIndicator for minor original founders.
    setup()
    installForeignMajor(5, 5)
    installForeignMajor(7, 7)
    local city = mkCity({ owner = 5, team = 5, originalOwner = 7 })
    T.falsy(CitySpeech.diplomatic(city):find("originally", 1, true), "no originally token for major recapture")
end

function M.test_diplomatic_speaks_warmonger_preview_when_at_war()
    setup()
    installForeignMajor(5, 5, { atWar = true, warmonger = "Severe warmonger penalty." })
    local city = mkCity({ owner = 5, team = 5, originalOwner = 5 })
    local out = CitySpeech.diplomatic(city)
    T.truthy(out:find("warmonger preview", 1, true), "label expected: " .. out)
    T.truthy(out:find("Severe warmonger penalty", 1, true), "engine preview string expected: " .. out)
end

function M.test_diplomatic_omits_warmonger_when_at_peace()
    setup()
    installForeignMajor(5, 5, { atWar = false, warmonger = "Severe." })
    local city = mkCity({ owner = 5, team = 5, originalOwner = 5 })
    T.falsy(
        CitySpeech.diplomatic(city):find("warmonger", 1, true),
        "warmonger preview must not fire at peace"
    )
end

function M.test_diplomatic_omits_liberation_when_original_owner_same()
    setup()
    installForeignMajor(5, 5, { atWar = true, warmonger = "W", liberation = "L" })
    local city = mkCity({ owner = 5, team = 5, originalOwner = 5 })
    T.falsy(
        CitySpeech.diplomatic(city):find("liberation", 1, true),
        "no liberation when original owner unchanged"
    )
end

function M.test_diplomatic_speaks_liberation_when_original_differs()
    setup()
    installForeignMajor(5, 5, { atWar = true, warmonger = "W", liberation = "Liberate to restore Athens." })
    Players[2] = {
        IsMinorCiv = function()
            return true
        end,
        GetCivilizationShortDescriptionKey = function()
            return "TXT_KEY_CIV_ATHENS_SHORT"
        end,
    }
    local city = mkCity({ owner = 5, team = 5, originalOwner = 2 })
    local out = CitySpeech.diplomatic(city)
    T.truthy(out:find("liberation preview", 1, true), "liberation label expected: " .. out)
    T.truthy(out:find("Liberate to restore Athens", 1, true), "engine liberation string expected: " .. out)
end

function M.test_diplomatic_speaks_spy_with_name_and_rank()
    setup()
    Players[0].GetEspionageSpies = function()
        return {
            { CityX = 5, CityY = 5, Name = "Carmen", Rank = "Agent", IsDiplomat = false },
        }
    end
    local city = mkCity({ x = 5, y = 5 })
    local out = CitySpeech.diplomatic(city)
    T.truthy(out:find("spy Carmen, Agent", 1, true), "spy entry expected: " .. out)
end

function M.test_diplomatic_distinguishes_diplomat_from_spy()
    setup()
    Players[0].GetEspionageSpies = function()
        return {
            { CityX = 5, CityY = 5, Name = "Smith", Rank = "Ambassador", IsDiplomat = true },
        }
    end
    local city = mkCity({ x = 5, y = 5 })
    local out = CitySpeech.diplomatic(city)
    T.truthy(out:find("diplomat Smith, Ambassador", 1, true), "diplomat entry expected: " .. out)
    T.falsy(out:find("spy", 1, true), "spy label must not fire for a diplomat: " .. out)
end

function M.test_diplomatic_skips_spy_on_wrong_tile()
    setup()
    Players[0].GetEspionageSpies = function()
        return {
            { CityX = 99, CityY = 99, Name = "Carmen", Rank = "Agent", IsDiplomat = false },
        }
    end
    local city = mkCity({ x = 5, y = 5 })
    T.eq(CitySpeech.diplomatic(city), "no diplomatic notes")
end

return M
