-- TechAwardPopup accessibility. TechName / TechQuote / TechHelp are the
-- three content labels populated by OnPopup from the awarded Technology.
-- Dismiss button is ContinueButton in BNW (CloseButton is hidden); we
-- wire both and visibility drops the hidden one from navigation.
--
-- Speech model: silentFirstOpen so the engine's narrated tech quote (a
-- voice clip the game plays as the popup appears) is not stepped on by
-- Tolk. The TechName is rolled into displayName via onShow so the first-
-- open announce still tells the user what finished researching. Quote
-- and help stay in the preamble and are reachable on demand via F1.

include("CivVAccess_PopupBoot")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local function labelOf(name)
    local c = Controls[name]
    if c == nil or c:IsHidden() then return "" end
    local ok, text = pcall(function() return c:GetText() end)
    if not ok or text == nil then return "" end
    return tostring(text)
end

-- TechName is in displayName, so omit it here to avoid F1 reading it twice.
local function preamble()
    return Text.joinNonEmpty({ labelOf("TechQuote"), labelOf("TechHelp") })
end

local handler = BaseMenu.install(ContextPtr, {
    name            = "TechAwardPopup",
    displayName     = Text.key("TXT_KEY_TECH_AWARD_TITLE"),
    preamble        = preamble,
    silentFirstOpen = true,
    priorInput      = priorInput,
    priorShowHide   = priorShowHide,
    items           = {
        BaseMenuItems.Button({
            controlName = "ContinueButton",
            textKey     = "TXT_KEY_TECH_AWARD_BUTTON",
            activate    = function() OnContinueButtonClicked() end,
        }),
        BaseMenuItems.Button({
            controlName = "CloseButton",
            textKey     = "TXT_KEY_CLOSE",
            activate    = function() OnClose() end,
        }),
    },
    onShow          = function(h)
        local title = Text.key("TXT_KEY_TECH_AWARD_TITLE")
        local name = labelOf("TechName")
        if name ~= "" then
            h.displayName = title .. ", " .. name
        else
            h.displayName = title
        end
    end,
})
