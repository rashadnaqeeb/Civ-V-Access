# `src/dlc/UI/FrontEnd/CivVAccess_FrontendCommon.lua`

45 lines · Shared include chain that bootstraps all mod infrastructure (Log, Text, SpeechPipeline, HandlerStack, BaseMenu, etc.) into a front-end Context's sandbox.

## Header comment

```
-- Include-chain that every front-end Lua Context needs before it touches
-- Text / Log / SpeechPipeline / HandlerStack / InputRouter. Globals live
-- in per-Context sandboxes (only civvaccess_shared crosses Contexts), so
-- each overridden screen must run this chain in its own Context rather
-- than relying on FrontendBoot's ToolTips-Context setup.
-- include() resolves stems via a lua_State-wide index but executes the
-- file per Context, so the same stems load the same module code into
-- each sandbox.
```

## Outline

- L11: `include("CivVAccess_Log")`
- L12: `include("CivVAccess_UserPrefs")`
- L13: `include("CivVAccess_AudioCueMode")`
- L14: `include("CivVAccess_TextFilter")`
- L16: `include("CivVAccess_StringsLoader")`
- L17: `include("CivVAccess_FrontEndStrings_en_US")`
- L18: `StringsLoader.loadOverlay("CivVAccess_FrontEndStrings")`
- L19: `include("CivVAccess_PluralRules")`
- L20: `include("CivVAccess_Text")`
- L21: `include("CivVAccess_Icons")`
- L22: `include("CivVAccess_SpeechEngine")`
- L23: `include("CivVAccess_SpeechPipeline")`
- L24: `include("CivVAccess_HandlerStack")`
- L25: `include("CivVAccess_InputRouter")`
- L26: `include("CivVAccess_TickPump")`
- L27: `include("CivVAccess_Nav")`
- L28: `include("CivVAccess_BaseMenuItems")`
- L29: `include("CivVAccess_TypeAheadSearch")`
- L30: `include("CivVAccess_BaseMenuHelp")`
- L31: `include("CivVAccess_BaseMenuTabs")`
- L39: `include("CivVAccess_BaseMenuCore")`
- L40: `include("CivVAccess_BaseMenuInstall")`
- L41: `include("CivVAccess_BaseMenuEditMode")`
- L42: `include("CivVAccess_Help")`
- L43: `include("CivVAccess_VolumeControl")`
- L44: `include("CivVAccess_Settings")`
