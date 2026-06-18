-- Ctrl+E Espionage Overview wrapper tests. Exercises the pure label / section
-- builders exposed via the EspionageOverviewAccess module table after dofiling
-- the wrapper with a stubbed engine surface. The TabbedShell.install at the
-- bottom of the wrapper is guarded on a real ContextPtr, so dofile doesn't try
-- to wire up a fake Context.
--
-- The load-bearing invariant: the comma-joined city row label and its
-- Alt+Up/Down section list share one fragment source (cityRowFragments), so a
-- breakdown that the label folds into a single trailing clause must reappear in
-- the section list as one section per modifier -- never recomputed, never
-- drifting from what is spoken. Same for the intrigue row's per-line split.
--
-- Mod-authored TXT_KEYs resolve through the real en_US strings file (the runner
-- dofiles it); only the engine keys the breakdown entries use are mapped via
-- installLocaleStrings so the per-entry content is distinguishable.

local T = require("support")
local M = {}

local function setup()
    Log.warn = function() end
    Log.error = function() end
    Log.info = function() end
    Log.debug = function() end

    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua")
    SpeechPipeline._reset()
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")

    -- Engine (non-mod) keys the breakdown entries format through. Mod keys are
    -- served by the real CivVAccess_Strings the runner loaded.
    T.installLocaleStrings({
        TXT_KEY_EO_POTENTIAL_BUILDING_MOD_ENTRY = "{1_Name} {2_Mod}",
        TXT_KEY_EO_POTENTIAL_POLICY_MOD_ENTRY = "{1_Name} {2_Mod}",
    })

    Game = Game or {}
    Game.GetActivePlayer = function()
        return 0
    end
    Game.IsOption = function()
        return false
    end
    Game.IsNetworkMultiPlayer = function()
        return false
    end

    Players = {}
    Map = Map or {}
    Map.GetPlot = function()
        return nil
    end

    Events = Events or {}
    Events.SerialEventEspionageScreenDirty = { Add = function() end }
    Events.SerialEventExitCityScreen = { Add = function() end, Remove = function() end }

    UI = UI or {}
    UIManager = UIManager or {}

    -- VP detection probe (PopulateSelectionList) is absent in the harness, so
    -- the wrapper takes the vanilla path (breakdown active). The include()
    -- chain is then a noop.
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
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")

    ContextPtr = nil
    EspionageOverviewAccess = nil
    dofile("src/dlc/UI/InGame/Popups/CivVAccess_EspionageOverviewAccess.lua")
end

-- Install a Players[0] (active player, owns the city) whose GetCityByID returns
-- a city exposing the espionage-modifier accessors the breakdown reads.
-- `modifiers` is an array of { name, mod }; GameInfo is wired so each shows up
-- as a building-mod entry in declared order. No policies.
local function installCityWithBreakdown(modifiers)
    local pCity = {}
    function pCity:GetBuildingEspionageModifier(id)
        return (modifiers[id] or {}).mod or 0
    end
    function pCity:GetBuildingGlobalEspionageModifier()
        return 0
    end
    function pCity:IsHasBuilding(id)
        return modifiers[id] ~= nil
    end

    local p = {}
    function p:GetCityByID()
        return pCity
    end
    function p:GetBuildingClassCount()
        return 0
    end
    function p:HasPolicy()
        return false
    end
    function p:IsPolicyBlocked()
        return false
    end
    function p:GetPolicyEspionageModifier()
        return 0
    end
    Players[0] = p

    GameInfo = GameInfo or {}
    GameInfo.Buildings = function()
        local i = 0
        return function()
            i = i + 1
            local m = modifiers[i]
            if m == nil then
                return nil
            end
            return { ID = i, BuildingClass = "BC" .. i, Description = m.name }
        end
    end
    GameInfo.BuildingClasses = setmetatable({}, {
        __index = function()
            return { ID = 0 }
        end,
    })
    -- No policies: index 0 nil exits the policy loop immediately.
    GameInfo.Policies = {}
end

local function cityInfo()
    return {
        PlayerID = 0,
        CityID = 1,
        CityX = 1,
        CityY = 1,
        CivilizationName = "Rome",
        Name = "Antium",
        Population = 6,
        BasePotential = 4,
        Potential = 4,
    }
end

-- ===== City row: label vs sections =====

