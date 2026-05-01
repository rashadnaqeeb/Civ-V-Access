# `src/dlc/UI/InGame/Popups/CivVAccess_LeagueOverviewRow.lua`

257 lines · Pure row formatters for the League Overview screen, providing no-cache helper functions for status pills, member rows, proposal rows, tooltip filtering, and vote-state labels.

## Header comment

```
-- Pure row formatters for the League Overview screen. No module state, no
-- caching of engine values; every call re-queries live league / player /
-- proposal data. Consumed by CivVAccess_LeagueOverviewAccess (status pill,
-- member rows, effects rows), CivVAccess_LeagueOverviewVote (proposal-row
-- announce in Vote mode), CivVAccess_LeagueOverviewProposal (slot picker
-- candidate rows). The formatters return strings ready for SpeechPipeline;
-- callers do not need to filter markup -- the pipeline runs TextFilter on
-- speak. Functions that compose multiple keys join with ", " for in-row
-- comma lists and ". " for sentence boundaries; trailing periods are added
-- by the row-builder, not by the formatter.
```

## Outline

- L12: `LeagueOverviewRow = {}`
- L14: `local kChoiceNone = -1`
- L20: `local function leaderOfCiv(playerID)`
- L31: `LeagueOverviewRow.leaderOfCiv = leaderOfCiv`
- L33: `function LeagueOverviewRow.leagueName(pLeague)`
- L42: `function LeagueOverviewRow.formatStatusPill(pLeague)`
- L67: `function LeagueOverviewRow.orderedMembers(pLeague)`
- L92: `local function delegatesPhrase(n)`
- L96: `LeagueOverviewRow._delegatesPhrase = delegatesPhrase`
- L101: `function LeagueOverviewRow.formatMember(pLeague, member, activePlayer)`
- L128: `function LeagueOverviewRow.formatResolutionName(pLeague, resolutionType, resolutionId, proposerDecision, direction)`
- L136: `local function proposerClause(playerID, activePlayer)`
- L146: `LeagueOverviewRow.proposerClause = proposerClause`
- L153: `function LeagueOverviewRow.formatProposal(pLeague, proposal, activePlayer, voteState)`
- L183: `function LeagueOverviewRow.formatProposalWithDetails(pLeague, proposal, activePlayer, voteState)`
- L196: `function LeagueOverviewRow.formatYesNoVoteState(votes)`
- L218: `function LeagueOverviewRow.filterTooltip(text)`
- L235: `function LeagueOverviewRow.appendTooltip(label, tooltip)`
- L249: `function LeagueOverviewRow.formatMajorCivVoteState(votes, choicePlayerID)`
- L257: `return LeagueOverviewRow`

## Notes

- L218 `filterTooltip`: Injects a period before `[NEWLINE]` tokens whose preceding character is not already terminal punctuation, so engine multi-line tooltips read as separate sentences rather than run-ons after TextFilter substitutes `[NEWLINE]` with a space.
- L235 `appendTooltip`: Collapses the tooltip into the label as a single spoken unit (no drill-in required), using `. ` as separator unless the label already ends in terminal punctuation.
- L67 `orderedMembers`: Sorts host-first, then by vote count descending, then by ascending player ID; the engine's own `GetLeagueMembers` returns members in raw player-ID order.
