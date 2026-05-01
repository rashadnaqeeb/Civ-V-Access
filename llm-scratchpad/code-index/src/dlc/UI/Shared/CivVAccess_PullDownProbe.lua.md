# `src/dlc/UI/Shared/CivVAccess_PullDownProbe.lua`

361 lines · Patches engine widget metatables (PullDown, Slider, CheckBox, Button) by replacing `__index` with an intercepting closure that records registered callbacks and built entries on `civvaccess_shared`.

## Header comment

```
-- Engine PullDowns and Sliders expose Register*Callback / BuildEntry /
-- ClearEntries / SetValue, but no public accessor for the registered
-- callback. BaseMenuItems needs both to:
--   * synthesize a keyboard sub-menu from a PullDown's entries
--   * fire the screen's SliderCallback after programmatic SetValue, since
--     the engine does not auto-fire it outside mouse drags
-- This module wraps those methods on the shared PullDown/Slider metatables
-- so every call still reaches the engine (mouse path stays intact) while
-- we record what we need on civvaccess_shared.
-- [... full state layout comment ...]
```

## Outline

- L45: `PullDownProbe = {}`
- L47: `civvaccess_shared = civvaccess_shared or {}`
- L55: `local type = type`
- L61: `local function resolveMethod(origIndex, sample, name)`
- L76: `local function patchIndex(mt, interceptors)`
- L92: `function PullDownProbe.ensureInstalled(samplePullDown)`
- L152: `function PullDownProbe.callbackFor(pulldown)`
- L157: `function PullDownProbe.entriesFor(pulldown)`
- L164: `function PullDownProbe.ensureSliderInstalled(sampleSlider)`
- L203: `function PullDownProbe.sliderCallbackFor(slider)`
- L209: `function PullDownProbe.ensureCheckBoxInstalled(sampleCheckBox)`
- L244: `function PullDownProbe.checkBoxCallbackFor(checkbox)`
- L258: `function PullDownProbe.ensureButtonInstalled(sampleButton)`
- L299: `function PullDownProbe.buttonCallbackFor(button, mouseEvent)`
- L316: `function PullDownProbe.installFromControls(pullDownNames, sliderNames, checkBoxNames, buttonNames)`

## Notes

- L55 `local type = type`: captured as an upvalue because the closures installed on engine metatables outlive their Context's `_ENV`; a global lookup from a dead env returns nil and crashes widget dispatch.
- L76 `patchIndex`: replaces `mt.__index` entirely with a Lua function regardless of whether the original was a table or a C function, handling both engine userdata and test polyfill shapes.
- L92 `PullDownProbe.ensureInstalled`: guarded by `civvaccess_shared.pullDownProbeInstalled` and designed to be install-once (metatable is shared across the lua_State), unlike most mod registrations.
- L316 `PullDownProbe.installFromControls`: iterates the named controls list until it finds one that resolves and installs successfully, then stops; only the first resolvable sample is needed per widget kind.
