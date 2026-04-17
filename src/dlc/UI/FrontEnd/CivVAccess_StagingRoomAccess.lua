-- StagingRoom (host + guest multiplayer pre-launch lobby) accessibility
-- wiring. Single-tab form covering the global game-settings widgets and
-- action buttons. Per-player-slot rows (InvitePulldown, CivPulldown,
-- TeamPulldown, SlotTypePulldown, HandicapPulldown inside the human slot
-- box and 15 AI rows built from PlayerSlot instances) are a follow-up:
-- the slot count and instance names are dynamic, so they need their own
-- discovery pass and a dynamic-item-list variant of FormHandler.

include("CivVAccess_FrontendCommon")
include("CivVAccess_FormHandler")

local priorShowHide = ShowHideHandler
local priorInput    = InputHandler

FormHandler.install(ContextPtr, {
    name             = "StagingRoom",
    displayName      = Text.key("TXT_KEY_CIVVACCESS_SCREEN_STAGING_ROOM"),
    priorShowHide    = priorShowHide,
    priorInput       = priorInput,
    focusParkControl = "CivVAccessFocusPark",
    items = {
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
          textKey       = "TXT_KEY_CIVVACCESS_FIELD_MAX_TURNS",
          priorCallback = OnMaxTurnsEditBoxChange },
        { kind = "checkbox", controlName = "TurnTimerCheck",
          textKey    = "TXT_KEY_GAME_OPTION_END_TURN_TIMER_ENABLED",
          tooltipKey = "TXT_KEY_GAME_OPTION_END_TURN_TIMER_ENABLED_HELP" },
        { kind = "textfield", controlName = "TurnTimerEdit",
          visibilityControlName = "TurnTimerEditbox",
          textKey       = "TXT_KEY_CIVVACCESS_FIELD_TURN_TIMER",
          priorCallback = OnTurnTimerEditBoxChange },
        { kind = "checkbox", controlName = "ScenarioCheck",
          textKey = "TXT_KEY_LOAD_SCENARIO" },
        { kind = "button",   controlName = "InviteButton",
          textKey = "TXT_KEY_MP_INVITE_BUTTON",
          activate = function() OnInviteButton() end },
        { kind = "button",   controlName = "SaveButton",
          textKey = "TXT_KEY_SAVE_GAME",
          activate = function() OnSaveButton() end },
        { kind = "button",   controlName = "BackButton",
          textKey = "TXT_KEY_BACK_BUTTON",
          activate = function() BackButtonClick() end },
        { kind = "button",   controlName = "ExitButton",
          textKey = "TXT_KEY_EXIT_BUTTON",
          activate = function() OnExitGame() end },
        { kind = "button",   controlName = "LaunchButton",
          textKey = "TXT_KEY_MP_LAUNCH_GAME",
          activate = function() LaunchGame() end },
    },
})
