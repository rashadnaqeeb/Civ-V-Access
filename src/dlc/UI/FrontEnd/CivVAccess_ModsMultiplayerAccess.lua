-- ModsMultiplayer accessibility wiring. ShowHide / InputHandler are named.
-- Internet button is SetDisabled when Steam is offline; Reconnect is
-- SetHide+SetDisabled when no reconnect cache exists — both states are
-- handled by SimpleListHandler's hidden-skip and disabled-walk paths.

include("CivVAccess_FrontendCommon")
include("CivVAccess_SimpleListHandler")
include("CivVAccess_ModListPreamble")

local priorShowHide = ShowHideHandler
local priorInput    = InputHandler

SimpleListHandler.install(ContextPtr, {
    name          = "ModsMultiplayer",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_MODS_MULTIPLAYER"),
    preamble      = ModListPreamble.fn(),
    priorShowHide = priorShowHide,
    priorInput    = priorInput,
    items = {
        { controlName = "InternetButton",  textKey = "TXT_KEY_MULTIPLAYER_INTERNET_GAME",
          activate    = function() InternetButtonClick() end },
        { controlName = "LANButton",       textKey = "TXT_KEY_MULTIPLAYER_LAN_GAME",
          activate    = function() LANButtonClick() end },
        { controlName = "HotSeatButton",   textKey = "TXT_KEY_MULTIPLAYER_HOTSEAT_GAME",
          activate    = function() HotSeatButtonClick() end },
        { controlName = "ReconnectButton", textKey = "TXT_KEY_MULTIPLAYER_RECONNECT",
          activate    = function() ReconnectButtonClick() end },
        { controlName = "BackButton",      textKey = "TXT_KEY_MODDING_MENU_BACK",
          activate    = function() BackButtonClick() end },
    },
})
