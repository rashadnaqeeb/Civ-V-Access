# tests/input_router_test.lua — 526 lines
Tests InputRouter dispatch routing, capturesAllInput barrier, modifier mask, help overlay, type-ahead hook, and hotseat-mute toggle.

## Header comment

```
-- InputRouter tests. HandlerStack loaded for real; UI queried via polyfill
-- stubs which we override per-test for modifier state.
```

## Outline

```
  4  local T = require("support")
  5  local M = {}
  6  local errors
  9  local function setup()
 30  local WM_KEYDOWN = 256
 31  local WM_SYSKEYDOWN = 260
 34  function M.test_dispatch_invokes_matching_binding()
 53  function M.test_dispatch_top_wins_when_both_bind_same_key()
 85  function M.test_capturesAllInput_stops_walk_even_on_no_match()
106  function M.test_passthrough_keys_fall_through_from_barrier()
121  function M.test_passthrough_matches_on_keycode_regardless_of_modifier()
136  function M.test_binding_on_barrier_beats_passthrough()
159  function M.test_non_matching_mod_mask_does_not_fire()
178  function M.test_non_key_message_returns_false()
197  function M.test_wm_syskeydown_routed_like_wm_keydown()
216  function M.test_binding_fn_error_caught_still_consumed()
235  function M.test_currentModifierMask_combines_bits()
246  function M.test_dispatch_no_handlers_returns_false()
256  function M.test_shift_question_opens_help()
270  function M.test_shift_question_skipped_when_help_on_top()
287  function M.test_question_without_shift_not_intercepted()
301  function M.test_shift_question_without_Help_module_warns()
315  function M.test_search_hook_consumes_when_handler_consumes()
333  function M.test_search_hook_falls_through_when_not_consumed()
357  function M.test_search_hook_only_on_top_handler()
379  function M.test_search_hook_not_called_on_syskeydown()
397  function M.test_search_hook_error_logged_and_falls_through()
431  local function setupMute()
461  function M.test_mute_toggle_enters_mute_and_speaks_paused_before_flip()
474  function M.test_mute_toggle_exits_mute_and_speaks_resumed_after_flip()
488  function M.test_mute_toggle_debounces_key_repeat()
500  function M.test_dispatch_is_short_circuited_while_muted()
522  return M
```
