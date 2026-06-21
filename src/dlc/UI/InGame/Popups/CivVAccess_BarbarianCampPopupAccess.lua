-- BarbarianCampPopup accessibility. DescriptionLabel (populated by OnPopup)
-- holds the reward text. Single Close button dismisses via
-- OnCloseButtonClicked; engine's Esc/Enter fallbacks already invoke it.

include("CivVAccess_PopupBoot")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

-- Shared by the F1 preamble and the Alt+Up/Down review, which splits the
-- reward text on any newlines.
local function descriptionFragments()
    return { Controls.DescriptionLabel:GetText() or "" }
end

local handler = BaseMenu.install(ContextPtr, {
    name = "BarbarianCampPopup",
    displayName = Text.key("TXT_KEY_POP_BARBARIAN_CLEARED"),
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
