-- ChooseProductionLogic tests. Exercises pure builders (entry construction,
-- sort, disabled / cost / label / advisor compositing) against a minimal
-- city stub and GameInfo table so we don't have to dofile the install-side
-- access module (which touches ContextPtr / InputHandler at load).

local T = require("support")
local M = {}

local function setup()
    -- Quiet logs so missing-key warnings don't pollute the runner output.
    Log.warn = function() end
    Log.error = function() end
    Log.info = function() end
    Log.debug = function() end

    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")

    -- Enum shims. OrderTypes / AdvisorTypes / CityUpdateTypes are not in the
    -- polyfill because only ChooseProduction needs them; add them here so
    -- downstream suites don't inherit an unused enum.
    OrderTypes = OrderTypes
        or {
            ORDER_TRAIN = 0,
            ORDER_CONSTRUCT = 1,
            ORDER_CREATE = 2,
            ORDER_MAINTAIN = 3,
        }
    AdvisorTypes = AdvisorTypes
        or {
            ADVISOR_ECONOMIC = 0,
            ADVISOR_MILITARY = 1,
            ADVISOR_SCIENCE = 2,
            ADVISOR_FOREIGN = 3,
        }
    YieldTypes.YIELD_FAITH = YieldTypes.YIELD_FAITH or 5
    YieldTypes.NO_YIELD = YieldTypes.NO_YIELD or -1

    -- Localized Compare defaults to alphabetical on the raw string so sort
    -- assertions can compare against known Description strings.
    Locale = Locale or {}
    Locale.Compare = function(a, b)
        if a == b then
            return 0
        end
        if a < b then
            return -1
        end
        return 1
    end
    Locale.ConvertTextKey = Locale.ConvertTextKey or function(k, ...)
        return k
    end
    Locale.Lookup = Locale.Lookup or Locale.ConvertTextKey

    -- Game / GameInfo will be populated per-test. Start with an empty scaffold.
    Game = Game or {}
    Game.IsUnitRecommended = function()
        return false
    end
    Game.IsBuildingRecommended = function()
        return false
    end
    Game.IsProjectRecommended = function()
        return false
    end
    Game.SetAdvisorRecommenderCity = function() end
    GameInfo = {}

    CivVAccess_Strings = CivVAccess_Strings or {}
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_BUTTON_DISABLED"] = "disabled"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TURNS"] = "{1_Num} turns"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_GOLD"] = "{1_Num} gold"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_FAITH"] = "{1_Num} faith"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_ADDED_SLOT"] = "added, slot {1_Slot} in queue"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_FULL"] = "queue full"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_EMPTY"] = "queue is empty"

    -- Advisor full-sentence keys: unique per advisor so concatenation is
    -- observable in tests.
    CivVAccess_Strings = CivVAccess_Strings or {}
    -- These aren't TXT_KEY_CIVVACCESS_*, so Text.key routes through Locale
    -- (overridden below to return a distinct string per advisor key).
    dofile("src/dlc/UI/InGame/Popups/CivVAccess_ChooseProductionLogic.lua")
end

