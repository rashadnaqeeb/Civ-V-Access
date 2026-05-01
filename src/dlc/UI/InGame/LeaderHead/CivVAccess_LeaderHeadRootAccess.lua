-- LeaderHeadRoot (BNW) accessibility. The diplomacy screen that shows when
-- an AI leader speaks to you: mood text, the spoken line, and action
-- buttons (Discuss / Trade / Demand / War-or-Peace). Back is reached via
-- Esc, falling through to the base InputHandler's OnReturn.
--
-- displayName is the leader title (populated from Controls.TitleText in
-- onShow, after LeaderMessageHandler has written it for the current
-- leader). The screen opens speaking title + mood + speech via the
-- function preamble, resolved live each call so a new AILeaderMessage
-- coming back from a sub-screen (Trade, DiscussionDialog, etc.)
-- re-reads the latest text. The engine's voice clip plays a
-- constructed-language line that doesn't match the subtitle text, so
-- letting Tolk overlap the clip is the accessible behavior -- the
-- subtitle is the only canonical content. F1 re-reads on demand.

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
include("CivVAccess_LeaderDescription")
include("CivVAccess_Help")

local priorInput = InputHandler
local priorShowHide = OnShowHide

-- Preamble --------------------------------------------------------------
--
-- Reads live each time BaseMenu resolves the preamble (first-open speech,
-- F1 readHeader, refresh). Mood text is set by LeaderMessageHandler
-- against one of the TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_* keys; speech
-- text is the szLeaderMessage the AI just spoke. Both controls outlive
-- the current dialogue cycle, so reading them here gives the most recent
-- content the engine placed on screen.

local function composePreamble()
    local body = Text.joinNonEmpty({
        Controls.MoodText:GetText(),
        Controls.LeaderSpeech:GetText(),
    })
    if body == "" then
        return nil
    end
    return body
end

-- War-button tooltip is set dynamically ("Locked into war for N turns",
-- "You have sworn a Peace Treaty", standard "Declare War" blurb). The
-- reason lives only on the control's tooltip string, not in a stable
-- TXT_KEY, so we read it at announce time.
local function warButtonTooltip(ctrl)
    local ok, tip = pcall(function()
        return ctrl:GetToolTipString()
    end)
    if not ok or tip == nil or tip == "" then
        return nil
    end
    return tostring(tip)
end

-- Install ---------------------------------------------------------------

-- LeaderHeadRoot's base-game module keeps the current AI as `local
-- g_iAIPlayer`, an upvalue we cannot read from our include chunk.
-- Chain Events.AILeaderMessage (new listener per Context include per
-- CLAUDE.md's no-install-once rule) and capture iPlayer ourselves so
-- F2 has a live id to look up at press time.
local currentAIPlayer = -1
local function onAILeaderMessage(iPlayer)
    currentAIPlayer = iPlayer
end
Events.AILeaderMessage.Add(onAILeaderMessage)

local handler = BaseMenu.install(ContextPtr, {
    name = "LeaderHeadRoot",
    -- Placeholder; onShow overwrites with the live leader title so each
    -- open speaks "Suleiman the Magnificent" rather than "Diplomacy".
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_DIPLOMACY"),
    preamble = composePreamble,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    onShow = function(handler)
        local title = Controls.TitleText:GetText()
        if title ~= nil and title ~= "" then
            handler.displayName = tostring(title)
        end
    end,
    items = {
        -- All four buttons use labelFn so the spoken label matches whatever
        -- the engine has put on the button: live for WarButton (flips
        -- between "Declare War" and "Negotiate Peace" on WarStateChanged),
        -- locale-correct for the others without us having to track each
        -- button's TXT_KEY manually.
        BaseMenuItems.Button({
            controlName = "DiscussButton",
            labelFn = function(ctrl)
                return ctrl:GetText()
            end,
            activate = function()
                OnDiscuss()
            end,
        }),
        BaseMenuItems.Button({
            controlName = "TradeButton",
            labelFn = function(ctrl)
                return ctrl:GetText()
            end,
            activate = function()
                OnTrade()
            end,
        }),
        BaseMenuItems.Button({
            controlName = "DemandButton",
            labelFn = function(ctrl)
                return ctrl:GetText()
            end,
            activate = function()
                OnDemand()
            end,
        }),
        BaseMenuItems.Button({
            controlName = "WarButton",
            labelFn = function(ctrl)
                return ctrl:GetText()
            end,
            tooltipFn = warButtonTooltip,
            activate = function()
                OnWarOrPeace()
            end,
        }),
    },
})

-- Re-read the preamble when a new AILeaderMessage updates mood / speech
-- on the already-open screen. Base's LeaderMessageHandler precedes ours
-- in dispatch order and finishes setting MoodText / LeaderSpeech (or the
-- "Anything else?" seed when the new state belongs to another screen)
-- before this listener runs. refresh is gated on _initialized so a
-- transition into trade / discussion -- which hides LeaderHeadRoot in
-- the same dispatch chain -- can't speak the seed text on the way out.
Events.AILeaderMessage.Add(function()
    if handler ~= nil then
        handler.refresh()
    end
end)

LeaderDescription.bindF2(handler, function()
    return currentAIPlayer
end)
