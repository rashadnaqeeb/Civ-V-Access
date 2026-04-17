-- WaitingForPlayers accessibility wiring. Status splash shown during
-- multiplayer load while one or more peers haven't finished loading. No
-- buttons; announce-only via empty items list.

include("CivVAccess_FrontendCommon")
include("CivVAccess_SimpleListHandler")

local priorShowHide = ShowHide

SimpleListHandler.install(ContextPtr, {
    name          = "WaitingForPlayers",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_WAITING_PLAYERS"),
    preamble      = Text.key("TXT_KEY_SOMEONE_STILL_LOADING"),
    priorShowHide = priorShowHide,
    items = {},
})
