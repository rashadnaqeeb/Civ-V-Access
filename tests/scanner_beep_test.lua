-- ScannerBeep: one short tone fired on every scanner cycle that encodes
-- the (origin -> target) displacement via beacon-style pan / pitch /
-- volume. The math is the same as Beacons.updateBeaconParams; this suite
-- pins the surface ScannerBeep exposes -- toggle-gating, voice
-- allocation idempotency, axis encoding, the rail-clamps when
-- displacement exceeds the saturation thresholds, the BeaconVolume /
-- BeaconRange linkage with the beacon sliders, and the no-op paths
-- (toggle off, audio missing, handle missing, nil coords). The stereo-
-- bus mixing the values eventually drive is owned by miniaudio in the
-- proxy and is not exercised here -- the offline harness asserts the
-- right values reach the audio bridge, not what the bridge does with
-- them.

local T = require("support")
local M = {}

local function setup()
    BeaconRange = {
        get = function()
            return 30
        end,
    }
    BeaconVolume = {
        get = function()
            return 1.0
        end,
    }

    civvaccess_shared = civvaccess_shared or {}
    civvaccess_shared.scannerBeepHandle = nil
    civvaccess_shared.scannerDirectionBeep = nil

    Prefs = Prefs or {}
    Prefs.getBool = function(_key, default)
        return default
    end

    Map.PlotDistance = function(_x1, _y1, _x2, _y2)
        return 0
    end

    audio._reset()
    dofile("src/dlc/UI/InGame/CivVAccess_ScannerBeep.lua")
end

local function findCall(op, slot)
    for _, c in ipairs(audio._calls) do
        if c.op == op and (slot == nil or c.id == slot) then
            return c
        end
    end
    return nil
end

local function enableBeep()
    civvaccess_shared.scannerDirectionBeep = true
end

-- ===== loadAll =====

function M.test_loadAll_allocates_one_voice_non_looping_silent()
    setup()
    ScannerBeep.loadAll()
    T.truthy(civvaccess_shared.scannerBeepHandle, "loadAll must allocate a voice handle")
    -- ScannerBeep voice is non-looping so the WAV plays through once per
    -- audio.play. Production cancel_all only stops non-looping voices --
    -- the trade is that PlotAudio cancel_all (per-cursor-move) can clip
    -- the beep when auto-move is on, which the design accepts since the
    -- beep is fired after autoMoveIfEnabled.
    local loop = findCall("set_loop", civvaccess_shared.scannerBeepHandle)
    T.truthy(loop, "set_loop must be called at load")
    T.eq(loop.v, false, "scanner beep voice must be non-looping")
    local vol = findCall("set_volume", civvaccess_shared.scannerBeepHandle)
    T.truthy(vol, "initial volume must be set")
    T.eq(vol.v, 0, "initial volume must be 0 so a stray play before parameters won't blast")
end

