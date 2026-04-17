-- AdvancedSetup (Single Player -> Set Up Game) accessibility wiring.
-- Single-tab form; the player-slot rows are dynamic and managed inside a
-- scroll stack, so the first pass covers only the global widgets (map,
-- size, handicap, speed, era, max-turns, minor civs slider, human Civ
-- pulldown, human team pulldown, bottom-row actions). Per-slot AI player
-- controls are a follow-up: they are built one per slot from g_SlotInstances
-- and have no stable Controls.X name we can enumerate here.

include("CivVAccess_FrontendCommon")
include("CivVAccess_FormHandler")
include("CivVAccess_TextFieldSubHandler")

local priorShowHide = ShowHideHandler
local priorInput    = InputHandler

-- MaxTurnsEdit's base-game callback is an anonymous inline function, so we
-- cannot capture the original by name. Re-declare the same one-liner as our
-- priorCallback so per-character SetMaxTurns still happens while our wrapper
-- is installed; on sub pop, RegisterCallback restores the engine's original.
local function maxTurnsEditCallback()
    PreGame.SetMaxTurns(Controls.MaxTurnsEdit:GetText())
end

FormHandler.install(ContextPtr, {
    name             = "AdvancedSetup",
    displayName      = Text.key("TXT_KEY_CIVVACCESS_SCREEN_ADVANCED_SETUP"),
    priorShowHide    = priorShowHide,
    priorInput       = priorInput,
    focusParkControl = "BackButton",
    items = {
        { kind = "pulldown", controlName = "CivPulldown",
          textKey = "TXT_KEY_RANDOM_LEADER",
          tooltipKey = "TXT_KEY_RANDOM_LEADER_HELP" },
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
          textKey    = "TXT_KEY_AD_SETUP_MAX_TURNS",
          tooltipKey = "TXT_KEY_AD_SETUP_MAX_TURNS_TT" },
        -- The MaxTurnsEditbox wrapper Box is what SetHide is called on when
        -- MaxTurnsCheck is toggled; the EditBox inside doesn't mirror that
        -- state, so the visibilityControlName points at the wrapper.
        { kind = "textfield", controlName = "MaxTurnsEdit",
          visibilityControlName = "MaxTurnsEditbox",
          textKey       = "TXT_KEY_AD_SETUP_MAX_TURNS",
          priorCallback = maxTurnsEditCallback },
        { kind = "button",   controlName = "AddAIButton",
          textKey    = "TXT_KEY_AD_SETUP_ADD_AI_PLAYER",
          tooltipKey = "TXT_KEY_AD_SETUP_ADD_AI_PLAYER_TT",
          activate   = function() OnAdAIClicked() end },
        { kind = "button",   controlName = "DefaultButton",
          textKey    = "TXT_KEY_AD_SETUP_DEFAULT",
          tooltipKey = "TXT_KEY_AD_SETUP_ADD_DEFAULT_TT",
          activate   = function() OnDefaultsClicked() end },
        { kind = "button",   controlName = "BackButton",
          textKey    = "TXT_KEY_BACK_BUTTON",
          tooltipKey = "TXT_KEY_REFRESH_GAME_LIST_TT",
          activate   = function() OnBackClicked() end },
        { kind = "button",   controlName = "StartButton",
          textKey  = "TXT_KEY_START_GAME",
          activate = function() OnStartClicked() end },
    },
})
