-- NewEraPopup accessibility. DescriptionLabel is populated with
-- "TXT_KEY_POP_NEW_ERA_DESCRIPTION" formatted against the era. Single
-- Close button dismisses via OnClose.

include("CivVAccess_PopupBoot")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

BaseMenu.install(ContextPtr, {
    name          = "NewEraPopup",
    displayName   = Text.key("TXT_KEY_POP_NEW_ERA_TITLE"),
    preamble      = function() return Controls.DescriptionLabel:GetText() end,
    priorInput    = priorInput,
    priorShowHide = priorShowHide,
    items         = {
        BaseMenuItems.Button({
            controlName = "CloseButton",
            textKey     = "TXT_KEY_CLOSE",
            activate    = function() OnClose() end,
        }),
    },
})
