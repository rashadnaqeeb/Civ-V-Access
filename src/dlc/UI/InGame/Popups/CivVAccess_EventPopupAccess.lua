-- EventPopup accessibility (Vox Populi only). Net-new Community Patch
-- Context announcing a player event-choice outcome, opened via
-- Events.SerialEventGameMessagePopup with BUTTONPOPUP_MODDER_9. The
-- vendor sets TitleLabel (choice name) and DescriptionLabel (scaled
-- effects) before queueing the popup, so the live title and preamble
-- cover the content; the only control is Close. No accept gate: the
-- vendor listener has no already-open check, every matching popup
-- refreshes the labels.

include("CivVAccess_PopupBoot")
include("CivVAccess_EventPopupCommon")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local function buildItems(_popupInfo)
    return {
        BaseMenuItems.Button({
            controlName = "CloseButton",
            textKey = "TXT_KEY_CLOSE",
            activate = function()
                OnCloseButtonClicked()
            end,
        }),
    }
end

EventPopupCommon.install({
    contextPtr = ContextPtr,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    handlerName = "EventPopup",
    popupType = ButtonPopupTypes.BUTTONPOPUP_MODDER_9,
    buildItems = buildItems,
})
