-- TechAwardPopup accessibility. TechName / TechQuote / TechHelp are the
-- three content labels populated by OnPopup from the awarded Technology.
-- Dismiss button is ContinueButton; vanilla also ships a hidden
-- CloseButton that Community Patch's rewrite deletes, so that item is
-- gated on the control existing.
--
-- Speech model: silentFirstOpen so the engine's narrated tech quote (a
-- voice clip the game plays as the popup appears) is not stepped on by
-- Tolk. The TechName is rolled into displayName via onShow so the first-
-- open announce still tells the user what finished researching. Quote,
-- help, and the unlock details stay in the preamble, reachable on demand
-- via F1. The unlock details are the tooltips of the small unlock icons
-- (B1-B5) the vendor file fills with one entry per thing the tech grants
-- (unit, building, ability) -- the hover detail sighted players get.

include("CivVAccess_PopupBoot")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

-- NUM_SMALL_BUTTONS in both vendor copies; the XML ships exactly B1-B5.
local NUM_SMALL_BUTTONS = 5

local function labelOf(name)
    local c = Controls[name]
    if c == nil or c:IsHidden() then
        return ""
    end
    local ok, text = pcall(function()
        return c:GetText()
    end)
    if not ok or text == nil then
        return ""
    end
    return tostring(text)
end

-- Community Patch's vendor file fills the unlock icons with callback-only
-- tooltips, which GetToolTipString cannot read back. Re-run the fill
-- asking for string tooltips (bStringTooltips, arg 7 in CP's signature)
-- so the preamble can read them. Vanilla always sets string tooltips, so
-- the empty probe never trips there and the refill never runs. Runs after
-- the vendor's own listener (include order), so the icons are populated.
Events.SerialEventGameMessagePopup.Add(Log.safeListener("TechAwardPopup tooltip refill", function(popupInfo)
    if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_TECH_AWARD or popupInfo.Data3 == -1 then
        return
    end
    local first = Controls.B1
    if first == nil or first:IsHidden() then
        return
    end
    local tip = first:GetToolTipString()
    if tip ~= nil and tip ~= "" then
        return
    end
    local kTechInfo = GameInfo.Technologies[popupInfo.Data3]
    AddSmallButtonsToTechButton(Controls, kTechInfo, NUM_SMALL_BUTTONS, 64, nil, nil, true)
end))

-- TechName is in displayName, so omit it here to avoid F1 reading it twice.
local function preamble()
    local parts = { labelOf("TechQuote"), labelOf("TechHelp") }
    for i = 1, NUM_SMALL_BUTTONS do
        local b = Controls["B" .. i]
        if b ~= nil and not b:IsHidden() then
            local tip = b:GetToolTipString()
            if tip ~= nil and tip ~= "" then
                parts[#parts + 1] = tip
            end
        end
    end
    return Text.joinNonEmpty(parts)
end

-- Ctrl+I from either button opens the awarded tech's pedia article. The
-- TechName control is populated by OnPopup with the localized tech name,
-- which the pedia search resolves through searchableList. pediaNameFn so
-- the lookup happens at keypress time -- the buttons are static specs but
-- the awarded tech varies per popup open.
local function awardedTechPedia()
    local name = labelOf("TechName")
    if name == "" then
        return nil
    end
    return name
end

local items = {
    BaseMenuItems.Button({
        controlName = "ContinueButton",
        textKey = "TXT_KEY_TECH_AWARD_BUTTON",
        activate = function()
            -- Vanilla names the dismiss handler OnContinueButtonClicked;
            -- Community Patch's rewrite names it Close (promoted to a
            -- global by our vp vendor recipe).
            if OnContinueButtonClicked ~= nil then
                OnContinueButtonClicked()
            else
                Close()
            end
        end,
        pediaNameFn = awardedTechPedia,
    }),
}

-- Vanilla's CloseButton (always hidden, so never navigable); Community
-- Patch deletes the control, where the item would only log a warning.
if Controls.CloseButton ~= nil then
    items[#items + 1] = BaseMenuItems.Button({
        controlName = "CloseButton",
        textKey = "TXT_KEY_CLOSE",
        activate = function()
            OnClose()
        end,
        pediaNameFn = awardedTechPedia,
    })
end

local handler = BaseMenu.install(ContextPtr, {
    name = "TechAwardPopup",
    displayName = Text.key("TXT_KEY_TECH_AWARD_TITLE"),
    preamble = preamble,
    silentFirstOpen = true,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    items = items,
    onShow = function(h)
        local title = Text.key("TXT_KEY_TECH_AWARD_TITLE")
        local name = labelOf("TechName")
        if name ~= "" then
            h.displayName = title .. ", " .. name
        else
            h.displayName = title
        end
    end,
})
