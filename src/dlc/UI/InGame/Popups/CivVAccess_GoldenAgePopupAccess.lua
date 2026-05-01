-- GoldenAgePopup accessibility. DescriptionLabel (populated by OnPopup from
-- TXT_KEY_GOLDEN_AGE_FLAVOR) holds the flavor text. Single Close button
-- dismisses via OnCloseButtonClicked.

include("CivVAccess_PopupBoot")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

BaseMenu.install(ContextPtr, {
    name          = "GoldenAgePopup",
    displayName   = Text.key("TXT_KEY_POP_GOLDEN_AGE_BEGIN"),
    preamble      = function() return Controls.DescriptionLabel:GetText() end,
    priorInput    = priorInput,
    priorShowHide = priorShowHide,
    items         = {
        BaseMenuItems.Button({
            controlName = "CloseButton",
            textKey     = "TXT_KEY_CLOSE",
            activate    = function() OnCloseButtonClicked() end,
        }),
    },
})
