# tests/foreign_unit_watch_test.lua

Lines: 526
Purpose: Tests `ForeignUnitWatch` — snapshot-diff at turn boundaries, four output buckets (hostile/neutral entered/left). Covers diff buckets, skip rules (own/teammate/dead/invisible/fogged), deterministic aggregation ordering, mid-turn war/peace diplomacy transitions, F7 delta, speech gate, and delta reset on turn end.

## Top comment

```
-- ForeignUnitWatch: snapshot-diff at turn boundaries, four-line output
-- (hostile/neutral entered/left). Tests exercise the diff buckets, the
-- skip-rules, and the deterministic aggregation ordering.
```

## Outline

```lua
local T = require("support")                          -- L6
local M = {}                                          -- L7

local function makeUnit(opts)                         -- L14
local function makePlayer(opts)                       -- L39
local function visiblePlot()                          -- L78
local function fogPlot()                              -- L82
local function setup()                                -- L88
local function installForeign(id, opts)               -- L174

function M.test_empty_initial_state_no_announce()                        -- L189
function M.test_neutral_unit_enters_view()                               -- L198
function M.test_hostile_unit_enters_view()                               -- L214
function M.test_unit_walks_into_fog()                                    -- L228
function M.test_unit_destroyed_silently_drops()                          -- L246
function M.test_persistent_unit_no_delta()                               -- L262
function M.test_war_declared_mid_turn_unit_still_visible()               -- L276
function M.test_peace_declared_mid_turn_no_announce()                    -- L298
function M.test_aggregation_same_civ_same_unit_type()                    -- L314
function M.test_aggregation_two_civs_alphabetic_order()                  -- L335
function M.test_skip_own_units()                                         -- L361
function M.test_skip_teammate_units()                                    -- L374
function M.test_skip_dead_player_units()                                 -- L388
function M.test_skip_invisible_units()                                   -- L401
function M.test_skip_units_on_fogged_plots()                             -- L414
function M.test_barbarian_treated_as_hostile()                           -- L427
function M.test_multiple_lines_speech_order()                            -- L445
function M.test_delta_stored_for_f7()                                    -- L480
function M.test_announce_off_silent_but_delta_still_set()                -- L495
function M.test_delta_cleared_on_turn_end()                              -- L511

return M                                              -- L526
```

## Notes

Monkey-patches `Text.key` and `Text.format` directly rather than going through the polyfill, so unit-type names resolve from a synthetic `GameInfo.UnitClasses` table.
