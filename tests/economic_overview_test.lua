-- F2 Economic Overview wrapper tests. Exercises the helpers exposed via
-- the EconomicOverviewAccess module table after dofiling the wrapper with a
-- stubbed engine surface. The TabbedShell.install at the bottom of the
-- wrapper is guarded on a real ContextPtr so dofile doesn't try to wire up
-- a fake Context.

local T = require("support")
local M = {}

local function setup()
    -- Capturing log so missing TXT_KEYs don't blow up.
    Log.warn = function() end
    Log.error = function() end
    Log.info = function() end
    Log.debug = function() end

    -- Reset speech / handler state so dofile-time writes don't leak.
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    SpeechPipeline._reset()
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")

    Locale.ToNumber = function(n, _fmt)
        return tostring(n)
    end

    -- Engine globals the helpers reach for.
    GameOptionTypes = {
        GAMEOPTION_NO_SCIENCE = 1,
        GAMEOPTION_NO_RELIGION = 2,
        GAMEOPTION_NO_HAPPINESS = 3,
    }
    ButtonPopupTypes = ButtonPopupTypes or {}
    ButtonPopupTypes.BUTTONPOPUP_CHOOSEPRODUCTION = 100
    ButtonPopupTypes.BUTTONPOPUP_TECH_TREE = 101

    Game = Game or {}
    Game.IsOption = function()
        return false
    end
    Game.GetActivePlayer = function()
        return 0
    end
    Game.GetResourceUsageType = function()
        return 0
    end

    GameDefines = GameDefines or {}
    GameDefines.MAX_CITY_HIT_POINTS = 200

    ResourceUsageTypes = ResourceUsageTypes
        or {
            RESOURCEUSAGE_BONUS = 0,
            RESOURCEUSAGE_STRATEGIC = 1,
            RESOURCEUSAGE_LUXURY = 2,
        }

    Players = {}
    Events = Events or {}
    Events.SerialEventGameMessagePopup = function() end

    UI = UI or {}
    UI.LookAt = function() end
    UI.SelectCity = function() end

    -- Popup dismissal goes through UIManager:DequeuePopup; the wrapper calls
    -- this when the science cell or a focusCity row Enter fires so EO closes
    -- before the next popup / cursor jump runs. Stub records that it ran.
    UIManager = UIManager or {}
    function UIManager:DequeuePopup() end

    -- ScannerNav.jumpCursorTo lives on civvaccess_shared.modules in-game;
    -- stub it here so focusCity has the same shared-module surface to call.
    civvaccess_shared = civvaccess_shared or {}
    civvaccess_shared.modules = civvaccess_shared.modules or {}
    civvaccess_shared.modules.ScannerNav = {
        jumpCursorTo = function()
            return ""
        end,
    }

    -- include() in the wrapper resolves to a noop here; the deps the wrapper
    -- needs (HandlerStack, BaseMenu, BaseTable, TabbedShell) are dofiled by
    -- this setup before the wrapper itself, in the order BaseMenu.install
    -- requires.
    include = function() end

    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_InputRouter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TickPump.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Nav.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuItems.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TypeAheadSearch.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuHelp.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuTabs.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuCore.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuInstall.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TabbedShell.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseTableCore.lua")
    -- Real CitySpeech so growthToken in the population cell test exercises
    -- the same code path the cursor / CityView do.
    dofile("src/dlc/UI/InGame/CivVAccess_CitySpeech.lua")

    -- Make sure the install guard skips: ContextPtr is not a table-with-methods.
    ContextPtr = nil

    -- Wrapper. dofile triggers the install guard, which short-circuits.
    EconomicOverviewAccess = nil
    dofile("src/dlc/UI/InGame/Popups/CivVAccess_EconomicOverviewAccess.lua")
end

-- Stub city with the engine methods the helpers reach for. Pass `opts` to
-- override individual fields.
local function stubCity(opts)
    opts = opts or {}
    local c = {}
    function c:GetName()
        return opts.name or "Rome"
    end
    function c:GetID()
        return opts.id or 1
    end
    function c:GetPopulation()
        return opts.pop or 5
    end
    function c:GetStrengthValue()
        return opts.strength or 1500
    end
    function c:GetDamage()
        return opts.damage or 0
    end
    function c:FoodDifference()
        return opts.food or 3
    end
    function c:FoodDifferenceTimes100()
        return (opts.food or 3) * 100
    end
    function c:IsFoodProduction()
        return opts.foodProd or false
    end
    function c:GetFoodTurnsLeft()
        return opts.growsIn or 8
    end
    function c:GetFood()
        return opts.foodStored or 0
    end
    function c:GrowthThreshold()
        return opts.foodThreshold or 30
    end
    function c:GetJONSCultureStored()
        return opts.cultureStored or 0
    end
    function c:GetJONSCultureThreshold()
        return opts.cultureThreshold or 30
    end
    function c:GetYieldRate(yieldType)
        return (opts.yields or {})[yieldType] or 0
    end
    function c:GetYieldRateTimes100(yieldType)
        return ((opts.yields or {})[yieldType] or 0) * 100
    end
    function c:GetJONSCulturePerTurn()
        return opts.culture or 2
    end
    function c:GetFaithPerTurn()
        return opts.faith or 0
    end
    function c:GetProductionModifier()
        return opts.prodMod or 0
    end
    function c:GetProductionNameKey()
        return opts.prodName or "TXT_KEY_UNIT_WARRIOR"
    end
    function c:IsProduction()
        return opts.isProduction ~= false
    end
    function c:IsProductionProcess()
        return opts.isProcess or false
    end
    function c:GetCurrentProductionDifferenceTimes100()
        return opts.prodDiff or 100
    end
    function c:GetProductionTurnsLeft()
        return opts.prodTurns or 5
    end
    function c:IsCapital()
        return opts.capital or false
    end
    function c:IsPuppet()
        return opts.puppet or false
    end
    function c:IsOccupied()
        return opts.occupied or false
    end
    function c:IsNoOccupiedUnhappiness()
        return opts.noOccupiedUnhappiness or false
    end
    function c:Plot()
        return opts.plot or {}
    end
    return c
