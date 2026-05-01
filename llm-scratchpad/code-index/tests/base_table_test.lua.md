# tests/base_table_test.lua

Lines: 462
Purpose: Tests `BaseTableCore` — navigation, sort, search, dedup, and lifecycle behavior against a synthetic data model without engine globals.

## Top comment

```
-- BaseTable tests. Loads the production module against a synthetic data
-- model so navigation, sort, search, dedup, and lifecycle behavior can be
-- exercised without engine globals.
```

## Outline

```lua
local T = require("support")                          -- L5
local M = {}                                          -- L6

local warns, errors                                   -- L8
local speaks                                          -- L9
local pediaCalls                                      -- L10

local function setup()                                -- L12
local function makeBasicSpec()                        -- L64
local function findBinding(h, key, mods)              -- L201

function M.test_create_requires_tabName()                                    -- L112
function M.test_create_requires_columns()                                    -- L120
function M.test_create_requires_rebuildRows_and_rowLabel()                   -- L128
function M.test_create_shape()                                               -- L141
function M.test_first_open_announce_false_chains_first_cell_queued()         -- L155
function M.test_first_open_announce_true_speaks_tabName_then_cell()          -- L166
function M.test_reactivation_after_deactivate_preserves_cursor()             -- L176
function M.test_down_navigates_data_rows_no_wrap()                           -- L211
function M.test_up_from_first_data_row_moves_to_header()                     -- L225
function M.test_left_right_wrap_columns()                                    -- L237
function M.test_home_jumps_to_first_data_row_end_jumps_to_last()             -- L252
function M.test_dedup_elides_row_label_when_only_column_changes()            -- L268
function M.test_dedup_elides_column_name_when_only_row_changes()             -- L281
function M.test_enter_on_header_cycles_sort_descending_first()               -- L296
function M.test_enter_on_header_cycles_through_asc_then_cleared()            -- L315
function M.test_enter_on_header_for_unsortable_column_is_silent()            -- L334
function M.test_enter_on_data_row_invokes_column_enterAction()               -- L350
function M.test_enter_on_data_row_without_action_re_speaks_cell()            -- L364
function M.test_search_jumps_to_matching_column()                            -- L378
function M.test_search_ignores_ctrl_chord()                                  -- L391
function M.test_ctrl_i_invokes_pedia_when_column_provides_pediaName()        -- L402
function M.test_ctrl_i_binding_absent_when_no_column_has_pediaName()         -- L417
function M.test_rebuildRows_called_fresh_on_each_navigation()                -- L426
function M.test_empty_table_lands_on_header_row()                            -- L446

return M                                              -- L462
```
