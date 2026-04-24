-- CityStateGreetingPopup (BNW) accessibility. Fires the first time the
-- active player meets a city-state; carries the name (TitleLabel), the
-- flavor meeting text + any gold / faith gift (DescriptionLabel), and two
-- action buttons: Close and Find On Map.
--
-- Preamble concatenates TitleLabel and DescriptionLabel so the user hears
-- both the city-state identity and the full gift / "speak again" line on
-- activation.

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
    local title = Controls.TitleLabel:GetText() or ""
    local description = Controls.DescriptionLabel:GetText() or ""
    if title ~= "" and description ~= "" then
        return title .. ", " .. description
    end
    if title ~= "" then return title end
    return description
end

BaseMenu.install(ContextPtr, {
    name          = "CityStateGreetingPopup",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_CITY_STATE_GREETING"),
    preamble      = preamble,
    priorInput    = priorInput,
    priorShowHide = priorShowHide,
    items         = {
        BaseMenuItems.Button({
            controlName = "CloseButton",
            textKey     = "TXT_KEY_CLOSE",
            activate    = function() OnCloseButtonClicked() end,
        }),
        BaseMenuItems.Button({
            controlName = "FindOnMapButton",
            textKey     = "TXT_KEY_POP_CSTATE_FIND_ON_MAP",
            activate    = function() OnFindOnMapButtonClicked() end,
        }),
    },
})
