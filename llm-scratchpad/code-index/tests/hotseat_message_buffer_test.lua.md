# tests/hotseat_message_buffer_test.lua

Lines: 222
Purpose: Tests `HotseatMessageBufferRestore` — per-player `civvaccess_shared.messageBuffer` save / restore on `GameplaySetActivePlayer`. Covers hotseat gate, save / restore round-trips, AI-active skip, negative event args, and `installListeners` wipe of saved table.

## Top comment

```
-- HotseatMessageBuffer tests. Engine seams stubbed: Game.IsHotSeat,
-- Players[i] (per-player IsHuman), Events.GameplaySetActivePlayer
-- (capturing listener registration). The module manipulates
-- civvaccess_shared.messageBuffer directly, so tests assert on that slot
-- and seed it as the production MessageBuffer would.
```

## Outline

```lua
local T = require("support")                          -- L7
local M = {}                                          -- L8

local activePlayerListeners                           -- L10
local hotseat                                         -- L11

local function fireActivePlayerChanged(iActive, iPrev) -- L13
local function makePlayer(opts)                       -- L19
local function makeBuf(entries, filter, position)     -- L28
local function setup()                                -- L36

function M.test_no_listener_registered_outside_hotseat()                 -- L62
function M.test_handler_inert_if_hotseat_flips_off_after_install()        -- L71
function M.test_human_prior_player_buffer_saved_and_restored()           -- L83
function M.test_round_trip_preserves_independent_buffers()               -- L104
function M.test_first_activation_leaves_live_nil_for_lazy_fresh()        -- L126
function M.test_ai_prior_player_buffer_not_saved()                       -- L140
function M.test_no_restore_when_active_player_is_ai()                    -- L160
function M.test_negative_prev_player_skips_save()                        -- L173
function M.test_negative_active_player_skips_restore()                   -- L190
function M.test_install_listeners_wipes_saved()                          -- L208

return M                                              -- L222
```
