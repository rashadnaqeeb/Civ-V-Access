# `src/dlc/UI/FrontEnd/CivVAccess_LoadMenuAccess.lua`

80 lines · Accessibility wiring for the Load Game screen (usable from both the front-end and in-game pause menu), using a two-tab PickerReader with a monkey-patched `SetupFileButtonList` to keep picker items in sync with the save list.

## Header comment

```
-- LoadMenu accessibility wiring. Appended to the LoadMenu.lua override.
--
-- LoadMenu is a single physical Lua/XML pair (Assets/UI/FrontEnd/LoadMenu.*)
-- used from both the front-end "Load Game" flow and the in-game pause-menu
-- "Load Game" (GameMenu embeds this Context as a hidden child). [...]
--
-- Structure: two-tab PickerReader.
--   Picker tab: one Entry per save in g_FileList [...]. Autosaves / Steam Cloud
--     filter checkboxes sit at the tail.
--   Reader tab: header fields [...] plus action leaves (Load, Delete,
--     Show-DLC, Show-Mods). Ctrl+Up/Down moves to the prev/next save [...]
--
-- Rebuild on filter toggle / delete: the engine calls SetupFileButtonList()
-- after every mutation [...]. We monkey-patch it with a wrapper that invokes
-- the base body and then rebuilds our picker items [...]
```

## Outline

- L38: `local priorShowHide = ShowHideHandler`
- L39: `local priorInput = InputHandler`
- L41: `local session = PickerReader.create()`
- L48: `local mainHandler`
- L49: `local function getHandler()`
- L59: `local baseSetupFileButtonList = SetupFileButtonList`
- L60: `SetupFileButtonList = function(...)`
- L69: `local pickerItems = LoadMenu.buildPickerItems(session.Entry, getHandler)`
- L71: `mainHandler = session.install(ContextPtr, { ... })`

## Notes

- L60 `SetupFileButtonList`: Monkey-patch of the base global; base body runs first to populate `g_FileList`, then picker items are rebuilt from the new state.
