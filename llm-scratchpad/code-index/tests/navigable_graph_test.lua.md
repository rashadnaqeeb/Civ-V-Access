# tests/navigable_graph_test.lua — 233 lines
Tests NavigableGraph cursor: sibling-context rule, root-swap on navigateUp, cycle wrap semantics, and lambda-on-demand contract.

## Header comment

```
-- NavigableGraph cursor tests. Exercises the sibling-context rule, the
-- root-swap on navigateUp, cycle wrap semantics, and the lambda-on-demand
-- contract (the cursor re-calls lambdas for every neighbor lookup, so a
-- mutation between calls is visible to the next move).
```

## Outline

```
  4  local T = require("support")
  5  local M = {}
  8  local function setup()
 24  local function buildCursor(adj, rootsOrder)
 50  local function diamond()
 75  function M.test_new_requires_all_three_lambdas()
 90  function M.test_navigateDown_sets_current_and_seeds_siblings()
108  function M.test_navigateUp_from_leaf_seeds_parents_as_siblings()
121  function M.test_navigateDown_returns_nil_at_leaf()
130  function M.test_navigateUp_returns_nil_at_root()
141  function M.test_navigateUp_to_root_swaps_siblings_to_root_set()
157  function M.test_moveTo_drops_sibling_context()
171  function M.test_moveToWithSiblings_seeds_context()
181  function M.test_moveToWithSiblings_finds_cursor_index_in_list()
194  function M.test_introspection_reflects_structure()
212  function M.test_lambdas_are_called_per_move_not_cached()
233  return M
```
