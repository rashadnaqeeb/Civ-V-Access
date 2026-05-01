# tests/cursor_test.lua

Lines: 2202
Purpose: Tests the hex-grid cursor — per-section logic (owner identity, terrain shape, resource/improvement/route/unit/river sections, glance, economy, combat), composer integration, cursor state machine (init, move, jumpTo), audio cue mode gating, settler recommendations, city activate / diplomacy, and ranged-targeting targetability prefix.

## Top comment

```
-- Tests for the hex-grid cursor: per-section logic, composer integration,
-- cursor state machine. Each test exercises one failure mode the others
-- don't cover; sections that exist only to call game APIs (terrain name
-- lookup, route name lookup) are covered by integration via the glance
-- composer rather than per-section.
```

## Outline

```lua
local T = require("support")                          -- L7
local M = {}                                          -- L8

local function setup()                                -- L10
local function setupUnitAtTile(unitsOnTile)           -- L1152
local function setupCityGlue(plot)                    -- L1211
local function setupModeMove(mode)                    -- L1258
local function hasOp(calls, op)                       -- L1285
local function primeCursor(plot)                      -- L1703
local function installActivateStubs()                 -- L1721
local function makeCity(opts)                         -- L1755
local function makePlayer(opts)                       -- L1764
local function setupRangedScene(opts)                 -- L1939
local function selectArcher(attackerPlot, opts)       -- L1987
local function setupCityRangedScene(opts)             -- L2107

-- PlotSections / PlotComposers
function M.test_owner_identity_unclaimed()                                        -- L101
function M.test_owner_identity_civ_uses_short_description()                       -- L109
function M.test_owner_identity_city_shares_territory_identity_of_owning_civ()     -- L118
function M.test_city_section_skips_non_city()                                     -- L137
function M.test_terrainShape_natural_wonder_overrides_hills_mountain_and_terrain() -- L145
function M.test_terrainShape_mountain_without_wonder_speaks_alone()               -- L159
function M.test_terrainShape_single_terrain_feature_suppresses_terrain()          -- L170
function M.test_terrainShape_multi_terrain_feature_keeps_terrain()                -- L183
function M.test_terrainShape_ice_suppresses_terrain_despite_being_multi_terrain() -- L195
function M.test_terrainShape_hills_keeps_terrain_and_adds_hills_token()           -- L208
function M.test_terrainShape_single_terrain_feature_on_hills_keeps_hills()        -- L219
function M.test_terrainShape_lake_speaks_alone()                                  -- L231
function M.test_terrainShape_cueOnly_suppresses_base_terrain()                    -- L247
function M.test_terrainShape_cueOnly_suppresses_mountain()                        -- L258
function M.test_terrainShape_cueOnly_suppresses_lake()                            -- L268
function M.test_terrainShape_cueOnly_suppresses_non_wonder_feature()              -- L278
function M.test_terrainShape_cueOnly_keeps_hills()                                -- L292
function M.test_terrainShape_cueOnly_keeps_natural_wonder()                       -- L302
function M.test_resource_quantity_prefix_when_greater_than_one()                  -- L315
function M.test_resource_no_quantity_prefix_when_one()                            -- L322
function M.test_improvement_pillaged_suffix()                                     -- L331
function M.test_route_pillaged_suffix()                                           -- L338
function M.test_units_invisible_filter()                                          -- L347
function M.test_units_skips_cargo_and_air()                                       -- L357
function M.test_units_never_use_multiplayer_template()                            -- L368
function M.test_units_hp_suffix_when_damaged()                                    -- L384
function M.test_units_fortified_enemy_surfaces_status()                           -- L393
function M.test_units_sleeping_enemy_omits_status()                               -- L405
function M.test_units_embarked_prefix()                                           -- L422
function M.test_units_friendly_sleep_surfaces_status()                            -- L434
function M.test_river_self_edge_only()                                            -- L452
function M.test_river_neighbor_sourced_edge()                                     -- L462
function M.test_river_all_six_collapses()                                         -- L476
function M.test_river_edges_in_clockwise_order_from_ne()                          -- L496

-- Glance / economy / combat sections
function M.test_glance_fog_marker_and_no_units_when_fogged()                      -- L516
function M.test_glance_visible_omits_fog_marker()                                 -- L530
function M.test_economy_yields_skip_zeros()                                       -- L538
function M.test_economy_fresh_water_flag()                                        -- L548
function M.test_economy_barren_tile_speaks_no_yield()                             -- L554
function M.test_economy_reports_working_city_on_fogged_revealed_tile()            -- L569
function M.test_combat_defense_modifier_announced()                               -- L579
function M.test_combat_defense_modifier_announced_on_fogged_revealed_tile()       -- L585
function M.test_combat_zone_of_control_when_enemy_combat_unit_adjacent()          -- L597
function M.test_combat_no_zoc_when_enemy_is_civilian()                            -- L613
function M.test_combat_no_zoc_on_fogged_plot_even_with_adjacent_enemy()           -- L628

-- Cursor state machine
function M.test_cursor_init_uses_selected_unit_plot()                            -- L653
function M.test_cursor_init_falls_back_to_capital_when_no_unit_selected()         -- L675
function M.test_cursor_move_owner_prefix_fires_once_within_same_civ()            -- L695
function M.test_cursor_move_into_city_of_same_civ_does_not_refire_owner_prefix() -- L725
function M.test_cursor_move_always_announce_speaks_owner_on_every_step()          -- L766
function M.test_cursor_move_always_announce_silent_on_unclaimed()                 -- L800
function M.test_city_banner_drops_civ_adjective_when_always_announce_on()         -- L830
function M.test_city_banner_keeps_city_state_designator_when_always_announce_on() -- L844
function M.test_cursor_move_emits_edge_of_map_at_boundary()                       -- L862
function M.test_cursor_coordinates_at_capital_is_zero_zero()                     -- L887
function M.test_cursor_coordinates_three_east()                                   -- L907
function M.test_cursor_coordinates_pre_capital_returns_empty()                    -- L931
function M.test_cursor_move_preserves_announcer_silence_with_coords_on()          -- L955
function M.test_cursor_move_onto_unexplored_speaks_unexplored_every_step()        -- L993
function M.test_cursor_move_onto_fogged_tile_injects_fog_marker()                 -- L1026
function M.test_cursor_owner_diff_does_not_fire_across_unexplored_gap()           -- L1052

-- Tile cost / unit-at-tile / city info
function M.test_combat_tile_cost_flat_terrain_is_one_move()                      -- L1090
function M.test_combat_tile_cost_hills_adds_one()                                 -- L1097
function M.test_combat_tile_cost_feature_overrides_terrain()                      -- L1104
function M.test_combat_tile_cost_zero_feature_movement_does_not_override()        -- L1115
function M.test_combat_includes_route_name()                                      -- L1128
function M.test_combat_tile_cost_mountain_is_impassable()                         -- L1139
function M.test_cursor_unit_at_tile_prefers_military_over_civilian()              -- L1174
function M.test_cursor_unit_at_tile_falls_back_to_civilian_when_no_military()     -- L1183
function M.test_cursor_unit_at_tile_speaks_no_units_when_empty()                  -- L1190
function M.test_cursor_unit_at_tile_skips_invisible_cargo_and_air()               -- L1195
function M.test_cursor_city_identity_speaks_no_city_on_non_city_tile()            -- L1237
function M.test_cursor_city_info_keys_delegate_to_city_speech()                   -- L1244

-- AudioCueMode gating
function M.test_speech_mode_move_produces_no_audio_calls()                        -- L1294
function M.test_speech_plus_cue_mode_fires_both()                                 -- L1304
function M.test_cue_only_mode_suppresses_terrain_name_in_speech()                 -- L1315
function M.test_cue_only_mode_keeps_hills_in_speech()                             -- L1326
function M.test_cue_only_mode_keeps_units_in_speech()                             -- L1357
function M.test_cue_only_mode_speaks_natural_wonder()                             -- L1391
function M.test_cue_only_mode_speaks_unexplored()                                 -- L1424

-- Settler / worker recommendations
function M.test_recommendation_section_silent_without_globals()                   -- L1463
function M.test_recommendation_section_silent_when_options_hide()                 -- L1476
function M.test_recommendation_section_silent_without_first_city()                -- L1484
function M.test_recommendation_section_silent_on_unrecommended_plot()             -- L1492
function M.test_recommendation_section_silent_when_plot_unfoundable()             -- L1503
function M.test_recommendation_settler_prefix_and_reason_tokens()                 -- L1517
function M.test_recommendation_settler_luxury_beats_food()                        -- L1545
function M.test_recommendation_worker_emits_build_name_and_reason()               -- L1578
function M.test_recommendation_worker_strategic_resource_beats_yield()            -- L1606
function M.test_recommendation_worker_fires_when_settler_cant_found()             -- L1639
function M.test_recommendation_section_wires_into_glance()                        -- L1670

-- CursorActivate / diplomacy dispatch
function M.test_activate_silent_on_non_city_plot()                                -- L1784
function M.test_activate_own_city_opens_city_screen()                             -- L1793
function M.test_activate_own_puppet_fires_annex_popup()                           -- L1809
function M.test_activate_own_puppet_with_may_not_annex_opens_city_screen()        -- L1826
function M.test_activate_unmet_foreign_is_silent()                                -- L1843
function M.test_activate_met_minor_opens_city_screen()                            -- L1861
function M.test_activate_met_major_ai_opens_diplomacy()                           -- L1880
function M.test_activate_met_major_human_opens_deal_screen()                      -- L1906

-- Ranged targetability prefix
function M.test_targetability_unseen_when_los_blocked()                           -- L1998
function M.test_targetability_out_of_range_when_in_los_but_far()                  -- L2010
function M.test_targetability_no_prefix_when_in_los_and_in_range()                -- L2024
function M.test_targetability_air_unit_skips_los_check()                          -- L2036
function M.test_targetability_no_prefix_when_not_in_ranged_mode()                 -- L2050
function M.test_targetability_skips_attackers_own_plot()                          -- L2062
function M.test_targetability_skips_fogged_plot()                                 -- L2077
function M.test_targetability_speaks_prefix_alone_on_featureless_plot()           -- L2090
function M.test_targetability_city_ranged_los_required_speaks_unseen()            -- L2150
function M.test_targetability_city_ranged_indirect_fire_skips_los()               -- L2166
function M.test_activate_major_out_of_turn_is_silent()                            -- L2183

return M                                              -- L2202
```
