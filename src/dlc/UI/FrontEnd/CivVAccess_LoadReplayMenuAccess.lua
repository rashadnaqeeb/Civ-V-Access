-- LoadReplayMenu accessibility wiring. Appended to the LoadReplayMenu.lua
-- override.
--
-- LoadReplayMenu is a LuaContext child of OtherMenu.xml, launched by the
-- OtherMenu "View Replays" button. On replay selection, OnSelectReplay
-- queues the embedded InGame/ReplayViewer and fires
-- LuaEvents.ReplayViewer_LoadReplay; this Context dequeues itself. Our
-- handler installs on LoadReplayMenu only; watching the replay in
-- ReplayViewer is a separate uncovered screen.
--
-- Structure: two-tab PickerReader.
--   Picker tab: one Entry per replay in g_FileList (label = bare filename,
--     path / extension stripped, matching the engine list). Sort-by Group
--     at the tail (Last Modified / Name) mirrors the engine's
--     SortByPullDown.
--   Reader tab: header fields (leader + civ, saved date, era / turn, start
--     era, map, size, difficulty, speed) plus action leaves (Select,
--     Delete, Show-DLC / Show-Mods when the replay has unmet
--     requirements). Ctrl+Up/Down moves to the prev/next replay in the
--     picker's flat order (PickerReader built-in).
--
-- Rebuild on delete / open: the engine calls SetupFileButtonList() from
-- OnYes (delete) and from its ShowHide handler. We monkey-patch
-- SetupFileButtonList with a wrapper that invokes the base body and then
-- rebuilds our picker items via LoadReplayMenu.buildPickerItems +
-- handler.setItems. The ShowHide path catches the first open and every
-- reopen without a separate onShow hook.

include("CivVAccess_FrontendCommon")
include("CivVAccess_PickerReader")
include("CivVAccess_SavedGameShared")
include("CivVAccess_LoadReplayMenuCore")

Log.info("LoadReplayMenuAccess: wiring PickerReader over base LoadReplayMenu")

local priorShowHide = ShowHideHandler
local priorInput    = InputHandler

local session = PickerReader.create()

-- Forward reference so picker-entry buildReader closures can reach the
-- installed handler (install returns it only after buildPickerItems has
-- run). Read at activation time; set below after install.
local mainHandler
local function getHandler() return mainHandler end

-- Monkey-patch SetupFileButtonList so every rebuild (OnYes delete,
-- ShowHide open) also refreshes our picker items. The base body must run
-- first (it populates g_FileList / instance visuals); we rebuild from the
-- new state afterwards. Skip when mainHandler hasn't been assigned yet
-- (pre-install ShowHides would also have no handler to setItems on).
local baseSetupFileButtonList = SetupFileButtonList
SetupFileButtonList = function(...)
    baseSetupFileButtonList(...)
    if mainHandler == nil then return end
    local newItems = LoadReplayMenu.buildPickerItems(session.Entry, getHandler)
    mainHandler.setItems(newItems, 1)
end

local pickerItems = LoadReplayMenu.buildPickerItems(session.Entry, getHandler)

mainHandler = session.install(ContextPtr, {
    name             = "LoadReplayMenu",
    displayName      = Text.key("TXT_KEY_CIVVACCESS_SCREEN_LOAD_REPLAY"),
    pickerTabName    = "TXT_KEY_CIVVACCESS_REPLAY_LIST_TAB",
    readerTabName    = "TXT_KEY_CIVVACCESS_REPLAY_DETAILS_TAB",
    emptyReaderText  = Text.key("TXT_KEY_CIVVACCESS_REPLAY_NO_SELECTION"),
    focusParkControl = "BackButton",
    priorShowHide    = priorShowHide,
    priorInput       = priorInput,
    pickerItems      = pickerItems,
})
