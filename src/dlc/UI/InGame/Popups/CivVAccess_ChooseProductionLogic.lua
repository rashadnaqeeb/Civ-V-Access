-- Pure helpers for ChooseProductionPopupAccess. Own module so offline tests
-- can exercise entry construction, sorting, disabled / cost / advisor
-- compositing, and label composition without dofiling the install-side
-- access file (which touches ContextPtr / InputHandler / Events at load).

ChooseProductionLogic = {}

-- Advisor icon order as shown on the sighted item row. Mirrors base's
-- AddProductionButton icon assignment; the per-advisor full-sentence TXT_KEYs
-- are the only localized strings the engine ships (no short-form keys exist),
-- so multi-advisor items read all applicable sentences end-to-end.
ChooseProductionLogic.ADVISORS = {
    { name = "ECONOMIC", key = "TXT_KEY_CITY_CONSTRUCTION_ADVISOR_RECOMMENDATION_ECONOMIC" },
    { name = "MILITARY", key = "TXT_KEY_CITY_CONSTRUCTION_ADVISOR_RECOMMENDATION_MILITARY" },
    { name = "SCIENCE", key = "TXT_KEY_CITY_CONSTRUCTION_ADVISOR_RECOMMENDATION_SCIENCE" },
    { name = "FOREIGN", key = "TXT_KEY_CITY_CONSTRUCTION_ADVISOR_RECOMMENDATION_FOREIGN" },
}

-- Wonder classification matches base's production-mode check at
-- ProductionPopup.lua:536: MaxGlobalInstances > 0 (true world wonders),
-- MaxPlayerInstances == 1 (national wonders), or MaxTeamInstances > 0
-- (team wonders, e.g. Hanging Gardens in some mods).
function ChooseProductionLogic.isWonderBuilding(building)
    local bclass = GameInfo.BuildingClasses[building.BuildingClass]
    if bclass == nil then
        return false
    end
    return bclass.MaxGlobalInstances > 0
        or bclass.MaxPlayerInstances == 1
        or bclass.MaxTeamInstances > 0
end

-- Era-by-tech mapping used by unit/building sort. +10 per era matches base's
-- GetUnitSortPriority / GetBuildingSortPriority so our sort order tracks the
-- sighted popup's "era by tech, then category offset" layout.
function ChooseProductionLogic.buildSortContext()
    local eraIDs = {}
    for row in GameInfo.Eras() do
        eraIDs[row.Type] = row.ID
    end
    local erasByTech = {}
    for row in GameInfo.Technologies() do
        erasByTech[row.Type] = (eraIDs[row.Era] or 0) + 10
    end
    return erasByTech
end

function ChooseProductionLogic.unitSortKey(unit, erasByTech)
    local era = 0
    if unit.PrereqTech then
        era = erasByTech[unit.PrereqTech] or 0
    end
    if unit.CivilianAttackPriority then
        if unit.Domain == "DOMAIN_LAND" then
            return era
        end
        return era + 1000
    end
    if unit.Domain == "DOMAIN_LAND" then
        return era + 2000
    end
    return era + 3000
end

function ChooseProductionLogic.buildingSortKey(building, erasByTech)
    if building.PrereqTech then
        return erasByTech[building.PrereqTech] or 0
    end
    return 0
end

-- Strict disabled check (right-now-ish). Separate from the visibility check
-- list-build uses: an item is visible if city:CanTrain(id, 0, 1) / IsCanPurchase(false, false, ...)
-- passes, but disabled if the strict variant fails. Announced labels say "disabled"
-- and activation no-ops when this returns true.
function ChooseProductionLogic.isEntryDisabled(city, entry)
    if entry.isProduce then
        if entry.orderType == OrderTypes.ORDER_TRAIN then
            return not city:CanTrain(entry.id, 0)
        elseif entry.orderType == OrderTypes.ORDER_CONSTRUCT then
            return not city:CanConstruct(entry.id)
        elseif entry.orderType == OrderTypes.ORDER_CREATE then
            return not city:CanCreate(entry.id)
        elseif entry.orderType == OrderTypes.ORDER_MAINTAIN then
            return not city:CanMaintain(entry.id)
        end
        return false
    end
    if entry.orderType == OrderTypes.ORDER_TRAIN then
        return not city:IsCanPurchase(true, true, entry.id, -1, -1, entry.yieldType)
    elseif entry.orderType == OrderTypes.ORDER_CONSTRUCT then
        return not city:IsCanPurchase(true, true, -1, entry.id, -1, entry.yieldType)
    elseif entry.orderType == OrderTypes.ORDER_CREATE then
        return not city:IsCanPurchase(true, true, -1, -1, entry.id, entry.yieldType)
    end
    return false
