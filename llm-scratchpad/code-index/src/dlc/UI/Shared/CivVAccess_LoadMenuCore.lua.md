# `src/dlc/UI/Shared/CivVAccess_LoadMenuCore.lua`

448 lines · Load-game menu data module providing picker and reader builders for regular, autosave, and Steam Cloud save files, with sort replication and speech-friendly delete confirmation.

## Header comment

```
-- LoadMenu data module. Two public fns:
--   LoadMenu.buildPickerItems(entryFactory, handlerRef) - picker-tab items
--     for the current g_FileList (regular / autosave mode) or g_CloudSaves
--     (Steam Cloud mode), followed by the Autosaves / Steam Cloud filter
--     checkboxes. One Entry per save (or populated cloud slot); label is the
--     bare filename with path and extension stripped (matches engine UI).
--   LoadMenu.buildReader(handlerRef, id) - reader-tab leaves for the save
--     identified by id: the save's header fields plus Load / Delete /
--     Show-DLC / Show-Mods action leaves.
-- [... design notes ...]
```

## Outline

- L30: `LoadMenu = {}`
- L32: `local READER_TAB_IDX = 2`
- L34: `local HEADER_KEYS = SavedGameShared.HEADER_KEYS`
- L35: `local stripPath = SavedGameShared.stripPath`
- L36: `local parseId = SavedGameShared.parseId`
- L37: `local resolveLeaderCiv = SavedGameShared.resolveLeaderCiv`
- L38: `local gameTypeLabel = SavedGameShared.gameTypeLabel`
- L39: `local descOf = SavedGameShared.descOf`
- L40: `local addField = SavedGameShared.addField`
- L53: `local function sortedFileIndices()`
- L96: `local function applySort(entryFactory, handlerRefThunk, sortFn, labelKey)`
- L108: `local function pushRequirementsSub(mainHandler, kind)`
- L152: `local function pushDeleteConfirmSub(mainHandler, filename)`
- L198: `function LoadMenu.buildReader(mainHandler, id)`
- L355: `function LoadMenu.buildPickerItems(entryFactory, mainHandlerRef)`
- L448: `return LoadMenu`

## Notes

- L53 `sortedFileIndices`: reads all filesystem mtimes up front before sorting to avoid N log N filesystem round-trips inside `table.sort`'s comparator.
- L198 `LoadMenu.buildReader`: calls `SetSelected(idx)` as a side effect to sync engine state (populates g_SavedGameModsRequired / g_SavedGameDLCRequired and the StartButton disabled state) before building leaves.
