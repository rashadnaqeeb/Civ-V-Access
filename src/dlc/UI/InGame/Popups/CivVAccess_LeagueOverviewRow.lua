-- Pure row formatters for the League Overview screen. No module state, no
-- caching of engine values; every call re-queries live league / player /
-- proposal data. Consumed by CivVAccess_LeagueOverviewAccess (status pill,
-- member rows, effects rows), CivVAccess_LeagueOverviewVote (proposal-row
-- announce in Vote mode), CivVAccess_LeagueOverviewProposal (slot picker
-- candidate rows). The formatters return strings ready for SpeechPipeline;
-- callers do not need to filter markup -- the pipeline runs TextFilter on
-- speak. Functions that compose multiple keys join with ", " for in-row
-- comma lists and ". " for sentence boundaries; trailing periods are added
-- by the row-builder, not by the formatter.

LeagueOverviewRow = {}

local kChoiceNone = -1

-- Resolve a major-civ player's "Leader of Civ" label from the engine's
-- localized name keys. League members are always alive major civs (engine
-- enforces in GetLeagueMembers); the call sites guarantee pPlayer is non-nil
-- so we do not nil-check.
local function leaderOfCiv(playerID)
    local pPlayer = Players[playerID]
    local leaderInfo = GameInfo.Leaders[pPlayer:GetLeaderType()]
    local civInfo = GameInfo.Civilizations[pPlayer:GetCivilizationType()]
    return Text.format(
        "TXT_KEY_CIVVACCESS_DIPLO_LEADER_OF_CIV",
        Text.key(leaderInfo.Description),
        Text.key(civInfo.Description)
    )
end

LeagueOverviewRow.leaderOfCiv = leaderOfCiv

function LeagueOverviewRow.leagueName(pLeague)
    return tostring(pLeague:GetName())
end

