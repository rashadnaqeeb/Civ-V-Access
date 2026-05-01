# tests/run.lua — 178 lines
Entry point for the offline test harness; aggregates all suites and exits with code 0/1.

## Header comment

```
-- Entry point. Aggregates all suites into a single runner and exit code.
-- Invoked by test.ps1 with the repo root as CWD.
```

## Outline

```
  4  local T = require("support")
  8  dofile("src/dlc/UI/InGame/CivVAccess_Polyfill.lua")
  9  dofile("src/dlc/UI/InGame/CivVAccess_InGameStrings_en_US.lua")
 10  dofile("src/dlc/UI/InGame/CivVAccess_SurveyorStrings_en_US.lua")
 11  dofile("src/dlc/UI/Shared/CivVAccess_PluralRules.lua")
 17  dofile("src/dlc/UI/Shared/CivVAccess_UserPrefs.lua")
 22  dofile("src/dlc/UI/InGame/CivVAccess_HexGeom.lua")
 26  civvaccess_shared = civvaccess_shared or {}
 48  Locale.ConvertTextKey = function(key, ...)   -- positional {N_Tag} substituter
 69  Log = { debug, info, warn, error }           -- capturing stub
 75  SpeechEngine = { say, stop }                 -- capturing stub
 83  audio = { _calls, _loadCounter }             -- capturing stub
 90  function audio.load(name)
 95  function audio.play(id)
 98  function audio.play_delayed(id, ms)
101  function audio.cancel_all()
104  function audio.set_master_volume(v)
107  function audio.set_volume(id, v)
110  function audio._reset()
115  T.register("text_filter", ...)
    ...  (all suites registered lines 115-176)
178  os.exit(T.run() and 0 or 1)
```

## Notes

Loads polyfill, localization files, PluralRules, UserPrefs, and HexGeom before any suite runs so production modules have their globals available. Log and SpeechEngine remain test-owned stubs (not in polyfill) so suites can monkey-patch them. The `audio` capturing stub records every call with its arguments and exposes `_reset()` for per-test cleanup.
