-- ContentSwitch accessibility wiring. Status splash shown while the engine
-- swaps DLC / expansion rules — no buttons, just a progress message. Empty
-- items list keeps SimpleListHandler on the announce-only path.

include("CivVAccess_FrontendCommon")
include("CivVAccess_SimpleListHandler")

local priorShowHide = OnShowHide

SimpleListHandler.install(ContextPtr, {
    name          = "ContentSwitch",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CONTENT_SWITCH"),
    preamble      = Text.key("TXT_KEY_UPDATING_GAME_DATA"),
    priorShowHide = priorShowHide,
    items = {},
})
