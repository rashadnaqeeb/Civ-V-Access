-- MainMenu accessibility wiring. Included from the MainMenu.lua override
-- after the game's own code has run, so ShowHideHandler is already a live
-- global. MainMenu doesn't install an InputHandler, so priorInput is nil
-- and Esc on MainMenu is silently discarded by the install wrapper.
--
-- Hidden promo buttons (MapPack2/3, AcePatrol, TouchHelp) are omitted from
-- the list — they're date-gated and usually invisible; add them back if a
-- future promo matters to players.

include("CivVAccess_FrontendCommon")
include("CivVAccess_SimpleListHandler")

local priorShowHide = ShowHideHandler

SimpleListHandler.install(ContextPtr, {
    name          = "MainMenu",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_MAIN_MENU"),
    priorShowHide = priorShowHide,
    priorInput    = nil,
    items = {
        { controlName = "SinglePlayerButton",    textKey = "TXT_KEY_MODDING_SINGLE_PLAYER",
          activate    = function() SinglePlayerClick() end },
        { controlName = "MultiplayerButton",     textKey = "TXT_KEY_MULTIPLAYER",
          activate    = function() MultiplayerClick() end },
        { controlName = "ModsButton",            textKey = "TXT_KEY_MODS",
          activate    = function() ModsButtonClick() end },
        { controlName = "OptionsButton",         textKey = "TXT_KEY_OPTIONS",
          activate    = function() OptionsClick() end },
        { controlName = "OtherButton",           textKey = "TXT_KEY_OTHER",
          activate    = function() OtherClick() end },
        { controlName = "ExpansionRulesSwitch",  textKey = "TXT_KEY_LOAD_MENU_DLC",
          activate    = function() OnExpansionRulesSwitch() end },
        { controlName = "ExitButton",            textKey = "TXT_KEY_EXIT_BUTTON",
          activate    = function() OnExitGame() end },
    },
})
