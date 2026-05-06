-- ProductionHelpText tests. Exercises the InfoTooltipInclude wrappers
-- that strip the engine helpers' name+separator prefix and optionally
-- drop the cost line so chooser / queue / built-buildings surfaces can
-- share one entry point.

local T = require("support")
local M = {}

local function setup()
    Log.warn = function() end
    Log.error = function() end
    Log.info = function() end
    Log.debug = function() end

    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")

    OrderTypes = OrderTypes
        or {
            ORDER_TRAIN = 0,
            ORDER_CONSTRUCT = 1,
            ORDER_CREATE = 2,
            ORDER_MAINTAIN = 3,
        }

    Locale = Locale or {}
    Locale.ConvertTextKey = Locale.ConvertTextKey or function(k)
        return k
    end

    GameInfo = {}
    CivVAccess_Strings = CivVAccess_Strings or {}
    CivVAccess_Strings["TXT_KEY_PRODUCTION_BUILDING_MAINTENANCE"] = nil

    -- Engine helpers don't exist by default; per-test installers below
    -- inject them when needed.
    GetHelpTextForUnit = nil
    GetHelpTextForBuilding = nil
    GetHelpTextForProject = nil

    dofile("src/dlc/UI/Shared/CivVAccess_ProductionHelpText.lua")
end

-- ---------------------------------------------------------------------
-- buildingHelp
-- ---------------------------------------------------------------------

function M.test_buildingHelp_returns_empty_when_helper_missing()
    setup()
    local building = { ID = 1, Description = "Library", GoldMaintenance = 1 }
    T.eq(ProductionHelpText.buildingHelp({}, building, true), "")
end

function M.test_buildingHelp_passthrough_with_cost()
    setup()
    GetHelpTextForBuilding = function(id, bExcludeName, bExcludeHeader, _bNoMaint, _city)
        T.eq(bExcludeName, true, "bExcludeName must be true; caller speaks the name")
        T.eq(bExcludeHeader, false, "includeCost=true keeps the engine header")
        return "Cost: 75[NEWLINE]Maintenance: 1[NEWLINE]Science: +25%"
    end
    local building = { ID = 1, Description = "Library", GoldMaintenance = 1 }
    T.eq(
        ProductionHelpText.buildingHelp({}, building, true),
        "Cost: 75[NEWLINE]Maintenance: 1[NEWLINE]Science: +25%"
    )
end

function M.test_buildingHelp_skips_cost_synthesizes_maintenance()
    setup()
    -- Built / queue surfaces want maintenance without the production
    -- cost line. bExcludeHeader=true skips both -- the wrapper
    -- re-prepends a maintenance line via Text.format.
    GetHelpTextForBuilding = function(id, bExcludeName, bExcludeHeader, _bNoMaint, _city)
        T.eq(bExcludeHeader, true, "includeCost=false skips engine header")
        return "Science: +25%"
    end
    CivVAccess_Strings["TXT_KEY_PRODUCTION_BUILDING_MAINTENANCE"] = nil
    Locale.ConvertTextKey = function(key, val)
        if key == "TXT_KEY_PRODUCTION_BUILDING_MAINTENANCE" then
            return "Maintenance: " .. val
        end
        return key
    end
    local building = { ID = 1, Description = "Library", GoldMaintenance = 1 }
    T.eq(ProductionHelpText.buildingHelp({}, building, false), "Maintenance: 1[NEWLINE]Science: +25%")
end

function M.test_buildingHelp_skips_cost_no_maintenance_skips_synthesized_line()
    setup()
    GetHelpTextForBuilding = function(_, _, _, _, _)
        return "Yields: +1 Faith"
    end
    -- Wonders typically have zero maintenance; no synthesized line.
    local building = { ID = 1, Description = "Pyramids", GoldMaintenance = 0 }
    T.eq(ProductionHelpText.buildingHelp({}, building, false), "Yields: +1 Faith")
end

-- ---------------------------------------------------------------------
-- unitHelp
-- ---------------------------------------------------------------------

function M.test_unitHelp_strips_leading_name_and_separator()
    setup()
    GetHelpTextForUnit = function(id, _)
        return "WARRIOR[NEWLINE]----------------[NEWLINE]Cost: 40[NEWLINE]Strength: 8[NEWLINE]----------------[NEWLINE]Strong unit."
    end
    local unit = { ID = 1, Description = "Warrior" }
    T.eq(
        ProductionHelpText.unitHelp({}, unit, true),
        "Cost: 40[NEWLINE]Strength: 8[NEWLINE]----------------[NEWLINE]Strong unit."
    )
end

function M.test_unitHelp_drops_cost_when_excluded()
    setup()
    GetHelpTextForUnit = function(id, _)
        return "WARRIOR[NEWLINE]----------------[NEWLINE]Cost: 40[NEWLINE]Strength: 8[NEWLINE]----------------[NEWLINE]Strong unit."
    end
    local unit = { ID = 1, Description = "Warrior" }
    -- includeCost=false: drops the first chunk after the prefix-strip.
    T.eq(
        ProductionHelpText.unitHelp({}, unit, false),
        "Strength: 8[NEWLINE]----------------[NEWLINE]Strong unit."
    )