local function mkCityStub(opts)
    opts = opts or {}
    local c = {
        _canTrain = opts.canTrain or {},
        _canTrainVisible = opts.canTrainVisible or opts.canTrain or {},
        _canConstruct = opts.canConstruct or {},
        _canConstructVisible = opts.canConstructVisible or opts.canConstruct or {},
        _canCreate = opts.canCreate or {},
        _canCreateVisible = opts.canCreateVisible or opts.canCreate or {},
        _canMaintain = opts.canMaintain or {},
        _canPurchaseGold = opts.canPurchaseGold or {},
        _canPurchaseFaith = opts.canPurchaseFaith or {},
        _canPurchaseGoldStrict = opts.canPurchaseGoldStrict or opts.canPurchaseGold or {},
        _canPurchaseFaithStrict = opts.canPurchaseFaithStrict or opts.canPurchaseFaith or {},
        _unitCost = opts.unitCost or {},
        _unitFaithCost = opts.unitFaithCost or {},
        _buildingCost = opts.buildingCost or {},
        _buildingFaithCost = opts.buildingFaithCost or {},
        _unitTurnsLeft = opts.unitTurnsLeft or {},
        _buildingTurnsLeft = opts.buildingTurnsLeft or {},
        _projectTurnsLeft = opts.projectTurnsLeft or {},
        _canTrainTooltip = opts.canTrainTooltip or {},
        _canConstructTooltip = opts.canConstructTooltip or {},
        _queue = opts.queue or {},
    }
    -- Build lookup keys for IsCanPurchase: tuple (unitID, buildingID, projectID, yield).
    -- Tests pass per-entry maps keyed by the non-(-1) id.
    function c:CanTrain(id, arg1, arg2)
        if arg2 == 1 then
            return self._canTrainVisible[id] == true
        end
        return self._canTrain[id] == true
    end
    function c:CanConstruct(id, arg1, arg2)
        if arg2 == 1 then
            return self._canConstructVisible[id] == true
        end
        return self._canConstruct[id] == true
    end
    function c:CanCreate(id, arg1, arg2)
        if arg2 == 1 then
            return self._canCreateVisible[id] == true
        end
        return self._canCreate[id] == true
    end
    function c:CanMaintain(id)
        return self._canMaintain[id] == true
    end
    function c:IsCanPurchase(strictEnable, strictEval, unitID, buildingID, projectID, yieldType)
        local id = (unitID ~= -1 and unitID) or (buildingID ~= -1 and buildingID) or projectID
        local gold = yieldType == YieldTypes.YIELD_GOLD
        local table_ = gold and (strictEnable and self._canPurchaseGoldStrict or self._canPurchaseGold)
            or (strictEnable and self._canPurchaseFaithStrict or self._canPurchaseFaith)
        return table_[id] == true
    end
    function c:GetUnitPurchaseCost(id)
        return self._unitCost[id] or 0
    end
    function c:GetUnitFaithPurchaseCost(id, flag)
        return self._unitFaithCost[id] or 0
    end
    function c:GetBuildingPurchaseCost(id)
        return self._buildingCost[id] or 0
    end
    function c:GetBuildingFaithPurchaseCost(id)
        return self._buildingFaithCost[id] or 0
    end
    function c:GetProjectPurchaseCost(id)
        return 0
    end
    function c:GetUnitProductionTurnsLeft(id)
        return self._unitTurnsLeft[id] or 1
    end
    function c:GetBuildingProductionTurnsLeft(id)
        return self._buildingTurnsLeft[id] or 1
    end
    function c:GetProjectProductionTurnsLeft(id)
        return self._projectTurnsLeft[id] or 1
    end
    function c:CanTrainTooltip(id)
        return self._canTrainTooltip[id] or ""
    end
    function c:CanConstructTooltip(id)
        return self._canConstructTooltip[id] or ""
    end
    function c:GetPurchaseUnitTooltip(id)
        return ""
    end
    function c:GetFaithPurchaseUnitTooltip(id)
        return ""
    end
    function c:GetPurchaseBuildingTooltip(id)
        return ""
    end
    function c:GetFaithPurchaseBuildingTooltip(id)
        return ""
    end
    function c:GetOrderQueueLength()
        return #self._queue
    end
    function c:GetOrderFromQueue(i)
        return self._queue[i + 1][1], self._queue[i + 1][2]
    end
    return c
end

-- Engine's GameInfo.X is a callable userdata that ALSO indexes by id (the
-- same table supports `for row in GameInfo.X()` and `GameInfo.X[id]`).
-- Emulate via __call + __index on a plain table.
local function mkInfoTable(rows)
    local rowsByID = {}
    for _, r in ipairs(rows) do
        if r.ID ~= nil then
            rowsByID[r.ID] = r
        end
    end
    local t = {}
    setmetatable(t, {
        __call = function(_self)
            local i = 0
            return function()
                i = i + 1
                return rows[i]
            end
        end,
        __index = function(_, id)
            return rowsByID[id]
        end,
    })
    return t
end

local function installGameInfoUnits(rows)
    GameInfo.Units = mkInfoTable(rows)
end
local function installGameInfoBuildings(rows)
    GameInfo.Buildings = mkInfoTable(rows)
end
local function installGameInfoProjects(rows)
    GameInfo.Projects = mkInfoTable(rows)
end
local function installGameInfoProcesses(rows)
    GameInfo.Processes = mkInfoTable(rows)
end
local function installEras(eras)
    GameInfo.Eras = mkInfoTable(eras)
end
local function installTechnologies(techs)
    GameInfo.Technologies = mkInfoTable(techs)
end

local function installBuildingClasses(map)
    GameInfo.BuildingClasses = setmetatable({}, {
        __index = function(_, k)
            return map[k]
        end,
    })
end

