-- Include-chain bundle for in-game popup Access wrappers. Civ V
-- sandboxes Lua globals per Context, so the modules loaded by Boot.lua
-- live only in WorldView's env. Each popup Context (fired from the
-- SerialEventGameMessagePopup dispatch, or opened directly via its own
-- ContextPtr show) is a separate sandbox and must rebuild the same
-- module surface in its own env before BaseMenu.install can run.
-- include() resolves stems via a lua_State-wide index but executes the
-- file per Context, so the same stems produce the same module code in
-- each sandbox.
--
-- Stem name (CivVAccess_PopupBoot) chosen to avoid the stem-prefix
-- collision rule (CLAUDE.md): no other file under src/dlc/UI starts
-- with CivVAccess_Popup, and this stem is not a prefix of any other.
-- A future contributor adding CivVAccess_PopupBootX would shadow this
-- (engine drops the shorter stem), so name carefully if you extend.
--
-- Mirror of FrontEnd's CivVAccess_FrontendCommon for the in-game popup
-- Context group. A few popups (Civilopedia*, etc.) need additional
-- includes beyond this bundle; those wrappers include the bundle here
-- and then the extras alongside.

include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_TextFilter")
include("CivVAccess_InGameStrings_en_US")
include("CivVAccess_PluralRules")
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
include("CivVAccess_BaseMenuTabs")
include("CivVAccess_BaseMenuCore")
include("CivVAccess_BaseMenuInstall")
include("CivVAccess_BaseMenuEditMode")
include("CivVAccess_Help")
