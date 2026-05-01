-- Detail readout composition tests. Each Shift+letter detail mirrors the
-- engine *TipHandler in TopPanel.lua, dropping only the segment(s) that the
-- bare key already spoke. These tests script enough of the Player / Game
-- surface to exercise the source breakdowns, then assert against the exact
-- composed string. Templates for engine TXT_KEY_TP_* keys are mirrored
-- locally so passthrough Locale.ConvertTextKey output is readable; the
-- production hash of "{1_N} Science from Cities" is what the player hears.

local T = require("support")
local M = {}

-- Minimal subset of the engine TXT_KEY_TP_* keys the detail readouts use,
-- with the same placeholder shapes the engine ships. The detail tests
-- verify composition order, item / section delimiters, and the headline-
-- skip rule; the exact phrasing of an engine string is not load-bearing,
-- so the templates here are short approximations not the full game text.
local GAME_TEXT = {
    ["TXT_KEY_TP_ANARCHY"] = "Anarchy {1_Turns} turns",
    ["TXT_KEY_TP_SCIENCE"] = "+{1_Rate} Science per Turn",
    ["TXT_KEY_TP_SCIENCE_FROM_CITIES"] = "+{1_Num} Science from Cities",
    ["TXT_KEY_TP_SCIENCE_FROM_ITR"] = "+{1_Num} Science from Trade Routes",
    ["TXT_KEY_TP_SCIENCE_FROM_MINORS"] = "+{1_Num} Science from City-States",
    ["TXT_KEY_TP_SCIENCE_FROM_HAPPINESS"] = "+{1_Num} Science from Happiness",
    ["TXT_KEY_TP_SCIENCE_FROM_RESEARCH_AGREEMENTS"] = "+{1_Num} Science from Research Agreements",
    ["TXT_KEY_TP_SCIENCE_FROM_BUDGET_DEFICIT"] = "{1_Num} Science from Budget Deficit",
    ["TXT_KEY_TP_TECH_CITY_COST"] = "Each city raises tech cost by {1_Pct}%",
    ["TXT_KEY_TP_AVAILABLE_GOLD"] = "Treasury: {1_Gold} Gold",
    ["TXT_KEY_TP_TOTAL_INCOME"] = "{1_Num} Total Income",
    ["TXT_KEY_TP_CITY_OUTPUT"] = "{1_Num} City Output",
    ["TXT_KEY_TP_GOLD_FROM_CITY_CONNECTIONS"] = "{1_Num} City Connections",
    ["TXT_KEY_TP_GOLD_FROM_ITR"] = "{1_Num} Trade Routes",
    ["TXT_KEY_TP_GOLD_FROM_TRAITS"] = "{1_Num} from Traits",
    ["TXT_KEY_TP_GOLD_FROM_OTHERS"] = "{1_Num} from Other Players",
    ["TXT_KEY_TP_GOLD_FROM_RELIGION"] = "{1_Num} from Religion",
    ["TXT_KEY_TP_TOTAL_EXPENSES"] = "{1_Num} Total Expenses",
    ["TXT_KEY_TP_UNIT_MAINT"] = "{1_Num} Unit Maintenance",
    ["TXT_KEY_TP_GOLD_UNIT_SUPPLY"] = "{1_Num} Unit Supply",
    ["TXT_KEY_TP_GOLD_BUILDING_MAINT"] = "{1_Num} Building Maintenance",
    ["TXT_KEY_TP_GOLD_TILE_MAINT"] = "{1_Num} Tile Maintenance",
    ["TXT_KEY_TP_GOLD_TO_OTHERS"] = "{1_Num} to Other Players",
    ["TXT_KEY_TP_LOSING_SCIENCE_FROM_DEFICIT"] = "Deficit will eat into Science",
    ["TXT_KEY_TP_GOLD_EXPLANATION"] = "Gold buys units and upgrades.",
    ["TXT_KEY_TP_TOTAL_HAPPINESS"] = "Total Happiness {1_Num}",
    ["TXT_KEY_TP_TOTAL_UNHAPPINESS"] = "Total Unhappiness {2_Num}",
    ["TXT_KEY_TP_EMPIRE_VERY_UNHAPPY"] = "Empire is Very Unhappy",
    ["TXT_KEY_TP_EMPIRE_SUPER_UNHAPPY"] = "Empire is in Revolt",
    ["TXT_KEY_TP_EMPIRE_UNHAPPY"] = "Empire is Unhappy",
    ["TXT_KEY_TP_HAPPINESS_SOURCES"] = "Happiness Sources {1_Num}",
    ["TXT_KEY_TP_HAPPINESS_FROM_RESOURCES"] = "{1_Num} from Resources",
    ["TXT_KEY_TP_HAPPINESS_EACH_RESOURCE"] = "{1_Num} from {3_Res}",
    ["TXT_KEY_TP_HAPPINESS_RESOURCE_VARIETY"] = "{1_Num} Variety bonus",
    ["TXT_KEY_TP_HAPPINESS_EXTRA_PER_RESOURCE"] = "{1_Num} extra per Luxury",
    ["TXT_KEY_TP_HAPPINESS_OTHER_SOURCES"] = "{1_Num} other resource sources",
    ["TXT_KEY_TP_HAPPINESS_CITIES"] = "{1_Num} from Cities",
    ["TXT_KEY_TP_HAPPINESS_POLICIES"] = "{1_Num} from Policies",
    ["TXT_KEY_TP_HAPPINESS_BUILDINGS"] = "{1_Num} from Buildings",
    ["TXT_KEY_TP_HAPPINESS_CONNECTED_CITIES"] = "{1_Num} from Trade Routes",
    ["TXT_KEY_TP_HAPPINESS_STATE_RELIGION"] = "{1_Num} from Religion",
    ["TXT_KEY_TP_HAPPINESS_NATURAL_WONDERS"] = "{1_Num} from Natural Wonders",
    ["TXT_KEY_TP_HAPPINESS_CITY_COUNT"] = "{1_Num} per City",
    ["TXT_KEY_TP_HAPPINESS_CITY_STATE_FRIENDSHIP"] = "{1_Num} from City-States",
    ["TXT_KEY_TP_HAPPINESS_LEAGUES"] = "{1_Num} from Leagues",
    ["TXT_KEY_TP_HAPPINESS_DIFFICULTY_LEVEL"] = "{1_Num} from Difficulty",
    ["TXT_KEY_TP_UNHAPPINESS_TOTAL"] = "Unhappiness Sources {1_Num}",
    ["TXT_KEY_TP_UNHAPPINESS_CITY_COUNT"] = "{1_Num} from City Count",
    ["TXT_KEY_TP_UNHAPPINESS_CAPTURED_CITY_COUNT"] = "{1_Num} from Captured Cities",
    ["TXT_KEY_TP_UNHAPPINESS_POPULATION"] = "{1_Num} from Population",
    ["TXT_KEY_TP_UNHAPPINESS_PUPPET_CITIES"] = "{1_Num} from Puppet Cities",
    ["TXT_KEY_TP_UNHAPPINESS_SPECIALISTS"] = "{1_Num} from Specialists",
    ["TXT_KEY_TP_UNHAPPINESS_OCCUPIED_POPULATION"] = "{1_Num} from Occupied Cities",
    ["TXT_KEY_TP_UNHAPPINESS_UNITS"] = "{1_Num} from Units",
    ["TXT_KEY_TP_UNHAPPINESS_PUBLIC_OPINION"] = "{1_Num} from Public Opinion",
    ["TXT_KEY_TP_HAPPINESS_EXPLANATION"] = "Happiness powers your empire.",
    ["TXT_KEY_TP_GOLDEN_AGE_NOW"] = "Golden Age for {1_Turns} turns",
    ["TXT_KEY_TP_GOLDEN_AGE_PROGRESS"] = "{1_Cur} of {2_Threshold} to Golden Age",
    ["TXT_KEY_TP_GOLDEN_AGE_ADDITION"] = "{1_Num} adds to Golden Age",
    ["TXT_KEY_TP_GOLDEN_AGE_LOSS"] = "{1_Num} drains Golden Age",
    ["TXT_KEY_TP_GOLDEN_AGE_EFFECT"] = "Golden Age boosts yields",
    ["TXT_KEY_TP_GOLDEN_AGE_EFFECT_NO_CULTURE"] = "Golden Age boosts yields, no culture",
    ["TXT_KEY_TP_CARNIVAL_EFFECT"] = "Carnival doubles tourism",
    ["TXT_KEY_TP_FAITH_ACCUMULATED"] = "{1_Num} Faith stored",
    ["TXT_KEY_TP_FAITH_FROM_CITIES"] = "{1_Num} from Cities",
    ["TXT_KEY_TP_FAITH_FROM_MINORS"] = "{1_Num} from City-States",
    ["TXT_KEY_TP_FAITH_FROM_RELIGION"] = "{1_Num} from Religion",
    ["TXT_KEY_TP_FAITH_NEXT_PROPHET"] = "{1_Num} Faith for next Prophet",
    ["TXT_KEY_TP_FAITH_NEXT_PANTHEON"] = "{1_Num} Faith for Pantheon",
    ["TXT_KEY_TP_FAITH_PANTHEONS_LOCKED"] = "Pantheons locked",
    ["TXT_KEY_TP_FAITH_RELIGIONS_LEFT"] = "{1_Num} religions left to found",
    ["TXT_KEY_TP_FAITH_NEXT_GREAT_PERSON"] = "{1_Num} Faith for next Great Person",
    ["TXT_KEY_RO_YR_NO_GREAT_PEOPLE"] = "No Great People available",
    ["TXT_KEY_NEXT_POLICY_TURN_LABEL"] = "Next Policy in {1_Turns} turns",
    ["TXT_KEY_TP_CULTURE_ACCUMULATED"] = "{1_Num} Culture stored",
    ["TXT_KEY_TP_CULTURE_NEXT_POLICY"] = "{1_Num} Culture for next Policy",
    ["TXT_KEY_TP_CULTURE_FOR_FREE"] = "{1_Num} Free Culture",
    ["TXT_KEY_TP_CULTURE_FROM_CITIES"] = "{1_Num} from Cities",
    ["TXT_KEY_TP_CULTURE_FROM_HAPPINESS"] = "{1_Num} from Happiness",
    ["TXT_KEY_TP_CULTURE_FROM_TRAITS"] = "{1_Num} from Traits",
    ["TXT_KEY_TP_CULTURE_FROM_MINORS"] = "{1_Num} from City-States",
    ["TXT_KEY_TP_CULTURE_FROM_RELIGION"] = "{1_Num} from Religion",
    ["TXT_KEY_TP_CULTURE_FROM_BONUS_TURNS"] = "{1_Num} from Bonus Turns",
    ["TXT_KEY_TP_CULTURE_FROM_GOLDEN_AGE"] = "{1_Num} from Golden Age",
    ["TXT_KEY_TP_CULTURE_CITY_COST"] = "Each city raises policy cost by {1_Pct}%",
    ["TXT_KEY_TOP_PANEL_TOURISM_TOOLTIP_1"] = "{1_Num} Great Works",
    ["TXT_KEY_TOP_PANEL_TOURISM_TOOLTIP_2"] = "{1_Num} empty slots",
    ["TXT_KEY_TOP_PANEL_TOURISM_TOOLTIP_3"] = "Influential on {1_Of}",
    ["TXT_KEY_CO_VICTORY_INFLUENTIAL_OF"] = "{1_Num} of {2_Total} civs",
    -- Engine standalone label keys reused by detail readouts as section
    -- transitions. Production reads the engine's localized values
    -- ("Help", "Income"); the test approximations match.
    ["TXT_KEY_HELP"] = "Help",
    ["TXT_KEY_EO_INCOME"] = "Income",
}

