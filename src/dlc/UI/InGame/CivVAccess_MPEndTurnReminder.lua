-- !!! MULTIPLAYER (SIMULTANEOUS TURNS) MODULE !!!
--
-- Guards against a trap unique to simultaneous-turns multiplayer: you press
-- end turn, then wander into a screen to pass the time, and an action there
-- (issuing an order, resolving a choice, anything that raises a new end-turn
-- blocker) makes the engine quietly pull your turn back. The "Waiting for
-- players" button reverts to "End Turn" and you are active again -- but the
-- only cue is visual, so a blind player keeps waiting on a wave that is now
-- waiting on them.
--
-- Detection: the submitted state is Network.HasSentNetTurnComplete(). The
-- engine's pull-back is that flag flipping true -> false within the same game
-- turn (CvGame/CvPlayer call gDLL->sendTurnUnready() + setEndTurn(false) when
-- a new blocker appears post-submit). We poll it every frame through a
-- TickPump subscriber rather than an Events listener because the poll has to
-- keep running while the user is off in a screen Context, which is exactly
-- when the trap springs -- the active-handler tick stops there, a subscriber
-- does not.
--
-- A genuine new turn also flips the flag true -> false. To never mistake that
-- for a cancellation we pre-clear the tracked submitted flag whenever the game
-- turn changes (polled, not event-driven, so it is immune to event ordering):
-- after a turn rollover the next observation sees false -> false, no
-- transition.
--
-- Alert policy: once armed by a cancellation, alert only while the player is
-- the SOLE remaining holdout (every other connected human has ended) -- that
-- is the moment the whole game is stalled on them. The first qualifying poll
-- fires immediately; it then repeats every REMINDER_INTERVAL_SECONDS until the
-- player re-submits or the turn advances. If the cancellation happens while
-- others are still acting, we stay armed but silent and fire the instant the
-- last of them ends.
--
-- Time source: os.date is available in Civ V UI Lua (base MainMenu.lua uses
-- it) and gives true wall-clock seconds, so the cadence is correct regardless
-- of how often the poll runs -- which varies, since TickPump can be installed
-- on more than one Context at once.
--
-- The attention cue is the engine's MP turn-end chat ding, the same sound
-- MultiplayerTurnEnd plays for a remote player ending their turn.
--
-- Sampling cadence. Every read below (Game.*, Players[], Network.*) crosses
-- into the game core, and the engine serialises those behind the game-core
-- lock while the UI thread holds the script lock. The game core takes those
-- two in the opposite order whenever it calls out to Lua from inside doTurn,
-- so a UI thread sitting inside an engine read is one half of a deadlock --
-- see docs/llm-docs/mp-deadlock.md. Running this poll on every frame, in
-- networked multiplayer only, kept the UI thread inside that window a large
-- fraction of the time. One sample per wall-clock second is ample for a
-- sixty-second reminder and cuts the exposure by two orders of magnitude.
-- Sampling this slowly cannot miss the transition it watches for: the
-- engine's pull-back persists until the player re-submits, so a later sample
-- still observes submitted -> not-submitted within the turn.
--
-- Listeners (the TickPump subscription) are re-established on every
-- onInGameBoot; see CivVAccess_Boot.lua for why install-once guards are wrong
-- across load-from-game.

MPEndTurnReminder = {}

local REMINDER_INTERVAL_SECONDS = 60
local SUBSCRIBER_NAME = "MPEndTurnReminder"
local DING_SOUND = "AS2D_IF_MP_CHAT_DING"

-- Monotonic wall-clock seconds, except across a year boundary, where yday
-- resets; the cadence check treats a backward jump as "interval elapsed", so
-- the once-a-year rollover at most fires one early reminder. Seam-exposed so
-- tests drive a synthetic clock.
local function wallClockSeconds()
    local t = os.date("!*t")
    return t.yday * 86400 + t.hour * 3600 + t.min * 60 + t.sec
end
MPEndTurnReminder._now = wallClockSeconds

