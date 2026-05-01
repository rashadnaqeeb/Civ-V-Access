# `src/dlc/UI/InGame/CivVAccess_HotseatCursorRestore.lua`

100 lines · Hotseat-only per-player cursor position save/restore on Events.GameplaySetActivePlayer: saves the outgoing player's cursor and restores the incoming player's, seeding from their settler on turn 0.

## Header comment

```
-- Hotseat-only per-player cursor save / restore. In a hotseat session,
-- save each human player's cursor at end-of-turn and restore it when
-- their next turn begins. Turn 0 seeds to the player's settler instead
-- of using a saved position so each player starts looking at their own
-- founder. Without a saved position (e.g. session start from a loaded
-- save), falls back to the player's capital city.
--
-- Per-session, in-memory only. Saved (x, y) on a different map are the
-- wrong cells, so a load-from-game wipes the table; the capital fallback
-- is the explicit recovery for that case. installListeners runs from
-- onInGameBoot at LoadScreenClose, which is the load-from-game seam.
--
-- Hooked to Events.GameplaySetActivePlayer. The event fires before the
-- PlayerChange password popup appears, with both the new and previous
-- active player IDs as args, so the prior player's cursor save and the
-- new player's restore happen in one event handler. Restoration is
-- silent: Cursor.jumpTo composes a glance string but never speaks; the
-- caller (us) discards it. PlotAudio cues still emit if the user has
-- them enabled, which is the normal cursor-move behavior.
```

## Outline

- L21: `HotseatCursor = {}`
- L23: `local saved = {}`
- L25: `local function findSettler(player)`
- L33: `local function targetForPlayer(ePlayer)`
- L56: `function HotseatCursor._onActivePlayerChanged(iActive, iPrev)`
- L79: `function HotseatCursor.installListeners()`
- L97: `function HotseatCursor._reset()`
