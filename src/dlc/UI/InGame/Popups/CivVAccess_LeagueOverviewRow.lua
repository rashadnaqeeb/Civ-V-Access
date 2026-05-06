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
    return Text.formatPlural("TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_DELEGATES", n, n)
end

LeagueOverviewRow._delegatesPhrase = delegatesPhrase

-- Per-member row label. Tags read in the order the plan documents:
-- (you), host, delegate count, can-propose marker. Diplomat-visiting and
-- ideology / knowledge clauses live inside the drill via
-- GetMemberKnowledgeDetails, not on the parent row. Trailing period is
-- appended here so the row is a complete spoken sentence.
--
-- Delegate count mirrors GetMemberDelegationDetails: starting votes outside
-- a session, remaining + spent during one. Lets the parent and the drill's
-- delegation line agree mid-session if a vote pool shifts.
function LeagueOverviewRow.formatMember(pLeague, member, activePlayer)
    local parts = { leaderOfCiv(member.playerID) }
    local tags = {}
    if member.playerID == activePlayer then
        tags[#tags + 1] = Text.key("TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_YOU")
    end
    if member.isHost then
        tags[#tags + 1] = Text.key("TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_HOST")
    end
    local votes
    if pLeague:IsInSession() then
        votes = pLeague:GetRemainingVotesForMember(member.playerID) + pLeague:GetSpentVotesForMember(member.playerID)
    else
        votes = pLeague:CalculateStartingVotesForMember(member.playerID)
    end
    tags[#tags + 1] = delegatesPhrase(votes)
    if pLeague:CanPropose(member.playerID) then
        tags[#tags + 1] = Text.key("TXT_KEY_CIVVACCESS_LEAGUE_MEMBER_CAN_PROPOSE")
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

-- formatProposal plus the engine's GetResolutionDetails appended via
-- appendTooltip / filterTooltip. Used by every Tab 2 proposal row (Vote /
-- View / on-hold) so the user hears what the resolution does without
-- having to drill anywhere; mirrors the View All / slot picker rows
-- which include the same details. proposal must carry Type / ID /
-- ProposerDecision (the snapshotProposal shape collectProposals returns).
function LeagueOverviewRow.formatProposalWithDetails(pLeague, proposal, activePlayer, voteState)
    local label = LeagueOverviewRow.formatProposal(pLeague, proposal, activePlayer, voteState)
    local detailsText = pLeague:GetResolutionDetails(
        proposal.Type,
        activePlayer,
        proposal.ID,
        proposal.ProposerDecision or kChoiceNone
    )
    return LeagueOverviewRow.appendTooltip(label, LeagueOverviewRow.formatResolutionDetails(detailsText))
end

-- Vote-state suffix for a yes/no resolution. Sign of `votes` carries the
-- direction (positive = Yea, negative = Nay, zero = abstain).
function LeagueOverviewRow.formatYesNoVoteState(votes)
    if votes == 0 then
        return Text.key("TXT_KEY_CIVVACCESS_LEAGUE_VOTE_ABSTAIN")
    end
    local n = math.abs(votes)
    if votes > 0 then
        return Text.formatPlural("TXT_KEY_CIVVACCESS_LEAGUE_VOTE_YEA", n, n)
    end
    return Text.formatPlural("TXT_KEY_CIVVACCESS_LEAGUE_VOTE_NAY", n, n)
end

-- Engine multi-line tooltips (GetMemberDetails / GetResolutionDetails /
-- GetCurrentEffectsSummary entries) use [NEWLINE] as a clause separator
-- without trailing punctuation on each clause, so TextFilter's plain-space
-- substitution produces runon speech ("1 from membership 2 from World
-- Wonders Their interests are largely a mystery"). Inject a period before
-- any [NEWLINE] whose preceding char isn't already terminal punctuation
-- (.!?:;,), then let TextFilter handle the rest. Only inject when there is
-- actual content after the [NEWLINE] so trailing newlines don't produce a
-- spurious sentence-ending period. Mirrors ChooseTechLogic.filterHelpText
-- which uses ", " for the same reason; tooltips here are sentence-shaped
-- so a period is the right separator.
function LeagueOverviewRow.filterTooltip(text)
    if text == nil then
        return ""
    end
    local s = tostring(text)
    s = s:gsub("([^%s%.%!%?%:%;%,])(%s*%[NEWLINE%]%s*)([%S])", "%1.%2%3")
    return TextFilter.filter(s)
end

-- Reshape the engine's GetResolutionDetails into screen-reader form:
-- engine emits "<description><opinion-section>" but the opinion (live
-- vote counts or pre-vote civ-leanings) is the actionable part of the
-- tooltip, while the description is reference text. Reorder to opinion-
-- first so the user hears their decision-driving counts before the help
-- prose, replace the engine's verbose opinion prefaces with terser mod
-- ones, and on the vote-counts flow drop the redundant "Our Civilization
-- controls X Delegates" tail (the user already knows their own count
-- from the Status tab).
--
-- Locale strategy: the three opinion sections always begin with one of
-- TXT_KEY_LEAGUE_OVERVIEW_VOTE_OPINIONS / PROPOSAL_OPINIONS_POSITIVE /
-- PROPOSAL_OPINIONS_NEGATIVE. We look up each in the active locale and
-- find them as plain substrings in the engine output. Description
-- bodies (resolution help text) can contain "[NEWLINE][NEWLINE]" so we
-- cannot just split on that token; matching the localized full preface
-- is precise.
--
-- Bullet processing: the vote-opinions section keeps the engine's per-
-- bullet text (each bullet has rich content like "Nay: 46 Delegates
-- (5 Civs)") and just drops the OURS bullet, which the engine always
-- appends last. The propose-opinion sections collapse the per-civ bullets
-- (each bullet is just a civ name) into a comma-joined list since
-- "Germany. France. Egypt" reads as three sentences while the same names
-- in a comma list read as a list.
function LeagueOverviewRow.formatResolutionDetails(rawText)
    if rawText == nil then
        return ""
    end
    local s = tostring(rawText)
    if s == "" then
        return ""
    end

    local voteMarker = Text.key("TXT_KEY_LEAGUE_OVERVIEW_VOTE_OPINIONS")
    local posMarker = Text.key("TXT_KEY_LEAGUE_OVERVIEW_PROPOSAL_OPINIONS_POSITIVE")
    local negMarker = Text.key("TXT_KEY_LEAGUE_OVERVIEW_PROPOSAL_OPINIONS_NEGATIVE")

    local function findPlain(haystack, needle)
        if needle == nil or needle == "" then
            return nil
        end
        return haystack:find(needle, 1, true)
    end

    local votePos = findPlain(s, voteMarker)
    local posPos = findPlain(s, posMarker)
    local negPos = findPlain(s, negMarker)

    -- Pick earliest non-nil position. Cannot use ipairs on a sparse table
    -- (it stops at the first nil), so check each candidate explicitly.
    local earliest
    local function tightest(p)
        if p ~= nil and (earliest == nil or p < earliest) then
            earliest = p
        end
    end
    tightest(votePos)
    tightest(posPos)
    tightest(negPos)

    if earliest == nil then
        return LeagueOverviewRow.filterTooltip(s)
    end

    local description = s:sub(1, earliest - 1)

    -- Extract bulleted civ names from a section, stopping at the next
    -- section marker (positive can be followed by negative).
    local function sliceSection(startPos, markerLen, endPos)
        if endPos ~= nil then
            return s:sub(startPos + markerLen, endPos - 1)
        end
        return s:sub(startPos + markerLen)
    end

    -- Pluck raw bullet bodies from a section. Each bullet starts with
    -- "[NEWLINE][ICON_BULLET]" and runs until the next "[NEWLINE]" or
    -- end-of-string; bullet bodies can contain other markup tags ([COLOR_*],
    -- icons) so we can't terminate on a bare "[".
    local function bulletsOf(section)
        local out = {}
        local pos = 1
        while true do
            local _, headEnd = section:find("%[NEWLINE%]%[ICON_BULLET%]", pos)
            if headEnd == nil then
                break
            end
            local nextStart = section:find("%[NEWLINE%]", headEnd + 1)
            local body
            if nextStart == nil then
                body = section:sub(headEnd + 1)
            else
                body = section:sub(headEnd + 1, nextStart - 1)
            end
            out[#out + 1] = body
            pos = headEnd + 1
        end
        return out
    end

    local opinionParts = {}

    if votePos ~= nil then
        local section = sliceSection(votePos, #voteMarker, nil)
        local bullets = bulletsOf(section)
        if #bullets > 0 then
            -- Drop the OURS bullet (always last in vote-opinions; engine
            -- ordering at CvVotingClasses.cpp:4360-4367 is fixed and the
            -- mod doesn't take upstream engine updates).
            bullets[#bullets] = nil
        end
        if #bullets > 0 then
            local cleaned = {}
            for _, b in ipairs(bullets) do
                local f = TextFilter.filter(b)
                if f ~= "" then
                    cleaned[#cleaned + 1] = f
                end
            end
            if #cleaned > 0 then
                opinionParts[#opinionParts + 1] = Text.key("TXT_KEY_CIVVACCESS_LEAGUE_VOTE_COUNTS_PREFACE")
                    .. " "
                    .. table.concat(cleaned, ". ")
            end
        end
    end

    local function formatCivList(startPos, markerLen, endPos, prefaceKey)
        local section = sliceSection(startPos, markerLen, endPos)
        local civs = {}
        for _, b in ipairs(bulletsOf(section)) do
            local f = TextFilter.filter(b)
            if f ~= "" then
                civs[#civs + 1] = f
            end
        end
        if #civs == 0 then
            return nil
        end
        return Text.format(prefaceKey, table.concat(civs, ", "))
    end

    if posPos ~= nil then
        local part = formatCivList(posPos, #posMarker, negPos, "TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_GRATEFUL_LIST")
        if part ~= nil then
            opinionParts[#opinionParts + 1] = part
        end
    end
    if negPos ~= nil then
        local part = formatCivList(negPos, #negMarker, nil, "TXT_KEY_CIVVACCESS_LEAGUE_PROPOSE_ANGRY_LIST")
        if part ~= nil then
            opinionParts[#opinionParts + 1] = part
        end
    end

    local out = {}
    for _, p in ipairs(opinionParts) do
        if p ~= "" then
            out[#out + 1] = p
        end
    end
    local descFiltered = LeagueOverviewRow.filterTooltip(description)
    if descFiltered ~= "" then
        out[#out + 1] = descFiltered
    end
    return table.concat(out, ". ")
end

-- Reshape GetMemberDelegationDetails for the drilled delegation sub-line.
-- The engine output is the TXT_KEY_LEAGUE_OVERVIEW_MEMBER_DETAILS header
-- ("X of Y commands a total of N Delegates. Once in session ...") followed
-- by sVoteSources, a series of [NEWLINE][ICON_BULLET]<count> <source> lines
-- (TXT_KEY_LEAGUE_OVERVIEW_MEMBER_DETAILS_*_VOTES). The header duplicates
-- what the parent row already speaks, and bare counts ("4 from membership")
-- on their own read as anonymous numbers, so:
--   1. Drop everything before the first [NEWLINE][ICON_BULLET] (the header).
--   2. Inject "Delegates" between the first bullet's count and the source
--      phrase so the line reads "4 Delegates from membership"; later
--      bullets stay bare ("2 from previous ...") with context established.
-- The bullet marker pattern is locale-stable across the engine's source
-- strings; the "Delegates" injection is English-only and the translation
-- pipeline reshapes locale-specific phrasing. Empty-bullets case (member
-- with zero delegates) returns "" so buildMemberDrillItems skips this
-- section -- the parent row already states "0 delegates".
function LeagueOverviewRow.formatDelegationBreakdown(rawText)
    if rawText == nil then
        return ""
    end
    local s = tostring(rawText)
    local cutStart = s:find("[NEWLINE][ICON_BULLET]", 1, true)
    if cutStart == nil then
        return ""
    end
    s = s:sub(cutStart)
    s = s:gsub("^(%[NEWLINE%]%[ICON_BULLET%])(%d+) ", "%1%2 Delegates ", 1)
    return LeagueOverviewRow.filterTooltip(s)
end

-- Concatenate a row's lead label and an appended tooltip into one spoken
-- sentence. Used by every row that would otherwise be a Group with a single
-- Text child: the inner Text is dropped and its body becomes part of the
-- row label, so the user navigates to the row and hears the full content
-- without an extra drill-in. Empty / nil tooltip returns the label as-is.
-- If the label already ends in terminal punctuation (.!?:;,) the join is a
-- single space; otherwise insert ". " so the two clauses read as separate
-- sentences.
function LeagueOverviewRow.appendTooltip(label, tooltip)
    if tooltip == nil or tooltip == "" then
        return label
    end
    if label:match("[%.%!%?%:%;%,]%s*$") then
        return label .. " " .. tooltip
    end
    return label .. ". " .. tooltip
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
    return Text.format("TXT_KEY_CIVVACCESS_LEAGUE_VOTE_FOR_CIV", votes, civLabel)
end

return LeagueOverviewRow
