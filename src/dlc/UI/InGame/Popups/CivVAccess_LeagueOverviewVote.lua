-- Mod-side replacement for the engine's VoteController / VoteYesNoController /
-- VoteMajorCivController (LeagueOverview.lua line 1057+). Tracks one entry
-- per votable proposal as a signed integer (positive = Yea, negative = Nay,
-- zero = abstain) for yes/no resolutions, or a non-negative integer plus a
-- chosen civ ID for major-civ resolutions. Pool accounting is identical to
-- the engine: `availableVotes = totalVotes - sum(abs(entry.votes))`. State
-- lives only in the controller table; commit fires the same Network.SendLeague*
-- calls the engine's CommitVotes path uses, with the same
-- TXT_KEY_LEAGUE_OVERVIEW_CONFIRM / _CONFIRM_MISSING_VOTES confirm copy.
--
-- Vote rows are built as kind="slider" items so BaseMenuCore's onLeft /
-- onRight call adjust(menu, dir, big). Step is +/- 1, big-step is +/- 5;
-- announce reads live entry state so reset / dirty-refresh / picker-commit
-- changes are reflected on the next move without an explicit setItems
-- rebuild. Major-civ rows whose choice is unset open the picker on Enter
-- (or Right / Left), matching the engine's VoteUp behavior of opening
-- ResolutionChoicePopup before the magnitude can change.

LeagueOverviewVote = {}

local kChoiceNone = -1
local STEP = 1
local BIG_STEP = 5
local PICKER_NAME = "LeagueOverviewMajorCivPicker"

-- Controller --------------------------------------------------------------

local Controller = {}
Controller.__index = Controller

local function isMajorCivProposal(proposal)
    return proposal.VoterChoices ~= nil
end

local function buildVoterChoices(pLeague, resolutionType, activePlayer)
    local resolutionInfo = GameInfo.Resolutions[resolutionType]
    if resolutionInfo == nil or resolutionInfo.VoterDecision == "RESOLUTION_DECISION_YES_OR_NO" then
        return nil
    end
    local decisionInfo = GameInfo.ResolutionDecisions[resolutionInfo.VoterDecision]
    local decisionId = decisionInfo.ID
    local choices = pLeague:GetChoicesForDecision(decisionId, activePlayer)
    local out = {}
    for _, choiceId in ipairs(choices) do
        out[#out + 1] = {
            Id = choiceId,
            Text = pLeague:GetTextForChoice(decisionId, choiceId),
        }
    end
    return out
end

-- Snapshot a proposal table from one of the GetEnactProposals /
-- GetRepealProposals / GetEnactProposalsOnHold / GetRepealProposalsOnHold
-- shapes into the consistent struct the rest of the module reads. The
-- direction string ("Enact" / "Retract") matches engine convention used for
-- the Network call dispatch in commit.
local function snapshotProposal(pLeague, raw, direction, onHold, activePlayer)
    return {
        ID = raw.ID,
        Type = raw.Type,
        ProposalPlayer = raw.ProposalPlayer,
        ProposerDecision = raw.ProposerDecision,
        Direction = direction,
        OnHold = onHold,
        VoterChoices = buildVoterChoices(pLeague, raw.Type, activePlayer),
    }
end

