# `src/dlc/UI/Shared/CivVAccess_CameraTracker.lua`

191 lines · Tracks the engine's world camera by decoding the 4x4 view matrix from CameraViewChanged to compute look-at grid coordinates, enabling cursor follow-on-notification-pan.

## Header comment

```
-- Tracks the engine's world camera. Subscribes to Events.CameraViewChanged,
-- which the events catalog claims is no-arg but actually fires with a 4x4
-- row-major view matrix every frame the camera animates. The matrix's bottom
-- row is the world-to-camera translation; inverting it (eye = -t * R^T)
-- gives the eye world position, then we cast a ray through the camera's
-- forward axis to the Z=0 ground plane to get the look-at point.
--
-- Why this matters: the engine's notification activate path (default branch
-- in CvNotifications::Activate) calls lookAt(plot) directly in C++ for
-- camera-only notifications (NOTIFICATION_GOODY, BARBARIAN, ENEMY_*, WAR,
-- etc). No Lua-observable selection event fires, no plot accessor exists on
-- the notification record, and there's no UI.GetMapCenter. CameraViewChanged
-- is the only signal that survives back into Lua, and the matrix it carries
-- is the only way to recover where the camera ended up.
-- [... world/grid math documented ...]
```

## Outline

- L26: `CameraTracker = {}`
- L28: `local SETTLE_FRAMES = 8`
- L29: `local MAX_WAIT_FRAMES = 120`
- L31: `local function readOriginAndStride()`
- L44: `local function onCameraViewChanged(matrix)`
- L54: `function CameraTracker.install()`
- L73: `function CameraTracker.getLookAtGrid()`
- L124: `function CameraTracker.followAndJumpCursor()`
- L149: `function CameraTracker.followNextSettle(callback)`
- L180: `function CameraTracker._reset()`
- L191: `Events.CameraViewChanged.Add(onCameraViewChanged)` (inside `CameraTracker.install`)

## Notes

- L54 `CameraTracker.install`: re-registers a fresh `CameraViewChanged` listener on every call (once per game load), re-reads origin/stride because those are map-layout constants that change across games in the same lua_State.
- L149 `CameraTracker.followNextSettle`: uses a generation counter so a second follower supersedes a racing first one; callback fires only after the camera both starts moving and settles for SETTLE_FRAMES ticks.
- L73 `CameraTracker.getLookAtGrid`: uses the view matrix's R[2] row (not -R[3]) as the forward axis, per empirical verification of Civ V's non-standard row layout.
