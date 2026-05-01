# `tests/surveyor_test.lua`

421 lines · Tests for `CivVAccess_SurveyorCore` covering radius grow/shrink clamping, yield/resource/terrain summation within radius, own-unit and enemy-unit filtering and ordering, city proximity ordering, and the unexplored-suffix appended when fogged plots exist in range.

## Header comment

```
-- Surveyor: per-scope logic, radius state, and the unexplored suffix.
-- HexGeom's plotsInRange inclusion math is covered in hexgeom_test; this
-- suite exercises the scope formatting and ordering layered on top.
```

## Outline

- L6: `local T = require("support")`
- L7: `local M = {}`
- L8: `local function setup()`
- L59: `local function installGrid(halfWidth, configure)`
- L86: `local function initCursorAtOrigin(plots)`
- L98: `function M.test_radius_initializes_to_one_and_grow_speaks_two()`
- L105: `function M.test_radius_grow_clamps_at_five_and_speaks_max()`
- L114: `function M.test_radius_shrink_clamps_at_one_and_speaks_min()`
- L127: `function M.test_yields_sums_non_zero_across_radius()`
- L141: `function M.test_yields_empty_fallback_when_every_plot_is_zero()`
- L149: `function M.test_resources_bucket_and_sort_by_count()`
- L178: `function M.test_resources_empty_fallback_when_none_revealed()`
- L186: `function M.test_terrain_buckets_forest_on_tundra_as_two_tokens()`
- L208: `function M.test_terrain_sorts_by_count_descending()`
- L233: `function M.test_own_units_lists_with_direction()`
- L249: `function M.test_own_units_orders_by_cube_distance_then_cw_rank()`
- L284: `function M.test_own_units_empty_fallback()`
- L291: `function M.test_enemy_units_filters_invisible_and_requires_visible_plot()`
- L326: `function M.test_enemy_units_empty_fallback()`
- L332: `function M.test_cities_orders_closest_first_regardless_of_owner()`
- L370: `function M.test_cities_empty_fallback()`
- L381: `function M.test_unexplored_suffix_appended_when_fogged_plots_in_range()`
- L392: `function M.test_unexplored_suffix_appended_even_on_empty_scope()`
- L410: `function M.test_unexplored_suffix_suppressed_when_zero()`
- L421: `return M`

## Notes

- L59 `installGrid`: Builds a 2D grid of `fakePlot` fixtures and installs a `Map.GetPlot` closure over it; the optional `configure(col, row, p)` callback can replace individual plots for targeted terrain/unit placement.
- L86 `initCursorAtOrigin`: Uses a `T.fakeUnit` staged at the origin plot and `UI.GetHeadSelectedUnit` to seed `Cursor.init()`, which is how the surveyor resolves its anchor position.
- L249 `test_own_units_orders_by_cube_distance_then_cw_rank`: Calls `SurveyorCore.grow()` to bump the radius to 2 so the ring-2 Archer is included, verifying that ordering considers both ring distance and clockwise direction rank within a ring.
