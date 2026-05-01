# `src/dlc/UI/Shared/CivVAccess_StringsLoader.lua`

90 lines · Locale overlay loader that `include`s a `<stem>_<locale>` strings file on top of the already-loaded `en_US` baseline, using an explicit supported-locales set to avoid VFS-miss log spam.

## Header comment

```
-- Locale-specific overlay loader for mod-authored strings.
--
-- The Boot include chain always loads the en_US strings file first, so
-- CivVAccess_Strings starts populated with the source-of-truth English
-- entries. This module overlays a locale-specific file on top: for active
-- locale <code> and stem <base>, it includes <base>_<code> if such
-- a file ships in the VFS, and the locale's reassignments overwrite the
-- en_US entries in CivVAccess_Strings.
-- [... full additive-loading and rationale comment ...]
```

## Outline

- L29: `StringsLoader = {}`
- L46: `local supportedLocales = { ... }`
- L58: `local function activeLocale()`
- L73: `function StringsLoader.loadOverlay(stem)`
- L87: `function StringsLoader._setSupportedLocales(set)`

## Notes

- L73 `StringsLoader.loadOverlay`: no-ops for `en_US` (baseline already loaded) and for any locale absent from `supportedLocales`, producing silent fall-through to English without a VFS-miss log entry.
- L87 `StringsLoader._setSupportedLocales`: test seam only; production code does not call it.
