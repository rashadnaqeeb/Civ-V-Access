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

civvaccess_shared.DiploOverview = civvaccess_shared.DiploOverview or {}
civvaccess_shared.DiploOverview.showRelations = OnRelations
civvaccess_shared.DiploOverview.showDeals = OnDeals
civvaccess_shared.DiploOverview.showGlobal = OnGlobal
-- Inline lambda instead of `close = OnClose`: captures THIS Context's
-- ContextPtr and UIManager directly so there's no ambiguity about which
-- function ends up bound (name collisions with OnClose-in-another-Context
-- or late reassignment would otherwise be invisible).
-- DequeuePopup on DiploOverview sets the parent's Hidden flag to true,
-- which visually cascades to the children, but does NOT fire the child
-- LuaContexts' ShowHide. Our BaseMenu handlers for Relations / Deals /
-- Global pop off HandlerStack in those ShowHide callbacks, so they
-- stayed on the stack after close -- the popup was visually gone but
-- the sub-handlers were still receiving input (Tab still cycled tabs,
-- Esc still fired onEscape). Explicitly SetHide(true) on each panel
-- before dequeueing so the ShowHides fire and the stack drains. On
-- re-show, DiploOverview.ShowHide's line 116 (m_CurrentPanel:SetHide(
-- false)) restores the last-selected tab.
civvaccess_shared.DiploOverview.close = function()
    Controls.RelationsPanel:SetHide(true)
    Controls.DealsPanel:SetHide(true)
    Controls.GlobalPanel:SetHide(true)
    UIManager:DequeuePopup(ContextPtr)
end
