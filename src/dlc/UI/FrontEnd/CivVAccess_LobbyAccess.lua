-- Lobby accessibility wiring. Appended to the Lobby.lua override.
-- The same physical Lobby.{lua,xml} is instantiated from both the standard
-- Multiplayer flow and the ModMultiplayer flow (LobbyScreen child of
-- MultiplayerSelect / ModMultiplayerSelectScreen); we run identically in
-- both because the user-facing interactions are the same — only the
-- TitleLabel text and pitboss-mode visibility gates differ, which we
-- already pick up from live Controls.
--
-- Structure: two-tab PickerReader.
--   Picker tab: one Entry per server in g_Listings (label = server name +
--     members count + map), then a Sort-by Group mirroring base's five
--     column headers, then an optional Connect-to-IP textfield (pitboss-
--     internet only), then Refresh / Host / Back shell Choices.
--   Reader tab: server header + per-player leaves + hosted-DLC detail +
--     Join action. Ctrl+Up/Down steps to the prev/next server in flat
--     picker order (PickerReader built-in).
--
-- Rebuild on list changes: the engine calls SortAndDisplayListings after
-- every AddServer / RemoveServer / Clear, and after a manual sort toggle
-- via SortOptionSelected. We monkey-patch it with a wrapper that invokes
-- the base body first (so g_Listings and the visual stack reflect the new
-- state) then rebuilds our picker. The patch also catches the initial
-- SortAndDisplayListings triggered by RefreshButtonClick in ShowHide, so
-- every reopen sees a current list without a separate onShow hook.

include("CivVAccess_FrontendCommon")
include("CivVAccess_PickerReader")
include("CivVAccess_SavedGameShared")
include("CivVAccess_LobbyCore")

Log.info("LobbyAccess: wiring PickerReader over base Lobby")

local priorShowHide = ShowHideHandler
local priorInput = InputHandler

local session = PickerReader.create()

-- Forward reference so picker-entry buildReader closures can reach the
-- installed handler (install returns it only after buildPickerItems has
-- run). Read at activation time; set below after install.
local mainHandler
local function getHandler()
    return mainHandler
end

-- Monkey-patch SortAndDisplayListings so every list mutation (AddServer /
-- RemoveServer from MultiplayerGameListUpdated, clear-on-show, sort toggle)
-- also refreshes our picker items. The base body populates g_Listings and
-- the visual Stack; our rebuild reads g_Listings.
local baseSortAndDisplayListings = SortAndDisplayListings
SortAndDisplayListings = function(...)
    baseSortAndDisplayListings(...)
    if mainHandler == nil then
        return
    end
    local newItems = Lobby.buildPickerItems(session.Entry, getHandler)
    mainHandler.setItems(newItems, 1)
end

-- Live TitleLabel as preamble. Base's TitleLabel text varies with lobby
-- mode (Internet / LAN / Pitboss, plus Mod variants) and is set inside
-- ShowHideHandler line 626-640; reading it at announce time covers every
-- mode without duplicating that logic here.
local function titlePreamble()
    if Controls.TitleLabel ~= nil then
        local ok, t = pcall(function()
            return Controls.TitleLabel:GetText()
        end)
        if ok and t ~= nil and t ~= "" then
            return tostring(t)
        end
    end
    return nil
end

local pickerItems = Lobby.buildPickerItems(session.Entry, getHandler)

mainHandler = session.install(ContextPtr, {
    name = "Lobby",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_LOBBY"),
    preamble = titlePreamble,
    pickerTabName = "TXT_KEY_CIVVACCESS_LOBBY_SERVERS_TAB",
    readerTabName = "TXT_KEY_CIVVACCESS_LOBBY_DETAILS_TAB",
    emptyReaderText = Text.key("TXT_KEY_CIVVACCESS_LOBBY_NO_SELECTION"),
    priorShowHide = priorShowHide,
    priorInput = priorInput,
    pickerItems = pickerItems,
})
