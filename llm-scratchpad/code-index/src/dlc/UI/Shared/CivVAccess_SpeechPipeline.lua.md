# `src/dlc/UI/Shared/CivVAccess_SpeechPipeline.lua`

69 lines · Central announcement pipeline that filters text, enforces mute/enable state, and deduplicates rapid-fire interrupt calls before forwarding to `SpeechEngine`.

## Header comment

```
-- Central announcement pipeline. All feature code speaks through here.
-- Pipeline: caller -> SpeechPipeline -> TextFilter -> SpeechEngine -> Tolk.
```

## Outline

- L4: `SpeechPipeline = {}`
- L6: `civvaccess_shared = civvaccess_shared or {}`
- L8: `local DEDUPE_WINDOW_SECONDS = 0.05`
- L10: `local _enabled = true`
- L11: `local _lastInterruptText = nil`
- L12: `local _lastInterruptTime = 0`
- L15: `SpeechPipeline._timeSource = os.clock`
- L16: `SpeechPipeline._speakAction = function(text, interrupt)`
- L20: `function SpeechPipeline.isActive()`
- L24: `function SpeechPipeline.setEnabled(enabled)`
- L28: `function SpeechPipeline._reset()`
- L39: `function SpeechPipeline.speakInterrupt(text)`
- L56: `function SpeechPipeline.speakQueued(text)`
- L67: `function SpeechPipeline.stop()`

## Notes

- L39 `SpeechPipeline.speakInterrupt`: checks `civvaccess_shared.muted` (cross-Context hotseat mute) in addition to the per-Context `_enabled` flag; these are separate mechanisms.
- L39 `SpeechPipeline.speakInterrupt`: suppresses the call when the filtered text matches `_lastInterruptText` within a 50 ms window to absorb engine event floods.
- L56 `SpeechPipeline.speakQueued`: bypasses the dedupe window; deduplication only applies to interrupt calls.
