# `src/dlc/UI/Shared/CivVAccess_Settings.lua`

356 lines · Settings overlay (F12) implemented as a `BaseMenu` handler, exposing mod-wide toggles and sliders whose state is persisted via `Prefs` and cached on `civvaccess_shared`.

## Header comment

```
-- Settings overlay. Opens via the F12 pre-walk hook in InputRouter and
-- gives the user a single place to flip mod-wide preferences. Built as a
-- BaseMenu handler with three items today (audio cue mode, master volume,
-- scanner auto-move); new settings drop in by appending to the items list.
--
-- The handler is reachable from every Context that routes through
-- InputRouter (front-end and in-game both), so its items must not assume
-- in-game state is available. Persistence goes through the canonical pref
-- key + civvaccess_shared cache field for each setting; the in-game
-- consumer module (ScannerNav, AudioCueMode, VolumeControl) reads the
-- same cache so the menu and its consumers stay in sync without a
-- registration system.
```

## Outline

- L14: `Settings = {}`
- L20: `local function getScannerAutoMove()`
- L24: `local function setScannerAutoMove(v)`
- L37: `civvaccess_shared.readSubtitles = ...`
- L41: `local function getReadSubtitles()`
- L45: `local function setReadSubtitles(v)`
- L59: `civvaccess_shared.cursorFollowsSelection = ...`
- L63: `local function getCursorFollowsSelection()`
- L67: `local function setCursorFollowsSelection(v)`
- L81: `local CURSOR_COORD_BY_INT = { ... }`
- L82: `local CURSOR_COORD_BY_NAME = { ... }`
- L83: `civvaccess_shared.cursorCoordMode = ...`
- L88: `local function getCursorCoordMode()`
- L92: `local function setCursorCoordMode(name)`
- L109: `civvaccess_shared.borderAlwaysAnnounce = ...`
- L113: `local function getBorderAlwaysAnnounce()`
- L117: `local function setBorderAlwaysAnnounce(v)`
- L127: `civvaccess_shared.scannerCoords = ...`
- L131: `local function getScannerCoords()`
- L135: `local function setScannerCoords(v)`
- L145: `civvaccess_shared.revealAnnounce = ...`
- L149: `local function getRevealAnnounce()`
- L153: `local function setRevealAnnounce(v)`
- L165: `civvaccess_shared.aiCombatAnnounce = ...`
- L169: `local function getAiCombatAnnounce()`
- L173: `local function setAiCombatAnnounce(v)`
- L183: `civvaccess_shared.foreignUnitWatchAnnounce = ...`
- L187: `local function getForeignUnitWatchAnnounce()`
- L191: `local function setForeignUnitWatchAnnounce(v)`
- L201: `civvaccess_shared.foreignClearWatchAnnounce = ...`
- L205: `local function getForeignClearWatchAnnounce()`
- L209: `local function setForeignClearWatchAnnounce(v)`
- L218: `local function audioCueModeChoice(modeConst, textKey)`
- L230: `local function cursorCoordModeChoice(name, textKey)`
- L242: `local function buildItems()`
- L325: `local SETTINGS_HELP_EXTRAS = { ... }`
- L332: `function Settings.open()`

## Notes

- L37, L59, L83, L109, L127, L145, L165, L183, L201: Each setting initializes its `civvaccess_shared` field at include time (guarded by `== nil`) by reading from `Prefs`, so the cache is seeded on first load.
- L332 `Settings.open`: adds an F12-close binding directly to the created handler after `BaseMenu.create` returns, so F12 toggles the overlay off when `Settings` is already on top.
