# tests/settings_test.lua — 431 lines
Tests Settings.open (12-item build, correct kinds), F12 pre-walk hook, AudioCueMode choices, VolumeControl slider, and each toggle/group item's default value and write-through behavior.

## Header comment

```
(no block comment; inline section comments describe each fixture area)
```

## Outline

```
  4  local T = require("support")
  5  local M = {}
    local function setup()
 97  function M.test_open_pushes_handler_named_Settings()
103  function M.test_open_announces_screen_name()
110  function M.test_open_builds_twelve_items()
124  function M.test_first_item_is_audio_cue_mode_group()
132  function M.test_second_item_is_volume_slider()
139  function M.test_third_item_is_scanner_toggle()
148  function M.test_f12_pre_walk_opens_settings_when_not_on_top()
156  function M.test_f12_while_settings_on_top_closes_via_in_menu_binding()
168  function M.test_escape_pops_settings()
179  function M.test_audio_cue_mode_choices_call_setMode()
189  function M.test_audio_cue_mode_marks_current_as_selected()
205  function M.test_volume_slider_adjust_drives_VolumeControl_set()
225  function M.test_scanner_toggle_flip_writes_shared_and_prefs()
240  function M.test_fourth_item_is_cursor_follows_selection_toggle()
247  function M.test_cursor_follows_selection_toggle_flip_writes_shared_and_prefs()
266  function M.test_fifth_item_is_cursor_coord_mode_group()
274  function M.test_cursor_coord_mode_off_is_default()
283  function M.test_cursor_coord_mode_choice_writes_shared_and_prefs()
294  function M.test_sixth_item_is_border_always_announce_toggle()
301  function M.test_border_always_announce_default_off()
307  function M.test_border_always_announce_toggle_flip_writes_shared_and_prefs()
325  function M.test_seventh_item_is_scanner_coords_toggle()
332  function M.test_scanner_coords_toggle_flip_writes_shared_and_prefs()
351  function M.test_eighth_item_is_read_subtitles_toggle()
358  function M.test_read_subtitles_toggle_flip_writes_shared_and_prefs()
375  function M.test_tenth_item_is_ai_combat_announce_toggle()
382  function M.test_ai_combat_announce_default_on()
388  function M.test_ai_combat_announce_toggle_flip_writes_shared_and_prefs()
404  function M.test_eleventh_item_is_foreign_unit_watch_announce_toggle()
411  function M.test_foreign_unit_watch_announce_default_on()
417  function M.test_foreign_unit_watch_announce_toggle_flip_writes_shared_and_prefs()
431  return M
```
