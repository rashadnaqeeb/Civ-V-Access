# `src/dlc/UI/Shared/CivVAccess_LoadReplayMenuCore.lua`

348 lines · Load-replay menu data module providing picker and reader builders for replay files, mirroring the LoadMenu pattern with replay-specific sort and action leaves.

## Header comment

```
-- LoadReplayMenu data module. Two public fns:
--   LoadReplayMenu.buildPickerItems(entryFactory, handlerRef) - picker-tab
--     items for the current g_FileList, followed by a Sort-by Group.
--     One Entry per replay; label is the bare filename (path / extension
--     stripped, same as engine).
--   LoadReplayMenu.buildReader(handlerRef, id) - reader-tab leaves for the
--     replay identified by id: header fields plus Select / Delete /
--     Show-DLC / Show-Mods action leaves.
-- [... design notes ...]
```

## Outline

- L26: `LoadReplayMenu = {}`
- L28: `local READER_TAB_IDX = 2`
- L30: `local HEADER_KEYS = SavedGameShared.HEADER_KEYS`
- L31: `local stripPath = SavedGameShared.stripPath`
- L32: `local parseId = SavedGameShared.parseId`
- L33: `local resolveLeaderCiv = SavedGameShared.resolveLeaderCiv`
- L34: `local descOf = SavedGameShared.descOf`
- L35: `local addField = SavedGameShared.addField`
- L45: `local function sortedFileIndices()`
- L78: `local function applySort(entryFactory, handlerRefThunk, sortFn, labelKey)`
- L90: `local function pushRequirementsSub(mainHandler, kind)`
- L134: `local function pushDeleteConfirmSub(mainHandler, filename)`
- L175: `function LoadReplayMenu.buildReader(mainHandler, id)`
- L298: `function LoadReplayMenu.buildPickerItems(entryFactory, mainHandlerRef)`
- L348: `return LoadReplayMenu`

## Notes

- L175 `LoadReplayMenu.buildReader`: calls `SetSelected(idx)` as a side effect, which populates the SelectReplayButton's disabled state and tooltip (Modding.CanLoadReplay reason) before the button leaf is built.
