include("CivVAccess_FrontendCommon")

-- Front-end boot. Runs in the ToolTips Context (via the ToolTips.lua
-- override) and in every overridden menu Context that includes this file.
-- The announce is guarded on the cross-Context shared table so it fires
-- exactly once per session even though this file runs per-Context.
Log.info("FrontendBoot: Context '" .. tostring(ContextPtr:GetID()) .. "' initialized")

-- Push the persisted master / beacon volumes to the proxy before any
-- front-end audio.load triggers ensure_audio. The proxy stores the user
-- values in statics that ensure_audio reads when it seeds the mixer
-- groups; without this push the seed uses the static default (0.1) and
-- every menu sound plays at default volume until the in-game boot's own
-- restore calls finally run after LoadScreenClose. Guarded once-per-
-- session because every overridden menu Context re-includes this file.
if not civvaccess_shared.frontendVolumesApplied then
    civvaccess_shared.frontendVolumesApplied = true
    VolumeControl.restore()
    BeaconVolume.restore()
end

if not civvaccess_shared.frontendAnnounced then
    civvaccess_shared.frontendAnnounced = true
    SpeechPipeline.speakInterrupt(
        Text.format("TXT_KEY_CIVVACCESS_BOOT_FRONTEND", civvaccess_shared.version or "unknown")
    )
end
