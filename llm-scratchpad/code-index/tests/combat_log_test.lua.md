# tests/combat_log_test.lua

Lines: 124
Purpose: Tests `CombatLog` — the AI-turn gate (records only between `TurnEnd` and the next `TurnStart`), reset-on-`TurnEnd` contract, survives-across-the-player-turn behavior the F7 popup depends on, and the hotseat active-player-change clear.

## Top comment

```
-- CombatLog: per-AI-turn capture of combat-readout text. Tests exercise
-- the AI-turn gate (only records between TurnEnd and the next TurnStart),
-- the reset-on-TurnEnd contract, and the survives-across-the-player-turn
-- behavior the F7 popup depends on.
```

## Outline

```lua
local T = require("support")                          -- L6
local M = {}                                          -- L7

local activePlayerListeners                           -- L9

local function setup()                                -- L11

function M.test_player_turn_records_nothing()                            -- L35
function M.test_ai_turn_collects_combats_in_order()                      -- L43
function M.test_list_survives_player_turn_until_next_turn_end()          -- L60
function M.test_reinstall_resets_state()                                 -- L80
function M.test_no_active_player_listener_outside_hotseat()              -- L97
function M.test_hotseat_active_player_change_clears_log()                -- L108

return M                                              -- L124
```
