# tests/scanner_announcement_test.lua — 250 lines
Tests ScannerNav announcement formatting through cycleItem/cycleInstance: name/distance/count shape, "here" and "empty" tokens, snapshot-origin vs live-cursor distance, toggleAutoMove, and returnToPreJump.

## Header comment

```
-- Scanner announcement formatting. Verifies the documented shape
-- "<name>. <distance/direction>. <N> of <M>." and the two short-circuit
-- tokens (here, empty) produced by the nav module's format path. Goes
-- through ScannerNav.cycleItem / cycleInstance because the formatter is
-- a module-private function; exercising it through the public seam is
-- both more realistic and keeps the surface small.
```

## Outline

```
  4  local T = require("support")
  5  local M = {}
 10  local _turnStartHandlers
 11  local _entries = {}
 12  local function setup()
    local function installStubBackend(entries)
    local function mkPlot(x, y, idx)
    local function mkEntry(cat, sub, name, plotIndex)
110  function M.test_cycle_item_announces_name_distance_and_count()
129  function M.test_instance_count_reflects_total_in_item()
146  function M.test_zero_distance_speaks_here_token()
157  function M.test_empty_item_falls_through_to_empty_token()
165  function M.test_distance_announcement_uses_snapshot_origin_not_live_cursor()
192  function M.test_distance_announcement_tracks_live_cursor_with_auto_move_off()
214  function M.test_distance_from_cursor_separately_produces_bare_direction()
228  function M.test_auto_move_toggle_announces_on_off()
239  function M.test_return_to_pre_jump_speaks_when_no_prior_jump()
250  return M
```
