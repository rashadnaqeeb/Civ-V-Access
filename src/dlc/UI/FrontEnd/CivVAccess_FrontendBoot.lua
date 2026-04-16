include("CivVAccess_Log")
include("CivVAccess_TextFilter")
include("CivVAccess_FrontEndStrings_en_US")
include("CivVAccess_Text")
include("CivVAccess_SpeechEngine")
include("CivVAccess_SpeechPipeline")
include("CivVAccess_HandlerStack")
include("CivVAccess_InputRouter")
include("CivVAccess_TickPump")

-- Front-end boot. Runs once per front-end Context instantiation via the
-- ToolTips.lua override. Guarded via civvaccess_shared so the announce fires
-- once per session even though ToolTips is re-included across Contexts.
Log.info("FrontendBoot: ToolTips override fired")

if not civvaccess_shared.frontendAnnounced then
    civvaccess_shared.frontendAnnounced = true
    SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_BOOT_FRONTEND"))
end
