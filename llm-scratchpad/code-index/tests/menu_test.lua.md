# tests/menu_test.lua — 4276 lines
Exhaustive tests for BaseMenu and BaseMenuItems: navigation, all item kinds, click-ack gating, tooltips, tabs, install contract, preamble, refresh, edit mode, groups/nested menus, type-ahead search, Choice.selectedFn, per-tab hooks, Ctrl+I pedia dispatch, VirtualSlider, and VirtualToggle.

## Header comment

```
-- BaseMenu + BaseMenuItems tests. HandlerStack, InputRouter, Nav, TickPump,
-- PullDownProbe, BaseMenu, and BaseMenuItems are loaded for real. Widget controls
-- come from the Polyfill factories which mirror engine semantics (SetValue
-- clamps, SetCheck flips, etc.). SpeechPipeline._speakAction is redirected
-- so suites can assert announcement text + interrupt flag in order.
```

## Outline

```
  4  local T = require("support")
  5  local M = {}
  8  local warns, errors
  9  local speaks
 10  local sounds
 11  local _test_pd_mt = nil
 14  local function resetPDMetatable()
 31  local function setup()
    local function setCtrls(names)
    local function populateControls(map)
    local function ctrlState   -- upvalue table controlling per-control IsHidden/IsDisabled
    local function buttonItem(name, label)
    local function buttonSpec(names)
    local function groupItem(label, items)
    local function makeContextPtr()
    local function makePullDownWithMetatable()
    local function patchProbeFromPullDown(pd)
    local WM_KEYDOWN = 256
    local WM_SYSKEYDOWN = 260
    local MOD_CTRL = 2
    local MOD_ALT = 4

-- Factory validation -------------------------------------------------------
164  function M.test_create_requires_name_and_displayName()
171  function M.test_create_requires_items_or_tabs()
178  function M.test_create_shape_matches_handler_contract()
197  function M.test_missing_control_logs_warn_and_keeps_item()

-- Button navigation --------------------------------------------------------
224  function M.test_down_moves_to_next_item()
233  function M.test_up_wraps_from_top_to_bottom()
242  function M.test_down_wraps_from_bottom_to_top()
253  function M.test_hidden_items_are_skipped()
263  function M.test_all_hidden_navigation_is_noop()
277  function M.test_home_jumps_to_first_navigable()
288  function M.test_end_jumps_to_last_navigable()
298  function M.test_enter_fires_activate()
318  function M.test_space_also_fires_activate()
340  function M.test_enter_activate_error_caught_and_logged()
362  function M.test_enter_plays_click_sound()
376  function M.test_enter_on_hidden_current_logs_warn_no_crash()
401  function M.test_post_activate_revalidation_advances_on_hidden_flip()

-- Disabled items -----------------------------------------------------------
429  function M.test_navigation_walks_disabled_items()
441  function M.test_enter_on_disabled_is_noop_no_activate_no_sound()
469  function M.test_onActivate_first_item_disabled_announces_with_suffix()

-- Checkbox -----------------------------------------------------------------
480  function M.test_checkbox_enter_toggles_and_announces_on()
496  function M.test_checkbox_space_toggles_back_and_announces_off()
512  function M.test_checkbox_focus_announces_current_state()
533  function M.test_checkbox_fires_captured_handler_on_toggle()

-- Slider -------------------------------------------------------------------
557  function M.test_slider_right_increments_by_small_step()
579  function M.test_slider_fires_captured_callback_on_adjust()
604  function M.test_slider_callback_missing_logs_warn()
622  function M.test_slider_left_decrements()
642  function M.test_slider_shift_left_decrements_by_big_step()
662  function M.test_slider_right_at_max_stays_clamped()
680  function M.test_home_with_slider_at_position_one_goes_to_first_item()

-- Pulldown -----------------------------------------------------------------
703  function M.test_pulldown_enter_pushes_subhandler_from_probe()
749  function M.test_pulldown_enter_without_probe_logs_warn_and_announces_current()
766  function M.test_pulldown_sub_pop_preserves_cursor_position()
794  function M.test_sub_pop_advances_cursor_off_hidden_item()

-- Click-ack gating ---------------------------------------------------------
832  function M.test_button_activate_throw_suppresses_click()
855  function M.test_text_without_onActivate_reannounces_label_no_click()
873  function M.test_text_with_onActivate_success_plays_click()
897  function M.test_text_with_throwing_onActivate_suppresses_click()
919  function M.test_choice_activate_throw_suppresses_click()
936  function M.test_checkbox_no_captured_callback_suppresses_click()
953  function M.test_checkbox_throwing_callback_suppresses_click()
972  function M.test_pulldown_no_entries_suppresses_click()
988  function M.test_pulldown_entry_throwing_callback_suppresses_click_still_pops()

-- Tooltips -----------------------------------------------------------------
1018  function M.test_tooltip_appended_after_label_value()
1039  function M.test_tooltip_dedupes_against_label()
1060  function M.test_tooltipFn_appends_dynamic_tooltip()
1084  function M.test_tooltipFn_error_is_logged_and_swallowed()
1106  function M.test_tooltip_newlines_become_period_separators()
1131  function M.test_tooltip_decimal_in_value_is_preserved()
1156  function M.test_tooltipFn_nil_result_does_not_add_comma()
1177  function M.test_slider_empty_label_falls_back_to_textKey()

-- Tabs ---------------------------------------------------------------------
1200  function M.test_tabs_tab_key_cycles_and_resets_cursor()
1235  function M.test_tabs_shift_tab_cycles_backward_wraps()
1258  function M.test_tab_position_preserved_across_pulldown_sub()

-- Install contract ---------------------------------------------------------
1307  function M.test_install_push_on_show_pop_on_hide()
1322  function M.test_install_hide_reactivates_underneath_by_default()
1342  function M.test_install_suppressReactivateOnHide_skips_reactivation()
1369  function M.test_install_suppressReactivateOnHide_false_still_reactivates()
1394  function M.test_install_suppressReactivateOnHide_throw_logs_and_reactivates()
1420  function M.test_install_double_show_keeps_stack_depth_at_one()
1430  function M.test_install_prior_showhide_chained()
1449  function M.test_install_prior_showhide_error_caught_push_still_happens()
1466  function M.test_install_esc_bypasses_to_prior_input()
1489  function M.test_install_esc_on_subhandler_closes_sub_not_screen()
1520  function M.test_install_input_falls_back_to_prior_on_unbound_key()
1543  function M.test_close_reopen_resets_cursor()

-- Preamble -----------------------------------------------------------------
1568  function M.test_preamble_string_queued_after_displayName()
1587  function M.test_preamble_function_called_at_onActivate_not_at_create()
1606  function M.test_preamble_function_returning_empty_is_skipped()
1625  function M.test_silent_first_open_speaks_only_display_name()
1641  function M.test_silent_first_open_still_initializes_cursor()
1656  function M.test_silent_first_open_readHeader_speaks_preamble()
1683  function M.test_silent_first_open_bypassed_by_read_subtitles()
1702  function M.test_silent_first_open_rejects_non_boolean_or_function()
1721  function M.test_silent_first_open_function_truthy_suppresses()
1738  function M.test_silent_first_open_function_falsy_speaks()
1757  function M.test_silent_first_open_function_error_treated_as_false()
1778  function M.test_silent_display_name_skips_header()
1792  function M.test_silent_display_name_still_speaks_preamble_and_first_item()
1807  function M.test_silent_display_name_rejects_non_boolean()

-- Refresh ------------------------------------------------------------------
1822  function M.test_refresh_respeaks_when_function_preamble_changes()
1843  function M.test_refresh_noop_when_unchanged()
1860  function M.test_refresh_noop_when_preamble_is_string()
1875  function M.test_refresh_fn_error_logged_no_crash()

-- F1 / readHeader ----------------------------------------------------------
1895  function M.test_f1_speaks_displayName_then_preamble()
1915  function M.test_f1_with_no_preamble_speaks_displayName_only()
1927  function M.test_f1_resolves_function_preamble_live()
1947  function M.test_f1_syncs_lastPreambleText_so_refresh_is_noop()

-- Edge cases ---------------------------------------------------------------
1970  function M.test_empty_items_onActivate_speaks_displayName_only()
1979  function M.test_empty_items_onEnter_is_safe_noop()
1994  function M.test_shouldActivate_false_skips_push()
2011  function M.test_shouldActivate_true_pushes()
2029  function M.test_deferActivate_delays_push_to_update_tick()
2048  function M.test_deferActivate_hide_before_tick_cancels_push()
2065  function M.test_deferActivate_hidden_at_tick_skips_push()
2083  function M.test_setItems_replaces_items_single_tab()
2104  function M.test_setItems_replaces_tab_items_by_index()
2127  function M.test_setItems_clamps_cursor_when_out_of_range()
2150  function M.test_labelText_overrides_textKey_lookup()
2163  function M.test_control_ref_bypasses_controlName_lookup()
2179  function M.test_capturesAllInput_blocks_lower_handlers()

-- Edit mode ----------------------------------------------------------------
2205  function M.test_enter_on_textfield_pushes_edit_submenu()
2233  function M.test_escape_during_edit_restores_and_pops()
2259  function M.test_enter_during_edit_commits_without_restoring()
2276  function M.test_commit_fires_priorCallback_with_final_text()
2300  function M.test_commit_announces_committed_value()
2317  function M.test_commit_on_empty_announces_blank()
2333  function M.test_commit_without_priorCallback_is_safe()
2350  function M.test_restore_does_not_fire_priorCallback()
2377  function M.test_edit_submenu_has_no_arrow_bindings()
2397  function M.test_reenter_edit_installs_fresh_wrapping_callback()
2421  function M.test_edit_mode_enter_keyup_is_claimed()

-- Groups / nested menus ---------------------------------------------------
2463  function M.test_group_drill_on_enter_enters_first_child()
2486  function M.test_group_drill_on_right()
2498  function M.test_left_at_level_2_goes_back()
2515  function M.test_esc_at_level_2_bypasses_to_priorInput_without_drilling_back()
2551  function M.test_esc_at_level_1_bypasses_to_priorInput()
2584  function M.test_down_at_level_2_past_last_wraps_to_next_group_first_child()
2602  function M.test_up_at_level_2_past_first_wraps_to_prev_group_last_child()
2620  function M.test_cross_parent_skips_leaves_at_parent_level()
2646  function M.test_home_at_level_2_stays_within_group()
2660  function M.test_ctrl_down_at_level_1_jumps_across_leaves_to_next_group()
2684  function M.test_ctrl_up_at_level_2_jumps_to_prev_group_first_child()
2704  function M.test_empty_group_is_skipped_in_navigation()
2724  function M.test_group_with_only_non_navigable_children_is_skipped()
2744  function M.test_nested_group_with_inner_drillable_stays_navigable()
2762  function M.test_nested_group_with_only_empty_inner_is_hidden()
2780  function M.test_group_itemsFn_is_called_lazily_and_cached()

-- Pulldown advanced --------------------------------------------------------
2801  function M.test_pulldown_fallback_fires_per_entry_button_callback()
2858  function M.test_pulldown_inner_button_disabled_marks_inactivatable()
2891  function M.test_pulldown_entry_announce_fn_replaces_entry_text()
2930  function M.test_pulldown_no_callback_at_all_logs_warn()
2952  function M.test_group_cached_false_rebuilds_on_every_drill()
2972  function M.test_hidden_group_is_skipped_in_navigation()
2996  function M.test_single_sibling_group_wraps_circularly_within_itself()
3011  function M.test_slider_at_level_2_left_right_adjusts_not_back()
3034  function M.test_level_reset_on_hide_then_reopen()

-- Type-ahead search --------------------------------------------------------
3066  local function installForSearch(labelledItems)
3086  local function keydown(ctx, vk)
3089  local function vkLetter(c)
3093  function M.test_search_letter_moves_to_first_match()
3106  function M.test_search_no_match_speaks_and_stays_active()
3125  function M.test_search_escape_clears_instead_of_going_back()
3140  function M.test_search_down_navigates_results_not_items()
3155  function M.test_search_backspace_to_empty_clears()
3166  function M.test_search_enter_activates_current_result()
3195  function M.test_search_clears_on_drill()
3221  function M.test_setIndex_clears_active_search()
3234  function M.test_search_ignored_when_ctrl_held()

-- Choice.selectedFn -------------------------------------------------------
3255  function M.test_choice_selectedfn_prepends_selected_and_reannounces()
3301  function M.test_choice_without_selectedfn_does_not_reannounce()
3328  function M.test_pulldown_sub_entry_announces_selected_for_current_value()
3358  function M.test_choice_selectedfn_skips_reannounce_when_activate_pops_handler()

-- Per-tab hooks ------------------------------------------------------------
3396  function M.test_tab_nameFn_overrides_tab_name_on_switch()
3431  function M.test_tab_nameFn_empty_result_skips_tab_name_announcement()
3471  function M.test_tab_buildSearchable_override_replaces_default_corpus()
3517  function M.test_tab_buildSearchable_override_receives_handler()
3548  function M.test_tab_buildSearchable_missing_falls_back_to_default_corpus()
3572  function M.test_tab_buildSearchable_bad_return_falls_back_to_default()
3602  function M.test_tab_onAltLeft_onAltRight_hooks_fire_on_active_tab()
3643  function M.test_spec_onAltLeft_fires_when_no_tabs()
3660  function M.test_spec_onAltRight_fires_when_no_tabs()
3677  function M.test_tab_onAltLeft_overrides_spec_onAltLeft()
3715  function M.test_spec_onAltLeft_rejects_non_function()
3730  function M.test_tab_onCtrlUp_hook_overrides_sibling_group_jump()
3764  function M.test_tab_without_onCtrl_hook_falls_back_to_default()
3793  function M.test_tab_first_init_fires_tab_one_onActivate()
3821  function M.test_tab_first_init_applies_tab_one_autoDrillToLevel()
3842  function M.test_tab_first_init_onActivate_can_override_cursor()

-- Ctrl+I pedia dispatch ---------------------------------------------------
3876  local function withPediaStub(fn)
3885  function M.test_ctrl_i_fires_pedia_event_with_static_name()
3909  function M.test_ctrl_i_resolves_pediaNameFn_dynamically()
3941  function M.test_ctrl_i_noop_when_item_has_no_pediaName()
3958  function M.test_ctrl_i_pediaNameFn_error_logged_and_swallowed()
3983  function M.test_ctrl_i_binding_absent_in_frontend()

-- VirtualSlider -----------------------------------------------------------
4020  function M.test_virtual_slider_right_increments_by_small_step()
4050  function M.test_virtual_slider_left_decrements_by_small_step()
4078  function M.test_virtual_slider_shift_right_uses_big_step()
4106  function M.test_virtual_slider_clamps_at_one()
4137  function M.test_virtual_slider_clamps_at_zero()
4164  function M.test_virtual_slider_focus_announces_current_value()

-- VirtualToggle -----------------------------------------------------------
4205  function M.test_virtual_toggle_enter_flips_to_true_and_announces_on()
4230  function M.test_virtual_toggle_space_flips_back_to_false_and_announces_off()
4255  function M.test_virtual_toggle_focus_announces_current_state()
4276  return M
```

## Notes

The largest suite in the harness at 4276 lines. Loads TextFilter, SpeechPipeline, Text, HandlerStack, InputRouter, TickPump, Nav, PullDownProbe, BaseMenuItems, TypeAheadSearch, BaseMenuHelp, BaseMenuTabs, BaseMenuCore, BaseMenuInstall, and BaseMenuEditMode all for real. The `populateControls` / `setCtrls` helpers build a live `ctrlState` map that drives `IsHidden` / `IsDisabled` behavior. The shared `_test_pd_mt` metatable is rebuilt per setup so pulldown probe tests don't bleed across suites.
