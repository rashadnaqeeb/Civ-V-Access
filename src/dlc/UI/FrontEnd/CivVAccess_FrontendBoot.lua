include("CivVAccess_FrontendCommon")

-- Front-end boot. Runs in the ToolTips Context (via the ToolTips.lua
-- override) and in every overridden menu Context that includes this file.
-- The announce is guarded on the cross-Context shared table so it fires
-- exactly once per session even though this file runs per-Context.
Log.info("FrontendBoot: Context '" .. tostring(ContextPtr:GetID()) .. "' initialized")

if not civvaccess_shared.frontendAnnounced then
    civvaccess_shared.frontendAnnounced = true
    SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_BOOT_FRONTEND"))
end
