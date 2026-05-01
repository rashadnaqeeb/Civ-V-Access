# tests/cursor_activate_test.lua

Lines: 205
Purpose: Tests `CursorActivate._buildEntries` — entry list ordering and filtering rules (city first, military, civilian; invisible / foreign-owner filtered; air and cargo aircraft included). The BaseMenu install path and `HandlerStack` push semantics are not covered here.

## Top comment

```
-- CursorActivate enumeration tests. Exercises _buildEntries against fake
-- plots + units to confirm the entry list honors the documented rules:
-- city first, then active-player military units, then active-player
-- civilian units, with invisible / foreign-owner units filtered out
-- and air units (including cargo aircraft on a carrier) included. The
-- BaseMenu install path (run's modal push) is not covered offline --
-- HandlerStack push semantics are covered by handler_stack_test; this
-- suite is just about what goes into the picker.
```

## Outline

```lua
local T = require("support")                          -- L10
local M = {}                                          -- L11

local function setup()                                -- L13

function M.test_empty_plot_produces_no_entries()                         -- L42
function M.test_city_only_produces_single_city_entry()                   -- L48
function M.test_city_label_prefixes_name()                               -- L58
function M.test_own_military_only()                                      -- L70
function M.test_own_civilian_only()                                      -- L80
function M.test_city_then_military_then_civilian_ordering()              -- L90
function M.test_multiple_military_units_listed_individually()            -- L110
function M.test_air_unit_included_under_military()                       -- L123
function M.test_invisible_unit_filtered()                                -- L137
function M.test_cargo_aircraft_included()                                -- L144
function M.test_carrier_with_cargo_lists_both()                          -- L160
function M.test_foreign_unit_not_listed_even_when_visible()              -- L177
function M.test_foreign_city_with_own_garrison_lists_both()              -- L188

return M                                              -- L205
```
