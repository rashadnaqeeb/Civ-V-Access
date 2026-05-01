-- TextPopup accessibility. Informational popup with a single Close/OK
-- button; DescriptionLabel holds the body text set via OnPopup. Close and
-- the engine's Esc/Enter fallbacks dismiss via OnCloseButtonClicked.

include("CivVAccess_PopupBoot")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

BaseMenu.install(ContextPtr, {
    name          = "TextPopup",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_TEXT_POPUP"),
    preamble      = function() return Controls.DescriptionLabel:GetText() end,
    priorInput    = priorInput,
    priorShowHide = priorShowHide,
    items         = {
        BaseMenuItems.Button({
            controlName = "CloseButton",
            textKey     = "TXT_KEY_OK_BUTTON",
            activate    = function() OnCloseButtonClicked() end,
        }),
    },
})
