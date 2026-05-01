# `src/dlc/UI/Shared/CivVAccess_BaseTableCore.lua`

553 lines · 2D-cursor table viewer that implements the `TabbedShell` tab interface, with sortable columns, type-ahead column search, and Civilopedia lookup.

## Header comment

```
-- BaseTable produces a tab-shaped handler with a 2D-cursor table viewer.
-- Designed for screens whose content is a sortable table of homogeneous rows
-- with named columns: F2 city table, future F8 demographics, F9 hall of fame,
-- unit lists, etc. Hosted inside a TabbedShell or, in principle, pushed
-- standalone onto HandlerStack -- the contract matches both shapes.
-- [... full spec comment ...]
```

## Outline

- L54: `BaseTable = {}`
- L56: `local MOD_CTRL = 2`
- L58: `local function check(cond, msg)`
- L63: `local function buildRows(self)`
- L96: `local function buildCellSpeech(self, rows, force)`
- L142: `local function speakCell(self, force)`
- L161: `local function onUp(self)`
- L168: `local function onDown(self)`
- L177: `local function onLeft(self)`
- L189: `local function onRight(self)`
- L201: `local function onHome(self)`
- L211: `local function onEnd(self)`
- L227: `local function cycleSort(self)`
- L249: `local function onEnter(self)`
- L271: `local function onPedia(self)`
- L295: `local function buildSearchable(self)`
- L314: `local function handleSearchInput(self, vk, mods)`
- L338: `local function buildHelpEntries(spec)`
- L369: `function BaseTable.create(spec)`
- L500: `function self.onTabActivated(_self, announce)`
- L525: `function self.onTabDeactivated()`
- L529: `function self.handleSearchInput(_me, vk, mods)`
- L533: `function self.resetForNextOpen()`
- L541: `function self.onActivate()`
- L545: `function self.onDeactivate()`
- L549: `return self`
- L552: `return BaseTable`

## Notes

- L63 `buildRows`: called on every navigation event (no caching), applying sort if active; clamps `_row` if `rebuildRows` yields fewer rows than before.
- L96 `buildCellSpeech`: elides unchanged row label and column name from the announcement unless `force=true`; force is set on activation, sort changes, and search jumps.
- L227 `cycleSort`: cycles none -> descending -> ascending -> none on Enter at the header row; silently no-ops on non-sortable columns.
- L500 `self.onTabActivated`: sets `_chainSpeech = true` before calling `speakCell` so the activation cell announcement uses `speakQueued` to chain after the shell's tab-name interrupt.
- L541 `self.onActivate`: mirrors to `onTabActivated(self, true)` so `BaseTable` works as a standalone `HandlerStack` handler without a `TabbedShell`.
