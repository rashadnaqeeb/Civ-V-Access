# `src/dlc/UI/InGame/CivVAccess_ScannerStrings_en_US.lua`

107 lines · English baseline string table for all scanner-specific TXT_KEY_CIVVACCESS_SCANNER_* keys, with a trailing StringsLoader call to apply any active locale overlay.

## Header comment

```
-- Mod-authored strings for the scanner, in-game Context.
-- Every key is prefixed TXT_KEY_CIVVACCESS_SCANNER_ per design section 11.
-- Extends the shared CivVAccess_Strings table already populated by
-- CivVAccess_InGameStrings_en_US.lua; include order in Boot places the
-- base InGame strings first so this file can freely assume the table
-- exists.
--
-- The scanner is the keyboard-driven map enumerator: a hierarchy of
-- categories (cities, units, improvements, etc.) and subcategories that
-- the user pages through with PageUp / PageDown chords. Every string in
-- this file is spoken by Tolk through the screen reader; see the
-- translator orientation block at the top of CivVAccess_InGameStrings_en_US.lua
-- for the conventions that apply (lead with the distinguishing word, no
-- decorative punctuation, plural-form bundles use CLDR keywords).
```

## Outline

- L15: `CivVAccess_Strings = CivVAccess_Strings or {}`
- L24-99: ~75 string assignments (`CivVAccess_Strings["TXT_KEY_CIVVACCESS_SCANNER_*"] = "..."`)
- L105: `include("CivVAccess_StringsLoader")`
- L106: `StringsLoader.loadOverlay("CivVAccess_ScannerStrings")`
