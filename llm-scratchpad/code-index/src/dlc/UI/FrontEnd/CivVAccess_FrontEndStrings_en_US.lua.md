# `src/dlc/UI/FrontEnd/CivVAccess_FrontEndStrings_en_US.lua`

463 lines · English baseline for all mod-authored strings used in front-end Contexts, plus translator orientation notes covering speech-reader conventions and localization guidelines.

## Header comment

```
-- Mod-authored localized strings, front-end Context.
-- The FrontEnd and InGame skin directories are separate VFS Contexts, so each
-- needs its own strings file with the keys relevant to that Context. The
-- in-game equivalent lives at UI/InGame/CivVAccess_InGameStrings_en_US.lua;
-- some keys are duplicated between the two files because each Context has its
-- own sandboxed CivVAccess_Strings table.
--
-- Translator orientation:
-- [... detailed guidelines for speech output, placeholder syntax, CLDR plurals,
--  register consistency, ASCII preservation, and key-identity policy ...]
```

## Outline

- L85: `CivVAccess_Strings = CivVAccess_Strings or {}`
- L88-455: ~230 string assignments (`CivVAccess_Strings["TXT_KEY_CIVVACCESS_*"] = "..."`)
- L462: `include("CivVAccess_StringsLoader")`
- L463: `StringsLoader.loadOverlay("CivVAccess_FrontEndStrings")`
