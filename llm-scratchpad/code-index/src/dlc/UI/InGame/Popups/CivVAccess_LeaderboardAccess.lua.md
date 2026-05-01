# `src/dlc/UI/InGame/Popups/CivVAccess_LeaderboardAccess.lua`

372 lines · Accessibility wrapper for the online Leaderboard screen (front-end), providing three category tabs with a pulldown, pagination items, and async score rows populated by `Leaderboard_ScoresDownloaded`.

## Header comment

```
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
```

## Outline

- L33: `include("CivVAccess_FrontendCommon")`
- L35: `local priorInput = InputHandler`
- L36: `local priorShowHide = ShowHideHandler`
- L38: `local m_handler = nil`
- L39: `local m_currentTab = 1`
- L40: `local m_atTop = true`
- L41: `local m_atBottom = true`
- L44: `local m_pendingCursor = nil`
- L55: `local m_engineCategory = nil`
- L56: `local _vanillaOnCategory = OnCategory`
- L57: `OnCategory = function(idx)`
- L61: `local function joinNonEmpty(parts)`
- L76: `local function lookupDescription(tbl, key)`
- L87: `local function leaderCivText(v)`
- L104: `local function winnerText(v)`
- L114: `local function victoryTypeText(v)`
- L125: `local function mapTypeText(v)`
- L136: `local function eraTurnText(v)`
- L144: `local function statusBangText(v)`
- L151: `local function rankText(v)`
- L155: `local function scoreText(v)`
- L159: `local function rowLabel(v)`
- L183: `local function statusLabelText()`
- L197: `local function leaderboardPulldown()`
- L208: `local function refreshButton()`
- L218: `local function prevPageItem()`
- L229: `local function nextPageItem()`
- L249: `local function buildItemsForActiveTab()`
- L286: `local function applyPendingCursor(items, firstRowIdx, lastRowIdx)`
- L309: `local function rebuildActiveTab()`
- L334: `Events.Leaderboard_ScoresDownloaded.Add(function(_, atTop, atBottom) ... end)`
- L340: `local function makeTabSpec(name, idx)`
- L361: `m_handler = BaseMenu.install(ContextPtr, { ... })`

## Notes

- L57 `OnCategory`: Wraps the vanilla global to keep `m_engineCategory` in sync so `makeTabSpec.onActivate` can skip a redundant `RequestLeaderboardScores` call when the vanilla ShowHide already fired for the same category.
- L44 `m_pendingCursor`: Set to `"first"` or `"last"` before a pagination scroll so `applyPendingCursor` knows where to land the cursor after the async response rebuilds the list.
