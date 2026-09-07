-- Map-generation progress speech for map scripts that regenerate the whole
-- map until it passes their own checks. LekMod's Lekmap Pangaea v6.2 does
-- this up to 300 times, and with exactly six civs (the standard LekMod
-- lobby) its spawn validation rejects most maps, so a launch can sit on
-- the loading screen for minutes. A sighted player at least sees the
-- screen stay up; a screen-reader user hears nothing and cannot tell a
-- long regeneration from a hang.
--
-- The map script runs in the same Lua state as the UI Contexts (the proxy
-- log shows one state per session), so it can reach the proxy-injected
-- civvaccess_shared table. FrontendBoot publishes MapGenProgress.report
-- there via MapGenProgress.install; the deploy / package step patches
-- Lekmap's script to call it (Add-CivVAccessLekmapProgressHook in
-- tools/dlc-assembly.ps1). The script side wraps the call in pcall and
-- falls back to plain English through tolk when the hook is absent, so a
-- failure here can never break map generation.
--
-- Events (all numbers come from the script; elapsed is os.clock seconds
-- since the regeneration loop started):
--   report("attempt", attempt, cap, elapsed)          top of each pass
--   report("done", accepted, attempt, cap, elapsed)   after the loop
--
-- Speech policy: attempt 1 is silent (a script that accepts its first map
-- sounds like any other map script). The first regeneration explains what
-- is happening; then a short tick whenever TICK_SECONDS have passed since
-- the last announcement; then the outcome. Everything interrupts: the main
-- thread is blocked inside the script, so nothing else is speaking, and a
-- tick queued behind a stale one would lag reality.
MapGenProgress = {}

MapGenProgress.TICK_SECONDS = 10

local lastSpokenAt = nil

local function seconds(elapsed)
    return math.floor((tonumber(elapsed) or 0) + 0.5)
end

local function say(text)
    SpeechPipeline.speakInterrupt(text)
end

local function onAttempt(attempt, cap, elapsed)
    attempt = tonumber(attempt) or 0
    elapsed = tonumber(elapsed) or 0
    if attempt <= 1 then
        lastSpokenAt = nil
        return
    end
    if lastSpokenAt == nil then
        lastSpokenAt = elapsed
        say(Text.format("TXT_KEY_CIVVACCESS_MAPGEN_REGENERATING", tonumber(cap) or 0))
        return
    end
    if elapsed - lastSpokenAt >= MapGenProgress.TICK_SECONDS then
        lastSpokenAt = elapsed
        local secs = seconds(elapsed)
        say(Text.formatPlural("TXT_KEY_CIVVACCESS_MAPGEN_ATTEMPT", secs, attempt, secs))
    end
end

local function onDone(accepted, attempt, cap, elapsed)
    attempt = tonumber(attempt) or 0
    lastSpokenAt = nil
    if attempt <= 1 then
        return
    end
    local secs = seconds(elapsed)
    if accepted then
        say(Text.formatPlural("TXT_KEY_CIVVACCESS_MAPGEN_ACCEPTED", secs, attempt, secs))
    else
        say(Text.formatPlural("TXT_KEY_CIVVACCESS_MAPGEN_GAVE_UP", secs, attempt, secs))
    end
end

function MapGenProgress.report(event, ...)
    if event == "attempt" then
        onAttempt(...)
    elseif event == "done" then
        onDone(...)
    end
end

-- Publish the reporter where a map script can find it. Re-run per Context
-- include (FrontendBoot runs in every overridden menu Context); the latest
-- Context's closure wins, which is fine, since each carries the same
-- localized strings.
function MapGenProgress.install()
    civvaccess_shared = civvaccess_shared or {}
    civvaccess_shared.mapGenProgress = MapGenProgress.report
end

-- Test seam.
function MapGenProgress._reset()
    lastSpokenAt = nil
end
