-- ProposalChartPopup accessibility (LekMod only). LekMod's MP voting system
-- opens this via BUTTONPOPUP_MODDER_0 (Data1 = proposal id, Data2 = status):
-- the proposal headline, vote tally, expiration, per-player vote state, and
-- (while voting is open) the local player's Yes / No buttons. The Context is a
-- LekMod UI addin; this file never loads on a vanilla / VP install, so it calls
-- LekMod's voting bindings directly. Those bindings exist on no other engine,
-- which is why this screen is engine-scoped to lekmod in the vendor manifest.
--
-- The proposal id arrives on the popup event, not in any Control we can read,
-- so a sibling SerialEventGameMessagePopup listener captures it (running
-- alongside LekMod's own OnPopup). preamble and items read live proposal state
-- on every show / re-read.

include("CivVAccess_PopupBoot")

local priorInput = InputHandler
local priorShowHide = ShowHideHandler

local capturedId = -1
local capturedStatus = 0

-- Proposal-type headline. cc (1) names the subject; the others are bare. Keys
-- are LekMod's own proposal-screen summary strings.
local function proposalHeadline(id)
    local proposalType = Game.GetProposalType(id)
    if proposalType == 1 then
        local subjectId = Game.GetProposalSubject(id)
        local subject = subjectId ~= -1 and Players[subjectId]:GetName() or ""
        return Text.format("TXT_KEY_MP_PROPOSAL_SCREEN_SUMMARY_CC", subject)
    elseif proposalType == 0 then
        return Text.key("TXT_KEY_MP_PROPOSAL_SCREEN_SUMMARY_IRR")
    elseif proposalType == 2 then
        return Text.key("TXT_KEY_MP_PROPOSAL_SCREEN_SUMMARY_SCRAP")
    end
    return Text.key("TXT_KEY_MP_PROPOSAL_SCREEN_SUMMARY_REMAP")
end

-- A player's display name: the MP nickname when human and set, else the civ /
-- leader name. Shared by the pending-voter list and the per-player vote rows.
local function playerDisplayName(player)
    if player:IsHuman() and player:GetNickName() ~= "" then
        return player:GetNickName()
    end
    return player:GetName()
end

local function pendingVoterClause(id)
    local names = {}
    for i = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        local pVoter = Players[i]
        if pVoter ~= nil and pVoter:IsAlive() and pVoter:IsHuman() then
            if Game.GetProposalVoterEligibility(id, i) and not Game.GetProposalVoterHasVoted(id, i) then
                names[#names + 1] = playerDisplayName(pVoter)
            end
        end
    end
    if #names == 0 then
        return Text.key("TXT_KEY_LEKMOD_MP_PENDING_VOTES_NONE")
    end
    return Text.format("TXT_KEY_LEKMOD_MP_PENDING_VOTES", tostring(#names)) .. ": " .. table.concat(names, ", ")
end

local function buildPreamble()
    if capturedId < 0 then
        return Text.key("TXT_KEY_CIVVACCESS_SCREEN_PROPOSAL")
    end
    local id = capturedId
    local parts = { proposalHeadline(id) }

    local ownerId = Game.GetProposalOwner(id)
    if ownerId ~= nil and ownerId >= 0 and Players[ownerId] ~= nil then
        parts[#parts + 1] = Text.format("TXT_KEY_MP_PROPOSAL_SCREEN_STARTED_BY", Players[ownerId]:GetName())
    end

    -- Tally is a secret ballot except for the open remap vote (type 3), which
    -- shows per-player votes instead of running totals.
    if Game.GetProposalType(id) ~= 3 then
        local maxVotes = Game.GetMaxVotes(id)
        local received = Game.GetYesVotes(id) + Game.GetNoVotes(id)
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_PROPOSAL_TALLY", received, maxVotes, maxVotes - received)
    end

    parts[#parts + 1] = Text.format(
        "TXT_KEY_CIVVACCESS_PROPOSAL_EXPIRES",
        Game.GetElapsedGameTurns() + Game.GetProposalExpirationCounter(id) + 1
    )
    parts[#parts + 1] = pendingVoterClause(id)

    if capturedStatus == 1 then
        parts[#parts + 1] = Text.key("TXT_KEY_MP_PROPOSAL_SCREEN_PROPOSAL_PASSED")
    elseif capturedStatus == 2 then
        parts[#parts + 1] = Text.key("TXT_KEY_MP_PROPOSAL_SCREEN_PROPOSAL_FAILED")
    end
    return table.concat(parts, ". ")
end

-- One status word per voter, mirroring UpdatePlayerData: a revealed Yes / No
-- only for the open remap vote (or once resolved), otherwise voted / not yet
-- voted / not eligible.
local function voterStatus(id, playerId)
    if not Game.GetProposalVoterEligibility(id, playerId) then
        return Text.key("TXT_KEY_CIVVACCESS_PROPOSAL_NOT_ELIGIBLE")
    end
    if not Game.GetProposalVoterHasVoted(id, playerId) then
        return Text.key("TXT_KEY_CIVVACCESS_PROPOSAL_NOT_VOTED")
    end
    local revealed = Game.GetProposalType(id) == 3
        and (playerId == Game.GetActivePlayer() or Game.GetProposalStatus(id) ~= 0)
    if revealed then
        if Game.GetProposalVoterVote(id, playerId) then
            return Text.key("TXT_KEY_POSITIVE_VOTE_CHART_STATUS")
        end
        return Text.key("TXT_KEY_NEGATIVE_VOTE_CHART_STATUS")
    end
    return Text.key("TXT_KEY_CIVVACCESS_PROPOSAL_VOTED")
end

local function buildItems()
    local items = {}
    if capturedId < 0 then
        return items
    end
    local id = capturedId
    for i = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        local pPlayer = Players[i]
        if pPlayer ~= nil and pPlayer:IsAlive() and not pPlayer:IsObserver() then
            local name = playerDisplayName(pPlayer)
            items[#items + 1] = BaseMenuItems.Text({
                labelText = Text.format("TXT_KEY_CIVVACCESS_PROPOSAL_VOTER", name, voterStatus(id, i)),
            })
        end
    end

    -- Yes / No only while voting is open and the local player can still vote.
    local me = Game.GetActivePlayer()
    if
        capturedStatus == 0
        and Game.GetProposalVoterEligibility(id, me)
        and not Game.GetProposalVoterHasVoted(id, me)
    then
        items[#items + 1] = BaseMenuItems.Choice({
            labelText = Text.key("TXT_KEY_CIVVACCESS_PROPOSAL_VOTE_YES"),
            activate = function()
                Network.SendGiftUnit(id, -5)
                OnClose()
            end,
        })
        items[#items + 1] = BaseMenuItems.Choice({
            labelText = Text.key("TXT_KEY_CIVVACCESS_PROPOSAL_VOTE_NO"),
            activate = function()
                Network.SendGiftUnit(id, -6)
                OnClose()
            end,
        })
    end

    items[#items + 1] = BaseMenuItems.Button({
        controlName = "CloseButton",
        textKey = "TXT_KEY_CLOSE",
        activate = function()
            OnClose()
        end,
    })
    return items
end

-- Capture the proposal id / status off the popup event (runs alongside
-- LekMod's OnPopup). The handler's onShow then reads live state for it.
Events.SerialEventGameMessagePopup.Add(function(popupInfo)
    if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_MODDER_0 then
        return
    end
    capturedId = popupInfo.Data1
    capturedStatus = popupInfo.Data2 or 0
end)

BaseMenu.install(ContextPtr, {
    name = "ProposalChartPopup",
    displayName = Text.key("TXT_KEY_CIVVACCESS_SCREEN_PROPOSAL"),
    preamble = buildPreamble,
    priorInput = priorInput,
    priorShowHide = priorShowHide,
    onShow = function(handler)
        handler.setItems(buildItems())
    end,
    items = {},
})
