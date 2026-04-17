-- MPGameSetupScreen (Multiplayer -> Host Game) accessibility wiring.
-- Single-tab form. GameOptionsStack holds dynamically-built GameOption
-- checkboxes (per DLC + map script); the dynamic list has no stable
-- Controls.X names and is a follow-up, same as AdvancedSetup's per-slot rows.
-- First pass covers the fixed-position widgets.

include("CivVAccess_FrontendCommon")
include("CivVAccess_SimpleListHandler")
include("CivVAccess_FormHandler")

local priorShowHide = ShowHideHandler
local priorInput    = InputHandler

FormHandler.install(ContextPtr, {
    name          = "MPGameSetupScreen",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_MP_GAME_SETUP"),
    priorShowHide = priorShowHide,
    priorInput    = priorInput,
    items = {
        { kind = "checkbox", controlName = "PrivateGameCheckbox",
          textKey = "TXT_KEY_MULTIPLAYER_HOST_PRIVATE_GAME" },
        { kind = "slider",   controlName = "MinorCivsSlider",
          labelControlName = "MinorCivsLabel",
          textKey = "TXT_KEY_AD_SETUP_CITY_STATES" },
        { kind = "pulldown", controlName = "MapTypePullDown",
          textKey = "TXT_KEY_AD_SETUP_MAP_TYPE" },
        { kind = "pulldown", controlName = "MapSizePullDown",
          textKey = "TXT_KEY_AD_SETUP_MAP_SIZE" },
        { kind = "pulldown", controlName = "GameSpeedPullDown",
          textKey = "TXT_KEY_AD_SETUP_GAME_SPEED" },
        { kind = "pulldown", controlName = "EraPull",
          textKey = "TXT_KEY_AD_SETUP_GAME_ERA" },
        { kind = "pulldown", controlName = "TurnModePull",
          textKey = "TXT_KEY_AD_SETUP_GAME_TURN_MODE" },
        { kind = "checkbox", controlName = "MaxTurnsCheck",
          textKey = "TXT_KEY_AD_SETUP_MAX_TURNS" },
        { kind = "checkbox", controlName = "TurnTimerCheck",
          textKey = "TXT_KEY_GAME_OPTION_END_TURN_TIMER_ENABLED" },
        { kind = "checkbox", controlName = "ScenarioCheck",
          textKey = "TXT_KEY_LOAD_SCENARIO" },
        { kind = "button",   controlName = "LoadGameButton",
          textKey = "TXT_KEY_LOAD_GAME",
          activate = function() OnLoadGame() end },
        { kind = "button",   controlName = "DefaultButton",
          textKey = "TXT_KEY_AD_SETUP_DEFAULT",
          activate = function() OnDefaultButton() end },
        { kind = "button",   controlName = "BackButton",
          textKey = "TXT_KEY_BACK_BUTTON",
          activate = function() OnBack() end },
        { kind = "button",   controlName = "ExitButton",
          textKey = "TXT_KEY_EXIT_BUTTON",
          activate = function() OnExitGame() end },
        { kind = "button",   controlName = "LaunchButton",
          textKey = "TXT_KEY_HOST_GAME",
          activate = function() OnStart() end },
    },
})
