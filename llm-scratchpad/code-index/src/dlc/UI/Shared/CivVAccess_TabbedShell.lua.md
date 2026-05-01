# `src/dlc/UI/Shared/CivVAccess_TabbedShell.lua`

585 lines · Hosts an array of tab objects under one `HandlerStack` handler, owning Tab/Shift+Tab cycling, composing bindings and help entries from the active tab, and wrapping Context show/hide/input handlers.

## Header comment

```
-- TabbedShell hosts an array of tab objects under one HandlerStack handler.
-- Tab/Shift+Tab cycling is owned by the shell; only the shell pushes onto
-- HandlerStack. Each tab is a normal handler-shaped object plus implements
-- onTabActivated(announce) and onTabDeactivated() for lifecycle speech. Tabs
-- can be backed by anything: BaseMenu (via TabbedShell.menuTab), BaseTable,
-- or a hand-rolled handler with its own cursor (e.g., the tech-tree DAG, when
-- F6 is retrofitted).
-- [... full tab contract and spec comment ...]
```

## Outline

- L50: `TabbedShell = {}`
- L52: `local MOD_SHIFT = 1`
- L54: `local function check(cond, msg)`
- L63: `local function filterTabBindings(bindings)`
- L86: `local function checkTab(tab, i)`
- L109: `local function composeBindings(self)`
- L127: `local function composeHelpEntries(self)`
- L141: `local function rebuildExposed(self)`
- L148: `local function resolveTabName(tab)`
- L153: `local function deactivateTab(tab)`
- L162: `local function activateTab(tab, announce)`
- L169: `local function cycleTab(self, direction)`
- L199: `local function readShellHeader(self)`
- L207: `local function buildShellBindings(self)`
- L237: `local function buildShellHelpEntries()`
- L246: `function TabbedShell.create(spec)`
- L279: `function self.onActivate()`
- L296: `function self.onDeactivate()`
- L303: `function self.handleSearchInput(_me, vk, mods)`
- L319: `function self.switchToTab(idx)`
- L333: `function self.activeTabIndex()`
- L337: `function self.activeTab()`
- L344: `function self.rebuildExposed()`
- L349: `return self`
- L362: `function TabbedShell.menuTab(args)`
- L388: `function tab.onTabActivated(self, announce)`
- L403: `function tab.onTabDeactivated(self)`
- L416: `function tab.handleSearchInput(_self, vk, mods)`
- L427: `function tab.resetForNextOpen(self)`
- L433: `function tab.menu()`
- L438: `return tab`
- L455: `function TabbedShell.install(ContextPtr, spec)`
- L502: `ContextPtr:SetShowHideHandler(function(bIsHide, bIsInit))`
- L545: `ContextPtr:SetInputHandler(function(msg, wp, lp))`
- L582: `return handler`
- L584: `return TabbedShell`

## Notes

- L279 `self.onActivate`: distinguishes first-open (speaks `displayName`, calls tab with `announce=false`) from re-activation after a sub pop (calls tab with `announce=true`), gated by `_initialized`.
- L362 `TabbedShell.menuTab`: forces `silentDisplayName=true` on the inner `BaseMenu` spec and sets `_chainSpeech = true` during `onTabActivated` so the menu's activation speech queues after the shell's tab-name interrupt.
- L455 `TabbedShell.install`: `deferActivate=true` defers the `HandlerStack.push` by one tick via `TickPump.runOnce` so a same-frame hide can cancel before the push and its `onActivate` speech fire.
- L502 `SetShowHideHandler`: calls `resetTabsForNextOpen` on hide, which resets `_initialized` and `_activeIdx` on every tab and the shell itself so the next open is a clean first-open.
