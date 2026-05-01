# `src/dlc/UI/Shared/CivVAccess_MPGameSetupShared.lua`

322 lines · Shared helpers for multiplayer game-setup screens (Host and StagingRoom), building map-type size labels and dynamic children for victory, game options, and DLC groups.

## Header comment

```
-- Shared helpers for screens that surface MPGameOptions. Consumed by
-- MPGameSetupAccess (the Host screen) and StagingRoomAccess (the lobby).
-- Both screens include MPGameOptions.lua, so they draw from the same
-- GameInfo.MapScripts/Maps iteration, the same Victory / GameOptions /
-- DLC managers, and the same sort order (raw string compare, no Random
-- seed, no t[0]). Pulldown index i lines up one-to-one with ipairs i.
--
-- Dependencies: BaseMenuItems.Checkbox / Pulldown, Text.key / Text.format,
-- Log.warn. Consumers must include CivVAccess_FrontendCommon first.
--
-- Cache lifetime: the map-size labels cache is session-sticky across a
-- screen show/hide but must be invalidated when the underlying pulldown is
-- repopulated. Consumers call MPGameSetupShared.invalidateMapLabels() in
-- their showPanel / onShow path.
```

## Outline

- L16: `MPGameSetupShared = {}`
- L20: `local function safeText(getter, context)`
- L34: `local function worldNameById(worldID)`
- L42: `local function worldNameByType(typeKey)`
- L59: `local _mpMapSizeLabelsCache`
- L61: `function MPGameSetupShared.invalidateMapLabels()`
- L65: `local function mpMapTypeSizeLabels()`
- L145: `function MPGameSetupShared.mapTypeEntryAnnounce(inst, index)`
- L175: `local EXCLUDED_GAME_OPTION_TYPES = {...}`
- L184: `local function mpSortOptions(options)`
- L193: `function MPGameSetupShared.victoryChildren()`
- L211: `local function gameOptionDropdownRows()`
- L231: `local function gameOptionCheckboxRows()`
- L264: `function MPGameSetupShared.gameOptionsChildren()`
- L301: `function MPGameSetupShared.dlcChildren()`

## Notes

- L59 `_mpMapSizeLabelsCache`: module-level upvalue; invalidated by `invalidateMapLabels()` whenever the map-type pulldown is repopulated (consumers must call this in their onShow/showPanel path).
- L184 `mpSortOptions`: sorts by SortPriority first, then raw `a.Name < b.Name` (not `Locale.Compare`), matching MP's exact iteration order so allocated-instance indices align.
