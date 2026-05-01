# `src/dlc/UI/Shared/CivVAccess_VolumeControl.lua`

62 lines · Master volume control for the proxy's audio cue layer, persisting via `Prefs` and caching on `civvaccess_shared`, with a `restore()` call needed after `PlotAudio.loadAll` initializes the audio engine.

## Header comment

```
-- Master volume for the per-hex audio cue layer. The proxy's mixer runs
-- outside the game's audio pipeline, so the engine's own volume sliders
-- don't reach our sounds. This module is the canonical access point for
-- the user-controlled volume of those cues.
-- [... full restore/boot-order comment ...]
```

## Outline

- L15: `VolumeControl = VolumeControl or {}`
- L17: `local PREF_KEY = "MasterVolume"`
- L22: `local DEFAULT_VOLUME = 0.1`
- L24: `local function clampUnit(v)`
- L37: `function VolumeControl.get()`
- L44: `function VolumeControl.set(v)`
- L56: `function VolumeControl.restore()`

## Notes

- L37 `VolumeControl.get`: lazy-initializes `civvaccess_shared.masterVolume` from `Prefs` on first call; subsequent reads use the cache without a `Prefs` round-trip.
- L56 `VolumeControl.restore`: must be called after `PlotAudio.loadAll`; calling it before `ma_engine_init` runs makes `audio.set_master_volume` a no-op and the intent is silently dropped.
