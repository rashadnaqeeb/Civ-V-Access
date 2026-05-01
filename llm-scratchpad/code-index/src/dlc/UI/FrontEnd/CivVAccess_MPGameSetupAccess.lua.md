# `src/dlc/UI/FrontEnd/CivVAccess_MPGameSetupAccess.lua`

187 lines · Accessibility wiring for the Multiplayer Host game setup screen, mirroring the AdvancedSetup nested structure (global settings, Victory Conditions, Game Options, DLC Allowed groups) without the per-player slot panel.

## Header comment

```
-- MPGameSetupScreen (Multiplayer -> Host) accessibility wiring. Same nested
-- shape as AdvancedSetup: flat leaves at the top level for each global
-- setting, plus drill-in groups for Victory Conditions, Game Options, and
-- DLC Allowed (all dynamically built by InstanceManager into per-section
-- stacks). MP has no per-slot AI panel on this screen; player slot
-- selection happens in the Staging Room after Host.
--
-- Visibility proxies handle mode-dependent hiding: [...]
```

## Outline

- L17: `local priorShowHide = ShowHideHandler`
- L18: `local priorInput = InputHandler`
- L20: `local mapTypeEntryAnnounce = MPGameSetupShared.mapTypeEntryAnnounce`
- L21: `local victoryChildren = MPGameSetupShared.victoryChildren`
- L22: `local gameOptionsChildren = MPGameSetupShared.gameOptionsChildren`
- L23: `local dlcChildren = MPGameSetupShared.dlcChildren`
- L28: `local function buildItems(handler)`
- L169: `BaseMenu.install(ContextPtr, { ... })`
