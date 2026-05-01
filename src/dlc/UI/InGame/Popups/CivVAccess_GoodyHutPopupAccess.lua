-- GoodyHutPopup accessibility (informational variant). DescriptionLabel is
-- populated by OnPopup from the selected GoodyHuts row's Description,
-- formatted with Data2 (gold/culture/faith amount) when applicable. The
-- choice-picker popup is a separate Context (ChooseGoodyHutReward) and
-- not handled here. Single Close button dismisses via OnCloseButtonClicked.

include("CivVAccess_PopupBoot")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

BaseMenu.install(ContextPtr, {
    name          = "GoodyHutPopup",
    displayName   = Text.key("TXT_KEY_POP_RUINS_EXPLORED"),
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
