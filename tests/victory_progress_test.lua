-- F8 Victory Progress wrapper tests. Exercises the science-section label /
-- section builders exposed via the VictoryProgressAccess module table after
-- dofiling the wrapper with a stubbed engine surface. The TabbedShell.install
-- at the bottom is guarded on a real ContextPtr, so dofile doesn't wire up a
-- fake Context.
--
-- The load-bearing invariant: the comma-joined spaceship-parts summary on a
-- per-civ science row (partsBuiltSummary) and the Alt+Up/Down section list for
-- that row (scienceCivSections) draw from one fragment source (partsBuiltList),
-- so the per-part sections can never drift from the parts the label folds into
-- one clause. Single-fragment rows (no Apollo / Apollo but no parts) return nil
-- sections and fall back to the spoken string.

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

    -- Engine (non-mod) key civDisplayName formats through; the science part /
    -- row keys are served by the real CivVAccess_Strings the runner loaded.
    T.installLocaleStrings({
        TXT_KEY_RANDOM_LEADER_CIV = "{1_Leader} of {2_Civ}",
    })

    Game = Game or {}
    Game.GetActivePlayer = function()
        return 99
    end
    Game.GetActiveTeam = function()
        return 99
    end
    Game.IsNetworkMultiPlayer = function()
        return false
    end

    Players = {}
    Teams = {}

    -- Project lookups. Each spaceship project resolves to a distinct id; the
    -- threshold is 1 for the singletons and 3 for boosters (BNW vanilla).
    GameInfoTypes = {
        PROJECT_APOLLO_PROGRAM = 10,
        PROJECT_SS_BOOSTER = 11,
        PROJECT_SS_COCKPIT = 12,
        PROJECT_SS_STASIS_CHAMBER = 13,
        PROJECT_SS_ENGINE = 14,
    }
    local thresholdByType = {
        PROJECT_SS_BOOSTER = 3,
        PROJECT_SS_COCKPIT = 1,
        PROJECT_SS_STASIS_CHAMBER = 1,
        PROJECT_SS_ENGINE = 1,
    }
    GameInfo = GameInfo or {}
    GameInfo.Project_VictoryThresholds = function(query)
        local t = thresholdByType[query.ProjectType]
        return function()
            if t == nil then
                return nil
            end
            local v = t
            t = nil
            return { Threshold = v }
        end
    end
    GameInfo.Civilizations = setmetatable({}, {
        __index = function()
            return { ShortDescription = "Rome" }
        end,
    })

    -- Other engine globals the wrapper touches at dofile / build time.
    GameOptionTypes = setmetatable({}, {
        __index = function()
            return 0
        end,
    })
    Game.IsOption = function()
        return false
    end
    Game.IsCustomModOption = nil
    PreGame = PreGame or {}
    PreGame.GetLoadWBScenario = function()
        return false
    end

    EngineData = EngineData or {}

    include = function() end
    dofile("src/dlc/UI/InGame/Popups/CivVAccess_OverviewCivLabels.lua")

    ContextPtr = nil
    VictoryProgressAccess = nil
    dofile("src/dlc/UI/InGame/Popups/CivVAccess_VictoryProgressAccess.lua")
end

-- Stub a player on a team that has built the given spaceship parts. `projects`
-- maps project id -> built count; absence means 0. The player is met (so
-- civDisplayName names it) and reads as a non-active civ.
local function installSciencePlayer(playerId, projects)
    local team = {}
    function team:GetProjectCount(proj)
        return projects[proj] or 0
    end
    function team:IsHasMet()
        return true
    end
    Teams[playerId] = team

    local p = {}
    function p:GetTeam()
        return playerId
    end
    function p:GetID()
        return playerId
    end
    function p:GetCivilizationType()
        return 0
    end
    function p:GetNickName()
        return ""
    end
    function p:GetNameKey()
        return "Caesar"
    end
    Players[playerId] = p
    return p
end

-- ===== partsBuiltList / Summary share one source =====

function M.test_partsBuiltList_orders_built_parts_boosters_first()
    setup()
    installSciencePlayer(0, { [10] = 1, [11] = 2, [12] = 1, [14] = 1 })
    local parts = VictoryProgressAccess.partsBuiltList(Teams[0])
    -- Booster count, then cockpit / chamber / engine in fixed order; chamber
    -- absent (not built).
    T.eq(parts[1], "2 boosters")
    T.eq(parts[2], "cockpit")
    T.eq(parts[3], "engine")
    T.eq(parts[4], nil)
end

function M.test_partsBuiltSummary_joins_the_same_list()
    setup()
    installSciencePlayer(0, { [10] = 1, [11] = 2, [12] = 1, [14] = 1 })
    T.eq(VictoryProgressAccess.partsBuiltSummary(Teams[0]), "2 boosters, cockpit, engine")
end

function M.test_partsBuiltSummary_nil_when_no_parts()
    setup()
    installSciencePlayer(0, { [10] = 1 })
    T.eq(VictoryProgressAccess.partsBuiltSummary(Teams[0]), nil)
end

-- ===== scienceCivLine vs scienceCivSections =====

function M.test_science_label_folds_parts_into_one_clause()
    setup()
    local p = installSciencePlayer(0, { [10] = 1, [11] = 2, [12] = 1 })
    -- Label weaves civ name and the comma-joined parts into one sentence.
    T.eq(VictoryProgressAccess.scienceCivLine(p), "Caesar of Rome, Apollo built, 2 boosters, cockpit")
end

function M.test_science_sections_split_parts_one_per_section()
    setup()
    local p = installSciencePlayer(0, { [10] = 1, [11] = 2, [12] = 1 })
    local sections = VictoryProgressAccess.scienceCivSections(p)
    -- Civ name leads, then each built part on its own section -- NOT the joined
    -- clause the label uses.
    T.eq(sections[1], "Caesar of Rome")
    T.eq(sections[2], "2 boosters")
    T.eq(sections[3], "cockpit")
    T.eq(sections[4], nil)
end

function M.test_science_sections_nil_without_apollo()
    setup()
    -- No Apollo: the row is a single short line, so no section split.
    local p = installSciencePlayer(0, {})
    T.eq(VictoryProgressAccess.scienceCivLine(p), "Caesar of Rome, Apollo not built")
    T.eq(VictoryProgressAccess.scienceCivSections(p), nil)
end

function M.test_science_sections_nil_for_bare_apollo()
    setup()
    -- Apollo built but no parts yet: single short line, no split.
    local p = installSciencePlayer(0, { [10] = 1 })
    T.eq(VictoryProgressAccess.scienceCivLine(p), "Caesar of Rome, Apollo built")
    T.eq(VictoryProgressAccess.scienceCivSections(p), nil)
end

return M
