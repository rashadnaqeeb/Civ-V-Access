-- Tests for the replay graph-data row builder shared by the end-game
-- screen's Graphs tab and the front-end replay viewer's Graphs panel.
--
-- The load-bearing invariants are the two shapes the engine hands back.
-- Player:GetReplayData is table[dataSet][turn] and has to be transposed
-- before it can be read a turn at a time; a replay file's PlayerInfo
-- arrives already transposed. Both feed the same tree, so a transpose that
-- swapped its keys would speak one civ's numbers under another turn with
-- nothing to give it away. The rest covers the leaf composition (dataset
-- name plus its number), dataset ordering, which turns earn a group, and
-- the laziness that keeps a full game off the screen-open path.

local T = require("support")
local M = {}

local origGameInfo, origGameDefines, origPlayers

-- GameInfo.ReplayDataSets is called as an iterator over rows carrying Type
-- and Description, the way the engine's XML-backed tables behave.
local function installDataSets(rows)
    GameInfo.ReplayDataSets = function()
        local i = 0
        return function()
            i = i + 1
            return rows[i]
        end
    end
end

-- Three datasets whose descriptions sort into a different order than the
-- rows are declared in, so the dataset ordering assertion can't pass by
-- accident.
local function installDefaultDataSets()
    installDataSets({
        { Type = "REPLAYDATASET_SCORE", Description = "Score" },
        { Type = "REPLAYDATASET_CITYCOUNT", Description = "Cities" },
        { Type = "REPLAYDATASET_TECHSKNOWN", Description = "Techs Known" },
    })
end

local function setup()
    -- Both re-established here rather than inherited: an earlier suite
    -- clears CivVAccess_Strings, and another leaves verbosity at the
    -- production default, either of which would make these assertions
    -- depend on registration order. The kind tag verbosity appends is
    -- covered by the BaseMenu suites.
    dofile("src/dlc/UI/InGame/CivVAccess_InGameStrings_en_US.lua")
    civvaccess_shared.verbosity = false
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_HandlerStack.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_InputRouter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_TickPump.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Nav.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_BaseMenuItems.lua")
    dofile("src/dlc/UI/InGame/Popups/CivVAccess_ReplayGraphRows.lua")

    origGameInfo = GameInfo
    origGameDefines = GameDefines
    origPlayers = Players

    GameInfo = {}
    installDefaultDataSets()
    GameDefines = { MAX_CIV_PLAYERS = 4 }
    Players = {}
end

local function teardown()
    GameInfo = origGameInfo
    GameDefines = origGameDefines
    Players = origPlayers
end

-- A player whose GetReplayData returns the engine's table[dataSet][turn]
-- shape. `calls` counts the engine hits so the laziness test can assert
-- the tree didn't pull the data on build.
local function fakePlayer(civName, byDataSet, calls)
    local p = {}
    function p:IsEverAlive()
        return true
    end
    function p:GetCivilizationShortDescription()
        return civName
    end
    function p:GetReplayData()
        if calls ~= nil then
            calls.n = calls.n + 1
        end
        return byDataSet
    end
    return p
end

