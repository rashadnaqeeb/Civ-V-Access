-- Mod-side replacement for the engine's ProposalController (LeagueOverview.lua
-- line 1180+). One slot per available proposal -- a slot is either empty
-- ("Empty proposal slot N" Text) or filled ({Direction, Type, ResolutionId,
-- ChoiceId} which renders as "Slot N: Enact: <name>"). Activating a slot
-- pushes a picker (BaseMenu sub-handler) showing the resolution catalog in
-- three drillable sections; picking a candidate fills the slot and pops back.
-- Reset returns every slot to empty (no Network call); Commit fires
-- Network.SendLeagueProposeEnact / SendLeagueProposeRepeal for each filled
-- slot then closes the popup.
--
-- Sub-decision picker (which civ to embargo, which religion to designate)
-- is a second push: opening the candidate's GetResolutionDetails plus a
-- Choice per ProposerChoice. Engine handles this in a separate
-- ResolutionChoicePopup overlay (line 855); we replicate the same shape
-- as a stack-based handler.

LeagueOverviewProposal = {}

local kChoiceNone = -1
local kNoPlayer = -1
local PICKER_NAME = "LeagueOverviewSlotPicker"
local SUB_DECISION_NAME = "LeagueOverviewSlotSubDecision"

local Controller = {}
Controller.__index = Controller

local function snapshotInactiveCandidate(pLeague, raw, activePlayer)
    local proposerDecision = raw.ProposerDecision or kChoiceNone
    local canEnact = pLeague:CanProposeEnactAnyChoice(raw.Type, activePlayer)
    local possible = pLeague:CanProposeEnactAnyChoice(raw.Type, kNoPlayer)
    local resolutionInfo = GameInfo.Resolutions[raw.Type]
    local proposerDecisionType = resolutionInfo and resolutionInfo.ProposerDecision or nil
    local proposerChoices = nil
    if proposerDecisionType ~= nil and proposerDecisionType ~= "RESOLUTION_DECISION_NONE" then
        local decisionInfo = GameInfo.ResolutionDecisions[proposerDecisionType]
        if decisionInfo ~= nil then
            local decisionId = decisionInfo.ID
            local choices = pLeague:GetChoicesForDecision(decisionId, activePlayer)
            proposerChoices = {}
            for _, choiceId in ipairs(choices) do
                proposerChoices[#proposerChoices + 1] = {
                    Id = choiceId,
                    Text = pLeague:GetTextForChoice(decisionId, choiceId),
                    -- Engine stores a per-choice Disabled flag from CanProposeEnact;
                    -- we mirror so the sub-decision picker can grey unselectable rows.
                    Disabled = not pLeague:CanProposeEnact(raw.Type, activePlayer, choiceId),
                }
            end
        end
    end
    return {
        Type = raw.Type,
        ResolutionId = -1,
        ProposerDecision = proposerDecision,
        Direction = "Enact",
        Disabled = not canEnact,
        Possible = possible,
        ProposerChoices = proposerChoices,
    }
end

local function snapshotActiveCandidate(pLeague, raw, activePlayer)
    local proposerDecision = raw.ProposerDecision or kChoiceNone
    return {
        Type = raw.Type,
        ResolutionId = raw.ID,
        ProposerDecision = proposerDecision,
        Direction = "Retract",
        Disabled = not pLeague:CanProposeRepeal(raw.ID, activePlayer),
    }
end

