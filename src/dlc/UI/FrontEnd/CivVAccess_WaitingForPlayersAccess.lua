-- WaitingForPlayers accessibility wiring. Status splash the engine shows
-- during load while one or more players haven't finished. In MP / hotseat
-- the message applies; in SP the engine still flashes this screen briefly
-- even though there is no peer to wait on, so skip the announce via
-- shouldActivate (LoadScreen handles the SP load cue).

include("CivVAccess_FrontendCommon")

local priorShowHide = ShowHide

Menu.install(ContextPtr, {
    name           = "WaitingForPlayers",
    displayName    = Text.key("TXT_KEY_CIVVACCESS_SCREEN_WAITING_PLAYERS"),
    preamble       = Text.key("TXT_KEY_SOMEONE_STILL_LOADING"),
    priorShowHide  = priorShowHide,
    shouldActivate = function()
        return PreGame.IsMultiplayerGame() or PreGame.IsHotSeatGame()
    end,
    items = {},
})
