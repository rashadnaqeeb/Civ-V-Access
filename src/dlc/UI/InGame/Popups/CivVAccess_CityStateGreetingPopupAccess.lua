-- CityStateGreetingPopup (BNW) accessibility. Fires the first time the
-- active player meets a city-state; carries the name (TitleLabel), the
-- flavor meeting text + any gold / faith gift (DescriptionLabel), and two
-- action buttons: Close and Find On Map.
--
-- Preamble concatenates TitleLabel and DescriptionLabel so the user hears
-- both the city-state identity and the full gift / "speak again" line on
-- activation.

include("CivVAccess_PopupBoot")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

-- City-state name then the flavor / gift line. Shared by the F1 preamble
-- (joined) and the Alt+Up/Down review so the two cannot drift; joinNonEmpty
-- drops either when empty, matching the prior branch logic.
local function fragments()
    return { Controls.TitleLabel:GetText() or "", Controls.DescriptionLabel:GetText() or "" }
end

local function preamble()
    return Text.joinNonEmpty(fragments())
end

local handler = BaseMenu.install(ContextPtr, {
    name = "CityStateGreetingPopup",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CITY_STATE_GREETING"),
    preamble = preamble,
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
        BaseMenuItems.Button({
            controlName = "FindOnMapButton",
            textKey = "TXT_KEY_POP_CSTATE_FIND_ON_MAP",
            activate = function()
                OnFindOnMapButtonClicked()
            end,
        }),
    },
})

RewardReview.install(handler, fragments)
