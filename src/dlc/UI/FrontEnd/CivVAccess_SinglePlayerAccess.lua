-- SinglePlayer accessibility wiring. ScenariosButton is hidden when no
-- Firaxis scenarios are installed; SimpleListHandler's live :IsHidden()
-- check transparently skips it.

include("CivVAccess_FrontendCommon")
include("CivVAccess_SimpleListHandler")

local priorShowHide = ShowHideHandler
local priorInput    = InputHandler

SimpleListHandler.install(ContextPtr, {
    name          = "SinglePlayer",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_SINGLE_PLAYER"),
    priorShowHide = priorShowHide,
    priorInput    = priorInput,
    items = {
        { controlName = "StartGameButton",    textKey = "TXT_KEY_PLAY_NOW",
          activate    = function() StartGameClick() end },
        { controlName = "GameSetupButton",    textKey = "TXT_KEY_SETUP_GAME",
          activate    = function() SetupGameClicked() end },
        { controlName = "LoadGameButton",     textKey = "TXT_KEY_LOAD_GAME",
          activate    = function() LoadGameClick() end },
        { controlName = "ScenariosButton",    textKey = "TXT_KEY_SCENARIOS",
          activate    = function() ScenariosClicked() end },
        { controlName = "LoadTutorialButton", textKey = "TXT_KEY_TUTORIAL",
          activate    = function() LoadTutorialClick() end },
        { controlName = "BackButton",         textKey = "TXT_KEY_MODDING_MENU_BACK",
          activate    = function() BackButtonClick() end },
    },
})
