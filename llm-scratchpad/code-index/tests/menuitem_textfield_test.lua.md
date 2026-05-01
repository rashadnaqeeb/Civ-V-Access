# tests/menuitem_textfield_test.lua — 209 lines
Tests BaseMenuItems.Textfield factory surface: control lookup, priorCallback validation, focus-announce composition, blank sentinel, and visibility-wrapper gating.

## Header comment

```
-- BaseMenuItems.Textfield announcement + resolution tests. EditMode coverage
-- lives in menu_test. This suite exercises the factory-level surface:
-- control lookup, priorCallback validation, focus-announce composition,
-- blank sentinel, and visibility-wrapper gating.
```

## Outline

```
  4  local T = require("support")
  5  local M = {}
  8  local warns, errors
  9  local speaks
 11  local function setup()
 74  local function populateControls(map)
 77  function M.test_missing_editbox_logs_warn()
 84  function M.test_non_function_priorCallback_is_rejected()
 98  function M.test_focus_announce_includes_current_text()
112  function M.test_focus_announce_blank_when_empty()
125  function M.test_focus_announce_updates_when_text_changes_between_visits()
150  function M.test_visibilityControlName_hidden_wrapper_skips_item()
173  function M.test_visibilityControlName_visible_wrapper_allows_item()
195  function M.test_missing_visibilityControl_logs_warn()
209  return M
```