end

-- formatSigned --------------------------------------------------------

function M.test_formatSigned_positive_gets_plus()
    setup()
    T.eq(EconomicOverviewAccess.formatSigned(5), "+5")
end

function M.test_formatSigned_zero_unsigned()
    setup()
    T.eq(EconomicOverviewAccess.formatSigned(0), "0")
end

function M.test_formatSigned_negative_unsigned_native_minus()
    setup()
    T.eq(EconomicOverviewAccess.formatSigned(-3), "-3")
end

-- cityAnnotation ------------------------------------------------------

function M.test_cityAnnotation_capital()
    setup()
    local c = stubCity({ capital = true })
    T.eq(EconomicOverviewAccess.cityAnnotation(c), "capital")
end

function M.test_cityAnnotation_puppet()
    setup()
    local c = stubCity({ puppet = true })
    T.eq(EconomicOverviewAccess.cityAnnotation(c), "puppet")
end

function M.test_cityAnnotation_occupied_with_unhappiness()
    setup()
    local c = stubCity({ occupied = true, noOccupiedUnhappiness = false })
    T.eq(EconomicOverviewAccess.cityAnnotation(c), "occupied")
end

function M.test_cityAnnotation_occupied_but_no_unhappiness_unannotated()
    setup()
    local c = stubCity({ occupied = true, noOccupiedUnhappiness = true })
    T.eq(EconomicOverviewAccess.cityAnnotation(c), nil)
end

function M.test_cityAnnotation_normal_city_unannotated()
    setup()
    local c = stubCity({})
    T.eq(EconomicOverviewAccess.cityAnnotation(c), nil)
end

function M.test_cityAnnotation_capital_takes_precedence_over_puppet()
    setup()
    -- Engine guarantees a city is at most one of these, but if the helpers
    -- ever encountered both flags, capital is the more important to surface.
    local c = stubCity({ capital = true, puppet = true })
    T.eq(EconomicOverviewAccess.cityAnnotation(c), "capital")
end

-- cityRowLabel --------------------------------------------------------

function M.test_cityRowLabel_no_annotation_returns_bare_name()
    setup()
    local c = stubCity({ name = "Athens" })
    T.eq(EconomicOverviewAccess.cityRowLabel(c), "Athens")
end

function M.test_cityRowLabel_capital_appended()
    setup()
    local c = stubCity({ name = "Rome", capital = true })
    T.eq(EconomicOverviewAccess.cityRowLabel(c), "Rome (capital)")
end

function M.test_cityRowLabel_occupied_appended()
    setup()
    local c = stubCity({ name = "Sparta", occupied = true })
    T.eq(EconomicOverviewAccess.cityRowLabel(c), "Sparta (occupied)")
end

-- cityProductionPerTurn -----------------------------------------------

function M.test_cityProductionPerTurn_no_modifier()
    setup()
    local c = stubCity({ yields = { [YieldTypes.YIELD_PRODUCTION] = 12 } })
    T.eq(EconomicOverviewAccess.cityProductionPerTurn(c), 12)
end

function M.test_cityProductionPerTurn_applies_percent_modifier()
    setup()
    local c = stubCity({
        yields = { [YieldTypes.YIELD_PRODUCTION] = 10 },
        prodMod = 50,
    })
    T.eq(EconomicOverviewAccess.cityProductionPerTurn(c), 15)
end

-- buildCityColumns visibility ----------------------------------------

local function hasColumn(cols, name)
    for _, c in ipairs(cols) do
        if c.name == name then
            return true
        end
    end
    return false
end

function M.test_buildCityColumns_default_includes_science_and_faith()
    setup()
    local cols = EconomicOverviewAccess.buildCityColumns()
    T.truthy(hasColumn(cols, "TXT_KEY_CIVVACCESS_EO_COL_SCIENCE"))
    T.truthy(hasColumn(cols, "TXT_KEY_CIVVACCESS_EO_COL_FAITH"))
end

function M.test_buildCityColumns_no_science_drops_science_column()
    setup()
    Game.IsOption = function(opt)
        return opt == GameOptionTypes.GAMEOPTION_NO_SCIENCE
    end
    local cols = EconomicOverviewAccess.buildCityColumns()
    T.falsy(hasColumn(cols, "TXT_KEY_CIVVACCESS_EO_COL_SCIENCE"))
    T.truthy(hasColumn(cols, "TXT_KEY_CIVVACCESS_EO_COL_FAITH"))
end

function M.test_buildCityColumns_no_religion_drops_faith_column()
    setup()
    Game.IsOption = function(opt)
        return opt == GameOptionTypes.GAMEOPTION_NO_RELIGION
    end
    local cols = EconomicOverviewAccess.buildCityColumns()
    T.truthy(hasColumn(cols, "TXT_KEY_CIVVACCESS_EO_COL_SCIENCE"))
    T.falsy(hasColumn(cols, "TXT_KEY_CIVVACCESS_EO_COL_FAITH"))
end

function M.test_buildCityColumns_all_have_getCell_and_sortKey()
    setup()
    local cols = EconomicOverviewAccess.buildCityColumns()
    for _, c in ipairs(cols) do
        T.eq(type(c.getCell), "function", "column " .. c.name .. " getCell")
        T.eq(type(c.sortKey), "function", "column " .. c.name .. " sortKey")
    end
end

function M.test_buildCityColumns_omits_name_column()
    setup()
    local cols = EconomicOverviewAccess.buildCityColumns()
    T.falsy(
        hasColumn(cols, "TXT_KEY_PRODPANEL_CITY_NAME"),
        "city name column should not be present (row label carries the name)"
    )
end

function M.test_buildCityColumns_every_column_has_enterAction()
    setup()
    local cols = EconomicOverviewAccess.buildCityColumns()
    for _, c in ipairs(cols) do
        T.eq(type(c.enterAction), "function", "column " .. c.name .. " missing enterAction")
    end
