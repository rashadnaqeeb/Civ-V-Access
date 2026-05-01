-- NaturalWonderPopup accessibility. WonderLabel holds the feature name
-- (set from feature.Description in OnPopup); DescriptionLabel holds the
-- yield/happiness/promotion/gold summary. Single Close button dismisses
-- via OnCloseButtonClicked.

include("CivVAccess_PopupBoot")

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
