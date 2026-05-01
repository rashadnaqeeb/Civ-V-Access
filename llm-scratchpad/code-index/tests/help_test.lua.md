# tests/help_test.lua

Lines: 240
Purpose: Tests the `Help` overlay — full pipeline from collecting `helpEntries` from the current stack, building `Button` items, and pushing a Help handler via `BaseMenu.create`. Runs against real `HandlerStack`, `InputRouter`, `BaseMenu`, and `Help` modules (no mocks for production code).

## Top comment

```
-- Help overlay tests. Exercises the full pipeline: collect helpEntries from
-- the current stack, build Button items from each, push a Help handler via
-- BaseMenu.create. Runs against real HandlerStack, InputRouter, TickPump,
-- Nav, PullDownProbe, BaseMenu*, and Help modules (no mocks for production
-- code).
```

## Outline

```lua
local T = require("support")                          -- L6
local M = {}                                          -- L7

local speaks                                          -- L9
local warns                                           -- L10

local function setup()                                -- L12
local function itemCount(handler)                     -- L62
local function speakTextAt(i)                         -- L67

function M.test_help_open_pushes_handler_named_Help()                    -- L73
function M.test_help_announces_screen_name_on_open()                     -- L88
function M.test_help_items_are_keyLabel_comma_description()              -- L96
function M.test_help_collects_from_stack_before_pushing_itself()         -- L117
function M.test_help_self_entries_describe_navigation_not_base_menu()    -- L139
function M.test_help_escape_pops_handler()                               -- L155
function M.test_help_shift_question_pops_handler()                       -- L166
function M.test_help_respects_captures_barrier_below()                   -- L183
function M.test_help_dedupes_keyLabel_top_wins()                         -- L209

return M                                              -- L240
```
