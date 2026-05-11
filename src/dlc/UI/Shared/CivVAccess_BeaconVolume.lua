-- Per-feature gain on the audio beacons. Multiplies into the falloff
-- volume in Beacons.updateBeaconParams, so 0.5 halves every beacon at
-- every distance, 0 silences without removing them from the active set,
-- 1 keeps the original full-volume-at-source behavior. Independent of
-- VolumeControl (master mixer gain): this knob lets the user bring
-- beacons up or down relative to the per-hex terrain cues without
-- touching anything else.
--
-- Beacons.updateBeaconParams reads BeaconVolume.get() live each cursor
-- step, so a slider tweak takes effect on the next move without an
-- explicit notification path.
--
-- Slider mapping. The Settings UI slider operates in [0, 1] but drives
-- the multiplier in [0, MAX], so a slider position of 1.0 corresponds
-- to MAX gain. MAX = 2 * DEFAULT so the historical default (1.0 -- full
-- volume at source) sits at the midpoint of the slider, giving the user
-- equal headroom to go louder or quieter. Settings.lua does the slider
-- <-> multiplier conversion via BeaconVolume.MAX.

BeaconVolume = BeaconVolume or {}

local PREF_KEY = "BeaconMaxVolume"
-- Default matches the pre-slider behavior (full at-source volume), so
-- users who never open Settings hear the same beacons they had before.
local DEFAULT = 1.0

-- Multiplier ceiling. Twice the default so the slider centers on the
-- historical value. The beacon WAV peaks at ~0.22 of full scale so the
-- 2x ceiling never clips at the proxy mixer.
BeaconVolume.MAX = 2 * DEFAULT

local function clamp(v)
    if type(v) ~= "number" then
        return DEFAULT
    end
    if v < 0 then
        return 0
    end
    if v > BeaconVolume.MAX then
        return BeaconVolume.MAX
    end
    return v
end

function BeaconVolume.get()
    if civvaccess_shared.beaconMaxVolume == nil then
        civvaccess_shared.beaconMaxVolume = clamp(Prefs.getFloat(PREF_KEY, DEFAULT))
    end
    return civvaccess_shared.beaconMaxVolume
end

function BeaconVolume.set(v)
    local clamped = clamp(v)
    civvaccess_shared.beaconMaxVolume = clamped
    Prefs.setFloat(PREF_KEY, clamped)
end
