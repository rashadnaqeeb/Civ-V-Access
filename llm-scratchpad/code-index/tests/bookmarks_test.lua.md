# tests/bookmarks_test.lua

Lines: 242
Purpose: Tests the `Bookmarks` module — per-session digit-keyed cursor positions plus `Ctrl+S` jump-to-capital. Covers save, overwrite, warn-on-unset, jumpTo delegation to `ScannerNav.jumpCursorTo`, directionTo HERE at zero distance, coord segment under `scannerCoords` toggle, `resetForNewGame`, and `jumpToCapital`.

## Top comment

```
-- Bookmarks: per-session digit-keyed cursor positions plus the Ctrl+S
-- permanent jump-to-capital. Each test exercises a path the others
-- don't: save populates a slot, save warns when the cursor is unset,
-- jumpTo rejects empty slots, jumpTo delegates to ScannerNav.jumpCursorTo
-- (which owns the at-target SCANNER_HERE short-circuit and the pre-jump
-- anchor; covered in scanner_navigation_test), directionTo speaks HERE
-- at zero distance, directionTo composes the optional coord segment
-- under the scannerCoords toggle, resetForNewGame drops every slot,
-- jumpToCapital speaks NO_CAPITAL pre-founding and otherwise delegates
-- to jumpCursorTo with the live capital plot.
```

## Outline

```lua
local T = require("support")                          -- L12
local M = {}                                          -- L13

local cursorPosition                                  -- L15

local function setup()                                -- L17

function M.test_save_populates_slot_and_returns_added_string()           -- L63
function M.test_save_overwrites_prior_slot()                             -- L72
function M.test_save_warns_when_cursor_unset()                           -- L82
function M.test_jumpTo_speaks_no_bookmark_on_empty_slot()                -- L97
function M.test_jumpTo_delegates_to_jumpCursorTo()                       -- L110
function M.test_directionTo_speaks_HERE_when_cursor_on_bookmark()        -- L127
function M.test_directionTo_returns_direction_string()                   -- L136
function M.test_directionTo_appends_coord_when_scannerCoords_on()        -- L151
function M.test_directionTo_omits_coord_when_scannerCoords_off()         -- L170
function M.test_resetForNewGame_drops_every_slot()                       -- L187
function M.test_getBindings_returns_thirtyone_bindings_and_three_help_entries() -- L198
function M.test_jumpToCapital_speaks_no_capital_pre_founding()           -- L214
function M.test_jumpToCapital_delegates_to_jumpCursorTo_with_capital_plot() -- L226

return M                                              -- L242
```