end

function ChooseProductionLogic.disabledReason(city, entry)
    if entry.isProduce then
        if entry.orderType == OrderTypes.ORDER_TRAIN then
            return city:CanTrainTooltip(entry.id)
        elseif entry.orderType == OrderTypes.ORDER_CONSTRUCT then
            return city:CanConstructTooltip(entry.id)
        end
        return nil
    end
    if entry.orderType == OrderTypes.ORDER_TRAIN then
        if entry.yieldType == YieldTypes.YIELD_GOLD then
            return city:GetPurchaseUnitTooltip(entry.id)
        end
        return city:GetFaithPurchaseUnitTooltip(entry.id)
    end
    if entry.orderType == OrderTypes.ORDER_CONSTRUCT then
        if entry.yieldType == YieldTypes.YIELD_GOLD then
            return city:GetPurchaseBuildingTooltip(entry.id)
        end
        return city:GetFaithPurchaseBuildingTooltip(entry.id)
    end
    return nil
end

local function produceCost(city, entry)
    local turns
    if entry.orderType == OrderTypes.ORDER_TRAIN then
        turns = city:GetUnitProductionTurnsLeft(entry.id)
    elseif entry.orderType == OrderTypes.ORDER_CONSTRUCT then
        turns = city:GetBuildingProductionTurnsLeft(entry.id)
    elseif entry.orderType == OrderTypes.ORDER_CREATE then
        turns = city:GetProjectProductionTurnsLeft(entry.id)
    end
    if turns == nil then
        return nil
    end
    return Text.format("TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_TURNS", turns)
end

local function purchaseCost(city, entry)
    local cost
    if entry.orderType == OrderTypes.ORDER_TRAIN then
        if entry.yieldType == YieldTypes.YIELD_FAITH then
            cost = city:GetUnitFaithPurchaseCost(entry.id, true)
        else
            cost = city:GetUnitPurchaseCost(entry.id)
        end
    elseif entry.orderType == OrderTypes.ORDER_CONSTRUCT then
        if entry.yieldType == YieldTypes.YIELD_FAITH then
            cost = city:GetBuildingFaithPurchaseCost(entry.id)
        else
            cost = city:GetBuildingPurchaseCost(entry.id)
        end
    elseif entry.orderType == OrderTypes.ORDER_CREATE then
        if entry.yieldType == YieldTypes.YIELD_FAITH then
            return nil
        end
        cost = city:GetProjectPurchaseCost(entry.id)
    end
    if cost == nil then
        return nil
    end
    if entry.yieldType == YieldTypes.YIELD_FAITH then
        return Text.format("TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_FAITH", cost)
    end
    return Text.format("TXT_KEY_CIVVACCESS_CHOOSEPRODUCTION_GOLD", cost)
end

function ChooseProductionLogic.costClause(city, entry)
    if entry.orderType == OrderTypes.ORDER_MAINTAIN then
        return nil
    end
    if entry.isProduce then
        return produceCost(city, entry)
    end
    return purchaseCost(city, entry)
end

