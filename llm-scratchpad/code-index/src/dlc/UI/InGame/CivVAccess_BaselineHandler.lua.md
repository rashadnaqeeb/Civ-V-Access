# `src/dlc/UI/InGame/CivVAccess_BaselineHandler.lua`

432 lines · Bottom-of-stack HandlerStack handler that owns map cursor movement, overview hotkeys, and aggregates bindings from all sibling modules into a single capturesAllInput barrier.

## Header comment

```
-- Routes the in-game cursor keys (Q/A/Z/E/D/C movement, S unit-at-tile,
-- W economy, X combat, Shift+S coordinates) to the Cursor module, plus
-- the Shift-letter surveyor cluster to SurveyorCore. Sits at the bottom
-- of the
-- HandlerStack so any popup / overlay above it that sets capturesAllInput
-- will pre-empt both clusters without us having to coordinate.
--
-- capturesAllInput = true: Baseline eats every unbound key on the map.
-- The mod reimplements every map-mode action we expose to the user, so
-- letting the engine's huge mission / build / automate key set fire under
-- us would be noise (keys that pick up different meanings depending on
-- the selected unit are impossible to speak consistently). passthroughKeys
-- carves out the minimum set we explicitly want the engine to still
-- handle: F1-F12 (advisor screens, strategic view, quick save/load,
-- Ctrl+F10 select capital, Ctrl+F11 quick load all hang off F-row
-- keycodes) and Escape (opens the pause menu, which our GameMenuAccess
-- then layers over). Popups above Baseline set their own capturesAllInput
-- without a passthrough list, so F-keys and Escape are correctly
-- swallowed while any dialog or menu is up.
--
-- F10 is both passed through AND bound: the plain-F10 binding wins at the
-- bindings-loop stage (InputRouter matches key + mods) and fires the
-- advisor counsel popup, overriding the engine's strategic-view toggle
-- which is useless to blind players. Ctrl+F10 has no mods=2 binding here
-- so it falls through the bindings loop, hits the passthrough check on
-- keycode alone, and reaches the engine's select-capital binding intact.
-- Rebinding F10 is the accessibility path because the engine's native
-- hotkey for advisor counsel is KB_V, which Baseline swallows as an
-- unbound letter.
--
-- Help entries are composed as one unified map-mode list in eight sections:
-- tile info (cursor cluster), game info (T/R/G/H/F/P/I empire-status keys),
-- unit control, turn lifecycle, surveyor, scanner (pulled from
-- ScannerHandler.HELP_ENTRIES), bookmarks (Ctrl/Shift/Alt + digit), and
-- function-row keys that open engine screens (F1-F9, plus our F10 rebind).
-- Scanner is always on the stack alongside Baseline in-game, so its entries
-- belong inside this ordered list rather than at the top (which is what a
-- top-down HandlerStack.collectHelpEntries walk would produce if Scanner
-- authored its own helpEntries). The F1-F9 entries describe engine behavior
-- reached via passthroughKeys; they have no Baseline binding.
```

## Outline

- L42: `BaselineHandler = {}`
- L44: `local MOD_NONE = 0`
- L45: `local MOD_SHIFT = 1`
- L46: `local MOD_CTRL = 2`
- L48: `local VK_OEM_5 = 220`
- L50: `local function speak(s)`
- L57: `local bind = HandlerStack.bind`
- L63: `local function moveDir(dir)`
- L69: `local MOVEMENT_AND_INFO_HELP_ENTRIES = {...}`
- L119: `local FUNCTION_KEY_HELP_ENTRIES = {...}`
- L182: `local function appendAll(dst, src)`
- L191: `function BaselineHandler.create()`

## Notes

- L191 `BaselineHandler.create`: Returns a handler table (not a module); also aggregates bindings and help entries from SurveyorCore, UnitControl, Turn, EmpireStatus, TaskList, Bookmarks, and MessageBuffer into a single unified Baseline handler.
