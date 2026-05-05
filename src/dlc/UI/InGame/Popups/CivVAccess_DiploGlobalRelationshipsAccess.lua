-- DiploGlobalRelationships accessibility, residual stub.
--
-- The sighted Global Politics tab of DiploOverview is no longer surfaced
-- in the F4 cycle: its data (era, policies, wonders, third-party
-- relationships, war / denounce flags) folds into the Majors table in
-- CivVAccess_DiploRelationshipsAccess. The Lua Context still exists in
-- the engine and the sighted button still navigates here, so the
-- wrapper stays installed to keep input routing sane if anyone lands
-- on this panel: a single notice item plus Tab / Shift+Tab routes back
-- to Relations, Esc closes the popup.
--
-- This is the non-load-bearing path. Removing the wrapper would strand
-- input on Scanner with no way to escape the popup short of clicking
-- the visible Close button -- something a blind user can't do.

include("CivVAccess_PopupBoot")
include("CivVAccess_DiploCommon")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local RELATIONS_TAB_MAJORS = 1
local RELATIONS_TAB_MINORS = 2

BaseMenu.install(ContextPtr, {
    name = "DiploGlobalRelationships",
    displayName = Text.key("TXT_KEY_DO_GLOBAL_RELATIONS"),
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    shouldActivate = DiploCommon.shouldActivate,
    items = {
        BaseMenuItems.Text({
            labelText = Text.key("TXT_KEY_CIVVACCESS_DIPLO_MAJORS_GROUP"),
        }),
    },
    onTab = function()
        civvaccess_shared.DiploOverview.showRelations(RELATIONS_TAB_MAJORS)
    end,
    onShiftTab = function()
        civvaccess_shared.DiploOverview.showRelations(RELATIONS_TAB_MINORS)
    end,
    onEscape = function()
        civvaccess_shared.DiploOverview.close()
        return true
    end,
    suppressReactivateOnHide = function()
        return civvaccess_shared.DiploOverview._switching == true
    end,
})
