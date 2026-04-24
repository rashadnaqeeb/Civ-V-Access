-- TechAwardPopup accessibility. TechName / TechQuote / TechHelp are the
-- three content labels populated by OnPopup from the awarded Technology.
-- Dismiss button is ContinueButton in BNW (CloseButton is hidden); we
-- wire both and visibility drops the hidden one from navigation.

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

local function labelOf(name)
    local c = Controls[name]
    if c == nil or c:IsHidden() then return "" end
    local ok, text = pcall(function() return c:GetText() end)
    if not ok or text == nil then return "" end
    return tostring(text)
end

local function preamble()
    local parts = {}
    local name = labelOf("TechName")
    if name ~= "" then parts[#parts + 1] = name end
    local quote = labelOf("TechQuote")
    if quote ~= "" then parts[#parts + 1] = quote end
    local help = labelOf("TechHelp")
    if help ~= "" then parts[#parts + 1] = help end
    return table.concat(parts, ", ")
end

BaseMenu.install(ContextPtr, {
    name          = "TechAwardPopup",
    displayName   = Text.key("TXT_KEY_TECH_AWARD_TITLE"),
    preamble      = preamble,
    priorInput    = priorInput,
    priorShowHide = priorShowHide,
    items         = {
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
})
