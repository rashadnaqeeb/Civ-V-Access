# `src/dlc/UI/FrontEnd/CivVAccess_ProbeBoot.lua`

85 lines · Prepended to each overridden form screen to install PullDown, Slider, Checkbox, and Button metatable probes before the screen's own top-level code registers callbacks.

## Header comment

```
-- Prepended to each overridden form screen (OptionsMenu, AdvancedSetup,
-- MPGameSetupScreen, StagingRoom) so the widget probes are in place BEFORE
-- the screen's own top-level code registers callbacks or builds entries.
-- Patching the metatable after those calls would miss the one-time
-- Register*Callback, leaving BaseMenu with no way to invoke the
-- engine's callback from keyboard activation.
--
-- include() is idempotent (engine caches by bare stem); multiple screens
-- chaining through here cost nothing on the second Context. The probe's
-- install itself is guarded by civvaccess_shared.{pullDownProbeInstalled,
-- sliderProbeInstalled}.
--
-- Sample control lists are per-widget-kind supersets: the first control
-- that resolves is enough since each widget-kind metatable is shared by
-- every instance of that kind in the lua_State.
```

## Outline

- L18: `PullDownProbe.installFromControls({ ... }, { ... }, { ... }, { ... })`
