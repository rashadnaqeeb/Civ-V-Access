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
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_CITYVIEW_PROD_REMAINING"] = "Production remaining: {1_Num}"

    -- Players table for ProductionHelpText.remainingLine. Each setup()
    -- resets the per-test maps so values don't leak; tests populate
    -- M._unitNeeded / _buildingNeeded / _projectNeeded.
    M._unitNeeded = {}
    M._buildingNeeded = {}
    M._projectNeeded = {}
    Players = setmetatable({}, {
        __index = function(_, owner)
            return {
                GetUnitProductionNeeded = function(_, id)
                    return M._unitNeeded[id] or 0
                end,
                GetBuildingProductionNeeded = function(_, id)
                    return M._buildingNeeded[id] or 0
                end,
                GetProjectProductionNeeded = function(_, id)
                    return M._projectNeeded[id] or 0
                end,
            }
        end,
    })

    -- Advisor full-sentence keys: unique per advisor so concatenation is
    -- observable in tests.
    CivVAccess_Strings = CivVAccess_Strings or {}
    -- These aren't TXT_KEY_CIVVACCESS_*, so Text.key routes through Locale
    -- (overridden below to return a distinct string per advisor key).

    -- InfoTooltipInclude lookalikes. Mirror the engine's exact output
    -- shape -- always prepend "<NAME>[NEWLINE]----------------[NEWLINE]"
    -- (Unit / Project), always emit a "[NEWLINE]----------------[NEWLINE]"
    -- separator before the prose Help section -- so ProductionHelpText's
    -- stripNamePrefix and the chooser's prose-tail strip both exercise the
    -- same patterns they do in the live engine. Locale.ConvertTextKey is
    -- applied to Description / Help as the engine does, so per-test mocks
    -- that override Locale see the same call path.
    GetHelpTextForUnit = function(id, _bIncludeRequirements)
        local info = GameInfo.Units and GameInfo.Units[id]
        if info == nil then
            return ""
        end
        local out = Locale.ConvertTextKey(info.Description) .. "[NEWLINE]----------------[NEWLINE]"
        local statsLines = {}
        if (info.Cost or 0) > 0 then
            statsLines[#statsLines + 1] = "Cost: " .. info.Cost
        end
        if info.Strength then
            statsLines[#statsLines + 1] = "Strength: " .. info.Strength
        end
        -- Engine pattern: cost has no leading [NEWLINE], subsequent stats do.
        if (info.Cost or 0) > 0 then
            out = out .. statsLines[1]
            for i = 2, #statsLines do
                out = out .. "[NEWLINE]" .. statsLines[i]
            end
        elseif #statsLines > 0 then
            out = out .. "[NEWLINE]" .. table.concat(statsLines, "[NEWLINE]")
        end
        if info.Help then
            local helpText = Locale.ConvertTextKey(info.Help)
            if helpText and helpText ~= "" then
                out = out .. "[NEWLINE]----------------[NEWLINE]" .. helpText
            end
        end
        return out
    end
    GetHelpTextForBuilding = function(id, bExcludeName, bExcludeHeader, _bNoMaint, _city)
        local info = GameInfo.Buildings and GameInfo.Buildings[id]
        if info == nil then
            return ""
        end
        local out = ""
        if not bExcludeName then
            out = Locale.ConvertTextKey(info.Description) .. "[NEWLINE]----------------[NEWLINE]"
        end
        if not bExcludeHeader then
            local headerLines = {}
            if (info.Cost or 0) > 0 then
                headerLines[#headerLines + 1] = "Cost: " .. info.Cost
            end
            if (info.GoldMaintenance or 0) ~= 0 then
                headerLines[#headerLines + 1] = "Maintenance: " .. info.GoldMaintenance
            end
            out = out .. table.concat(headerLines, "[NEWLINE]")
        end
        if info.Help then
            local helpText = Locale.ConvertTextKey(info.Help)
            if helpText and helpText ~= "" then
                -- Engine always prepends separator before Help, even when
                -- the stats block is empty.
                out = out .. "[NEWLINE]----------------[NEWLINE]" .. helpText
            end
        end
        return out
    end
    GetHelpTextForProject = function(id, _bIncludeRequirements)
        local info = GameInfo.Projects and GameInfo.Projects[id]
        if info == nil then
            return ""
        end
        local out = Locale.ConvertTextKey(info.Description) .. "[NEWLINE]----------------[NEWLINE]"
        out = out .. "Cost: " .. (info.Cost or 0)
        if info.Help then
            local helpText = Locale.ConvertTextKey(info.Help)
            if helpText and helpText ~= "" then
                out = out .. "[NEWLINE]----------------[NEWLINE]" .. helpText
            end
        end
        return out
    end
    if Locale.ConvertTextKey == nil then
        Locale.ConvertTextKey = function(k)
            return k
        end
    end

    dofile("src/dlc/UI/Shared/CivVAccess_ProductionHelpText.lua")
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
        _owner = opts.owner or 0,
        _productionTimes100 = opts.productionTimes100 or 0,
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
    function c:GetOwner()
        return self._owner
    end
    function c:GetProductionTimes100()
        return self._productionTimes100
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
    -- Order: name, cost, disabled, reason, contributions, prose, advisor.
    T.truthy(label:find("Warrior"), "label contains name")
    T.truthy(label:find("5 turns"), "label contains cost clause")
    T.truthy(label:find("disabled"), "label contains disabled word")
    T.truthy(label:find("Need more production", 1, true), "label contains disabled reason")
    T.truthy(label:find("Strat"), "label contains strategy")
    -- Help is dropped when Strategy is present (Help typically rephrases
    -- Strategy as a one-liner; proseText prefers Strategy and never falls
    -- back to Help here).
    T.falsy(label:find("Helpful"), "Help dropped when Strategy is present")
    -- Disabled clause should appear before strategy so the blocker arrives early.
    local dPos = label:find("disabled")
    local sPos = label:find("Strat")
    T.truthy(dPos < sPos, "disabled before strategy")
end

function M.test_label_orders_stats_before_prose()
    -- The chooser orders the announcement: name, cost, [disabled], stats,
    -- prose, advisor. Strategy / Help should sit AFTER the helper-derived
    -- stats so the player hears concrete numbers (Strength, Cost) before
    -- the flavor paragraph that explains them.
    setup()
    installGameInfoUnits({
        { ID = 1, Description = "AntiTank", Domain = "DOMAIN_LAND", Cost = 300, Strength = 50, Strategy = "Pair with tanks." },
    })
    local city = mkCityStub({
        canTrain = { [1] = true },
        unitTurnsLeft = { [1] = 5 },
    })
    local entry = {
        orderType = OrderTypes.ORDER_TRAIN,
        id = 1,
        info = GameInfo.Units[1],
        yieldType = YieldTypes.NO_YIELD,
        isProduce = true,
    }
    local label = ChooseProductionLogic.buildLabel(entry, city)
    local statsPos = label:find("Strength: 50")
    local prosePos = label:find("Pair with tanks", 1, true)
    T.truthy(statsPos, "label contains Strength stat")
    T.truthy(prosePos, "label contains Strategy prose")
    T.truthy(statsPos < prosePos, "stats appear before prose")
end

function M.test_label_falls_back_to_help_when_no_strategy()
    -- Without a Strategy field the helper's prose Help is the only flavor
    -- text; proseText must surface it (else the chooser entry would have
    -- no descriptive paragraph at all).
    setup()
    installGameInfoUnits({
        { ID = 1, Description = "Worker", Domain = "DOMAIN_LAND", Cost = 70, Help = "Builds improvements." },
    })
    local city = mkCityStub({ canTrain = { [1] = true }, unitTurnsLeft = { [1] = 3 } })
    local entry = {
        orderType = OrderTypes.ORDER_TRAIN,
        id = 1,
        info = GameInfo.Units[1],
        yieldType = YieldTypes.NO_YIELD,
        isProduce = true,
    }
    local label = ChooseProductionLogic.buildLabel(entry, city)
    T.truthy(label:find("Builds improvements", 1, true), "Help is the prose when Strategy is absent")
end

function M.test_contributions_strips_prose_help_tail()
    -- contributionsText is just the stats; the prose-Help block (every-
    -- thing after the engine's "[NEWLINE]----------------[NEWLINE]"
    -- separator) belongs to proseText. Verify the strip fires so the
    -- prose isn't read twice.
    setup()
    installGameInfoUnits({
        { ID = 1, Description = "AntiTank", Domain = "DOMAIN_LAND", Cost = 300, Strength = 50, Help = "Specialized in fighting tanks." },
    })
    local city = mkCityStub({ canTrain = { [1] = true } })
    local entry = {
        orderType = OrderTypes.ORDER_TRAIN,
        id = 1,
        info = GameInfo.Units[1],
        yieldType = YieldTypes.NO_YIELD,
        isProduce = true,
    }
    local contributions = ChooseProductionLogic.contributionsText(entry, city)
    T.truthy(contributions:find("Strength: 50"), "contributions has stats")
    T.falsy(contributions:find("Specialized", 1, true), "contributions strips the prose-Help tail")
end

function M.test_contributions_slot_one_entry_shows_remaining_not_cost()
    -- The currently-building head item owns the city's production
    -- accumulator, so its full base cost is misleading. Switch to
    -- "Production remaining" computed against the city's stored
    -- production (GetProductionTimes100 / 100).
    setup()
    installGameInfoUnits({
        { ID = 1, Description = "Warrior", Domain = "DOMAIN_LAND", Cost = 40, Strength = 8 },
    })
    M._unitNeeded[1] = 40
    local city = mkCityStub({
        canTrain = { [1] = true },
        unitTurnsLeft = { [1] = 2 },
        queue = { { OrderTypes.ORDER_TRAIN, 1 } },
        owner = 0,
        productionTimes100 = 2500, -- 25 stored
    })
    local entry = {
        orderType = OrderTypes.ORDER_TRAIN,
        id = 1,
        info = GameInfo.Units[1],
        yieldType = YieldTypes.NO_YIELD,
        isProduce = true,
    }
    local contributions = ChooseProductionLogic.contributionsText(entry, city)
    T.truthy(contributions:find("Production remaining: 15", 1, true), "shows 40 - 25 = 15 remaining")
    T.falsy(contributions:find("Cost: 40", 1, true), "full cost line is replaced")
    T.truthy(contributions:find("Strength: 8"), "stats still present")
end

function M.test_contributions_non_slot_one_entry_keeps_full_cost()
    -- Items not currently in slot 1 don't have accumulated production
    -- against them; the contributions show the engine's full cost line.
    setup()
    installGameInfoUnits({
        { ID = 1, Description = "Warrior", Domain = "DOMAIN_LAND", Cost = 40, Strength = 8 },
        { ID = 2, Description = "Spearman", Domain = "DOMAIN_LAND", Cost = 56, Strength = 11 },
    })
    M._unitNeeded[1] = 40
    M._unitNeeded[2] = 56
    -- Warrior is slot 1 (half-built); Spearman is the entry under inspection.
    local city = mkCityStub({
        canTrain = { [1] = true, [2] = true },
        unitTurnsLeft = { [2] = 4 },
        queue = { { OrderTypes.ORDER_TRAIN, 1 } },
        productionTimes100 = 2000,
    })
    local entry = {
        orderType = OrderTypes.ORDER_TRAIN,
        id = 2,
        info = GameInfo.Units[2],
        yieldType = YieldTypes.NO_YIELD,
        isProduce = true,
    }
    local contributions = ChooseProductionLogic.contributionsText(entry, city)
    T.truthy(contributions:find("Cost: 56"), "non-head entry shows full cost")
    T.falsy(contributions:find("Production remaining", 1, true), "no remaining line on non-head entry")
end

function M.test_contributions_remaining_clamps_at_zero_when_overbuilt()
    -- Engine allows production to exceed the item's needed (overflow
    -- carries to next slot). For a half-built item that's overbuilt,
    -- "remaining" should clamp at zero rather than going negative.
    setup()
    installGameInfoUnits({
        { ID = 1, Description = "Warrior", Domain = "DOMAIN_LAND", Cost = 40, Strength = 8 },
    })
    M._unitNeeded[1] = 40
    local city = mkCityStub({
        canTrain = { [1] = true },
        unitTurnsLeft = { [1] = 1 },
        queue = { { OrderTypes.ORDER_TRAIN, 1 } },
        productionTimes100 = 6000, -- 60 stored, more than 40 needed
    })
    local entry = {
        orderType = OrderTypes.ORDER_TRAIN,
        id = 1,
        info = GameInfo.Units[1],
        yieldType = YieldTypes.NO_YIELD,
        isProduce = true,
    }
    local contributions = ChooseProductionLogic.contributionsText(entry, city)
    T.truthy(contributions:find("Production remaining: 0", 1, true), "clamps at 0")
end

function M.test_contributions_purchase_entry_keeps_full_cost_even_at_slot_one()
    -- Purchase entries don't own the production accumulator (the player
    -- pays gold / faith, not production). Even when an entry's id matches
    -- the queue head, a purchase variant of that entry shows full cost.
    setup()
    installGameInfoUnits({
        { ID = 1, Description = "Warrior", Domain = "DOMAIN_LAND", Cost = 40, Strength = 8 },
    })
    M._unitNeeded[1] = 40
    local city = mkCityStub({
        canTrain = { [1] = true },
        canPurchaseGold = { [1] = true },
        unitCost = { [1] = 200 },
        queue = { { OrderTypes.ORDER_TRAIN, 1 } },
        productionTimes100 = 2500,
    })
    local entry = {
        orderType = OrderTypes.ORDER_TRAIN,
        id = 1,
        info = GameInfo.Units[1],
        yieldType = YieldTypes.YIELD_GOLD,
        isProduce = false,
    }
    local contributions = ChooseProductionLogic.contributionsText(entry, city)
    T.truthy(contributions:find("Cost: 40"), "purchase entry keeps full cost")
    T.falsy(contributions:find("Production remaining", 1, true), "no remaining line on purchase entry")
end

function M.test_contributions_empty_for_process()
    -- Processes have no engine-exposed stats; contributionsText returns ""
    -- so proseText becomes the only source of prose for a process entry.
    setup()
    installGameInfoProcesses({
        { ID = 1, Description = "Wealth", Help = "Converts production into gold." },
    })
    local city = mkCityStub({ canMaintain = { [1] = true } })
    local entry = {
        orderType = OrderTypes.ORDER_MAINTAIN,
        id = 1,
        info = GameInfo.Processes[1],
        yieldType = YieldTypes.NO_YIELD,
        isProduce = true,
    }
    T.eq(ChooseProductionLogic.contributionsText(entry, city), "")
end

function M.test_label_drops_help_when_identical_to_strategy()
    -- Monument-style entries point Help and Strategy at the same TXT_KEY so
    -- both resolve to the same localized string. The label must not read it
    -- twice.
    setup()
    local origConvert = Locale.ConvertTextKey
    Locale.ConvertTextKey = function(k, ...)
        if k == "TXT_KEY_BUILDING_MONUMENT_STRATEGY" then
            return "Cultural anchor."
        end
        return origConvert(k, ...)
    end
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
    local _, count = label:gsub("Cultural anchor%.", "")
    T.eq(count, 1, "strategy/help text appears exactly once")
end

function M.test_label_drops_unresolved_strategy_key()
    -- A handful of base-game records (PROCESS_RESEARCH, PROCESS_WEALTH)
    -- reference TXT_KEY_*_STRATEGY strings that were never registered. The
    -- label must drop the unresolved key rather than letting Tolk spell out
    -- "TXT KEY PROCESS RESEARCH STRATEGY" letter by letter.
    setup()
    local origConvert = Locale.ConvertTextKey
    Locale.ConvertTextKey = function(k, ...)
        if k == "TXT_KEY_PROCESS_RESEARCH" then
            return "Research"
        end
        if k == "TXT_KEY_PROCESS_RESEARCH_HELP" then
            return "Research converts production into science."
        end
        return origConvert(k, ...)
    end
    installGameInfoProcesses({
        {
            ID = 1,
            Type = "PROCESS_RESEARCH",
            Description = "TXT_KEY_PROCESS_RESEARCH",
            Help = "TXT_KEY_PROCESS_RESEARCH_HELP",
            Strategy = "TXT_KEY_PROCESS_RESEARCH_STRATEGY",
        },
    })
    local city = mkCityStub({ canMaintain = { [1] = true } })
    local entry = {
        orderType = OrderTypes.ORDER_MAINTAIN,
        id = 1,
        info = GameInfo.Processes[1],
        yieldType = YieldTypes.NO_YIELD,
        isProduce = true,
    }
    local label = ChooseProductionLogic.buildLabel(entry, city)
    T.truthy(label:find("Research"), "label includes the Description")
    T.truthy(label:find("converts production"), "label includes the Help text")
    T.falsy(label:find("TXT_KEY_PROCESS_RESEARCH_STRATEGY", 1, true), "label drops the unresolved Strategy key")
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
