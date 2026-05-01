-- Shared helpers for the Diplomatic Overview tab wrappers. Both the
-- Relations panel (Your Relations) and the Global panel (Global Politics)
-- compose per-civ speech lines from the same list-join primitive and
-- share the "open trade with this civ" activation path.

DiploCommon = {}

-- BaseMenuInstall's bIsInit guard skips pushes only when bIsInit AND
-- bIsHide are both true (so DeferLoad popups -- HallOfFame, Leaderboard,
-- Credits -- whose first user open coincides with init+show=false can
-- still push). The DiploOverview tab panels (Relations / CurrentDeals /
-- Global) are embedded LuaContexts inside DiploOverview.xml; the panel
-- whose container starts visible (RelationsPanel by default) receives
-- ShowHide(bIsInit=true, bIsHide=false) during the engine's popup-priming
-- pass at game start, slipping past the guard. Without this check the
-- sub-panel's BaseMenu lands on the stack on top of LoadScreen and traps
-- input there once LoadScreen pops.
--
-- During real opens (F4 or mouse-corner) the LoadScreen handler is
-- already off the stack, so this returns true.
function DiploCommon.shouldActivate()
    local top = HandlerStack.active()
    return top == nil or top.name ~= "LoadScreen"
end

-- Open trade with the specified civ. Humans go through the PvP deal
-- screen event; AI goes through the begin-diplo path that spins up the
-- leader head + trade screen. Matches base DiploRelationships.lua /
-- DiploGlobalRelationships.lua LeaderSelected.
--
-- Human path closes DiploOverview first. SimpleDiploTrade.OnOpenPlayerDealScreen
-- shows the trade screen via ContextPtr:SetHide(false), so it stays out of
-- the popup queue. If DiploOverview is queued (the F4 entry path) and we
-- don't close it, both screens are alive simultaneously: input dispatch
-- routes to DiploOverview (queue priority), Esc closes DiploOverview, and
-- SimpleDiploTrade is left orphaned with no way to escape via keyboard
-- (its BaseMenu handler captures all input with no Esc binding). Mirrors
-- DiploList.OnOpenPlayerDealScreen / DiploCorner.OnOpenPlayerDealScreen,
-- which already close themselves on this event.
--
-- AI path leaves DiploOverview alone -- LeaderHeadRoot uses UIManager:
-- QueuePopup at PopupPriority.LeaderHead, so it stacks above DiploOverview
-- correctly and Esc returns the user to DiploOverview after the AI
-- conversation. Closing DiploOverview here would drop them back to the map
-- instead.
function DiploCommon.openTradeWith(iOther)
    if Players[iOther]:IsHuman() then
        if civvaccess_shared.DiploOverview ~= nil
            and type(civvaccess_shared.DiploOverview.close) == "function" then
            civvaccess_shared.DiploOverview.close()
        end
        Events.OpenPlayerDealScreenEvent(iOther)
    else
        UI.SetRepeatActionPlayer(iOther)
        UI.ChangeStartDiploRepeatCount(1)
        Players[iOther]:DoBeginDiploWithHuman()
    end
end

-- Apply Tab / Shift+Tab cycling, Esc-bubble close, and the _switching-aware
-- suppressReactivateOnHide to a BaseMenu.install spec. Mutates and returns
-- the spec.
--
-- nextSibling / prevSibling are method names on civvaccess_shared.DiploOverview
-- (e.g. "showGlobal", "showDeals", "showRelations"). The bridge is set up by
-- DiploOverview's bridge module; each tab references the sibling-show
-- methods by name to avoid hard-coding closures into the spec.
--
-- onEscape: base DiploOverview's InputHandler maps Esc/Enter to OnClose, but
-- it's installed on the DiploOverview Context. Sub-LuaContext InputHandlers
-- (our BaseMenu wrappers) consume keys first; Civ V doesn't bubble an
-- unclaimed key back to the parent Context, so the user can never close the
-- popup from a sub-tab without the explicit bridge.
--
-- suppressReactivateOnHide: the bridge wraps showX with a _switching flag so
-- Scanner's onActivate doesn't fire in the gap between this panel hiding and
-- the sibling pushing.
function DiploCommon.applyTabBindings(spec, nextSibling, prevSibling)
    spec.onTab = function()
        civvaccess_shared.DiploOverview[nextSibling]()
    end
    spec.onShiftTab = function()
        civvaccess_shared.DiploOverview[prevSibling]()
    end
    spec.onEscape = function()
        civvaccess_shared.DiploOverview.close()
        return true
    end
    spec.suppressReactivateOnHide = function()
        return civvaccess_shared.DiploOverview._switching == true
    end
    return spec
end

return DiploCommon
