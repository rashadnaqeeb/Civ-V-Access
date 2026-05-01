# tests/number_entry_test.lua — 330 lines
Tests BaseMenuNumberEntry: push validation, digit append via top-row and numpad, backspace, commit with clamp, cancel via Esc and empty/zero Enter, and capturesAllInput modal barrier.

## Header comment

```
-- BaseMenuNumberEntry tests. Exercises buffer management (digit append,
-- Backspace, empty Backspace), commit paths (valid integer, over-max clamp,
-- empty/zero = cancel), cancel paths (Esc, empty Enter, zero Enter), and
-- speech output on each keystroke.
```

## Outline

```
  4  local T = require("support")
  5  local M = {}
  8  local warns, errors, speaks
 10  local function setup()
    local function press(vk, mods)
    local function pressDigit(ch)
    local function pressNumpad(n)
    local function onCommitCapture()
    local function onCancelCapture()
 81  function M.test_push_rejects_non_table_opts()
 88  function M.test_push_rejects_missing_onCommit()
 95  function M.test_push_speaks_prompt_with_max()
107  function M.test_push_without_max_speaks_prompt_only()
116  function M.test_push_sets_capturesAllInput()
125  function M.test_digit_appends_and_speaks_running_total()
137  function M.test_numpad_digits_also_append()
149  function M.test_backspace_removes_last_digit()
160  function M.test_backspace_on_empty_speaks_empty_sentinel()
168  function M.test_backspace_to_empty_speaks_empty_sentinel()
179  function M.test_commit_valid_number_calls_onCommit_and_pops()
191  function M.test_commit_over_max_clamps_and_announces()
205  function M.test_commit_unclamped_still_announces_committed_value()
219  function M.test_commit_empty_buffer_treated_as_cancel()
235  function M.test_commit_zero_treated_as_cancel()
251  function M.test_onCommit_error_is_logged_and_handler_still_pops()
268  function M.test_esc_cancels_without_committing()
286  function M.test_cancel_announces_canceled_keyword()
298  function M.test_cancel_without_onCancel_still_pops()
311  function M.test_captures_all_input_blocks_arrow_keys()
330  return M
```
