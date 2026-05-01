# tests/scanner_search_filter_test.lua — 171 lines
Tests ScannerSearch: empty/nil returns nil, no-match nil, single-match isSearch flag, tier ordering within sub, taxonomy-ordered subs, all-sub aggregation, unknown category dropped, name collisions, and instance collapse.

## Header comment

```
-- ScannerSearch filter. Verifies tier-based inclusion/exclusion plus
-- the synthetic-snapshot shape: one top category with subs keyed by the
-- entries' original category, `all` first.
```

## Outline

```
  4  local T = require("support")
  5  local M = {}
  7  local function setup()
 21  local function mkPlot(x, y, idx)
 25  local function firstSearchCat(snap)
 30  local function namedSubs(snap)
 39  function M.test_empty_query_returns_nil()
 47  function M.test_no_match_returns_nil()
 58  function M.test_single_match_produces_search_category()
 68  function M.test_match_tier_orders_items_within_sub()
 86  function M.test_subs_ordered_by_taxonomy_not_match_order()
101  function M.test_all_sub_first_and_aggregates_everything()
119  function M.test_all_sub_shares_item_refs_with_named_subs()
132  function M.test_entries_with_unknown_category_dropped()
140  function M.test_same_name_shared_across_subs_produces_separate_items()
157  function M.test_multiple_instances_of_same_name_collapse_into_one_item()
171  return M
```
