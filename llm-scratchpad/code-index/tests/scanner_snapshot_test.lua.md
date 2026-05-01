# tests/scanner_snapshot_test.lua — 226 lines
Tests ScannerSnap construction, sort, shared-reference invariant of the all-sub, and pruneInstance remove/keep behavior.

## Header comment

```
-- ScannerSnap construction, sort, and prune-by-instance. Covers the
-- `all` sub's shared-reference invariant (the only place in the scanner
-- pipeline where one item object intentionally lives in two containers).
```

## Outline

```
  4  local T = require("support")
  5  local M = {}
  7  local function setup()
 15  local function mkPlot(x, y, idx)
 21  local function findCat(snap, key)
 30  local function findSub(cat, key)
 40  function M.test_build_produces_all_taxonomy_categories()
 51  function M.test_all_sub_at_index_1_every_category()
 60  function M.test_items_within_sub_sort_by_nearest_instance_distance()
 75  function M.test_instances_within_item_sort_by_distance_then_plotindex()
 94  function M.test_all_sub_shares_item_ref_with_named_sub()
107  function M.test_prune_instance_removes_item_from_both_subs_when_empty()
134  function M.test_prune_instance_keeps_item_when_other_instances_remain()
163  function M.test_all_direct_category_lands_item_in_all_once()
181  function M.test_all_direct_category_prune_removes_from_all()
200  function M.test_unknown_category_logged_and_dropped()
215  function M.test_unresolved_plotindex_logged_and_dropped()
226  return M
```
