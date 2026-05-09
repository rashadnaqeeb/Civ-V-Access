include("CivVAccess_FrontendCommon")

-- Front-end boot. Runs in the ToolTips Context (via the ToolTips.lua
-- override) and in every overridden menu Context that includes this file.
-- The announce is guarded on the cross-Context shared table so it fires
-- exactly once per session even though this file runs per-Context.
Log.info("FrontendBoot: Context '" .. tostring(ContextPtr:GetID()) .. "' initialized")

if not civvaccess_shared.frontendAnnounced then
    civvaccess_shared.frontendAnnounced = true
    SpeechPipeline.speakInterrupt(Text.format("TXT_KEY_CIVVACCESS_BOOT_FRONTEND", civvaccess_shared.version or "unknown"))
end

-- Out-of-date warning. The proxy spawns a WinHTTP thread at DllMain that
-- queries GitHub for the latest release tag; civvaccess_shared.get_latest_version
-- returns the parsed string once the response lands, nil while the check
-- is pending or after a network failure. Poll one frame at a time until
-- ~1s has passed, then either warn or fall silent. Drains via TickPump,
-- which is shared across Contexts -- ToolTips itself doesn't tick, but
-- BaseMenu.install on MainMenu / other front-end menus does, so the
-- queue empties as soon as the main menu Context is alive.
if not civvaccess_shared.updateCheckScheduled then
    civvaccess_shared.updateCheckScheduled = true
    local startTime = os.clock()
    local function poll()
        if os.clock() - startTime < 1.0 then
            TickPump.runOnce(poll)
            return
        end
        local getter = civvaccess_shared.get_latest_version
        local latest = getter and getter() or nil
        local local_version = civvaccess_shared.version
        if latest and local_version and latest ~= local_version then
            Log.info("FrontendBoot: out-of-date local=" .. tostring(local_version)
                     .. " latest=" .. tostring(latest))
            SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_UPDATE_AVAILABLE"))
        end
    end
    TickPump.runOnce(poll)
end
