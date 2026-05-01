# `tests/volume_control_test.lua`

100 lines · Tests for `CivVAccess_VolumeControl` covering `get` (proxy default on first read, cache hydration, persisted value), `set` (Prefs persist, cache update, audio proxy push), `set` clamping (above 1, below 0), and `restore` (pushes persisted value to proxy).

## Header comment

```
-- VolumeControl tests. Exercises the get / set / restore pipeline end-to-end:
-- the cache on civvaccess_shared, the Prefs writes, and the audio proxy
-- side effect. Prefs is monkey-patched to a fake handle so reads / writes
-- round-trip without needing the engine's user-data file.
```

## Outline

- L6: `local T = require("support")`
- L7: `local M = {}`
- L9: `local prefsStore`
- L11: `local function setup()`
- L38: `function M.test_get_returns_proxy_default_on_first_read()`
- L45: `function M.test_get_caches_on_shared_after_first_read()`
- L51: `function M.test_get_reads_persisted_value()`
- L57: `function M.test_set_persists_to_prefs()`
- L62: `function M.test_set_updates_cache()`
- L67: `function M.test_set_pushes_to_audio_proxy()`
- L77: `function M.test_set_clamps_above_one()`
- L83: `function M.test_set_clamps_below_zero()`
- L91: `function M.test_restore_pushes_persisted_value_to_proxy()`
- L100: `return M`

## Notes

- L11 `setup`: Replaces `Prefs.getFloat` / `Prefs.setFloat` with a capturing pair backed by `prefsStore` (a plain table); calls `audio._reset()` to clear the proxy call log; resets `civvaccess_shared = {}` so the cache starts empty on every test.
- L38 `test_get_returns_proxy_default_on_first_read`: Asserts `0.1`, which matches the audio proxy's `ensure_audio` default; the test pins this value so a change to the default is caught as a regression rather than silently drifting.
- L67 `test_set_pushes_to_audio_proxy`: Reads `audio._calls[#audio._calls]` and asserts `op == "set_master_volume"` and `v == 0.55`, verifying the proxy side-effect fires in addition to the Prefs write and cache update.
