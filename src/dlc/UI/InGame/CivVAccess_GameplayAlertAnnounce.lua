-- Announces engine "gameplay alert" floating messages through the speech
-- pipeline. Events.GameplayAlertMessage is a floating-alert channel,
-- distinct from the notification system: LekMod's custom-civ ability logic
-- (prophetreplace and the other custom-civ scripts) fires its ability
-- feedback through it -- Nabatea discovery gold, New Zealand meeting yields,
-- Bolivia, golden-age-from-political-prowess, and many more. On LekMod it is
-- the only channel for that feedback. Base InGame.lua renders these visually
-- (OnGameplayAlertMessage); without this listener a blind player hears
-- nothing. The event is vanilla, so this also surfaces the rare base / VP
-- alerts that flow through the same channel.
--
-- Queued, not interrupt: the alerts can arrive in a burst (several ability
-- triggers resolve together at end of a turn), so queueing keeps each one
-- audible rather than the burst cutting itself down to the last line --
-- matching how NotificationAnnounce treats a notification wave. Filtering is
-- the pipeline's job: speakQueued runs the text through TextFilter, so the
-- raw markup the engine sends is stripped before it is spoken, and the same
-- raw text stored in the message buffer is filtered again on read-back.
--
-- A handful of alerts also post a notification carrying the same text, which
-- would double-announce (once here, once through NotificationAnnounce). Most
-- alerts are floating-only; the overlap set is identified during the live
-- text audit and is not guarded here, since a blanket text-dedup across the
-- two channels would also suppress a legitimately repeated alert.

GameplayAlertAnnounce = {}

function GameplayAlertAnnounce._onAlert(text)
    if text == nil or text == "" then
        return
    end
    SpeechPipeline.speakQueued(text)
    MessageBuffer.append(text, "notification")
end

-- Idempotent within one Context lifetime via a file-scope local, matching
-- ChatBuffer / StagingRoomAccess. onInGameBoot runs on every LoadScreenClose,
-- which fires more than once against the same env (multiplayer resyncs, hotseat
-- handoff); without the guard each run adds another live GameplayAlertMessage
-- listener and one alert speaks two or three times. A civvaccess_shared flag
-- would persist across load-from-game and strand the mod on the dead prior-env
-- listener (CLAUDE.md's no-install-once-guards rule); the file-scope local
-- resets when Boot re-includes this chunk on WorldView re-init, so a fresh env
-- still gets a fresh listener.
local listenersInstalled = false

function GameplayAlertAnnounce.install()
    if listenersInstalled then
        return
    end
    listenersInstalled = true
    Log.installEvent(Events, "GameplayAlertMessage", GameplayAlertAnnounce._onAlert, "GameplayAlertAnnounce")
    Log.info("GameplayAlertAnnounce: installed")
end
