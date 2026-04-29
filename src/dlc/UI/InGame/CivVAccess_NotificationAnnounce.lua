-- Announces incoming engine notifications through the speech pipeline.
--
-- Rebroadcast suppression. UI.RebroadcastNotifications re-fires
-- Events.NotificationAdded for every undismissed notification the active
-- player holds. NotificationPanel.lua calls it at module load and inside
-- its Events.GameplaySetActivePlayer handler. seenIds is snapshotted at
-- install (covering the at-load-time backlog) and reseated on every
-- GameplaySetActivePlayer (covering hotseat / MP / observer handoffs).
-- Our handler runs after NotificationPanel's, by which point the
-- rebroadcast wave has flooded into pending synchronously, but nothing
-- has spoken yet (speech only fires from the next-tick drain). We sweep
-- pending in the same handler.
--
-- Debounce. Each add pushes batchStartAt forward; the drain holds until
-- DEBOUNCE_SECONDS of quiet have passed. A wave of inter-turn adds
-- (wars declared, wonders built elsewhere) collapses into one drain pass
-- regardless of how many entries land.
--
-- Turn-start hold. ActivePlayerTurnStart sets holdUntil = now +
-- TURN_START_HOLD_SECONDS. Drain blocks until time >= holdUntil. The
-- engine fires its popup storm (production blockers, tech choices,
-- diplomacy) right around turn start; the hold buys those popups a head
-- start so they begin speaking before notifications come through.
--
-- Speech priority. Every notification goes through speakQueued. The
-- engine's popup speech also flows through SpeechPipeline, so a
-- speakInterrupt on the first notification would cut a popup mid-line
-- after the hold expires. Queueing keeps both audible.

NotificationAnnounce = {}

local DEBOUNCE_SECONDS = 0.2
local TURN_START_HOLD_SECONDS = 0.5

-- Swappable seam for tests. Wall-clock seconds; same source SpeechPipeline
-- uses for its dedupe window.
NotificationAnnounce._timeSource = os.clock

local seenIds = {}
local pending = {}
local batchStartAt = 0
local holdUntil = 0
local drainScheduled = false

function NotificationAnnounce._reset()
    seenIds = {}
    pending = {}
    batchStartAt = 0
    holdUntil = 0
    drainScheduled = false
end

local function schedule()
    if drainScheduled then
        return
    end
    drainScheduled = true
    TickPump.runOnce(NotificationAnnounce._drain)
end

function NotificationAnnounce._drain()
    drainScheduled = false
    if #pending == 0 then
        return
    end
    local now = NotificationAnnounce._timeSource()
    if now - batchStartAt < DEBOUNCE_SECONDS or now < holdUntil then
        schedule()
        return
    end
    for _, e in ipairs(pending) do
        SpeechPipeline.speakQueued(e.text)
        MessageBuffer.append(e.text, "notification")
    end
    pending = {}
end

-- ePlayer is not a "target" field -- for several notification types the
-- engine passes the civ the notification is *about* (the enemy that
-- declared war, the minor civ we met, the barbarian that spawned rebels).
-- Base NotificationPanel.lua uses it only for portrait lookups, never as
-- a filter, and we follow suit: NotificationAdded only fires for the local
-- player's notification list, so any add we see is already ours.
function NotificationAnnounce._onAdded(id, _ntype, toolTip, summary, _iGameValue, _iExtra, _ePlayer)
    if seenIds[id] then
        return
    end
    seenIds[id] = true
    local text = summary
    if text == nil or text == "" then
        text = toolTip
    end
    if text == nil or text == "" then
        return
    end
    pending[#pending + 1] = { id = id, text = text }
    batchStartAt = NotificationAnnounce._timeSource()
    schedule()
end

function NotificationAnnounce._onTurnStart()
    holdUntil = NotificationAnnounce._timeSource() + TURN_START_HOLD_SECONDS
end

local function snapshotExisting()
    local player = Players[Game.GetActivePlayer()]
    if player == nil then
        Log.warn("NotificationAnnounce: active player is nil at snapshot")
        return 0
    end
    local num = player:GetNumNotifications()
    for i = 0, num - 1 do
        seenIds[player:GetNotificationIndex(i)] = true
    end
    return num
end

-- See the rebroadcast-suppression note in the module header. The wave has
-- already gone through _onAdded into pending by the time we run; we
-- discard pending and reseat seenIds from the new active player's standing
-- list (in case Ids are per-player, the previous player's Ids would
-- otherwise collide and false-suppress a real new add for this player).
--
-- Atomic swap: build the new seenIds in a local first, only commit on
-- success. If the active player is nil here, we keep the prior seenIds
-- untouched -- a stale set may false-suppress a real new add (silence for
-- one event), but wiping seenIds without repopulating would let the
-- entire rebroadcast wave through as "unseen" the moment any add slips
-- past the pending clear (a backlog flood). Silence is the safer
-- failure mode.
function NotificationAnnounce._onActivePlayerChanged(_iActive, _iPrev)
    pending = {}
    local player = Players[Game.GetActivePlayer()]
    if player == nil then
        Log.error(
            "NotificationAnnounce: active player is nil at GameplaySetActivePlayer; preserving prior seenIds to avoid backlog flood"
        )
        return
    end
    local fresh = {}
    local num = player:GetNumNotifications()
    for i = 0, num - 1 do
        fresh[player:GetNotificationIndex(i)] = true
    end
    seenIds = fresh
end

-- Registers fresh listeners on every call (onInGameBoot invokes this once
-- per game load). See CivVAccess_Boot.lua's LoadScreenClose registration
-- for the rationale: prior-Context listener closures die on
-- load-game-from-game.
function NotificationAnnounce.install()
    local snapshotted = snapshotExisting()
    Events.NotificationAdded.Add(NotificationAnnounce._onAdded)
    Events.GameplaySetActivePlayer.Add(NotificationAnnounce._onActivePlayerChanged)
    Events.ActivePlayerTurnStart.Add(NotificationAnnounce._onTurnStart)
    Log.info("NotificationAnnounce: installed, snapshotted " .. tostring(snapshotted) .. " existing notifications")
end