function M.test_city_label_folds_breakdown_into_one_trailing_clause()
    setup()
    installCityWithBreakdown({ { name = "Constabulary", mod = -15 }, { name = "Police Station", mod = -25 } })
    -- dropCiv=true: civ named by the parent group, so the lead starts at name.
    local label = EspionageOverviewAccess.cityRowLabel(cityInfo(), false, nil, true)
    -- One joined string: name, population, potential, then the breakdown as a
    -- single "breakdown: ..." clause holding both modifiers comma-joined.
    T.eq(label, "Antium, population 6, potential 4, breakdown: Constabulary -15, Police Station -25")
end

function M.test_city_sections_split_breakdown_one_per_modifier()
    setup()
    installCityWithBreakdown({ { name = "Constabulary", mod = -15 }, { name = "Police Station", mod = -25 } })
    local sections = EspionageOverviewAccess.cityRowSections(cityInfo(), false, nil, true)
    -- Lead fragments each their own section, then each modifier separately --
    -- NOT the joined "breakdown: ..." clause the label uses.
    T.eq(sections[1], "Antium")
    T.eq(sections[2], "population 6")
    T.eq(sections[3], "potential 4")
    T.eq(sections[4], "Constabulary -15")
    T.eq(sections[5], "Police Station -25")
    T.eq(sections[6], nil, "no trailing joined-breakdown section")
end

function M.test_city_sections_include_civ_when_not_dropped()
    setup()
    installCityWithBreakdown({})
    -- dropCiv=false (top-level / not under a per-civ group): civ leads.
    local sections = EspionageOverviewAccess.cityRowSections(cityInfo(), false, nil, false)
    T.eq(sections[1], "Rome")
    T.eq(sections[2], "Antium")
end

function M.test_city_sections_include_spy_clause_before_potential()
    setup()
    installCityWithBreakdown({})
    local spy = { Name = "Pickles", IsDiplomat = false }
    local sections = EspionageOverviewAccess.cityRowSections(cityInfo(), false, spy, true)
    -- name, population, spy clause, potential -- spy clause is its own section.
    T.eq(sections[1], "Antium")
    T.eq(sections[2], "population 6")
    T.eq(sections[3], "agent Pickles")
    T.eq(sections[4], "potential 4")
end

function M.test_city_no_breakdown_label_equals_sections_joined()
    setup()
    installCityWithBreakdown({})
    local ci = cityInfo()
    local label = EspionageOverviewAccess.cityRowLabel(ci, false, nil, true)
    local sections = EspionageOverviewAccess.cityRowSections(ci, false, nil, true)
    -- With no modifiers, the label is exactly the section list comma-joined:
    -- the two builders share one source and can't drift.
    T.eq(label, "Antium, population 6, potential 4")
    T.eq(table.concat(sections, ", "), label)
end

-- ===== Intrigue row: label vs sections =====

function M.test_intrigue_label_joins_turn_from_message_with_periods()
    setup()
    local msg = {
        Turn = 42,
        DiscoveringPlayer = 0,
        SpyName = "Pickles",
        String = "Plotting war against Greece",
    }
    T.eq(EspionageOverviewAccess.intrigueRowLabel(msg), "Turn 42. from your spy Pickles. Plotting war against Greece")
end

function M.test_intrigue_sections_split_multiline_message_per_line()
    setup()
    local msg = {
        Turn = 42,
        DiscoveringPlayer = 0,
        SpyName = "Pickles",
        String = "Plotting war against Greece[NEWLINE]Targeting your capital",
    }
    local sections = EspionageOverviewAccess.intrigueRowSections(msg)
    T.eq(sections[1], "Turn 42")
    T.eq(sections[2], "from your spy Pickles")
    T.eq(sections[3], "Plotting war against Greece")
    T.eq(sections[4], "Targeting your capital")
    T.eq(sections[5], nil)
end

function M.test_intrigue_sections_single_line_message_one_section()
    setup()
    local msg = {
        Turn = 7,
        DiscoveringPlayer = 0,
        SpyName = "Pickles",
        String = "Building a spaceship",
    }
    local sections = EspionageOverviewAccess.intrigueRowSections(msg)
    T.eq(sections[1], "Turn 7")
    T.eq(sections[2], "from your spy Pickles")
    T.eq(sections[3], "Building a spaceship")
    T.eq(sections[4], nil)
end

return M
