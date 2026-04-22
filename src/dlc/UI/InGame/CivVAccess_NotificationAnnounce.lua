-- Announces incoming engine notifications through the speech pipeline.
--
-- Rebroadcast suppression. UI.RebroadcastNotifications re-fires
-- Events.NotificationAdded for every undismissed notification the active
-- player holds. It runs at NotificationPanel.lua module load and on every
-- GameplaySetActivePlayer. Without filtering, we would read the player's
-- entire standing backlog on save/load and (in hotseat / MP) on every turn
-- handoff. Install snapshots the current Ids into seenIds so subsequent
-- rebroadcasts filter out; any Id we haven't seen is a genuine new add.
--
-- Burst coalescing. The engine flushes all world-tick notifications (wars
-- declared, wonders built elsewhere, etc.) synchronously in the frames
-- immediately before ActivePlayerTurnStart. Naive speech of each summary
-- buries the player under a wall of text before input returns. When three
-- or more adds land inside a six-frame window, the whole pending queue
-- collapses into a single "N new notifications" announcement. Six frames
-- is ~100-200ms at 30-60fps, which covers the engine's burst (one to a
-- few frames) without merging genuinely separate user-initiated events
-- during active play.
--
-- Burst detection runs synchronously inside the listener, using the frame
-- at the moment of the add. The alternative (checking in the tick drain)
-- fails the late-arrival case: if two adds land at frame 0 and the third
-- at frame 5, the drain at frame 6 sees frame-0 entries as one frame too
-- old to count, even though the adds are only five frames apart by any
-- reasonable reading. Checking at add time uses the frame the add was
-- actually recorded against and triggers correctly.
--
-- The per-tick drain is still needed for the fallback: when adds don't
-- reach the burst threshold, pending entries have to flush individually
-- after aging past the window. That drain reschedules itself while
-- anything remains pending.

NotificationAnnounce = {}

local BURST_WINDOW_FRAMES = 6
local BURST_THRESHOLD = 3

local seenIds = {}
local pending = {}
local drainScheduled = false

function NotificationAnnounce._reset()
    seenIds = {}
    pending = {}
    drainScheduled = false
    if civvaccess_shared ~= nil then
        civvaccess_shared.notificationAnnounceInstalled = nil
    end
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
    local now = TickPump.frame()
    local windowStart = now - BURST_WINDOW_FRAMES + 1
    local remaining = {}
    local spokeFirst = false
    for _, e in ipairs(pending) do
        if e.frame < windowStart then
            if e.summary ~= "" then
                if spokeFirst then
                    SpeechPipeline.speakQueued(e.summary)
                else
                    SpeechPipeline.speakInterrupt(e.summary)
                    spokeFirst = true
                end
            end
        else
            remaining[#remaining + 1] = e
        end
    end
    pending = remaining
    if #pending > 0 then
        schedule()
    end
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
        text = toolTip or ""
    end
    local now = TickPump.frame()
    pending[#pending + 1] = {
        id = id,
        summary = text,
        frame = now,
    }
    local windowStart = now - BURST_WINDOW_FRAMES + 1
    local recent = 0
    for _, e in ipairs(pending) do
        if e.frame >= windowStart then
            recent = recent + 1
        end
    end
    if recent >= BURST_THRESHOLD then
        local count = #pending
        pending = {}
        SpeechPipeline.speakInterrupt(Text.format("TXT_KEY_CIVVACCESS_NOTIFICATION_BURST", count))
        return
    end
    schedule()
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

function NotificationAnnounce.install()
    if civvaccess_shared.notificationAnnounceInstalled then
        return
    end
    civvaccess_shared.notificationAnnounceInstalled = true
    local snapshotted = snapshotExisting()
    Events.NotificationAdded.Add(NotificationAnnounce._onAdded)
    Log.info(
        "NotificationAnnounce: installed, snapshotted "
            .. tostring(snapshotted)
            .. " existing notifications"
    )
end
