# `src/dlc/UI/InGame/Popups/CivVAccess_DiploOverviewBridge.lua`

59 lines · Publishes DiploOverview's tab-switch and close functions on `civvaccess_shared` so the three sub-panel LuaContexts can route Tab/Shift+Tab and Esc across Context boundaries.

## Header comment

```
-- DiploOverview bridge. The three tab panels (DiploRelationships,
-- DiploCurrentDeals, DiploGlobalRelationships) are embedded LuaContexts
-- inside DiploOverview.xml; each runs in its own Context env, so the base
-- tab-switch globals OnRelations / OnDeals / OnGlobal -- defined here in
-- DiploOverview's Context -- aren't directly callable from the children.
--
-- This bridge publishes references to those functions on
-- civvaccess_shared so the per-panel accessibility wrappers can route
-- Tab / Shift+Tab to the right base fn, which flips the sighted panel
-- and triggers the ShowHide cycle that pops the current wrapper's menu
-- and pushes the sibling's.
--
-- The wrappers also raise a transient _switching flag around the base
-- call. Base OnX fires SetHide on three panels synchronously in
-- hide-then-show order; between the hide and show ShowHide events the
-- previous panel's BaseMenu has popped but the new one has not yet
-- pushed, briefly exposing Scanner underneath -- whose onActivate
-- announces "map mode". Each panel's BaseMenu.install reads this flag
-- via suppressReactivateOnHide to skip Scanner's reactivation during a
-- sibling tab swap.
```

## Outline

- L23: `include("CivVAccess_Log")`
- L25: `civvaccess_shared.DiploOverview = civvaccess_shared.DiploOverview or {}`
- L27: `local function withSwitching(fn)`
- L37: `civvaccess_shared.DiploOverview.showRelations = withSwitching(OnRelations)`
- L38: `civvaccess_shared.DiploOverview.showDeals = withSwitching(OnDeals)`
- L39: `civvaccess_shared.DiploOverview.showGlobal = withSwitching(OnGlobal)`
- L54: `civvaccess_shared.DiploOverview.close = function()`

## Notes

- L54 `close`: Explicitly calls `SetHide(true)` on all three child panels before `DequeuePopup` so their `ShowHide` callbacks fire and drain the handler stack; without this the panels stay on the stack after the popup closes.
