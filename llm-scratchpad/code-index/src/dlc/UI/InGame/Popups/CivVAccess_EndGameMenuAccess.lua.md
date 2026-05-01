# `src/dlc/UI/InGame/Popups/CivVAccess_EndGameMenuAccess.lua`

195 lines · Accessibility wrapper for the EndGameMenu popup, providing three tabs (Info/actions, Ranking, and Replay) via BaseMenu's built-in tab mechanism.

## Header comment

```
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
```

## Outline

- L59: `local priorInput = InputHandler`
- L60: `local priorShowHide = ShowHideHandler`
- L62: `local m_handler = nil`
- L73: `local function buildRankingItems()`
- L99: `local infoTab = { ... }`
- L136: `local rankingTab = { ... }`
- L159: `local function buildReplayItems()`
- L175: `local replayTab = { ... }`
- L186: `m_handler = BaseMenu.install(ContextPtr, { ... })`

## Notes

- L145 `rankingTab.onActivate`: Calls `buildRankingItems()` each time the tab is opened (not at install time) because the active player does not exist during front-end load when the module first runs.
- L147 `m_handler.setItems(items, 2)`: The second argument `2` is the tab index, passed so `setItems` knows which tab's items to replace without switching the active tab.
