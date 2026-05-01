# tests/picker_reader_test.lua — 472 lines
Tests PickerReader two-tab activate/restore contract, buildReader rebuild on re-entry, autoDrillToLevel, Ctrl+Up/Down article navigation, Alt hook wiring, and pickerBuildSearchable override.

## Header comment

```
-- PickerReader cross-tab behavior. Focused on the two-tab activate/restore
-- contract so regressions in BaseMenu's switchTab / cycleTab don't silently
-- break the pedia flow. BaseMenu + BaseMenuItems + TypeAheadSearch are
-- loaded for real; engine globals come from Polyfill. Every test drives
-- through the real session.install path so the install-site wiring
-- (onActivate, nameFn, Ctrl+arrow hooks) stays under test.
```

## Outline

```
  4  local T = require("support")
  5  local M = {}
 10  local warns, errors
 11  local speaks
 13  local WM_KEYDOWN = 256
 15  local function setup()
    local function makeContextPtr()
    local function installFixture(readerFactory)
    local function sectionedReader(id)
    local function spokeText(needle)
    local function installFixtureWithAltHooks(onLeft, onRight)
175  function M.test_handler_starts_on_picker_tab_level_1()
182  function M.test_entry_activation_swaps_reader_items_and_switches_tab()
200  function M.test_entry_activation_reading_first_body_line()
212  function M.test_same_entry_reactivated_rebuilds_reader()
228  function M.test_switch_to_reader_tab_programmatically_re_announces()
238  function M.test_empty_build_result_keeps_user_on_picker()
251  function M.test_autoDrill_level_one_stays_at_level_one()
261  function M.test_tab_cycling_preserves_reader_items_after_selection()
278  function M.test_install_reader_nameFn_speaks_article_title_not_content()
289  function M.test_install_reader_nameFn_empty_when_no_selection()
301  function M.test_install_reader_ctrl_down_advances_article()
316  function M.test_install_reader_ctrl_up_goes_to_previous_article()
330  function M.test_install_reader_ctrl_up_at_first_article_is_noop()
339  function M.test_install_reader_ctrl_down_at_last_article_is_noop()
351  function M.test_install_reader_ctrl_keys_on_picker_tab_use_default_behavior()
392  function M.test_install_reader_alt_hooks_fire_on_reader_tab()
409  function M.test_install_pickerBuildSearchable_routes_to_picker_tab_search()
457  function M.test_install_reader_alt_hooks_do_not_fire_on_picker_tab()
472  return M
```
