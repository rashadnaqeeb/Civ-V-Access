# `tests/strings_loader_test.lua`

99 lines · Tests for `CivVAccess_StringsLoader` covering locale detection, overlay inclusion decisions for supported/unsupported/baseline locales, stem concatenation shape, and nil-API fallback behavior.

## Header comment

```
-- StringsLoader: branches over the active locale and the supported-locales
-- set to decide whether to include() the overlay file. The actual file
-- existence is the engine's concern; tests stub include() to capture the
-- stem the loader requested.
```

## Outline

- L6: `local T = require("support")`
- L7: `local M = {}`
- L9: `local origGetCurrentSpokenLanguage`
- L10: `local origInclude`
- L11: `local includeCalls`
- L13: `local function setup()`
- L22: `local function teardown()`
- L29: `local function setLocale(code)`
- L35: `function M.test_en_US_skips_overlay()`
- L43: `function M.test_supported_non_baseline_locale_includes_overlay()`
- L52: `function M.test_unsupported_locale_skips_overlay()`
- L62: `function M.test_stem_concatenation_uses_locale_suffix()`
- L74: `function M.test_missing_GetCurrentSpokenLanguage_falls_back_to_en_US()`
- L88: `function M.test_GetCurrentSpokenLanguage_table_without_Type_falls_back()`
- L99: `return M`

## Notes

- L13 `setup`: Replaces the global `include` function with a capturing stub so tests assert on the stem string passed to the engine's VFS loader without needing real files.
- L22 `teardown`: Calls `StringsLoader._setSupportedLocales({})` to reset module state between tests, preventing locale-set contamination.
