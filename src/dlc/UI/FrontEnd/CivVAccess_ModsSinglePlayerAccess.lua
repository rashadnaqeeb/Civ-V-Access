-- ModsSinglePlayer accessibility wiring. Button clicks in the game file
-- are anonymous callbacks so we inline the one-line bodies into activate.
-- PlayMap / CustomGame may SetHide at runtime (already handled by the
-- hidden-walking path in BaseMenu).

include("CivVAccess_FrontendCommon")
include("CivVAccess_ModListPreamble")

BaseMenu.install(ContextPtr, {
    name        = "ModsSinglePlayer",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_MODS_SINGLE_PLAYER"),
    preamble    = ModListPreamble.fn(),
    priorInput  = BaseMenu.escOnlyInput(NavigateBack),
    items = {
        BaseMenuItems.Button({ controlName = "PlayMapButton",
            textKey  = "TXT_KEY_MODDING_MAPS",
            activate = function()
                UIManager:QueuePopup(Controls.ModdingGameSetupScreen,
                    PopupPriority.ModdingGameSetupScreen)
            end }),
        BaseMenuItems.Button({ controlName = "CustomGameButton",
            textKey  = "TXT_KEY_MODDING_CUSTOMGAME",
            activate = function()
                UIManager:QueuePopup(Controls.ModsCustom, PopupPriority.ModsCustom)
            end }),
        BaseMenuItems.Button({ controlName = "LoadGameButton",
            textKey  = "TXT_KEY_MODDING_LOADGAME",
            activate = function()
                UIManager:QueuePopup(Controls.LoadGameScreen,
                    PopupPriority.LoadGameScreen)
            end }),
        BaseMenuItems.Button({ controlName = "BackButton",
            textKey  = "TXT_KEY_MODDING_MENU_BACK",
            activate = function() NavigateBack() end }),
    },
})