-- Requires Game.SetAdvisorRecommenderCity(city) to have been called before
-- Game.IsXxxRecommended can answer correctly. Caller sets once per itemsFn.
-- Returns "" when no advisor recommends so callers can skip the separator.
function ChooseProductionLogic.advisorSuffix(entry)
    local parts = {}
    for _, adv in ipairs(ChooseProductionLogic.ADVISORS) do
        local rec = false
        local t = AdvisorTypes["ADVISOR_" .. adv.name]
        if t ~= nil then
            if entry.orderType == OrderTypes.ORDER_TRAIN then
                rec = Game.IsUnitRecommended(entry.id, t)
            elseif entry.orderType == OrderTypes.ORDER_CONSTRUCT then
                rec = Game.IsBuildingRecommended(entry.id, t)
            elseif entry.orderType == OrderTypes.ORDER_CREATE then
                rec = Game.IsProjectRecommended(entry.id, t)
            end
        end
        if rec then
            parts[#parts + 1] = Text.key(adv.key)
        end
    end
    return table.concat(parts, " ")
end

-- Sort contract: enabled items before disabled items, then by sortKey ascending,
-- then by localized-name ascending, then gold before faith (so a dual-yield
-- unit reads gold-cost entry first in the Purchase tab).
function ChooseProductionLogic.sortEntries(entries, sortKeyFn)
    for _, e in ipairs(entries) do
        e.sortKey = sortKeyFn(e)
        e.displayName = Locale.ConvertTextKey(e.info.Description)
    end
    table.sort(entries, function(a, b)
        if a.disabledForSort ~= b.disabledForSort then
            return not a.disabledForSort
        end
        if a.sortKey ~= b.sortKey then
            return a.sortKey < b.sortKey
        end
        local comp = Locale.Compare(a.displayName, b.displayName)
        if comp ~= 0 then
            return comp == -1
        end
        local aFaith = (a.yieldType == YieldTypes.YIELD_FAITH) and 1 or 0
        local bFaith = (b.yieldType == YieldTypes.YIELD_FAITH) and 1 or 0
        return aFaith < bFaith
    end)
end

local function mkUnitEntry(id, unit, yieldType, isProduce)
    return { orderType = OrderTypes.ORDER_TRAIN, id = id, info = unit, yieldType = yieldType, isProduce = isProduce }
end
local function mkBuildingEntry(id, building, yieldType, isProduce)
    return { orderType = OrderTypes.ORDER_CONSTRUCT, id = id, info = building, yieldType = yieldType, isProduce = isProduce }
end
local function mkProjectEntry(id, project, yieldType, isProduce)
    return { orderType = OrderTypes.ORDER_CREATE, id = id, info = project, yieldType = yieldType, isProduce = isProduce }
end
local function mkProcessEntry(id, process)
    return { orderType = OrderTypes.ORDER_MAINTAIN, id = id, info = process, yieldType = YieldTypes.NO_YIELD, isProduce = true }
end

ChooseProductionLogic._mkUnitEntry = mkUnitEntry
ChooseProductionLogic._mkBuildingEntry = mkBuildingEntry
ChooseProductionLogic._mkProjectEntry = mkProjectEntry
ChooseProductionLogic._mkProcessEntry = mkProcessEntry

function ChooseProductionLogic.buildUnitEntries(city, isProduce)
    local entries = {}
    for unit in GameInfo.Units() do
        local id = unit.ID
        if isProduce then
            if city:CanTrain(id, 0, 1) then
                entries[#entries + 1] = mkUnitEntry(id, unit, YieldTypes.NO_YIELD, true)
            end
        else
            if city:IsCanPurchase(false, false, id, -1, -1, YieldTypes.YIELD_GOLD) then
                entries[#entries + 1] = mkUnitEntry(id, unit, YieldTypes.YIELD_GOLD, false)
            end
            if city:IsCanPurchase(false, false, id, -1, -1, YieldTypes.YIELD_FAITH) then
                entries[#entries + 1] = mkUnitEntry(id, unit, YieldTypes.YIELD_FAITH, false)
            end
        end
    end
    for _, e in ipairs(entries) do
        e.disabledForSort = ChooseProductionLogic.isEntryDisabled(city, e)
    end
    local erasByTech = ChooseProductionLogic.buildSortContext()
    ChooseProductionLogic.sortEntries(entries, function(e)
        return ChooseProductionLogic.unitSortKey(e.info, erasByTech)
    end)
    return entries
end

function ChooseProductionLogic.buildBuildingAndWonderEntries(city, isProduce)
    local buildings, wonders = {}, {}
    for building in GameInfo.Buildings() do
        local id = building.ID
        local bucket = ChooseProductionLogic.isWonderBuilding(building) and wonders or buildings
        if isProduce then
            if city:CanConstruct(id, 0, 1) then
                bucket[#bucket + 1] = mkBuildingEntry(id, building, YieldTypes.NO_YIELD, true)
            end
        else
            if city:IsCanPurchase(false, false, -1, id, -1, YieldTypes.YIELD_GOLD) then
                bucket[#bucket + 1] = mkBuildingEntry(id, building, YieldTypes.YIELD_GOLD, false)
            end
            if city:IsCanPurchase(false, false, -1, id, -1, YieldTypes.YIELD_FAITH) then
                bucket[#bucket + 1] = mkBuildingEntry(id, building, YieldTypes.YIELD_FAITH, false)
            end
        end
    end
    for _, e in ipairs(buildings) do
        e.disabledForSort = ChooseProductionLogic.isEntryDisabled(city, e)
    end
    for _, e in ipairs(wonders) do
        e.disabledForSort = ChooseProductionLogic.isEntryDisabled(city, e)
    end
    local erasByTech = ChooseProductionLogic.buildSortContext()
    local keyFn = function(e)
        return ChooseProductionLogic.buildingSortKey(e.info, erasByTech)
    end
    ChooseProductionLogic.sortEntries(buildings, keyFn)
    ChooseProductionLogic.sortEntries(wonders, keyFn)
    return buildings, wonders
end

function ChooseProductionLogic.buildOtherEntries(city, isProduce)
    local entries = {}
    for project in GameInfo.Projects() do
        local id = project.ID
        if isProduce then
            if city:CanCreate(id, 0, 1) then
                entries[#entries + 1] = mkProjectEntry(id, project, YieldTypes.NO_YIELD, true)
            end
        else
            if city:IsCanPurchase(false, false, -1, -1, id, YieldTypes.YIELD_GOLD) then
                entries[#entries + 1] = mkProjectEntry(id, project, YieldTypes.YIELD_GOLD, false)
            end
        end
    end
    if isProduce then
        for process in GameInfo.Processes() do
            local id = process.ID
            if city:CanMaintain(id) then
                entries[#entries + 1] = mkProcessEntry(id, process)
            end
        end
    end
    for _, e in ipairs(entries) do
        e.disabledForSort = ChooseProductionLogic.isEntryDisabled(city, e)
    end
    ChooseProductionLogic.sortEntries(entries, function(_) return 0 end)
    return entries
end

-- Focus announcement order: name, cost, disabled clause (with reason if any),
-- strategy, help, advisor suffix. Disabled clause precedes strategy so the
-- "can I even click this?" information arrives before the flavor blurbs.
function ChooseProductionLogic.buildLabel(entry, city)
    local parts = { Text.key(entry.info.Description) }
    local cost = ChooseProductionLogic.costClause(city, entry)
    if cost ~= nil then
        parts[#parts + 1] = cost
    end
    if ChooseProductionLogic.isEntryDisabled(city, entry) then
        parts[#parts + 1] = Text.key("TXT_KEY_CIVVACCESS_BUTTON_DISABLED")
        local reason = ChooseProductionLogic.disabledReason(city, entry)
        if reason ~= nil and reason ~= "" then
            parts[#parts + 1] = reason
        end
    end
    if entry.info.Strategy and entry.info.Strategy ~= "" then
        parts[#parts + 1] = Text.key(entry.info.Strategy)
    end
    if entry.info.Help and entry.info.Help ~= "" then
        parts[#parts + 1] = Text.key(entry.info.Help)
    end
    local suffix = ChooseProductionLogic.advisorSuffix(entry)
    if suffix ~= "" then
        parts[#parts + 1] = suffix
    end
    return table.concat(parts, ", ")
end

return ChooseProductionLogic
