# `tests/menu_structure_test.lua`

1581 lines - Tests BaseMenu factory validation, structural edge cases, nested Group navigation, type-ahead search, Choice.selectedFn / pulldown sub selected-prefix, and Ctrl+I pedia dispatch.

## Header comment

```
-- BaseMenu structural and navigation tests. Peeled out of menu_test
-- .lua. Covers factory validation, edge cases (empty items / setItems
-- / capturesAllInput / shouldActivate / deferActivate / dynamic-item
-- features), nested groups (drill / wrap / Ctrl up-down jumps /
-- pulldown-advanced behavior), type-ahead search + Choice.selectedFn
-- announce-on-current-value, and the Ctrl+I pedia dispatch chord.
-- The shared setup() and helpers are duplicated across the four
-- menu_*_test files so each is self-contained.
```

## Outline

```lua
local T = require("support")                          -- L9
local M = {}                                          -- L10

local warns, errors                                   -- L12
local speaks                                          -- L13
local sounds                                          -- L14
local _test_pd_mt = nil                               -- L15

local function resetPDMetatable()                     -- L17
local function setup()                                -- L34

local WM_KEYDOWN = 256                                -- L108

local function populateControls(map)                  -- L112
local function patchProbeFromPullDown(pd)             -- L119
local function makePullDownWithMetatable()            -- L123
local function registerSliderCallback(slider, fn)     -- L130
local function registerCheckHandler(cb, fn)           -- L135
local ctrlState                                       -- L142
local function makeCtrl(name)                         -- L143
local function setCtrls(names)                        -- L155
local function makeContextPtr()                       -- L163
local function buttonSpec(names)                      -- L181

local MOD_CTRL = 2                                    -- L484

local function buttonItem(name, label)                -- L486
local function groupItem(label, children)             -- L493

local function installForSearch(labelledItems)        -- L1104
local function keydown(ctx, vk)                       -- L1124
local function vkLetter(c)                            -- L1127

local function withPediaStub(fn)                      -- L1441

function M.test_create_requires_name_and_displayName()                       -- L196
function M.test_create_requires_items_or_tabs()                              -- L203
function M.test_create_shape_matches_handler_contract()                      -- L210
function M.test_missing_control_logs_warn_and_keeps_item()                  -- L229
function M.test_empty_items_onActivate_speaks_displayName_only()            -- L244
function M.test_empty_items_onEnter_is_safe_noop()                          -- L253
function M.test_shouldActivate_false_skips_push()                           -- L268
function M.test_shouldActivate_true_pushes()                                -- L285
function M.test_deferActivate_delays_push_to_update_tick()                  -- L303
function M.test_deferActivate_hide_before_tick_cancels_push()               -- L322
function M.test_deferActivate_hidden_at_tick_skips_push()                   -- L339
function M.test_setItems_replaces_items_single_tab()                        -- L357
function M.test_setItems_replaces_tab_items_by_index()                      -- L378
function M.test_setItems_clamps_cursor_when_out_of_range()                  -- L401
function M.test_labelText_overrides_textKey_lookup()                        -- L424
function M.test_control_ref_bypasses_controlName_lookup()                   -- L437
function M.test_capturesAllInput_blocks_lower_handlers()                    -- L453
function M.test_group_drill_on_enter_enters_first_child()                   -- L501
function M.test_group_drill_on_right()                                      -- L524
function M.test_left_at_level_2_goes_back()                                 -- L536
function M.test_esc_at_level_2_bypasses_to_priorInput_without_drilling_back() -- L553
function M.test_esc_at_level_1_bypasses_to_priorInput()                    -- L589
function M.test_down_at_level_2_past_last_wraps_to_next_group_first_child() -- L622
function M.test_up_at_level_2_past_first_wraps_to_prev_group_last_child()   -- L640
function M.test_cross_parent_skips_leaves_at_parent_level()                 -- L658
function M.test_home_at_level_2_stays_within_group()                        -- L684
function M.test_ctrl_down_at_level_1_jumps_across_leaves_to_next_group()    -- L697
function M.test_ctrl_up_at_level_2_jumps_to_prev_group_first_child()        -- L722
function M.test_empty_group_is_skipped_in_navigation()                      -- L742
function M.test_group_with_only_non_navigable_children_is_skipped()         -- L762
function M.test_nested_group_with_inner_drillable_stays_navigable()         -- L782
function M.test_nested_group_with_only_empty_inner_is_hidden()              -- L800
function M.test_group_itemsFn_is_called_lazily_and_cached()                 -- L818
function M.test_pulldown_fallback_fires_per_entry_button_callback()         -- L839
function M.test_pulldown_inner_button_disabled_marks_inactivatable()        -- L896
function M.test_pulldown_entry_announce_fn_replaces_entry_text()            -- L929
function M.test_pulldown_no_callback_at_all_logs_warn()                     -- L968
function M.test_group_cached_false_rebuilds_on_every_drill()                -- L990
function M.test_hidden_group_is_skipped_in_navigation()                     -- L1010
function M.test_single_sibling_group_wraps_circularly_within_itself()       -- L1034
function M.test_slider_at_level_2_left_right_adjusts_not_back()             -- L1049
function M.test_level_reset_on_hide_then_reopen()                           -- L1072
function M.test_search_letter_moves_to_first_match()                        -- L1131
function M.test_search_no_match_speaks_and_stays_active()                   -- L1143
function M.test_search_escape_clears_instead_of_going_back()               -- L1163
function M.test_search_down_navigates_results_not_items()                   -- L1178
function M.test_search_backspace_to_empty_clears()                          -- L1193
function M.test_search_enter_activates_current_result()                     -- L1204
function M.test_search_clears_on_drill()                                    -- L1233
function M.test_setIndex_clears_active_search()                             -- L1259
function M.test_search_ignored_when_ctrl_held()                             -- L1272
function M.test_choice_selectedfn_prepends_selected_and_reannounces()       -- L1293
function M.test_choice_without_selectedfn_does_not_reannounce()             -- L1339
function M.test_pulldown_sub_entry_announces_selected_for_current_value()   -- L1366
function M.test_choice_selectedfn_skips_reannounce_when_activate_pops_handler() -- L1396
function M.test_ctrl_i_fires_pedia_event_with_static_name()                 -- L1450
function M.test_ctrl_i_resolves_pediaNameFn_dynamically()                   -- L1474
function M.test_ctrl_i_noop_when_item_has_no_pediaName()                    -- L1506
function M.test_ctrl_i_pediaNameFn_error_logged_and_swallowed()             -- L1523
function M.test_ctrl_i_binding_absent_in_frontend()                         -- L1548

return M                                              -- L1581
```

## Notes

- L1104 `installForSearch`: section-local helper that builds a full installed menu from a list of `{name, label}` pairs, returning `ctx` and the handler; used by all type-ahead search tests.
- L1441 `withPediaStub`: section-local helper that stubs `Events.SearchForPediaEntry` for the duration of a callback, capturing fired names into a table, then clears the stub.
- L839 `test_pulldown_fallback_fires_per_entry_button_callback`: covers the map-script dropdown pattern where per-entry `RegisterCallback` clicks are used instead of a top-level `RegisterSelectionCallback`.
- L1396 `test_choice_selectedfn_skips_reannounce_when_activate_pops_handler`: verifies that when activate pops the handler, the Choice re-announce is suppressed so it does not race against the parent's own onActivate speech.
- L1548 `test_ctrl_i_binding_absent_in_frontend`: temporarily nils the `Game` global to simulate a FrontEnd context, then checks `h.bindings` directly for the absence of the Ctrl+I entry.
