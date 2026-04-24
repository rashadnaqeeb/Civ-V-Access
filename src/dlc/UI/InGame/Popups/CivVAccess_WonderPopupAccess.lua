-- WonderPopup accessibility. Title holds the wonder name, Quote the
-- flavor quote, Stats the help/bonus text (all populated by OnPopup from
-- the selected Building row). Single Close button dismisses via OnClose.

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
    local title = labelOf("Title")
    if title ~= "" then parts[#parts + 1] = title end
    local quote = labelOf("Quote")
    if quote ~= "" then parts[#parts + 1] = quote end
    local stats = labelOf("Stats")
    if stats ~= "" then parts[#parts + 1] = stats end
    return table.concat(parts, ", ")
end

BaseMenu.install(ContextPtr, {
    name          = "WonderPopup",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_WONDER_POPUP"),
    preamble      = preamble,
    priorInput    = priorInput,
    priorShowHide = priorShowHide,
    items         = {
        BaseMenuItems.Button({
            controlName = "CloseButton",
            textKey     = "TXT_KEY_CLOSE",
            activate    = function() OnClose() end,
        }),
    },
})
