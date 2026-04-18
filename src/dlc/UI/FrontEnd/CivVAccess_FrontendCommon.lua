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
include("CivVAccess_BaseMenuItems")
-- The BaseMenu container file is named with a "Core" suffix to avoid a
-- stem-prefix collision with BaseMenuItems: Civ V's include index drops
-- the shorter of two stems when one is a prefix of the other, leaving the
-- BaseMenu stem unreachable in every Context. "BaseMenuCore" is just a
-- unique stem; the global it defines is still `BaseMenu`.
include("CivVAccess_BaseMenuCore")
