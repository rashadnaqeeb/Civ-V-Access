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
include("CivVAccess_LeaderDescription")
include("CivVAccess_Help")

local priorInput = InputHandler
local priorShowHide = OnShowHide

-- F1 speaks displayName (NameText) then the preamble. DiploTrade's screen
-- has no separate mood field, so the only new content the preamble adds is
-- the AI's current discussion line. Re-reading NameText here would double-
-- narrate the leader name on every F1 press.
local function composePreamble()
    local speech = Controls.DiscussionText:GetText()
    if speech == nil or speech == "" then
        return nil
    end
    return tostring(speech)
end

-- Screen title = "<leader> says:" derived from g_iThem rather than from
-- Controls.NameText. NameText is set later in LeaderMessageHandler (via
-- DisplayDeal -> ResetDisplay), so when QueuePopup fires its ShowHide
-- synchronously the reused Context can briefly still hold the previous
-- leader's NameText -- which is what produced "Bismarck says:" while
-- actually opening trade with Harald. g_iThem is updated at the very top
-- of LeaderMessageHandler, before any popup or display work, so it's
-- always the current leader by the time onShow runs.
local function titleFn()
    if g_iThem ~= nil and g_iThem >= 0 then
        local pPlayer = Players[g_iThem]
        if pPlayer ~= nil then
            return Text.format("TXT_KEY_DIPLO_LEADER_SAYS", pPlayer:GetName())
        end
    end
    -- Fallback in case globals haven't been populated yet.
    local text = Controls.NameText:GetText()
    if text ~= nil and text ~= "" then
        return tostring(text)
    end
    return nil
end

local handler = TradeLogicAccess.install(ContextPtr, priorInput, priorShowHide, {
    name = "DiploTrade",
    kind = "AI",
    displayNameFn = titleFn,
    preambleFn = composePreamble,
    -- The engine's voice clip is a constructed-language line that doesn't
    -- match the subtitle text, so we don't suppress the open-speech --
    -- the subtitle is the only canonical content for this screen.
    fallbackDisplayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_TRADE"),
})

-- F2 reads the AI leader's portrait description. TradeLogic exposes the
-- other-side player id as a global `g_iThem` (the TradeLogic chunk runs
-- in this Context's env before our include), so resolve live at
-- keypress rather than caching.
LeaderDescription.bindF2(handler, function()
    return g_iThem
end)
