-- RandomVCPopup accessibility (Vox Populi only). Net-new Vox Populi
-- Context announcing the randomly selected world victory condition,
-- opened via Events.SerialEventGameMessagePopup with
-- BUTTONPOPUP_MODDER_4. The vendor sets TitleLabel (splash header) and
-- DescriptionLabel (the chosen victory type) before queueing; Close is
-- the only control. The vendor swallows Enter so it cannot dismiss the
-- splash; under the menu handler Enter activates the focused Close
-- button instead, the standard flow on every wrapped popup.

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
                OnClose()
            end,
        }),
    }
end

EventPopupCommon.install({
    contextPtr = ContextPtr,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    handlerName = "RandomVCPopup",
    popupType = ButtonPopupTypes.BUTTONPOPUP_MODDER_4,
    buildItems = buildItems,
})
