-- EndGameMenu accessibility. Victory / defeat screen with a top-row panel
-- switcher (GameOver / Demographics / Ranking / Replay) and a bottom-row
-- action stack (MainMenu exit, Back for extended play, Beyond Earth store).
--
-- Three tabs map onto the top-row visual switcher's GameOver, Ranking, and
-- Replay panels:
--   "Info" — the GameOver panel. Items are the action stack plus the
--   Demographics panel-switcher button (kept so the user can flip the
--   visual to Demographics; its per-screen wrapper owns announcement on
--   the resulting child Context).
--   "Ranking" — the historical-leader scoreboard. Items are one row per
--   GameInfo.HistoricRankings entry mirroring the engine's PopulateResults
--   layout: rank, leader, score, plus the leader's quote on the matched
--   row. The matched row replaces the threshold with the player's actual
--   score, and tab.onActivate lands the cursor on it so the first speech
--   on tab open is the answer.
--   "Replay" — the per-turn replay log. Items are one row per
--   Game.GetReplayMessages() entry, formatted as "Turn N, <text>". No
--   panel-mode pulldown here: the engine's ReplayInfoPulldown lives in the
--   EndGameReplay child Context which we can't reach from the EndGameMenu
--   env, and Graphs / Map don't have summarizers yet. When they do, this
--   tab grows a synthetic mode toggle. End-game pulls messages directly
--   from Game.GetReplayMessages() rather than the child Context's
--   g_ReplayInfo to avoid a cross-Context env reach.
--
-- Demographics doesn't get its own tab in this wrapper. The Demographics
-- LuaContext is wrapped separately for its in-game F9 path and the same
-- wrapper loads at end-game; Tab 1's DemographicsButton remains so the
-- visual flip is still reachable from the keyboard.
--
-- EndGameText carries the victory flavor line set by OnDisplay; surfaced
-- as a function preamble so it speaks on first show and is re-read by F1
-- on any tab. MainMenuButton's text flips to "Continue" in hotseat
-- alt-player mode; we label it with the common "Exit to Main Menu" since
-- that's the path that matters on a finished game.

include("CivVAccess_PopupBoot")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local m_handler = nil

-- Walk HistoricRankings in DB order and find the first row whose threshold
-- is <= the player's final score. Mirrors EndGameMenu's vanilla
-- PopulateResults short-circuit (the `pPlayerScore >= row.LeaderScore and
-- not playerAdded` guard) so the row we mark as matched is the same one
-- the visual highlights and titles. Score is computed via Player:GetScore
-- with the same (true, bWinner) args vanilla passes.
local function buildRankingItems()
    local pPlayer = Players[Game.GetActivePlayer()]
    local bWinner = (pPlayer:GetTeam() == Game:GetWinner())
    local pPlayerScore = pPlayer:GetScore(true, bWinner)
    local items = {}
    local matchedIdx = nil
    local count = 0
    for row in GameInfo.HistoricRankings() do
        count = count + 1
        local rankNum = Text.format("TXT_KEY_NUMBERING_FORMAT", count)
        local leaderName = Text.key(row.HistoricLeader)
        local label
        if matchedIdx == nil and pPlayerScore >= row.LeaderScore then
            matchedIdx = count
            label = Text.format(
                "TXT_KEY_CIVVACCESS_RANKING_MATCHED_ROW",
                rankNum,
                leaderName,
                pPlayerScore,
                Text.key(row.LeaderQuote)
            )
        else
            label = Text.format("TXT_KEY_CIVVACCESS_RANKING_ROW", rankNum, leaderName, row.LeaderScore)
        end
        items[count] = BaseMenuItems.Text({ labelText = label })
    end
    return items, matchedIdx
end

local infoTab = {
    name = "TXT_KEY_VICTORY_INFO",
    showPanel = function()
        OnGameOver()
    end,
    items = {
        BaseMenuItems.Button({
            controlName = "MainMenuButton",
            textKey = "TXT_KEY_MENU_EXIT_TO_MAIN",
            activate = function()
                OnMainMenu()
            end,
        }),
        BaseMenuItems.Button({
            controlName = "BackButton",
            textKey = "TXT_KEY_EXTENDED_GAME_YES",
            activate = function()
                OnBack()
            end,
        }),
        BaseMenuItems.Button({
            controlName = "BeyondButton",
            textKey = "TXT_KEY_GO_BEYOND_EARTH",
            activate = function()
                ShowBeyondEarthStorePage()
            end,
        }),
        BaseMenuItems.Button({
            controlName = "DemographicsButton",
            textKey = "TXT_KEY_DEMOGRAPHICS_TITLE",
            activate = function()
                OnDemographics()
            end,
        }),
    },
}

local rankingTab = {
    name = "TXT_KEY_RANKING_TITLE",
    showPanel = function()
        OnRanking()
    end,
    -- Placeholder; the real items are computed in onActivate every time the
    -- tab is opened so the player's live score reaches buildRankingItems.
    -- Install-time runs at front-end load before any active player exists.
    items = { BaseMenuItems.Text({ labelText = "" }) },
    onActivate = function(self)
        local items, matchedIdx = buildRankingItems()
        m_handler.setItems(items, 2)
        if matchedIdx ~= nil then
            self._indices[self._level] = matchedIdx
        end
    end,
}

-- Game.GetReplayMessages() returns the same per-turn record array vanilla
-- bakes into g_ReplayInfo.Messages on its Refresh() path. Each record has
-- Turn and Text fields; we only render rows whose text is non-empty (some
-- type-only records have empty text and serve only the visual map's plot
-- color updates).
local function buildReplayItems()
    local items = {}
    local messages = Game.GetReplayMessages()
    if messages == nil then
        return items
    end
    for _, m in ipairs(messages) do
        if m.Text ~= nil and m.Text ~= "" then
            items[#items + 1] = BaseMenuItems.Text({
                labelText = Text.format("TXT_KEY_CIVVACCESS_REPLAY_MESSAGE_ROW", m.Turn, m.Text),
            })
        end
    end
    return items
end

local replayTab = {
    name = "TXT_KEY_REPLAY_TITLE",
    showPanel = function()
        OnReplay()
    end,
    items = { BaseMenuItems.Text({ labelText = "" }) },
    onActivate = function(self)
        m_handler.setItems(buildReplayItems(), 3)
    end,
}

m_handler = BaseMenu.install(ContextPtr, {
    name = "EndGameMenu",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_END_GAME"),
    preamble = function()
        return Controls.EndGameText:GetText()
    end,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    tabs = { infoTab, rankingTab, replayTab },
})
