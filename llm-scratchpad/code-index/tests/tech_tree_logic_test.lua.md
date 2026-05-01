# `tests/tech_tree_logic_test.lua`

926 lines · Tests for `CivVAccess_TechTreeLogic` (and `CivVAccess_ChooseTechLogic`) covering graph construction (roots, children/parents, GridY sort), the five status keys, landing-speech composition, queue-row building and speech, mode detection (normal/free/stealing), commit eligibility per mode, initial-cursor fallback chain, search corpus shape, `seedCursorSiblings`, grid/column neighbor navigation, and era boundary prefix logic.

## Header comment

```
-- TechTreeLogic tests. Exercises graph construction from a stubbed
-- Technology_PrereqTechs table, status-token determination across the
-- five game states, queue-row composition, preamble mode switches,
-- commit eligibility rejections per mode, and the initial-cursor
-- fallback chain.
```

## Outline

- L6: `local T = require("support")`
- L7: `local M = {}`
- L13: `local function tech(id, typeName, gridY, description)`
- L17: `local function installTechDB(techs, prereqs)`
- L50: `local function fakePlayer(opts)`
- L104: `local function fakeTeam(opts)`
- L121: `local function setup()`
- L175: `local function techs3()`
- L190: `function M.test_buildGraph_roots_exclude_techs_with_prereqs()`
- L198: `function M.test_buildGraph_children_and_parents_resolve()`
- L205: `function M.test_buildGraph_sorts_children_by_gridY_then_ID()`
- L229: `function M.test_statusKey_researched_wins()`
- L237: `function M.test_statusKey_current_precedes_available()`
- L246: `function M.test_statusKey_available_when_canResearch()`
- L253: `function M.test_statusKey_unavailable_when_only_canEver()`
- L261: `function M.test_statusKey_locked_when_not_canEver()`
- L270: `function M.test_landing_current_shows_turns_without_queue_slot()`
- L289: `function M.test_landing_queued_shows_slot_number()`
- L305: `function M.test_landing_researched_suppresses_turns()`
- L315: `function M.test_landing_zero_science_suppresses_turns()`
- L326: `function M.test_queue_rows_sorted_by_position()`
- L340: `function M.test_queue_rows_empty_when_nothing_queued()`
- L346: `function M.test_queue_row_speech_current_vs_queued()`
- L378: `function M.test_currentMode_stealing_beats_free()`
- L385: `function M.test_currentMode_free_beats_normal()`
- L391: `function M.test_currentMode_normal_by_default()`
- L399: `function M.test_commit_rejects_researched_tech()`
- L407: `function M.test_commit_rejects_locked_tech()`
- L415: `function M.test_commit_allows_prereq_gap_in_normal_mode()`
- L432: `function M.test_commit_accepts_available_tech_in_normal()`
- L440: `function M.test_commit_free_requires_canResearchForFree()`
- L454: `function M.test_commit_stealing_requires_opponent_has_tech()`
- L466: `function M.test_commit_stealing_accepts_when_opponent_has_tech()`
- L475: `function M.test_initialCursor_prefers_current_research()`
- L484: `function M.test_initialCursor_falls_back_to_first_canResearch()`
- L496: `function M.test_initialCursor_falls_back_to_first_root_when_nothing_canResearch()`
- L504: `function M.test_searchCorpus_one_entry_per_tech()`
- L511: `function M.test_searchCorpus_label_is_name_only_when_prose_empty()`
- L524: `function M.test_searchCorpus_label_joins_name_and_unlocks_prose()`
- L546: `local function loadNavigableGraph()`
- L551: `function M.test_seedCursorSiblings_uses_roots_when_landing_is_a_root()`
- L575: `local function gridTech(id, typeName, gridX, gridY, era)`
- L582: `local function installGridTechs(techs)`
- L585: `function M.test_buildGrid_byColumn_sorted_by_gridY()`
- L597: `function M.test_gridNeighbor_row_right_steps_exactly_one_column()`
- L614: `function M.test_gridNeighbor_row_left_steps_exactly_one_column()`
- L628: `function M.test_gridNeighbor_row_snaps_to_nearest_gridY()`
- L641: `function M.test_gridNeighbor_row_intended_gridY_overrides_current_row()`
- L659: `function M.test_gridNeighbor_row_falls_back_to_cursor_gridY_when_intended_nil()`
- L675: `function M.test_gridNeighbor_row_ties_prefer_smaller_gridY()`
- L689: `function M.test_gridNeighbor_row_silent_when_adjacent_column_empty()`
- L698: `function M.test_gridNeighbor_column_down_finds_next_tech_at_same_gridX()`
- L710: `function M.test_gridNeighbor_column_up_finds_prior_tech()`
- L718: `function M.test_gridNeighbor_returns_nil_at_row_edge()`
- L730: `function M.test_gridNeighbor_returns_nil_at_column_edge()`
- L740: `function M.test_gridNeighbor_returns_nil_when_column_unpopulated()`
- L749: `local function installEras()`
- L806: `function M.test_eraID_returns_techs_era_key()`
- L813: `function M.test_eraID_returns_nil_for_missing_tech()`
- L817: `function M.test_eraName_returns_localized_era_description()`
- L824: `function M.test_eraPrefix_announces_when_era_changes()`
- L832: `function M.test_eraPrefix_silent_when_era_unchanged()`
- L840: `function M.test_eraPrefix_announces_on_first_landing_with_nil_prev()`
- L847: `function M.test_eraPrefix_silent_when_tech_has_no_era()`
- L856: `function M.test_eraPrefix_advances_prev_when_era_known_but_name_missing()`
- L868: `function M.test_seedCursorSiblings_uses_first_parents_children_for_non_root()`
- L926: `return M`

## Notes

- L546 `loadNavigableGraph`: A local helper that `dofile`s `CivVAccess_NavigableGraph.lua` and clears the global first; called only by the `seedCursorSiblings` tests that need a live `NavigableGraph.new`.
- L749 `installEras`: Also patches `Locale.ConvertTextKey` to map era description keys (e.g. `TXT_KEY_ERA_ANCIENT`) to display strings, because era names go through vanilla game keys rather than the CIVVACCESS namespace.
- L415 `test_commit_allows_prereq_gap_in_normal_mode`: Verifies that `commitEligibility` does NOT gate on `CanResearch` in normal mode (the engine auto-queues prereqs), asserting that only `HasTech` and `!CanEverResearch` are hard rejects.
