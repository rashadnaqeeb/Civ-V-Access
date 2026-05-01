# `src/dlc/UI/FrontEnd/CivVAccess_InstalledPanelAccess.lua`

110 lines · Accessibility wiring for the Installed Mods panel inside ModsBrowser, using a two-tab PickerReader and a monkey-patched `RefreshMods` to keep the picker current, with push/pop driven by a LuaEvent from the parent ModsBrowser rather than the child Context's own ShowHide.

## Header comment

```
-- InstalledPanel accessibility wiring. Appended to our InstalledPanel.lua
-- override, runs inside the InstalledPanel child LuaContext (ModsBrowser.xml
-- line 41 hosts it with Hidden="0"). Sibling to our ModsBrowserAccess wiring
-- which handles the parent shell's Delete / Workshop / Next / Back buttons.
-- Both handlers coexist on the stack: InstalledPanel on top while reading a
-- mod list, popping to expose the shell for Next / Back.
-- [...]
-- Rebuild on state transitions: the engine's RefreshMods is called on
-- sort, enable / disable, download / install state changes, and the
-- Options popup's OK. We monkey-patch it with a wrapper that invokes the
-- base body then rebuilds our picker items via
-- InstalledPanel.buildPickerItems + handler.setItems. [...]
```

## Outline

- L48: `local session = PickerReader.create()`
- L53: `local mainHandler`
- L54: `local function getHandler()`
- L65: `local baseRefreshMods = RefreshMods`
- L66: `RefreshMods = function(...)`
- L75: `local pickerItems = InstalledPanel.buildPickerItems(session.Entry, getHandler)`
- L77: `mainHandler = session.install(ContextPtr, { ... })`
- L95: `LuaEvents.CivVAccessModsBrowserVisibilityChanged.Add(...)`

## Notes

- L66 `RefreshMods`: Monkey-patch of the base global; the original body is saved as `baseRefreshMods` and called first before rebuilding picker items.
- L95 `LuaEvents.CivVAccessModsBrowserVisibilityChanged.Add`: The push/pop is intentionally driven by a custom LuaEvent rather than the child Context's own ShowHide, because the child Context is initialized with `Hidden="0"` and its ShowHide never re-fires when the parent ModsBrowser actually opens.
