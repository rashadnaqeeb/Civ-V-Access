-- AdvancedSetup (Single Player -> Set Up Game) accessibility wiring.
-- Single-tab form; the player-slot rows are dynamic and managed inside a
-- scroll stack, so the first pass covers only the global widgets (map,
-- size, handicap, speed, era, max-turns, minor civs slider, human Civ
-- pulldown, human team pulldown, bottom-row actions). Per-slot AI player
-- controls are a follow-up: they are built one per slot from g_SlotInstances
-- and have no stable Controls.X name we can enumerate here.

include("CivVAccess_FrontendCommon")
include("CivVAccess_SimpleListHandler")
include("CivVAccess_FormHandler")

local priorShowHide = ShowHideHandler
local priorInput    = InputHandler

FormHandler.install(ContextPtr, {
    name          = "AdvancedSetup",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_ADVANCED_SETUP"),
    priorShowHide = priorShowHide,
    priorInput    = priorInput,
    items = {
        { kind = "pulldown", controlName = "CivPulldown",
          textKey = "TXT_KEY_RANDOM_LEADER" },
        { kind = "pulldown", controlName = "TeamPullDown",
          textKey = "TXT_KEY_MULTIPLAYER_SELECT_TEAM" },
        { kind = "pulldown", controlName = "MapTypePullDown",
          textKey = "TXT_KEY_AD_SETUP_MAP_TYPE" },
        { kind = "pulldown", controlName = "MapSizePullDown",
          textKey = "TXT_KEY_AD_SETUP_MAP_SIZE" },
        { kind = "pulldown", controlName = "HandicapPullDown",
          textKey = "TXT_KEY_AD_SETUP_HANDICAP" },
        { kind = "pulldown", controlName = "GameSpeedPullDown",
          textKey = "TXT_KEY_AD_SETUP_GAME_SPEED" },
        { kind = "pulldown", controlName = "EraPullDown",
          textKey = "TXT_KEY_AD_SETUP_GAME_ERA" },
        { kind = "slider",   controlName = "MinorCivsSlider",
          labelControlName = "MinorCivsLabel",
          textKey = "TXT_KEY_AD_SETUP_CITY_STATES" },
        { kind = "checkbox", controlName = "MaxTurnsCheck",
          textKey = "TXT_KEY_AD_SETUP_MAX_TURNS" },
        { kind = "button",   controlName = "AddAIButton",
          textKey = "TXT_KEY_AD_SETUP_ADD_AI_PLAYER",
          activate = function() OnAdAIClicked() end },
        { kind = "button",   controlName = "DefaultButton",
          textKey = "TXT_KEY_AD_SETUP_DEFAULT",
          activate = function() OnDefaultsClicked() end },
        { kind = "button",   controlName = "BackButton",
          textKey = "TXT_KEY_BACK_BUTTON",
          activate = function() OnBackClicked() end },
        { kind = "button",   controlName = "StartButton",
          textKey = "TXT_KEY_START_GAME",
          activate = function() OnStartClicked() end },
    },
})
