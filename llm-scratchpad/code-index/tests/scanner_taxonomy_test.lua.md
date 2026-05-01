# tests/scanner_taxonomy_test.lua — 195 lines
Tests ScannerCore taxonomy invariants: fixed category order, CATEGORIES_BY_KEY consistency, per-category subcategory lists, label key shapes, and registerBackend validation.

## Header comment

```
-- ScannerCore taxonomy invariants. The four cycle axes read positions in
-- these ordered tables, and every backend writes its entries against the
-- keys declared here; a silent reorder (or a key rename) would desync
-- backends from Nav without any one test elsewhere catching it.
```

## Outline

```
  4  local T = require("support")
  5  local M = {}
  8  local function setup()
 13  local function catKeys()
 20  local function subKeys(catKey)
 31  function M.test_category_order_fixed()
 52  function M.test_categories_by_key_matches_list()
 63  function M.test_all_sub_not_listed_in_taxonomy()
 75  function M.test_unit_categories_share_role_subs()
 89  function M.test_cities_subs()
 98  function M.test_resources_subs_in_usage_order()
108  function M.test_improvements_subs_owner_order()
116  function M.test_special_subs()
123  function M.test_terrain_subs()
131  function M.test_recommendations_has_no_named_subs()
141  function M.test_waypoints_has_no_named_subs()
149  function M.test_all_category_labels_resolve_to_text_keys()
165  function M.test_register_backend_rejects_bad_shape()
178  function M.test_register_backend_accepts_complete_shape()
195  return M
```
