# `src/dlc/UI/InGame/CivVAccess_Bookmarks.lua`

178 lines · Per-session digit-keyed cursor bookmarks (Ctrl+1-0 save, Shift+1-0 jump, Alt+1-0 direction) plus a permanent Ctrl+S jump-to-capital.

## Header comment

```
-- Per-session digit-keyed cursor bookmarks plus the Ctrl+S permanent
-- jump-to-capital. Ctrl + 1-0 saves the cursor's current (x, y) into
-- the slot, Shift + 1-0 jumps the cursor there (with backspace return
-- via the scanner's pre-jump cell), Alt + 1-0 speaks a direction (and
-- optional capital-relative coord, gated on the scanner's coord
-- setting) from the live cursor to the saved cell. Ctrl+S is the
-- equivalent of a permanent slot for the player's current capital.
-- All three jumps go through ScannerNav.jumpCursorTo, the shared
-- mark-then-jump primitive that also handles the cursor-already-at-
-- target case (speaks SCANNER_HERE rather than re-running the full
-- glance).
--
-- Lives here rather than inline in BaselineHandler because the jump
-- pattern is identical to the slot jumps and this file already has
-- the Cursor / ScannerNav dependencies wired up at boot. The Ctrl+S
-- help entry is author'd in BaselineHandler so it sits next to the
-- Shift+S coordinate readout in the map-mode help list.
--
-- Storage shape: civvaccess_shared.bookmarks[slot] = {x, y}. Slot
-- key is the literal digit string ("1".."9","0") -- same form as
-- Keys["1"] dispatch. onInGameBoot calls resetForNewGame before any
-- binding can fire, so the table is always non-nil at access time.
-- Not persisted to the save file: Civ V's save format has no mod-
-- controlled extension point, and any custom payload on a save would
-- risk multiplayer-hash drift.
```

## Outline

- L27: `Bookmarks = {}`
- L29: `local MOD_SHIFT = 1`
- L30: `local MOD_CTRL = 2`
- L31: `local MOD_ALT = 4`
- L33: `local SLOT_KEYS = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }`
- L35: `function Bookmarks.resetForNewGame()`
- L39: `function Bookmarks.save(slot)`
- L55: `function Bookmarks.jumpTo(slot)`
- L70: `local function capitalPlot()`
- L87: `function Bookmarks.jumpToCapital()`
- L100: `function Bookmarks.directionTo(slot)`
- L121: `local bind = HandlerStack.bind`
- L123: `local function speak(s)`
- L130: `local function saveBinding(slot)`
- L136: `local function jumpBinding(slot)`
- L142: `local function directionBinding(slot)`
- L148: `function Bookmarks.getBindings()`

## Notes

- L70 `capitalPlot`: Returns the active player's *current* capital (not original capital), matching Cursor.init's initial placement rather than HexGeom.activeOriginalCapital which Shift+S coordinates use.