end

function M.test_unitHelp_zero_cost_drop_is_a_noop_when_no_cost_line()
    setup()
    -- Zero-cost units (free units) have no cost line; the helper still
    -- emits a leading [NEWLINE] before the next section, which our drop
    -- consumes -- harmless because that [NEWLINE] was just a separator.
    GetHelpTextForUnit = function(id, _)
        return "FREEUNIT[NEWLINE]----------------[NEWLINE][NEWLINE]Strength: 8"
    end
    local unit = { ID = 1, Description = "FreeUnit" }
    T.eq(ProductionHelpText.unitHelp({}, unit, false), "Strength: 8")
end

-- ---------------------------------------------------------------------
-- projectHelp
-- ---------------------------------------------------------------------

function M.test_projectHelp_strips_name_keeps_cost()
    setup()
    GetHelpTextForProject = function(id, _)
        return "MANHATTAN[NEWLINE]----------------[NEWLINE]Cost: 1500[NEWLINE]----------------[NEWLINE]Enables nukes."
    end
    local project = { ID = 1, Description = "Manhattan" }
    T.eq(
        ProductionHelpText.projectHelp({}, project, true),
        "Cost: 1500[NEWLINE]----------------[NEWLINE]Enables nukes."
    )
end

function M.test_projectHelp_drops_cost_when_excluded()
    setup()
    GetHelpTextForProject = function(id, _)
        return "MANHATTAN[NEWLINE]----------------[NEWLINE]Cost: 1500[NEWLINE]----------------[NEWLINE]Enables nukes."
    end
    local project = { ID = 1, Description = "Manhattan" }
    T.eq(
        ProductionHelpText.projectHelp({}, project, false),
        "----------------[NEWLINE]Enables nukes."
    )
end

-- ---------------------------------------------------------------------
-- processHelp
-- ---------------------------------------------------------------------

function M.test_processHelp_returns_resolved_help()
    setup()
    Locale.ConvertTextKey = function(k)
        if k == "TXT_KEY_PROCESS_RESEARCH_HELP" then
            return "Converts production into science."
        end
        return k
    end
    local process = { ID = 1, Description = "Research", Help = "TXT_KEY_PROCESS_RESEARCH_HELP" }
    T.eq(ProductionHelpText.processHelp(process), "Converts production into science.")
end

function M.test_processHelp_returns_empty_when_help_missing()
    setup()
    T.eq(ProductionHelpText.processHelp({ ID = 1, Description = "X" }), "")
    T.eq(ProductionHelpText.processHelp({ ID = 1, Description = "X", Help = "" }), "")
end

function M.test_processHelp_returns_empty_when_help_unresolved()
    setup()
    -- Text.keyOrNil drops unresolved keys so Tolk doesn't spell out the
    -- raw TXT_KEY name. Check the wrapper preserves that behavior.
    Locale.ConvertTextKey = function(k)
        return k
    end
    local process = { ID = 1, Help = "TXT_KEY_PROCESS_GHOST_HELP" }
    T.eq(ProductionHelpText.processHelp(process), "")
end

-- ---------------------------------------------------------------------
-- forOrder dispatch
-- ---------------------------------------------------------------------

function M.test_forOrder_dispatches_by_orderType()
    setup()
    GameInfo.Units = { [1] = { ID = 1, Description = "U" } }
    GameInfo.Buildings = { [2] = { ID = 2, Description = "B", Help = "BHelp" } }
    GameInfo.Projects = { [3] = { ID = 3, Description = "P" } }
    GameInfo.Processes = { [4] = { ID = 4, Description = "Pr", Help = "TXT_KEY_X" } }

    local seenUnit, seenBuilding, seenProject = false, false, false
    GetHelpTextForUnit = function(id, _)
        seenUnit = (id == 1)
        return "U[NEWLINE]----------------[NEWLINE]"
    end
    GetHelpTextForBuilding = function(id, _, _, _, _)
        seenBuilding = (id == 2)
        return "BHelp"
    end
    GetHelpTextForProject = function(id, _)
        seenProject = (id == 3)
        return "P[NEWLINE]----------------[NEWLINE]"
    end
    Locale.ConvertTextKey = function(k)
        return (k == "TXT_KEY_X") and "process help" or k
    end

    ProductionHelpText.forOrder({}, OrderTypes.ORDER_TRAIN, 1, true)
    ProductionHelpText.forOrder({}, OrderTypes.ORDER_CONSTRUCT, 2, true)
    ProductionHelpText.forOrder({}, OrderTypes.ORDER_CREATE, 3, true)
    T.truthy(seenUnit, "TRAIN dispatched to unitHelp")
    T.truthy(seenBuilding, "CONSTRUCT dispatched to buildingHelp")
    T.truthy(seenProject, "CREATE dispatched to projectHelp")
    T.eq(
        ProductionHelpText.forOrder({}, OrderTypes.ORDER_MAINTAIN, 4, true),
        "process help",
        "MAINTAIN routes to processHelp"
    )
end

return M
