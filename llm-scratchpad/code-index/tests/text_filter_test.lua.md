# `tests/text_filter_test.lua`

304 lines · Tests for `CivVAccess_TextFilter` covering nil/empty/type-coercion, fast-path passthrough with whitespace normalization, every bracket-token category ([NEWLINE] pause insertion and sentence-ender trimming, COLOR/ENDCOLOR, slash-close tags, Civilopedia LINK markup, STYLE/TAB/BULLET/numeric tokens), the uppercase-only catch-all, icon registration and adjacent-word deduplication (case-insensitive, plural-suffix collapse, word-boundary guard), control characters, emdash replacement, colon-period artifact collapse, and composed multi-feature inputs.

## Header comment

```
-- TextFilter tests. Each test_* calls setup() first for isolation:
-- the filter module holds _iconMap in a closure, so we re-dofile to reset
-- before each test.
```

## Outline

- L6: `local T = require("support")`
- L7: `local M = {}`
- L9: `local function setup()`
- L14: `function M.test_nil_returns_empty_string()`
- L19: `function M.test_empty_string_returns_empty_string()`
- L23: `function M.test_number_coerced_via_tostring()`
- L29: `function M.test_plain_text_passes_through()`
- L33: `function M.test_fast_path_collapses_internal_whitespace()`
- L38: `function M.test_fast_path_trims_edges()`
- L48: `function M.test_newline_becomes_comma_pause()`
- L56: `function M.test_double_newline_collapses_to_single_separator()`
- L63: `function M.test_newline_after_sentence_ender_drops_comma()`
- L70: `function M.test_newline_after_question_mark_drops_comma()`
- L75: `function M.test_newline_at_edges_trimmed()`
- L81: `function M.test_league_vote_tally_reads_as_list()`
- L96: `function M.test_color_tokens_stripped()`
- L100: `function M.test_color_token_with_digits_stripped()`
- L108: `function M.test_slash_color_close_stripped()`
- L114: `function M.test_slash_red_close_stripped()`
- L123: `function M.test_link_markup_stripped_keeping_label()`
- L128: `function M.test_link_markup_with_multiword_label()`
- L132: `function M.test_style_token_stripped_by_catchall()`
- L137: `function M.test_tab_token_stripped()`
- L142: `function M.test_bullet_token_stripped()`
- L147: `function M.test_numeric_bracket_token_stripped()`
- L152: `function M.test_lowercase_bracket_content_preserved()`
- L162: `function M.test_registered_icon_substituted()`
- L167: `function M.test_unregistered_icon_stripped()`
- L171: `function M.test_registered_icon_wins_over_catchall()`
- L178: `function M.test_icon_dropped_when_spoken_form_follows()`
- L184: `function M.test_icon_dropped_when_spoken_form_precedes()`
- L189: `function M.test_icon_kept_when_adjacent_word_differs()`
- L194: `function M.test_icon_kept_when_adjacent_word_is_longer_prefix_match()`
- L201: `function M.test_icon_dedup_handles_trailing_punctuation()`
- L206: `function M.test_icon_dedup_is_case_insensitive()`
- L213: `function M.test_icon_dedup_collapses_trailing_plural_after()`
- L219: `function M.test_icon_dedup_collapses_trailing_plural_before()`
- L224: `function M.test_icon_dedup_still_collapses_singular()`
- L234: `function M.test_icon_dedup_does_not_eat_longer_word_with_s_prefix()`
- L241: `function M.test_control_chars_stripped()`
- L246: `function M.test_newline_and_tab_preserved_as_whitespace()`
- L251: `function M.test_null_byte_stripped()`
- L256: `function M.test_emdash_replaced_with_space()`
- L261: `function M.test_emdash_with_spaces_collapses()`
- L267: `function M.test_colon_period_artifact_collapses()`
- L273: `function M.test_composed_color_newline_icon_whitespace()`
- L280: `function M.test_composed_all_markup_emdash_control()`
- L304: `return M`

## Notes

- L9 `setup`: Re-`dofile`s `CivVAccess_TextFilter.lua` on each test because the module's `_iconMap` is a closure upvalue; without re-loading, icons registered in one test contaminate the next.
- L256 `test_emdash_replaced_with_space`: Uses raw UTF-8 bytes (`\226\128\148`) for the emdash literal because Lua 5.1 has no Unicode escape syntax.
