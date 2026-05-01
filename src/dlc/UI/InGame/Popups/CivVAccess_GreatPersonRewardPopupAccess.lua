-- GreatPersonRewardPopup accessibility. BUTTONPOPUP_GREAT_PERSON_REWARD pops
-- when a Great Person is born. DescriptionLabel is populated by base OnPopup
-- with TXT_KEY_GREAT_PERSON_REWARD formatted against the unit type and host
-- city. Single Close button dismisses via OnCloseButtonClicked.

include("CivVAccess_PopupBoot")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

BaseMenu.install(ContextPtr, {
    name          = "GreatPersonRewardPopup",
    displayName   = Text.key("TXT_KEY_POP_GREAT_PERSON_BORN"),
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
