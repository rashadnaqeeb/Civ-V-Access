# `src/dlc/UI/InGame/Menus/CivVAccess_SaveMenuAccess.lua`

98 lines · Accessibility wiring for the in-game SaveMenu screen as a PickerReader, with a monkey-patch on SetupFileButtonList to keep the picker in sync after every cloud toggle, save, or delete.

## Header comment

```
-- SaveMenu accessibility wiring. Appended to the SaveMenu.lua override.
--
-- SaveMenu is in-game only (there's no front-end save flow; you can't save
-- without a game in progress). Opened from GameMenu via
-- UIManager:QueuePopup( Controls.SaveMenu ); our include runs in the SaveMenu
-- sandbox that GameMenu embeds.
--
-- Structure: two-tab PickerReader.
--   Picker tab: in local mode, a Textfield (NameBox), a Save action, a
--     Steam Cloud checkbox, and one Entry per existing save. In cloud mode,
--     just the checkbox and one Entry per slot (1..s_maxCloudSaves, populated
--     or empty).
--   Reader tab: header fields (leader + civ, date, era / turn, start era,
--     game type, map / size / difficulty / speed) plus an Overwrite action,
--     plus Delete for disk saves. Empty cloud slots get a Save-to-slot
--     action instead of Overwrite. Ctrl+Up/Down cycles saves per PickerReader.
--
-- Rebuild on filter toggle / save / delete: the engine calls
-- SetupFileButtonList after every mutation (CloudCheck handler, OnYes,
-- ShowHide open). We monkey-patch it with a wrapper that invokes the base
-- body and then rebuilds our picker items via SaveMenu.buildPickerItems +
-- handler.setItems. The patch catches the ShowHide open path too, so the
-- picker reflects fresh state on every reopen without a separate onShow.
```

## Outline

- L53: `local priorShowHide = ShowHideHandler`
- L54: `local priorInput = InputHandler`
- L56: `local session = PickerReader.create()`
- L58: `local mainHandler`
- L59: `local function getHandler()`
- L69: `local baseSetupFileButtonList = SetupFileButtonList`
- L70: `SetupFileButtonList = function(...)`
- L85: `local bootstrapPickerItems = { BaseMenuItems.Text({ textKey = "TXT_KEY_CIVVACCESS_SAVE_NO_SAVES" }) }`
- L89: `mainHandler = session.install(ContextPtr, { name = "SaveMenu", ... })`

## Notes

- L70 `SetupFileButtonList`: monkey-patching a global in the Context's env so every engine-side call (cloud toggle, save, open) also rebuilds our picker items without us needing a separate event listener.
- L85 `bootstrapPickerItems`: a single-item placeholder passed at install time because the base `ShowHide` hasn't fired yet and `g_SavedGames` is empty; the monkey-patched `SetupFileButtonList` replaces it on the first open.
