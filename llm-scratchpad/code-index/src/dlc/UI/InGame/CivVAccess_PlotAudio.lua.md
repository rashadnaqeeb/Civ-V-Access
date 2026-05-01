# `src/dlc/UI/InGame/CivVAccess_PlotAudio.lua`

202 lines · Maps plot terrain/feature state to audio cue descriptors and drives the proxy's audio bank for the per-hex cursor sound layer.

## Header comment

```
-- Plot-handle-in, cue-out mapping for the per-hex audio layer. Output shape:
-- { bed = "<name>", fog = bool, stingers = { "<name>", ... } } or nil for an
-- unrevealed plot.
--
-- PlotAudio.loadAll() preloads every sound in the palette into the proxy's
-- audio bank and stashes the name-to-handle map on civvaccess_shared so
-- re-entered Contexts reuse the existing handles (the proxy also dedups by
-- name; both guards keep the bank from filling up with duplicates).
--
-- PlotAudio.emit(plot) is the one-call dispatcher used by the cursor layer:
-- cancel in-flight audio, play bed + optional fog at t=0, fire each stinger
-- at the offset.
--
-- Natural wonders do NOT promote to a feature bed here. The bed for a
-- wonder plot comes from the plot's mountain/terrain core, and wonder
-- identity is spoken by the cursor pipeline separately (no dedicated wonder
-- sound in the palette).
--
-- See .planning/audio-cues-plan.md for the sound-palette rationale.
```

## Outline

- L21: `PlotAudio = PlotAudio or {}`
- L25: `local STINGER_OFFSET_MS = 100`
- L30: `local FOG_VOLUME = 0.5`
- L35: `local PROMOTABLE_FEATURES = { ... }`
- L45: `local STINGER_FEATURES = { ... }`
- L51: `local TERRAIN_BEDS = { ... }`
- L63: `local function allSoundNames()`
- L81: `local function featureRow(plot)`
- L89: `function PlotAudio.cueForPlot(plot)`
- L143: `function PlotAudio.loadAll()`
- L170: `local function handleFor(name)`
- L175: `function PlotAudio.emit(plot)`

## Notes

- L21 `PlotAudio = PlotAudio or {}`: Uses the `or {}` guard (not `PlotAudio = {}`) so `loadAll` stays install-once across load-from-game; the audio bank handles on `civvaccess_shared.plotAudioHandles` persist with the same guard.
- L89 `PlotAudio.cueForPlot`: Returns `nil` for unrevealed plots; the fog field in the returned cue signals revealed-but-not-visible (plays the fog wash overlay at half volume).
