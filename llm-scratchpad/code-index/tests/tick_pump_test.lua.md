# `tests/tick_pump_test.lua`

124 lines · Tests for `CivVAccess_TickPump` covering the frame counter, active-handler dispatch, no-handler noop, error catching, `install` rewiring, `runOnce` one-shot drain, multi-callback queue ordering, re-scheduling from a callback, and `runOnce` error catching.

## Header comment

```
-- TickPump tests. HandlerStack loaded for real so we can verify tick()
-- forwards to the active handler.
```

## Outline

- L4: `local T = require("support")`
- L5: `local M = {}`
- L7: `local errors`
- L9: `local function setup()`
- L22: `function M.test_tick_bumps_frame_counter()`
- L30: `function M.test_tick_calls_active_handler_tick()`
- L43: `function M.test_tick_no_active_handler_is_noop()`
- L49: `function M.test_tick_handler_error_caught_and_logged()`
- L61: `function M.test_install_rewires_setupdate_each_call()`
- L74: `function M.test_runOnce_drained_on_next_tick_then_cleared()`
- L86: `function M.test_runOnce_queues_multiple_drained_together()`
- L99: `function M.test_runOnce_callback_can_schedule_next_tick()`
- L115: `function M.test_runOnce_callback_error_caught_and_logged()`
- L124: `return M`

## Notes

- L9 `setup`: Loads `CivVAccess_HandlerStack.lua` and `CivVAccess_TickPump.lua` for real (not mocked), then calls `HandlerStack._reset()` and `TickPump._reset()` to ensure a clean slate; `Log.error` is captured into `errors` to assert on caught handler failures.
- L99 `test_runOnce_callback_can_schedule_next_tick`: Asserts that a `runOnce` callback which itself calls `runOnce` does NOT run the inner callback in the same tick — verifying the drain loop operates on a snapshot rather than the live queue, so re-scheduling defers to the subsequent tick.
