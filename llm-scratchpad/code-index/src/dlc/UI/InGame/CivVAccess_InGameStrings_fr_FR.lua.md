# `src/dlc/UI/InGame/CivVAccess_InGameStrings_fr_FR.lua`

2267 lines · French (fr_FR) locale overlay that overrides the en_US baseline entries in `CivVAccess_Strings` with French translations.

## Header comment

```
-- Mod-authored strings, fr_FR overlay. Baseline in CivVAccess_InGameStrings_en_US.lua.
```

## Outline

- L1: `CivVAccess_Strings = CivVAccess_Strings or {}`
- L1-L2267: ~950 string assignments (`CivVAccess_Strings["TXT_KEY_CIVVACCESS_*"] = "<french>"`)

## Notes

- L1 `CivVAccess_Strings = CivVAccess_Strings or {}`: The `or {}` guard means this file can be loaded standalone or on top of an existing en_US table; keys not overridden here fall back to whatever the en_US baseline set.
