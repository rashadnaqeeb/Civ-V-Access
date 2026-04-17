-- ModsSinglePlayer accessibility wiring. Button clicks in the game file
-- are anonymous callbacks so we inline the one-line bodies into activate.
-- PlayMap / CustomGame may SetHide at runtime (already handled by the
-- hidden-walking path in Menu).

include("CivVAccess_FrontendCommon")
include("CivVAccess_ModListPreamble")

local priorInput = function(uiMsg, wParam, lParam)
    if (uiMsg == 256 or uiMsg == 260) and wParam == Keys.VK_ESCAPE then
        NavigateBack()
    end
    return true
end

Menu.install(ContextPtr, {
    name        = "ModsSinglePlayer",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_MODS_SINGLE_PLAYER"),
    preamble    = ModListPreamble.fn(),
    priorInput  = priorInput,
    items = {
        MenuItems.Button({ controlName = "PlayMapButton",
            textKey  = "TXT_KEY_MODDING_MAPS",
            activate = function()
                UIManager:QueuePopup(Controls.ModdingGameSetupScreen,
                    PopupPriority.ModdingGameSetupScreen)
            end }),
        MenuItems.Button({ controlName = "CustomGameButton",
            textKey  = "TXT_KEY_MODDING_CUSTOMGAME",
            activate = function()
                UIManager:QueuePopup(Controls.ModsCustom, PopupPriority.ModsCustom)
            end }),
        MenuItems.Button({ controlName = "LoadGameButton",
            textKey  = "TXT_KEY_MODDING_LOADGAME",
            activate = function()
                UIManager:QueuePopup(Controls.LoadGameScreen,
                    PopupPriority.LoadGameScreen)
            end }),
        MenuItems.Button({ controlName = "BackButton",
            textKey  = "TXT_KEY_MODDING_MENU_BACK",
            activate = function() NavigateBack() end }),
    },
})
