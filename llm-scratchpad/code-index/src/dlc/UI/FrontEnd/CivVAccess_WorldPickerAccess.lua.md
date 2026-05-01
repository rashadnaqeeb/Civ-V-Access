# `src/dlc/UI/FrontEnd/CivVAccess_WorldPickerAccess.lua`

61 lines · Accessibility wiring for the WorldPicker screen, presenting six world-size buttons that each fire `Events.SerialEventStartGame` via the base globals.

## Header comment

```
-- WorldPicker accessibility wiring. Six world-size buttons plus Esc ->
-- SetHide. Base's InputHandler is a global (routes Esc to
-- ContextPtr:SetHide); each *ButtonClick is a global that fires
-- Events.SerialEventStartGame with the matching WorldSizeType. The
-- source file marks this screen as a placeholder, so it may never
-- appear in the normal flow; wiring it is cheap insurance.
```

## Outline

- L10: `local priorInput = InputHandler`
- L12: `BaseMenu.install(ContextPtr, { ... })`
