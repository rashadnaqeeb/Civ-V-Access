# `tests/text_plural_test.lua`

148 lines · Tests for `Text.formatPlural` covering bundle form selection (one/other), count-separate-from-args calling convention, Russian few/many forms, missing-form fallback chain (selected form -> other -> one), scalar-entry passthrough to `Text.format`, and empty-bundle warning behavior.

## Header comment

```
-- Text.formatPlural: bundle resolution, form selection, scalar fallback,
-- and the missing-form fallback chain. The plural rule itself is
-- exercised by plural_rules_test; this suite checks the wiring between
-- the strings table and PluralRules.
```

## Outline

- L6: `local T = require("support")`
- L7: `local M = {}`
- L9: `local warnings`
- L10: `local origWarn`
- L12: `local function setup()`
- L25: `local function teardown(keys)`
- L33: `function M.test_bundle_one_form_returns_singular_for_count_one()`
- L43: `function M.test_bundle_other_form_returns_plural_for_count_two()`
- L53: `function M.test_count_separate_from_substitution_args()`
- L71: `function M.test_russian_few_picks_few_form()`
- L85: `function M.test_russian_many_picks_many_form()`
- L99: `function M.test_missing_form_falls_back_to_other()`
- L112: `function M.test_missing_other_falls_back_to_one()`
- L121: `function M.test_scalar_entry_falls_through_to_format()`
- L133: `function M.test_empty_bundle_warns_and_returns_key()`
- L148: `return M`

## Notes

- L12 `setup`: Re-`dofile`s `CivVAccess_Text.lua` so its captured `Log.warn` upvalue points at the per-test capturing stub rather than the original.
- L25 `teardown`: Cleans up test-specific keys from `CivVAccess_Strings` and resets `PluralRules` locale to `en_US` to prevent cross-test contamination.
