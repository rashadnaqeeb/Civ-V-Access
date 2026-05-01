# `src/dlc/UI/Shared/CivVAccess_BaseMenuCore.lua`

1122 lines · Polymorphic menu container that navigates a nested list of items with optional tabs, type-ahead search, and multi-level drill-in.

## Header comment

```
-- Polymorphic menu container. Navigates a nested list of items that implement
-- the BaseMenuItems interface (isNavigable / isActivatable / announce /
-- activate / adjust / children), with optional tabbed grouping.
--
-- Nested navigation:
--   Items can be Groups (see BaseMenuItems.Group) whose children are another
--   list of items. Navigation tracks a 1-based level (_level) and a cursor at
--   each level (_indices[level]). Right drills into a group; Left at level > 1
--   goes back up a level. Esc never drills out — it bypasses to the screen's
--   priorInput at any level (so 5 Esc presses aren't needed to close a menu
--   drilled 5 levels deep). At level > 1 Up/Down wraps across sibling
--   groups (skipping leaves at the parent level), announcing the new group
--   before the first child on a boundary crossing. Ctrl+Up / Ctrl+Down jump
--   to the prev / next sibling group at the parent level, or across groups
--   at level 1.
-- [... key bindings, tab ownership, spec fields documented in full ...]
```

## Outline

- L88: `BaseMenu = {}`
- L90: `local MOD_SHIFT = 1`
- L91: `local MOD_CTRL = 2`
- L92: `local MOD_ALT = 4`
- L99: `local function check(cond, msg)`
- L108: `local function nextValidIndex(items, start, step)`
- L117: `local function stepValid(items, start, step)`
- L131: `local function topLevelItems(self)`
- L143: `local function itemsAtLevel(self, level)`
- L154: `local function currentItems(self)`
- L158: `local function currentIndex(self)`
- L165: `local function findSiblingGroup(items, startIdx, step)`
- L189: `local function resolvePreamble(self)`
- L209: `local function resetSearch(self)`
- L218: `local nav = {...}`
- L227: `local function moveToIndex(self, newIndex)`
- L242: `local function drillInto(self)`
- L260: `local function goBackLevel(self)`
- L278: `local function jumpSiblingGroup(self, step, landOnLast)`
- L311: `local function onUp(self)`
- L329: `local function onDown(self)`
- L347: `local function onHome(self)`
- L355: `local function onEnd(self)`
- L364: `local function onEnter(self)`
- L399: `local function onLeft(self, big)`
- L415: `local function onRight(self, big)`
- L435: `local function onCtrlUp(self)`
- L454: `local function onCtrlDown(self)`
- L478: `local function onAltLeft(self)`
- L489: `local function onAltRight(self)`
- L508: `local function defaultSearchable(self)`
- L544: `local function buildSearchable(self)`
- L566: `function BaseMenu._handleSearchInput(handler, vk, mods)`
- L593: `function BaseMenu.create(spec)`
- L907: `function self.onActivate()`
- L998: `function self.onDeactivate()`
- L1009: `function self.setItems(items, tabIndex)`
- L1038: `function self.setInitialIndex(idx)`
- L1045: `function self.setInitialTabIndex(idx)`
- L1055: `function self.setIndex(idx)`
- L1067: `function self.readHeader()`
- L1084: `function self.refresh()`
- L1104: `self._goBackLevel = function()`
- L1114: `function self.switchToTab(idx)`
- L1118: `return self`
- L1121: `return BaseMenu`

## Notes

- L1084 `self.refresh`: no-ops silently before first `onActivate` and after hide; only speaks when preamble is a function and its resolved text changed since last speak.
- L566 `BaseMenu._handleSearchInput`: public only so `InputRouter` can route printable keys; not intended as a general extension point.
- L218 `nav`: a table of closures passed by reference to `BaseMenuTabs` so both modules share the same nav helpers without circular requires.
