# `src/dlc/UI/Shared/CivVAccess_SpeechEngine.lua`

34 lines · Thin wrapper around the `tolk` global injected by the proxy DLL; only `SpeechPipeline` should call this directly.

## Header comment

```
-- Thin wrapper around the tolk global injected by the proxy DLL. Only
-- SpeechPipeline should call this; feature code goes through SpeechPipeline.
```

## Outline

- L4: `SpeechEngine = {}`
- L6: `local _missingWarned = false`
- L8: `local function tolkMissing()`
- L15: `function SpeechEngine.isAvailable()`
- L19: `function SpeechEngine.say(text, interrupt)`
- L27: `function SpeechEngine.stop()`

## Notes

- L8 `tolkMissing`: emits the "proxy DLL not loaded" error only once per session via `_missingWarned` to avoid log spam.
