-- InstalledPanel accessibility wiring. Appended to our InstalledPanel.lua
-- override, runs inside the InstalledPanel child LuaContext (ModsBrowser.xml
-- line 41 hosts it with Hidden="0"). Sibling to our ModsBrowserAccess wiring
-- which handles the parent shell's Delete / Workshop / Next / Back buttons.
-- Both handlers coexist on the stack: InstalledPanel on top while reading a
-- mod list, popping to expose the shell for Next / Back.
--
-- Structure: two-tab PickerReader.
--   Picker tab: one Entry per installed mod in g_SortedMods (Downloading /
--     Installing rows appear as non-activatable Text leaves), followed by
--     Sort-by and Options tail groups.
--   Reader tab: per-mod header fields + dependency / reference / blocker
--     bullets + state + Enable or Disable + Update (when NeedsUpdate) +
--     Delete or Unsubscribe (gated on ownership). See InstalledPanelCore.
--
-- Rebuild on state transitions: the engine's RefreshMods is called on
-- sort, enable / disable, download / install state changes, and the
-- Options popup's OK. We monkey-patch it with a wrapper that invokes the
-- base body then rebuilds our picker items via
-- InstalledPanel.buildPickerItems + handler.setItems. The patch also
-- catches the initial RefreshMods() at include time if our handler is
-- already installed (it is not on first load; the post-install call
-- covers that).

include("CivVAccess_FrontendCommon")
include("CivVAccess_PickerReader")
include("CivVAccess_InstalledPanelCore")

Log.info("InstalledPanelAccess: wiring PickerReader over base InstalledPanel")

-- Base InstalledPanel registers its SetShowHideHandler with an anonymous
-- closure (InstalledPanel.lua line 875), so there is no named reference we
-- can chain as priorShowHide. More importantly, the child LuaContext's own
-- ShowHide only fires once at Context init (Hidden="0" in ModsBrowser.xml
-- line 41 makes it "visible" at engine boot, regardless of parent popup
-- state) and does not re-fire when the parent ModsBrowser popup actually
-- opens. If we let BaseMenu.install push the handler on that first ShowHide,
-- it lands at the bottom of the stack forever while ModsBrowser's handler
-- stacks on top whenever the browser opens -- the user only hears the
-- shell (Next / Back / Workshop / Delete), never the installed mods list.
--
-- Fix: skip the automatic push via shouldActivate, and listen for our
-- own LuaEvents.CivVAccessModsBrowserVisibilityChanged signal fired by
-- ModsBrowserAccess's priorShowHide. On show we defer the push one tick so
-- ModsBrowser's own push completes first and our handler ends up on top.
-- On hide we remove immediately.

local session = PickerReader.create()

-- Forward reference so picker-entry buildReader closures and the
-- RefreshMods wrapper can reach the installed handler. See LoadMenuAccess
-- for the same pattern.
local mainHandler
local function getHandler()
    return mainHandler
end

-- Monkey-patch RefreshMods so every rebuild (sort toggle, enable / disable,
-- download state transition, explicit Options-apply) also refreshes our
-- picker items. The base body must run first (it repopulates g_SortedMods
-- and the visual Stack); we then rebuild from the new state. Skip when
-- mainHandler hasn't been assigned yet (the pre-install RefreshMods at the
-- bottom of InstalledPanel.lua), which would also fail to have a handler
-- to setItems on.
local baseRefreshMods = RefreshMods
RefreshMods = function(...)
    baseRefreshMods(...)
    if mainHandler == nil then
        return
    end
    local newItems = InstalledPanel.buildPickerItems(session.Entry, getHandler)
    mainHandler.setItems(newItems, 1)
end

local pickerItems = InstalledPanel.buildPickerItems(session.Entry, getHandler)

mainHandler = session.install(ContextPtr, {
    name = "InstalledPanel",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_INSTALLED_PANEL"),
    pickerTabName = "TXT_KEY_CIVVACCESS_MODS_LIST_TAB",
    readerTabName = "TXT_KEY_CIVVACCESS_MODS_DETAILS_TAB",
    pickerItems = pickerItems,
    -- Skip the Context-init push. The LuaEvent listener below drives push /
    -- pop based on the parent ModsBrowser's real visibility transitions.
    shouldActivate = function()
        return false
    end,
})

-- Push / pop in response to ModsBrowser visibility signal. Defer the push
-- one tick on show so ModsBrowser's own push (which fires in its ShowHide
-- wrapper, called by the engine on the same popup event) completes before
-- ours. Without the defer, we push first and ModsBrowser lands on top,
-- leaving the user on the shell again.
LuaEvents.CivVAccessModsBrowserVisibilityChanged.Add(function(visible)
    if visible then
        TickPump.runOnce(function()
            -- Refresh first so picker items reflect the current mod list,
            -- then re-stack above ModsBrowser. Remove-before-push handles
            -- the pathological case where our handler is somehow already
            -- on the stack (reinstall, double-event).
            RefreshMods()
            HandlerStack.removeByName(mainHandler.name, false)
            HandlerStack.push(mainHandler)
        end)
    else
        HandlerStack.removeByName(mainHandler.name, true)
    end
end)
