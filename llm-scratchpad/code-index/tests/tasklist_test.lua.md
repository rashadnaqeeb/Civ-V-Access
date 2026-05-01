# `tests/tasklist_test.lua`

126 lines · Tests for `CivVAccess_TaskList` covering the file-scope `TaskListUpdate` listener registration, mirror writes to `civvaccess_shared.tasks`, active-task filtering and concatenation, silent paths (mirror unset/empty/all-completed), in-place status overwrites, reset-for-new-game, and engine-order iteration with index holes.

## Header comment

```
-- TaskList-module tests. Covers the file-scope TaskListUpdate listener
-- that mirrors engine task pushes into civvaccess_shared.tasks, and the
-- Shift+T readout that filters to active (status 0) tasks and concatenates
-- via TextFilter.filter. Silent paths (no mirror, all-completed) are
-- explicitly asserted because a wrong value reaching Tolk is a silent
-- failure for the blind player.
```

## Outline

- L6: `local T = require("support")`
- L7: `local M = {}`
- L9: `local spoken`
- L10: `local listener`
- L12: `local function setup()`
- L43: `function M.test_listener_registers_at_file_scope()`
- L48: `function M.test_listener_writes_to_civvaccess_shared_tasks()`
- L55: `function M.test_silent_when_mirror_unset()`
- L63: `function M.test_silent_when_mirror_empty()`
- L70: `function M.test_speaks_only_active_tasks()`
- L83: `function M.test_silent_when_all_tasks_completed_or_failed()`
- L92: `function M.test_status_update_overwrites_in_place()`
- L99: `function M.test_reset_for_new_game_clears_mirror()`
- L108: `function M.test_iterates_in_engine_order()`
- L126: `return M`

## Notes

- L12 `setup`: Re-`dofile`s `CivVAccess_TaskList.lua` on every call so the file-scope `Events.TaskListUpdate.Add` registration runs against a freshly captured stub; this is required because the offline harness has no Context lifecycle to trigger re-include.
- L12 `setup`: Captures the registered listener in an upvalue by replacing `Events.TaskListUpdate.Add` with a closure before the dofile, letting tests call `listener(...)` directly to simulate engine task-push events.
