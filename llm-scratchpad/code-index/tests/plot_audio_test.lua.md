# tests/plot_audio_test.lua — 338 lines
Tests PlotAudio.cueForPlot bed/stinger/fog mapping and emit dispatch ordering, plus loadAll idempotency.

## Header comment

```
-- Tests for the PlotAudio mapping + dispatch. cueForPlot is pure (plot
-- handle in, cue table out) so most tests just assert the returned shape.
-- emit tests use the capturing audio stub from run.lua to observe call
-- order and arguments.
```

## Outline

```
  4  local T = require("support")
  5  local M = {}
  8  local function setup()
 26  local function feature(id, typeName, extra)
 37  local function terrain(id, typeName)
    local function opNames(calls)
 44  function M.test_cueForPlot_unrevealed_returns_nil()
 55  function M.test_cueForPlot_mountain_outranks_feature_and_terrain()
 66  function M.test_cueForPlot_promotable_feature_replaces_terrain_bed()
 77  function M.test_cueForPlot_natural_wonder_does_not_promote_to_feature_bed()
 90  function M.test_cueForPlot_natural_wonder_on_flat_falls_through_to_terrain()
101  function M.test_cueForPlot_stinger_feature_does_not_promote_to_bed()
114  function M.test_cueForPlot_terrain_bed_grass()
121  function M.test_cueForPlot_coast_and_ocean_collapse_to_water_bed()
133  function M.test_cueForPlot_lake_resolves_to_water_even_without_known_terrain()
142  function M.test_cueForPlot_ice_feature_replaces_water_bed()
154  function M.test_cueForPlot_fog_true_when_revealed_but_not_visible()
161  function M.test_cueForPlot_fog_false_when_fully_visible()
170  function M.test_cueForPlot_forest_stinger_fires_independently_of_terrain()
182  function M.test_cueForPlot_fallout_stinger_on_any_terrain()
192  function M.test_cueForPlot_road_stinger_when_route_present()
204  function M.test_cueForPlot_forest_and_road_coexist_in_stingers()
222  function M.test_cueForPlot_no_route_means_no_road_stinger()
241  function M.test_emit_cancel_all_fires_before_any_play()
257  function M.test_emit_plays_bed_then_stingers_delayed()
276  function M.test_emit_plays_fog_alongside_bed_at_t_zero()
293  function M.test_emit_on_unrevealed_plot_only_cancels()
309  function M.test_loadAll_is_idempotent_across_reentry()
320  function M.test_loadAll_sets_fog_to_half_volume()
338  return M
```
