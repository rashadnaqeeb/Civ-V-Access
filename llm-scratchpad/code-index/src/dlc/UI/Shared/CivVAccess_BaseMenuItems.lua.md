# `src/dlc/UI/Shared/CivVAccess_BaseMenuItems.lua`

1197 lines · Polymorphic item factories for the BaseMenu container, each returning a table with a common isNavigable/isActivatable/announce/activate/adjust interface.

## Header comment

```
-- Polymorphic item factories for the BaseMenu container. Each factory validates
-- its spec, resolves control references, and returns a table with a common
-- method interface: isNavigable / isActivatable / announce / activate / adjust.
-- The BaseMenu container calls these methods without knowing the item kind, so
-- new kinds (drill-in, production picker) slot in without touching BaseMenu.
--
-- Shared speech composition: table.concat(parts, ", ") + optional "disabled"
-- suffix + tooltip (deduped against existing segments). The tooltip dedupe
-- drops sentences that repeat a label/value the user just heard.
--
-- Common spec fields (all item kinds):
--   controlName / control / textKey / labelText / labelFn /
--   tooltipKey / tooltipText / tooltipFn
```

## Outline

- L22: `BaseMenuItems = {}`
- L24: `local STEP_SMALL = 0.01`
- L25: `local STEP_BIG = 0.10`
- L31: `local function check(cond, msg)`
- L41: `local function resolveLabel(item)`
- L56: `local function resolveTooltip(item)`
- L98: `local function appendTooltip(base, tooltip)`
- L138: `BaseMenuItems.appendTooltip = appendTooltip`
- L139: `BaseMenuItems.labelOf = resolveLabel`
- L140: `BaseMenuItems.tooltipOf = resolveTooltip`
- L148: `function BaseMenuItems.clickAck()`
- L154: `local function isNavigable(self)`
- L163: `local function isActivatable(self)`
- L171: `local function composeSpeech(item, parts)`
- L183: `local function resolveControl(spec, kind)`
- L196: `local function assertLabel(spec, kind)`
- L202: `local function assertTooltip(spec, kind)`
- L210: `local function copyCommonFields(spec, item)`
- L230: `function BaseMenuItems.Button(spec)`
- L277: `function BaseMenuItems.Text(spec)`
- L324: `function BaseMenuItems.Checkbox(spec)`
- L486: `local function sliderCompositeLabel(item)`
- L501: `local function clampUnit(v)`
- L512: `local function fireSliderCallback(item, newValue)`
- L533: `function BaseMenuItems.Slider(spec)`
- L598: `local function pulldownCurrentValue(item)`
- L642: `local function buildChoice(button, callback, useVoids, parentControlName, announceOverride, isSelected, onSelected)`
- L731: `function BaseMenuItems.Pulldown(spec)`
- L938: `function BaseMenuItems.Group(spec)`
- L1016: `local function textfieldCurrentValue(item)`
- L1027: `BaseMenuItems._textfieldCurrentValue = textfieldCurrentValue`
- L1029: `function BaseMenuItems.Textfield(spec)`
- L1084: `function BaseMenuItems.VirtualSlider(spec)`
- L1152: `function BaseMenuItems.VirtualToggle(spec)`
- L1197: `return BaseMenuItems`

## Notes

- L98 `appendTooltip`: uses NUL as a split sentinel to avoid mangling decimal points ("1.06") when splitting tooltip sentences; `[NEWLINE]` tokens are normalized to ". " before dedup.
- L642 `buildChoice`: private factory for pulldown sub-menu entries; `useVoids` selects between `callback(v1, v2)` and `callback()` depending on how the pulldown was wired in the base screen.
- L938 `BaseMenuItems.Group`: `isNavigable` walks all children on every check when `cached=false`; avoid deeply nested cached=false groups in hot navigation paths.
- L1016 `textfieldCurrentValue`: returns a localized "blank" sentinel (not empty string) when the EditBox is empty, so the user hears explicit feedback.
