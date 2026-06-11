-- BeliefAdvisor tests. The trophy thresholds mirror Community Patch's
-- belief chooser ranking exactly (the three highest scores in the offered
-- list, ties sharing a tier), and a wrong tier reaching speech is a silent
-- failure -- the player has no score display to cross-check against.

local T = require("support")
local M = {}

local function setup(scores)
    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")

    CivVAccess_Strings = CivVAccess_Strings or {}
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_TROPHY_GOLD"] = "gold"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_TROPHY_SILVER"] = "silver"
    CivVAccess_Strings["TXT_KEY_CIVVACCESS_ADVISOR_TROPHY_BRONZE"] = "bronze"

    Game = Game or {}
    Game.GetActivePlayer = function()
        return 0
    end
    if scores ~= nil then
        Game.ScoreBelief = function(_, beliefID)
            return scores[beliefID]
        end
    else
        Game.ScoreBelief = nil
    end

    OptionsManager = OptionsManager or {}
    OptionsManager.IsNoBasicHelp = function()
        return false
    end

    dofile("src/dlc/UI/InGame/Popups/CivVAccess_BeliefAdvisor.lua")
end

local function ids(scores)
    local out = {}
    for id in pairs(scores) do
        out[#out + 1] = id
    end
    table.sort(out)
    return out
end

function M.test_vanilla_without_scorebelief_returns_empty()
    setup(nil)
    local suffixes = BeliefAdvisor.labelSuffixes({ 1, 2, 3 })
    T.eq(next(suffixes), nil, "no suffixes without Game.ScoreBelief")
end

function M.test_no_basic_help_suppresses_ranking()
    local scores = { [1] = 30, [2] = 20, [3] = 10 }
    setup(scores)
    OptionsManager.IsNoBasicHelp = function()
        return true
    end
    local suffixes = BeliefAdvisor.labelSuffixes(ids(scores))
    T.eq(next(suffixes), nil, "no suffixes with basic help off")
end

function M.test_distinct_scores_rank_top_three()
    local scores = { [1] = 40, [2] = 30, [3] = 20, [4] = 10 }
    setup(scores)
    local suffixes = BeliefAdvisor.labelSuffixes(ids(scores))
    T.eq(suffixes[1], "gold", "highest score is gold")
    T.eq(suffixes[2], "silver", "second is silver")
    T.eq(suffixes[3], "bronze", "third is bronze")
    T.eq(suffixes[4], nil, "fourth gets nothing")
end

-- A tie for first consumes the gold and silver thresholds, so the next
-- distinct score lands on bronze and nothing is spoken as silver. This is
-- the vendor's exact behavior, not an off-by-one.
function M.test_tied_top_scores_share_gold()
    local scores = { [1] = 10, [2] = 10, [3] = 5, [4] = 3 }
    setup(scores)
    local suffixes = BeliefAdvisor.labelSuffixes(ids(scores))
    T.eq(suffixes[1], "gold", "tied first is gold")
    T.eq(suffixes[2], "gold", "tied first is gold")
    T.eq(suffixes[3], "bronze", "next distinct score is bronze, not silver")
    T.eq(suffixes[4], nil, "fourth gets nothing")
end

function M.test_two_beliefs_rank_gold_and_silver()
    local scores = { [1] = 7, [2] = 4 }
    setup(scores)
    local suffixes = BeliefAdvisor.labelSuffixes(ids(scores))
    T.eq(suffixes[1], "gold", "higher of two is gold")
    T.eq(suffixes[2], "silver", "lower of two is silver")
end

-- All-equal scores (including all-zero) mark every belief gold; the vendor
-- shows a gold trophy on each, so speech mirrors the screen.
function M.test_uniform_scores_mark_everything_gold()
    local scores = { [1] = 0, [2] = 0, [3] = 0, [4] = 0 }
    setup(scores)
    local suffixes = BeliefAdvisor.labelSuffixes(ids(scores))
    for id = 1, 4 do
        T.eq(suffixes[id], "gold", "uniform score " .. id .. " is gold")
    end
end

return M
