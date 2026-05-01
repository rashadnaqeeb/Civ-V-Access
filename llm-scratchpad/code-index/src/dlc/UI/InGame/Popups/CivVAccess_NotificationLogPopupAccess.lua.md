# `src/dlc/UI/InGame/Popups/CivVAccess_NotificationLogPopupAccess.lua`

175 lines · Accessibility wrapper for the notification log popup, presenting active notifications, a mod-authored turn log (foreign unit/clear/combat deltas), and dismissed notifications as three navigable tabs.

## Header comment

```
-- NotificationLogPopup accessibility. BUTTONPOPUP_NOTIFICATION_LOG lists
-- every notification the active player has received this game, dismissed
-- or not. Three tabs:
--   Active    notifications whose dismissed flag is false (still on the
--             right-side stack for a sighted player).
--   Turn Log  mod-authored cross-turn surfaces that don't live on the
--             engine's notification list: the ForeignUnitWatch four-line
--             delta (units entered / left view during the AI turn), the
--             ForeignClearWatch line (camps and ruins others claimed in
--             view), and the CombatLog group (one entry per combat
--             announced while the player was waiting). All clear at the
--             next TurnEnd.
--   Dismissed notifications whose dismissed flag is true (activated,
--             right-clicked, or auto-expired by the engine).
-- Enter on an active entry calls NotificationSelected(id), which is the
-- game's own OnClose + UI.ActivateNotification path. On a dismissed entry
-- activation is a no-op: the engine disables those buttons on sighted
-- UI, and calling ActivateNotification on a stale id has undefined
-- behavior.
--
-- After NotificationSelected fires, we ask CameraTracker to wait for the
-- engine's camera pan to settle and then jump the cursor onto the look-at
-- plot. This covers every notification whose Activate() in the engine ends
-- up calling lookAt(plot) -- ruins, barbarians, war declarations, enemy in
-- territory, etc -- because the engine emits no other Lua-observable
-- signal for those. Notifications that open a popup instead of panning
-- (production, tech, diplomacy) leave the camera still; CameraTracker's
-- timeout drops the cursor jump silently in that case.
--
-- Items rebuild from Players[active]:GetNumNotifications() on every open
-- via onShow. No caching. The game's OnPopup rebuilds its own visual row
-- stack in parallel; both read from the engine's authoritative list. The
-- menu's Tab key (BaseMenu default) switches between tabs; Esc falls
-- through priorInput to the popup's own handler which dismisses.
```

## Outline

- L59: `local priorInput = InputHandler`
- L60: `local priorShowHide = ShowHideHandler`
- L62: `local function emptyItem()`
- L69: `local function activateAndFollow(notificationId)`
- L78: `local function appendDeltaLines(turnLog, delta)`
- L87: `local function buildItems()`
- L147: `local function onShow(handler)`
- L154: `BaseMenu.install(ContextPtr, { ... })`
