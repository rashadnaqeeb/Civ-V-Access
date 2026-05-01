# `src/dlc/UI/Shared/CivVAccess_Text.lua`

199 lines · Wrapper around `Locale.ConvertTextKey` that logs missing keys, handles mod-authored `TXT_KEY_CIVVACCESS_*` strings with positional substitution, plural selection, and locale-aware civ-adjective + unit-name composition.

## Header comment

```
-- Wrapper around Locale.ConvertTextKey that surfaces missing keys to the log.
-- A missing key in raw Locale silently returns the input string and the user
-- hears "TXT KEY FOO" spelled out. Routing through here turns that into an
-- actionable Log.warn while still returning something speakable.
```

## Outline

- L6: `Text = {}`
- L14: `local function substitute(s, args, argCount)`
- L29: `local function lookup(key, ...)`
- L48: `local function isTxtKey(s)`
- L52: `function Text.key(keyName)`
- L66: `function Text.keyOrNil(keyName)`
- L75: `function Text.format(keyName, ...)`
- L99: `function Text.formatPlural(keyName, count, ...)`
- L146: `local NOUN_ADJ_LOCALES = { ... }`
- L152: `local function activeLocale()`
- L161: `local function lower(s)`
- L168: `local function escapePattern(s)`
- L181: `local function nameContainsAdj(name, adj)`
- L189: `function Text.unitWithCiv(adjKey, nameKey)`

## Notes

- L66 `Text.keyOrNil`: returns `nil` instead of the raw key string on a miss, to prevent unresolved keys from reaching Tolk.
- L99 `Text.formatPlural`: only applies plural bundle logic for `TXT_KEY_CIVVACCESS_*` keys with table-valued entries; non-mod keys and scalar entries fall through to `Text.format`.
- L189 `Text.unitWithCiv`: detects when the localized unit name already embeds the adjective (via `nameContainsAdj`) and skips concatenation to avoid speaking the adjective twice.