end

local function findColumn(cols, key)
    for _, c in ipairs(cols) do
        if c.name == key then
            return c
        end
    end
    return nil
end

function M.test_production_column_enterAction_fires_choose_production_popup()
    setup()
    local fired
    Events.SerialEventGameMessagePopup = function(p)
        fired = p
    end
    local prod = findColumn(EconomicOverviewAccess.buildCityColumns(), "TXT_KEY_CIVVACCESS_EO_COL_PRODUCTION")
    T.truthy(prod)
    prod.enterAction(stubCity({ id = 42 }))
    T.eq(fired.Type, ButtonPopupTypes.BUTTONPOPUP_CHOOSEPRODUCTION)
    T.eq(fired.Data1, 42, "Data1 carries the row's city id")
end

function M.test_production_column_enterAction_does_not_dismiss_eo()
    setup()
    -- Production stacks on top of EO; dismissing here would break the
    -- "queue a build then return to the table" flow that worked correctly
    -- in the field log.
    local dismissed = false
    function UIManager:DequeuePopup()
        dismissed = true
    end
    local prod = findColumn(EconomicOverviewAccess.buildCityColumns(), "TXT_KEY_CIVVACCESS_EO_COL_PRODUCTION")
    prod.enterAction(stubCity({ id = 1 }))
    T.eq(dismissed, false, "production must not dismiss EO before firing the popup")
end

