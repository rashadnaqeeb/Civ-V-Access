-- ModsMultiplayer accessibility wiring. ShowHide / InputHandler are named.
-- Internet button is SetDisabled when Steam is offline; Reconnect is
-- SetHide+SetDisabled when no reconnect cache exists — both states are
-- handled by Menu's hidden-skip and disabled-walk paths.
-- Internet's "why disabled" tooltip mirrors MultiplayerSelect's wiring:
-- the screen sets it via LocalizeAndSetToolTip, and we re-check
-- Network.IsConnectedToSteam at announce time.

include("CivVAccess_FrontendCommon")
include("CivVAccess_ModListPreamble")

local priorShowHide = ShowHideHandler
local priorInput    = InputHandler

local function internetTooltipFn()
    if Network.IsConnectedToSteam() then return nil end
    return Text.key("TXT_KEY_STEAM_CONNECTED_NO")
end

Menu.install(ContextPtr, {
    name          = "ModsMultiplayer",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_MODS_MULTIPLAYER"),
    preamble      = ModListPreamble.fn(),
    priorShowHide = priorShowHide,
    priorInput    = priorInput,
    items = {
        MenuItems.Button({ controlName = "InternetButton",
            textKey   = "TXT_KEY_MULTIPLAYER_INTERNET_GAME",
            tooltipFn = internetTooltipFn,
            activate  = function() InternetButtonClick() end }),
        MenuItems.Button({ controlName = "LANButton",
            textKey  = "TXT_KEY_MULTIPLAYER_LAN_GAME",
            activate = function() LANButtonClick() end }),
        MenuItems.Button({ controlName = "HotSeatButton",
            textKey  = "TXT_KEY_MULTIPLAYER_HOTSEAT_GAME",
            activate = function() HotSeatButtonClick() end }),
        MenuItems.Button({ controlName = "ReconnectButton",
            textKey  = "TXT_KEY_MULTIPLAYER_RECONNECT",
            activate = function()
                ReconnectButtonClick()
                SpeechPipeline.speakQueued(Text.key("TXT_KEY_CIVVACCESS_MP_RECONNECTING"))
            end }),
        MenuItems.Button({ controlName = "BackButton",
            textKey  = "TXT_KEY_MODDING_MENU_BACK",
            activate = function() BackButtonClick() end }),
    },
})
