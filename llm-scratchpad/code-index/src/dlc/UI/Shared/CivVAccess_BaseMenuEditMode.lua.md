# `src/dlc/UI/Shared/CivVAccess_BaseMenuEditMode.lua`

165 lines · Sub-handler pushed onto HandlerStack when a BaseMenuItems.Textfield is activated, providing edit-commit / restore semantics around a live EditBox control.

## Header comment

```
-- Edit-mode sub-handler for BaseMenuItems.Textfield. Pushed above the menu
-- when Textfield.activate fires. capturesAllInput is false so every printable
-- character / Backspace / caret arrow falls through the mod's InputRouter to
-- the engine-focused EditBox.
--
-- The sub also sets _editMode = true, a flag that BaseMenuCore's install
-- InputHandler reads to swallow the Enter KEYUP (msg 257). Without that
-- swallow, the engine's default Enter-release revokes focus from the EditBox
-- we just took focus on and typed characters end up nowhere. The flag is the
-- only coupling back to Core; setting it from this file is fine because
-- install reads it off the active handler by name.
--
-- Enter commits: reads the current text and invokes priorCallback with
-- bIsEnter=true so non-CallOnChar EditBoxes (OptionsMenu's email, SMTP host,
-- MaxTurns / TurnTimer fields) still persist to OptionsManager / PreGame,
-- then parks focus + pops. Esc restores the snapshot.
--
-- The pop triggers BaseMenu.onActivate which re-announces the current item
-- (with its updated value). We then speakInterrupt the committed value or
-- "<label> restored" so the user hears explicit confirmation.
```

## Outline

- L22: `BaseMenuEditMode = {}`
- L24: `function BaseMenuEditMode.push(menu, textfieldItem)`
- L29: `local function safe(op, fn)`
- L49: `local function wrappingCallback(t, control, bIsEnter)`
- L68: `local function exit(restore)`

## Notes

- L24 `BaseMenuEditMode.push`: defers `editBox:TakeFocus()` one tick via `TickPump.runOnce` to avoid the engine revoking focus when the Enter KEYUP fires in the same frame as the KEYDOWN handler that opened edit mode.
