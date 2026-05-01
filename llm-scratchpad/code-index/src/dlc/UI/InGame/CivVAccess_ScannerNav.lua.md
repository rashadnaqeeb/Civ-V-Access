# `src/dlc/UI/InGame/CivVAccess_ScannerNav.lua`

704 lines · Scanner navigation state machine: owns the four cursor indices (category, subcategory, item, instance), snapshot lifecycle, auto-move, and all public entry points that ScannerHandler bindings call.

## Header comment

```
-- Scanner navigation state machine. Owns the four cursor indices
-- (category, subcategory, item, instance), the current snapshot, and
-- the pre-jump cell for Backspace. Every scanner binding maps to one of
-- the entry points below; the handler file is purely the (key, mods) ->
-- entry-point table (CivVAccess_ScannerHandler.lua).
--
-- Rebuild model (design section 5, revised):
-- Every navigation entry point rebuilds the snapshot from live backend
-- output. Explicit "reorient" cycles (Ctrl+PageUp/Down, Shift+PageUp/Down,
-- Ctrl+F) re-anchor the sort origin to the current cursor and land the
-- user at the front of the new scope. Every other cycle (bare, Alt,
-- Home, End) preserves the origin from the previous rebuild and
-- re-locates the user's current instance in the new snapshot by its
-- entry key, so a resort never moves them off whatever entity they were
-- pointing at. New entries that slot in behind the cursor's identity
-- appear naturally on subsequent reverse cycles; new entries that would
-- reorder existing items leave the user's cursor on the same entity at
-- its new index. A Ctrl/Shift+PageUp/Down remains the "forget where I
-- was" escape hatch.
--
-- Search snapshots (isSearch) are an exception: they are frozen slices
-- produced by applySearch and not rebuilt on navigation. Exiting search
-- (Ctrl+PageUp/Down from inside a search snapshot) rebuilds the normal
-- snapshot anchored to the cursor at exit time.
```

## Outline

- L26: `ScannerNav = {}`
- L28: `local _catIdx = 1`
- L29: `local _subIdx = 1`
- L30: `local _itemIdx = 0`
- L31: `local _instIdx = 0`
- L32: `local _snapshot = nil`
- L33: `local _preJumpX = nil`
- L34: `local _preJumpY = nil`
- L39: `local _preSearchCatIdx = nil`
- L52: `local function currentCategory()`
- L59: `local function currentSub()`
- L66: `local function currentItem()`
- L73: `local function currentInstance()`
- L83: `local function isSearchSnapshot()`
- L90: `local function landOnCurrentSub()`
- L101: `local function snapToCategoryFront()`
- L114: `local function gatherEntries()`
- L142: `local function cursorOriginOrDefault()`
- L154: `local function rebuildSnapshot(originX, originY)`
- L175: `local function rebuildAndLocate()`
- L221: `local function rebuildFromCursor()`
- L234: `local function ensureCurrentInstanceValid()`
- L297: `local function formatInstance(instance, instIdx, instCount)`
- L332: `local function announceCurrent()`
- L346: `local function announceWithLabel(labelKey)`
- L356: `local function autoMoveIfEnabled()`
- L377: `local function wrapIndex(i, n, dir)`
- L394: `local function categoryHasItems(cat)`
- L399: `local function subHasItems(sub)`
- L411: `local function nextIndexMatching(list, startIdx, dir, pred)`
- L440: `function ScannerNav.cycleCategory(dir)`
- L463: `function ScannerNav.cycleSubcategory(dir)`
- L488: `local function stepFromZero(dir, n)`
- L492: `function ScannerNav.cycleItem(dir)`
- L510: `function ScannerNav.cycleInstance(dir)`
- L532: `function ScannerNav.jumpToEntry()`
- L546: `function ScannerNav.distanceFromCursor()`
- L566: `function ScannerNav.getAutoMove()`
- L570: `function ScannerNav.setAutoMove(v)`
- L579: `function ScannerNav.toggleAutoMove()`
- L593: `function ScannerNav.markPreJump(x, y)`
- L608: `function ScannerNav.jumpCursorTo(x, y)`
- L622: `function ScannerNav.returnToPreJump()`
- L636: `function ScannerNav.openSearch()`
- L645: `function ScannerNav.applySearch(query)`
- L676: `function ScannerNav._refresh()`
- L684: `function ScannerNav._reset()`
- L692: `function ScannerNav._indices()`
- L695: `function ScannerNav._snapshot()`
- L698: `function ScannerNav._preJump()`
- L702: `function ScannerNav._preSearchCatIdx()`

## Notes

- L488 `stepFromZero`: handles the sentinel `_itemIdx == 0` / `_instIdx == 0` case; wrapIndex would skip index 1 when starting from 0 with a forward step.
- L676 `_refresh`, L684 `_reset`, L692 `_indices`, L695 `_snapshot`, L698 `_preJump`, L702 `_preSearchCatIdx`: test seams only; never called in production.
- L608 `jumpCursorTo`: shared by scanner Home, Bookmarks jump, and Bookmarks capital jump; lives here because it writes the pre-jump anchor that Backspace reads.
