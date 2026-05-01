# tests/handler_stack_test.lua

Lines: 467
Purpose: Tests `HandlerStack` — push/pop/insertAt/removeByName/drainAndRemove/replace/popAbove/deactivateAll/collectHelpEntries. Captures callback counts via closures on handler tables; captures `Log.*` via monkey-patch.

## Top comment

```
-- HandlerStack tests. Callback counts observed via closures on the
-- handler tables; Log.* captured via monkey-patch.
```

## Outline

```lua
local T = require("support")                          -- L3
local M = {}                                          -- L4

local warns, errors                                   -- L6

local function setup()                                -- L9
local function makeHandler(name, opts)                -- L28
local function makeEscSub(name, escFn)                -- L258

function M.test_push_appends_and_activates()                             -- L50
function M.test_pop_removes_and_deactivates_top()                        -- L59
function M.test_pop_empty_warns_does_not_error()                         -- L71
function M.test_push_nil_warns()                                         -- L78
function M.test_push_onactivate_failure_does_not_add()                   -- L84
function M.test_insertAt_into_empty_stack_activates()                    -- L95
function M.test_insertAt_below_top_does_not_activate()                   -- L104
function M.test_insertAt_middle_position_does_not_activate()             -- L118
function M.test_insertAt_count_plus_one_acts_like_push()                 -- L133
function M.test_insertAt_idx_out_of_range_warns_and_refuses()            -- L143
function M.test_insertAt_nil_handler_warns()                             -- L152
function M.test_insertAt_onactivate_failure_does_not_add()               -- L158
function M.test_insertAt_below_existing_popup_preserves_popup_active()   -- L166
function M.test_replace_deactivates_then_activates()                     -- L190
function M.test_popAbove_removes_only_above_target()                     -- L204
function M.test_popAbove_missing_target_returns_false()                  -- L218
function M.test_removeByName_top_reactivates_new_top()                   -- L229
function M.test_removeByName_middle_does_not_reactivate()                -- L239
function M.test_removeByName_absent_returns_false()                      -- L251
function M.test_drainAndRemove_finds_and_removes_named()                 -- L267
function M.test_drainAndRemove_drains_subs_via_their_esc()               -- L278
function M.test_drainAndRemove_hard_pops_when_sub_has_no_esc()           -- L296
function M.test_drainAndRemove_hard_pops_when_sub_esc_throws()           -- L307
function M.test_drainAndRemove_absent_returns_false()                    -- L320
function M.test_drainAndRemove_no_reactivate()                           -- L328
function M.test_deactivateAll_clears_and_deactivates_each()              -- L340
function M.test_collectHelpEntries_reads_helpEntries_only()              -- L353
function M.test_collectHelpEntries_ignores_bindings_without_helpEntries() -- L367
function M.test_push_warns_when_bindings_lack_helpEntries()              -- L377
function M.test_push_does_not_warn_when_empty_helpEntries_declared()     -- L386
function M.test_collectHelpEntries_dedups_by_keyLabel_top_wins()         -- L396
function M.test_collectHelpEntries_stops_after_capture_barrier()         -- L417
function M.test_collectHelpEntries_appends_commonHelpEntries()           -- L437
function M.test_collectHelpEntries_common_does_not_duplicate_handler_label() -- L452

return M                                              -- L467
```

## Notes

Resets `HandlerStack.commonHelpEntries = {}` in setup to avoid cross-test pollution.
