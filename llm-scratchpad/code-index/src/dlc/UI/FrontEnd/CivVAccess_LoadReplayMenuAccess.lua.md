# `src/dlc/UI/FrontEnd/CivVAccess_LoadReplayMenuAccess.lua`

76 lines · Accessibility wiring for the Load Replay screen, using a two-tab PickerReader with a monkey-patched `SetupFileButtonList` to keep the replay picker current on delete and reopen.

## Header comment

```
-- LoadReplayMenu accessibility wiring. Appended to the LoadReplayMenu.lua
-- override.
--
-- LoadReplayMenu is a LuaContext child of OtherMenu.xml, launched by the
-- OtherMenu "View Replays" button. [...]
--
-- Structure: two-tab PickerReader.
--   Picker tab: one Entry per replay in g_FileList [...]. Sort-by Group
--     at the tail [...]
--   Reader tab: header fields [...] plus action leaves (Select, Delete,
--     Show-DLC / Show-Mods when the replay has unmet requirements). [...]
--
-- Rebuild on delete / open: the engine calls SetupFileButtonList() from
-- OnYes (delete) and from its ShowHide handler. We monkey-patch
-- SetupFileButtonList [...]
```

## Outline

- L36: `local priorShowHide = ShowHideHandler`
- L37: `local priorInput = InputHandler`
- L39: `local session = PickerReader.create()`
- L44: `local mainHandler`
- L45: `local function getHandler()`
- L54: `local baseSetupFileButtonList = SetupFileButtonList`
- L55: `SetupFileButtonList = function(...)`
- L64: `local pickerItems = LoadReplayMenu.buildPickerItems(session.Entry, getHandler)`
- L66: `mainHandler = session.install(ContextPtr, { ... })`

## Notes

- L55 `SetupFileButtonList`: Monkey-patch of the base global; same pattern as `LoadMenuAccess`.