function M.test_science_column_enterAction_dismisses_eo_then_opens_tech_tree()
    setup()
    local order = {}
    function UIManager:DequeuePopup()
        order[#order + 1] = "dismiss"
    end
    Events.SerialEventGameMessagePopup = function(p)
        order[#order + 1] = p.Type
    end
    local science = findColumn(EconomicOverviewAccess.buildCityColumns(), "TXT_KEY_CIVVACCESS_EO_COL_SCIENCE")
    T.truthy(science)
    science.enterAction(stubCity())
    -- Dismiss must precede the popup dispatch -- the engine queues
    -- BUTTONPOPUP_TECH_TREE behind any open popup, so a reversed order
    -- leaves the tree pending until the user manually closes EO.
    T.eq(order[1], "dismiss", "EO must dismiss before tech tree fires")
    T.eq(order[2], ButtonPopupTypes.BUTTONPOPUP_TECH_TREE)
end

function M.test_focus_city_speaks_glance_returned_by_jumpCursorTo()
    setup()
    -- jumpCursorTo returns the cursor's announce composer text (or
    -- SCANNER_HERE on a no-move). focusCity must speakInterrupt that text
    -- so the user hears the new location after EO dismisses.
    civvaccess_shared.modules.ScannerNav.jumpCursorTo = function()
        return "grass plot, your borders, capital nearby"
    end
    local spoken
    SpeechPipeline._speakAction = function(text, interrupt)
        spoken = { text = text, interrupt = interrupt }
    end
    local city = stubCity({ id = 1 })
    function city:Plot()
        return {
            GetX = function()
                return 0
            end,
            GetY = function()
                return 0
            end,
        }
    end
    local pop = findColumn(EconomicOverviewAccess.buildCityColumns(), "TXT_KEY_CIVVACCESS_EO_COL_POPULATION")
    pop.enterAction(city)
    T.eq(spoken.text, "grass plot, your borders, capital nearby")
    T.eq(spoken.interrupt, true, "glance must speakInterrupt to clear popup-close speech")
end

function M.test_focus_city_silent_on_empty_glance()
    setup()
    -- Empty glance is the Map.GetPlot-failure signal Cursor.jumpTo emits
    -- after logging; speaking it would surface a blank string to Tolk.
    civvaccess_shared.modules.ScannerNav.jumpCursorTo = function()
        return ""
    end
    local spoken = false
    SpeechPipeline._speakAction = function()
        spoken = true
    end
    local city = stubCity({ id = 1 })
    function city:Plot()
        return {
            GetX = function()
                return 0
            end,
            GetY = function()
                return 0
            end,
        }
    end
    local pop = findColumn(EconomicOverviewAccess.buildCityColumns(), "TXT_KEY_CIVVACCESS_EO_COL_POPULATION")
    pop.enterAction(city)
    T.eq(spoken, false, "empty glance must not reach the speech pipeline")
end

function M.test_focus_city_columns_dismiss_eo_then_jump_cursor_via_scanner()
    setup()
    -- Capture the dismiss + cursor-jump call order; assert each focus column
    -- routes through ScannerNav.jumpCursorTo (the shared bookmark / scanner
    -- Home primitive) rather than bare UI.LookAt + UI.SelectCity.
    local order
    function UIManager:DequeuePopup()
        order[#order + 1] = "dismiss"
    end
    local jumpedTo
    civvaccess_shared.modules.ScannerNav.jumpCursorTo = function(x, y)
        order[#order + 1] = "jump"
        jumpedTo = { x = x, y = y }
        return ""
    end
    local city = stubCity({ id = 7 })
    function city:Plot()
        return {
            GetX = function()
                return 12
            end,
            GetY = function()
                return 9
            end,
        }
    end
    local focusKeys = {
        "TXT_KEY_CIVVACCESS_EO_COL_POPULATION",
        "TXT_KEY_CIVVACCESS_EO_COL_STRENGTH",
        "TXT_KEY_CIVVACCESS_EO_COL_FOOD",
        "TXT_KEY_CIVVACCESS_EO_COL_GOLD",
        "TXT_KEY_CIVVACCESS_EO_COL_CULTURE",
        "TXT_KEY_CIVVACCESS_EO_COL_FAITH",
    }
    local cols = EconomicOverviewAccess.buildCityColumns()
    for _, key in ipairs(focusKeys) do
        order, jumpedTo = {}, nil
        local col = findColumn(cols, key)
        T.truthy(col, key .. " column missing")
        col.enterAction(city)
        T.eq(order[1], "dismiss", key .. ": EO must dismiss before cursor jump")
        T.eq(order[2], "jump", key .. ": cursor jump must follow dismiss")
        T.eq(jumpedTo.x, 12, key .. ": jumpCursorTo received plot x")
        T.eq(jumpedTo.y, 9, key .. ": jumpCursorTo received plot y")
    end
end

-- Column getCell results ----------------------------------------------

function M.test_food_column_getCell_signs_yield_and_appends_progress()
    setup()
    local food = findColumn(EconomicOverviewAccess.buildCityColumns(), "TXT_KEY_CIVVACCESS_EO_COL_FOOD")
    T.truthy(food)
    local city = stubCity({ food = 4, foodStored = 12, foodThreshold = 30 })
    T.eq(food.getCell(city), "+4, 12 of 30 food")
end

function M.test_food_column_getCell_signs_negative_yield_and_appends_progress()
    setup()
    local food = findColumn(EconomicOverviewAccess.buildCityColumns(), "TXT_KEY_CIVVACCESS_EO_COL_FOOD")
    local city = stubCity({ food = -2, foodStored = 5, foodThreshold = 25 })
    T.eq(food.getCell(city), "-2, 5 of 25 food")
end

function M.test_culture_column_getCell_appends_next_tile_clause()
    setup()
    local culture = findColumn(EconomicOverviewAccess.buildCityColumns(), "TXT_KEY_CIVVACCESS_EO_COL_CULTURE")
    T.truthy(culture)
    -- (30 - 10) / 5 = 4 turns to next tile.
    local city = stubCity({ culture = 5, cultureStored = 10, cultureThreshold = 30 })
    T.eq(culture.getCell(city), "+5, next tile in 4 turns")
end

function M.test_culture_column_getCell_appends_stalled_when_perTurn_zero()
    setup()
    local culture = findColumn(EconomicOverviewAccess.buildCityColumns(), "TXT_KEY_CIVVACCESS_EO_COL_CULTURE")
    local city = stubCity({ culture = 0 })
    T.eq(culture.getCell(city), "0, tile expansion stalled")
end

function M.test_strength_column_getCell_divides_by_100_and_appends_full_hp()
    setup()
    local strength = findColumn(EconomicOverviewAccess.buildCityColumns(), "TXT_KEY_CIVVACCESS_EO_COL_STRENGTH")
    T.truthy(strength)
    local city = stubCity({ strength = 1750, damage = 0 })
    T.eq(strength.getCell(city), "17, 200 of 200 hp")
end

function M.test_strength_column_getCell_appends_damaged_hp()
    setup()
    local strength = findColumn(EconomicOverviewAccess.buildCityColumns(), "TXT_KEY_CIVVACCESS_EO_COL_STRENGTH")
    local city = stubCity({ strength = 2000, damage = 75 })
    T.eq(strength.getCell(city), "20, 125 of 200 hp")
end

function M.test_population_column_getCell_appends_grows_in_clause()
    setup()
    local pop = findColumn(EconomicOverviewAccess.buildCityColumns(), "TXT_KEY_CIVVACCESS_EO_COL_POPULATION")
    T.truthy(pop)
    local city = stubCity({ pop = 7, food = 4, growsIn = 8 })
    T.eq(pop.getCell(city), "7, grows in 8 turns")
end

function M.test_population_column_getCell_appends_starving_clause()
    setup()
    local pop = findColumn(EconomicOverviewAccess.buildCityColumns(), "TXT_KEY_CIVVACCESS_EO_COL_POPULATION")
    local city = stubCity({ pop = 5, food = -2 })
    T.eq(pop.getCell(city), "5, starving")
end

function M.test_population_column_getCell_appends_stopped_growing_clause()
    setup()
    local pop = findColumn(EconomicOverviewAccess.buildCityColumns(), "TXT_KEY_CIVVACCESS_EO_COL_POPULATION")
    local city = stubCity({ pop = 5, food = 0 })
    T.eq(pop.getCell(city), "5, stopped growing")
end

function M.test_population_column_sortKey_uses_bare_population()
    setup()
    -- Sort dimension shouldn't shift just because the cell speaks growth too;
    -- a player wants the column to sort by population size, not turns-to-grow.
    local pop = findColumn(EconomicOverviewAccess.buildCityColumns(), "TXT_KEY_CIVVACCESS_EO_COL_POPULATION")
    T.eq(pop.sortKey(stubCity({ pop = 7, growsIn = 1 })), 7)
end

-- productionColumnCell -------------------------------------------------

function M.test_productionColumnCell_with_active_build_includes_turns_and_name()
    setup()
    local city = stubCity({
        yields = { [YieldTypes.YIELD_PRODUCTION] = 10 },
        prodMod = 0,
        prodName = "Warrior", -- passed through Locale.ConvertTextKey
        isProduction = true,
        isProcess = false,
        prodDiff = 100,
        prodTurns = 4,
    })
    local out = EconomicOverviewAccess.productionColumnCell(city)
    T.truthy(out:find("10"), "yield in output")
    T.truthy(out:find("4 turns"), "turn count in output")
    T.truthy(out:find("Warrior"), "build name in output")
end

function M.test_productionColumnCell_with_no_production_says_none()
    setup()
    local city = stubCity({
        yields = { [YieldTypes.YIELD_PRODUCTION] = 0 },
        prodName = "",
        isProduction = false,
    })
    local out = EconomicOverviewAccess.productionColumnCell(city)
    T.truthy(out:find("no production"))
end

-- Player + handicap fixtures ------------------------------------------

-- Stub player exposing the engine methods the happiness/unhappiness
-- helpers reach for. Defaults are zero so each test only sets the
-- specific accessors it cares about.
local function stubPlayer(opts)
    opts = opts or {}
    local p = {}
    -- Per-luxury contributions keyed by resource id; nil → 0. Mirrors the
    -- Expansion2 Lua binding (CvLuaPlayer::lGetHappinessFromLuxury), which
    -- silently adds GetExtraHappinessPerLuxury to the C++ return when
    -- positive. Helpers and display code must strip this back out per row,
    -- otherwise the per-luxury bonus gets double-counted against
    -- GetHappinessFromResources.
    local lux = opts.luxuries or {}
    function p:GetHappinessFromLuxury(id)
        local h = lux[id] or 0
        if h > 0 then
            h = h + (opts.perLuxRate or 0)
        end
        return h
    end
    function p:GetHappinessFromResources()
        return opts.resourcesTotal or 0
    end
    function p:GetHappinessFromResourceVariety()
        return opts.variety or 0
    end
    function p:GetExtraHappinessPerLuxury()
        return opts.perLuxRate or 0
    end
    function p:GetHappiness()
        return opts.happiness or 0
    end
    function p:GetHappinessFromPolicies()
        return opts.fromPolicies or 0
    end
    function p:GetHappinessFromBuildings()
        return opts.fromBuildings or 0
    end
    function p:GetHappinessFromCities()
        return opts.fromCities or 0
    end
    function p:GetHappinessFromTradeRoutes()
        return opts.fromTradeRoutes or 0
    end
    function p:GetHappinessFromReligion()
        return opts.fromReligion or 0
    end
    function p:GetHappinessFromNaturalWonders()
        return opts.fromNaturalWonders or 0
    end
    function p:GetHappinessFromMinorCivs()
        return opts.fromMinorCivs or 0
    end
    function p:GetExtraHappinessPerCity()
        return opts.extraPerCity or 0
    end
    function p:GetNumCities()
        return opts.numCities or 0
    end
    function p:GetHappinessFromLeagues()
        return opts.fromLeagues or 0
    end
    -- Unhappiness modifier accessors used by the tooltip composers.
    function p:GetCityCountUnhappinessMod()
        return opts.cityCountMod or 0
    end
    function p:GetTraitCityUnhappinessMod()
        return opts.traitCityMod or 0
    end
    function p:GetUnhappinessMod()
        return opts.unhappinessMod or 0
    end
    function p:GetTraitPopUnhappinessMod()
        return opts.traitPopMod or 0
    end
    function p:GetCapitalUnhappinessMod()
        return opts.capitalMod or 0
    end
    function p:GetOccupiedPopulationUnhappinessMod()
        return opts.occupiedPopMod or 0
    end
    function p:IsHalfSpecialistUnhappiness()
        return opts.halfSpecialistUnhappiness or false
    end
    return p
end

-- Override GameInfo.Resources to iterate over a fixed set of stub
-- resource rows for the luxury tests. Pass `idsWithDescription` -- a
-- table mapping ID -> Description -- and the iterator yields one row
-- per entry. The Description value is whatever the test wants to look
-- for in row labels (formatted via Locale.ConvertTextKey, which the
-- harness leaves as identity).
local function installResourceFixtures(idsWithDescription)
    GameInfo = GameInfo or {}
    GameInfo.Resources = function()
        local rows = {}
        for id, desc in pairs(idsWithDescription) do
            rows[#rows + 1] = { ID = id, Description = desc }
        end
        local i = 0
        return function()
            i = i + 1
            return rows[i]
        end
    end
end

local function installHandicapFixtures(opts)
    opts = opts or {}
    GameInfo = GameInfo or {}
    GameInfo.HandicapInfos = {
        [0] = {
            NumCitiesUnhappinessMod = opts.numCitiesMod or 100,
            PopulationUnhappinessMod = opts.populationMod or 100,
        },
    }
    Game.GetHandicapType = function()
        return 0
    end
    Game.GetWorldNumCitiesUnhappinessPercent = function()
        return opts.worldMod or 100
    end
end

-- luxuryBaseSumAndCount --------------------------------------------------

function M.test_luxuryBaseSumAndCount_skips_unowned_luxuries()
    setup()
    installResourceFixtures({
        [1] = "TXT_KEY_RESOURCE_WINE",
        [2] = "TXT_KEY_RESOURCE_SILK",
        [3] = "TXT_KEY_RESOURCE_GOLD",
    })
    local p = stubPlayer({
        luxuries = { [1] = 4, [2] = 4 }, -- not [3]: unowned
    })
    local sum, count = EconomicOverviewAccess.luxuryBaseSumAndCount(p)
    T.eq(sum, 8)
    T.eq(count, 2)
end

function M.test_luxuryBaseSumAndCount_zero_count_when_no_luxuries()
    setup()
    installResourceFixtures({
        [1] = "TXT_KEY_RESOURCE_WINE",
    })
    local p = stubPlayer({ luxuries = {} })
    local sum, count = EconomicOverviewAccess.luxuryBaseSumAndCount(p)
    T.eq(sum, 0)
    T.eq(count, 0)
end

function M.test_luxuryBaseSumAndCount_strips_lua_binding_per_luxury_bonus()
    setup()
    installResourceFixtures({
        [1] = "TXT_KEY_RESOURCE_WINE",
        [2] = "TXT_KEY_RESOURCE_SILK",
    })
    -- Per the Expansion2 Lua binding, the stubbed GetHappinessFromLuxury
    -- returns base (4) plus the per-luxury bonus rate (1) = 5. The helper
    -- must strip the per-luxury rate back out so the returned base sum
    -- reflects pkResourceInfo->getHappiness() alone, not the binding-
    -- inflated value. Otherwise the misc-residual formula double-subtracts
    -- the bonus and the drilldown shows phantom contributions.
    local p = stubPlayer({
        luxuries = { [1] = 4, [2] = 4 },
        perLuxRate = 1,
    })
    local sum, count = EconomicOverviewAccess.luxuryBaseSumAndCount(p)
    T.eq(sum, 8) -- 4 + 4 (true base), NOT 5 + 5 = 10
    T.eq(count, 2)
end

-- luxuryMiscResidual -----------------------------------------------------

function M.test_luxuryMiscResidual_zero_when_total_matches_components()
    setup()
    -- 8 luxuries * 4 base = 32, +1 per-luxury rate * 8 = 8; total 40.
    -- Variety 0, misc 0 (the user's reported scenario).
    local p = stubPlayer({
        resourcesTotal = 40,
        variety = 0,
        perLuxRate = 1,
    })
    T.eq(EconomicOverviewAccess.luxuryMiscResidual(p, 32, 8), 0)
end

function M.test_luxuryMiscResidual_picks_up_unattributed_remainder()
    setup()
    -- e.g. Mt. Kailash adds happiness via GetHappinessFromResources but
    -- not via the per-luxury list; the residual catches it.
    local p = stubPlayer({
        resourcesTotal = 50,
        variety = 4,
        perLuxRate = 1,
    })
    -- 50 - 32 (base) - 4 (variety) - (1 * 8) = 6
    T.eq(EconomicOverviewAccess.luxuryMiscResidual(p, 32, 8), 6)
end

-- difficultyHappiness ----------------------------------------------------

function M.test_difficultyHappiness_subtracts_every_listed_source()
    setup()
    local p = stubPlayer({
        happiness = 30,
        fromPolicies = 2,
        resourcesTotal = 8,
        fromBuildings = 4,
        fromCities = 1,
        fromTradeRoutes = 1,
        fromReligion = 0,
        fromNaturalWonders = 1,
        fromMinorCivs = 0,
        extraPerCity = 1,
        numCities = 4, -- contributes 4 to free-per-city
        fromLeagues = 0,
    })
    -- 30 - 2 - 8 - 4 - 1 - 1 - 0 - 1 - 0 - (1*4) - 0 = 9
    T.eq(EconomicOverviewAccess.difficultyHappiness(p), 9)
end

-- citiesUnhappinessTooltip -----------------------------------------------

function M.test_citiesUnhappinessTooltip_default_difficulty_returns_base_only()
    setup()
    Players[0] = stubPlayer({})
    installHandicapFixtures({}) -- all 100% / 0
    local tip = EconomicOverviewAccess.citiesUnhappinessTooltip()
    -- No modifiers active; base text key only (TXT_KEY_NUMBER_OF_CITIES_TT
    -- resolves to its own name in the harness via missing-key fallback).
    T.eq(tip, "TXT_KEY_NUMBER_OF_CITIES_TT")
end

function M.test_citiesUnhappinessTooltip_appends_handicap_when_modifier_active()
    setup()
    Players[0] = stubPlayer({})
    installHandicapFixtures({ numCitiesMod = 60 }) -- 40% reduction
    local tip = EconomicOverviewAccess.citiesUnhappinessTooltip()
    -- TT_NORMALLY swap (engine pattern unique to Cities row)
    T.truthy(tip:find("TXT_KEY_NUMBER_OF_CITIES_TT_NORMALLY"))
    -- Handicap modifier appendix attached
    T.truthy(tip:find("TXT_KEY_NUMBER_OF_CITIES_HANDICAP_TT"))
end

function M.test_citiesUnhappinessTooltip_chains_multiple_modifiers()
    setup()
    Players[0] = stubPlayer({
        cityCountMod = -25, -- player mod
        traitCityMod = -50, -- trait mod
    })
    installHandicapFixtures({ numCitiesMod = 60, worldMod = 80 })
    local tip = EconomicOverviewAccess.citiesUnhappinessTooltip()
    T.truthy(tip:find("TXT_KEY_UNHAPPINESS_MOD_PLAYER"))
    T.truthy(tip:find("TXT_KEY_UNHAPPINESS_MOD_TRAIT"))
    T.truthy(tip:find("TXT_KEY_UNHAPPINESS_MOD_MAP"))
    T.truthy(tip:find("TXT_KEY_NUMBER_OF_CITIES_HANDICAP_TT"))
end

-- citizensUnhappinessTooltip --------------------------------------------

function M.test_citizensUnhappinessTooltip_includes_specialist_when_flag_set()
    setup()
    Players[0] = stubPlayer({ halfSpecialistUnhappiness = true })
    installHandicapFixtures({})
    local tip = EconomicOverviewAccess.citizensUnhappinessTooltip()
    T.truthy(tip:find("TXT_KEY_UNHAPPINESS_MOD_SPECIALIST"))
    -- Inline "(Normally)" pattern (different from Cities' TT_NORMALLY swap)
    T.truthy(tip:find("TXT_KEY_NORMALLY"))
end

function M.test_citizensUnhappinessTooltip_includes_capital_modifier()
    setup()
    -- Tradition opener: -5% Unhappiness from population in capital.
    Players[0] = stubPlayer({ capitalMod = -5 })
    installHandicapFixtures({})
    local tip = EconomicOverviewAccess.citizensUnhappinessTooltip()
    T.truthy(tip:find("TXT_KEY_UNHAPPINESS_MOD_CAPITAL"))
end

-- occupiedCitizensUnhappinessTooltip ------------------------------------

function M.test_occupiedCitizensUnhappinessTooltip_uses_occupied_pop_mod_not_general()
    setup()
    -- Police State: -10% Unhappiness from occupied population only. The
    -- general unhappiness mod and trait mod must not leak into this row.
    Players[0] = stubPlayer({
        unhappinessMod = -3, -- general (must NOT appear)
        traitPopMod = -2, -- trait (must NOT appear)
        occupiedPopMod = -10, -- occupied (must appear)
    })
    installHandicapFixtures({})
    local tip = EconomicOverviewAccess.occupiedCitizensUnhappinessTooltip()
    -- Occupied-population mod surfaces as TXT_KEY_UNHAPPINESS_MOD_PLAYER
    -- (engine reuses the player-mod text for occupied-pop attribution).
    T.truthy(tip:find("TXT_KEY_UNHAPPINESS_MOD_PLAYER"))
    -- Must not include the general-population trait/capital paths.
    T.falsy(tip:find("TXT_KEY_UNHAPPINESS_MOD_TRAIT"))
    T.falsy(tip:find("TXT_KEY_UNHAPPINESS_MOD_CAPITAL"))
end

-- Resources tab fixtures and tests --------------------------------------
--
-- Builds a player + GameInfo.Resources fixture in one call. `resources` is
-- an array of {id, description, usage, available, used, local, import,
-- export}; missing fields default to 0/luxury. Wires Game.GetResourceUsageType
-- to read each row's `usage` and Players[0] to a stub returning each row's
-- per-resource counts. Order in the array becomes the order GameInfo.Resources
-- iterates, which the row-builder sorts alphabetically anyway.
local function installResourceTabFixture(resources)
    local byID = {}
    for _, r in ipairs(resources) do
        byID[r.id] = r
    end
    GameInfo = GameInfo or {}
    GameInfo.Resources = function()
        local i = 0
        return function()
            i = i + 1
            local row = resources[i]
            if row == nil then
                return nil
            end
            return { ID = row.id, Description = row.description }
        end
    end
    Game.GetResourceUsageType = function(id)
        local r = byID[id]
        if r == nil then
            return ResourceUsageTypes.RESOURCEUSAGE_BONUS
        end
        return r.usage or ResourceUsageTypes.RESOURCEUSAGE_LUXURY
    end
    local p = stubPlayer({})
    function p:GetNumResourceAvailable(id, _includeImport)
        return (byID[id] or {}).available or 0
    end
    function p:GetNumResourceUsed(id)
        return (byID[id] or {}).used or 0
    end
    function p:GetNumResourceTotal(id, includeImport)
        local r = byID[id] or {}
        local total = (r["local"] or 0) - (r.export or 0)
        if includeImport then
            total = total + (r.import or 0)
        end
        return total
    end
    function p:GetResourceImport(id)
        return (byID[id] or {}).import or 0
    end
    function p:GetResourceExport(id)
        return (byID[id] or {}).export or 0
    end
    Players[0] = p
    return p
end

local function findResourceColumn(name)
    for _, c in ipairs(EconomicOverviewAccess.buildResourceColumns()) do
        if c.name == name then
            return c
        end
    end
    return nil
end

-- buildResourceColumns shape -------------------------------------------

function M.test_buildResourceColumns_order_available_used_local_imported_exported()
    setup()
    local cols = EconomicOverviewAccess.buildResourceColumns()
    -- Screen-reader users hear the column name in every cell announcement
    -- (BaseTable speaks "row, column, value"). Available is the first
    -- thing the user wants to know on entering a row, so it must come
    -- first; reordering this is a UX regression.
    T.eq(cols[1].name, "TXT_KEY_CIVVACCESS_EO_RES_AVAILABLE")
    T.eq(cols[2].name, "TXT_KEY_CIVVACCESS_EO_RES_USED")
    T.eq(cols[3].name, "TXT_KEY_CIVVACCESS_EO_RES_LOCAL")
    T.eq(cols[4].name, "TXT_KEY_CIVVACCESS_EO_RES_IMPORTED")
    T.eq(cols[5].name, "TXT_KEY_CIVVACCESS_EO_RES_EXPORTED")
    T.eq(#cols, 5, "exactly five columns")
end

function M.test_buildResourceColumns_all_have_getCell_sortKey_pediaName()
    setup()
    for _, c in ipairs(EconomicOverviewAccess.buildResourceColumns()) do
        T.eq(type(c.getCell), "function", "column " .. c.name .. " getCell")
        T.eq(type(c.sortKey), "function", "column " .. c.name .. " sortKey")
        T.eq(type(c.pediaName), "function", "column " .. c.name .. " pediaName")
    end
end

function M.test_buildResourceColumns_no_enterAction()
    setup()
    -- The engine has no per-counterparty trade or per-unit consumption
    -- breakdown surface, so Enter on a cell has nothing to drill into;
    -- BaseTable's default re-speak is the right behavior. An accidental
    -- enterAction would shadow that.
    for _, c in ipairs(EconomicOverviewAccess.buildResourceColumns()) do
        T.eq(c.enterAction, nil, "column " .. c.name .. " must not define enterAction")
    end
end

-- Used column: strategic vs luxury behavior -----------------------------

function M.test_used_column_speaks_count_for_strategic()
    setup()
    installResourceTabFixture({
        { id = 10, description = "Iron", usage = ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC, used = 4 },
    })
    local used = findResourceColumn("TXT_KEY_CIVVACCESS_EO_RES_USED")
    T.eq(used.getCell({ ID = 10 }), "4")
end

function M.test_used_column_speaks_na_for_luxury_not_zero()
    setup()
    -- A luxury cell of "0" would imply zero out of some pool, but luxuries
    -- have no consumption pool at all -- the "n/a" sentinel is the spoken
    -- distinction the user asked for. The harness loads the en_US strings
    -- file, so the TXT_KEY resolves to the localized "n/a" value rather
    -- than echoing the key verbatim.
    installResourceTabFixture({
        { id = 20, description = "Wine", usage = ResourceUsageTypes.RESOURCEUSAGE_LUXURY, used = 0 },
    })
    local used = findResourceColumn("TXT_KEY_CIVVACCESS_EO_RES_USED")
    T.eq(used.getCell({ ID = 20 }), "n/a")
end

function M.test_used_sortKey_negative_for_luxury_so_descending_sinks_to_bottom()
    setup()
    installResourceTabFixture({
        { id = 10, description = "Iron", usage = ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC, used = 0 },
        { id = 20, description = "Wine", usage = ResourceUsageTypes.RESOURCEUSAGE_LUXURY, used = 0 },
    })
    local used = findResourceColumn("TXT_KEY_CIVVACCESS_EO_RES_USED")
    -- Strategic with 0 used still ranks above luxuries on descending sort.
    T.eq(used.sortKey({ ID = 10 }), 0)
    T.eq(used.sortKey({ ID = 20 }), -1)
end

-- Available / Local / Import / Export plumbing -------------------------

function M.test_available_column_reads_GetNumResourceAvailable()
    setup()
    installResourceTabFixture({
        { id = 10, description = "Iron", usage = ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC, available = 7 },
    })
    local avail = findResourceColumn("TXT_KEY_CIVVACCESS_EO_RES_AVAILABLE")
    T.eq(avail.getCell({ ID = 10 }), "7")
end

function M.test_local_column_returns_raw_owned_agnostic_to_trade_and_use()
    setup()
    -- Local should read 5 even when 2 are exported and 3 are tied up in
    -- units: it's what your own tiles produce post-strategic-mod, not net
    -- of trade or consumption. Verify against the engine's
    -- HappinessInfo.lua formula: GetNumResourceTotal(false) + Export.
    installResourceTabFixture({
        {
            id = 10,
            description = "Iron",
            usage = ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC,
            ["local"] = 5,
            export = 2,
            used = 3,
        },
    })
    local localCol = findResourceColumn("TXT_KEY_CIVVACCESS_EO_RES_LOCAL")
    T.eq(localCol.getCell({ ID = 10 }), "5")
end

function M.test_imported_and_exported_columns_pass_through_player_methods()
    setup()
    installResourceTabFixture({
        { id = 20, description = "Wine", usage = ResourceUsageTypes.RESOURCEUSAGE_LUXURY, import = 3, export = 1 },
    })
    local imp = findResourceColumn("TXT_KEY_CIVVACCESS_EO_RES_IMPORTED")
    local exp = findResourceColumn("TXT_KEY_CIVVACCESS_EO_RES_EXPORTED")
    T.eq(imp.getCell({ ID = 20 }), "3")
    T.eq(exp.getCell({ ID = 20 }), "1")
end

-- rebuildResourceRows filtering ----------------------------------------

local function rowDescriptions(rows)
    local out = {}
    for _, r in ipairs(rows) do
        out[#out + 1] = r.Description
    end
    return out
end

function M.test_rebuildResourceRows_excludes_bonus_resources()
    setup()
    -- Wheat / Cattle / Fish have tile yields but no trade or consumption
    -- mechanics; including them would be six dead rows on every player's
    -- table.
    installResourceTabFixture({
        { id = 1, description = "Wheat", usage = ResourceUsageTypes.RESOURCEUSAGE_BONUS, ["local"] = 5 },
        { id = 2, description = "Wine", usage = ResourceUsageTypes.RESOURCEUSAGE_LUXURY, ["local"] = 2 },
    })
    local rows = EconomicOverviewAccess.rebuildResourceRows()
    T.eq(#rows, 1)
    T.eq(rows[1].Description, "Wine")
end

function M.test_rebuildResourceRows_excludes_resources_with_no_data()
    setup()
    -- Resources you have no exposure to (Uranium before Atomic Theory etc.)
    -- shouldn't waste a row.
    installResourceTabFixture({
        { id = 10, description = "Iron", usage = ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC },
        { id = 20, description = "Wine", usage = ResourceUsageTypes.RESOURCEUSAGE_LUXURY, ["local"] = 2 },
    })
    local rows = EconomicOverviewAccess.rebuildResourceRows()
    T.eq(#rows, 1)
    T.eq(rows[1].Description, "Wine")
end

function M.test_rebuildResourceRows_includes_strategic_known_only_through_usage()
    setup()
    -- Engine corner case: imports already netted to zero (treaty expired
    -- mid-turn) but the unit's reservation hasn't released yet, so Used > 0
    -- with everything else zero. The row must still surface so the player
    -- can see that strategics are tied up despite no apparent stockpile.
    installResourceTabFixture({
        { id = 10, description = "Iron", usage = ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC, used = 2 },
    })
    local rows = EconomicOverviewAccess.rebuildResourceRows()
    T.eq(#rows, 1)
    T.eq(rows[1].Description, "Iron")
end

function M.test_rebuildResourceRows_includes_strategic_visible_via_export_only()
    setup()
    -- Edge case: a captured city's strategic gets immediately exported in
    -- a deal, so Local is zero but Export > 0. ResourceList.lua's same
    -- inclusion rule keeps it visible.
    installResourceTabFixture({
        { id = 10, description = "Iron", usage = ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC, export = 2 },
    })
    local rows = EconomicOverviewAccess.rebuildResourceRows()
    T.eq(#rows, 1)
end

function M.test_rebuildResourceRows_default_order_strategics_first_then_alpha_within_group()
    setup()
    -- Strategics lead because they're decision-critical (running out of
    -- iron mid-war is a problem); within each group the rows are
    -- alphabetical so the user can predictably scan to a known resource.
    installResourceTabFixture({
        { id = 1, description = "Wine", usage = ResourceUsageTypes.RESOURCEUSAGE_LUXURY, ["local"] = 1 },
        { id = 2, description = "Iron", usage = ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC, ["local"] = 1 },
        { id = 3, description = "Citrus", usage = ResourceUsageTypes.RESOURCEUSAGE_LUXURY, ["local"] = 1 },
        { id = 4, description = "Coal", usage = ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC, ["local"] = 1 },
    })
    local rows = EconomicOverviewAccess.rebuildResourceRows()
    T.eq(rowDescriptions(rows)[1], "Coal", "strategics first, alpha within")
    T.eq(rowDescriptions(rows)[2], "Iron")
    T.eq(rowDescriptions(rows)[3], "Citrus", "luxuries follow strategics, alpha within")
    T.eq(rowDescriptions(rows)[4], "Wine")
end

-- resourceRowLabel ------------------------------------------------------

function M.test_resourceRowLabel_returns_localized_description()
    setup()
    -- Description is the resource's TXT_KEY; the harness's missing-key
    -- fallback returns the key verbatim, exercising the same Text.key path
    -- the in-game wrapper hits.
    T.eq(EconomicOverviewAccess.resourceRowLabel({ Description = "TXT_KEY_RESOURCE_WINE" }), "TXT_KEY_RESOURCE_WINE")
end

return M
