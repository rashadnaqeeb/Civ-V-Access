-- SetCivNames accessibility wiring. Modal opened from GameSetupScreen via
-- UIManager:PushModal when the user activates the Edit button on the civ
-- tile. Contains four text fields (leader / civ name / short name /
-- adjective) plus an Accept and Cancel button; in hot-seat mode, a nick-
-- name field and a "use password" checkbox with two password fields also
-- appear, gated by PasswordStack visibility.
--
-- Each textfield's priorCallback is the base file's Validate function,
-- which enables / disables AcceptButton based on live field contents;
-- live isActivatable reads IsDisabled and announces "disabled" on Accept
-- until every required field has legal content.
--
-- UsePasswordCheck is wired via RegisterCallback(Mouse.eLClick, Validate)
-- in the base, so PullDownProbe cannot capture the handler -- we pass
-- Validate explicitly as activateCallback.

include("CivVAccess_FrontendCommon")

local priorShowHide = ShowHideHandler
local priorInput    = InputHandler

BaseMenu.install(ContextPtr, {
    name             = "SetCivNames",
    displayName      = Text.key("TXT_KEY_CIVVACCESS_SCREEN_SET_CIV_NAMES"),
    priorShowHide    = priorShowHide,
    priorInput       = priorInput,
    focusParkControl = "CancelButton",
    items = {
        BaseMenuItems.Textfield({ controlName = "EditCivLeader",
            textKey       = "TXT_KEY_PEDIA_LEADER_NAME",
            priorCallback = Validate }),
        BaseMenuItems.Textfield({ controlName = "EditCivName",
            textKey       = "TXT_KEY_PEDIA_CIVILIZATION_NAME",
            priorCallback = Validate }),
        BaseMenuItems.Textfield({ controlName = "EditCivShortName",
            textKey       = "TXT_KEY_PEDIA_CIVILIZATION_SHORT_NAME",
            priorCallback = Validate }),
        BaseMenuItems.Textfield({ controlName = "EditCivAdjective",
            textKey       = "TXT_KEY_PEDIA_CIVILIZATION_ADJECTIVE",
            priorCallback = Validate }),
        BaseMenuItems.Textfield({ controlName = "EditNickName",
            visibilityControlName = "NickNameEditbox",
            textKey       = "TXT_KEY_MP_NICK_NAME",
            priorCallback = Validate }),
        BaseMenuItems.Checkbox({ controlName = "UsePasswordCheck",
            visibilityControlName = "PasswordStack",
            textKey          = "TXT_KEY_MP_USE_PASSWORD",
            tooltipKey       = "TXT_KEY_MP_USE_PASSWORD_TT",
            activateCallback = function() Validate() end }),
        BaseMenuItems.Textfield({ controlName = "EditPassword",
            visibilityControlName = "PasswordStack",
            textKey       = "TXT_KEY_MP_PASSWORD",
            priorCallback = Validate }),
        BaseMenuItems.Textfield({ controlName = "EditRetypePassword",
            visibilityControlName = "PasswordStack",
            textKey       = "TXT_KEY_MP_RETYPE_PASSWORD",
            priorCallback = Validate }),
        BaseMenuItems.Button({ controlName = "CancelButton",
            textKey  = "TXT_KEY_CANCEL_BUTTON",
            activate = function() OnCancel() end }),
        BaseMenuItems.Button({ controlName = "AcceptButton",
            textKey  = "TXT_KEY_ACCEPT_BUTTON",
            activate = function() OnAccept() end }),
    },
})
