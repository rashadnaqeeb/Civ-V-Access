-- NaturalWonderPopup accessibility. WonderLabel holds the feature name
-- (set from feature.Description in OnPopup); DescriptionLabel holds the
-- yield/happiness/promotion/gold summary. Single Close button dismisses
-- via OnCloseButtonClicked.

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

local function preamble()
    local wonder = Controls.WonderLabel:GetText() or ""
    local description = Controls.DescriptionLabel:GetText() or ""
    if wonder ~= "" and description ~= "" then
        return wonder .. ", " .. description
    end
    if wonder ~= "" then return wonder end
    return description
end

BaseMenu.install(ContextPtr, {
    name          = "NaturalWonderPopup",
    displayName   = Text.key("TXT_KEY_POP_NATURAL_WONDER_FOUND"),
    preamble      = preamble,
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
