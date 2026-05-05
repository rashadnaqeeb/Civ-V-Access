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

    ResourceUsageTypes = ResourceUsageTypes or { RESOURCEUSAGE_BONUS = 0 }

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
    civvaccess_shared.modules.ScannerNav = { jumpCursorTo = function() return "" end }

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
    Events.SerialEventGameMessagePopup = function(p) fired = p end
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
    function UIManager:DequeuePopup() dismissed = true end
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
        return { GetX = function() return 12 end, GetY = function() return 9 end }
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

return M