-- Announce every item in a list, joined so one assertion covers content
-- and order together.
local function labels(items)
    local out = {}
    for _, item in ipairs(items) do
        out[#out + 1] = item:announce()
    end
    return table.concat(out, " | ")
end

-- The navigable items at one level, dropping the groups BaseMenu skips.
local function navigable(items)
    local out = {}
    for _, item in ipairs(items) do
        if item:isNavigable() then
            out[#out + 1] = item
        end
    end
    return out
end

-- ===== Leaf composition =====

function M.test_leaf_speaks_dataset_name_and_value()
    setup()
    local players = {
        {
            name = "Rome",
            scoresFn = function()
                return { [7] = { REPLAYDATASET_SCORE = 58 } }
            end,
        },
    }
    local turns = ReplayGraphRows.buildItems(players)[1]:children()
    T.eq(labels(turns[1]:children()), "Score 58")
    teardown()
end

function M.test_turn_lists_only_datasets_with_a_value()
    setup()
    -- A civ conquered mid-game stops recording some datasets; the turn's
    -- leaves are what the table actually holds, not one row per dataset.
    local players = {
        {
            name = "Rome",
            scoresFn = function()
                return { [7] = { REPLAYDATASET_SCORE = 58, REPLAYDATASET_TECHSKNOWN = 14 } }
            end,
        },
    }
    local turns = ReplayGraphRows.buildItems(players)[1]:children()
    T.eq(labels(turns[1]:children()), "Score 58 | Techs Known 14")
    teardown()
end

function M.test_datasets_are_ordered_by_localized_description()
    setup()
    -- Declared Score, Cities, Techs Known; spoken Cities, Score, Techs Known.
    local players = {
        {
            name = "Rome",
            scoresFn = function()
                return {
                    [7] = {
                        REPLAYDATASET_SCORE = 58,
                        REPLAYDATASET_CITYCOUNT = 4,
                        REPLAYDATASET_TECHSKNOWN = 14,
                    },
                }
            end,
        },
    }
    local turns = ReplayGraphRows.buildItems(players)[1]:children()
    T.eq(labels(turns[1]:children()), "Cities 4 | Score 58 | Techs Known 14")
    teardown()
end

-- ===== Turn groups =====

function M.test_turns_are_ascending_and_skip_gaps()
    setup()
    local players = {
        {
            name = "Rome",
            scoresFn = function()
                return {
                    [9] = { REPLAYDATASET_SCORE = 61 },
                    [2] = { REPLAYDATASET_SCORE = 24 },
                    [7] = { REPLAYDATASET_SCORE = 58 },
                }
            end,
        },
    }
    local turns = ReplayGraphRows.buildItems(players)[1]:children()
    T.eq(labels(turns), "Turn 2 | Turn 7 | Turn 9")
    teardown()
end

function M.test_civ_with_no_recorded_turns_is_not_navigable()
    setup()
    local players = {
        {
            name = "Rome",
            scoresFn = function()
                return {}
            end,
        },
        {
            name = "Songhai",
            scoresFn = function()
                return { [3] = { REPLAYDATASET_SCORE = 30 } }
            end,
        },
    }
    T.eq(labels(navigable(ReplayGraphRows.buildItems(players))), "Songhai")
    teardown()
end

function M.test_no_players_speaks_the_no_data_notice()
    setup()
    T.eq(labels(ReplayGraphRows.buildItems({})), "TXT_KEY_REPLAY_NOGRAPHDATA")
    teardown()
end

-- ===== Laziness =====

function M.test_scores_are_not_read_until_the_civ_is_drilled()
    setup()
    -- Every dataset is recorded for every living civ on every turn, so a
    -- build that pulled all of it up front would stall the screen on open.
    local calls = { n = 0 }
    local players = {
        {
            name = "Rome",
            scoresFn = function()
                calls.n = calls.n + 1
                return { [3] = { REPLAYDATASET_SCORE = 30 } }
            end,
        },
    }
    local items = ReplayGraphRows.buildItems(players)
    T.eq(calls.n, 0, "buildItems must not read scores")
    items[1]:children()
    T.eq(calls.n, 1, "drill reads scores once")
    items[1]:children()
    T.eq(calls.n, 1, "second drill reuses the built children")
    teardown()
end

-- ===== Live-game normalization =====

function M.test_game_players_transpose_dataset_major_engine_data()
    setup()
    Players[0] = fakePlayer("Rome", {
        REPLAYDATASET_SCORE = { [2] = 24, [3] = 31 },
        REPLAYDATASET_CITYCOUNT = { [3] = 2 },
    })
    local items = ReplayGraphRows.buildItems(ReplayGraphRows.playersFromGame())
    T.eq(labels(items), "Rome")
    local turns = items[1]:children()
    T.eq(labels(turns), "Turn 2 | Turn 3")
    T.eq(labels(turns[1]:children()), "Score 24")
    T.eq(labels(turns[2]:children()), "Cities 2 | Score 31")
    teardown()
end

function M.test_game_players_skip_slots_never_alive()
    setup()
    Players[0] = fakePlayer("Rome", { REPLAYDATASET_SCORE = { [2] = 24 } })
    Players[1] = fakePlayer("Songhai", {})
    Players[1].IsEverAlive = function()
        return false
    end
    T.eq(labels(ReplayGraphRows.buildItems(ReplayGraphRows.playersFromGame())), "Rome")
    teardown()
end

function M.test_game_players_do_not_call_the_engine_on_build()
    setup()
    local calls = { n = 0 }
    Players[0] = fakePlayer("Rome", { REPLAYDATASET_SCORE = { [2] = 24 } }, calls)
    local items = ReplayGraphRows.buildItems(ReplayGraphRows.playersFromGame())
    T.eq(calls.n, 0, "GetReplayData must not run until the civ is drilled")
    items[1]:children()
    T.eq(calls.n, 1, "drill queries the engine once")
    teardown()
end

-- ===== Replay-file normalization =====

function M.test_replay_info_players_read_turn_major_scores()
    setup()
    local info = {
        PlayerInfo = {
            {
                CivShortDescription = "Rome",
                Scores = { [2] = { REPLAYDATASET_SCORE = 24 } },
            },
        },
    }
    local items = ReplayGraphRows.buildItems(ReplayGraphRows.playersFromReplayInfo(info))
    T.eq(labels(items), "Rome")
    local turns = items[1]:children()
    T.eq(labels(turns), "Turn 2")
    T.eq(labels(turns[1]:children()), "Score 24")
    teardown()
end

function M.test_replay_info_falls_back_to_the_civilization_row_name()
    setup()
    -- Older replay files carry no CivShortDescription; vanilla's graph
    -- legend falls back to the Civilizations row and so do we.
    GameInfo.Civilizations = { CIVILIZATION_ROME = { ShortDescription = "Rome" } }
    local info = {
        PlayerInfo = {
            {
                Civilization = "CIVILIZATION_ROME",
                Scores = { [2] = { REPLAYDATASET_SCORE = 24 } },
            },
        },
    }
    T.eq(labels(ReplayGraphRows.buildItems(ReplayGraphRows.playersFromReplayInfo(info))), "Rome")
    teardown()
end

function M.test_replay_info_with_no_scores_speaks_the_no_data_notice()
    setup()
    local info = {
        PlayerInfo = {
            { CivShortDescription = "Rome", Scores = {} },
        },
    }
    T.eq(labels(ReplayGraphRows.buildItems(ReplayGraphRows.playersFromReplayInfo(info))), "TXT_KEY_REPLAY_NOGRAPHDATA")
    teardown()
end

function M.test_replay_info_without_player_info_speaks_the_no_data_notice()
    setup()
    T.eq(labels(ReplayGraphRows.buildItems(ReplayGraphRows.playersFromReplayInfo(nil))), "TXT_KEY_REPLAY_NOGRAPHDATA")
    teardown()
end

return M
