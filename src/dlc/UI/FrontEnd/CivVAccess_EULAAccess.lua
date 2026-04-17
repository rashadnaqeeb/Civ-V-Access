-- EULA accessibility wiring. The game file's ShowHide body is commented out
-- and its InputHandler is anonymous, so we cannot capture a prior symbol;
-- we re-register a minimal Esc handler here that routes to the game's
-- NavigateBack global.

include("CivVAccess_FrontendCommon")
include("CivVAccess_SimpleListHandler")

local priorInput = function(uiMsg, wParam, lParam)
    if (uiMsg == 256 or uiMsg == 260) and wParam == Keys.VK_ESCAPE then
        NavigateBack()
    end
    return true
end

SimpleListHandler.install(ContextPtr, {
    name        = "EULA",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_EULA"),
    preamble    = Text.key("TXT_KEY_MODDING_EULA_BODY"),
    priorInput  = priorInput,
    items = {
        { controlName = "DeclineButton", textKey = "TXT_KEY_MODDING_EULA_DECLINE",
          activate    = function() NavigateBack() end },
        { controlName = "AcceptButton",  textKey = "TXT_KEY_MODDING_EULA_ACCEPT",
          activate    = function() OnAccept() end },
    },
})
