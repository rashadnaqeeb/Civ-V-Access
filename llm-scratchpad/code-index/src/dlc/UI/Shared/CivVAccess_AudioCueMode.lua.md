# `src/dlc/UI/Shared/CivVAccess_AudioCueMode.lua`

58 lines · Manages the audio cue output mode preference (speech-only, speech+cue, or cue-only), persisted via Prefs and cached on civvaccess_shared.

## Header comment

```
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
```

## Outline

- L17: `AudioCueMode = AudioCueMode or {}`
- L19: `AudioCueMode.MODE_SPEECH = 0`
- L20: `AudioCueMode.MODE_SPEECH_PLUS_CUE = 1`
- L21: `AudioCueMode.MODE_CUE_ONLY = 2`
- L23: `local PREF_KEY = "AudioCueMode"`
- L24: `local DEFAULT_MODE = AudioCueMode.MODE_SPEECH_PLUS_CUE`
- L26: `function AudioCueMode.getMode()`
- L33: `function AudioCueMode.setMode(m)`
- L42: `function AudioCueMode.isSpeechEnabled()`
- L47: `function AudioCueMode.isCueEnabled()`
- L55: `function AudioCueMode.isCueOnly()`

## Notes

- L47 `AudioCueMode.isCueEnabled`: also returns false when `civvaccess_shared.muted` is true, independent of the mode setting.
