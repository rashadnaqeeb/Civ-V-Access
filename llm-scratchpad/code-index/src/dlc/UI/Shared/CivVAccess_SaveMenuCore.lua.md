# `src/dlc/UI/Shared/CivVAccess_SaveMenuCore.lua`

378 lines · Save-game menu data module providing picker and reader builders for disk and Steam Cloud save slots, with speech-friendly overwrite and delete confirmation subs.

## Header comment

```
-- SaveMenu data module. Two public fns:
--   SaveMenu.buildPickerItems(entryFactory, handlerRef) - picker-tab items.
--     Local mode: Textfield for NameBox (gated on NameBoxFrame visibility),
--     Save action, Steam Cloud checkbox, and one Entry per existing save in
--     g_SavedGames. Cloud mode: Steam Cloud checkbox and one Entry per slot
--     (1..s_maxCloudSaves), populated or empty.
--   SaveMenu.buildReader(handlerRef, id) - reader-tab leaves for the save
--     or cloud slot identified by id: the save's header fields plus an
--     Overwrite (or Save-to-slot for empty cloud slots) action, and Delete
--     for disk saves.
--
-- Why bypass the base OnSave / OnDelete wiring: OnSave's collision branch
-- pops Controls.DeleteConfirm (a sighted-only overlay) [...].
-- [... never-cache, entry id scheme documented ...]
```

## Outline

- L32: `SaveMenu = {}`
- L34: `local READER_TAB_IDX = 2`
- L36: `local HEADER_KEYS = SavedGameShared.HEADER_KEYS`
- L37: `local stripPath = SavedGameShared.stripPath`
- L38: `local parseId = SavedGameShared.parseId`
- L39: `local resolveLeaderCiv = SavedGameShared.resolveLeaderCiv`
- L40: `local gameTypeLabel = SavedGameShared.gameTypeLabel`
- L41: `local descOf = SavedGameShared.descOf`
- L42: `local addField = SavedGameShared.addField`
- L44: `local function isMultiplayerStarted()`
- L55: `local function performSaveDisk(text)`
- L66: `local function performSaveCloud(slotIndex)`
- L77: `local function performDelete(filename)`
- L85: `local function pushConfirmSub(mainHandler, subSuffix, promptLabel, onYes)`
- L116: `local function pushOverwriteDiskConfirm(mainHandler, entry, saveText)`
- L123: `local function pushOverwriteCloudConfirm(mainHandler, slotIndex)`
- L130: `local function pushDeleteConfirm(mainHandler, entry)`
- L145: `local function onSaveActivate(mainHandler)`
- L165: `function SaveMenu.buildReader(mainHandler, id)`
- L294: `function SaveMenu.buildPickerItems(entryFactory, mainHandlerRef)`
- L378: `return SaveMenu`

## Notes

- L145 `onSaveActivate`: wraps the Textfield's `priorCallback` to suppress the `bIsEnter=true` path (which would invoke base's OnSave and open the sighted collision overlay); Enter-commit from edit mode calls `priorCallback(text, control, false)` instead, leaving the actual save action to this function.
- L44 `isMultiplayerStarted`: distinguishes copy-last-autosave (MP) from direct save (SP) for both disk and cloud paths.
