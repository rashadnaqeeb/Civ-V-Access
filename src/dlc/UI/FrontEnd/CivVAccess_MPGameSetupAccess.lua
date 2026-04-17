-- MPGameSetupScreen (Multiplayer -> Host Game) accessibility wiring.
-- Single-tab form. GameOptionsStack holds dynamically-built GameOption
-- checkboxes (per DLC + map script); the dynamic list has no stable
-- Controls.X names and is a follow-up, same as AdvancedSetup's per-slot rows.
-- First pass covers the fixed-position widgets.

include("CivVAccess_FrontendCommon")
include("CivVAccess_FormHandler")
include("CivVAccess_TextFieldSubHandler")

local priorShowHide = ShowHideHandler
local priorInput    = InputHandler

FormHandler.install(ContextPtr, {
    name             = "MPGameSetupScreen",
    displayName      = Text.key("TXT_KEY_CIVVACCESS_SCREEN_MP_GAME_SETUP"),
    priorShowHide    = priorShowHide,
    priorInput       = priorInput,
    focusParkControl = "BackButton",
    items = {
        { kind = "textfield", controlName = "NameBox",
          textKey = "TXT_KEY_MULTIPLAYER_GAME_NAME" },
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
          textKey    = "TXT_KEY_AD_SETUP_MAX_TURNS",
          tooltipKey = "TXT_KEY_AD_SETUP_MAX_TURNS_TT" },
        { kind = "textfield", controlName = "MaxTurnsEdit",
          visibilityControlName = "MaxTurnsEditbox",
          textKey       = "TXT_KEY_AD_SETUP_MAX_TURNS",
          priorCallback = OnMaxTurnsEditBoxChange },
        { kind = "checkbox", controlName = "TurnTimerCheck",
          textKey    = "TXT_KEY_GAME_OPTION_END_TURN_TIMER_ENABLED",
          tooltipKey = "TXT_KEY_GAME_OPTION_END_TURN_TIMER_ENABLED_HELP" },
        { kind = "textfield", controlName = "TurnTimerEdit",
          visibilityControlName = "TurnTimerEditbox",
          textKey       = "TXT_KEY_GAME_OPTION_END_TURN_TIMER_ENABLED",
          priorCallback = OnTurnTimerEditBoxChange },
        { kind = "checkbox", controlName = "ScenarioCheck",
          textKey = "TXT_KEY_LOAD_SCENARIO" },
        { kind = "button",   controlName = "LoadGameButton",
          textKey    = "TXT_KEY_LOAD_GAME",
          tooltipKey = "TXT_KEY_LOAD_GAME_TT",
          activate   = function() OnLoadGame() end },
        { kind = "button",   controlName = "DefaultButton",
          textKey    = "TXT_KEY_AD_SETUP_DEFAULT",
          tooltipKey = "TXT_KEY_AD_SETUP_ADD_DEFAULT_TT",
          activate   = function() OnDefaultButton() end },
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
