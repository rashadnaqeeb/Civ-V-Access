# `src/dlc/UI/InGame/Popups/CivVAccess_LeagueProjectPopupAccess.lua`

161 lines · Accessibility wrapper for the BUTTONPOPUP_LEAGUE_PROJECT_COMPLETED popup, presenting World Congress project results as a navigable ranked contributor list.

## Header comment

```
-- LeagueProjectPopup accessibility. BUTTONPOPUP_LEAGUE_PROJECT_COMPLETED pops
-- when a World Congress project (World's Fair, International Games, ISS)
-- finishes. The screen shows project description + a per-major-civ ranking
-- (rank, leader name, contribution points, reward tier earned).
--
-- The contributor list can run all 22 majors in a full game, so each entry
-- is exposed as its own navigable Text item rather than concatenated into
-- one preamble. Preamble is the project header + description; items are the
-- contributor entries followed by Close.
--
-- Capture strategy: monkey-patch the base AddPlayerEntry global, which base
-- UpdateAll calls per major in sorted order. We piggyback on that call so
-- our list is already in the same rank order base displays without re-doing
-- the contribution-tier sort. base UpdateAll runs synchronously inside the
-- SerialEventGameMessagePopup dispatch, so by the time ShowHide(false)
-- fires the captured list is complete.
```

## Outline

- L40: `local priorInput = InputHandler`
- L41: `local priorShowHide = ShowHideHandler`
- L43: `local capturedEntries = {}`
- L44: `local capturedLeague = nil`
- L45: `local capturedProject = nil`
- L49: `Events.SerialEventGameMessagePopup.Add(...)`
- L56: `local baseAddPlayerEntry = AddPlayerEntry`
- L57: `AddPlayerEntry = function(iPlayerID, iScore, iTier, iRank)`
- L73: `local function playerNameFor(iPlayerID)`
- L85: `local function tierLabel(iTier)`
- L98: `local function buildPreamble()`
- L115: `local function rewardTooltipFor(iTier)`
- L129: `local function buildItems()`
- L150: `BaseMenu.install(ContextPtr, { ... })`

## Notes

- L57 `AddPlayerEntry`: Monkey-patches the base global; resets `capturedEntries` when `iRank == 1` to handle the engine re-firing the popup during boot recovery.
- L115 `rewardTooltipFor`: Returns cumulative reward detail for tiers 1..iTier in descending order, matching the base tooltip's ordering.
