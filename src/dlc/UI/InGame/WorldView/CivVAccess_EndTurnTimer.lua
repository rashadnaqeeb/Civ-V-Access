-- File stem is CivVAccess_EndTurnTimer, not CivVAccess_TurnTimer: the latter
-- has CivVAccess_Turn (the end-turn module) as a prefix, and Civ V's stem
-- index silently drops the shorter of two prefix-sharing stems, which would
-- stop include("CivVAccess_Turn") from loading. The exported table stays
-- TurnTimer.
--
-- Multiplayer end-turn timer audio and math. The engine surfaces the
-- timer only by pushing Events.EndTurnTimerUpdate(percentComplete) (see
-- base UI/InGame/WorldView/MPTurnPanel.lua:OnEndTurnTimerUpdate); it binds
-- no pull API for the remaining time. CivVAccess_MPTurnPanelAccess sits in
-- that same Context, mirrors the latest value onto civvaccess_shared for
-- the T-key status line, and drives the last-15-seconds tick through the
-- helpers here. Keeping the math and the audio in one tested module leaves
-- the wrapper as thin Context glue.

TurnTimer = {}

-- The countdown ticks once per whole second across this final window.
local TICK_WINDOW_SECONDS = 15

-- Seconds remaining, mirroring base MPTurnPanel.OnEndTurnTimerUpdate:
-- ceil(length - length * percentComplete), floored at zero. length is
-- getEndTurnTimerLength() in seconds; percentComplete is 0 at the start of
-- the timer and approaches 1 as it runs out.
function TurnTimer.remainingSeconds(percentComplete, length)
    local secs = math.ceil(length - (length * percentComplete))
    if secs < 0 then
        secs = 0
    end
    return secs
end

-- One tick per whole second across [1, TICK_WINDOW_SECONDS]. Returns
-- (shouldPlay, nextLastTick): play when this second is inside the window
-- and differs from the second last ticked; outside the window the dedup
-- resets to nil so re-entering ticks again. EndTurnTimerUpdate fires many
-- times per displayed second, so the dedup is what holds it to one tick.
function TurnTimer.tickStep(secs, lastTick)
    if secs >= 1 and secs <= TICK_WINDOW_SECONDS then
        if secs ~= lastTick then
            return true, secs
        end
        return false, lastTick
    end
    return false, nil
end

-- Preload the tick cue into the proxy audio bank. Install-once: the bank
-- survives the load-from-game env wipe, so the handle on civvaccess_shared
-- is the guard (mirrors PlotAudio / ScannerBeep). Logs once so a missing
-- binding or a saturated bank surfaces in Lua.log instead of going silent.
function TurnTimer.loadAll()
    if civvaccess_shared.turnTimerTickHandle ~= nil then
        return
    end
    if audio == nil then
        Log.warn("TurnTimer.loadAll: audio binding missing")
        return
    end
    local h = audio.load("tick")
    if h == nil then
        Log.error("TurnTimer.loadAll: failed to load tick")
        return
    end
    civvaccess_shared.turnTimerTickHandle = h
    Log.info("TurnTimer.loadAll: loaded")
end

-- Play one tick. No-op when the bank load failed: a nil handle means loadAll
-- bailed (audio binding absent or load failed, both already logged at boot),
-- so the handle guard alone covers the missing-audio case.
function TurnTimer.playTick()
    local h = civvaccess_shared.turnTimerTickHandle
    if h == nil then
        return
    end
    audio.play(h)
end
