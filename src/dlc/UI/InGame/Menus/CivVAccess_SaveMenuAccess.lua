-- SaveMenu accessibility wiring. Appended to the SaveMenu.lua override.
--
-- SaveMenu is in-game only (there's no front-end save flow; you can't save
-- without a game in progress). Opened from GameMenu via
-- UIManager:QueuePopup( Controls.SaveMenu ); our include runs in the SaveMenu
-- sandbox that GameMenu embeds.
--
-- Structure: two-tab PickerReader.
--   Picker tab: in local mode, a Textfield (NameBox), a Save action, a
--     Steam Cloud checkbox, and one Entry per existing save. In cloud mode,
--     just the checkbox and one Entry per slot (1..s_maxCloudSaves, populated
--     or empty).
--   Reader tab: header fields (leader + civ, date, era / turn, start era,
--     game type, map / size / difficulty / speed) plus an Overwrite action,
--     plus Delete for disk saves. Empty cloud slots get a Save-to-slot
--     action instead of Overwrite. Ctrl+Up/Down cycles saves per PickerReader.
--
-- Rebuild on filter toggle / save / delete: the engine calls
-- SetupFileButtonList after every mutation (CloudCheck handler, OnYes,
-- ShowHide open). We monkey-patch it with a wrapper that invokes the base
-- body and then rebuilds our picker items via SaveMenu.buildPickerItems +
-- handler.setItems. The patch catches the ShowHide open path too, so the
-- picker reflects fresh state on every reopen without a separate onShow.

include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_TextFilter")
include("CivVAccess_InGameStrings_en_US")
include("CivVAccess_Text")
include("CivVAccess_Icons")
include("CivVAccess_SpeechEngine")
include("CivVAccess_SpeechPipeline")
include("CivVAccess_HandlerStack")
include("CivVAccess_InputRouter")
include("CivVAccess_TickPump")
include("CivVAccess_Nav")
include("CivVAccess_PullDownProbe")
include("CivVAccess_BaseMenuItems")
include("CivVAccess_TypeAheadSearch")
include("CivVAccess_BaseMenuHelp")
include("CivVAccess_BaseMenuTabs")
include("CivVAccess_BaseMenuCore")
include("CivVAccess_BaseMenuInstall")
include("CivVAccess_BaseMenuEditMode")
include("CivVAccess_Help")
include("CivVAccess_PickerReader")
include("CivVAccess_SavedGameShared")
include("CivVAccess_SaveMenuCore")

Log.info("SaveMenuAccess: wiring PickerReader over base SaveMenu")

local priorShowHide = ShowHideHandler
local priorInput = InputHandler

local session = PickerReader.create()

local mainHandler
local function getHandler()
    return mainHandler
end

-- Monkey-patch SetupFileButtonList so every rebuild (cloud toggle, delete,
-- save-and-close on failure path, ShowHide open) also refreshes our picker.
-- Base body must run first (it populates g_SavedGames); we then rebuild from
-- the new state. Skip when mainHandler hasn't been assigned yet (pre-install
-- ShowHides, which would also fail to have a handler to setItems on).
local baseSetupFileButtonList = SetupFileButtonList
SetupFileButtonList = function(...)
    baseSetupFileButtonList(...)
    if mainHandler == nil then
        return
    end
    local newItems = SaveMenu.buildPickerItems(session.Entry, getHandler)
    mainHandler.setItems(newItems, 1)
end

-- SaveMenu's ShowHideHandler seeds NameBox with GetDefaultSaveName and calls
-- SetupFileButtonList. Base SetupFileButtonList runs after our monkey-patch
-- is in place, so the picker is rebuilt on every open. buildPickerItems at
-- install time is a bootstrap: PickerReader.install requires non-empty
-- pickerItems up front, but the base ShowHide hasn't fired yet so
-- g_SavedGames is empty. We pass a single-item placeholder and rely on the
-- first ShowHide to replace it via the monkey-patched SetupFileButtonList.
local bootstrapPickerItems = {
    BaseMenuItems.Text({ textKey = "TXT_KEY_CIVVACCESS_SAVE_NO_SAVES" }),
}

mainHandler = session.install(ContextPtr, {
    name = "SaveMenu",
    displayName = Text.key("TXT_KEY_MENU_SAVE_BUTTON"),
    pickerTabName = "TXT_KEY_CIVVACCESS_SAVE_SAVES_TAB",
    readerTabName = "TXT_KEY_CIVVACCESS_SAVE_DETAILS_TAB",
    priorShowHide = priorShowHide,
    priorInput = priorInput,
    pickerItems = bootstrapPickerItems,
})
