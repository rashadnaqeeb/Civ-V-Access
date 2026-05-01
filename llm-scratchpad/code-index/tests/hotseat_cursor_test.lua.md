# tests/hotseat_cursor_test.lua

Lines: 313
Purpose: Tests `HotseatCursorRestore` — per-player cursor save / restore on `GameplaySetActivePlayer`. Covers hotseat gate, save-on-handoff for human prior players, restore branches (turn-0 settler, saved position, capital fallback, no-op when no target), AI-active skip, and edge cases on negative event args.

## Top comment

```
-- HotseatCursor tests. Engine seams stubbed: Game.IsHotSeat /
-- GetGameTurn, Players[i] (per-player IsHuman / Units / GetCapitalCity),
-- Map.GetPlot (saved-position lookup), Cursor.position / Cursor.jumpTo
-- (capturing stubs). Events.GameplaySetActivePlayer captures the
-- registered listener so tests can fire synthetic transitions.
```

## Outline

```lua
local T = require("support")                          -- L7
local M = {}                                          -- L8

local activePlayerListeners                           -- L10
local jumpCalls                                       -- L11
local cursorPos                                       -- L12
local hotseat                                         -- L13
local gameTurn                                        -- L14

local function fireActivePlayerChanged(iActive, iPrev) -- L16
local function makePlot(x, y)                         -- L22
local function makeUnit(x, y, isFound)                -- L33
local function makePlayer(opts)                       -- L46
local function setup()                                -- L71

function M.test_no_listener_registered_outside_hotseat()                 -- L115
function M.test_handler_inert_if_hotseat_flips_off_after_install()        -- L127
function M.test_human_prior_player_cursor_saved()                        -- L141
function M.test_ai_prior_player_cursor_not_saved()                       -- L157
function M.test_turn_zero_restores_to_settler_even_if_saved()            -- L184
function M.test_turn_zero_falls_back_to_capital_if_no_settler()          -- L208
function M.test_saved_position_used_after_turn_zero()                    -- L225
function M.test_capital_fallback_when_no_saved()                         -- L241
function M.test_no_op_when_target_player_has_no_capital_and_no_saved()   -- L257
function M.test_no_restore_when_active_player_is_ai()                    -- L272
function M.test_negative_prev_player_skips_save()                        -- L284
function M.test_negative_active_player_skips_restore()                   -- L297

return M                                              -- L313
```
