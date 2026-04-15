-- Front-end boot. Runs once per front-end Context instantiation via the
-- ToolTips.lua override. Keeps a tiny surface: no handler stack, no speech
-- pipeline. The tolk global is injected by the proxy into every Context
-- env; Locale.ConvertTextKey resolves TXT_KEYs ingested via the DLC's
-- <TextData> manifest entry.
civvaccess_shared = civvaccess_shared or {}

if not civvaccess_shared.frontendAnnounced then
    civvaccess_shared.frontendAnnounced = true
    if tolk ~= nil and tolk.output ~= nil then
        tolk.output(Locale.ConvertTextKey("TXT_KEY_CIVVACCESS_BOOT_FRONTEND"), true)
    end
end
