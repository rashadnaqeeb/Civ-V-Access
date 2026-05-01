# `tests/menu_lifecycle_test.lua`

1420 lines - Tests BaseMenu install lifecycle and tab machinery: push/pop on show/hide, reactivation, suppressReactivateOnHide, Esc bypass, preamble variants (silentFirstOpen / silentDisplayName / function preamble), refresh, F1 readHeader, and per-tab nameFn / buildSearchable / onAltLeft-Right / onCtrl hooks.

## Header comment

```
-- BaseMenu lifecycle and tabbing tests. Peeled out of menu_test.lua.
-- Covers Install (push on show / pop on hide / reactivation /
-- suppressReactivateOnHide / Esc bypass), preamble (silentFirstOpen
-- variants, ReadSubtitles, function preamble), refresh, F1 readHeader,
-- single-handler tabs, and the per-tab nameFn / buildSearchable /
-- onAltLeft-Right / onCtrl hooks. The shared setup() and helpers are
-- duplicated across the four menu_*_test files so each is self-
-- contained.
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

function M.test_tabs_tab_key_cycles_and_resets_cursor()                      -- L196
function M.test_tabs_shift_tab_cycles_backward_wraps()                       -- L231
function M.test_tab_position_preserved_across_pulldown_sub()                 -- L254
function M.test_install_push_on_show_pop_on_hide()                          -- L285
function M.test_install_hide_reactivates_underneath_by_default()            -- L300
function M.test_install_suppressReactivateOnHide_skips_reactivation()       -- L320
function M.test_install_suppressReactivateOnHide_false_still_reactivates()  -- L347
function M.test_install_suppressReactivateOnHide_throw_logs_and_reactivates() -- L372
function M.test_install_double_show_keeps_stack_depth_at_one()              -- L398
function M.test_install_prior_showhide_chained()                            -- L407
function M.test_install_prior_showhide_error_caught_push_still_happens()    -- L427
function M.test_install_esc_bypasses_to_prior_input()                       -- L444
function M.test_install_esc_on_subhandler_closes_sub_not_screen()           -- L467
function M.test_install_input_falls_back_to_prior_on_unbound_key()          -- L498
function M.test_close_reopen_resets_cursor()                                -- L521
function M.test_preamble_string_queued_after_displayName()                  -- L546
function M.test_preamble_function_called_at_onActivate_not_at_create()      -- L565
function M.test_preamble_function_returning_empty_is_skipped()              -- L584
function M.test_silent_first_open_speaks_only_display_name()                -- L603
function M.test_silent_first_open_still_initializes_cursor()                -- L619
function M.test_silent_first_open_readHeader_speaks_preamble()              -- L634
function M.test_silent_first_open_bypassed_by_read_subtitles()              -- L661
function M.test_silent_first_open_rejects_non_boolean_or_function()         -- L680
function M.test_silent_first_open_function_truthy_suppresses()              -- L699
function M.test_silent_first_open_function_falsy_speaks()                   -- L716
function M.test_silent_first_open_function_error_treated_as_false()         -- L735
function M.test_silent_display_name_skips_header()                          -- L756
function M.test_silent_display_name_still_speaks_preamble_and_first_item()  -- L770
function M.test_silent_display_name_rejects_non_boolean()                   -- L785
function M.test_refresh_respeaks_when_function_preamble_changes()           -- L800
function M.test_refresh_noop_when_unchanged()                               -- L821
function M.test_refresh_noop_when_preamble_is_string()                      -- L838
function M.test_refresh_fn_error_logged_no_crash()                          -- L853
function M.test_f1_speaks_displayName_then_preamble()                       -- L873
function M.test_f1_with_no_preamble_speaks_displayName_only()               -- L893
function M.test_f1_resolves_function_preamble_live()                        -- L905
function M.test_f1_syncs_lastPreambleText_so_refresh_is_noop()              -- L925
function M.test_tab_nameFn_overrides_tab_name_on_switch()                   -- L948
function M.test_tab_nameFn_empty_result_skips_tab_name_announcement()       -- L983
function M.test_tab_buildSearchable_override_replaces_default_corpus()      -- L1023
function M.test_tab_buildSearchable_override_receives_handler()             -- L1069
function M.test_tab_buildSearchable_missing_falls_back_to_default_corpus()  -- L1100
function M.test_tab_buildSearchable_bad_return_falls_back_to_default()      -- L1124
function M.test_tab_onAltLeft_onAltRight_hooks_fire_on_active_tab()         -- L1154
function M.test_spec_onAltLeft_fires_when_no_tabs()                         -- L1195
function M.test_spec_onAltRight_fires_when_no_tabs()                        -- L1212
function M.test_tab_onAltLeft_overrides_spec_onAltLeft()                    -- L1229
function M.test_spec_onAltLeft_rejects_non_function()                       -- L1267
function M.test_tab_onCtrlUp_hook_overrides_sibling_group_jump()            -- L1282
function M.test_tab_without_onCtrl_hook_falls_back_to_default()             -- L1316
function M.test_tab_first_init_fires_tab_one_onActivate()                   -- L1345
function M.test_tab_first_init_applies_tab_one_autoDrillToLevel()           -- L1373
function M.test_tab_first_init_onActivate_can_override_cursor()             -- L1394

return M                                              -- L1420
```

## Notes

- L634 `test_silent_first_open_readHeader_speaks_preamble`: manually resets SpeechPipeline between push and the F1 call so the pipeline's deduplication state doesn't suppress the re-announcement under test.
- L735 `test_silent_first_open_function_error_treated_as_false`: verifies the fail-open contract -- a broken gate must not silence the screen's announcement.
- L1124 `test_tab_buildSearchable_bad_return_falls_back_to_default`: monkey-patches `Log.error` mid-test to detect whether the specific "buildSearchable" phrase appears in the error message, then restores the original.
