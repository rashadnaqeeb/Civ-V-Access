-- ModsMenu accessibility wiring. SinglePlayer / MultiPlayer buttons get
-- SetDisabled based on mod-property gating, so we want the handler to walk
-- disabled items and announce them as "disabled" without firing activate.
-- ShowHide and InputHandler in the game file are anonymous; priorInput
-- reproduces the original Esc -> NavigateBack routing.

include("CivVAccess_FrontendCommon")
include("CivVAccess_SimpleListHandler")
include("CivVAccess_ModListPreamble")

local priorInput = function(uiMsg, wParam, lParam)
    if (uiMsg == 256 or uiMsg == 260) and wParam == Keys.VK_ESCAPE then
        NavigateBack()
    end
    return true
end

SimpleListHandler.install(ContextPtr, {
    name        = "ModsMenu",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_MODS_MENU"),
    preamble    = ModListPreamble.fn(),
    priorInput  = priorInput,
    items = {
        { controlName = "SinglePlayerButton", textKey = "TXT_KEY_MODDING_SINGLE_PLAYER",
          activate    = function() OnSinglePlayerClick() end },
        { controlName = "MultiPlayerButton",  textKey = "TXT_KEY_MODDING_MULTIPLAYER",
          activate    = function() OnMultiPlayerClick() end },
        { controlName = "BackButton",         textKey = "TXT_KEY_MODDING_MENU_BACK",
          activate    = function() NavigateBack() end },
    },
})
