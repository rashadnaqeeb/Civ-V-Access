# `src/dlc/UI/FrontEnd/CivVAccess_AdvancedSetupAccess.lua`

665 lines · Accessibility wiring for the Advanced Setup (single-player game configuration) screen, building a three-level nested BaseMenu over the map, player-slot, victory-condition, and game-option widgets.

## Header comment

```
-- AdvancedSetup (Single Player -> Set Up Game -> Advanced) accessibility
-- wiring. Nested menu layout:
--
--   Level 1  global settings (Map Type / Size / Handicap / Game Speed /
--            Era / Minor Civs / Max Turns), Players group, Victory
--            Conditions group, Game Options group, Defaults, Back, Start.
--   Level 2  inside Players: the human slot + each active AI slot (both
--            as groups), plus Add AI.
--   Level 3  inside a player slot: Civ, Team, and (for AI slots that allow
--            it) a Remove button; for the human slot, also Edit / cancel
--            custom-name.
--
-- The base file's dynamic data (player rows, victory / game-option
-- checkboxes, map-script dropdowns) is built through InstanceManager so
-- the widgets themselves have no stable Controls.X names. For per-player
-- widgets we read each slot's g_SlotInstances[i] entry. For victory and
-- game-option rows we iterate GameInfo (with the same sort base uses) in
-- parallel with each manager's allocated instances so the row's TXT_KEY
-- furnishes the label, avoiding GetTextButton:GetText() round-tripping
-- (which empirically returns an empty string on CheckBox widgets in this
-- engine).
--
-- Dynamic groups pass cached=false so the children rebuild on every drill;
-- PartialSync from pulldown selections can reshape the game-option set
-- without notice and slot presence can flip when Add AI / Remove fires.
```

## Outline

- L30: `local priorShowHide = ShowHideHandler`
- L31: `local priorInput = InputHandler`
- L34: `local handler`
- L35: `local buildItems`
- L43: `local _civLabelsCache`
- L44: `local function civPulldownLabels()`
- L49: `local function civEntryAnnounce(inst, index)`
- L62: `local function safeText(getter, context)`
- L76: `local function pulldownButtonText(control)`
- L105: `local function worldNameById(worldID)`
- L113: `local function worldNameByType(typeKey)`
- L121: `local _mapSizeLabelsCache`
- L122: `local function mapTypeSizeLabels()`
- L203: `local function mapTypeEntryAnnounce(inst, index)`
- L227: `local function onMaxTurnsChecked()`
- L239: `local function maxTurnsEditCallback()`
- L245: `local function humanCivText()`
- L260: `local function humanTeamText()`
- L264: `local function humanSlotLabel()`
- L268: `local function humanSlotChildren()`
- L325: `local function slotLabel(slotIndex)`
- L342: `local function slotChildren(slotIndex)`
- L387: `local function playersChildren()`
- L431: `local function victoryChildren()`
- L449: `local function sortedOptions(rows, defaultSortPriority)`
- L467: `local function mapScriptDropdownRows()`
- L491: `local function mapScriptCheckboxRows()`
- L511: `local function gameOptionCheckboxRows()`
- L525: `local function gameOptionsChildren()`
- L570: `buildItems = function()`
- L644: `handler = BaseMenu.install(ContextPtr, { ... })`

## Notes

- L325 `slotLabel`: Returns a closure (not a string) so the label is re-evaluated each time the group is announced; the `slotIndex` argument is captured, not the slot data.
- L342 `slotChildren`: Also returns a closure for the same lazy-eval reason; the actual children table is built at drill time, not at include time.
- L570 `buildItems`: Assigned via `buildItems = function()` (not `local function`) because the forward declaration on L35 must be visible to closures that reference `buildItems` before the body is defined.
