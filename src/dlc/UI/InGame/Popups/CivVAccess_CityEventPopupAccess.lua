-- CityEventPopup accessibility (Vox Populi only). Net-new Community
-- Patch Context announcing a city event-choice outcome or a completed
-- spy mission, opened via Events.SerialEventGameMessagePopup with
-- BUTTONPOPUP_MODDER_7. The vendor sets TitleLabel and DescriptionLabel
-- before queueing, so the live title and preamble cover the content.
--
-- Find On Map mirrors the vendor (camera pan plus a hex pulse, popup
-- stays open) and then drops the hex cursor on the city. The vendor
-- keeps its city in a local, so the wrapper re-derives it from
-- popupInfo the same way: spy popups (Option1) carry spy owner in
-- Data2 / spy ID in Data3 and fall back to the owner's capital when
-- the spy fled; plain city events carry city ID in Data2 / owner in
-- Data3 -- the two branches read those fields in opposite orders.

include("CivVAccess_PopupBoot")
include("CivVAccess_EventPopupCommon")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local function eventCity(popupInfo)
    if popupInfo.Option1 then
        local spyOwner = Players[popupInfo.Data2]
        local city = spyOwner:GetCityWithSpy(popupInfo.Data3)
        if city == nil then
            city = spyOwner:GetCapitalCity()
        end
        return city
    end
    local owner = Players[popupInfo.Data3]
    return owner:GetCityByID(popupInfo.Data2)
end

local function buildItems(popupInfo)
    return {
        BaseMenuItems.Button({
            controlName = "FindOnMapButton",
            textKey = "TXT_KEY_POP_CSTATE_FIND_ON_MAP",
            activate = function()
                -- Vendor pan + pulse (it resolves the same city from its
                -- own local).
                OnFindOnMapButtonClicked()
                local city = eventCity(popupInfo)
                if city == nil then
                    Log.error("CityEventPopup find-on-map: no city for popup data")
                    return
                end
                local plot = city:Plot()
                local Cursor = civvaccess_shared.modules and civvaccess_shared.modules.Cursor
                if Cursor == nil then
                    Log.warn("CityEventPopup find-on-map: Cursor module not published")
                    return
                end
                local text = Cursor.jumpTo(plot:GetX(), plot:GetY())
                if text ~= nil and text ~= "" then
                    SpeechPipeline.speakQueued(text)
                end
            end,
        }),
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
    handlerName = "CityEventPopup",
    popupType = ButtonPopupTypes.BUTTONPOPUP_MODDER_7,
    buildItems = buildItems,
})
