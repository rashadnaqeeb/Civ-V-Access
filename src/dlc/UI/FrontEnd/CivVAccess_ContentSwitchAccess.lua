-- ContentSwitch accessibility wiring. Status splash shown while the engine
-- swaps DLC / expansion rules — no buttons, just a progress message. Empty
-- items list keeps Menu on the announce-only path.

include("CivVAccess_FrontendCommon")

local priorShowHide = OnShowHide

Menu.install(ContextPtr, {
    name          = "ContentSwitch",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CONTENT_SWITCH"),
    preamble      = Text.key("TXT_KEY_UPDATING_GAME_DATA"),
    priorShowHide = priorShowHide,
    items = {},
})
