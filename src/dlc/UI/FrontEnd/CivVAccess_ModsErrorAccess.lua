-- ModsError accessibility wiring. Dynamic preamble reads the live
-- ErrorText label so the spoken body matches whatever the engine just
-- populated (error text is set by the caller before the popup shows).

include("CivVAccess_FrontendCommon")

local priorShowHide = ShowHideHandler
local priorInput = InputHandler

BaseMenu.install(ContextPtr, {
    name = "ModsError",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_MODS_ERROR"),
    preamble = function()
        return Text.controlText(Controls.ErrorText, "ModsErrorAccess")
    end,
    priorShowHide = priorShowHide,
    priorInput = priorInput,
    items = {
        BaseMenuItems.Button({
            controlName = "OKButton",
            textKey = "TXT_KEY_OK_BUTTON",
            activate = function()
                OnOK()
            end,
        }),
    },
})
