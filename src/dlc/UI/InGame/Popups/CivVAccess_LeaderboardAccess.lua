-- Leaderboard accessibility. Online-leaderboard popup with three category
-- tabs (Friends / Personal / Global), a leaderboard-source pulldown that
-- scopes which leaderboard mod's data is shown, and a paginated row list
-- fetched async via UI.RequestLeaderboardScores. Each tab carries the
-- pulldown + Refresh + page boundary items at fixed positions; the rows
-- are populated when Leaderboard_ScoresDownloaded fires.
--
-- Each row is flattened to a single Text entry whose announce string
-- carries the full XML row in visual order: rank, score, player name,
-- leader of civ, victory/defeat, winner + victory type, map and setup
-- icons, start era + winning turn, end time.
--
-- Pagination is exposed as Previous Page / Next Page Text items at the
-- top / bottom of the row list (filtered out at the corresponding
-- boundary). Activating one fires UI.ScrollLeaderboard{Up,Down} +
-- RefreshScores; the cursor lands on the first / last row of the new
-- chunk after the data arrives so the user keeps moving in the same
-- direction without bouncing back to the pulldown.
--
-- Status preamble surfaces the LeaderboardStatus label text — covers the
-- "retrieving scores", "no leaderboard", "not supported by mod", and
-- "no scores" engine states the user would otherwise hit silently while
-- arrowing past the static items.
--
-- Loaded as a child LuaContext of the front-end OtherMenu (no in-game
-- entry point), which is why our DLC manifest extends <Skin> with
-- UI/InGame/Popups so this override is visible at front-end resolution
-- time. The override file prepends CivVAccess_ProbeBoot so the shared
-- PullDown metatable is patched before vanilla calls
-- LeaderboardPull:RegisterSelectionCallback.

