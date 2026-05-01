# `src/dlc/UI/FrontEnd/CivVAccess_SelectMapTypeAccess.lua`

245 lines · Accessibility wiring for the SelectMapType folder-tree screen, wrapping the `View` global to rebuild items on every drill-in and annotating size-constrained map entries with their supported world sizes.

## Header comment

```
-- Select Map Type accessibility wiring.
-- The base screen is a folder tree: Refresh() builds a rootFolder with
-- nested sub-folders, View(folder) renders folder.Items. Our items are
-- kept in sync by wrapping the global View: after the base renders, we
-- translate folder.Items into Choice items. Sub-folder entries drill in
-- via their own Callback (= View(subfolder)); folder.ParentFolder handles
-- back navigation. Leaf entries call through to OnMapScriptSelected /
-- OnMultiSizeMapSelected (via v.Callback), which fires OnBack and pops
-- our handler through the Context's ShowHide.
```

## Outline

- L15: `local priorShowHide = ShowHideHandler`
- L16: `local priorInput = InputHandler`
- L17: `local handler`
- L32: `local _sizeByNameCache`
- L34: `local function worldNameById(worldID)`
- L42: `local function worldNameByType(typeKey)`
- L50: `local function buildSizeByName()`
- L111: `local function sizeByName()`
- L121: `local function currentSelectionName()`
- L142: `local function buildItemsForFolder(folder)`
- L217: `local originalView = View`
- L218: `function View(folder)`
- L235: `handler = BaseMenu.install(ContextPtr, { ... })`

## Notes

- L32 `_sizeByNameCache`: lazily populated on first `sizeByName()` call and cleared to nil on each screen show (via `onShow`) so a DLC/mod toggle that changes map availability gets a fresh build.
- L218 `View`: replaces the global `View` used by the base file; the original is saved to `originalView` and called first so the base visual panel updates before items are rebuilt.
