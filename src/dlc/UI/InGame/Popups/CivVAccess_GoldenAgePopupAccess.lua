-- GoldenAgePopup accessibility. DescriptionLabel (populated by OnPopup from
-- TXT_KEY_GOLDEN_AGE_FLAVOR) holds the flavor text. Single Close button
-- dismisses via OnCloseButtonClicked.

include("CivVAccess_PopupBoot")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

-- Shared by the F1 preamble and the Alt+Up/Down review, which splits the
-- flavor text on any newlines.
local function descriptionFragments()
    return { Controls.DescriptionLabel:GetText() or "" }
end

local handler = BaseMenu.install(ContextPtr, {
    name = "GoldenAgePopup",
    displayName = Text.key("TXT_KEY_POP_GOLDEN_AGE_BEGIN"),
    preamble = function()
        return Text.joinNonEmpty(descriptionFragments())
    end,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    items = {
        BaseMenuItems.Button({
            controlName = "CloseButton",
            textKey = "TXT_KEY_CLOSE",
            activate = function()
                OnCloseButtonClicked()
            end,
        }),
    },
})

RewardReview.install(handler, descriptionFragments)