function M.test_loadAll_is_idempotent()
    setup()
    ScannerBeep.loadAll()
    local first = civvaccess_shared.scannerBeepHandle
    audio._reset()
    ScannerBeep.loadAll()
    T.eq(#audio._calls, 0, "subsequent loadAll calls must short-circuit")
    T.eq(civvaccess_shared.scannerBeepHandle, first)
end

-- ===== toggle gating =====

function M.test_play_no_op_when_toggle_off()
    -- Default state: civvaccess_shared.scannerDirectionBeep is false
    -- (Prefs.getBool defaults). play must not touch the audio bank.
    setup()
    ScannerBeep.loadAll()
    audio._reset()
    ScannerBeep.play(0, 0, 5, 0)
    T.eq(#audio._calls, 0, "play must be silent when the toggle is off")
end

function M.test_play_fires_when_toggle_on()
    setup()
    ScannerBeep.loadAll()
    enableBeep()
    audio._reset()
    ScannerBeep.play(0, 0, 5, 0)
    T.truthy(findCall("play", civvaccess_shared.scannerBeepHandle), "audio.play must fire when toggle on")
end

-- ===== no-op paths =====

function M.test_play_no_op_when_handle_missing()
    setup()
    enableBeep()
    -- Skip loadAll: handle stays nil.
    audio._reset()
    ScannerBeep.play(0, 0, 5, 0)
    T.eq(#audio._calls, 0, "play must not fire before loadAll")
end

function M.test_play_no_op_when_audio_binding_missing()
    setup()
    ScannerBeep.loadAll()
    enableBeep()
    local prev = audio
    audio = nil
    -- Must return cleanly without indexing nil.
    ScannerBeep.play(0, 0, 5, 0)
    audio = prev
end

function M.test_play_no_op_on_nil_coords()
    setup()
    ScannerBeep.loadAll()
    enableBeep()
    audio._reset()
    ScannerBeep.play(nil, nil, 5, 0)
    T.eq(#audio._calls, 0, "missing origin must short-circuit before audio bank touched")
    ScannerBeep.play(0, 0, nil, nil)
    T.eq(#audio._calls, 0, "missing target must short-circuit before audio bank touched")
end

function M.test_play_silent_when_origin_equals_target()
    -- Cycle landed on the entry's own plot (or the snapshot anchor matches
    -- the entry under auto-move). formatInstance speaks SCANNER_HERE in
    -- this case; the beep mirrors that silence rather than firing a
    -- centered, full-volume tone with no directional information.
    setup()
    ScannerBeep.loadAll()
    enableBeep()
    audio._reset()
    ScannerBeep.play(7, 3, 7, 3)
    T.eq(#audio._calls, 0, "no audio when origin == target")
end

-- ===== axis encoding =====

function M.test_play_pan_proportional_to_column_delta()
    -- 6 hexes east of origin: dcol = 6, PAN_SAT_HEXES = 12, pan = 0.5.
    -- Row delta zero -> pitch stays at 1.0. Matches Beacons.updateBeaconParams.
    setup()
    ScannerBeep.loadAll()
    enableBeep()
    audio._reset()
    ScannerBeep.play(0, 0, 6, 0)
    local pan = findCall("set_pan", civvaccess_shared.scannerBeepHandle)
    T.truthy(pan)
    T.eq(pan.v, 0.5)
    local pitch = findCall("set_pitch", civvaccess_shared.scannerBeepHandle)
    T.truthy(pitch)
    T.eq(pitch.v, 1.0)
end

function M.test_play_pitch_one_semitone_per_row()
    -- 6 rows north: drow = 6, pitch = 2^(6/12) ~= 1.4142.
    setup()
    ScannerBeep.loadAll()
    enableBeep()
    audio._reset()
    ScannerBeep.play(0, 6, 0, 0)
    local pitch = findCall("set_pitch", civvaccess_shared.scannerBeepHandle)
    T.truthy(pitch)
    -- drow = 0 - 6 = -6 -> pitch = 2^(-6/12). HexGeom.displacement returns
    -- toY - fromY (positive when target is south of origin).
    local expected = 2 ^ (-6 / 12)
    T.truthy(math.abs(pitch.v - expected) < 1e-6, "pitch must be 2^(drow/12); got " .. tostring(pitch.v))
end

-- ===== rail clamps =====

function M.test_play_pan_saturates_past_12_hexes()
    setup()
    ScannerBeep.loadAll()
    enableBeep()
    audio._reset()
    -- 30 hexes east clamps to +1; HexGeom.displacement returns dcol = 30
    -- and pan would otherwise overflow to 2.5.
    ScannerBeep.play(0, 0, 30, 0)
    local pan = findCall("set_pan", civvaccess_shared.scannerBeepHandle)
    T.truthy(pan)
    T.eq(pan.v, 1.0, "pan must clamp to +1 past PAN_SAT_HEXES")

    audio._reset()
    ScannerBeep.play(30, 0, 0, 0)
    pan = findCall("set_pan", civvaccess_shared.scannerBeepHandle)
    T.truthy(pan)
    T.eq(pan.v, -1.0, "pan must clamp to -1 past PAN_SAT_HEXES")
end

function M.test_play_pitch_saturates_past_one_octave()
    setup()
    ScannerBeep.loadAll()
    enableBeep()
    audio._reset()
    -- 20 rows north would otherwise raise pitch by 5/3 octaves.
    -- PITCH_MAX_SEMITONES = 12 caps semitones to +/-12 -> pitch in [0.5, 2.0].
    ScannerBeep.play(0, 20, 0, 0)
    local pitch = findCall("set_pitch", civvaccess_shared.scannerBeepHandle)
    T.truthy(pitch)
    T.eq(pitch.v, 0.5, "pitch must clamp to -1 octave past PITCH_MAX_SEMITONES")

    audio._reset()
    ScannerBeep.play(0, 0, 0, 20)
    pitch = findCall("set_pitch", civvaccess_shared.scannerBeepHandle)
    T.truthy(pitch)
    T.eq(pitch.v, 2.0, "pitch must clamp to +1 octave past PITCH_MAX_SEMITONES")
end

-- ===== volume linkage with beacon sliders =====

function M.test_play_volume_at_source_uses_beacon_volume()
    setup()
    ScannerBeep.loadAll()
    enableBeep()
    BeaconVolume.get = function()
        return 1.5
    end
    Map.PlotDistance = function()
        return 0
    end
    audio._reset()
    ScannerBeep.play(0, 0, 1, 0)
    local vol = findCall("set_volume", civvaccess_shared.scannerBeepHandle)
    T.truthy(vol)
    T.eq(vol.v, 1.5, "at-source volume must come straight from BeaconVolume")
end

function M.test_play_volume_falls_linearly_with_distance()
    setup()
    ScannerBeep.loadAll()
    enableBeep()
    BeaconRange.get = function()
        return 30
    end
    BeaconVolume.get = function()
        return 1.0
    end
    Map.PlotDistance = function()
        return 15
    end
    audio._reset()
    ScannerBeep.play(0, 0, 15, 0)
    local vol = findCall("set_volume", civvaccess_shared.scannerBeepHandle)
    T.truthy(vol)
    T.eq(vol.v, 0.5, "halfway to range -> half volume")
end

function M.test_play_volume_clamped_at_zero_past_range()
    setup()
    ScannerBeep.loadAll()
    enableBeep()
    BeaconRange.get = function()
        return 30
    end
    Map.PlotDistance = function()
        return 60
    end
    audio._reset()
    ScannerBeep.play(0, 0, 60, 0)
    local vol = findCall("set_volume", civvaccess_shared.scannerBeepHandle)
    T.truthy(vol)
    T.eq(vol.v, 0, "past range, volume must clamp to 0 rather than going negative")
end

return M
