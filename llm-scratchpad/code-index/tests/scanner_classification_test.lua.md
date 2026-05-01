# tests/scanner_classification_test.lua — 854 lines
Tests per-backend bucket decisions for units, resources, improvements, special, terrain, and recommendations scanners.

## Header comment

```
-- Per-backend bucket-decision tests. Each backend converts flag/enum
-- inputs (Domain, UnitCombat, ResourceUsage, owner stance, NaturalWonder,
-- goody-hut improvement constant) into a subcategory string; a silent
-- misbucket here is one of the few scanner bugs that no other suite
-- would catch because it still produces well-formed entries, just in
-- the wrong slot.
```

## Outline

```
  4  local T = require("support")
  5  local M = {}
 11  local function resetScanner()
 16  local function loadModule(path)
 20  local function mapFromPlots(plots)
 29  local function setup()
    local function loadUnitsBackend()
    local function makeUnit(opts)
    local function makePlotAt(x, y, idx, opts)
    local function installPlayer(...)
    local function runUnitsScan()
    local function classifyLandCombat(...)
    local function loadResourcesBackend()
    local function loadImprovementsBackend()
    local function impPlot(...)
    local function loadSpecialBackend()
    local function loadTerrainBackend()
    local function subsFromEntries(entries)
    local function loadRecommendationsBackend()
    local installRecGlobals
    local installRecPlayer
170  function M.test_unit_role_melee_gun_armor_recon_all_melee()
185  function M.test_unit_role_archer_is_ranged()
191  function M.test_unit_role_siege()
197  function M.test_unit_role_mounted_and_helicopter_share_sub()
206  function M.test_unit_role_naval_from_domain_not_combat()
221  function M.test_unit_role_air_from_domain()
232  function M.test_unit_role_civilian_when_not_combat()
243  function M.test_unit_role_great_people_beats_civilian()
257  function M.test_unit_owner_category_routes_by_team_stance()
282  function M.test_unit_barbarian_routes_to_enemy_with_barbarians_sub()
297  function M.test_unit_invisible_unit_excluded()
317  function M.test_resource_usage_to_subcategory()
340  function M.test_resource_neg_one_skipped()
351  function M.test_resource_unrevealed_plot_skipped()
384  function M.test_improvement_owner_routes_to_three_subs()
417  function M.test_improvement_unowned_routes_neutral()
434  function M.test_improvement_skips_barb_camp_and_goody_hut()
456  function M.test_special_natural_wonder_by_flag()
476  function M.test_special_ancient_ruin_by_goody_hut_improvement()
488  function M.test_special_unrevealed_plots_skipped()
515  function M.test_terrain_plain_plot_emits_base_only()
529  function M.test_terrain_feature_adds_feature_entry()
542  function M.test_terrain_hills_emit_elevation()
555  function M.test_terrain_mountain_emits_elevation()
570  function M.test_terrain_forested_hill_triple_emits()
588  function M.test_terrain_validate_feature_goes_stale_when_chopped()
611  function M.test_terrain_validate_returns_true_when_state_unchanged()
639  function M.test_terrain_unrevealed_plot_skipped()
665  function M.test_recs_empty_when_options_hide()
674  function M.test_recs_empty_when_no_selection()
687  function M.test_recs_settler_needs_first_city()
699  function M.test_recs_settler_emits_city_site_entries()
717  function M.test_recs_settler_skips_unfoundable_plots()
738  function M.test_recs_worker_emits_build_description()
772  function M.test_recs_validate_drops_when_selection_lost()
793  function M.test_recs_validate_drops_when_plot_leaves_list()
815  function M.test_recs_validate_worker_drops_on_build_change()
840  function M.test_recs_validate_keeps_live_entry()
854  return M
```
