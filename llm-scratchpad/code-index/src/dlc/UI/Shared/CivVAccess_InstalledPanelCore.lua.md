# `src/dlc/UI/Shared/CivVAccess_InstalledPanelCore.lua`

642 lines · Installed-mods panel data module providing picker and reader builders for the ModsBrowser screen, with speech-friendly confirmation subs for disable/delete/unsubscribe.

## Header comment

```
-- InstalledPanel data module. Two public fns:
--   InstalledPanel.buildPickerItems(entryFactory, handlerRefThunk) - picker-
--     tab items for the current g_SortedMods (one Entry per installed mod
--     that can be activated; Text leaves for download / install progress
--     rows which cannot), followed by Sort-by and Options tail groups.
--   InstalledPanel.buildReader(handlerRef, id) - reader-tab leaves for the
--     mod identified by id: header fields (version, author, supports-SP/MP,
--     affects saves, updated, description), dependency / reference / blocker
--     bullets, and the action leaves (Enable or Disable gated on state,
--     Update when NeedsUpdate, Delete or Unsubscribe gated on ownership).
-- [... design notes ...]
```

## Outline

- L34: `InstalledPanel = {}`
- L36: `local READER_TAB_IDX = 2`
- L42: `local CAN_ENABLE_REASON = {...}`
- L55: `local function parseId(id)`
- L76: `local function findRowById(modId, version)`
- L88: `local function canEnableReason(modId, version)`
- L109: `local function addField(leaves, headerKey, value)`
- L120: `local function yesNoLabel(value)`
- L130: `local function dependencyBullets(leaves, modId, version, modDetails)`
- L244: `local function pushDisableConfirmSub(mainHandler, modId, version, dependents)`
- L290: `local function pushDeleteConfirmSub(mainHandler, modId, version, displayName)`
- L342: `local function pushUnsubscribeConfirmSub(mainHandler, modId, version, displayName)`
- L378: `function InstalledPanel.buildReader(mainHandler, id)`
- L508: `local function pickerLabel(row)`
- L532: `function InstalledPanel.buildPickerItems(entryFactory, mainHandlerRef)`
- L642: `return InstalledPanel`

## Notes

- L55 `parseId`: splits on the last colon (not the first) to handle ModIds that themselves contain colons (some Steam Workshop mod ids do).
- L130 `dependencyBullets`: strips the CivVAccess DLC's own GUID from the DLC association list so the user doesn't hear "depends on Civ V Access" for every installed mod.
