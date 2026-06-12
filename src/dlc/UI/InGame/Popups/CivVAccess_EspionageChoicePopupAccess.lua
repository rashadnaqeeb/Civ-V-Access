-- EspionageChoicePopup accessibility (Vox Populi only). Net-new
-- Community Patch Context for spy mission / counterspy event choices,
-- opened via Events.SerialEventGameMessagePopup with
-- BUTTONPOPUP_MODDER_12 (Data1 = player ID, Data3 = plot index of the
-- city, Data4 = spy ID; Data2 = city event type). Same
-- commit-on-activate flow as the other event pickers; the deltas are
-- the espionage validity / effects / commit signatures (all take the
-- spy and player), the vendor replacing a disabled choice's effects
-- text with the disabled reason (mirrored: sighted players see only
-- the reason there), and a Go To City button.
--
-- Go To City mirrors the vendor (select the city's plot, close) and
-- then drops the hex cursor on the city: the vendor already panned the
-- camera there when the popup opened, so a camera-settle follow would
-- time out -- the destination is known, jump directly.

include("CivVAccess_PopupBoot")
include("CivVAccess_EventPopupCommon")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local function eventCity(popupInfo)
    local plot = Map.GetPlotByIndex(popupInfo.Data3)
    return plot and plot:GetPlotCity() or nil
end

local function buildItems(popupInfo)
    local playerID = popupInfo.Data1
    local spyID = popupInfo.Data4
    local city = eventCity(popupInfo)
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
        local effects = Text.format(city:GetScaledEventChoiceValue(choiceID, false, spyID, playerID), cityName)
        local overrideStrings = {}
        -- Second arg nil mirrors the vendor (it passes an undefined
        -- cityID local here).
        LuaEvents.EventChoice_OverrideTextStrings(playerID, nil, info, overrideStrings)
        for _, str in ipairs(overrideStrings) do
            choiceName = str.Description or choiceName
            effects = str.Help or effects
        end

        local label = choiceName
        if not city:IsCityEventChoiceValidEspionage(choiceID, iEventType, spyID, playerID) then
            label = label .. ", " .. Text.key("TXT_KEY_CIVVACCESS_BUTTON_DISABLED")
            local reason = city:GetDisabledTooltip(choiceID, spyID, playerID)
            if reason == nil or reason == "" then
                reason = Text.key("TXT_KEY_CANNOT_TAKE_TT")
            end
            effects = reason
        end

        items[#items + 1] = BaseMenuItems.Choice({
            labelText = label,
            tooltipText = effects,
            activate = function()
                local c = eventCity(popupInfo)
                if c == nil then
                    Log.error("EspionageChoicePopup activate: no city at plot " .. tostring(popupInfo.Data3))
                    return
                end
                -- Disabled-button convention: silent on invalid.
                if not c:IsCityEventChoiceValidEspionage(choiceID, iEventType, spyID, playerID) then
                    return
                end
                c:DoCityEventChoice(choiceID, spyID, playerID)
                ContextPtr:SetHide(true)
            end,
        })
    end

    items[#items + 1] = BaseMenuItems.Button({
        controlName = "GoToCity",
        textKey = "TXT_KEY_EO_VIEW_TOOLTIP",
        activate = function()
            local c = eventCity(popupInfo)
            if c == nil then
                Log.error("EspionageChoicePopup go-to-city: no city at plot " .. tostring(popupInfo.Data3))
                return
            end
            local plot = c:Plot()
            UI.DoSelectCityAtPlot(plot)
            ContextPtr:SetHide(true)
            local Cursor = civvaccess_shared.modules and civvaccess_shared.modules.Cursor
            if Cursor == nil then
                Log.warn("EspionageChoicePopup go-to-city: Cursor module not published")
                return
            end
            local text = Cursor.jumpTo(plot:GetX(), plot:GetY())
            if text ~= nil and text ~= "" then
                -- Queued so the announcement of whatever the close
                -- exposes isn't cut off.
                SpeechPipeline.speakQueued(text)
            end
        end,
    })

    items[#items + 1] = BaseMenuItems.Button({
        controlName = "HideButton",
        textKey = "TXT_KEY_HIDE",
        tooltipKey = "TXT_KEY_HIDE_TT",
        activate = function()
            OnHideButtonClicked()
        end,
    })
    return items
end

EventPopupCommon.install({
    contextPtr = ContextPtr,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    handlerName = "EspionageChoicePopup",
    popupType = ButtonPopupTypes.BUTTONPOPUP_MODDER_12,
    buildItems = buildItems,
    gateOnDisplayPopup = true,
})
