# `src/dlc/UI/InGame/CivVAccess_NotificationAnnounce.lua`

159 lines · Intercepts engine notification events and speaks them through the pipeline with debounce, turn-start hold, and rebroadcast suppression.

## Header comment

```
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
```

## Outline

- L30: `NotificationAnnounce = {}`
- L32: `local DEBOUNCE_SECONDS = 0.2`
- L33: `local TURN_START_HOLD_SECONDS = 0.5`
- L37: `NotificationAnnounce._timeSource = os.clock`
- L39: `local seenIds = {}`
- L40: `local pending = {}`
- L41: `local batchStartAt = 0`
- L42: `local holdUntil = 0`
- L43: `local drainScheduled = false`
- L45: `function NotificationAnnounce._reset()`
- L53: `local function schedule()`
- L61: `function NotificationAnnounce._drain()`
- L84: `function NotificationAnnounce._onAdded(id, _ntype, toolTip, summary, _iGameValue, _iExtra, _ePlayer)`
- L101: `function NotificationAnnounce._onTurnStart()`
- L105: `local function snapshotExisting()`
- L131: `function NotificationAnnounce._onActivePlayerChanged(_iActive, _iPrev)`
- L152: `function NotificationAnnounce.install()`
- L154: `Events.NotificationAdded.Add(NotificationAnnounce._onAdded)`
- L155: `Events.GameplaySetActivePlayer.Add(NotificationAnnounce._onActivePlayerChanged)`
- L156: `Events.ActivePlayerTurnStart.Add(NotificationAnnounce._onTurnStart)`

## Notes

- L37 `NotificationAnnounce._timeSource`: Public field intentionally exposed as a seam so tests can inject a fake clock without patching `os`.
- L84 `_onAdded`: The `_ePlayer` arg is the civ the notification is *about*, not a filter target; all adds seen by this handler are already for the local player.