-- Collect every current-session proposal in engine display order: enact
-- live, repeal live, enact on-hold, repeal on-hold. Returns a flat list;
-- on-hold proposals are included so the screen still surfaces them even
-- though they are not votable.
function LeagueOverviewVote.collectProposals(pLeague, activePlayer)
    local out = {}
    local sources = {
        { pLeague:GetEnactProposals(), "Enact", false },
        { pLeague:GetRepealProposals(), "Retract", false },
        { pLeague:GetEnactProposalsOnHold(), "Enact", true },
        { pLeague:GetRepealProposalsOnHold(), "Retract", true },
    }
    for _, src in ipairs(sources) do
        for _, raw in ipairs(src[1]) do
            out[#out + 1] = snapshotProposal(pLeague, raw, src[2], src[3], activePlayer)
        end
    end
    return out
end

-- Construct a controller for the active player's vote pool. proposals is
-- the pre-collected list (typically from collectProposals) so the caller
-- can pass the same list it uses to build the proposal rows -- on-hold
-- entries are filtered out here since they are not votable. leagueId is
-- the integer ID required for the Network commit calls (the league handle
-- itself does not expose a GetID method); the Access file derives it once
-- per show via findLeagueIdFor and passes it down.
function LeagueOverviewVote.create(pLeague, activePlayer, leagueId, proposals)
    local self = setmetatable({}, Controller)
    self.leagueId = leagueId
    self.activePlayer = activePlayer
    self.totalVotes = pLeague:GetRemainingVotesForMember(activePlayer)
    self.entries = {}
    for _, proposal in ipairs(proposals) do
        if not proposal.OnHold then
            self.entries[#self.entries + 1] = {
                proposal = proposal,
                votes = 0,
                choice = nil,
            }
        end
    end
    return self
end

-- Reconcile entries against a fresh proposal list (after dirty-refresh).
-- Preserves votes / choice for entries whose proposal.ID still appears in
-- the new list; drops entries for proposals that vanished; appends fresh
-- entries (votes = 0) for proposals that newly appeared. The total vote
-- pool is re-read in case the engine has updated it (rare in-session, but
-- happens on city-state ally swaps).
function Controller:syncToCurrent(pLeague, proposals)
    local oldByID = {}
    for _, entry in ipairs(self.entries) do
        oldByID[entry.proposal.ID] = entry
    end
    local newEntries = {}
    for _, proposal in ipairs(proposals) do
        if not proposal.OnHold then
            local prior = oldByID[proposal.ID]
            if prior ~= nil then
                prior.proposal = proposal
                newEntries[#newEntries + 1] = prior
            else
                newEntries[#newEntries + 1] = {
                    proposal = proposal,
                    votes = 0,
                    choice = nil,
                }
            end
        end
    end
    self.entries = newEntries
    self.totalVotes = pLeague:GetRemainingVotesForMember(self.activePlayer)
    -- If the vote pool shrank below what the user already had allocated
    -- (city-state ally swap, vote-source loss), zero every entry rather
    -- than leave the controller in an over-budget state where commit would
    -- fire SendLeagueVote* with vote counts the engine no longer believes
    -- the player owns. Engine handles this case by re-initializing the
    -- controller from scratch on its own dirty refresh; we mirror by
    -- resetting allocations.
    local used = 0
    for _, entry in ipairs(self.entries) do
        used = used + math.abs(entry.votes)
    end
    if used > self.totalVotes then
        for _, entry in ipairs(self.entries) do
            entry.votes = 0
            entry.choice = nil
        end
    end
end

function Controller:availableVotes()
    local used = 0
    for _, entry in ipairs(self.entries) do
        used = used + math.abs(entry.votes)
    end
    return self.totalVotes - used
end

function Controller:reset()
    for _, entry in ipairs(self.entries) do
        entry.votes = 0
        entry.choice = nil
    end
end

-- Adjust a yes/no entry by signed delta, clamping to the row's symmetric
-- absolute max (pool + abs(current)). Returns the new value so callers can
-- detect a no-op and skip the speak.
function Controller:adjustYesNo(idx, delta)
    local entry = self.entries[idx]
    local pool = self:availableVotes()
    local absMax = pool + math.abs(entry.votes)
    local target = entry.votes + delta
    if target > absMax then
        target = absMax
    elseif target < -absMax then
        target = -absMax
    end
    entry.votes = target
    return target
end

-- Adjust a major-civ entry by signed delta, clamping to [0, pool + current].
-- Reaching zero clears the picked civ so the next adjust / activate re-opens
-- the picker (mirrors engine's VoteDown-to-zero behavior).
function Controller:adjustMajorCiv(idx, delta)
    local entry = self.entries[idx]
    local pool = self:availableVotes()
    local maxV = pool + entry.votes
    local target = entry.votes + delta
    if target < 0 then
        target = 0
    elseif target > maxV then
        target = maxV
    end
    entry.votes = target
    if target == 0 then
        entry.choice = nil
    end
    return target
end

function Controller:setMajorCivChoice(idx, choicePlayerID)
    local entry = self.entries[idx]
    entry.choice = choicePlayerID
    if entry.votes == 0 then
        local pool = self:availableVotes()
        if pool > 0 then
            entry.votes = 1
        end
    end
end

-- Fire the same Network.SendLeague* calls the engine's VoteController:CommitVotes
-- emits, in the same order: SendLeagueVoteEnact / SendLeagueVoteRepeal for
-- each non-zero entry, then SendLeagueVoteAbstain for unspent delegates.
-- closeFn is the engine OnClose hook (popped popup on commit, matching
-- engine OnConfirmYes line 1684).
function Controller:commit(closeFn)
    for _, entry in ipairs(self.entries) do
        if entry.votes ~= 0 then
            local choice = entry.choice or kChoiceNone
            local votes = math.abs(entry.votes)
            if entry.proposal.Direction == "Enact" then
                Network.SendLeagueVoteEnact(self.leagueId, entry.proposal.ID, self.activePlayer, votes, choice)
            else
                Network.SendLeagueVoteRepeal(self.leagueId, entry.proposal.ID, self.activePlayer, votes, choice)
            end
        end
    end
    local remaining = self:availableVotes()
    if remaining > 0 then
        Network.SendLeagueVoteAbstain(self.leagueId, self.activePlayer, remaining)
    end
    if type(closeFn) == "function" then
        closeFn()
    end
end

function Controller:hasUnspentDelegates()
    return self:availableVotes() > 0
end

function Controller:findEntryByProposalID(proposalID)
    for i, entry in ipairs(self.entries) do
        if entry.proposal.ID == proposalID then
            return i
        end
    end
    return nil
end

-- Major-civ picker --------------------------------------------------------

-- Push a sub-handler listing the proposal's voter choices (one Choice per
-- candidate civ). Picking a civ writes the choice back into the controller
-- entry and pops the sub; the parent menu re-activates and the row's
-- announce re-reads the new vote-state ("1 for Bismarck of Germany").
local function pushMajorCivPicker(controller, idx)
    local entry = controller.entries[idx]
    local choices = entry.proposal.VoterChoices or {}
    local items = {}
    for _, choice in ipairs(choices) do
        local choiceId = choice.Id
        local label = choice.Text
        items[#items + 1] = BaseMenuItems.Choice({
            labelText = tostring(label),
            activate = function()
                controller:setMajorCivChoice(idx, choiceId)
                HandlerStack.removeByName(PICKER_NAME, true)
            end,
        })
    end
    local sub = BaseMenu.create({
        name = PICKER_NAME,
        displayName = LeagueOverviewRow.formatResolutionName(
            Game.GetLeague(controller.leagueId),
            entry.proposal.Type,
            entry.proposal.ID,
            entry.proposal.ProposerDecision,
            entry.proposal.Direction
        ),
        items = items,
        capturesAllInput = true,
        escapePops = true,
        escapeAnnounce = Text.key("TXT_KEY_CIVVACCESS_CANCELED"),
    })
    HandlerStack.push(sub)
end

-- Vote row item -----------------------------------------------------------
--
-- kind="slider" so onLeft / onRight in BaseMenuCore call adjust(menu, dir,
-- big). The row's announce / activate / adjust read live state from the
-- controller -- no rebuild needed after a value change. isNavigable always
-- true (the proposal exists by construction); isActivatable mirrors that.

function LeagueOverviewVote.row(controller, idx, pLeague, activePlayer)
    local entry = controller.entries[idx]
    local item = {
        kind = "slider",
        step = STEP,
        bigStep = BIG_STEP,
    }
    function item:isNavigable()
        return true
    end
    function item:isActivatable()
        return true
    end
    function item:announce(menu)
        local voteState
        if isMajorCivProposal(entry.proposal) then
            voteState = LeagueOverviewRow.formatMajorCivVoteState(entry.votes, entry.choice)
        else
            voteState = LeagueOverviewRow.formatYesNoVoteState(entry.votes)
        end
        return LeagueOverviewRow.formatProposal(pLeague, entry.proposal, activePlayer, voteState)
    end
    function item:activate(menu)
        if isMajorCivProposal(entry.proposal) and entry.choice == nil then
            pushMajorCivPicker(controller, idx)
            return
        end
        SpeechPipeline.speakInterrupt(self:announce(menu))
    end
    function item:adjust(menu, dir, big)
        if isMajorCivProposal(entry.proposal) and entry.choice == nil then
            pushMajorCivPicker(controller, idx)
            return
        end
        local delta = (big and BIG_STEP or STEP) * dir
        if isMajorCivProposal(entry.proposal) then
            controller:adjustMajorCiv(idx, delta)
        else
            controller:adjustYesNo(idx, delta)
        end
        SpeechPipeline.speakInterrupt(self:announce(menu))
    end
    return item
end

return LeagueOverviewVote
