-- LoadMenu accessibility wiring. Appended to the LoadMenu.lua override.
--
-- LoadMenu is a single physical Lua/XML pair (Assets/UI/FrontEnd/LoadMenu.*)
-- used from both the front-end "Load Game" flow and the in-game pause-menu
-- "Load Game" (GameMenu embeds this Context as a hidden child). Our include
-- runs in whichever sandbox instantiated LoadMenu; g_IsInGame at LoadMenu.lua
-- line 693 is the runtime discriminator if we need it. For our purposes the
-- load flow is identical in both contexts (single-player ends the popup with
-- Events.PlayerChoseToLoadGame, multiplayer stages via PreGame.SetLoadFileName),
-- and the engine picks the right branch inside OnStartButton. We don't.
--
-- Structure: two-tab PickerReader.
--   Picker tab: one Entry per save in g_FileList (or per populated cloud
--     slot in g_CloudSaves when g_ShowCloudSaves). Labels are bare filenames
--     (path / extension stripped, same as engine). Autosaves / Steam Cloud
--     filter checkboxes sit at the tail.
--   Reader tab: header fields (leader + civ, time saved, era / turn, start
--     era, game type, map, size, difficulty, speed) plus action leaves
--     (Load, Delete, Show-DLC, Show-Mods). Ctrl+Up/Down moves to the
--     prev/next save in the picker's flat order (PickerReader built-in).
--
-- Rebuild on filter toggle / delete: the engine calls SetupFileButtonList()
-- after every mutation (AutoCheck / CloudCheck handlers, OnYes delete).
-- We monkey-patch it with a wrapper that invokes the base body and then
-- rebuilds our picker items via LoadMenu.buildPickerItems +
-- handler.setItems. The patch catches the ShowHide open path too (base
-- ShowHideHandler calls SetupFileButtonList on every show), so our picker
-- sees the current save list on every reopen without a separate onShow
-- hook.

include("CivVAccess_FrontendCommon")
include("CivVAccess_PickerReader")
include("CivVAccess_SavedGameShared")
include("CivVAccess_LoadMenuCore")

Log.info("LoadMenuAccess: wiring PickerReader over base LoadMenu")

local priorShowHide = ShowHideHandler
local priorInput = InputHandler

local session = PickerReader.create()

-- Forward reference so picker-entry buildReader closures can reach the
-- installed handler (install returns it only after buildPickerItems has
-- run). Read at activation time; set below after install. Passed into
-- buildPickerItems as a thunk so buildReader sees the live handler rather
-- than a captured nil.
local mainHandler
local function getHandler()
    return mainHandler
end

-- Monkey-patch SetupFileButtonList so every rebuild (filter toggle,
-- OnYes delete, ShowHide open) also refreshes our picker items. The base
-- body must run first (it populates g_FileList / instance visuals); we
-- then rebuild from the new state. Skip when mainHandler hasn't been
-- assigned yet (pre-install ShowHides, which would also fail to have a
-- handler to setItems on).
local baseSetupFileButtonList = SetupFileButtonList
SetupFileButtonList = function(...)
    baseSetupFileButtonList(...)
    if mainHandler == nil then
        return
    end
    local newItems = LoadMenu.buildPickerItems(session.Entry, getHandler)
    mainHandler.setItems(newItems, 1)
end

local pickerItems = LoadMenu.buildPickerItems(session.Entry, getHandler)

mainHandler = session.install(ContextPtr, {
    name = "LoadMenu",
    displayName = Text.key("TXT_KEY_LOAD_GAME"),
    pickerTabName = "TXT_KEY_CIVVACCESS_LOAD_SAVES_TAB",
    readerTabName = "TXT_KEY_CIVVACCESS_LOAD_DETAILS_TAB",
    priorShowHide = priorShowHide,
    priorInput = priorInput,
    pickerItems = pickerItems,
})
