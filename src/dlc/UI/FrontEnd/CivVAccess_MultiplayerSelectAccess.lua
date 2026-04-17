-- MultiplayerSelect accessibility wiring. Standard and Pitboss don't
-- navigate; they toggle visibility so Internet/LAN replace
-- Standard/HotSeat/Pitboss in place. Menu's post-activate revalidation
-- catches the flipped-hidden item and announces the next valid one so the
-- user hears that something changed.
--
-- ReconnectButton is shown only when Network.HasReconnectCache() is true;
-- InternetButton is disabled when not connected to Steam but not hidden
-- (users can still hit Enter on it and the game's own handler no-ops). The
-- screen sets a "not connected to Steam" tooltip in that state via
-- LocalizeAndSetToolTip; we re-check the same network flag at announce
-- time since there is no Lua API to read the stored tooltip back.

include("CivVAccess_FrontendCommon")

local priorShowHide = ShowHideHandler
local priorInput    = InputHandler

local function internetTooltipFn()
    if Network.IsConnectedToSteam() then return nil end
    return Text.key("TXT_KEY_STEAM_CONNECTED_NO")
end

Menu.install(ContextPtr, {
    name          = "MultiplayerSelect",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_MULTIPLAYER_SELECT"),
    priorShowHide = priorShowHide,
    priorInput    = priorInput,
    items = {
        MenuItems.Button({ controlName = "StandardButton",
            textKey  = "TXT_KEY_MULTIPLAYER_STANDARD_GAME",
            activate = function() StandardButtonClick() end }),
        MenuItems.Button({ controlName = "HotSeatButton",
            textKey  = "TXT_KEY_MULTIPLAYER_HOTSEAT_GAME",
            activate = function() HotSeatButtonClick() end }),
        MenuItems.Button({ controlName = "PitbossButton",
            textKey  = "TXT_KEY_MULTIPLAYER_PITBOSS_GAME",
            activate = function() PitbossButtonClick() end }),
        MenuItems.Button({ controlName = "InternetButton",
            textKey   = "TXT_KEY_MULTIPLAYER_INTERNET_GAME",
            tooltipFn = internetTooltipFn,
            activate  = function() InternetButtonClick() end }),
        MenuItems.Button({ controlName = "LANButton",
            textKey  = "TXT_KEY_MULTIPLAYER_LAN_GAME",
            activate = function() LANButtonClick() end }),
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