local function installStandardEras()
    installEras({
        { Type = "ERA_ANCIENT", ID = 0 },
        { Type = "ERA_CLASSICAL", ID = 1 },
    })
    installTechnologies({
        { Type = "TECH_BRONZE_WORKING", Era = "ERA_ANCIENT" },
        { Type = "TECH_IRON_WORKING", Era = "ERA_CLASSICAL" },
    })
end

-- ===== Tests =====

function M.test_is_wonder_building_flags_world_wonder()
    setup()
    installBuildingClasses({
        WONDER = { MaxGlobalInstances = 1, MaxPlayerInstances = 0, MaxTeamInstances = 0 },
        NATIONAL = { MaxGlobalInstances = 0, MaxPlayerInstances = 1, MaxTeamInstances = 0 },
        TEAM = { MaxGlobalInstances = 0, MaxPlayerInstances = 0, MaxTeamInstances = 1 },
        REGULAR = { MaxGlobalInstances = 0, MaxPlayerInstances = 0, MaxTeamInstances = 0 },
    })
    T.truthy(ChooseProductionLogic.isWonderBuilding({ BuildingClass = "WONDER" }))
    T.truthy(ChooseProductionLogic.isWonderBuilding({ BuildingClass = "NATIONAL" }))
    T.truthy(ChooseProductionLogic.isWonderBuilding({ BuildingClass = "TEAM" }))
    T.falsy(ChooseProductionLogic.isWonderBuilding({ BuildingClass = "REGULAR" }))
    T.falsy(ChooseProductionLogic.isWonderBuilding({ BuildingClass = "MISSING" }))
end

function M.test_unit_sort_key_category_offsets()
    setup()
    local eras = { TECH_A = 10, TECH_B = 20 }
    -- Civilian land at ERA_ANCIENT base 10 -> 10
    local civLandEarly = { PrereqTech = "TECH_A", Domain = "DOMAIN_LAND", CivilianAttackPriority = 1 }
    T.eq(ChooseProductionLogic.unitSortKey(civLandEarly, eras), 10)
    -- Civilian sea -> +1000
    local civSea = { PrereqTech = "TECH_A", Domain = "DOMAIN_SEA", CivilianAttackPriority = 1 }
    T.eq(ChooseProductionLogic.unitSortKey(civSea, eras), 1010)
    -- Military land -> +2000
    local milLand = { PrereqTech = "TECH_B", Domain = "DOMAIN_LAND" }
    T.eq(ChooseProductionLogic.unitSortKey(milLand, eras), 2020)
    -- Military sea -> +3000
    local milSea = { PrereqTech = "TECH_B", Domain = "DOMAIN_SEA" }
    T.eq(ChooseProductionLogic.unitSortKey(milSea, eras), 3020)
    -- No PrereqTech -> era 0
    local noTech = { Domain = "DOMAIN_LAND" }
    T.eq(ChooseProductionLogic.unitSortKey(noTech, eras), 2000)
end

function M.test_building_sort_key_via_prereq_tech()
    setup()
    local eras = { TECH_A = 10, TECH_B = 20 }
    T.eq(ChooseProductionLogic.buildingSortKey({ PrereqTech = "TECH_B" }, eras), 20)
    T.eq(ChooseProductionLogic.buildingSortKey({}, eras), 0)
end

function M.test_sort_entries_puts_enabled_before_disabled()
    setup()
    -- Entries with same sortKey (0) and distinct names. Two disabled + two
    -- enabled mixed order on input; enabled must come first on output, each
    -- group internally sorted by localized name.
    local entries = {
        { info = { Description = "B" }, disabledForSort = false, yieldType = YieldTypes.NO_YIELD },
        { info = { Description = "A" }, disabledForSort = true, yieldType = YieldTypes.NO_YIELD },
        { info = { Description = "C" }, disabledForSort = false, yieldType = YieldTypes.NO_YIELD },
        { info = { Description = "D" }, disabledForSort = true, yieldType = YieldTypes.NO_YIELD },
    }
    ChooseProductionLogic.sortEntries(entries, function(_)
        return 0
    end)
    T.eq(entries[1].info.Description, "B", "first enabled by name")
    T.eq(entries[2].info.Description, "C", "second enabled by name")
    T.eq(entries[3].info.Description, "A", "first disabled by name")
    T.eq(entries[4].info.Description, "D", "second disabled by name")
end

function M.test_sort_entries_prefers_gold_over_faith_on_ties()
    setup()
    local entries = {
        { info = { Description = "X" }, disabledForSort = false, yieldType = YieldTypes.YIELD_FAITH },
        { info = { Description = "X" }, disabledForSort = false, yieldType = YieldTypes.YIELD_GOLD },
    }
    ChooseProductionLogic.sortEntries(entries, function(_)
        return 0
    end)
    T.eq(entries[1].yieldType, YieldTypes.YIELD_GOLD, "gold entry sorts before faith")
    T.eq(entries[2].yieldType, YieldTypes.YIELD_FAITH)
