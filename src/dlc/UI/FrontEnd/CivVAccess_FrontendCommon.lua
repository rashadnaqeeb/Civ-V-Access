-- Include-chain that every front-end Lua Context needs before it touches
-- Text / Log / SpeechPipeline / HandlerStack / InputRouter. Globals live
-- in per-Context sandboxes (only civvaccess_shared crosses Contexts), so
-- each overridden screen must run this chain in its own Context rather
-- than relying on FrontendBoot's ToolTips-Context setup.
-- include() resolves stems via a lua_State-wide index but executes the
-- file per Context, so the same stems load the same module code into
-- each sandbox.

include("CivVAccess_Log")
include("CivVAccess_TextFilter")
include("CivVAccess_FrontEndStrings_en_US")
include("CivVAccess_Text")
include("CivVAccess_SpeechEngine")
include("CivVAccess_SpeechPipeline")
include("CivVAccess_HandlerStack")
include("CivVAccess_InputRouter")
include("CivVAccess_TickPump")
include("CivVAccess_Nav")
include("CivVAccess_MenuItems")
include("CivVAccess_Menu")
