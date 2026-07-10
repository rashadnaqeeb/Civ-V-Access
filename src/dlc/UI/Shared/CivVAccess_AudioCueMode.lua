-- Audio cue output mode. Three values:
--   MODE_SPEECH          = 0: speech only, no audio cues (preserves the mod's
--                            original behavior for users who don't want audio)
--   MODE_SPEECH_PLUS_CUE = 1: speech plus layered per-hex audio cue
--   MODE_CUE_ONLY        = 2: audio cue only, except natural wonders, which
--                            are always spoken since the cue palette has no
--                            dedicated wonder sounds
--
-- Persisted via Prefs.getInt/setInt. The live value is cached on
-- civvaccess_shared so repeated reads across cursor moves don't round-trip
-- through the engine's user-data file.
--
-- No user-facing toggle yet; the config menu (future) will own that along
-- with the master volume slider. For now, dev-side changes go through
-- AudioCueMode.setMode().

AudioCueMode = AudioCueMode or {}

AudioCueMode.MODE_SPEECH = 0
AudioCueMode.MODE_SPEECH_PLUS_CUE = 1
AudioCueMode.MODE_CUE_ONLY = 2

local PREF_KEY = "AudioCueMode"

-- Exposed so the Settings screen's reset-to-defaults can restore it without
-- duplicating the value.
AudioCueMode.DEFAULT_MODE = AudioCueMode.MODE_SPEECH_PLUS_CUE

function AudioCueMode.getMode()
    if civvaccess_shared.audioCueMode == nil then
        civvaccess_shared.audioCueMode = Prefs.getInt(PREF_KEY, AudioCueMode.DEFAULT_MODE)
    end
    return civvaccess_shared.audioCueMode
end

function AudioCueMode.setMode(m)
    if m ~= AudioCueMode.MODE_SPEECH and m ~= AudioCueMode.MODE_SPEECH_PLUS_CUE and m ~= AudioCueMode.MODE_CUE_ONLY then
        Log.warn("AudioCueMode.setMode: invalid mode " .. tostring(m))
        return
    end
    civvaccess_shared.audioCueMode = m
    Prefs.setInt(PREF_KEY, m)
end

function AudioCueMode.isSpeechEnabled()
    local m = AudioCueMode.getMode()
    return m == AudioCueMode.MODE_SPEECH or m == AudioCueMode.MODE_SPEECH_PLUS_CUE
end

function AudioCueMode.isCueEnabled()
    if civvaccess_shared.muted then
        return false
    end
    local m = AudioCueMode.getMode()
    return m == AudioCueMode.MODE_SPEECH_PLUS_CUE or m == AudioCueMode.MODE_CUE_ONLY
end

function AudioCueMode.isCueOnly()
    return AudioCueMode.getMode() == AudioCueMode.MODE_CUE_ONLY
end
