# `src/dlc/UI/Shared/CivVAccess_BaseMenuTabs.lua`

254 lines · Tab subsystem for BaseMenu, owning spec validation, per-tab lifecycle dispatch (showPanel / onActivate / autoDrillToLevel), and switch/cycle orchestration.

## Header comment

```
-- Tab subsystem for BaseMenu. Owns tab-spec validation, the per-tab show /
-- onActivate / nameFn dispatch, and the switch / cycle orchestration that
-- resets the level cursor and announces the new tab's first item.
--
-- BaseMenuCore loads this file and calls into it; tab-aware reads of
-- self.tabs / self._tabIndex (e.g., topLevelItems) stay in Core because they
-- are one-line conditionals on the data layout, not behavior.
--
-- Navigation helpers Core owns (currentItems, currentIndex, nextValidIndex,
-- resetSearch) are passed in as a `nav` table on every entry point that
-- needs them. They cannot be required as locals because they are module-
-- scoped to Core.
```

## Outline

- L14: `BaseMenuTabs = {}`
- L16: `local function check(cond, msg)`
- L26: `function BaseMenuTabs.normalize(specTabs)`
- L86: `function BaseMenuTabs.hook(self, name)`
- L103: `local function resolveNameText(self, tab)`
- L124: `local function autoDrillTo(self, targetLevel, nav)`
- L146: `function BaseMenuTabs.switch(self, newTabIndex, force, nav)`
- L210: `function BaseMenuTabs.cycle(self, step, nav)`
- L223: `function BaseMenuTabs.openInitial(self, nav)`
- L253: `return BaseMenuTabs`

## Notes

- L146 `BaseMenuTabs.switch`: the `force` parameter bypasses the same-tab no-op so programmatic `switchToTab` re-announces even when already on the target tab (used by PickerReader's entry activation to re-enter the reader tab).
- L223 `BaseMenuTabs.openInitial`: mirrors `switch`'s lifecycle but returns the tab name text instead of speaking it, letting `BaseMenu.create`'s `onActivate` control the overall open-speech order.
