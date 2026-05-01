# `src/dlc/UI/InGame/CivVAccess_SurveyorStrings_en_US.lua`

64 lines · English baseline string table for all TXT_KEY_CIVVACCESS_SURVEYOR_* keys, including the CLDR plural-form bundle for the unexplored-tile suffix.

## Header comment

```
-- Mod-authored strings for the surveyor, in-game Context. Extends the
-- CivVAccess_Strings table that CivVAccess_InGameStrings_en_US.lua sets
-- up; include order in Boot places the base InGame strings first so this
-- file can append.
--
-- The surveyor answers "what is in a radius around the cursor" questions:
-- yields, resources, terrain, friendly units, enemy units, and cities. Each
-- of the six scope queries (yields / resources / terrain / own units /
-- enemy units / cities) has its own Shift+letter binding documented in the
-- help-overlay block below. See the translator orientation block at the
-- top of CivVAccess_InGameStrings_en_US.lua for the conventions that
-- apply across all in-game string files.
```

## Outline

- L13: `CivVAccess_Strings = CivVAccess_Strings or {}`
- L16-56: ~41 string assignments (`CivVAccess_Strings["TXT_KEY_CIVVACCESS_SURVEYOR_*"] = "..."` or `{ one = ..., other = ... }`)
- L62: `include("CivVAccess_StringsLoader")`
- L63: `StringsLoader.loadOverlay("CivVAccess_SurveyorStrings")`
