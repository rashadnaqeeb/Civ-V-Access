-- SetUnitName (rename-unit dialog) accessibility. Textfield plus Accept /
-- Cancel, identical shape to SetCityName.

include("CivVAccess_PopupBoot")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

BaseMenu.install(ContextPtr, {
    name          = "SetUnitName",
    displayName   = Text.key("TXT_KEY_NAME_UNIT_TITLE"),
    priorInput    = priorInput,
    priorShowHide = priorShowHide,
    items         = {
        BaseMenuItems.Textfield({
            controlName   = "EditUnitName",
            textKey       = "TXT_KEY_UNIT_NAME",
            priorCallback = Validate,
        }),
        BaseMenuItems.Button({
            controlName = "AcceptButton",
            textKey     = "TXT_KEY_ACCEPT_BUTTON",
            activate    = function() OnAccept() end,
        }),
        BaseMenuItems.Button({
            controlName = "CancelButton",
            textKey     = "TXT_KEY_CANCEL_BUTTON",
            activate    = function() OnCancel() end,
        }),
    },
})
