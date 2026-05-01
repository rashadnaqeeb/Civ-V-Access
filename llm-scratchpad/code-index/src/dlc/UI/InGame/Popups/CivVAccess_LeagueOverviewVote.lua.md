# `src/dlc/UI/InGame/Popups/CivVAccess_LeagueOverviewVote.lua`

359 lines · Mod-side vote controller replacing the engine's VoteController, tracking signed per-proposal vote allocations and providing slider-kind vote row items with a major-civ picker sub-flow.

## Header comment

```
-- Mod-side replacement for the engine's VoteController / VoteYesNoController /
-- VoteMajorCivController (LeagueOverview.lua line 1057+). Tracks one entry
-- per votable proposal as a signed integer (positive = Yea, negative = Nay,
-- zero = abstain) for yes/no resolutions, or a non-negative integer plus a
-- chosen civ ID for major-civ resolutions. Pool accounting is identical to
-- the engine: `availableVotes = totalVotes - sum(abs(entry.votes))`. State
-- lives only in the controller table; commit fires the same Network.SendLeague*
-- calls the engine's CommitVotes path uses, with the same
-- TXT_KEY_LEAGUE_OVERVIEW_CONFIRM / _CONFIRM_MISSING_VOTES confirm copy.
--
-- Vote rows are built as kind="slider" items so BaseMenuCore's onLeft /
-- onRight call adjust(menu, dir, big). Step is +/- 1, big-step is +/- 5;
-- announce reads live entry state so reset / dirty-refresh / picker-commit
-- changes are reflected on the next move without an explicit setItems
-- rebuild. Major-civ rows whose choice is unset open the picker on Enter
-- (or Right / Left), matching the engine's VoteUp behavior of opening
-- ResolutionChoicePopup before the magnitude can change.
```

## Outline

- L19: `LeagueOverviewVote = {}`
- L21: `local kChoiceNone = -1`
- L22: `local STEP = 1`
- L23: `local BIG_STEP = 5`
- L24: `local PICKER_NAME = "LeagueOverviewMajorCivPicker"`
- L26: `local Controller = {}`
- L27: `Controller.__index = Controller`
- L29: `local function isMajorCivProposal(proposal)`
- L33: `local function buildVoterChoices(pLeague, resolutionType, activePlayer)`
- L58: `local function snapshotProposal(pLeague, raw, direction, onHold, activePlayer)`
- L74: `function LeagueOverviewVote.collectProposals(pLeague, activePlayer)`
- L97: `function LeagueOverviewVote.create(pLeague, activePlayer, leagueId, proposals)`
- L121: `function Controller:syncToCurrent(pLeague, proposals)`
- L163: `function Controller:availableVotes()`
- L171: `function Controller:reset()`
- L178: `function Controller:adjustYesNo(idx, delta)`
- L197: `function Controller:adjustMajorCiv(idx, delta)`
- L215: `function Controller:setMajorCivChoice(idx, choicePlayerID)`
- L231: `function Controller:commit(closeFn)`
- L252: `function Controller:hasUnspentDelegates()`
- L256: `function Controller:findEntryByProposalID(proposalID)`
- L271: `local function pushMajorCivPicker(controller, idx)`
- L310: `function LeagueOverviewVote.row(controller, idx, pLeague, activePlayer)`
- L359: `return LeagueOverviewVote`

## Notes

- L178 `adjustYesNo`: Accepts a signed delta and clamps to `[-absMax, absMax]` where `absMax = pool + abs(current)`, so the player can always swing their full personal allotment to either side regardless of what is already spent.
- L121 `syncToCurrent`: Resets all allocations if the pool shrank below the already-used total (e.g. city-state ally swap), mirroring the engine's controller re-initialization on dirty-refresh.
- L310 `LeagueOverviewVote.row`: Returns a table with `kind="slider"` and methods `isNavigable`, `isActivatable`, `announce`, `activate`, `adjust` - a custom item protocol consumed by BaseMenuCore's slider handling.
