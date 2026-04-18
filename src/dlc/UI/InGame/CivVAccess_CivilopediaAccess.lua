-- CivilopediaScreen accessibility wiring. Appended to the pedia.lua override.
--
-- The pedia's own code has finished running by the time this include fires,
-- so CivilopediaCategory / SetSelectedCategory / ShowHideHandler /
-- InputHandler are live globals. We chain priorShowHide so the engine's
-- history restoration on reopen still runs, and priorInput so the pedia's
-- own Esc-to-close path fires when the user Escs out at picker level 1.
--
-- Per-Context include chain: the pedia is its own LuaContext under InGame,
-- with its own Lua globals. The shared modules must load into this sandbox
-- before anything touches Text / BaseMenu / etc. These same include stems
-- are already loaded into other InGame Contexts; the engine's VFS indexes
-- by bare stem and re-runs the file per Context.
--
-- UISkin caveat: this access file ships under all three skin directories
-- (BaseGame / Expansion1 / Expansion2). The pedia.lua we copied next to
-- it is the BNW (Expansion2) version -- base-only and G&K-only sessions
-- will run that file against a GameInfo that lacks Beliefs / Resolutions
-- tables. Our buildPickerItems() probes GameInfo for those tables before
-- adding them, so our picker is safe on every skin; the underlying base-
-- game pedia code is what may misbehave there. Add per-skin copies of
-- CivilopediaScreen.{lua,xml} under per-skin directories in the
-- manifests when base/G&K support becomes a requirement.

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
include("CivVAccess_BaseMenuItems")
include("CivVAccess_TypeAheadSearch")
include("CivVAccess_BaseMenuHelp")
include("CivVAccess_BaseMenuCore")
include("CivVAccess_BaseMenuEditMode")
include("CivVAccess_Help")
include("CivVAccess_PickerReader")
include("CivVAccess_CivilopediaCore")

local priorShowHide = ShowHideHandler
local priorInput    = InputHandler

Log.info("CivilopediaAccess: wiring PickerReader over base pedia")

local session = PickerReader.create()
local pickerItems = Civilopedia.buildPickerItems(session.Entry)

Log.info("CivilopediaAccess: built " .. tostring(#pickerItems) .. " top-level categories")

session.install(ContextPtr, {
    name             = "CivilopediaScreen",
    displayName      = Text.key("TXT_KEY_CIVILOPEDIA"),
    pickerTabName    = "TXT_KEY_CIVVACCESS_PEDIA_CATEGORIES_TAB",
    readerTabName    = "TXT_KEY_CIVVACCESS_PEDIA_CONTENT_TAB",
    focusParkControl = "CloseButton",
    priorShowHide    = priorShowHide,
    priorInput       = priorInput,
    pickerItems      = pickerItems,
})
