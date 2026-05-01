# tests/foreign_clear_watch_test.lua

Lines: 274
Purpose: Tests `ForeignClearWatch` — counter-driven flush at turn boundaries. Covers visibility and teammate filters, singular / plural / both string shapes, the F7 delta + speech-gate split, the bracket-buffer push category, and counter reset between AI turns.

## Top comment

```
-- ForeignClearWatch: counter-driven flush at turn boundaries. Tests
-- exercise visibility and teammate filters, the singular / plural / both
-- string shapes, the F7 delta + speech-gate split, and the bracket-buffer
-- push category.
```

## Outline

```lua
local T = require("support")                          -- L6
local M = {}                                          -- L7

local function visiblePlot(x, y)                      -- L11
local function fogPlot(x, y)                          -- L15
local function installPlots(plots)                    -- L20
local function setup()                                -- L33
local function installForeign(slot, opts)             -- L78

function M.test_no_clears_no_announce()                                  -- L85
function M.test_visible_camp_cleared_by_foreign_counts()                 -- L94
function M.test_visible_ruin_cleared_by_foreign_counts()                 -- L108
function M.test_fogged_plot_skipped()                                    -- L120
function M.test_teammate_clears_skipped()                                -- L133
function M.test_unknown_actor_skipped()                                  -- L147
function M.test_plural_form_for_multiple_camps()                         -- L161
function M.test_camps_and_ruins_joined_with_and()                        -- L175
function M.test_delta_stored_for_f7()                                    -- L192
function M.test_announce_off_silent_but_delta_still_set()                -- L206
function M.test_message_buffer_push_uses_reveal_category()               -- L220
function M.test_delta_cleared_on_turn_end()                              -- L236
function M.test_counters_reset_between_ai_turns()                        -- L250

return M                                              -- L274
```

## Notes

Uses `PluralRules._setLocale("en_US")` to fix plural forms for English assertions.
