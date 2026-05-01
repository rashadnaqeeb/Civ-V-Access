# `tests/suite_unit_speech.lua`

1295 lines · Tests for `CivVAccess_UnitSpeech` covering selection direction prefix, embarked prefix, named-unit form, HP display, moves fraction (including road remainders and aircraft range/rebase), promotion-available toggle, the full status-cascade (garrison/automate/heal/alert/fortify/sleep/build/queued-mission), cascade first-match-wins, the info dump (ranged/melee/level/xp/upgrade/promotions/out-of-attacks/HP-last invariant), move result, self-plot confirm, combat result (attacker+defender damage, kills, unhurt sides, intercept clause, sweep/dogfight prefix, per-side max-HP kill threshold), nuclear strike, and combatant-name lookup helpers.

## Header comment

```
-- UnitSpeech formatter tests. Exercises the shapes listed in the plan:
-- selection direction prefix, embarked prefix, HP at max vs below-max,
-- always-on moves, promotion-available toggle, per-rung status cascade,
-- first-match wins when two rungs apply, and the info dump's skip-if-
-- zero + HP-last invariants.
```

## Outline

- L6: `local T = require("support")`
- L7: `local M = {}`
- L13: `local function mkUnit(opts)`
- L170: `local function setup()`
- L219: `function M.test_selection_zero_delta_no_direction_prefix()`
- L229: `function M.test_selection_non_zero_delta_leads_with_direction()`
- L240: `function M.test_selection_embarked_prefix_on_name()`
- L247: `function M.test_selection_not_embarked_no_prefix()`
- L255: `function M.test_selection_named_unit_wraps_civ_form_in_parens()`
- L266: `function M.test_selection_named_unit_embarked_combines_prefix_and_paren_form()`
- L275: `function M.test_selection_hp_at_max_no_hp_token()`
- L281: `function M.test_selection_hp_below_max_speaks_fraction()`
- L290: `function M.test_selection_moves_always_announced_full()`
- L297: `function M.test_selection_moves_always_announced_zero()`
- L309: `function M.test_selection_moves_announced_with_road_remainder()`
- L317: `function M.test_selection_moves_announced_with_half_move()`
- L325: `function M.test_selection_promotion_available_on()`
- L332: `function M.test_selection_promotion_available_off()`
- L340: `function M.test_selection_status_garrisoned()`
- L347: `function M.test_selection_status_automate_build()`
- L354: `function M.test_selection_status_automate_trade()`
- L361: `function M.test_selection_status_automate_explore()`
- L368: `function M.test_selection_status_heal()`
- L375: `function M.test_selection_status_alert()`
- L382: `function M.test_selection_status_fortified()`
- L389: `function M.test_selection_status_sleep()`
- L396: `function M.test_selection_status_building_with_turns()`
- L408: `function M.test_selection_status_queued_mission()`
- L418: `function M.test_selection_status_queued_mission_with_waypoints()`
- L437: `function M.test_selection_status_queued_mission_falls_back_when_no_waypoints()`
- L453: `function M.test_selection_status_building_wins_over_queued_mission()`
- L469: `function M.test_selection_status_garrison_wins_over_fortify()`
- L480: `function M.test_selection_status_heal_wins_over_fortify()`
- L493: `function M.test_info_skip_zero_ranged_on_melee()`
- L500: `function M.test_info_ranged_unit_speaks_range_and_strength()`
- L507: `function M.test_info_hp_always_last()`
- L523: `function M.test_info_upgrade_speaks_only_when_available()`
- L544: `function M.test_info_promotions_list_iterates_has_promotion()`
- L565: `function M.test_info_friendly_speaks_moves_fraction()`
- L572: `function M.test_info_enemy_speaks_moves_fraction()`
- L585: `function M.test_selection_aircraft_speaks_range_and_rebase_not_moves()`
- L593: `function M.test_info_aircraft_speaks_range_and_rebase_not_moves()`
- L603: `function M.test_info_aircraft_ranged_strength_drops_embedded_range()`
- L619: `function M.test_aircraft_rebase_multiplier_is_live()`
- L630: `function M.test_selection_land_unit_keeps_moves_fraction()`
- L644: `function M.test_selection_aircraft_zero_moves_speaks_out_of_moves()`
- L651: `function M.test_info_aircraft_zero_moves_speaks_out_of_moves()`
- L658: `function M.test_selection_aircraft_full_moves_omits_out_of_moves()`
- L665: `function M.test_selection_land_zero_moves_omits_out_of_moves()`
- L676: `function M.test_selection_enemy_aircraft_zero_moves_omits_out_of_moves()`
- L685: `function M.test_info_speaks_out_of_attacks_when_friendly_combat_with_moves()`
- L692: `function M.test_info_omits_out_of_attacks_when_unit_can_still_attack()`
- L699: `function M.test_info_omits_out_of_attacks_when_unit_has_zero_moves()`
- L707: `function M.test_info_omits_out_of_attacks_on_non_combat_unit()`
- L714: `function M.test_info_omits_out_of_attacks_on_enemy()`
- L721: `function M.test_selection_speaks_out_of_attacks_when_friendly_combat_with_moves()`
- L728: `function M.test_selection_omits_out_of_attacks_when_unit_has_zero_moves()`
- L740: `function M.test_info_enemy_speaks_exact_fraction()`
- L750: `function M.test_info_enemy_ranged_omits_range_distance()`
- L757: `function M.test_info_enemy_omits_level_xp()`
- L764: `function M.test_info_enemy_omits_upgrade()`
- L771: `function M.test_info_enemy_keeps_promotions()`
- L783: `function M.test_info_friendly_speaks_fortified_status()`
- L789: `function M.test_info_friendly_speaks_sleep_status()`
- L795: `function M.test_info_enemy_speaks_fortified()`
- L801: `function M.test_info_enemy_omits_sleep_status()`
- L808: `function M.test_info_enemy_omits_heal_status()`
- L814: `function M.test_info_embarked_prefixes_name()`
- L820: `function M.test_info_hp_stays_last_when_status_present()`
- L833: `function M.test_info_status_speaks_before_level_xp()`
- L848: `function M.test_move_result_clean_arrival()`
- L855: `function M.test_move_result_short_stop()`
- L862: `function M.test_move_result_short_stop_with_turns()`
- L870: `function M.test_move_result_short_stop_zero_turns_is_bare()`
- L882: `function M.test_self_plot_confirm_known_tokens()`
- L895: `function M.test_self_plot_confirm_build_start_uses_payload()`
- L901: `function M.test_self_plot_confirm_unknown_token_empty()`
- L935: `function M.test_combat_result_both_sides_take_damage()`
- L956: `function M.test_combat_result_kill_threshold_uses_event_max_hp()`
- L972: `function M.test_combat_result_defender_killed_appends_kill_line()`
- L991: `function M.test_combat_result_zero_damage_attacker_still_named_unhurt()`
- L1007: `function M.test_combat_result_zero_damage_defender_still_named_unhurt()`
- L1027: `function M.test_combat_result_intercepted_appends_intercept_clause()`
- L1045: `function M.test_combat_result_no_interceptor_no_intercept_clause()`
- L1063: `function M.test_combat_result_city_attacker_uses_bare_city_name()`
- L1083: `function M.test_combat_result_sweep_one_way_prepends_interception()`
- L1104: `function M.test_combat_result_sweep_dogfight_prepends_dogfight()`
- L1120: `function M.test_combat_result_normal_combat_no_kind_prefix()`
- L1140: `function M.test_combat_result_intercept_kill_keeps_kill_line_last()`
- L1164: `function M.test_nuclear_strike_full_payload()`
- L1187: `function M.test_nuclear_strike_destroyed_city_drops_pop_clause()`
- L1200: `function M.test_nuclear_strike_no_targets_announces_inert()`
- L1213: `function M.test_nuclear_strike_units_only_no_target_city()`
- L1233: `function M.test_combatant_name_resolves_via_player_lookup()`
- L1245: `function M.test_combatant_name_returns_empty_when_unit_gone()`
- L1251: `function M.test_combatant_name_returns_empty_when_player_missing()`
- L1263: `function M.test_city_combatant_name_resolves_via_player_lookup()`
- L1279: `function M.test_city_combatant_name_returns_empty_when_city_gone()`
- L1285: `function M.test_city_combatant_name_returns_empty_when_player_missing()`
- L1295: `return M`

## Notes

- L139 `mkUnit`: The `CanUpgradeRightNow` stub asserts `type(bOnlyTestVisible) == "number"` to mirror the engine's strictness, causing a test failure if the production caller passes a Lua boolean instead.
- L418 `test_selection_status_queued_mission_with_waypoints`: Monkey-patches `Waypoints.finalAndTurns` and sets `UI.GetHeadSelectedUnit` to the test unit to exercise the engine-fork path where the waypoint destination and turn count are embedded in the queued-move rung.
- L523 `test_info_upgrade_speaks_only_when_available`: Calls `setup()` three times within the same test function to isolate the three sub-cases (no upgrade path, upgrade locked, upgrade available).
