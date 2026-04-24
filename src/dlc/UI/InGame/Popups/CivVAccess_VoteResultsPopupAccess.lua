-- VoteResultsPopup accessibility. BUTTONPOPUP_VOTE_RESULTS pops after the
-- World Leader (Diplomatic Victory) ballot resolves. The screen lists every
-- team in vote order, showing each team's name, the team they voted for, and
-- the votes that team received.
--
-- The full ballot can include 22 majors plus city-states, so each team is
-- exposed as its own navigable Text item rather than one long preamble.
-- Preamble carries the screen header (votes-needed-to-win, or the
-- preliminary-election variant when popupInfo.Option1 is true).
--
-- Capture strategy: monkey-patch the base AddTeamEntry global so we ride
-- the same sorted iteration base does (table.sort by votes, ties broken in
-- favor of majors). Base UpdateAll runs synchronously inside the
-- SerialEventGameMessagePopup dispatch, so by the time ShowHide(false)
-- fires the captured list is complete.

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

local capturedEntries = {}
local capturedTeamGame = false

local baseAddTeamEntry = AddTeamEntry
AddTeamEntry = function(iTeam, iVotes, iRank)
    baseAddTeamEntry(iTeam, iVotes, iRank)
    if iRank == 1 then
        capturedEntries = {}
        capturedTeamGame = g_bIsTeamGame == true
    end
    capturedEntries[#capturedEntries + 1] = {
        iTeam  = iTeam,
        iVotes = iVotes,
        iRank  = iRank,
    }
end

local function teamLabel(iTeam, asVoter)
    local pTeam = Teams[iTeam]
    local pPlayer = Players[pTeam:GetLeaderID()]
    local activeTeam = Teams[Game.GetActiveTeam()]
    if pPlayer:GetID() == Game.GetActivePlayer() or activeTeam:GetID() == iTeam then
        if capturedTeamGame and asVoter ~= true then
            return Text.key("TXT_KEY_POP_VOTE_RESULTS_YOUR_TEAM")
        end
        return Text.key("TXT_KEY_POP_VOTE_RESULTS_YOU")
    end
    if not pTeam:IsHasMet(Game.GetActiveTeam()) then
        if capturedTeamGame then
            return Text.key("TXT_KEY_POP_VOTE_RESULTS_UNMET_TEAM")
        end
        return Text.key("TXT_KEY_POP_VOTE_RESULTS_UNMET_PLAYER")
    end
    if capturedTeamGame and not pTeam:IsMinorCiv() then
        return Text.format("TXT_KEY_POP_UN_TEAM_LABEL", iTeam + 1)
    end
    return Text.key(pPlayer:GetNameKey())
end

local function voteCastLabel(iTeam)
    local pTeam = Teams[iTeam]
    local iVoteCast = Game.GetVoteCast(iTeam)
    -- Minor abstaining (votes for itself).
    if pTeam:IsMinorCiv() and iTeam == iVoteCast then
        return Text.key("TXT_KEY_ABSTAIN")
    end
    return teamLabel(iVoteCast, true)
end

local function buildPreamble()
    local parts = {}
    parts[#parts + 1] = Text.key("TXT_KEY_POP_UN_ELEC_RESULTS")
    local label = Controls.PrelimElectionLabel
    if label ~= nil and not label:IsHidden() then
        local t = label:GetText()
        if t ~= nil and t ~= "" then
            parts[#parts + 1] = tostring(t)
        end
    end
    local needed = Controls.VotesNeededLabel
    if needed ~= nil and not needed:IsHidden() then
        local t = needed:GetText()
        if t ~= nil and t ~= "" then
            parts[#parts + 1] = tostring(t)
        end
    end
    return table.concat(parts, ". ")
end

local function buildItems()
    local items = {}
    for _, e in ipairs(capturedEntries) do
        local label = Text.format("TXT_KEY_CIVVACCESS_VOTE_RESULTS_ENTRY",
            e.iRank,
            teamLabel(e.iTeam, false),
            voteCastLabel(e.iTeam),
            tostring(e.iVotes))
        items[#items + 1] = BaseMenuItems.Text({ labelText = label })
    end
    items[#items + 1] = BaseMenuItems.Button({
        controlName = "CloseButton",
        textKey     = "TXT_KEY_CLOSE",
        activate    = function() OnClose() end,
    })
    return items
end

BaseMenu.install(ContextPtr, {
    name          = "VoteResultsPopup",
    displayName   = Text.key("TXT_KEY_CIVVACCESS_SCREEN_VOTE_RESULTS"),
    preamble      = buildPreamble,
    priorInput    = priorInput,
    priorShowHide = priorShowHide,
    onShow        = function(handler)
        handler.setItems(buildItems())
    end,
    items         = {},
})