-- Snapshot every catalog entry the slot picker (and View All) can read
-- from. Returns three arrays: active (repealable, includes disabled
-- non-repealable for awareness), inactiveEnactable (Disabled == false),
-- inactiveOther (Disabled == true; includes both can't-propose-now and
-- can't-be-proposed-by-anyone). Order matches engine's GetActiveResolutions
-- / GetInactiveResolutions iteration.
function LeagueOverviewProposal.collectCandidates(pLeague, activePlayer)
    local active = {}
    for _, raw in ipairs(pLeague:GetActiveResolutions()) do
        active[#active + 1] = snapshotActiveCandidate(pLeague, raw, activePlayer)
    end
    local inactiveEnactable = {}
    local inactiveOther = {}
    for _, raw in ipairs(pLeague:GetInactiveResolutions()) do
        local snap = snapshotInactiveCandidate(pLeague, raw, activePlayer)
        if snap.Disabled then
            inactiveOther[#inactiveOther + 1] = snap
        else
            inactiveEnactable[#inactiveEnactable + 1] = snap
        end
    end
    return active, inactiveEnactable, inactiveOther
end

-- Construct a controller with N empty slots, where N is the active player's
-- remaining proposal allowance. leagueId is required for the Network commit
-- calls (the league handle does not expose its own ID).
function LeagueOverviewProposal.create(pLeague, activePlayer, leagueId)
    local self = setmetatable({}, Controller)
    self.leagueId = leagueId
    self.activePlayer = activePlayer
    self.numSlots = pLeague:GetRemainingProposalsForMember(activePlayer)
    self.slots = {}
    return self
end

-- Reset all slots to empty. No Network call -- pending state lives only
-- in this controller, mirroring engine ProposalController:ResetProposals.
function Controller:reset()
    self.slots = {}
end

function Controller:isSlotEmpty(idx)
    return self.slots[idx] == nil
end

function Controller:fillSlot(idx, candidate, choiceId)
    self.slots[idx] = {
        Direction = candidate.Direction,
        Type = candidate.Type,
        ResolutionId = candidate.ResolutionId,
        ChoiceId = choiceId or candidate.ProposerDecision or kChoiceNone,
    }
end

function Controller:filledCount()
    local n = 0
    for i = 1, self.numSlots do
        if self.slots[i] ~= nil then
            n = n + 1
        end
    end
    return n
end

-- Same dispatch order as engine ProposalController:CommitProposals: fire
-- SendLeagueProposeEnact for each Enact slot, SendLeagueProposeRepeal for
-- each Retract slot, then call closeFn (engine's OnClose, matching
-- OnConfirmYes line 1684). Empty slots are no-ops.
function Controller:commit(closeFn)
    for i = 1, self.numSlots do
        local slot = self.slots[i]
        if slot ~= nil then
            if slot.Direction == "Enact" then
                Network.SendLeagueProposeEnact(self.leagueId, slot.Type, self.activePlayer, slot.ChoiceId)
            else
                Network.SendLeagueProposeRepeal(self.leagueId, slot.ResolutionId, self.activePlayer)
            end
        end
    end
    if type(closeFn) == "function" then
        closeFn()
    end
end

-- Slot picker -------------------------------------------------------------
--
-- Pushed when the user activates a slot. Three drillable Group sections
-- (Active to repeal / Resolutions to propose / Other resolutions); each
-- candidate's drill-in is one Text row containing the full filtered
-- GetResolutionDetails plus (for actionable ones) a "Propose this
-- resolution" / "Repeal this resolution" Choice. If the candidate has
-- ProposerChoices (sub-decision: which civ to embargo, etc.), the Choice
-- pushes a sub-decision picker before filling the slot.

local function fillSlotAndPopAll(controller, slotIdx, candidate, choiceId)
    controller:fillSlot(slotIdx, candidate, choiceId)
    -- Pop both the sub-decision picker (if open) and the slot picker so
    -- the user lands back on the proposals tab with the slot now filled.
    HandlerStack.removeByName(SUB_DECISION_NAME, false)
    HandlerStack.removeByName(PICKER_NAME, true)
end

local function pushSubDecisionPicker(controller, slotIdx, candidate, pLeague)
    local items = {}
    for _, choice in ipairs(candidate.ProposerChoices or {}) do
        local choiceId = choice.Id
        local label = tostring(choice.Text)
        if choice.Disabled then
            -- Engine renders disabled rows greyed; we surface as a non-
            -- activatable Text so the user still hears them but can't pick.
            items[#items + 1] = BaseMenuItems.Text({ labelText = label })
        else
            items[#items + 1] = BaseMenuItems.Choice({
                labelText = label,
                activate = function()
                    fillSlotAndPopAll(controller, slotIdx, candidate, choiceId)
                end,
            })
        end
    end
    local sub = BaseMenu.create({
        name = SUB_DECISION_NAME,
        displayName = LeagueOverviewRow.formatResolutionName(
            pLeague,
            candidate.Type,
            candidate.ResolutionId,
            candidate.ProposerDecision,
            candidate.Direction
        ),
        items = items,
        capturesAllInput = true,
        escapePops = true,
        escapeAnnounce = Text.key("TXT_KEY_CIVVACCESS_CANCELED"),
    })
    HandlerStack.push(sub)
end

local function buildCandidateGroup(controller, slotIdx, candidate, pLeague, activePlayer, allowCommit)
    local label = LeagueOverviewRow.formatResolutionName(
        pLeague,
        candidate.Type,
        candidate.ResolutionId,
        candidate.ProposerDecision,
        candidate.Direction
    )
    local detailsText =
        pLeague:GetResolutionDetails(candidate.Type, activePlayer, candidate.ResolutionId, candidate.ProposerDecision)
    local children = {
        BaseMenuItems.Text({ labelText = TextFilter.filter(tostring(detailsText or "")) }),
    }
    if allowCommit and not candidate.Disabled then
        local commitKey = candidate.Direction == "Retract" and "TXT_KEY_CIVVACCESS_LEAGUE_REPEAL_THIS"
            or "TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_THIS"
        children[#children + 1] = BaseMenuItems.Choice({
            textKey = commitKey,
            activate = function()
                if candidate.ProposerChoices ~= nil and #candidate.ProposerChoices > 0 then
                    pushSubDecisionPicker(controller, slotIdx, candidate, pLeague)
                else
                    fillSlotAndPopAll(controller, slotIdx, candidate, candidate.ProposerDecision)
                end
            end,
        })
    end
    return BaseMenuItems.Group({ labelText = label, items = children })
end

local function buildSection(headerKey, candidates, controller, slotIdx, pLeague, activePlayer, allowCommit)
    if #candidates == 0 then
        return nil
    end
    local children = {}
    for _, candidate in ipairs(candidates) do
        children[#children + 1] =
            buildCandidateGroup(controller, slotIdx, candidate, pLeague, activePlayer, allowCommit)
    end
    return BaseMenuItems.Group({
        labelText = Text.key(headerKey),
        items = children,
    })
end

-- Push the slot picker. slotIdx is the 1-based slot the user activated;
-- picking a candidate writes back into controller.slots[slotIdx].
function LeagueOverviewProposal.pushSlotPicker(controller, slotIdx, pLeague)
    local activePlayer = controller.activePlayer
    local active, inactiveEnactable, inactiveOther = LeagueOverviewProposal.collectCandidates(pLeague, activePlayer)
    local items = {}
    local sActive = buildSection(
        "TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_ACTIVE",
        active,
        controller,
        slotIdx,
        pLeague,
        activePlayer,
        true
    )
    if sActive ~= nil then
        items[#items + 1] = sActive
    end
    local sEnactable = buildSection(
        "TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_INACTIVE",
        inactiveEnactable,
        controller,
        slotIdx,
        pLeague,
        activePlayer,
        true
    )
    if sEnactable ~= nil then
        items[#items + 1] = sEnactable
    end
    local sOther = buildSection(
        "TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_SECTION_OTHER",
        inactiveOther,
        controller,
        slotIdx,
        pLeague,
        activePlayer,
        false
    )
    if sOther ~= nil then
        items[#items + 1] = sOther
    end
    -- Generic slot title regardless of empty/filled state. The original
    -- "Empty proposal slot N" was wrong on re-open of a filled slot, where
    -- the user is changing rather than first-picking.
    local picker = BaseMenu.create({
        name = PICKER_NAME,
        displayName = Text.format("TXT_KEY_CIVVACCESS_LEAGUE_SLOT_PICKER", slotIdx),
        items = items,
        capturesAllInput = true,
        escapePops = true,
        escapeAnnounce = Text.key("TXT_KEY_CIVVACCESS_CANCELED"),
    })
    HandlerStack.push(picker)
end

-- Slot item ---------------------------------------------------------------

function LeagueOverviewProposal.slotItem(controller, slotIdx, pLeague, activePlayer)
    return BaseMenuItems.Text({
        labelFn = function()
            local slot = controller.slots[slotIdx]
            if slot == nil then
                return Text.format("TXT_KEY_CIVVACCESS_LEAGUE_SLOT_EMPTY", slotIdx)
            end
            local body = LeagueOverviewRow.formatResolutionName(
                pLeague,
                slot.Type,
                slot.ResolutionId,
                slot.ChoiceId,
                slot.Direction
            )
            return Text.format("TXT_KEY_CIVVACCESS_LEAGUE_SLOT_FILLED", slotIdx, body)
        end,
        onActivate = function()
            LeagueOverviewProposal.pushSlotPicker(controller, slotIdx, pLeague)
        end,
    })
end

return LeagueOverviewProposal
