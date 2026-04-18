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
-- can chain as priorShowHide. BaseMenu.install replaces the handler wholesale
-- when we pass it nothing to chain. We replicate the base body inside our
-- onShow / the install wrapper's hide branch: on show the base calls
-- RefreshMods; on hide it calls SetListingsState("results") to reset the
-- visual panels. Both are side-effects on the sighted UI; the picker's
-- rebuild also happens through our monkey-patched RefreshMods wrapper.

local session = PickerReader.create()

-- Forward reference so picker-entry buildReader closures and the
-- RefreshMods wrapper can reach the installed handler. See LoadMenuAccess
-- for the same pattern.
local mainHandler
local function getHandler() return mainHandler end

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
    if mainHandler == nil then return end
    local newItems = InstalledPanel.buildPickerItems(session.Entry, getHandler)
    mainHandler.setItems(newItems, 1)
end

local pickerItems = InstalledPanel.buildPickerItems(session.Entry, getHandler)

mainHandler = session.install(ContextPtr, {
    name             = "InstalledPanel",
    displayName      = Text.key("TXT_KEY_CIVVACCESS_SCREEN_INSTALLED_PANEL"),
    pickerTabName    = "TXT_KEY_CIVVACCESS_MODS_LIST_TAB",
    readerTabName    = "TXT_KEY_CIVVACCESS_MODS_DETAILS_TAB",
    -- InstalledPanel has no top-level back button of its own; the parent
    -- ModsBrowser owns BackButton. Park on the scroll panel so any engine-
    -- held EditBox focus is released.
    focusParkControl = "ListingScrollPanel",
    pickerItems      = pickerItems,
    -- Replaces the base's anonymous SetShowHideHandler body on the show
    -- branch. RefreshMods re-reads g_SortedMods from Modding.* and our
    -- wrapper then rebuilds the picker. BaseMenu.install runs this after
    -- priorShowHide (nil here) and before the handler push, so our setItems
    -- lands before onActivate reads the items for first-announcement.
    onShow = function(handler)
        RefreshMods()
    end,
})