local activePlayer
local team
local options
local resources
local goldData
local sciData
local happyData
local goldenAgeData
local faithData
local cultureData
local tourismData
local otherPlayers
local influenceLevels
local optionNoBasicHelp
local pregameVictories
local greatPeopleUnits
local capitalCity

local function setup()
    T.installLocaleStrings(GAME_TEXT)
    Locale.ToNumber = function(v, _fmt)
        return tostring(v)
    end

    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/InGame/CivVAccess_EmpireStatus.lua")

    options = {}
    resources = {}
    -- Each x100 field is set to its raw value times 100 by the test;
    -- detail code divides by 100 to get the displayed integer.
    sciData = {
        budgetDeficitTimes100 = 0,
        citiesOnlyTimes100 = 0,
        citiesWithTradeTimes100 = 0,
        otherPlayersTimes100 = 0,
        happinessTimes100 = 0,
        researchAgreementsTimes100 = 0,
    }
    goldData = {
        gold = 0,
        fromDiplomacy = 0,
        fromReligion = 0,
        fromCitiesTimes100 = 0,
        fromCitiesMinusTradeTimes100 = 0,
        cityConnectionTimes100 = 0,
        traitGold = 0,
        unitCost = 0,
        unitSupply = 0,
        buildingMaint = 0,
        improvementMaint = 0,
    }
    happyData = {
        excess = 0,
        unhappy = false,
        veryUnhappy = false,
        superUnhappy = false,
        policies = 0,
        resources_ = 0,
        extraPerLux = 0,
        cities = 0,
        buildings = 0,
        tradeRoutes = 0,
        religion = 0,
        naturalWonders = 0,
        extraPerCity = 0,
        numCities = 0,
        minorCivs = 0,
        leagues = 0,
        happiness = 0,
        unhappinessTotal = 0,
        unhappyFromUnits = 0,
        unhappyFromCityCount = 0,
        unhappyFromCaptured = 0,
        unhappyFromPuppets = 0,
        unhappyFromSpecialists = 0,
        unhappyFromPop = 0,
        unhappyFromOccupied = 0,
        publicOpinion = 0,
        varietyBonus = 0,
    }
    goldenAgeData = {
        turns = 0,
        meter = 0,
        threshold = 100,
        cultureBonusDisabled = false,
        tourismModifier = 0,
    }
    faithData = {
        faith = 0,
        rate = 0,
        fromCities = 0,
        fromMinors = 0,
        fromReligion = 0,
        hasPantheon = false,
        canPantheon = true,
        hasReligion = false,
        currentEra = 1,
        nextProphet = 0,
        nextPantheon = 0,
        religionsStillToFound = 3,
    }
    cultureData = {
        culture = 0,
        cost = 0,
        rate = 0,
        forFree = 0,
        fromCities = 0,
        fromHappiness = 0,
        fromTraits = 0,
        fromMinors = 0,
        fromReligion = 0,
        fromBonusTurns = 0,
        bonusTurns = 0,
    }
    tourismData = {
        rate = 0,
        greatWorks = 0,
        slots = 0,
        numInfluential = 0,
        numToBeInfluential = 0,
    }
    otherPlayers = {}
    influenceLevels = {}
    optionNoBasicHelp = false
    pregameVictories = { VICTORY_CULTURAL = true }
    greatPeopleUnits = {}
    capitalCity = nil

    OptionsManager = OptionsManager or {}
    OptionsManager.IsNoBasicHelp = function()
        return optionNoBasicHelp
    end

    Game.GetActivePlayer = function()
        return 0
    end
    Game.IsOption = function(opt)
        return options[opt] == true
    end
    Game.GetNumCitiesTechCostMod = function()
        return 5
    end
    Game.GetNumCitiesPolicyCostMod = function()
        return 7
    end
    Game.GetNumReligionsStillToFound = function()
        return faithData.religionsStillToFound
    end
    Game.GetMinimumFaithNextPantheon = function()
        return faithData.nextPantheon
    end

    GameOptionTypes = {
        GAMEOPTION_NO_SCIENCE = 1,
        GAMEOPTION_NO_HAPPINESS = 2,
        GAMEOPTION_NO_RELIGION = 3,
        GAMEOPTION_NO_POLICIES = 4,
    }
    InfluenceLevelTypes = {
        NO_INFLUENCE_LEVEL = -1,
        INFLUENCE_LEVEL_INFLUENTIAL = 4,
        INFLUENCE_LEVEL_DOMINANT = 5,
    }
    YieldTypes = YieldTypes or {}
    YieldTypes.YIELD_FAITH = 5
    GameDefines = GameDefines or {}
    GameDefines.MAX_CIV_PLAYERS = 8

    GameInfo = GameInfo or {}
    GameInfo.Resources = function()
        local i = 0
        return function()
            i = i + 1
            return resources[i]
        end
    end
    GameInfo.Eras = setmetatable({}, {
        __index = function(_, k)
            if k == "ERA_INDUSTRIAL" then
                return { ID = 5 }
            end
            return nil
        end,
    })
    GameInfo.Victories = setmetatable({}, {
        __index = function(_, k)
            if k == "VICTORY_CULTURAL" then
                return { ID = 3 }
            end
            return nil
        end,
    })
    -- GameInfo.Units{Special = "SPECIALUNIT_PEOPLE"} returns an iterator over
    -- the great-people unit infos. faithDetail uses it to enumerate
    -- buyable Great People in the industrial+ era branch.
    GameInfo.Units = function(filter)
        local i = 0
        local matches = {}
        if filter and filter.Special == "SPECIALUNIT_PEOPLE" then
            for _, u in ipairs(greatPeopleUnits) do
                matches[#matches + 1] = u
            end
        end
        return function()
            i = i + 1
            return matches[i]
        end
    end
    GameInfoTypes = setmetatable({}, {
        __index = function()
            return nil
        end,
    })

    PreGame = {
        IsVictory = function(id)
            for k, v in pairs(pregameVictories) do
                if v then
                    -- Best-effort: match either the symbolic key or the id
                    -- against GameInfo.Victories[k].ID. Tests never set
                    -- pregameVictories with an id, only the symbolic name.
                    if k == "VICTORY_CULTURAL" and id == 3 then
                        return true
                    end
                end
            end
            return false
        end,
    }

    team = {
        GetTeamTechs = function(self)
            return self
        end,
        HasTech = function()
            return true
        end,
    }
    Teams = { [0] = team }

    activePlayer = {
        GetTeam = function()
            return 0
        end,
        IsAnarchy = function()
            return false
        end,
        GetAnarchyNumTurns = function()
            return 0
        end,

        GetGold = function()
            return goldData.gold
        end,
        GetGoldPerTurnFromDiplomacy = function()
            return goldData.fromDiplomacy
        end,
        GetGoldPerTurnFromReligion = function()
            return goldData.fromReligion
        end,
        GetGoldFromCitiesTimes100 = function()
            return goldData.fromCitiesTimes100
        end,
        GetGoldFromCitiesMinusTradeRoutesTimes100 = function()
            return goldData.fromCitiesMinusTradeTimes100
        end,
        GetCityConnectionGoldTimes100 = function()
            return goldData.cityConnectionTimes100
        end,
        GetGoldPerTurnFromTraits = function()
            return goldData.traitGold
        end,
        CalculateUnitCost = function()
            return goldData.unitCost
        end,
        CalculateUnitSupply = function()
            return goldData.unitSupply
        end,
        GetBuildingGoldMaintenance = function()
            return goldData.buildingMaint
        end,
        GetImprovementGoldMaintenance = function()
            return goldData.improvementMaint
        end,

        GetScienceFromBudgetDeficitTimes100 = function()
            return sciData.budgetDeficitTimes100
        end,
        -- Engine signature: GetScienceFromCitiesTimes100(bIgnoreTrade).
        -- bIgnoreTrade=true -> cities-only; bIgnoreTrade=false -> cities
        -- plus trade. Production code subtracts the cities-only result
        -- from the with-trade result to derive the trade-route delta.
        GetScienceFromCitiesTimes100 = function(_, bIgnoreTrade)
            if bIgnoreTrade then
                return sciData.citiesOnlyTimes100
            end
            return sciData.citiesWithTradeTimes100
        end,
        GetScienceFromOtherPlayersTimes100 = function()
            return sciData.otherPlayersTimes100
        end,
        GetScienceFromHappinessTimes100 = function()
            return sciData.happinessTimes100
        end,
        GetScienceFromResearchAgreementsTimes100 = function()
            return sciData.researchAgreementsTimes100
        end,

        GetExcessHappiness = function()
            return happyData.excess
        end,
        IsEmpireUnhappy = function()
            return happyData.unhappy
        end,
        IsEmpireVeryUnhappy = function()
            return happyData.veryUnhappy
        end,
        IsEmpireSuperUnhappy = function()
            return happyData.superUnhappy
        end,
        GetHappinessFromPolicies = function()
            return happyData.policies
        end,
        GetHappinessFromResources = function()
            return happyData.resources_
        end,
        GetExtraHappinessPerLuxury = function()
            return happyData.extraPerLux
        end,
        GetHappinessFromCities = function()
            return happyData.cities
        end,
        GetHappinessFromBuildings = function()
            return happyData.buildings
        end,
        GetHappinessFromTradeRoutes = function()
            return happyData.tradeRoutes
        end,
        GetHappinessFromReligion = function()
            return happyData.religion
        end,
        GetHappinessFromNaturalWonders = function()
            return happyData.naturalWonders
        end,
        GetExtraHappinessPerCity = function()
            return happyData.extraPerCity
        end,
        GetNumCities = function()
            return happyData.numCities
        end,
        GetHappinessFromMinorCivs = function()
            return happyData.minorCivs
        end,
        GetHappinessFromLeagues = function()
            return happyData.leagues
        end,
        GetHappiness = function()
            return happyData.happiness
        end,
        GetHappinessFromLuxury = function(_, id)
            for _, r in ipairs(resources) do
                if r.ID == id then
                    return r.HappinessFromLuxury or 0
                end
            end
            return 0
        end,
        GetHappinessFromResourceVariety = function()
            return happyData.varietyBonus
        end,

        GetUnhappiness = function()
            return happyData.unhappinessTotal
        end,
        GetUnhappinessFromUnits = function()
            return happyData.unhappyFromUnits
        end,
        GetUnhappinessFromCityCount = function()
            return happyData.unhappyFromCityCount
        end,
        GetUnhappinessFromCapturedCityCount = function()
            return happyData.unhappyFromCaptured
        end,
        GetUnhappinessFromPuppetCityPopulation = function()
            return happyData.unhappyFromPuppets
        end,
        GetUnhappinessFromCitySpecialists = function()
            return happyData.unhappyFromSpecialists
        end,
        GetUnhappinessFromCityPopulation = function()
            return happyData.unhappyFromPop
        end,
        GetUnhappinessFromOccupiedCities = function()
            return happyData.unhappyFromOccupied
        end,
        GetUnhappinessFromPublicOpinion = function()
            return happyData.publicOpinion
        end,

        GetGoldenAgeTurns = function()
            return goldenAgeData.turns
        end,
        GetGoldenAgeProgressMeter = function()
            return goldenAgeData.meter
        end,
        GetGoldenAgeProgressThreshold = function()
            return goldenAgeData.threshold
        end,
        IsGoldenAgeCultureBonusDisabled = function()
            return goldenAgeData.cultureBonusDisabled
        end,
        GetGoldenAgeTourismModifier = function()
            return goldenAgeData.tourismModifier
        end,

        GetFaith = function()
            return faithData.faith
        end,
        GetTotalFaithPerTurn = function()
            return faithData.rate
        end,
        GetFaithPerTurnFromCities = function()
            return faithData.fromCities
        end,
        GetFaithPerTurnFromMinorCivs = function()
            return faithData.fromMinors
        end,
        GetFaithPerTurnFromReligion = function()
            return faithData.fromReligion
        end,
        HasCreatedPantheon = function()
            return faithData.hasPantheon
        end,
        HasCreatedReligion = function()
            return faithData.hasReligion
        end,
        CanCreatePantheon = function()
            return faithData.canPantheon
        end,
        GetCurrentEra = function()
            return faithData.currentEra
        end,
        GetMinimumFaithNextGreatProphet = function()
            return faithData.nextProphet
        end,
        GetCapitalCity = function()
            return capitalCity
        end,
        IsCanPurchaseAnyCity = function()
            return true
        end,
        DoesUnitPassFaithPurchaseCheck = function()
            return true
        end,

        GetJONSCulture = function()
            return cultureData.culture
        end,
        GetNextPolicyCost = function()
            return cultureData.cost
        end,
        GetTotalJONSCulturePerTurn = function()
            return cultureData.rate
        end,
        GetJONSCulturePerTurnForFree = function()
            return cultureData.forFree
        end,
        GetJONSCulturePerTurnFromCities = function()
            return cultureData.fromCities
        end,
        GetJONSCulturePerTurnFromExcessHappiness = function()
            return cultureData.fromHappiness
        end,
        GetJONSCulturePerTurnFromTraits = function()
            return cultureData.fromTraits
        end,
        GetCulturePerTurnFromMinorCivs = function()
            return cultureData.fromMinors
        end,
        GetCulturePerTurnFromReligion = function()
            return cultureData.fromReligion
        end,
        GetCulturePerTurnFromBonusTurns = function()
            return cultureData.fromBonusTurns
        end,
        GetCultureBonusTurns = function()
            return cultureData.bonusTurns
        end,

        GetTourism = function()
            return tourismData.rate
        end,
        GetNumGreatWorks = function()
            return tourismData.greatWorks
        end,
        GetNumGreatWorkSlots = function()
            return tourismData.slots
        end,
        GetNumCivsInfluentialOn = function()
            return tourismData.numInfluential
        end,
        GetNumCivsToBeInfluentialOn = function()
            return tourismData.numToBeInfluential
        end,
        GetInfluenceLevel = function(_, otherID)
            return influenceLevels[otherID] or InfluenceLevelTypes.NO_INFLUENCE_LEVEL
        end,
    }
    Players = {}
    Players[0] = activePlayer
    for i = 1, 7 do
        local data = otherPlayers[i] or {}
        Players[i] = {
            IsAlive = function()
                return data.alive ~= false
            end,
            IsMinorCiv = function()
                return data.minor == true
            end,
        }
    end
end

local function refreshPlayers()
    for i = 1, 7 do
        local data = otherPlayers[i] or {}
        Players[i] = {
            IsAlive = function()
                return data.alive ~= false
            end,
            IsMinorCiv = function()
                return data.minor == true
            end,
        }
    end
end

local function contains(haystack, needle)
    return string.find(haystack, needle, 1, true) ~= nil
end

-- Research detail --------------------------------------------------------

function M.test_research_detail_skips_rate_and_lists_sources()
    setup()
    -- Engine convention: bIgnoreTrade=true is cities-only, =false is
    -- cities-plus-trade-routes; trade contribution is the difference.
    -- Setting both fields equal means "no trade routes."
    sciData.citiesOnlyTimes100 = 1500
    sciData.citiesWithTradeTimes100 = 1500
    sciData.otherPlayersTimes100 = 200
    sciData.researchAgreementsTimes100 = 100
    -- Headline (TXT_KEY_TP_SCIENCE / "Science per Turn") must NOT appear --
    -- bare R already spoke the rate. Per-source items joined with ", "
    -- in the source section, basic-help trailer in its own period-delimited
    -- section.
    local s = EmpireStatus._researchDetail()
    T.eq(
        s,
        "+15 Science from Cities, +2 Science from City-States, +1 Science from Research Agreements"
            .. ". Help: +5% tech cost per city"
    )
end

function M.test_research_detail_anarchy_prefix_when_anarchy()
    setup()
    activePlayer.IsAnarchy = function()
        return true
    end
    activePlayer.GetAnarchyNumTurns = function()
        return 3
    end
    sciData.citiesOnlyTimes100 = 800
    sciData.citiesWithTradeTimes100 = 800
    local s = EmpireStatus._researchDetail()
    T.truthy(contains(s, "Anarchy 3 turns"), "anarchy prefix present")
    T.truthy(contains(s, "+8 Science from Cities"), "source line present")
end

function M.test_research_detail_drops_basic_help_when_disabled()
    setup()
    sciData.citiesOnlyTimes100 = 800
    sciData.citiesWithTradeTimes100 = 800
    optionNoBasicHelp = true
    local s = EmpireStatus._researchDetail()
    T.eq(s, "+8 Science from Cities")
end

function M.test_research_detail_off_when_no_science()
    setup()
    options[GameOptionTypes.GAMEOPTION_NO_SCIENCE] = true
    T.eq(EmpireStatus._researchDetail(), "")
end

-- Gold detail ------------------------------------------------------------

function M.test_gold_detail_skips_treasury_and_total_income()
    setup()
    goldData.gold = 250
    goldData.fromCitiesMinusTradeTimes100 = 1500
    goldData.fromCitiesTimes100 = 1700
    goldData.cityConnectionTimes100 = 300
    goldData.unitCost = 4
    goldData.buildingMaint = 6
    local s = EmpireStatus._goldDetail()
    T.falsy(contains(s, "Treasury"), "treasury (TXT_KEY_TP_AVAILABLE_GOLD) skipped")
    T.falsy(contains(s, "Total Income"), "total income (TXT_KEY_TP_TOTAL_INCOME) skipped")
    T.truthy(contains(s, "15 City Output"))
    T.truthy(contains(s, "3 City Connections"))
    T.truthy(contains(s, "10 Total Expenses"))
    T.truthy(contains(s, "4 Unit Maintenance"))
    T.truthy(contains(s, "6 Building Maintenance"))
end

function M.test_gold_detail_warns_about_deficit_eating_science()
    setup()
    -- Negative income larger than treasury -> deficit warning in own section.
    -- Both x100 fields match because there are no trade routes (so trade
    -- contribution is zero); see researchDetail tests for the same engine
    -- convention.
    goldData.gold = 5
    goldData.fromCitiesMinusTradeTimes100 = -2000 -- city output -20
    goldData.fromCitiesTimes100 = -2000
    local s = EmpireStatus._goldDetail()
    T.truthy(contains(s, "Deficit will eat into Science"), "deficit warning surfaces")
end

function M.test_gold_detail_basic_help_trailer_toggle()
    setup()
    goldData.fromCitiesMinusTradeTimes100 = 0
    -- With basic help on, the explanation trailer follows expenses with ". ".
    local withHelp = EmpireStatus._goldDetail()
    -- Trailing engine punctuation is stripped by compose so the spoken
    -- output joins cleanly; the period that the engine string ships with
    -- is gone in the joined result.
    T.truthy(contains(withHelp, "Gold buys units and upgrades"))
    optionNoBasicHelp = true
    local withoutHelp = EmpireStatus._goldDetail()
    T.falsy(contains(withoutHelp, "Gold buys units"), "trailer dropped when option off")
end

-- Happiness detail -------------------------------------------------------

function M.test_happiness_detail_skips_total_lines()
    setup()
    happyData.happiness = 10
    happyData.cities = 0
    happyData.buildings = 6
    happyData.policies = 2
    happyData.minorCivs = 2
    -- handicapHappiness fills the gap to total: happiness=10, others sum 10
    -- so handicap=0; tweak so handicap is non-zero by inflating happiness.
    happyData.happiness = 12
    happyData.unhappinessTotal = 5
    happyData.unhappyFromCityCount = 200 -- 2.0 in display (Locale.ToNumber)
    happyData.unhappyFromPop = 300
    -- Expect the "Total Happiness X" / "Total Unhappiness X" lines to be
    -- absent (those duplicate the bare H headline). Source / unhappiness
    -- breakdowns must be present.
    local s = EmpireStatus._happinessDetail()
    T.falsy(contains(s, "Total Happiness "), "total happiness skipped")
    T.falsy(contains(s, "Total Unhappiness "), "total unhappiness skipped")
    T.truthy(contains(s, "Happiness Sources"))
    T.truthy(contains(s, "Unhappiness Sources"))
    T.truthy(contains(s, "6 from Buildings"))
    T.truthy(contains(s, "2 from Policies"))
    T.truthy(contains(s, "2 from City-States"))
end

function M.test_happiness_detail_very_unhappy_warning_present()
    setup()
    happyData.veryUnhappy = true
    happyData.unhappy = true
    happyData.excess = -5
    local s = EmpireStatus._happinessDetail()
    T.truthy(contains(s, "Empire is Very Unhappy"))
end

function M.test_happiness_detail_super_unhappy_revolt_above_very()
    setup()
    happyData.veryUnhappy = true
    happyData.superUnhappy = true
    happyData.unhappy = true
    happyData.excess = -20
    local s = EmpireStatus._happinessDetail()
    -- Both warnings present and the revolt warning comes before the very-
    -- unhappy line (engine ordering: super-unhappy is escalated state).
    T.truthy(contains(s, "Empire is in Revolt"))
    T.truthy(contains(s, "Empire is Very Unhappy"))
    local revoltAt = string.find(s, "Empire is in Revolt", 1, true)
    local veryAt = string.find(s, "Empire is Very Unhappy", 1, true)
    T.truthy(revoltAt < veryAt, "revolt warning precedes very-unhappy line")
end

function M.test_happiness_detail_folds_in_golden_age_addition_and_effect()
    -- Bare H reads the GA headline (turns or progress); the detail extends
    -- with the addition / loss line and the effect description. Skip the
    -- NOW / PROGRESS lines, keep ADDITION + EFFECT. Distinct meter/
    -- threshold values let us assert the PROGRESS line is gone by
    -- searching for the threshold; "Golden Age" itself appears in the
    -- additive ADDITION / EFFECT lines and isn't a unique marker.
    setup()
    happyData.excess = 4
    goldenAgeData.turns = 0
    goldenAgeData.meter = 80
    goldenAgeData.threshold = 200
    local s = EmpireStatus._happinessDetail()
    T.falsy(contains(s, "Golden Age for "), "GA NOW headline skipped")
    T.falsy(contains(s, "80 of 200"), "GA PROGRESS headline skipped")
    T.truthy(contains(s, "4 adds to Golden Age"))
    T.truthy(contains(s, "Golden Age boosts yields"))
end

-- Engine TXT_KEY_TP_* strings end in "." or ":"; the detail builder must
-- strip that trailing punctuation before joining items / sections, or the
-- spoken stream gets ".," and ".." runs that the screen reader pauses on.
function M.test_happiness_detail_strips_trailing_engine_punctuation()
    setup()
    happyData.excess = 4
    happyData.naturalWonders = 1
    happyData.happiness = 5
    happyData.numCities = 0
    happyData.cities = 0
    happyData.buildings = 0
    happyData.policies = 0
    happyData.resources_ = 0
    -- Override a couple of templates with their real-engine trailing
    -- punctuation so the trim is exercised end-to-end.
    GAME_TEXT["TXT_KEY_TP_HAPPINESS_SOURCES"] = "{1_Num} total Happiness from all sources."
    GAME_TEXT["TXT_KEY_TP_HAPPINESS_FROM_RESOURCES"] = "{1_Num} from Luxury Resources:"
    GAME_TEXT["TXT_KEY_TP_HAPPINESS_DIFFICULTY_LEVEL"] = "{1_Num} from Difficulty Level."
    GAME_TEXT["TXT_KEY_TP_GOLDEN_AGE_ADDITION"] = "{1_Num} adds from excess Happiness."
    local s = EmpireStatus._happinessDetail()
    T.falsy(s:find(".,", 1, true), "no '.,' in joined output: " .. s)
    T.falsy(s:find("..", 1, true), "no '..' in joined output: " .. s)
    T.falsy(s:find(":,", 1, true), "no ':,' in joined output: " .. s)
end

-- The golden-age effect description is a rules explainer with no current
-- state. Gated behind noBasicHelp the same way the dedicated
-- *_EXPLANATION trailers are.
function M.test_happiness_detail_drops_golden_age_effect_when_basic_help_off()
    setup()
    optionNoBasicHelp = true
    happyData.excess = 4
    goldenAgeData.turns = 0
    local s = EmpireStatus._happinessDetail()
    T.truthy(contains(s, "4 adds to Golden Age"), "addition line still present")
    T.falsy(contains(s, "Golden Age boosts yields"), "effect explainer dropped")
end

function M.test_happiness_detail_carnival_when_active_and_modifier()
    setup()
    goldenAgeData.turns = 8
    goldenAgeData.tourismModifier = 100
    local s = EmpireStatus._happinessDetail()
    T.truthy(contains(s, "Carnival doubles tourism"))
end

-- Section-label transitions across the detail readouts. The happiness
-- and unhappiness sub-sections rely on the engine's own TXT_KEY_TP_*
-- leading sentences as topic anchors and stay unlabeled; the golden-age
-- and basic-help transitions don't have an engine anchor so they get
-- mod-authored labels prefixed by ". ".
function M.test_happiness_detail_labels_golden_age_and_help_transitions()
    setup()
    happyData.excess = 4
    goldenAgeData.turns = 0
    goldenAgeData.meter = 80
    goldenAgeData.threshold = 200
    local s = EmpireStatus._happinessDetail()
    T.truthy(contains(s, ". Golden age: "), "GA section labeled at transition: " .. s)
    T.truthy(contains(s, ". Help: "), "basic-help section labeled at transition: " .. s)
end

function M.test_gold_detail_labels_income_and_help_transitions()
    setup()
    goldData.fromCitiesMinusTradeTimes100 = 1500
    goldData.fromCitiesTimes100 = 1500
    local s = EmpireStatus._goldDetail()
    T.truthy(contains(s, "Income: "), "income section labeled: " .. s)
    T.truthy(contains(s, ". Help: "), "help trailer labeled: " .. s)
end

function M.test_research_detail_labels_help_transition()
    setup()
    sciData.citiesOnlyTimes100 = 800
    sciData.citiesWithTradeTimes100 = 800
    local s = EmpireStatus._researchDetail()
    T.truthy(contains(s, ". Help: "), "help trailer labeled: " .. s)
end

function M.test_policy_detail_labels_help_transition()
    setup()
    cultureData.fromCities = 6
    local s = EmpireStatus._policyDetail()
    T.truthy(contains(s, ". Help: "), "help trailer labeled: " .. s)
end

function M.test_faith_detail_labels_religions_transition()
    setup()
    faithData.fromCities = 4
    faithData.canPantheon = false
    faithData.religionsStillToFound = 5
    local s = EmpireStatus._faithDetail()
    T.truthy(contains(s, ". Religions: "), "religions section labeled: " .. s)
end

function M.test_faith_detail_labels_great_people_transition_industrial()
    setup()
    faithData.currentEra = 5
    faithData.nextProphet = 600
    capitalCity = nil
    local s = EmpireStatus._faithDetail()
    T.truthy(contains(s, ". Great people: "), "great-people section labeled: " .. s)
end

function M.test_tourism_detail_labels_influence_transition()
    setup()
    tourismData.rate = 5
    tourismData.totalGreatWorks = 2
    tourismData.totalSlots = 4
    pregameVictories[1] = true -- VICTORY_CULTURAL.ID
    -- influentialOn=2 of total=5 (gap 3, beyond within-reach), so the
    -- bare key didn't speak X-of-Y, and the detail surfaces TOOLTIP_3.
    otherPlayers = { { alive = true, minor = false, influence = 0 } }
    -- Build out the others so total - count > 2. Four more zero-influence
    -- non-minor others puts total at 5, count at 0 (none influential).
    for _ = 1, 4 do
        otherPlayers[#otherPlayers + 1] = { alive = true, minor = false, influence = 0 }
    end
    activePlayer.GetNumCivsInfluentialOn = function()
        return 0
    end
    activePlayer.GetNumCivsToBeInfluentialOn = function()
        return 5
    end
    local s = EmpireStatus._tourismDetail()
    T.truthy(contains(s, ". Influence: "), "influence section labeled: " .. s)
end

-- Faith detail -----------------------------------------------------------

function M.test_faith_detail_skips_accumulated_and_lists_sources()
    setup()
    faithData.fromCities = 4
    faithData.fromMinors = 1
    faithData.canPantheon = false
    faithData.religionsStillToFound = 5
    local s = EmpireStatus._faithDetail()
    T.falsy(contains(s, "Faith stored"), "FAITH_ACCUMULATED skipped (in bare F)")
    T.truthy(contains(s, "4 from Cities"))
    T.truthy(contains(s, "1 from City-States"))
    T.truthy(contains(s, "no pantheons available"))
    T.truthy(contains(s, "5 religions left to found"))
end

function M.test_faith_detail_industrial_era_great_person_branch()
    setup()
    faithData.currentEra = 5
    faithData.nextProphet = 600
    capitalCity = {
        GetUnitFaithPurchaseCost = function(_, infoID)
            -- Two purchasable: ID 1 (Engineer), ID 2 (Scientist). ID 3 too
            -- expensive returns 0 to drop it.
            if infoID == 1 or infoID == 2 then
                return 500
            end
            return 0
        end,
    }
    greatPeopleUnits = {
        { ID = 1, Description = "Great Engineer" },
        { ID = 2, Description = "Great Scientist" },
        { ID = 3, Description = "Great Merchant" },
    }
    local s = EmpireStatus._faithDetail()
    T.truthy(contains(s, "600 Faith for next Great Person"))
    T.truthy(contains(s, "Great Engineer"))
    T.truthy(contains(s, "Great Scientist"))
    T.falsy(contains(s, "Great Merchant"), "non-purchasable unit excluded")
end

function M.test_faith_detail_off_when_no_religion()
    setup()
    options[GameOptionTypes.GAMEOPTION_NO_RELIGION] = true
    T.eq(EmpireStatus._faithDetail(), "")
end

-- Pantheon-faith branch uses the mod-authored short string instead of the
-- engine's TXT_KEY_TP_FAITH_NEXT_PANTHEON, which inlines a long rules
-- explainer after the data value.
function M.test_faith_detail_pantheon_uses_short_form()
    setup()
    faithData.hasPantheon = false
    faithData.canPantheon = true
    faithData.nextPantheon = 25
    local s = EmpireStatus._faithDetail()
    T.truthy(contains(s, "25 faith for next pantheon"), "uses mod-authored short form: " .. s)
    T.falsy(contains(s, "minimum required"), "engine's verbose phrasing not used")
end

-- Same family as the next-pantheon line: engine TXT_KEY_TP_FAITH_NEXT_PROPHET
-- wraps a single data value in a sentence. Use the mod-authored short form.
function M.test_faith_detail_prophet_uses_short_form()
    setup()
    faithData.hasPantheon = true
    faithData.religionsStillToFound = 2
    faithData.currentEra = 2
    faithData.nextProphet = 200
    local s = EmpireStatus._faithDetail()
    T.truthy(contains(s, "200 faith for next great prophet"), "uses mod-authored short form: " .. s)
    T.falsy(contains(s, "minimum required"), "engine's verbose phrasing not used")
end

-- Policy detail ----------------------------------------------------------

function M.test_policy_detail_skips_turn_label_and_lists_sources()
    setup()
    cultureData.culture = 60
    cultureData.cost = 85
    cultureData.rate = 8
    cultureData.fromCities = 5
    cultureData.fromTraits = 3
    local s = EmpireStatus._policyDetail()
    T.falsy(contains(s, "Next Policy in"), "TURN_LABEL skipped (in bare P)")
    T.truthy(contains(s, "60 Culture stored"))
    T.truthy(contains(s, "85 Culture for next Policy"))
    T.truthy(contains(s, "5 from Cities"))
    T.truthy(contains(s, "3 from Traits"))
    T.truthy(contains(s, "+7% policy cost per city"))
end

function M.test_policy_detail_anarchy_short_circuits_source_list()
    -- Engine returns early on anarchy after the basic-help block; sources
    -- and trailer are skipped. Bare P doesn't speak anarchy, so the prefix
    -- is additive.
    setup()
    activePlayer.IsAnarchy = function()
        return true
    end
    activePlayer.GetAnarchyNumTurns = function()
        return 3
    end
    cultureData.culture = 60
    cultureData.cost = 85
    cultureData.fromCities = 5
    local s = EmpireStatus._policyDetail()
    T.truthy(contains(s, "Anarchy 3 turns"))
    T.falsy(contains(s, "5 from Cities"), "source breakdown skipped during anarchy")
    T.falsy(contains(s, "% policy cost per city"), "trailer skipped during anarchy")
end

function M.test_policy_detail_off_when_no_policies()
    setup()
    options[GameOptionTypes.GAMEOPTION_NO_POLICIES] = true
    T.eq(EmpireStatus._policyDetail(), "")
end

-- Tourism detail ---------------------------------------------------------

function M.test_tourism_detail_speaks_great_works_and_slots()
    setup()
    tourismData.greatWorks = 3
    tourismData.slots = 7
    -- No culture victory enabled so tooltip 3 is not in scope.
    pregameVictories = {}
    T.eq(EmpireStatus._tourismDetail(), "3 Great Works, 4 empty slots")
end

function M.test_tourism_detail_appends_x_of_y_when_bare_did_not()
    -- Bare I speaks "X civs" without denominator when gap > 2. Detail
    -- should fill in the X-of-Y in that case.
    setup()
    tourismData.greatWorks = 0
    tourismData.slots = 0
    tourismData.numInfluential = 3
    tourismData.numToBeInfluential = 7
    -- Gap > 2: count=3 of total=7 alive non-minor civs.
    for i = 1, 7 do
        otherPlayers[i] = { alive = true, minor = false }
    end
    refreshPlayers()
    influenceLevels[1] = InfluenceLevelTypes.INFLUENCE_LEVEL_INFLUENTIAL
    influenceLevels[2] = InfluenceLevelTypes.INFLUENCE_LEVEL_INFLUENTIAL
    influenceLevels[3] = InfluenceLevelTypes.INFLUENCE_LEVEL_INFLUENTIAL
    local s = EmpireStatus._tourismDetail()
    T.truthy(contains(s, "Influential on 3 of 7 civs"), "X-of-Y present when bare omitted it")
end

function M.test_tourism_detail_drops_x_of_y_when_bare_already_spoke_it()
    -- Within-reach branch (gap <= 2) means bare I said "5 of 7 civs"
    -- already; detail should NOT repeat it.
    setup()
    tourismData.greatWorks = 1
    tourismData.slots = 4
    tourismData.numInfluential = 5
    tourismData.numToBeInfluential = 7
    for i = 1, 7 do
        otherPlayers[i] = { alive = true, minor = false }
    end
    refreshPlayers()
    for i = 1, 5 do
        influenceLevels[i] = InfluenceLevelTypes.INFLUENCE_LEVEL_INFLUENTIAL
    end
    local s = EmpireStatus._tourismDetail()
    T.falsy(contains(s, "Influential on"), "X-of-Y suppressed (bare already said it)")
    T.truthy(contains(s, "1 Great Works"))
    T.truthy(contains(s, "3 empty slots"))
end

function M.test_tourism_detail_drops_x_of_y_when_no_culture_victory()
    setup()
    tourismData.greatWorks = 0
    tourismData.slots = 0
    pregameVictories = {}
    -- Even with influential count tracking, no cultural victory means
    -- tooltip 3 never appears.
    tourismData.numInfluential = 1
    tourismData.numToBeInfluential = 4
    for i = 1, 7 do
        otherPlayers[i] = { alive = true, minor = false }
    end
    refreshPlayers()
    local s = EmpireStatus._tourismDetail()
    T.falsy(contains(s, "Influential on"), "no X-of-Y when culture victory disabled")
end

return M
