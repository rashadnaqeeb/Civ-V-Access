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

-- ===== Host kick column =====
--
-- Network-MP host-only far-right column. canKick gates which rows offer the
-- action; kickActivate is a two-press confirm whose second press is the only
-- path to Matchmaking.KickPlayer. Both are speech / destructive boundaries.

-- Re-run setup() into a network-MP host session, with a kick-recording
-- Matchmaking and a connection table. `connected` maps playerId -> bool.
-- Installs three players: the active player (99), a connected human (0), and
-- an AI (1). Returns the recorder table { kicked = <playerId or nil> }.
local function setupKick(connected)
    setup()
    Game.IsNetworkMultiPlayer = function()
        return true
    end
    local recorder = { kicked = nil }
    Matchmaking = {
        IsHost = function()
            return true
        end,
        KickPlayer = function(id)
            recorder.kicked = id
        end,
    }
    Network = {
        IsPlayerConnected = function(id)
            return connected[id] == true
        end,
    }

    local function installPlayer(id, opts)
        Teams[id] = {
            IsHasMet = function()
                return true
            end,
        }
        local p = {}
        function p:GetID()
            return id
        end
        function p:GetTeam()
            return id
        end
        function p:GetCivilizationType()
            return 0
        end
        function p:GetNickName()
            return opts.nick or ""
        end
        function p:GetNameKey()
            return "Caesar"
        end
        function p:IsHuman()
            return opts.human == true
        end
        function p:IsObserver()
            return opts.observer == true
        end
        Players[id] = p
        return p
    end

    installPlayer(99, { human = true, nick = "Me" }) -- active player (self)
    installPlayer(0, { human = true, nick = "Bob" }) -- kickable human
    installPlayer(1, { human = false }) -- AI
    return recorder
end

function M.test_canKick_true_for_connected_human_opponent()
    setupKick({ [0] = true })
    T.eq(VictoryProgressAccess.canKick(Players[0]), true)
end

function M.test_canKick_false_for_self()
    setupKick({ [99] = true })
    T.eq(VictoryProgressAccess.canKick(Players[99]), false)
end

function M.test_canKick_false_for_ai()
    setupKick({})
    -- AI: not connected and not human -> not an active human.
    T.eq(VictoryProgressAccess.canKick(Players[1]), false)
end

function M.test_canKick_false_when_not_host()
    setupKick({ [0] = true })
    Matchmaking.IsHost = function()
        return false
    end
    T.eq(VictoryProgressAccess.canKick(Players[0]), false)
end

function M.test_canKick_false_outside_network_mp()
    setupKick({ [0] = true })
    Game.IsNetworkMultiPlayer = function()
        return false
    end
    T.eq(VictoryProgressAccess.canKick(Players[0]), false)
end

function M.test_kick_requires_two_presses()
    local recorder = setupKick({ [0] = true })
    VictoryProgressAccess.resetKickArm()
    local spoken = T.captureSpeech()

    -- First press arms only: no kick yet, a confirm prompt naming the player.
    VictoryProgressAccess.kickActivate(Players[0])
    T.eq(recorder.kicked, nil)
    T.eq(spoken[1].text, "kick Bob of Rome? Enter again to confirm")

    -- Second press on the same player commits the kick.
    VictoryProgressAccess.kickActivate(Players[0])
    T.eq(recorder.kicked, 0)
    T.eq(spoken[2].text, "kicked Bob of Rome")
end

function M.test_kick_arm_does_not_carry_to_other_player()
    local recorder = setupKick({ [0] = true, [2] = true })
    -- A second kickable human.
    Teams[2] = {
        IsHasMet = function()
            return true
        end,
    }
    local p2 = {}
    function p2:GetID()
        return 2
    end
    function p2:GetTeam()
        return 2
    end
    function p2:GetCivilizationType()
        return 0
    end
    function p2:GetNickName()
        return "Eve"
    end
    function p2:GetNameKey()
        return "Caesar"
    end
    function p2:IsHuman()
        return true
    end
    function p2:IsObserver()
        return false
    end
    Players[2] = p2

    VictoryProgressAccess.resetKickArm()
    -- Arm player 0, then press on player 2: player 2 only arms (no kick), and
    -- player 0 is no longer armed.
    VictoryProgressAccess.kickActivate(Players[0])
    VictoryProgressAccess.kickActivate(Players[2])
    T.eq(recorder.kicked, nil)
end

function M.test_resetKickArm_clears_pending_confirm()
    local recorder = setupKick({ [0] = true })
    VictoryProgressAccess.resetKickArm()
    -- Arm, then a screen-open reset; the next press must re-confirm, not kick.
    VictoryProgressAccess.kickActivate(Players[0])
    VictoryProgressAccess.resetKickArm()
    VictoryProgressAccess.kickActivate(Players[0])
    T.eq(recorder.kicked, nil)
end

function M.test_score_columns_append_kick_for_host()
    setupKick({ [0] = true })
    local cols = VictoryProgressAccess.buildScoreColumns()
    -- Kick is the far-right column when host in network MP.
    T.eq(cols[#cols].name, "TXT_KEY_CIVVACCESS_VP_COL_KICK")
end

function M.test_score_columns_omit_kick_when_not_host()
    setupKick({ [0] = true })
    Matchmaking.IsHost = function()
        return false
    end
    local cols = VictoryProgressAccess.buildScoreColumns()
    for _, c in ipairs(cols) do
        T.eq(c.name ~= "TXT_KEY_CIVVACCESS_VP_COL_KICK", true)
    end
end

return M
