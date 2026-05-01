# `src/dlc/UI/InGame/Popups/CivVAccess_VoteResultsPopupAccess.lua`

143 lines · Accessibility wrapper for the BUTTONPOPUP_VOTE_RESULTS World Leader ballot results popup, capturing team entries via monkey-patching AddTeamEntry and presenting them as ranked Text items.

## Header comment

```
-- VoteResultsPopup accessibility. BUTTONPOPUP_VOTE_RESULTS pops after the
-- World Leader (Diplomatic Victory) ballot resolves. The screen lists every
-- team in vote order, showing each team's name, the team they voted for, and
-- the votes that team received.
--
-- The full ballot can include 22 majors plus city-states, so each team is
-- exposed as its own navigable Text item rather than one long preamble.
-- Preamble carries the screen header (votes-needed-to-win, or the
-- preliminary-election variant when popupInfo.Option1 is true).
--
-- Capture strategy: monkey-patch the base AddTeamEntry global so we ride
-- the same sorted iteration base does (table.sort by votes, ties broken in
-- favor of majors). Base UpdateAll runs synchronously inside the
-- SerialEventGameMessagePopup dispatch, so by the time ShowHide(false)
-- fires the captured list is complete.
```

## Outline

- L39: `local priorInput = InputHandler`
- L40: `local priorShowHide = ShowHideHandler`
- L42: `local capturedEntries = {}`
- L43: `local capturedTeamGame = false`
- L45: `local baseAddTeamEntry = AddTeamEntry`
- L46: `AddTeamEntry = function(iTeam, iVotes, iRank)`
- L59: `local function teamLabel(iTeam, asVoter)`
- L81: `local function voteCastLabel(iTeam)`
- L91: `local function buildPreamble()`
- L111: `local function buildItems()`
- L132: `BaseMenu.install(ContextPtr, { ... })`

## Notes

- L46 `AddTeamEntry`: Monkey-patches the base global; `capturedTeamGame` is snapshotted from `g_bIsTeamGame` on rank 1 so later calls to `teamLabel` see the correct team-game flag even if the global changes.
- L59 `teamLabel`: The `asVoter` parameter changes "Your Team" to "You" for the vote-cast column in team games, matching the engine's own label distinction.
