# `tests/text_test.lua`

163 lines · Tests for `CivVAccess_Text` covering `Text.key` (engine hit, missing-key warn + passthrough, non-TXT_KEY_ no-warn, CIVVACCESS short-circuit), `Text.unitWithCiv` (adj-first en_US, noun-first fr_FR, dedup guard, word-boundary guard), and `Text.format` varargs passthrough.

## Header comment

```
-- Text wrapper tests. Locale.ConvertTextKey is replaced by the polyfill in
-- run.lua; these tests override it per-case to simulate engine hit / miss.
-- Log.warn is swapped for a capturing stub so we can assert on missing-key
-- logging at the wrapper boundary.
```

## Outline

- L6: `local T = require("support")`
- L7: `local M = {}`
- L9: `local warnings`
- L10: `local origWarn, origConvert, origGetSpokenLang`
- L12: `local function setup()`
- L23: `local function teardown()`
- L29: `function M.test_key_returns_engine_value()`
- L39: `function M.test_key_logs_and_passes_through_when_missing()`
- L51: `function M.test_key_no_warn_for_non_txt_key_input()`
- L62: `function M.test_key_returns_civvaccess_string_from_table()`
- L77: `function M.test_unit_with_civ_default_locale_orders_adj_first()`
- L92: `function M.test_unit_with_civ_french_orders_noun_first()`
- L110: `function M.test_unit_with_civ_dedup_when_name_already_contains_adj()`
- L128: `function M.test_unit_with_civ_dedup_is_word_bounded()`
- L146: `function M.test_format_passes_varargs_through()`
- L163: `return M`

## Notes

- L12 `setup`: Re-`dofile`s `CivVAccess_Text.lua` on every call so the module's captured `Log.warn` upvalue points at the per-test stub; also saves and restores `Locale.ConvertTextKey` and `Locale.GetCurrentSpokenLanguage` via `teardown()` so per-test overrides don't leak.
- L62 `test_key_returns_civvaccess_string_from_table`: Verifies that a `TXT_KEY_CIVVACCESS_*` key present in `CivVAccess_Strings` bypasses `Locale.ConvertTextKey` entirely (zero calls asserted), confirming the mod-string short-circuit path.
- L128 `test_unit_with_civ_dedup_is_word_bounded`: Uses adjective `"ar"` against unit name `"Archer"` — `"ar"` appears as a prefix inside `"Archer"` but is not a whole word, so dedup must not fire and the output is `"ar Archer"`.
- L146 `test_format_passes_varargs_through`: Captures the full `select("#", ...)` argument list inside the `Locale.ConvertTextKey` spy to assert that `Text.format` forwards exactly 4 args (key + 3 substitution values) without dropping or reordering any.
