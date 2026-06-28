-- MPTurnPanel accessibility wiring, appended to our MPTurnPanel.lua
-- override. This is the one Context where the EXE injects
-- getEndTurnTimerLength() and fires Events.EndTurnTimerUpdate, the only
-- source of the multiplayer end-turn timer's remaining time -- the engine
-- binds no pull API for it. We mirror the latest pushed value onto
-- civvaccess_shared so the T-key status line (CivVAccess_EmpireStatus) can
-- read it, and drive the last-15-seconds tick cue here.
--
-- Per-Context include chain: MPTurnPanel is its own LuaContext with its own
-- globals, so the shared stems must load into this sandbox before we touch
-- Log / Prefs / TurnTimer. The engine's VFS indexes by bare stem and
-- re-runs each file per Context.
--
-- Fresh listener every include, no install-once guard: load-game-from-game
-- wipes this Context's env and strands any listener that closed over it
-- (see CivVAccess_Boot.lua's LoadScreenClose note). This mirrors base
-- MPTurnPanel.lua's own Events.EndTurnTimerUpdate.Add at include scope, so
-- our listener's survival across that transition is identical to the base
-- timer display's. The audio bank load is install-once because the bank
-- itself survives the wipe.

include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_UserPrefs")
include("CivVAccess_EndTurnTimer")

-- Tick toggle (F12 Notifications group, default on). Seeded here as well as
-- in Settings so the live read below is correct regardless of which Context
-- ran first; defineBoolPref is a no-op once the field is set.
if civvaccess_shared.turnTimerTick == nil then
    civvaccess_shared.turnTimerTick = Prefs.getBool("TurnTimerTick", true)
end

TurnTimer.loadAll()

-- The local player's own active, unsubmitted turn -- the only situation
-- whose countdown is the player's to act on. During AI / unit processing,
-- other players' sequential turns, or after the player has readied up, the
-- on-screen countdown keeps moving but is not the player's own clock. Both
-- the spoken T-line (via the mirror) and the tick gate on this so they
-- agree: the T-line never reports another player's countdown as the local
-- player's remaining time.
local function isMyActiveTurn()
    local player = Players[Game.GetActivePlayer()]
    if player == nil or not player:IsTurnActive() then
        return false
    end
    if PreGame.IsMultiplayerGame() and Network.HasSentNetTurnComplete() then
        return false
    end
    return true
end

local function onEndTurnTimerUpdate(percentComplete)
    -- length 0 is the engine holding the timer at the turn boundary while
    -- AI / unit processing finishes; no meaningful remaining time yet. The
    -- mirror is cleared unless it is the local player's own active turn, so
    -- the T-line never speaks a countdown that is not the player's clock.
    -- (or short-circuits the per-frame isMyActiveTurn cost on length-0 frames.)
    local length = getEndTurnTimerLength()
    if length == nil or length <= 0 or not isMyActiveTurn() then
        civvaccess_shared.turnTimerSeconds = nil
        civvaccess_shared.turnTimerLastTick = nil
        return
    end
    local secs = TurnTimer.remainingSeconds(percentComplete, length)
    civvaccess_shared.turnTimerSeconds = secs

    -- not muted: the tick is event-driven (it bypasses the InputRouter mute
    -- gate that suppresses the cursor / scanner cues), so the master mute
    -- must be honored here or it would keep sounding while everything else
    -- is silenced.
    if civvaccess_shared.turnTimerTick == true and not civvaccess_shared.muted then
        local play, lastTick = TurnTimer.tickStep(secs, civvaccess_shared.turnTimerLastTick)
        civvaccess_shared.turnTimerLastTick = lastTick
        if play then
            TurnTimer.playTick()
        end
    else
        civvaccess_shared.turnTimerLastTick = nil
    end
end

Events.EndTurnTimerUpdate.Add(onEndTurnTimerUpdate)

Log.info("MPTurnPanelAccess: end-turn timer wiring installed")
