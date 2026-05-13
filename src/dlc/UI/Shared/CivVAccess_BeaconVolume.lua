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
-- to MAX gain. The slider stores the resulting multiplier (not the
-- normalized position), so changing MAX widens or narrows the slider's
-- range without altering the volume any saved value produces. Settings.lua
-- does the slider <-> multiplier conversion via BeaconVolume.MAX.

BeaconVolume = BeaconVolume or {}

local PREF_KEY = "BeaconMaxVolume"
-- Default matches the pre-slider behavior (full at-source volume), so
-- users who never open Settings hear the same beacons they had before.
local DEFAULT = 1.0

-- Multiplier ceiling. PlotAudio's per-hex cues play through the same
-- miniaudio engine and are gated by the same master VolumeControl, so
-- without an above-1.0 ceiling here the beacons cap out at the per-hex
-- baseline. 5x gives the user a meaningful "beacons dominate per-hex
-- cues" zone (most of the slider sits above the historical default).
-- The beacon WAV peaks at ~0.22 of full scale, so at the default master
-- (0.1) the slider top stays well below clipping; users running master
-- near 1.0 with the beacon slider near max will clip and need to balance
-- the two themselves.
BeaconVolume.MAX = 5 * DEFAULT

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
