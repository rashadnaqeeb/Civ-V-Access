-- Master volume for the per-hex audio cue layer. The proxy's mixer runs
-- outside the game's audio pipeline, so the engine's own volume sliders
-- don't reach our sounds. This module is the canonical access point for
-- the user-controlled volume of those cues.
--
-- VolumeControl.get() returns the live value (cached on civvaccess_shared
-- after first read so repeated reads from the Settings menu don't round-
-- trip through user data). VolumeControl.set(v) clamps to [0, 1], updates
-- the cache, persists via Prefs.setFloat, and pushes the new value into
-- the proxy via audio.set_master_volume. VolumeControl.restore() applies
-- the persisted value to the proxy at boot. The proxy stores the user
-- value in a static that ensure_audio reads when it seeds the mixer
-- group, so restore is effective before the audio engine has been
-- initialized -- this is what lets FrontendBoot push the user value
-- before the first menu sound is played.

VolumeControl = VolumeControl or {}

local PREF_KEY = "MasterVolume"

-- Mirrors the proxy's ensure_audio default. If we change one, change both,
-- otherwise restore() at boot will silently re-set the volume to a different
-- value than the proxy chose for users who have never opened Settings.
local DEFAULT_VOLUME = 0.1

local function clampUnit(v)
    if type(v) ~= "number" then
        return DEFAULT_VOLUME
    end
    if v < 0 then
        return 0
    end
    if v > 1 then
        return 1
    end
    return v
end

function VolumeControl.get()
    if civvaccess_shared.masterVolume == nil then
        civvaccess_shared.masterVolume = clampUnit(Prefs.getFloat(PREF_KEY, DEFAULT_VOLUME))
    end
    return civvaccess_shared.masterVolume
end

function VolumeControl.set(v)
    local clamped = clampUnit(v)
    civvaccess_shared.masterVolume = clamped
    Prefs.setFloat(PREF_KEY, clamped)
    if audio ~= nil then
        audio.set_master_volume(clamped)
    end
end

-- Push the persisted value to the proxy. Safe to call before the audio
-- engine has been initialized: the proxy stores the value in a static
-- that ensure_audio later reads when seeding the mixer group.
function VolumeControl.restore()
    local v = VolumeControl.get()
    if audio ~= nil then
        audio.set_master_volume(v)
    end
end
