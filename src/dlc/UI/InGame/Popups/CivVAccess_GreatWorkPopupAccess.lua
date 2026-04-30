-- GreatWorkPopup accessibility. Title holds either the great work's artist
-- (from Game.GetGreatWorkArtist) or TXT_KEY_GREAT_WORK_POPUP_WRITTEN_ARTIFACT
-- for archaeology-only works; LowerCaption holds the work's Description;
-- Quote holds the flavor quote and is hidden when the work has no quote.
-- Single Close button dismisses via OnClose.
--
-- Speech model: silentFirstOpen is conditional on the great work's class.
-- Writings (GREAT_WORK_LITERATURE) come with a Quote and the engine plays a
-- narrated voice clip of that quote when the popup is shown — Tolk stays
-- silent on first open so the two don't compete. Art and music popups have
-- no narrated quote, so first-open speaks the preamble normally. The work's
-- name (LowerCaption) is rolled into displayName via onShow so the silent-
-- first-open path still tells the user which work was completed; F1 reads
-- artist + quote on demand.
--
-- The class lookup uses popup info captured from
-- SerialEventGameMessagePopupShown, which fires from inside the engine's
-- ShowHideHandler before priorShowHide returns. By the time onShow runs and
-- silentFirstOpen evaluates inside HandlerStack.push, the captured type is
-- current. Capturing in SerialEventGameMessagePopup (queue time) would race
-- when multiple great works finish on the same turn.

include("CivVAccess_Polyfill")
include("CivVAccess_Log")
include("CivVAccess_TextFilter")
include("CivVAccess_InGameStrings_en_US")
include("CivVAccess_PluralRules")
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

local capturedGWType = nil

Events.SerialEventGameMessagePopupShown.Add(function(popupInfo)
    if popupInfo == nil or popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_GREAT_WORK_COMPLETED_ACTIVE_PLAYER then
        return
    end
    local iGWIndex = popupInfo.Data1
    if iGWIndex ~= -1 then
        capturedGWType = Game.GetGreatWorkType(iGWIndex)
    else
        capturedGWType = popupInfo.Data2
    end
end)

local function isLiterature()
    if capturedGWType == nil then
        return false
    end
    local row = GameInfo.GreatWorks[capturedGWType]
    return row ~= nil and row.GreatWorkClassType == "GREAT_WORK_LITERATURE"
end

-- LowerCaption (work name) is in displayName, so omit it here to avoid F1
-- reading it twice.
local function preamble()
    local parts = {}
    local title = labelOf("Title")
    if title ~= "" then
        parts[#parts + 1] = title
    end
    local quote = labelOf("Quote")
    if quote ~= "" then
        parts[#parts + 1] = quote
    end
    return table.concat(parts, ", ")
end

BaseMenu.install(ContextPtr, {
    name = "GreatWorkPopup",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_GREAT_WORK_POPUP"),
    preamble = preamble,
    silentFirstOpen = isLiterature,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    items = {
        BaseMenuItems.Button({
            controlName = "CloseButton",
            textKey = "TXT_KEY_CLOSE",
            activate = function()
                OnClose()
            end,
        }),
    },
    onShow = function(h)
        local title = Text.key("TXT_KEY_CIVVACCESS_SCREEN_GREAT_WORK_POPUP")
        local name = labelOf("LowerCaption")
        if name ~= "" then
            h.displayName = title .. ", " .. name
        else
            h.displayName = title
        end
    end,
})