-- Status pill: turns-until-session / IN SESSION / SPECIAL SESSION clause,
-- with the UN-only "next World Leader proposal" + "votes needed" tail when
-- a Diplomatic victory is enabled and the UN is active. Engine assembles the
-- same pieces in Update() lines 159-198; the strings here are reused
-- verbatim so localisation tracks the engine.
function LeagueOverviewRow.formatStatusPill(pLeague)
    local clauses = {}
    if not pLeague:IsInSession() then
        clauses[#clauses + 1] =
            Text.format("TXT_KEY_LEAGUE_OVERVIEW_TURNS_UNTIL_SESSION", math.max(pLeague:GetTurnsUntilSession(), 0))
    elseif pLeague:IsInSpecialSession() then
        clauses[#clauses + 1] = Text.key("TXT_KEY_LEAGUE_OVERVIEW_IN_SPECIAL_SESSION")
    else
        clauses[#clauses + 1] = Text.key("TXT_KEY_LEAGUE_OVERVIEW_IN_SESSION")
    end
    if Game.IsUnitedNationsActive() and PreGame.IsVictory(GameInfo.Victories["VICTORY_DIPLOMATIC"].ID) then
        clauses[#clauses + 1] =
            Text.format("TXT_KEY_LEAGUE_OVERVIEW_WORLD_LEADER_INFO_SESSION", pLeague:GetTurnsUntilVictorySession())
        clauses[#clauses + 1] =
            Text.format("TXT_KEY_LEAGUE_OVERVIEW_WORLD_LEADER_INFO_VOTES", Game.GetVotesNeededForDiploVictory())
    end
    return table.concat(clauses, ". ")
end

-- Order league members host-first, then by delegate count descending,
-- tiebreak by ascending player ID. Engine ships them in raw player ID order
-- (no vote sort); we sort by votes desc so the most influential civs read
-- first, then mirror the engine's player-ID tiebreak. CalculateStartingVotes
-- matches the in-session "remaining + spent" sum (both equal session budget),
-- so the ordering is stable across mode transitions inside a session.
function LeagueOverviewRow.orderedMembers(pLeague)
    local hostId = pLeague:GetHostMember()
    local members = {}
    for iPlayer = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        local pPlayer = Players[iPlayer]
        if pPlayer ~= nil and pPlayer:IsAlive() and not pPlayer:IsMinorCiv() and pLeague:IsMember(iPlayer) then
            members[#members + 1] = {
                playerID = iPlayer,
                isHost = (iPlayer == hostId),
                votes = pLeague:CalculateStartingVotesForMember(iPlayer),
            }
        end
    end
    table.sort(members, function(a, b)
        if a.isHost ~= b.isHost then
            return a.isHost
        end
        if a.votes ~= b.votes then
            return a.votes > b.votes
        end
        return a.playerID < b.playerID
    end)
    return members
end

local function delegatesPhrase(n)
    if n == 1 then
        return Text.key("TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_DELEGATE_ONE")
    end
    return Text.format("TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_DELEGATES", n)
end

LeagueOverviewRow._delegatesPhrase = delegatesPhrase

-- Per-member row label. Tags read in the order the plan documents:
-- (you), host, delegate count, can-propose marker, diplomat-visiting marker.
-- Trailing period is appended here so the row is a complete spoken sentence.
function LeagueOverviewRow.formatMember(pLeague, member, activePlayer)
    local parts = { leaderOfCiv(member.playerID) }
    local tags = {}
    if member.playerID == activePlayer then
        tags[#tags + 1] = Text.key("TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_YOU")
    end
    if member.isHost then
        tags[#tags + 1] = Text.key("TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_HOST")
    end
    tags[#tags + 1] = delegatesPhrase(member.votes)
    if pLeague:CanPropose(member.playerID) then
        tags[#tags + 1] = Text.key("TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_CAN_PROPOSE")
    end
    if member.playerID ~= activePlayer then
        local pActive = Players[activePlayer]
        if pActive ~= nil and pActive:IsMyDiplomatVisitingThem(member.playerID) then
            tags[#tags + 1] = Text.key("TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_DIPLOMAT_VISITING")
        end
    end
    parts[#parts + 1] = table.concat(tags, ", ")
    return table.concat(parts, ", ") .. "."
end

-- Direction prefix + resolution name. proposerDecision is the kChoiceNone
-- (-1) sentinel for resolutions with no sub-decision; engine accepts that
-- value in GetResolutionName. resolutionId is -1 for inactive (catalog)
-- resolutions and the live instance ID for proposed / active ones.
function LeagueOverviewRow.formatResolutionName(pLeague, resolutionType, resolutionId, proposerDecision, direction)
    local name = pLeague:GetResolutionName(resolutionType, resolutionId, proposerDecision or kChoiceNone, false)
    if direction == "Retract" then
        return Text.format("TXT_KEY_CIVVACCESS_LEAGUE_REPEAL_PREFIX", name)
    end
    return Text.format("TXT_KEY_CIVVACCESS_LEAGUE_ENACT_PREFIX", name)
end

local function proposerClause(playerID, activePlayer)
    if playerID == nil or playerID == -1 then
        return nil
    end
    if playerID == activePlayer then
        return Text.key("TXT_KEY_CIVVACCESS_LEAGUE_PROPOSED_BY_YOU")
    end
    return Text.format("TXT_KEY_CIVVACCESS_LEAGUE_PROPOSED_BY_CIV", leaderOfCiv(playerID))
end

LeagueOverviewRow.proposerClause = proposerClause

-- Render a current-session proposal row. voteState is the spoken vote-state
-- string (see formatVoteState) when the screen is in Vote mode and this row
-- is votable; nil in View / Propose modes and for on-hold proposals (engine
-- hides the vote control on those). Trailing period is part of the row
-- sentence; the on-hold and vote-state clauses each get their own period.
function LeagueOverviewRow.formatProposal(pLeague, proposal, activePlayer, voteState)
    local clauses = {
        LeagueOverviewRow.formatResolutionName(
            pLeague,
            proposal.Type or proposal.ResolutionType,
            proposal.ID,
            proposal.ProposerDecision or proposal.ProposerChoice,
            proposal.Direction
        ),
    }
    local proposer = proposerClause(proposal.ProposalPlayer, activePlayer)
    if proposer ~= nil then
        clauses[#clauses + 1] = proposer
    end
    if proposal.OnHold then
        clauses[#clauses + 1] = Text.key("TXT_KEY_CIVVACCESS_LEAGUE_ON_HOLD")
    end
    local row = table.concat(clauses, ". ") .. "."
    if voteState ~= nil and voteState ~= "" then
        row = row .. " " .. Text.format("TXT_KEY_CIVVACCESS_LEAGUE_VOTE_STATE_LABEL", voteState) .. "."
    end
    return row
end

-- Vote-state suffix for a yes/no resolution. Sign of `votes` carries the
-- direction (positive = Yea, negative = Nay, zero = abstain).
function LeagueOverviewRow.formatYesNoVoteState(votes)
    if votes == 0 then
        return Text.key("TXT_KEY_CIVVACCESS_LEAGUE_VOTE_ABSTAIN")
    end
    local n = math.abs(votes)
    if votes > 0 then
        if n == 1 then
            return Text.key("TXT_KEY_CIVVACCESS_LEAGUE_VOTE_YEA_ONE")
        end
        return Text.format("TXT_KEY_CIVVACCESS_LEAGUE_VOTE_YEA", n)
    end
    if n == 1 then
        return Text.key("TXT_KEY_CIVVACCESS_LEAGUE_VOTE_NAY_ONE")
    end
    return Text.format("TXT_KEY_CIVVACCESS_LEAGUE_VOTE_NAY", n)
end

-- Vote-state suffix for a major-civ resolution. choicePlayerID is nil when
-- no civ has been picked yet (the engine's VoteUp click opens the picker;
-- our equivalent is Enter on the row). votes >= 0 here -- major-civ votes
-- never go negative.
function LeagueOverviewRow.formatMajorCivVoteState(votes, choicePlayerID)
    if votes == 0 or choicePlayerID == nil then
        return Text.key("TXT_KEY_CIVVACCESS_LEAGUE_VOTE_ABSTAIN")
    end
    local civLabel = leaderOfCiv(choicePlayerID)
    if votes == 1 then
        return Text.format("TXT_KEY_CIVVACCESS_LEAGUE_VOTE_FOR_CIV_ONE", civLabel)
    end
    return Text.format("TXT_KEY_CIVVACCESS_LEAGUE_VOTE_FOR_CIV", votes, civLabel)
end

return LeagueOverviewRow
