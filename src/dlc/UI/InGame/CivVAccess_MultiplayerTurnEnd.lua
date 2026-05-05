-- Per-remote-player turn-end announcement for networked multiplayer.
-- Civ V's only sighted-player cue when a remote human ends their turn is
-- the MPList row dimming on the right side of the HUD; without speech, a
-- blind player has no way to tell who is still acting and who the wave
-- is waiting on. This module routes each remote-human turn-end into a
-- queued speech line plus a "notification" entry in the message buffer.
--
-- Signal: Events.RemotePlayerTurnEnd. Fires with no args (the engine's
-- ICvDLLUserInterface::PublishRemotePlayerTurnEnd is parameterless), so
-- we diff HasReceivedNetTurnComplete against a per-turn set of already-
-- announced player IDs. The set is cleared on Events.NewGameTurn, which
-- marks the start of a fresh turn cycle for the whole game (not just for
-- the local player). Using Events.ActivePlayerTurnStart instead would be
-- wrong in sequential MP: that fires when the local human's turn comes
-- up mid-cycle, while already-ended remote players still carry the
-- net-turn-complete flag, so a later RemotePlayerTurnEnd for any other
-- player would rescan and re-announce them.
--
-- Boot seeding matters: civvaccess_shared persists across load-from-game,
-- and a load mid-simul-turn lands in a state where some remote players
-- are already ended. Seeding the set from current state on every
-- installListeners() prevents the next RemotePlayerTurnEnd from
-- "discovering" everyone whose turn ended before the load.
--
-- Filter chain: network MP, not the local active player, IsHuman, IsAlive,
-- not Observer, Network.IsPlayerConnected. AI turn-ends flow through the
-- same event but are noise -- the engine drives AI deterministically and
-- the user is not waiting on any specific AI. A disconnected human has
-- been taken over by the AI; same reasoning, skip it.
--
-- Speech path: speakQueued + MessageBuffer.append(..., "notification"),
-- matching MultiplayerRewards. Turn-end fires arrive alongside other
-- inter-turn announcements; queueing avoids clipping prior lines.

MultiplayerTurnEnd = {}

local function isAnnounceable(pPlayer)
    local id = pPlayer:GetID()
    if id == Game.GetActivePlayer() then
        return false
    end
    if not pPlayer:IsHuman() then
        return false
    end
    if not pPlayer:IsAlive() then
        return false
    end
    if pPlayer:IsObserver() then
        return false
    end
    if not Network.IsPlayerConnected(id) then
        return false
    end
    return true
end

local function announcedSet()
    local s = civvaccess_shared.mpTurnEnded
    if s == nil then
        s = {}
        civvaccess_shared.mpTurnEnded = s
    end
    return s
end

local function clearSet()
    local s = announcedSet()
    for k in pairs(s) do
        s[k] = nil
    end
end

function MultiplayerTurnEnd._onRemoteTurnEnd()
    if not Game:IsNetworkMultiPlayer() then
        return
    end
    local s = announcedSet()
    for i = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        local pPlayer = Players[i]
        if isAnnounceable(pPlayer) and pPlayer:HasReceivedNetTurnComplete() and not s[i] then
            s[i] = true
            local text = Text.format("TXT_KEY_PLAYER_TURN_ENDED", pPlayer:GetNickName())
            Events.AudioPlay2DSound("AS2D_IF_MP_CHAT_DING")
            SpeechPipeline.speakQueued(text)
            MessageBuffer.append(text, "notification")
        end
    end
end

function MultiplayerTurnEnd._onNewGameTurn()
    clearSet()
end

function MultiplayerTurnEnd.installListeners()
    clearSet()
    if Game:IsNetworkMultiPlayer() then
        local s = announcedSet()
        for i = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
            local pPlayer = Players[i]
            if isAnnounceable(pPlayer) and pPlayer:HasReceivedNetTurnComplete() then
                s[i] = true
            end
        end
    end
    Log.installEvent(Events, "RemotePlayerTurnEnd", MultiplayerTurnEnd._onRemoteTurnEnd, "MultiplayerTurnEnd")
    Log.installEvent(Events, "NewGameTurn", MultiplayerTurnEnd._onNewGameTurn, "MultiplayerTurnEnd")
end
