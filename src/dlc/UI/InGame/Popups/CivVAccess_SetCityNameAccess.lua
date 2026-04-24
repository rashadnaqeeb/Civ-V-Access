-- SetCityName (rename-city dialog) accessibility. Textfield plus Accept /
-- Cancel. Shape matches AdvancedSetup's MaxTurnsEdit: the edit box's
-- CallOnChar=1 drives the base's Validate on every keystroke, which
-- toggles AcceptButton disabled state; Textfield edit mode routes keys
-- straight through so validation keeps firing.

include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_TextFilter")
include("CivVAccess_InGameStrings_en_US")
include("CivVAccess_Text")
include("CivVAccess_Icons")
include("CivVAccess_SpeechEngine")
include("CivVAccess_SpeechPipeline")
include("CivVAccess_HandlerStack")
include("CivVAccess_InputRouter")
include("CivVAccess_TickPump")
include("CivVAccess_Nav")
include("CivVAccess_BaseMenuItems")
include("CivVAccess_TypeAheadSearch")
include("CivVAccess_BaseMenuHelp")
include("CivVAccess_BaseMenuTabs")
include("CivVAccess_BaseMenuCore")
include("CivVAccess_BaseMenuInstall")
include("CivVAccess_BaseMenuEditMode")
include("CivVAccess_Help")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

BaseMenu.install(ContextPtr, {
    name          = "SetCityName",
    displayName   = Text.key("TXT_KEY_NAME_CITY_TITLE"),
    priorInput    = priorInput,
    priorShowHide = priorShowHide,
    items         = {
        BaseMenuItems.Textfield({
            controlName   = "EditCityName",
            textKey       = "TXT_KEY_PRODPANEL_CITY_NAME",
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
