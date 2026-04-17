-- ExitConfirm accessibility wiring. The game file names its handler
-- OnShowHide (not ShowHideHandler), so we capture that symbol explicitly.
-- PushModal / PopModal still fire the ShowHide handler per the game source.

include("CivVAccess_FrontendCommon")

local priorShowHide = OnShowHide
local priorInput    = InputHandler

Menu.install(ContextPtr, {
    name          = "ExitConfirm",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_EXIT_CONFIRM"),
    preamble      = Text.key("TXT_KEY_MENU_EXIT_WARN"),
    priorShowHide = priorShowHide,
    priorInput    = priorInput,
    items = {
        MenuItems.Button({ controlName = "Yes", textKey = "TXT_KEY_YES_BUTTON",
            activate = function() OnYes() end }),
        MenuItems.Button({ controlName = "No",  textKey = "TXT_KEY_NO_BUTTON",
            activate = function() OnNo() end }),
    },
})
