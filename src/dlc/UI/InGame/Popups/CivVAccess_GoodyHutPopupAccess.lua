-- GoodyHutPopup accessibility (informational variant). DescriptionLabel is
-- populated by OnPopup from the selected GoodyHuts row's Description. The
-- choice-picker popup is a separate Context (ChooseGoodyHutReward) and not
-- handled here. Single Close button dismisses via OnCloseButtonClicked.
--
-- VP rewrote several goody descriptions (gold, culture, faith) to flavor-only
-- text and routed the reward amount through a floating plot message instead
-- (CvPlayer::receiveGoody), so those popups no longer render the number. The
-- amount still rides the popup payload (Data2 = the scaled reward, 0 for
-- non-yield goodies), so when the description omits it we re-append it using
-- the engine's own per-yield "received" string -- the same text the plot
-- message shows. On vanilla, and on any goody whose description still carries
-- the placeholder, the amount renders itself and we add nothing.

include("CivVAccess_PopupBoot")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

-- The engine's per-yield reward strings, keyed by goody type, mirroring the
-- yields CvPlayer::receiveGoody appends to its plot message. Extend if VP
-- strips the placeholder from another yield goody's description (the preamble
-- logs a breadcrumb when that happens).
local RECEIVED_TEXT = {
    GOODY_GOLD = "TXT_KEY_MISC_RECEIVED_GOLD",
    GOODY_CULTURE = "TXT_KEY_MISC_RECEIVED_CULTURE",
    GOODY_FAITH = "TXT_KEY_MISC_RECEIVED_FAITH",
    GOODY_PROPHET_FAITH = "TXT_KEY_MISC_RECEIVED_FAITH",
    GOODY_PANTHEON_FAITH = "TXT_KEY_MISC_RECEIVED_FAITH",
}

local goodyType, goodyDescKey, goodyValue

-- Snapshot the payload: the goody's type and description key (to decide
-- whether the amount needs supplying) and Data2 (the amount itself). The
-- vendor keeps its own m_PopupInfo local but it is not reachable from here.
--
-- This listener is appended after the vendor's OnPopup on the same event, and
-- OnPopup's QueuePopup shows the Context synchronously, so the open-time
-- preamble runs before we get here. The install below defers the open push one
-- tick (deferActivate) so this snapshot lands first; without it the popup opens
-- speaking the description with no amount, while F1 -- which re-reads after the
-- dispatch completes -- speaks it correctly.
Events.SerialEventGameMessagePopup.Add(function(popupInfo)
    if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_GOODY_HUT_REWARD then
        return
    end
    local row = GameInfo.GoodyHuts[popupInfo.Data1]
    goodyType = row and row.Type or nil
    goodyDescKey = row and row.Description or nil
    goodyValue = popupInfo.Data2
end)

-- Whether the goody description template still substitutes its amount.
-- Rendering with two different values and comparing detects a missing
-- positional placeholder (identical output) without hardcoding which
-- descriptions VP rewrote, so a re-pin that restores a placeholder needs no
-- change here.
local function descriptionRendersAmount(descKey)
    return Text.format(descKey, 1) ~= Text.format(descKey, 2)
end

local function preamble()
    local text = Controls.DescriptionLabel:GetText() or ""
    -- Data2 is 0 for non-yield goodies (units, techs, maps), so a positive
    -- value means this goody granted a spoken amount.
    if goodyValue == nil or goodyValue <= 0 or goodyDescKey == nil then
        return text
    end
    if descriptionRendersAmount(goodyDescKey) then
        return text
    end
    local receivedKey = goodyType and RECEIVED_TEXT[goodyType]
    if receivedKey == nil then
        Log.warn(
            "GoodyHutPopup: goody '"
                .. tostring(goodyType)
                .. "' grants amount "
                .. tostring(goodyValue)
                .. " but its description omits it and no received-text mapping exists"
        )
        return text
    end
    return text .. " " .. Text.format(receivedKey, goodyValue)
end

BaseMenu.install(ContextPtr, {
    name = "GoodyHutPopup",
    displayName = Text.key("TXT_KEY_POP_RUINS_EXPLORED"),
    preamble = preamble,
    -- Open one tick late so the payload snapshot above has landed; see the
    -- listener comment for why an immediate push would miss the amount.
    deferActivate = true,
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