-- A connected human, other than us, whose unfinished turn the wave could be
-- waiting on. Observers and dead / AI-replaced slots do not hold the wave.
local function holdsTheWave(playerID)
    local p = Players[playerID]
    if not p:IsHuman() or not p:IsAlive() or p:IsObserver() then
        return false
    end
    return Network.IsPlayerConnected(playerID)
end

-- True when every other player that could hold the wave has already ended, so
-- the game is waiting on us alone.
local function isSoleHoldout(meId)
    for i = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        if i ~= meId and holdsTheWave(i) and not Players[i]:HasReceivedNetTurnComplete() then
            return false
        end
    end
    return true
end

local function announce()
    Events.AudioPlay2DSound(DING_SOUND)
    local text = Text.key("TXT_KEY_CIVVACCESS_MP_TURN_REMINDER")
    SpeechPipeline.speakInterrupt(text)
    MessageBuffer.append(text, "notification")
end

-- Poll driven by the TickPump subscription, rate-limited to one sample per
-- wall-clock second. The gate runs before any engine read -- that is the whole
-- point of it -- and _now's one-second resolution makes it idempotent when
-- TickPump fires the subscriber more than once in a frame.
function MPEndTurnReminder._poll()
    local S = civvaccess_shared
    local sampleAt = MPEndTurnReminder._now()
    if S.mpReminderLastSample == sampleAt then
        return
    end
    S.mpReminderLastSample = sampleAt
    if not Game:IsNetworkMultiPlayer() then
        return
    end
    local meId = Game.GetActivePlayer()
    local me = Players[meId]
    if me == nil or not me:IsSimultaneousTurns() then
        -- Sequential MP cannot submit-then-revert, and being the last to act
        -- is the normal state of a sequential turn, so nagging there would
        -- fire every turn. Drop any armed state from a prior simultaneous
        -- phase (dynamic turns can switch mode mid-game).
        S.mpReminderArmed = false
        S.mpReminderLastAlert = nil
        return
    end

    local turn = Game.GetGameTurn()
    if S.mpReminderTurn ~= turn then
        S.mpReminderTurn = turn
        S.mpReminderSubmitted = false
        S.mpReminderArmed = false
        S.mpReminderLastAlert = nil
    end

    local submittedNow = Network.HasSentNetTurnComplete()
    local prevSubmitted = S.mpReminderSubmitted
    S.mpReminderSubmitted = submittedNow

    if submittedNow then
        -- Submitted (again): the wave is no longer held on our account.
        S.mpReminderArmed = false
        S.mpReminderLastAlert = nil
        return
    end

    if prevSubmitted then
        -- Was submitted, now is not, same game turn: the engine pulled our
        -- ready back. Arm, and clear the last-alert stamp so the first
        -- qualifying poll fires immediately.
        S.mpReminderArmed = true
        S.mpReminderLastAlert = nil
    end

    if not S.mpReminderArmed or S.mpTurnReminder == false then
        return
    end
    if not me:IsTurnActive() or not isSoleHoldout(meId) then
        return
    end

    local now = MPEndTurnReminder._now()
    local last = S.mpReminderLastAlert
    if last == nil or now < last or (now - last) >= REMINDER_INTERVAL_SECONDS then
        announce()
        S.mpReminderLastAlert = now
    end
end

function MPEndTurnReminder.installListeners()
    if civvaccess_shared.mpTurnReminder == nil then
        civvaccess_shared.mpTurnReminder = Prefs.getBool("MPTurnReminder", true)
    end
    -- Reset tracking each game / load: civvaccess_shared survives the env
    -- wipe, so a prior game's armed state must not leak into a fresh one.
    civvaccess_shared.mpReminderTurn = nil
    civvaccess_shared.mpReminderSubmitted = false
    civvaccess_shared.mpReminderArmed = false
    civvaccess_shared.mpReminderLastAlert = nil
    civvaccess_shared.mpReminderLastSample = nil
    TickPump.subscribe(SUBSCRIBER_NAME, MPEndTurnReminder._poll)
end
