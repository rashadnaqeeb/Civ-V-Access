# `tests/menu_widgets_test.lua`

1055 lines - Tests BaseMenuItems widget types: Button-list navigation, disabled-but-visible walking, Checkbox / Slider / PullDown widgets, and VirtualSlider / VirtualToggle.

## Header comment

```
-- BaseMenuItems widgets and Button-list navigation. Peeled out of
-- menu_test.lua. Covers Button-list navigation, disabled-but-visible
-- walking, Checkbox / Slider / PullDown widgets, and the VirtualSlider
-- / VirtualToggle settings-menu items. The shared setup() and helpers
-- are duplicated across the four menu_*_test files so each is self-
-- contained; tests do not change between the pre-split menu_test.lua
-- and the new files, only their home moves.
```

## Outline

```lua
local T = require("support")                          -- L8
local M = {}                                          -- L9

local warns, errors                                   -- L11
local speaks                                          -- L12
local sounds                                          -- L13
local _test_pd_mt = nil                               -- L14

local function resetPDMetatable()                     -- L16
local function setup()                                -- L33

local WM_KEYDOWN = 256                                -- L107

local function populateControls(map)                  -- L111
local function patchProbeFromPullDown(pd)             -- L118
local function makePullDownWithMetatable()            -- L122
local function registerSliderCallback(slider, fn)     -- L129
local function registerCheckHandler(cb, fn)           -- L134
local ctrlState                                       -- L141
local function makeCtrl(name)                         -- L142
local function setCtrls(names)                        -- L154
local function makeContextPtr()                       -- L162
local function buttonSpec(names)                      -- L180

function M.test_down_moves_to_next_item()                                    -- L194
function M.test_up_wraps_from_top_to_bottom()                                -- L203
function M.test_down_wraps_from_bottom_to_top()                              -- L212
function M.test_hidden_items_are_skipped()                                   -- L223
function M.test_all_hidden_navigation_is_noop()                              -- L233
function M.test_home_jumps_to_first_navigable()                              -- L247
function M.test_end_jumps_to_last_navigable()                                -- L258
function M.test_enter_fires_activate()                                        -- L268
function M.test_space_also_fires_activate()                                   -- L288
function M.test_enter_activate_error_caught_and_logged()                     -- L310
function M.test_enter_plays_click_sound()                                     -- L332
function M.test_enter_on_hidden_current_logs_warn_no_crash()                 -- L346
function M.test_post_activate_revalidation_advances_on_hidden_flip()         -- L371
function M.test_navigation_walks_disabled_items()                            -- L399
function M.test_enter_on_disabled_is_noop_no_activate_no_sound()             -- L411
function M.test_onActivate_first_item_disabled_announces_with_suffix()       -- L439
function M.test_checkbox_enter_toggles_and_announces_on()                   -- L450
function M.test_checkbox_space_toggles_back_and_announces_off()             -- L466
function M.test_checkbox_focus_announces_current_state()                    -- L482
function M.test_checkbox_fires_captured_handler_on_toggle()                 -- L503
function M.test_slider_right_increments_by_small_step()                     -- L527
function M.test_slider_fires_captured_callback_on_adjust()                  -- L549
function M.test_slider_callback_missing_logs_warn()                         -- L574
function M.test_slider_left_decrements()                                    -- L592
function M.test_slider_shift_left_decrements_by_big_step()                  -- L612
function M.test_slider_right_at_max_stays_clamped()                         -- L632
function M.test_home_with_slider_at_position_one_goes_to_first_item()       -- L650
function M.test_pulldown_enter_pushes_subhandler_from_probe()               -- L673
function M.test_pulldown_enter_without_probe_logs_warn_and_announces_current() -- L719
function M.test_pulldown_sub_pop_preserves_cursor_position()                -- L736
function M.test_sub_pop_advances_cursor_off_hidden_item()                   -- L764
function M.test_virtual_slider_right_increments_by_small_step()             -- L798
function M.test_virtual_slider_left_decrements_by_small_step()              -- L828
function M.test_virtual_slider_shift_right_uses_big_step()                  -- L856
function M.test_virtual_slider_clamps_at_one()                              -- L884
function M.test_virtual_slider_clamps_at_zero()                             -- L915
function M.test_virtual_slider_focus_announces_current_value()              -- L942
function M.test_virtual_toggle_enter_flips_to_true_and_announces_on()       -- L983
function M.test_virtual_toggle_space_flips_back_to_false_and_announces_off() -- L1008
function M.test_virtual_toggle_focus_announces_current_state()              -- L1033

return M                                              -- L1055
```

## Notes

- L129 `registerSliderCallback`: manually writes into `civvaccess_shared.sliderCallbacks` in addition to calling the native API, mirroring what the probe patch does so the captured callback table is populated in the test harness.
- L673 `test_pulldown_enter_pushes_subhandler_from_probe`: most complex widget test -- exercises the full pulldown open/navigate/commit/pop cycle including void1 forwarding and sub-name assertion.
