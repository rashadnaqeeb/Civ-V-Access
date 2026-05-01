# tests/scanner_navigation_test.lua — 612 lines
Tests ScannerNav state machine: jumpCursorTo, item/instance/category cycle wrap, rebuild identity preservation, ValidateEntry pruning, search entry/exit, and empty-snapshot handling.

## Header comment

```
(no block comment at file top; inline section comments delineate areas)
```

## Outline

```
  4  local T = require("support")
  5  local M = {}
    local _entries
    local _validator
    local function installStubBackend()
    local function mkPlot(...)
    local function mkEntry(...)
    local function setup()
    local function findMySubIdx(snap)
    local function catIdxByKey(key)
 98  function M.test_jumpCursorTo_speaks_here_when_already_at_target()
120  function M.test_jumpCursorTo_marks_prejump_and_jumps_when_target_differs()
133  function M.test_jumpCursorTo_skips_prejump_when_cursor_uninit()
148  function M.test_cycle_item_wraps_forward_and_back()
175  function M.test_cycle_instance_wraps()
194  function M.test_cycle_category_rebuilds_snapshot()
210  function M.test_cycle_item_rebuilds_and_preserves_identity()
244  function M.test_new_entry_appearing_does_not_move_cursor()
272  function M.test_identity_lost_resets_to_sentinel()
296  function M.test_rebuild_preserves_origin_across_identity_cycles()
322  function M.test_explicit_reorient_refreshes_origin()
353  function M.test_validate_returning_false_prunes_on_next_nav_read()
381  function M.test_validate_false_on_all_instances_wraps_up_to_empty()
407  function M.test_format_name_dispatched_through_backend()
423  function M.test_empty_snapshot_speaks_empty_token()
446  function M.test_initial_build_skips_empty_category_on_first_plain_cycle()
461  function M.test_initial_build_stays_when_starting_category_has_items()
470  function M.test_rebuild_preserves_empty_category_choice()
489  function M.test_cycle_category_skips_empty_forward()
499  function M.test_cycle_category_skips_empty_backward()
508  function M.test_cycle_category_all_empty_speaks_empty()
519  function M.test_cycle_subcategory_skips_empty()
533  function M.test_cycle_subcategory_all_empty_in_cat_speaks_empty()
552  function M.test_apply_search_builds_search_snapshot()
565  function M.test_apply_search_no_match_keeps_existing_snapshot()
577  function M.test_cycle_category_exits_search_snapshot()
592  function M.test_open_search_during_search_preserves_pre_search_catidx()
612  return M
```
