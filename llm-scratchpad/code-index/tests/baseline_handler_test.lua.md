# tests/baseline_handler_test.lua

Lines: 296
Purpose: Tests `BaselineHandler` — handler shape and dispatch wiring for the in-game cursor key map and surveyor Shift-letter bindings. Cursor binding integration is covered by `cursor_test`; surveyor scope by `surveyor_test`.

## Top comment

```
-- BaselineHandler now owns the in-game cursor key map and concats the
-- surveyor's Shift-letter bindings. The integration of cursor bindings
-- (cursor movement, owner-prefix diff, etc.) is covered by cursor_test;
-- the surveyor's scope logic by surveyor_test. This suite asserts only
-- handler shape and dispatch wiring so a future refactor that breaks
-- the bindings tables is caught here.
```

## Outline

```lua
local T = require("support")                          -- L8
local M = {}                                          -- L9

local function setup()                                -- L11
local function findBinding(h, key, mods)              -- L201

function M.test_create_returns_named_handler_with_help_entries()         -- L174
function M.test_passthrough_covers_f_row_and_escape()                    -- L184
function M.test_movement_bindings_dispatch_to_cursor_with_correct_direction() -- L209
function M.test_plain_s_reads_unit_at_tile()                             -- L218
function M.test_shift_s_speaks_coordinates()                             -- L226
function M.test_number_keys_dispatch_to_city_info()                      -- L233
function M.test_enter_dispatches_to_cursor_activate()                    -- L244
function M.test_f10_fires_advisor_counsel_popup()                        -- L251
function M.test_shift_letter_cluster_dispatches_to_surveyor()            -- L275

return M                                              -- L296
```
