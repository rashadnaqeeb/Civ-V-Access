-- EventChoicePopup accessibility (Vox Populi only). Net-new Community
-- Patch Context for player-level event choices, opened via
-- Events.SerialEventGameMessagePopup with BUTTONPOPUP_MODDER_10
-- (Data1 = player ID, Data2 = event type). The Context only exists when
-- the Community Patch mod is active; on a vanilla install this file
-- ships in the DLC but nothing includes it.
--
-- The vendor screen is select-then-Confirm; the keyboard flow commits on
-- activate instead (no engine confirm overlay exists here, and the
-- ChooseProduction wrapper sets the same precedent). Esc falls through
-- to the vendor InputHandler, which hides without committing -- safe:
-- the pending choice sets ENDTURN_BLOCKING_EVENT_CHOICE in the DLL, so
-- the end-turn flow re-surfaces the popup.
--
-- Items rebuild from the same data path the vendor walks (parent-event
-- choice rows, GetScaledEventChoiceValue effects, the modmod
-- override-strings LuaEvents), so spoken text matches the screen.
-- Rebuild is gated on the vendor accepting the popup: its OnPopup calls
-- the global DisplayPopup only when the Context was hidden, so a wrap
-- of that global is the accept signal (our popup listener runs after
-- the vendor's in the same dispatch and cannot see its local gate).

include("CivVAccess_PopupBoot")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local function controlText(control)
    if control == nil then
        return nil
    end
    local ok, text = pcall(function()
        return control:GetText()
    end)
    if not ok or text == nil then
        return nil
    end
    return tostring(text)
end

local mainHandler = BaseMenu.install(ContextPtr, {
    name = "EventChoicePopup",
    -- Install-time placeholder; onShow writes the live event title (with
    -- any modmod override applied by the vendor) into displayName.
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_EVENT"),
    preamble = function()
        return controlText(Controls.DescriptionLabel)
    end,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    deferActivate = true,
    onShow = function(h)
        local title = controlText(Controls.TitleLabel)
        if title ~= nil and title ~= "" then
            h.displayName = title
        end
    end,
    items = {},
})

local function buildItems(popupInfo)
    local playerID = popupInfo.Data1
    local player = Players[playerID]
    local iEventType = popupInfo.Data2
    local items = {}
    if iEventType == -1 then
        return items
    end
    local pEventInfo = GameInfo.Events[iEventType]
    if pEventInfo == nil then
        return items
    end

    for row in GameInfo.Event_ParentEvents("EventType = '" .. pEventInfo.Type .. "'") do
        local info = GameInfo.EventChoices[row.EventChoiceType]
        local choiceID = info.ID
        local choiceName = Text.key(info.Description)
        -- Composite localization payload, not a bare key; Text.key still
        -- converts it and only warns when conversion fails.
        local effects = Text.key(player:GetScaledEventChoiceValue(choiceID))
        local overrideStrings = {}
        LuaEvents.EventChoice_OverrideTextStrings(playerID, nil, info, overrideStrings)
        for _, str in ipairs(overrideStrings) do
            choiceName = str.Description or choiceName
            effects = str.Help or effects
        end

        local label = choiceName
        if not player:IsEventChoiceValid(choiceID, iEventType) then
            label = label .. ", " .. Text.key("TXT_KEY_CIVVACCESS_BUTTON_DISABLED")
            local reason = player:GetDisabledTooltip(choiceID)
            if reason == nil or reason == "" then
                reason = Text.key("TXT_KEY_CANNOT_TAKE_TT")
            end
            effects = effects .. "[NEWLINE]" .. reason
        end

        items[#items + 1] = BaseMenuItems.Choice({
            labelText = label,
            tooltipText = effects,
            activate = function()
                local p = Players[popupInfo.Data1]
                -- Disabled-button convention: activating an invalid choice
                -- is silent (the label already said disabled).
                if not p:IsEventChoiceValid(choiceID, iEventType) then
                    return
                end
                p:DoEventChoice(choiceID, iEventType)
                local audio = GameInfo.EventChoices[choiceID].EventChoiceAudio
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
        -- "Hides the window, but does not dismiss the Event" -- the
        -- hide-not-dismiss semantics earn the tooltip.
        tooltipKey = "TXT_KEY_HIDE_TT",
        activate = function()
            OnHideButtonClicked()
        end,
    })
    return items
end

-- Accept signal: the vendor OnPopup calls this global only when it
-- actually displays the popup (Context was hidden). Without the gate, a
-- MODDER_10 popup arriving while the screen is already open would
-- rebuild our items for an event the vendor is not showing.
local vendorAccepted = false
local priorDisplayPopup = DisplayPopup
function DisplayPopup(playerID, classType, numberOfChoices)
    vendorAccepted = true
    return priorDisplayPopup(playerID, classType, numberOfChoices)
end

Events.SerialEventGameMessagePopup.Add(function(popupInfo)
    if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_MODDER_10 then
        return
    end
    if not vendorAccepted then
        return
    end
    vendorAccepted = false
    local ok, items = pcall(buildItems, popupInfo)
    if not ok then
        Log.error("EventChoicePopupAccess buildItems failed: " .. tostring(items))
        return
    end
    mainHandler.setItems(items)
end)
