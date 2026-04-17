-- MainMenu accessibility wiring. Included from the MainMenu.lua override
-- after the game's own code has run, so ShowHideHandler is already a live
-- global. MainMenu doesn't install an InputHandler, so priorInput is nil
-- and Esc on MainMenu is silently discarded by the install wrapper.
--
-- Hidden promo buttons (MapPack2/3, AcePatrol, TouchHelp) are omitted from
-- the list — they're date-gated and usually invisible; add them back if a
-- future promo matters to players.

include("CivVAccess_FrontendCommon")

local priorShowHide = ShowHideHandler

-- deferActivate: the EULA-accept path transitions popups synchronously
-- (DequeuePopup EULA, QueuePopup ModsBrowser), briefly firing MainMenu's
-- ShowHide(false) then (true) within one frame. Deferral lets the hide
-- cancel the push before the name + first item speaks.
BaseMenu.install(ContextPtr, {
    name          = "MainMenu",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_MAIN_MENU"),
    deferActivate = true,
    priorShowHide = priorShowHide,
    items = {
        BaseMenuItems.Button({ controlName = "SinglePlayerButton",
            textKey  = "TXT_KEY_MODDING_SINGLE_PLAYER",
            activate = function() SinglePlayerClick() end }),
        BaseMenuItems.Button({ controlName = "MultiplayerButton",
            textKey  = "TXT_KEY_MULTIPLAYER",
            activate = function() MultiplayerClick() end }),
        BaseMenuItems.Button({ controlName = "ModsButton",
            textKey  = "TXT_KEY_MODS",
            activate = function() ModsButtonClick() end }),
        BaseMenuItems.Button({ controlName = "OptionsButton",
            textKey  = "TXT_KEY_OPTIONS",
            activate = function() OptionsClick() end }),
        BaseMenuItems.Button({ controlName = "OtherButton",
            textKey  = "TXT_KEY_OTHER",
            activate = function() OtherClick() end }),
        BaseMenuItems.Button({ controlName = "ExpansionRulesSwitch",
            textKey  = "TXT_KEY_LOAD_MENU_DLC",
            activate = function() OnExpansionRulesSwitch() end }),
        BaseMenuItems.Button({ controlName = "ExitButton",
            textKey  = "TXT_KEY_EXIT_BUTTON",
            activate = function() OnExitGame() end }),
    },
})
