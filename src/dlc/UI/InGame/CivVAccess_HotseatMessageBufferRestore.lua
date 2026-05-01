-- Hotseat-only per-player MessageBuffer save / restore. Mirrors
-- HotseatCursor: save each human player's buffer state (entries, filter,
-- position) when active player swaps away, swap their saved state back in
-- when they become active again. Without a saved entry (first activation,
-- or installListeners-cleared after load-from-game), leave
-- civvaccess_shared.messageBuffer nil so MessageBuffer.state() lazy-creates
-- a fresh table on next access.
--
-- Per-session, in-memory only. Buffer entries reference unit / city / turn
-- details that don't survive load-from-game, so the saved table is wiped
-- at every onInGameBoot.
--
-- Hooked to Events.GameplaySetActivePlayer. The engine fires this event
-- only when the active player actually changes (CvGame.cpp:5584's
-- eOldActivePlayer != eNewValue gate), and in hotseat only humans become
-- the active player (CvPlayer.cpp:15812's setActivePlayer call inside
-- setTurnActive is gated on isHuman()). So under normal play both iActive
-- and iPrev are humans here; the IsHuman gate is defensive parity with
-- HotseatCursor.

HotseatMessageBuffer = {}

local saved = {}

function HotseatMessageBuffer._onActivePlayerChanged(iActive, iPrev)
    if not Game.IsHotSeat() then
        return
    end
    if iPrev ~= nil and iPrev >= 0 then
        local priorPlayer = Players[iPrev]
        if priorPlayer ~= nil and priorPlayer:IsHuman() then
            saved[iPrev] = civvaccess_shared.messageBuffer
        end
    end
    if iActive == nil or iActive < 0 then
        return
    end
    local activePlayer = Players[iActive]
    if activePlayer == nil or not activePlayer:IsHuman() then
        return
    end
    civvaccess_shared.messageBuffer = saved[iActive]
end

function HotseatMessageBuffer.installListeners()
    saved = {}
    if not Game.IsHotSeat() then
        Log.info("HotseatMessageBuffer: not a hotseat session, skipping listener registration")
        return
    end
    if Log.installEvent(Events, "GameplaySetActivePlayer", HotseatMessageBuffer._onActivePlayerChanged,
        "HotseatMessageBuffer", "per-player buffer disabled") then
        Log.info("HotseatMessageBuffer: installed")
    end
end

function HotseatMessageBuffer._reset()
    saved = {}
end
