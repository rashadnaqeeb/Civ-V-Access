-- SimpleDiploTrade (PvP live-deal) accessibility. Included by
-- SimpleDiploTrade.lua's verbatim override. PvP-specific wiring in the
-- descriptor: title from ThemName, no preamble (no speech frame), full
-- speech on open (no voice clip to double-narrate).

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

-- PvP title: "Trade with <other-player-name>". ThemName is live text the
-- engine sets on OpenPlayerDealScreen; format around it so the user hears
-- the full context (trade with someone specific, not a floating name).
local function titleFn()
    local text = Controls.ThemName:GetText()
    if text == nil or text == "" then
        return nil
    end
    return Text.format("TXT_KEY_CIVVACCESS_SCREEN_TRADE_WITH", tostring(text))
end

TradeLogicAccess.install(ContextPtr, priorInput, priorShowHide, {
    name = "SimpleDiploTrade",
    kind = "PvP",
    displayNameFn = titleFn,
    preambleFn = nil,
    silentFirstOpen = false,
    fallbackDisplayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_TRADE"),
})
