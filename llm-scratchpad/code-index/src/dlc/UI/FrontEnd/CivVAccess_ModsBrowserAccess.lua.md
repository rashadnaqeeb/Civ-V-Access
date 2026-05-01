# `src/dlc/UI/FrontEnd/CivVAccess_ModsBrowserAccess.lua`

118 lines · Accessibility wiring for the ModsBrowser shell screen, including cross-Context LuaEvent forwarding for sub-panel buttons and dynamic delete-button label/tooltip reading.

## Header comment

```
-- ModsBrowser accessibility wiring. This context is a four-button shell
-- around the installed-mods sub-panel (InstalledPanel, not yet handled);
-- the Next / Workshop / Back actions are global functions, but SmallButton1
-- (Delete) is wired to a LuaEvents signal that sub-contexts dispatch
-- (LuaEvents.OnModBrowserDeleteButtonClicked), and its caption + tooltip
-- are pushed in from sub-contexts via LuaEvents.ModBrowserSetDeleteButtonState
-- -> SetButtonState(button, label, visible, enabled, caption, tooltip).
-- We read the current caption via labelFn so a sub that relabels SmallButton1
-- from "Delete" to "Disable" etc. is reflected in speech. Visibility /
-- IsDisabled are already respected by Button's shared isNavigable /
-- isActivatable.
--
-- Workshop (SmallButton2) opens the Steam overlay to the Workshop page
-- when the overlay is enabled; base's anonymous ShowHide hides it when
-- the overlay is off. We replicate that gate in onShow since the base's
-- ShowHide registration is anonymous and BaseMenu.install's wrapper
-- overwrites it.
```

## Outline

- L21: `local priorInput = InputHandler`
- L29: `local function onShowHide(bIsHide, bIsInit)`
- L37: `LuaEvents.CivVAccessModsBrowserNext.Add(...)`
- L40: `LuaEvents.CivVAccessModsBrowserWorkshop.Add(...)`
- L43: `LuaEvents.CivVAccessModsBrowserBack.Add(...)`
- L47: `local function deleteButtonLabel()`
- L60: `local function deleteButtonTooltip()`
- L74: `BaseMenu.install(ContextPtr, { ... })`