include("CivVAccess_FrontendCommon")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local m_handler = nil
local m_currentTab = 1
local m_atTop = true
local m_atBottom = true
-- "first" / "last" sentinel set right before activating a page item so the
-- post-refresh handler knows where to land the cursor. Cleared after
-- application; default (nil) means "leave cursor where setItems clamps it".
local m_pendingCursor = nil
-- Tracks the leaderboard category the engine is currently on. Vanilla's
-- ShowHide always calls OnCategory(1) on every show, AND our tab[1].onActivate
-- fires from BaseMenu.openInitial on the same show — without de-dup, every
-- open would issue two RequestLeaderboardScores calls and trigger our
-- listener twice. Wrapping OnCategory below is the single point that keeps
-- this in sync across vanilla's ShowHide path, vanilla's mouse-click button
-- callbacks (already captured pre-wrap, so they won't update this — but
-- mouse-clicking the category buttons isn't part of the keyboard flow), and
-- our tab.onActivate path.
local m_engineCategory = nil
local _vanillaOnCategory = OnCategory
OnCategory = function(idx)
    m_engineCategory = idx
    _vanillaOnCategory(idx)
end

local function joinNonEmpty(parts)
    local out = nil
    for i = 1, #parts do
        local s = parts[i]
        if s ~= nil and s ~= "" then
            if out == nil then
                out = s
            else
                out = out .. ", " .. s
            end
        end
    end
    return out or ""
end

local function lookupDescription(tbl, key)
    if key == nil then
        return ""
    end
    local row = tbl[key]
    if row == nil or row.Description == nil then
        return ""
    end
    return Text.key(row.Description)
end

local function leaderCivText(v)
    local civ = GameInfo.Civilizations[v.Civ]
    if civ == nil then
        return Text.key("TXT_KEY_MISC_UNKNOWN")
    end
    local civName = Text.key(civ.ShortDescription)
    local linkRow = GameInfo.Civilization_Leaders("CivilizationType = '" .. civ.Type .. "'")()
    if linkRow == nil then
        return civName
    end
    local leader = GameInfo.Leaders[linkRow.LeaderheadType]
    if leader == nil then
        return civName
    end
    return joinNonEmpty({ Text.key(leader.Description), civName })
end

local function winnerText(v)
    if v.WinningTeamLeaderCivilizationType ~= nil then
        local winCiv = GameInfo.Civilizations[v.WinningTeamLeaderCivilizationType]
        if winCiv ~= nil then
            return Text.key(winCiv.ShortDescription)
        end
    end
    return Text.key("TXT_KEY_CITY_STATE_NOBODY")
end

local function victoryTypeText(v)
    if v.VictoryType == nil then
        return ""
    end
    local row = GameInfo.Victories[v.VictoryType]
    if row == nil or row.VictoryStatement == nil then
        return ""
    end
    return Text.key(row.VictoryStatement)
end

local function mapTypeText(v)
    if v.MapName == nil or v.MapName == "" then
        return ""
    end
    local info = MapUtilities.GetBasicInfo(v.MapName)
    if info == nil or info.Name == nil then
        return ""
    end
    return Text.key(info.Name)
end

local function eraTurnText(v)
    local eraName = lookupDescription(GameInfo.Eras, v.StartEraType)
    if eraName == "" then
        eraName = Text.key("TXT_KEY_MISC_UNKNOWN")
    end
    return Text.format("TXT_KEY_ERA_TURNS_FORMAT", eraName, v.WinningTurn or 0)
end

local function statusBangText(v)
    if v.PlayerTeamWon then
        return Text.key("TXT_KEY_VICTORY_BANG")
    end
    return Text.key("TXT_KEY_DEFEAT_BANG")
end

local function rankText(v)
    return Text.format("TXT_KEY_CIVVACCESS_LABEL_VALUE", Text.key("TXT_KEY_DEMOGRAPHICS_RANK"), v.GlobalRank or 0)
end

local function scoreText(v)
    return Text.format("TXT_KEY_CIVVACCESS_LABEL_VALUE", Text.key("TXT_KEY_POP_SCORE"), v.Score or 0)
end

local function rowLabel(v)
    return joinNonEmpty({
        rankText(v),
        scoreText(v),
        v.PlayerName or "",
        leaderCivText(v),
        statusBangText(v),
        winnerText(v),
        victoryTypeText(v),
        mapTypeText(v),
        lookupDescription(GameInfo.Worlds, v.WorldSize),
        lookupDescription(GameInfo.HandicapInfos, v.PlayerHandicapType),
        lookupDescription(GameInfo.GameSpeeds, v.GameSpeed),
        eraTurnText(v),
        v.GameEndTime or "",
    })
end

-- The vanilla LeaderboardStatus label is shown over the row list whenever
-- a non-success state is in flight (request pending, no leaderboard, mod
-- doesn't support, no scores). Surfaces here as the screen preamble so
-- the user hears the status on open and on F1, and as a list-tail Text
-- item when there are no rows so arrow-key nav lands on a non-silent
-- entry instead of past the page items.
local function statusLabelText()
    if Controls.LeaderboardStatus == nil then
        return nil
    end
    if Controls.LeaderboardStatus:IsHidden() then
        return nil
    end
    local s = Controls.LeaderboardStatus:GetText()
    if s == nil or s == "" then
        return nil
    end
    return s
end

local function leaderboardPulldown()
    return BaseMenuItems.Pulldown({
        controlName = "LeaderboardPull",
        textKey = "TXT_KEY_LEADERBOARD_PULLDOWN",
        tooltipKey = "TXT_KEY_LEADERBOARD_PULLDOWN_TT",
        -- Engine callback (OnLeaderboardPull) already fires UI.SetLeaderboard +
        -- RefreshScores; rows arrive via Leaderboard_ScoresDownloaded which
        -- rebuilds the items list. No extra work here.
    })
end

local function refreshButton()
    return BaseMenuItems.Button({
        controlName = "RefreshButton",
        textKey = "TXT_KEY_MULTIPLAYER_REFRESH_GAME_LIST",
        tooltipKey = "TXT_KEY_LEADERBOARD_REFRESH_TT",
        activate = function()
            RefreshScores()
        end,
    })
end

local function prevPageItem()
    return BaseMenuItems.Text({
        labelText = Text.key("TXT_KEY_CIVVACCESS_LEADERBOARD_PREV_PAGE"),
        onActivate = function()
            m_pendingCursor = "last"
            UI.ScrollLeaderboardUp()
            RefreshScores()
        end,
    })
end

local function nextPageItem()
    return BaseMenuItems.Text({
        labelText = Text.key("TXT_KEY_CIVVACCESS_LEADERBOARD_NEXT_PAGE"),
        onActivate = function()
            m_pendingCursor = "first"
            UI.ScrollLeaderboardDown()
            RefreshScores()
        end,
    })
end

-- Build the items list for the active tab. Layout (cursor lands on the
-- pulldown by default at first show):
--   1. leaderboard-source pulldown  (always)
--   2. Refresh button                (always)
--   3. Previous page                 (only when not at top of leaderboard)
--   4..N. game rows                  (one per UI.GetLeaderboardScores entry)
--   N+1. status notice               (when no rows are available)
--   tail. Next page                  (only when not at bottom of leaderboard)
local function buildItemsForActiveTab()
    local items = { leaderboardPulldown(), refreshButton() }
    local firstRowIdx, lastRowIdx
    if not m_atTop then
        items[#items + 1] = prevPageItem()
    end
    local games = UI.GetLeaderboardScores()
    if games ~= nil and next(games) ~= nil then
        -- Vanilla iterates with pairs (rank ordering comes from the
        -- engine-provided table's insertion order). Match that to avoid
        -- the Civ V ipairs (0,t[0]) quirk if the engine ever returns a
        -- 0-indexed table.
        for _, v in pairs(games) do
            items[#items + 1] = BaseMenuItems.Text({ labelText = rowLabel(v) })
            if firstRowIdx == nil then
                firstRowIdx = #items
            end
            lastRowIdx = #items
        end
    else
        local s = statusLabelText()
        if s ~= nil then
            items[#items + 1] = BaseMenuItems.Text({ labelText = s })
        end
    end
    if not m_atBottom then
        items[#items + 1] = nextPageItem()
    end
    return items, firstRowIdx, lastRowIdx
end

-- Apply m_pendingCursor's "land on first/last new row" hint after a
-- pagination-driven setItems. setIndex itself doesn't announce, so we
-- speak the new row's label directly to confirm to the user that the
-- prev/next page activation took effect and where the cursor landed.
-- No-op when the rebuilt list has no rows (handler keeps clamped cursor;
-- preamble already covers the silent state).
local function applyPendingCursor(items, firstRowIdx, lastRowIdx)
    if m_pendingCursor == nil then
        return
    end
    local target
    if m_pendingCursor == "first" then
        target = firstRowIdx
    elseif m_pendingCursor == "last" then
        target = lastRowIdx
    end
    m_pendingCursor = nil
    if target == nil or items == nil or items[target] == nil or m_handler == nil then
        return
    end
    m_handler.setIndex(target)
    local ok, text = pcall(function()
        return items[target]:announce(m_handler)
    end)
    if ok and text ~= nil and text ~= "" then
        SpeechPipeline.speakInterrupt(text)
    end
end

local function rebuildActiveTab()
    if m_handler == nil then
        m_pendingCursor = nil
        return
    end
    -- A response can land after the user closes the popup (UI.RequestLeaderboardScores
    -- is fire-and-forget). setItems on a hidden handler is harmless but
    -- refresh() and the pagination announce would speak from a screen
    -- that's no longer visible. Skip speech when hidden; the next show
    -- triggers a fresh fetch via tab.onActivate / vanilla ShowHide anyway.
    local hidden = ContextPtr:IsHidden()
    local items, firstRowIdx, lastRowIdx = buildItemsForActiveTab()
    m_handler.setItems(items, m_currentTab)
    if hidden then
        m_pendingCursor = nil
        return
    end
    applyPendingCursor(items, firstRowIdx, lastRowIdx)
    m_handler.refresh()
end

-- Engine fires this on every UI.RequestLeaderboardScores response (success
-- or error). atTop / atBottom describe the loaded chunk's position within
-- the full leaderboard. Vanilla also has its own listener; we add ours
-- alongside (Events.Leaderboard_ScoresDownloaded.Add chains).
Events.Leaderboard_ScoresDownloaded.Add(function(_, atTop, atBottom)
    m_atTop = atTop
    m_atBottom = atBottom
    rebuildActiveTab()
end)

local function makeTabSpec(name, idx)
    return {
        name = name,
        items = { leaderboardPulldown(), refreshButton() },
        onActivate = function()
            m_currentTab = idx
            -- Skip if vanilla's ShowHide already fired OnCategory for this
            -- category (e.g. tab[1].onActivate during first-show openInitial).
            -- The wrapper above keeps m_engineCategory in sync with whichever
            -- code path called OnCategory most recently.
            if m_engineCategory == idx then
                return
            end
            local ok, err = pcall(OnCategory, idx)
            if not ok then
                Log.error("LeaderboardAccess: OnCategory(" .. idx .. ") failed: " .. tostring(err))
            end
        end,
    }
end

m_handler = BaseMenu.install(ContextPtr, {
    name = "Leaderboard",
    displayName = Text.key("TXT_KEY_LEADERBOARD"),
    preamble = statusLabelText,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    tabs = {
        makeTabSpec("TXT_KEY_LEADERBOARD_FRIENDS", 1),
        makeTabSpec("TXT_KEY_LEADERBOARD_PERSONAL", 2),
        makeTabSpec("TXT_KEY_LEADERBOARD_GLOBAL", 3),
    },
})
