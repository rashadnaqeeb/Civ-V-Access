# `tests/text_rule_test.lua`

108 lines · Static lint test that scans every `CivVAccess_*.lua` file under `src/dlc/UI/` for direct `Locale.ConvertTextKey` or `Locale.Lookup` calls and fails with a violation report if any are found outside the two allow-listed files.

## Header comment

```
-- Static lint enforcing the project's text-localization rule: mod code must
-- route user-facing text through the Text.key / Text.format wrapper
-- (CivVAccess_Text.lua), not through Locale.ConvertTextKey or Locale.Lookup
-- directly. The wrapper logs missing TXT_KEY lookups; raw Locale calls
-- silently return the key string and the screen reader spells it out letter
-- by letter to the user.
--
-- This is a text-scan over mod-authored Lua files; it does not load them.
-- Two files are allow-listed: the wrapper itself and the test polyfill that
-- stubs Locale for the offline harness.
```

## Outline

- L12: `local M = {}`
- L14: `local ALLOWED = { ... }`
- L19: `local function repoRelative(absPath)`
- L27: `local function listModFiles()`
- L45: `local function scanFile(absPath)`
- L76: `function M.test_no_direct_locale_calls_in_mod_code()`
- L108: `return M`

## Notes

- L14 `ALLOWED`: Exempts `src/dlc/UI/Shared/CivVAccess_Text.lua` (the wrapper, which must call `Locale.ConvertTextKey` by definition) and `src/dlc/UI/InGame/CivVAccess_Polyfill.lua` (the test harness stub that installs a fake `Locale`).
- L27 `listModFiles`: Uses `io.popen('cmd /c "dir /B /S /A:-D src\\dlc\\UI\\CivVAccess_*.lua"')` — Windows `dir` with recursive enumeration — to discover files; fails with `error()` if the popen returns nil or if zero files are found (guards against a broken FS walk silently passing the lint).
- L45 `scanFile`: Skips lines whose stripped leading content matches `^%-%-` (comment lines) before testing for `Locale%.ConvertTextKey%s*%(` and `Locale%.Lookup%s*%(`.
- L76 `test_no_direct_locale_calls_in_mod_code`: Accumulates all violations into a table then calls `error()` with a formatted multi-line message listing `path:line (what) code` for each hit; a single-pass report so all violations are visible at once rather than failing on the first.
