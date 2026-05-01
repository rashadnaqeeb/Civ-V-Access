# `src/dlc/UI/InGame/CivVAccess_PlayerChangeAccess.lua`

171 lines · Accessibility wrapper for the hotseat PlayerChange screen (player bumper with optional password field and main-menu exit confirm).

## Header comment

```
-- PlayerChange (hotseat player bumper) accessibility.
--
-- Flat menu with the optional password field, Continue / ChangePassword /
-- Save / MainMenu buttons. Title (leader name) is spoken as the preamble.
-- The password Stack container hides whenever the active hotseat player
-- doesn't have a password set (OnPasswordChanged toggles Controls.Stack);
-- gating the Textfield on "Stack" drops it from navigation automatically.
--
-- MainMenu opens an in-Context ExitConfirm (a hidden yes/no overlay that
-- the base screen toggles by swapping MainContainer / ExitConfirm
-- visibility). Mirrors GameMenu's ExitConfirm treatment: push a flat-list
-- confirm sub (No / Yes Choice items, Esc cancels via OnNo); the tick
-- watches ExitConfirm:IsHidden() so any other dismissal path (active-
-- player change, debug reload) pops the sub cleanly.
```

## Outline

- L16: `include("CivVAccess_Polyfill")`
- L17: `include("CivVAccess_Log")`
- L18: `include("CivVAccess_TextFilter")`
- L19: `include("CivVAccess_InGameStrings_en_US")`
- L20: `include("CivVAccess_PluralRules")`
- L21: `include("CivVAccess_Text")`
- L22: `include("CivVAccess_Icons")`
- L23: `include("CivVAccess_SpeechEngine")`
- L24: `include("CivVAccess_SpeechPipeline")`
- L25: `include("CivVAccess_HandlerStack")`
- L26: `include("CivVAccess_InputRouter")`
- L27: `include("CivVAccess_TickPump")`
- L28: `include("CivVAccess_Nav")`
- L29: `include("CivVAccess_BaseMenuItems")`
- L30: `include("CivVAccess_TypeAheadSearch")`
- L31: `include("CivVAccess_BaseMenuHelp")`
- L32: `include("CivVAccess_BaseMenuTabs")`
- L33: `include("CivVAccess_BaseMenuCore")`
- L34: `include("CivVAccess_BaseMenuInstall")`
- L35: `include("CivVAccess_BaseMenuEditMode")`
- L36: `include("CivVAccess_Help")`
- L38: `local priorShowHide = ShowHideHandler`
- L39: `local priorInput = InputHandler`
- L41: `local function exitConfirmPrompt()`
- L53: `local function pushExitConfirmSub()`
- L105: `local function mainMenuActivate()`
- L114: `local function wrappedShowHide(bIsHide, bIsInit)`
- L126: `BaseMenu.install(ContextPtr, { ... })`
