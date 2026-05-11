-- PlayerChange (hotseat player bumper) accessibility.
--
-- Flat menu with the optional password field, Continue / ChangePassword /
-- Save / MainMenu buttons. Title (leader name) is spoken as the preamble.
-- The password Stack container hides whenever the active hotseat player
-- doesn't have a password set (OnPasswordChanged toggles Controls.Stack);
-- gating the Textfield on "Stack" drops it from navigation automatically.
--
-- MainMenu opens an in-Context ExitConfirm (a hidden yes/no overlay that
-- the base screen toggles by swapping MainContainer / ExitConfirm
-- visibility). Mirrors GameMenu's ExitConfirm treatment: push a flat-list
-- confirm sub (No / Yes Choice items, Esc cancels via OnNo); the tick
-- watches ExitConfirm:IsHidden() so any other dismissal path (active-
-- player change, debug reload) pops the sub cleanly.

include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_UserPrefs")
include("CivVAccess_AudioCueMode")
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
include("CivVAccess_VolumeControl")
include("CivVAccess_BeaconRange")
include("CivVAccess_Settings")

local priorShowHide = ShowHideHandler
local priorInput = InputHandler

local function exitConfirmPrompt()
    if Controls.Message ~= nil then
        local ok, t = pcall(function()
            return Controls.Message:GetText()
        end)
        if ok and t ~= nil and t ~= "" then
            return t
        end
    end
    return Text.key("TXT_KEY_MENU_RETURN_MM_WARN")
end

local function pushExitConfirmSub()
    local subName = "PlayerChangeExitConfirm"
    local sub = BaseMenu.create({
        name = subName,
        displayName = exitConfirmPrompt(),
        items = {
            BaseMenuItems.Choice({
                textKey = "TXT_KEY_NO_BUTTON",
                activate = function()
                    local ok, err = pcall(OnNo)
                    if not ok then
                        Log.error("PlayerChangeAccess: OnNo failed: " .. tostring(err))
                    end
                    HandlerStack.removeByName(subName, true)
                end,
            }),
            BaseMenuItems.Choice({
                textKey = "TXT_KEY_YES_BUTTON",
                activate = function()
                    local ok, err = pcall(OnYes)
                    if not ok then
                        Log.error("PlayerChangeAccess: OnYes failed: " .. tostring(err))
                    end
                    -- reactivate=false: OnYes fires Events.ExitToMainMenu
                    -- which tears down the session; re-announcing the
                    -- parent handler's focused item mid-teardown is
                    -- garbage speech.
                    HandlerStack.removeByName(subName, false)
                end,
            }),
        },
    })
    sub.bindings[#sub.bindings + 1] = {
        key = Keys.VK_ESCAPE,
        mods = 0,
        description = "Cancel",
        fn = function()
            local ok, err = pcall(OnNo)
            if not ok then
                Log.error("PlayerChangeAccess: OnNo failed: " .. tostring(err))
            end
            HandlerStack.removeByName(subName, true)
        end,
    }
    sub.tick = function(self)
        if Controls.ExitConfirm:IsHidden() then
            HandlerStack.removeByName(subName, true)
        end
    end
    HandlerStack.push(sub)
end

local function mainMenuActivate()
    local ok, err = pcall(OnMainMenu)
    if not ok then
        Log.error("PlayerChangeAccess: OnMainMenu failed: " .. tostring(err))
        return
    end
    pushExitConfirmSub()
end

local function wrappedShowHide(bIsHide, bIsInit)
    if priorShowHide then
        local ok, err = pcall(priorShowHide, bIsHide, bIsInit)
        if not ok then
            Log.error("PlayerChangeAccess: priorShowHide failed: " .. tostring(err))
        end
    end
    if bIsHide then
        HandlerStack.removeByName("PlayerChangeExitConfirm", false)
    end
end

BaseMenu.install(ContextPtr, {
    name = "PlayerChange",
    displayName = Text.key("TXT_KEY_MP_NEXT_PLAYER"),
    preamble = function()
        return Controls.Title:GetText()
    end,
    priorInput = priorInput,
    priorShowHide = wrappedShowHide,
    items = {
        BaseMenuItems.Textfield({
            controlName = "EnterPasswordEditBox",
            visibilityControlName = "Stack",
            textKey = "TXT_KEY_MP_ENTER_PASSWORD",
            priorCallback = Validate,
        }),
        BaseMenuItems.Button({
            controlName = "ContinueButton",
            textKey = "TXT_KEY_MP_PLAYER_CHANGE_CONTINUE",
            activate = function()
                OnContinue()
            end,
        }),
        BaseMenuItems.Button({
            controlName = "ChangePasswordButton",
            labelFn = function()
                return Controls.ChangePasswordLabel:GetText()
            end,
            activate = function()
                OnChangePassword()
            end,
        }),
        BaseMenuItems.Button({
            controlName = "SaveButton",
            textKey = "TXT_KEY_ACTION_SAVE",
            activate = function()
                OnSave()
            end,
        }),
        BaseMenuItems.Button({
            controlName = "MainMenuButton",
            textKey = "TXT_KEY_MP_MAIN_MENU",
            activate = mainMenuActivate,
        }),
    },
})
