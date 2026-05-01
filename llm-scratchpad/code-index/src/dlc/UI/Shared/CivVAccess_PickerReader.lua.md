# `src/dlc/UI/Shared/CivVAccess_PickerReader.lua`

394 lines · Two-tab picker-plus-reader pattern built on BaseMenu: a picker tab hosts selectable Entry leaves; activation rebuilds the reader tab and switches to it; Shift+Tab or Esc returns to the picker.

## Header comment

```
-- Two-tab picker + reader pattern on top of BaseMenu. A picker tab hosts a
-- nested list of selectable Entries; Enter on an Entry rebuilds the reader
-- tab's items from the Entry's buildReader callback and switches tabs.
-- Shift+Tab (or Esc at reader level 1) returns to the picker, landing the
-- cursor on the just-opened Entry.
--
-- Modeled on ONI Access's CodexScreenHandler split (CategoriesTab + ContentTab),
-- but collapsed into one BaseMenu since our nested navigation natively handles
-- drill levels. Reusable across any "pick from a list, read details in another
-- panel" flow -- Civilopedia is the first consumer; the save-file LoadMenu is
-- a candidate second.
-- [... usage, Entry spec documented ...]
```

## Outline

- L37: `PickerReader = {}`
- L39: `local function check(cond, msg)`
- L49: `local function forEachEntry(items, path, visit)`
- L73: `local function restorePickerCursor(handler, state, pickerTabIdx)`
- L107: `local function entryIsNavigable(self)`
- L113: `local function entryIsActivatable(self)`
- L125: `function PickerReader.create()`
- L127: `local state = {...}`
- L133: `local session = {}`
- L141: `local function activateEntry(entry, menu, playSound)`
- L175: `local function flattenEntries(pickerItems)`
- L186: `local function labelForId(id)`
- L215: `local function navigateAdjacent(menu, step)`
- L242: `function session.Entry(spec)`
- L286: `function session.install(ContextPtr, config)`
- L374: `function handler.setPickerReaderSelection(id)`
- L391: `return session`
- L393: `return PickerReader`

## Notes

- L125 `PickerReader.create`: returns a session object, not the handler directly; `session.Entry` must be called to build picker items, then `session.install` wires the BaseMenu; both share the same `state` closure.
- L141 `activateEntry`: `playSound` is false when called from `navigateAdjacent` (Ctrl+Up/Down on reader tab) to avoid a click sound on keyboard browsing between articles.
- L374 `handler.setPickerReaderSelection`: exposed on the handler post-install so Civilopedia's follow-link path can update the stored selection without touching internal session state.
