# tests/pulldown_probe_test.lua — 272 lines
Tests PullDownProbe install idempotency, callback capture, entry recording, sibling patch via shared metatable, nil/bare-table failure, slider probe, checkbox probe, and button probe.

## Header comment

```
-- PullDownProbe tests. Uses a PullDown built from the polyfill factory with
-- its methods promoted onto a shared __index metatable -- the same shape the
-- engine uses, so the probe's monkey-patch applies across all PullDowns
-- created from that factory.
```

## Outline

```
  4  local T = require("support")
  5  local M = {}
  8  local warns
  9  local _shared_mt
 11  local function setup()
    local function makePD()
    local function buttonMt()
 57  function M.test_install_idempotent()
 67  function M.test_register_selection_callback_is_captured()
 76  function M.test_build_entry_records_instances_in_order()
 90  function M.test_clear_entries_wipes_list()
101  function M.test_install_on_sample_affects_other_pulldowns()
110  function M.test_install_logs_warn_when_sample_has_no_metatable()
118  function M.test_install_without_sample_logs_warn()
127  function M.test_slider_probe_captures_callback()
155  function M.test_slider_probe_with_function_index()
191  function M.test_checkbox_probe_captures_handler()
236  function M.test_button_probe_captures_click_callback_by_mouse_event()
246  function M.test_button_probe_ignores_non_numeric_mouse_event()
258  function M.test_button_probe_separate_buttons_have_separate_callbacks()
272  return M
```