end

function M.test_build_unit_entries_produce_tab_collects_trainable()
    setup()
    installStandardEras()
    installGameInfoUnits({
        { ID = 1, Description = "Warrior", Domain = "DOMAIN_LAND", PrereqTech = "TECH_BRONZE_WORKING" },
        { ID = 2, Description = "Settler", Domain = "DOMAIN_LAND", CivilianAttackPriority = 1 },
        { ID = 3, Description = "Hidden", Domain = "DOMAIN_LAND" }, -- not trainable even visible
    })
    local city = mkCityStub({
        canTrainVisible = { [1] = true, [2] = true },
        canTrain = { [1] = true, [2] = true },
    })
    local entries = ChooseProductionLogic.buildUnitEntries(city, true)
    T.eq(#entries, 2)
    -- Settler (civilian land, era 0, sort 0) before Warrior (military land, era 10, sort 2010)
    T.eq(entries[1].id, 2)
    T.eq(entries[2].id, 1)
    T.eq(entries[1].isProduce, true)
    T.eq(entries[1].yieldType, YieldTypes.NO_YIELD)
end

function M.test_build_unit_entries_purchase_tab_splits_on_both_yields()
    setup()
    installStandardEras()
    installGameInfoUnits({
        { ID = 7, Description = "Prophet", Domain = "DOMAIN_LAND", CivilianAttackPriority = 1 },
    })
    local city = mkCityStub({
        canPurchaseGold = { [7] = true },
        canPurchaseFaith = { [7] = true },
        canPurchaseGoldStrict = { [7] = true },
        canPurchaseFaithStrict = { [7] = true },
        unitCost = { [7] = 300 },
        unitFaithCost = { [7] = 400 },
    })
    local entries = ChooseProductionLogic.buildUnitEntries(city, false)
    T.eq(#entries, 2, "one entry per yield type for a dual-purchasable unit")
    -- Gold sorts before faith on tied name / sort.
    T.eq(entries[1].yieldType, YieldTypes.YIELD_GOLD)
    T.eq(entries[2].yieldType, YieldTypes.YIELD_FAITH)
    T.eq(entries[1].isProduce, false)
end

function M.test_build_building_and_wonder_entries_split_by_class()
    setup()
    installStandardEras()
    installBuildingClasses({
        BUILDINGCLASS_LIBRARY = { MaxGlobalInstances = 0, MaxPlayerInstances = 0, MaxTeamInstances = 0 },
        BUILDINGCLASS_PYRAMIDS = { MaxGlobalInstances = 1, MaxPlayerInstances = 0, MaxTeamInstances = 0 },
    })
    installGameInfoBuildings({
        { ID = 10, Description = "Library", BuildingClass = "BUILDINGCLASS_LIBRARY" },
        { ID = 11, Description = "Pyramids", BuildingClass = "BUILDINGCLASS_PYRAMIDS" },
    })
    local city = mkCityStub({
        canConstructVisible = { [10] = true, [11] = true },
        canConstruct = { [10] = true, [11] = true },
    })
    local buildings, wonders = ChooseProductionLogic.buildBuildingAndWonderEntries(city, true)
    T.eq(#buildings, 1)
    T.eq(buildings[1].id, 10)
    T.eq(#wonders, 1)
    T.eq(wonders[1].id, 11)
end

function M.test_build_other_entries_includes_processes_on_produce_only()
    setup()
    installStandardEras()
    installGameInfoProjects({
        { ID = 20, Description = "Manhattan" },
    })
    installGameInfoProcesses({
        { ID = 30, Description = "Wealth" },
        { ID = 31, Description = "Research" },
    })
    local city = mkCityStub({
        canCreateVisible = { [20] = true },
        canCreate = { [20] = true },
        canMaintain = { [30] = true, [31] = true },
    })
    local produce = ChooseProductionLogic.buildOtherEntries(city, true)
    T.eq(#produce, 3, "project + 2 processes on produce")
    -- Processes are produce-only.
    local purchase = ChooseProductionLogic.buildOtherEntries(city, false)
    T.eq(#purchase, 0, "project not purchasable here; processes are purchase-ineligible")
end

function M.test_disabled_entry_label_includes_reason()
    setup()
    installGameInfoUnits({
        { ID = 1, Description = "Warrior", Domain = "DOMAIN_LAND", Strategy = "Strat", Help = "Helpful" },
    })
    local city = mkCityStub({
        canTrain = { [1] = false }, -- disabled
        unitTurnsLeft = { [1] = 5 },
        canTrainTooltip = { [1] = "Need more production." },
    })
    local entry = {
        orderType = OrderTypes.ORDER_TRAIN,
        id = 1,
        info = GameInfo.Units[1],
        yieldType = YieldTypes.NO_YIELD,
        isProduce = true,
    }
    local label = ChooseProductionLogic.buildLabel(entry, city)
    -- Order: name, cost, disabled, reason, strategy, help (no advisor)
    T.truthy(label:find("Warrior"), "label contains name")
    T.truthy(label:find("5 turns"), "label contains cost clause")
    T.truthy(label:find("disabled"), "label contains disabled word")
    T.truthy(label:find("Need more production", 1, true), "label contains disabled reason")
    T.truthy(label:find("Strat"), "label contains strategy")
    T.truthy(label:find("Helpful"), "label contains help")
    -- Disabled clause should appear before strategy so the blocker arrives early.
    local dPos = label:find("disabled")
    local sPos = label:find("Strat")
    T.truthy(dPos < sPos, "disabled before strategy")
end

function M.test_label_drops_help_when_identical_to_strategy()
    -- Monument-style entries point Help and Strategy at the same TXT_KEY so
    -- both resolve to the same localized string. The label must not read it
    -- twice.
    setup()
    installGameInfoBuildings({
        {
            ID = 1,
            Description = "Monument",
            BuildingClass = "BUILDINGCLASS_MONUMENT",
            Strategy = "TXT_KEY_BUILDING_MONUMENT_STRATEGY",
            Help = "TXT_KEY_BUILDING_MONUMENT_STRATEGY",
        },
    })
    local city = mkCityStub({
        canConstruct = { [1] = true },
        buildingTurnsLeft = { [1] = 3 },
    })
    local entry = {
        orderType = OrderTypes.ORDER_CONSTRUCT,
        id = 1,
        info = GameInfo.Buildings[1],
        yieldType = YieldTypes.NO_YIELD,
        isProduce = true,
    }
    local label = ChooseProductionLogic.buildLabel(entry, city)
    local _, count = label:gsub("TXT_KEY_BUILDING_MONUMENT_STRATEGY", "")
    T.eq(count, 1, "strategy/help text appears exactly once")
end

function M.test_advisor_suffix_with_zero_one_and_all_advisors()
    setup()
    -- Distinct sentences per advisor key so the concatenation is observable.
    local orig = Locale.ConvertTextKey
    Locale.ConvertTextKey = function(k, ...)
        if k == "TXT_KEY_CITY_CONSTRUCTION_ADVISOR_RECOMMENDATION_ECONOMIC" then
            return "econ."
        end
        if k == "TXT_KEY_CITY_CONSTRUCTION_ADVISOR_RECOMMENDATION_MILITARY" then
            return "mil."
        end
        if k == "TXT_KEY_CITY_CONSTRUCTION_ADVISOR_RECOMMENDATION_SCIENCE" then
            return "sci."
        end
        if k == "TXT_KEY_CITY_CONSTRUCTION_ADVISOR_RECOMMENDATION_FOREIGN" then
            return "foreign."
        end
        return orig(k, ...)
    end
    local entry = { orderType = OrderTypes.ORDER_TRAIN, id = 42 }

    Game.IsUnitRecommended = function(_id, _t)
        return false
    end
    T.eq(ChooseProductionLogic.advisorSuffix(entry), "", "empty when nobody recommends")

    Game.IsUnitRecommended = function(_id, t)
        return t == AdvisorTypes.ADVISOR_MILITARY
    end
    T.eq(ChooseProductionLogic.advisorSuffix(entry), "mil.")

    Game.IsUnitRecommended = function(_id, _t)
        return true
    end
    T.eq(
        ChooseProductionLogic.advisorSuffix(entry),
        "econ. mil. sci. foreign.",
        "order follows ADVISORS array (Economic, Military, Science, Foreign)"
    )

    Locale.ConvertTextKey = orig
end

function M.test_append_slot_and_queue_full_text_templates()
    setup()
    for n = 1, 5 do
        T.eq(Text.format("TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_ADDED_SLOT", n), "added, slot " .. n .. " in queue")
    end
    T.eq(Text.key("TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_QUEUE_FULL"), "queue full")
end

return M
