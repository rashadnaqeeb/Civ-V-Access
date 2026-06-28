-- TurnTimer: the multiplayer end-turn timer's remaining-seconds math, the
-- last-15-seconds tick window with its per-second dedup, and the install-
-- once audio bank load. Each test exercises a path the others don't:
-- the ceil/floor of remainingSeconds, the window bounds and dedup of
-- tickStep, and that loadAll loads exactly "tick" once and playTick fires
-- the loaded handle. These feed a spatial/audio boundary (a wrong second
-- reaches the spoken T-line or a stray tick fires), so they are guarded
-- even though the math looks simple.

local T = require("support")
local M = {}

local function setup()
    civvaccess_shared = civvaccess_shared or {}
    civvaccess_shared.turnTimerTickHandle = nil
    audio._reset()
    dofile("src/dlc/UI/InGame/WorldView/CivVAccess_EndTurnTimer.lua")
end

-- remainingSeconds ---------------------------------------------------------

function M.test_remaining_full_at_start()
    setup()
    T.eq(TurnTimer.remainingSeconds(0, 30), 30)
end

function M.test_remaining_ceils_partial_second()
    setup()
    -- 30s timer, 52% elapsed -> 14.4s left -> ceil 15, matching the base
    -- panel's displayed countdown.
    T.eq(TurnTimer.remainingSeconds(0.52, 30), 15)
end

function M.test_remaining_floors_at_zero()
    setup()
    -- Past full elapsed (engine can push slightly over 1.0) never goes
    -- negative.
    T.eq(TurnTimer.remainingSeconds(1.1, 30), 0)
end

-- tickStep -----------------------------------------------------------------

function M.test_tick_fires_on_new_second_in_window()
    setup()
    local play, last = TurnTimer.tickStep(15, nil)
    T.eq(play, true)
    T.eq(last, 15)
end

function M.test_tick_dedups_same_second()
    setup()
    local play, last = TurnTimer.tickStep(15, 15)
    T.eq(play, false)
    T.eq(last, 15)
end

function M.test_tick_fires_each_descending_second()
    setup()
    local play14, last14 = TurnTimer.tickStep(14, 15)
    T.eq(play14, true)
    T.eq(last14, 14)
    local play1, last1 = TurnTimer.tickStep(1, 2)
    T.eq(play1, true)
    T.eq(last1, 1)
end

function M.test_tick_silent_above_window_and_resets()
    setup()
    local play, last = TurnTimer.tickStep(16, nil)
    T.eq(play, false)
    T.eq(last, nil, "outside the window the dedup resets so re-entry ticks")
end

function M.test_tick_silent_at_zero()
    setup()
    local play, last = TurnTimer.tickStep(0, 1)
    T.eq(play, false)
    T.eq(last, nil)
end

-- loadAll / playTick -------------------------------------------------------

function M.test_loadAll_loads_tick_once()
    setup()
    TurnTimer.loadAll()
    T.eq(#audio._calls, 1)
    T.eq(audio._calls[1].op, "load")
    T.eq(audio._calls[1].name, "tick")
    T.eq(civvaccess_shared.turnTimerTickHandle, audio._calls[1].id)
end

function M.test_loadAll_is_idempotent()
    setup()
    TurnTimer.loadAll()
    audio._reset()
    TurnTimer.loadAll()
    T.eq(#audio._calls, 0, "loadAll must short-circuit once the handle is set")
end

function M.test_playTick_plays_loaded_handle()
    setup()
    TurnTimer.loadAll()
    local handle = civvaccess_shared.turnTimerTickHandle
    audio._reset()
    TurnTimer.playTick()
    T.eq(#audio._calls, 1)
    T.eq(audio._calls[1].op, "play")
    T.eq(audio._calls[1].id, handle)
end

function M.test_playTick_noop_without_handle()
    setup()
    civvaccess_shared.turnTimerTickHandle = nil
    TurnTimer.playTick()
    T.eq(#audio._calls, 0, "playTick must not fire when the bank load failed")
end

return M
