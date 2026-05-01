# `tests/type_ahead_test.lua`

556 lines · Tests for `CivVAccess_TypeAheadSearch` covering the six matchTier levels (start-whole-word, start-prefix, mid-whole-word, mid-prefix, substring, multi-token, no-match), search results (word-start, mid-word, case-insensitive, multi-char narrowing), repeat-letter cycling in tiers 0-1, backspace, navigation wrap, jump first/last, no-match behavior, full tier-order sweep, within-tier position and length sort, length-beats-position, multi-token space queries, trailing-space ignore, multi-token abbreviation, name-vs-description ranking, name-length sort (not full label), interface wrappers (`handleChar`, `handleKey` backspace/nav/inactive), and the optional `groupOf` hook (group-0 over group-1 across tiers, group ordering over in-segment position, nil group treated as 0, `handleChar` end-to-end with groupOf).

## Header comment

```
-- TypeAheadSearch tests. Cover tier semantics, sort rules, and
-- single-letter cycling against the shared TypeAheadSearch module.
```

## Outline

- L4: `local T = require("support")`
- L5: `local M = {}`
- L7: `local speaks`
- L9: `local function setup()`
- L38: `local SEARCH_ITEMS = { ... }`
- L40: `local function labelAt(i)`
- L44: `local function searchable(items)`
- L59: `function M.test_match_tier_start_whole_word()`
- L66: `function M.test_match_tier_start_prefix()`
- L73: `function M.test_match_tier_mid_whole_word()`
- L80: `function M.test_match_tier_mid_prefix()`
- L87: `function M.test_match_tier_substring()`
- L94: `function M.test_match_tier_no_match()`
- L101: `function M.test_match_tier_multi_token_abbreviation()`
- L108: `function M.test_match_tier_multi_token_order_required()`
- L114: `function M.test_match_tier_multi_token_cross_segment_rejected()`
- L129: `function M.test_search_word_start_match()`
- L139: `function M.test_search_mid_word_match()`
- L154: `function M.test_search_case_insensitive()`
- L162: `function M.test_search_multi_char_narrowing()`
- L180: `function M.test_repeat_letter_cycles_in_tiers_0_1()`
- L198: `function M.test_backspace_widens_results()`
- L212: `function M.test_navigate_wraps()`
- L223: `function M.test_jump_first_last()`
- L236: `function M.test_no_match_keeps_search_active()`
- L247: `function M.test_tier_ordering_full_sweep()`
- L270: `function M.test_within_tier_position_sort()`
- L285: `function M.test_within_tier_name_length_tiebreaker()`
- L302: `function M.test_length_beats_position_within_tier()`
- L320: `function M.test_space_multi_word()`
- L331: `function M.test_trailing_space_ignored()`
- L342: `function M.test_multi_token_abbreviation()`
- L358: `function M.test_name_match_beats_description_match()`
- L375: `function M.test_sorts_by_name_length_not_full_label()`
- L394: `function M.test_handle_char_delegates_to_search()`
- L414: `function M.test_handle_key_backspace_clears_on_empty_buffer()`
- L428: `function M.test_handle_key_up_down_navigate_when_active()`
- L449: `function M.test_handle_key_inactive_without_buffer_ignored()`
- L465: `local function searchableWithGroup(items, groupFn)`
- L478: `function M.test_group_zero_ranks_above_group_one_across_tiers()`
- L496: `function M.test_group_ordering_outranks_in_segment()`
- L511: `function M.test_nil_group_of_preserves_default_ordering()`
- L526: `function M.test_group_returning_nil_treated_as_zero()`
- L541: `function M.test_handle_char_passes_group_of_from_searchable()`
- L556: `return M`

## Notes

- L38 `SEARCH_ITEMS`: Five fixed labels (Apple, Apricot, Banana, Blue Cheese, Cherry) chosen to exercise all tier transitions with predictable expected indices; comments track which item lands in which tier for a given query.
- L180 `test_repeat_letter_cycles_in_tiers_0_1`: Typing the same letter three times cycles the selection through start-of-string matches only (Apple, Apricot, wrap to Apple), not into the substring tier (Banana); also asserts that `buffer()` collapses back to the single letter during cycling.
- L114 `test_match_tier_multi_token_cross_segment_rejected`: Accepts either tier -1 or tier 5 with `pos > firstComma`; the assertion is written as a compound truthy because two different correct implementations are both acceptable.
- L465 `searchableWithGroup`: Local fixture factory used only by the `groupOf` suite below it; the `groupOf` field maps item indices to integer priority groups (lower = higher priority).
