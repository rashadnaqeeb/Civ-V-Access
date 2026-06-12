-- EventChoicePopupCity accessibility (Vox Populi only). Net-new
-- Community Patch Context for city-level event choices, opened via
-- Events.SerialEventGameMessagePopup with BUTTONPOPUP_MODDER_8
-- (Data1 = player ID, Data3 = city ID; Data2 = city event type). Same
-- commit-on-activate flow as the player picker (see
-- CivVAccess_EventChoicePopupAccess); the deltas are the city data
-- path and that the vendor's hide also pans the camera to the event's
-- city -- kept as-is, the camera move is free context for sighted
-- co-players and the popup is closing anyway.

include("CivVAccess_PopupBoot")
include("CivVAccess_EventPopupCommon")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local function buildItems(popupInfo)
    local playerID = popupInfo.Data1
    local cityID = popupInfo.Data3
    local player = Players[playerID]
    local city = player:GetCityByID(cityID)
    local iEventType = popupInfo.Data2
    local items = {}
    if iEventType == -1 or city == nil then
        return items
    end
    local pEventInfo = GameInfo.CityEvents[iEventType]
    if pEventInfo == nil then
        return items
    end
    local cityName = Text.key(city:GetNameKey())

    for row in GameInfo.CityEvent_ParentEvents("CityEventType = '" .. pEventInfo.Type .. "'") do
        local info = GameInfo.CityEventChoices[row.CityEventChoiceType]
        local choiceID = info.ID
        local choiceName = Text.key(info.Description)
        -- Composite localization payload; the vendor passes the city name
        -- as a positional argument for keys that reference it.
        local effects = Text.format(city:GetScaledEventChoiceValue(choiceID), cityName)
        local overrideStrings = {}
        LuaEvents.EventChoice_OverrideTextStrings(playerID, cityID, info, overrideStrings)
        for _, str in ipairs(overrideStrings) do
            choiceName = str.Description or choiceName
            effects = str.Help or effects
        end

        local label = choiceName
        if not city:IsCityEventChoiceValid(choiceID, iEventType) then
            label = label .. ", " .. Text.key("TXT_KEY_CIVVACCESS_BUTTON_DISABLED")
            local reason = city:GetDisabledTooltip(choiceID)
            if reason == nil or reason == "" then
                reason = Text.key("TXT_KEY_CANNOT_TAKE_TT")
            end
            effects = effects .. "[NEWLINE]" .. reason
        end

        items[#items + 1] = BaseMenuItems.Choice({
            labelText = label,
            tooltipText = effects,
            activate = function()
                local c = Players[popupInfo.Data1]:GetCityByID(popupInfo.Data3)
                if c == nil then
                    Log.error("EventChoicePopupCity activate: city " .. tostring(popupInfo.Data3) .. " gone")
                    return
                end
                -- Disabled-button convention: silent on invalid.
                if not c:IsCityEventChoiceValid(choiceID, iEventType) then
                    return
                end
                c:DoCityEventChoice(choiceID)
                local audio = GameInfo.CityEventChoices[choiceID].EventChoiceAudio
                if audio then
                    Events.AudioPlay2DSound(audio)
                end
                ContextPtr:SetHide(true)
            end,
        })
    end

    items[#items + 1] = BaseMenuItems.Button({
        controlName = "HideButton",
        textKey = "TXT_KEY_HIDE",
        tooltipKey = "TXT_KEY_HIDE_TT",
        activate = function()
            -- Vendor hide: SetHide plus a camera pan to the event's city.
            OnHideButtonClicked()
        end,
    })
    return items
end

EventPopupCommon.install({
    contextPtr = ContextPtr,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    handlerName = "EventChoicePopupCity",
    popupType = ButtonPopupTypes.BUTTONPOPUP_MODDER_8,
    buildItems = buildItems,
    gateOnDisplayPopup = true,
})
