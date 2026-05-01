# tests/message_buffer_test.lua — 344 lines
Tests MessageBuffer append, single-step navigation, end-jumps, edge re-speak, filter cycling, reset-to-newest on filter change, empty-buffer handling, and reset-on-boot.

## Header comment

```
-- MessageBuffer tests. Covers append (with cap eviction and the position
-- shift that follows it), single-step navigation, end-jumps, edge re-
-- speak when running off either end, filter cycling that skips empty
-- categories and the reset-to-newest contract that follows a filter
-- change, the empty-buffer announcement on every input, and reset-on-
-- boot. Speech goes through SpeechPipeline's _speakAction seam so each
-- test asserts on the exact text + interrupt the user would hear.
```

## Outline

```
  4  local T = require("support")
  5  local M = {}
 11  local spoken
 13  local function setup()
 42  local function lastSpoken()
 49  function M.test_append_records_text_and_category()
 61  function M.test_append_rejects_unknown_category()
 71  function M.test_append_skips_empty_text()
 81  function M.test_prev_from_uninitialized_jumps_to_newest()
 91  function M.test_prev_walks_backward_through_entries()
104  function M.test_prev_at_oldest_repeats_current_entry()
118  function M.test_next_from_uninitialized_enters_at_newest()
130  function M.test_next_walks_forward_after_prev()
148  function M.test_prev_on_empty_buffer_speaks_empty_marker()
154  function M.test_next_on_empty_buffer_speaks_empty_marker()
162  function M.test_jumpFirst_lands_on_oldest_matching()
173  function M.test_jumpLast_lands_on_newest_matching()
181  function M.test_end_jumps_on_empty_speak_empty_marker()
191  function M.test_filter_forward_cycles_and_announces_with_newest()
203  function M.test_filter_forward_skips_empty_categories()
216  function M.test_filter_backward_skips_empty_categories()
229  function M.test_filter_cycle_on_empty_buffer_speaks_only_empty_marker()
244  function M.test_filter_change_resets_position_to_newest()
263  function M.test_navigation_within_filter_skips_non_matching()
279  function M.test_cap_eviction_drops_oldest()
292  function M.test_cap_eviction_shifts_position_to_track_same_entry()
306  function M.test_cap_eviction_clamps_when_user_was_on_evicted_entry()
321  function M.test_install_listeners_clears_buffer()
335  function M.test_bindings_cover_all_six_chords()
344  return M
```
