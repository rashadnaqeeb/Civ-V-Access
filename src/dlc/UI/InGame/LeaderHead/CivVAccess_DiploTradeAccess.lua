-- DiploTrade (BNW AI-trade) accessibility. Included by DiploTrade.lua's
-- verbatim override after TradeLogic's own includes and event wiring have
-- finished, so TradeLogic globals (g_Deal, g_iUs, g_iThem, g_iDiploUIState)
-- resolve inside the shared logic module's closures.
--
-- This wrapper only sets up the Context-specific descriptor (leader name
-- source, discussion-text preamble, silent-first-open for the voice clip)
-- and hands off to TradeLogicAccess.install. All item-building lives in
-- the shared module.

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
include("CivVAccess_BaseMenuNumberEntry")
include("CivVAccess_TradeLogicAccess")
include("CivVAccess_Help")

local priorInput = InputHandler
local priorShowHide = OnShowHide

-- Preamble composes the leader's current speech line the same way
-- DiscussionDialog / LeaderHeadRoot do: name + discussion, live at read
-- time so F1 / refresh() picks up the latest AILeaderMessage content.
local function composePreamble()
    local parts = {}
    local name = Controls.NameText:GetText()
    if name ~= nil and name ~= "" then
        parts[#parts + 1] = tostring(name)
    end
    local speech = Controls.DiscussionText:GetText()
    if speech ~= nil and speech ~= "" then
        parts[#parts + 1] = tostring(speech)
    end
    if #parts == 0 then
        return nil
    end
    return table.concat(parts, ", ")
end

-- Screen title = leader's name as the engine places it in NameText on
-- every message. onShow runs after priorShowHide so NameText is populated
-- by the time we read it here.
local function titleFn()
    local text = Controls.NameText:GetText()
    if text == nil or text == "" then
        return nil
    end
    return tostring(text)
end

TradeLogicAccess.install(ContextPtr, priorInput, priorShowHide, {
    name = "DiploTrade",
    kind = "AI",
    displayNameFn = titleFn,
    preambleFn = composePreamble,
    -- Silent first open: the leader plays a voice clip on every message;
    -- Tolk reading NameText + DiscussionText at the same time would
    -- double-narrate. F1 re-reads the preamble on demand.
    silentFirstOpen = true,
    fallbackDisplayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_TRADE"),
})
