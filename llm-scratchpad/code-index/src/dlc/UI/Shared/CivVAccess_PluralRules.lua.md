# `src/dlc/UI/Shared/CivVAccess_PluralRules.lua`

131 lines · Per-locale CLDR plural-form selector for mod-authored strings, providing `one`/`few`/`many`/`other` keyword selection for the locales Civ V ships.

## Header comment

```
-- Per-locale CLDR plural-form selection for mod-authored strings.
-- The engine's plural machinery (CIV5 plural-choice tags) only fires for
-- TXT_KEYs registered through the engine text database. Fake-DLC text
-- ingestion is broken in the engine, so our TXT_KEY_CIVVACCESS_* keys
-- never reach that pipeline -- Text.lua resolves them from CivVAccess_Strings
-- and runs positional substitution itself. This module is the parallel
-- plural pipeline for those mod-authored keys.
-- [... full locale coverage comment ...]
```

## Outline

- L19: `PluralRules = {}`
- L22: `local function onePlural(n)`
- L30: `local function frenchPlural(n)`
- L37: `local function polishPlural(n)`
- L50: `local function russianPlural(n)`
- L66: `local function noPlural(_n)`
- L71: `local rules = { ... }`
- L86: `local cachedRule`
- L92: `local function currentRule()`
- L114: `function PluralRules.select(count)`
- L128: `function PluralRules._setLocale(code)`

## Notes

- L92 `currentRule`: caches the resolved rule function for the session lifetime after the first call, since Civ V does not change language mid-session.
- L114 `PluralRules.select`: folds negative counts to absolute value and maps fractional counts directly to "other" without per-locale fraction handling, which is correct for all shipped locales.
- L128 `PluralRules._setLocale`: test seam only; production code must not call it.
