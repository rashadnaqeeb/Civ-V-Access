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
--
-- valueFn per Textfield reads PreGame as the canonical source of truth
-- instead of relying on EditBox:GetText. The four "civ" EditBoxes are
-- affected by a Civ V engine quirk: GetText reads from the focused
-- EditBox's internal typing buffer, which TakeFocus and arrow-key
-- navigation reset to empty -- so a field shown visually as "Elizabeth"
-- can read as "" via GetText. Base ShowHide TakeFocuses EditCivLeader,
-- which means that field reads blank from the first cursor-land; the
-- other three break after the first nav that brushes them while they
-- carry engine focus. valueFn keeps the announce / restore path on a
-- reliable read regardless of buffer state.
--
-- On commit (priorCallback bIsEnter=true) we also write to PreGame so
-- the next valueFn read reflects the user's edit. Base OnAccept does
-- the same writes when the modal closes via Accept; doing it on per-
-- field commit just makes the post-commit value readable before close.

include("CivVAccess_FrontendCommon")

local priorShowHide = ShowHideHandler
local priorInput = InputHandler

-- LoadDefaults populates these globals as a side effect; valueFn reads
-- them when PreGame has no override (a fresh modal open where the user
-- has not yet customized the field). PreGame.GetCivilization-driven names
-- are set as globals by LoadDefaults at line 309 / on every ShowHide.
local function leaderValue()
    local n = PreGame.GetLeaderName(g_EditSlot or 0)
    if n ~= nil and n ~= "" then
        return n
    end
    return PlayerLeader
end

local function civNameValue()
    local n = PreGame.GetCivilizationDescription(g_EditSlot or 0)
    if n ~= nil and n ~= "" then
        return n
    end
    return PlayerCiv
end

local function civShortValue()
    local n = PreGame.GetCivilizationShortDescription(g_EditSlot or 0)
    if n ~= nil and n ~= "" then
        return n
    end
    return PlayerShortCiv or PlayerCiv
end

local function civAdjectiveValue()
    local n = PreGame.GetCivilizationAdjective(g_EditSlot or 0)
    if n ~= nil and n ~= "" then
        return n
    end
    return PlayerCivAdjective or PlayerCiv
end

local function nickNameValue()
    return PreGame.GetNickName(g_EditSlot or 0) or ""
end

local function passwordValue()
    return PreGame.GetPassword(g_EditSlot or 0) or ""
end

-- Wrap Validate so commit (bIsEnter=true) also writes the edited text to
-- PreGame via the provided setter. Lets valueFn return the latest value
-- on subsequent announce reads even if the EditBox buffer was wiped.
-- Skips the write on empty text: edit mode SetText("")s the field on
-- push, and GetText on the focused EditBox can return "" even when the
-- user typed nothing -- writing "" here would silently clobber the
-- field's PreGame state on a no-change Enter-through. Validate already
-- disables AcceptButton on empty fields so OnAccept (which has its own
-- writes) won't fire from an empty state.
local function commitWrapper(setter)
    return function(text, control, bIsEnter)
        Validate()
        if bIsEnter and text ~= nil and text ~= "" then
            setter(g_EditSlot or 0, text)
        end
    end
end

BaseMenu.install(ContextPtr, {
    name = "SetCivNames",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_SET_CIV_NAMES"),
    priorShowHide = priorShowHide,
    priorInput = priorInput,
    items = {
        BaseMenuItems.Textfield({
            controlName = "EditCivLeader",
            textKey = "TXT_KEY_PEDIA_LEADER_NAME",
            valueFn = leaderValue,
            priorCallback = commitWrapper(PreGame.SetLeaderName),
        }),
        BaseMenuItems.Textfield({
            controlName = "EditCivName",
            textKey = "TXT_KEY_PEDIA_CIVILIZATION_NAME",
            valueFn = civNameValue,
            priorCallback = commitWrapper(PreGame.SetCivilizationDescription),
        }),
        BaseMenuItems.Textfield({
            controlName = "EditCivShortName",
            textKey = "TXT_KEY_PEDIA_CIVILIZATION_SHORT_NAME",
            valueFn = civShortValue,
            priorCallback = commitWrapper(PreGame.SetCivilizationShortDescription),
        }),
        BaseMenuItems.Textfield({
            controlName = "EditCivAdjective",
            textKey = "TXT_KEY_PEDIA_CIVILIZATION_ADJECTIVE",
            valueFn = civAdjectiveValue,
            priorCallback = commitWrapper(PreGame.SetCivilizationAdjective),
        }),
        BaseMenuItems.Textfield({
            controlName = "EditNickName",
            visibilityControlName = "NickNameEditbox",
            textKey = "TXT_KEY_MP_NICK_NAME",
            valueFn = nickNameValue,
            priorCallback = commitWrapper(PreGame.SetNickName),
        }),
        BaseMenuItems.Checkbox({
            controlName = "UsePasswordCheck",
            visibilityControlName = "PasswordStack",
            textKey = "TXT_KEY_MP_USE_PASSWORD",
            tooltipKey = "TXT_KEY_MP_USE_PASSWORD_TT",
            activateCallback = function()
                Validate()
            end,
        }),
        BaseMenuItems.Textfield({
            controlName = "EditPassword",
            visibilityControlName = "PasswordStack",
            textKey = "TXT_KEY_MP_PASSWORD",
            valueFn = passwordValue,
            priorCallback = commitWrapper(PreGame.SetPassword),
        }),
        BaseMenuItems.Textfield({
            controlName = "EditRetypePassword",
            visibilityControlName = "PasswordStack",
            textKey = "TXT_KEY_MP_RETYPE_PASSWORD",
            valueFn = passwordValue,
            priorCallback = Validate,
        }),
        BaseMenuItems.Button({
            controlName = "CancelButton",
            textKey = "TXT_KEY_CANCEL_BUTTON",
            activate = function()
                OnCancel()
            end,
        }),
        BaseMenuItems.Button({
            controlName = "AcceptButton",
            textKey = "TXT_KEY_ACCEPT_BUTTON",
            activate = function()
                OnAccept()
            end,
        }),
    },
})
