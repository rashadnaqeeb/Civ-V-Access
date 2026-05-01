# `src/dlc/UI/FrontEnd/CivVAccess_FrontendBoot.lua`

13 lines · Front-end session boot that announces "Accessibility mod ready" exactly once per session via a `civvaccess_shared` guard, regardless of how many Contexts include this file.

## Header comment

```
-- Front-end boot. Runs in the ToolTips Context (via the ToolTips.lua
-- override) and in every overridden menu Context that includes this file.
-- The announce is guarded on the cross-Context shared table so it fires
-- exactly once per session even though this file runs per-Context.
```

## Outline

- L1: `include("CivVAccess_FrontendCommon")`
- L7: `Log.info("FrontendBoot: Context '" .. tostring(ContextPtr:GetID()) .. "' initialized")`
- L9: `if not civvaccess_shared.frontendAnnounced then`
- L11: `SpeechPipeline.speakInterrupt(Text.key("TXT_KEY_CIVVACCESS_BOOT_FRONTEND"))`
