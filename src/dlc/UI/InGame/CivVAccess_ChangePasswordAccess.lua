-- ChangePassword (hotseat add / change password modal) accessibility.
--
-- Pushed modally from PlayerChange when the user activates Change /
-- Add Password. Three EditBoxes (Old / New / Retype) plus OK / Cancel.
-- The OldPassword Textfield is gated on OldPasswordStack visibility,
-- which the base ShowHideHandler hides when the active player has no
-- existing password (Add mode); arrow nav skips it automatically.
--
-- OK is disabled by base Validate until: new + retype are non-empty,
-- character-legal, and identical, and (when shown) the old password
-- matches. Button items announce the disabled state so the user hears
-- why activation isn't doing anything if they hit OK early.

include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_TextFilter")
include("CivVAccess_InGameStrings_en_US")
include("CivVAccess_PluralRules")
include("CivVAccess_Text")
include("CivVAccess_Icons")
include("CivVAccess_SpeechEngine")
include("CivVAccess_SpeechPipeline")
include("CivVAccess_HandlerStack")
include("CivVAccess_InputRouter")
include("CivVAccess_TickPump")
include("CivVAccess_Nav")
include("CivVAccess_Verbosity")
include("CivVAccess_BaseMenuItems")
include("CivVAccess_TypeAheadSearch")
include("CivVAccess_BaseMenuHelp")
include("CivVAccess_BaseMenuTabs")
include("CivVAccess_BaseMenuCore")
include("CivVAccess_BaseMenuInstall")
include("CivVAccess_BaseMenuEditMode")
include("CivVAccess_Help")

local priorShowHide = ShowHideHandler
local priorInput = InputHandler

BaseMenu.install(ContextPtr, {
    name = "ChangePassword",
    displayName = Text.key("TXT_KEY_MP_CHANGE_PASSWORD"),
    priorShowHide = priorShowHide,
    priorInput = priorInput,
    onEscape = function()
        local ok, err = pcall(OnCancel)
        if not ok then
            Log.error("ChangePasswordAccess: OnCancel failed: " .. tostring(err))
        end
        return true
    end,
    items = {
        BaseMenuItems.Textfield({
            controlName = "OldPasswordEditBox",
            visibilityControlName = "OldPasswordStack",
            textKey = "TXT_KEY_MP_OLD_PASSWORD",
            priorCallback = Validate,
        }),
        BaseMenuItems.Textfield({
            controlName = "NewPasswordEditBox",
            textKey = "TXT_KEY_MP_NEW_PASSWORD",
            priorCallback = Validate,
        }),
        BaseMenuItems.Textfield({
            controlName = "RetypeNewPasswordEditBox",
            textKey = "TXT_KEY_MP_RETYPE_PASSWORD",
            priorCallback = Validate,
        }),
        BaseMenuItems.Button({
            controlName = "OKButton",
            textKey = "TXT_KEY_OK_BUTTON",
            activate = function()
                OnOK()
            end,
        }),
        BaseMenuItems.Button({
            controlName = "CancelButton",
            textKey = "TXT_KEY_CANCEL_BUTTON",
            activate = function()
                OnCancel()
            end,
        }),
    },
})
