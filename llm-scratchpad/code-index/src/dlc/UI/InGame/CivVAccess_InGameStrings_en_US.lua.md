# `src/dlc/UI/InGame/CivVAccess_InGameStrings_en_US.lua`

2456 lines · English (en_US) baseline for all mod-authored in-game spoken strings, loaded into the `CivVAccess_Strings` global table.

## Header comment

```
-- Mod-authored localized strings, in-game Context.
-- Looked up by Text.key / Text.format in CivVAccess_Text.lua. Sets a global
-- (rather than returning) so the offline test harness can dofile() it without
-- relying on Civ V's include() semantics. The front-end equivalent lives at
-- UI/FrontEnd/CivVAccess_FrontEndStrings_en_US.lua; the scanner and surveyor
-- subsystems extend this table from companion files in the same directory
-- (CivVAccess_ScannerStrings_en_US.lua and CivVAccess_SurveyorStrings_en_US.lua),
-- which Boot includes after this file.
--
-- Translator orientation:
-- - Every string in this file is spoken by a screen reader (Tolk into SAPI /
--   NVDA / JAWS), never displayed visually. There is no graphical fallback.
--   If a translation is missing or wrong the user has no way to recover, so
--   accuracy matters more than tone.
-- [... extended translator guidance through line 109 ...]
```

## Outline

- L112: `CivVAccess_Strings = CivVAccess_Strings or {}`
- L112-L2450: ~950 string assignments (`CivVAccess_Strings["TXT_KEY_CIVVACCESS_*"] = "..."`)
- L2455: `include("CivVAccess_StringsLoader")`
- L2456: `StringsLoader.loadOverlay("CivVAccess_InGameStrings")`

## Notes

- L2456 `StringsLoader.loadOverlay`: Called at the bottom so every Context that includes this baseline file also gets the active locale's overlay applied; without it, popup Contexts would always speak English regardless of the user's language setting.
