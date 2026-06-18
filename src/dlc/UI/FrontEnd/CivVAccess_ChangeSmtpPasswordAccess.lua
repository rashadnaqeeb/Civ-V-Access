-- ChangeSmtpPassword accessibility wiring. Modal pushed from the staging
-- room (UIManager:PushModal) when the host opens a pitboss game whose email
-- turn-notification SMTP host is set but whose password is still blank. The
-- host must enter the SMTP password twice; Accept stays disabled until the
-- two fields match.
--
-- Two password EditBoxes (TurnNotifySmtpPassEdit / TurnNotifySmtpPassRetypeEdit),
-- a live match-status label, and Accept / Cancel. Each field's commit runs the
-- base ValidateSmtpPassword, which updates the match label and toggles
-- AcceptButton's disabled state -- the framework announces "disabled" on
-- Accept until the two entries match, so the user hears that they don't yet.
--
-- valueFn mirrors SetCivNames: it backs the GetText read (which the Civ V
-- EditBox focus-buffer quirk can wipe to empty) with the OptionsManager cache
-- so a populated field doesn't read as blank. As with every wrapped EditBox,
-- the typed text is spoken -- here that means the SMTP password is voiced as
-- entered, the same tradeoff the SetCivNames password fields carry.

include("CivVAccess_FrontendCommon")

local priorShowHide = ShowHideHandler
local priorInput = InputHandler

-- Canonical fallback for a field whose live GetText came back empty. The
-- cache is base's source of truth for the committed SMTP password.
local function smtpPasswordValue()
    return OptionsManager.GetTurnNotifySmtpPassword_Cached() or ""
end

-- Live match / mismatch status. base ValidateSmtpPassword writes the result
-- text into StmpPasswordMatchLabel on every field change; read it back so the
-- user can poll whether the two entries currently agree.
local function matchStatusText()
    local c = Controls.StmpPasswordMatchLabel
    if c == nil then
        return ""
    end
    local ok, t = pcall(function()
        return c:GetText()
    end)
    if not ok or t == nil then
        return ""
    end
    return tostring(t)
end

BaseMenu.install(ContextPtr, {
    name = "ChangeSmtpPassword",
    displayName = Text.key("TXT_KEY_NAME_REENTER_MAIL_PASSWORD"),
    priorShowHide = priorShowHide,
    priorInput = priorInput,
    items = {
        BaseMenuItems.Textfield({
            controlName = "TurnNotifySmtpPassEdit",
            textKey = "TXT_KEY_OPSCREEN_TURN_NOTIFY_SMTP_PASSWORD",
            valueFn = smtpPasswordValue,
            priorCallback = function()
                if type(ValidateSmtpPassword) == "function" then
                    ValidateSmtpPassword()
                end
            end,
        }),
        BaseMenuItems.Textfield({
            controlName = "TurnNotifySmtpPassRetypeEdit",
            textKey = "TXT_KEY_OPSCREEN_TURN_NOTIFY_SMTP_RETYPE_PASSWORD",
            valueFn = smtpPasswordValue,
            priorCallback = function()
                if type(ValidateSmtpPassword) == "function" then
                    ValidateSmtpPassword()
                end
            end,
        }),
        BaseMenuItems.Text({
            labelFn = matchStatusText,
        }),
        BaseMenuItems.Button({
            controlName = "AcceptButton",
            textKey = "TXT_KEY_ACCEPT_BUTTON",
            activate = function()
                if type(OnAccept) == "function" then
                    OnAccept()
                end
            end,
        }),
        BaseMenuItems.Button({
            controlName = "CancelButton",
            textKey = "TXT_KEY_CANCEL_BUTTON",
            activate = function()
                if type(OnCancel) == "function" then
                    OnCancel()
                end
            end,
        }),
    },
})
