-- Row formatter tests for the League Overview screen. Covers status pill
-- (pre-session / in-session / special / UN-Diplomatic suffix), member-row
-- ordering and tag composition, vote-state suffixes (yes/no signed and
-- major-civ choice), proposal-row composition (proposer clause, on-hold
-- marker, Vote-mode vote-state appendage), and resolution-name direction
-- prefixes. Pure functions — no menu / handler stack involvement.

local T = require("support")
local M = {}

local origPlayers, origGameInfo, origGameDefines, origGame, origPreGame, origConvertTextKey

-- Engine TXT_KEY -> source-string mapping for the keys this suite touches.
-- The production code paths read these via Text.key / Text.format, which for
-- non-CivVAccess keys defers to Locale.ConvertTextKey. The harness's default
-- ConvertTextKey treats the key string itself as the source (no real text
-- DB), so engine-key payloads vanish unless we plug them in. Strings copied
-- verbatim from CIV5GameTextInfos_Leagues_Expansion2.xml.
local ENGINE_STRINGS = {
    TXT_KEY_LEAGUE_OVERVIEW_TURNS_UNTIL_SESSION = "Turns Until Session: {1_Num}",
    TXT_KEY_LEAGUE_OVERVIEW_IN_SESSION = "IN SESSION",
    TXT_KEY_LEAGUE_OVERVIEW_IN_SPECIAL_SESSION = "[COLOR_POSITIVE_TEXT]SPECIAL SESSION[ENDCOLOR]",
    TXT_KEY_LEAGUE_OVERVIEW_WORLD_LEADER_INFO_SESSION = "Turns until next World Leader proposal: {1_Num}",
    TXT_KEY_LEAGUE_OVERVIEW_WORLD_LEADER_INFO_VOTES = "Delegates to win World Leader proposal: {1_Num}",
}

-- Fake league handle. Behaviors are stubbed per-test via the opts table:
-- inSession, specialSession, turnsUntilSession, hostId, members map
-- (playerID -> {votes, canPropose, isAlive=true, isMinorCiv=false}),
-- diplomatVisitors set (playerID -> bool), turnsUntilVictorySession.
local function fakeLeague(opts)
    opts = opts or {}
    local league = {
        _name = opts.name or "World Congress",
        _inSession = opts.inSession or false,
        _specialSession = opts.specialSession or false,
        _turnsUntilSession = opts.turnsUntilSession or 5,
        _hostId = opts.hostId,
        _members = opts.members or {},
        _turnsUntilVictorySession = opts.turnsUntilVictorySession or 0,
    }
    function league:GetName()
        return self._name
    end
    function league:IsInSession()
        return self._inSession
    end
    function league:IsInSpecialSession()
        return self._specialSession
    end
    function league:GetTurnsUntilSession()
        return self._turnsUntilSession
    end
    function league:GetTurnsUntilVictorySession()
        return self._turnsUntilVictorySession
    end
    function league:GetHostMember()
        return self._hostId
    end
    function league:IsMember(pid)
        return self._members[pid] ~= nil
    end
    function league:CalculateStartingVotesForMember(pid)
        return (self._members[pid] or {}).votes or 0
    end
    -- formatMember reads these when IsInSession() is true; default to 0 so
    -- in-session tests that don't care about live tallies don't crash. Tests
    -- that exercise the in-session vote display patch them per-instance.
    function league:GetRemainingVotesForMember(_pid)
        return 0
    end
    function league:GetSpentVotesForMember(_pid)
        return 0
    end
    function league:CanPropose(pid)
        return (self._members[pid] or {}).canPropose or false
    end
    function league:GetResolutionName(rType, rId, choice, _flag)
        return "Resolution-" .. tostring(rType) .. "-" .. tostring(rId) .. "-" .. tostring(choice)
    end
    return league
end

local function setup(opts)
    opts = opts or {}
    origPlayers = Players
    origGameInfo = GameInfo
    origGameDefines = GameDefines
    origGame = Game
    origPreGame = PreGame

    -- Active player + a couple of major civs. Each player is keyed by ID;
    -- GetCivilizationType / GetLeaderType return string keys that GameInfo
    -- looks up.
    Players = {}
    local function mkPlayer(id, leaderKey, civKey, isMinor, diplomatVisitors)
        local p = {
            _id = id,
            _leader = leaderKey,
            _civ = civKey,
            _isMinor = isMinor or false,
            _diplomatVisitors = diplomatVisitors or {},
            _alive = true,
        }
        function p:IsAlive()
            return self._alive
        end
        function p:IsMinorCiv()
            return self._isMinor
        end
        function p:GetLeaderType()
            return self._leader
        end
        function p:GetCivilizationType()
            return self._civ
        end
        function p:IsMyDiplomatVisitingThem(target)
            return self._diplomatVisitors[target] or false
        end
        Players[id] = p
        return p
    end
    mkPlayer(0, "LEADER_AUGUSTUS", "CIVILIZATION_ROME", false, opts.activeDiplomatsAt or {})
    mkPlayer(1, "LEADER_BISMARCK", "CIVILIZATION_GERMANY")
    mkPlayer(2, "LEADER_GENGHIS", "CIVILIZATION_MONGOL")
    mkPlayer(3, "LEADER_PACHACUTI", "CIVILIZATION_INCA")

    GameInfo = {
        Leaders = {
            LEADER_AUGUSTUS = { Description = "TXT_KEY_LEADER_AUGUSTUS" },
            LEADER_BISMARCK = { Description = "TXT_KEY_LEADER_BISMARCK" },
            LEADER_GENGHIS = { Description = "TXT_KEY_LEADER_GENGHIS" },
            LEADER_PACHACUTI = { Description = "TXT_KEY_LEADER_PACHACUTI" },
        },
        Civilizations = {
            CIVILIZATION_ROME = { Description = "TXT_KEY_CIV_ROME" },
            CIVILIZATION_GERMANY = { Description = "TXT_KEY_CIV_GERMANY" },
            CIVILIZATION_MONGOL = { Description = "TXT_KEY_CIV_MONGOL" },
            CIVILIZATION_INCA = { Description = "TXT_KEY_CIV_INCA" },
        },
        Victories = {
            VICTORY_DIPLOMATIC = { ID = 3 },
        },
    }
    GameDefines = GameDefines or {}
    GameDefines.MAX_MAJOR_CIVS = 22

    Game = Game or {}
    Game.IsUnitedNationsActive = function()
        return opts.unActive or false
    end
    Game.GetVotesNeededForDiploVictory = function()
        return opts.votesForVictory or 0
    end
    PreGame = PreGame or {}
    PreGame.IsVictory = function(id)
        if opts.diploVictoryEnabled and id == 3 then
            return true
        end
        return false
    end

    -- Override Locale.ConvertTextKey so engine TXT_KEY lookups resolve
    -- against ENGINE_STRINGS first, then run the harness's positional
    -- substituter against the resolved source. Leader / civ keys not in
    -- ENGINE_STRINGS pass straight through unchanged so substring asserts
    -- on the literal key name still work.
    origConvertTextKey = Locale.ConvertTextKey
    T.installLocaleStrings(ENGINE_STRINGS)

    dofile("src/dlc/UI/Shared/CivVAccess_TextFilter.lua")
    dofile("src/dlc/UI/Shared/CivVAccess_Text.lua")
    dofile("src/dlc/UI/InGame/Popups/CivVAccess_LeagueOverviewRow.lua")
end

local function teardown()
    Players = origPlayers
    GameInfo = origGameInfo
    GameDefines = origGameDefines
    Game = origGame
    PreGame = origPreGame
    Locale.ConvertTextKey = origConvertTextKey
end

-- ===== Status pill ======================================================

function M.test_status_pill_pre_session_speaks_turns_until_session()
    setup()
    local league = fakeLeague({ turnsUntilSession = 7 })
    local pill = LeagueOverviewRow.formatStatusPill(league)
    T.truthy(pill:find("7", 1, true), "pill should include the 7 turns; got: " .. pill)
    teardown()
end

function M.test_status_pill_in_session_normal()
    setup()
    local league = fakeLeague({ inSession = true })
    local pill = LeagueOverviewRow.formatStatusPill(league)
    T.truthy(pill:find("IN SESSION", 1, true), "pill: " .. pill)
    teardown()
end

function M.test_status_pill_in_special_session_strips_to_label()
    setup()
    local league = fakeLeague({ inSession = true, specialSession = true })
    local pill = LeagueOverviewRow.formatStatusPill(league)
    -- engine key carries [COLOR_*] markup; markup-strip happens at speak time
    -- via the speech pipeline, so the raw formatter output may still contain
    -- the markup. We just verify the literal payload made it through.
    T.truthy(pill:find("SPECIAL SESSION", 1, true), "pill: " .. pill)
    teardown()
end

function M.test_status_pill_negative_turns_clamps_to_zero()
    setup()
    -- Engine clamps GetTurnsUntilSession with math.max(..., 0); we mirror.
    local league = fakeLeague({ turnsUntilSession = -3 })
    local pill = LeagueOverviewRow.formatStatusPill(league)
    T.truthy(pill:find("0", 1, true), "negative-turns input should clamp to 0; pill: " .. pill)
    teardown()
end

function M.test_status_pill_un_active_without_diplo_victory_no_world_leader_suffix()
    setup({ unActive = true, diploVictoryEnabled = false })
    local league = fakeLeague({ inSession = true })
    local pill = LeagueOverviewRow.formatStatusPill(league)
    T.falsy(
        pill:find("WORLD_LEADER", 1, true) or pill:find("World Leader", 1, true),
        "no world-leader clause without a Diplomatic victory: " .. pill
    )
    teardown()
end

function M.test_status_pill_un_active_with_diplo_victory_appends_world_leader_clauses()
    setup({ unActive = true, diploVictoryEnabled = true, votesForVictory = 12 })
    local league = fakeLeague({ inSession = true, turnsUntilVictorySession = 9 })
    local pill = LeagueOverviewRow.formatStatusPill(league)
    -- engine WORLD_LEADER_INFO_* keys substitute the numeric turns / votes
    -- via {1_Num}; positional replacement should put 9 and 12 into the pill.
    T.truthy(pill:find("9", 1, true), "should include turns until victory session: " .. pill)
    T.truthy(pill:find("12", 1, true), "should include votes needed for victory: " .. pill)
    teardown()
end

-- ===== orderedMembers ===================================================

function M.test_ordered_members_host_first_then_votes_desc_then_id_asc()
    setup()
    local league = fakeLeague({
        hostId = 1,
        members = {
            [0] = { votes = 5 },
            [1] = { votes = 3 }, -- host (lowest votes; goes first regardless)
            [2] = { votes = 5 }, -- ties player 0 on votes; ID asc tiebreak
            [3] = { votes = 7 },
        },
    })
    local ordered = LeagueOverviewRow.orderedMembers(league)
    T.eq(#ordered, 4)
    T.eq(ordered[1].playerID, 1, "host first")
    T.eq(ordered[2].playerID, 3, "highest votes (7) next")
    T.eq(ordered[3].playerID, 0, "tie at 5 votes, lower ID first")
    T.eq(ordered[4].playerID, 2, "tie at 5 votes, higher ID later")
    teardown()
end

function M.test_ordered_members_filters_dead_minor_and_non_members()
    setup()
    -- Player 2 is a minor civ; player 3 is not a member.
    Players[2]._isMinor = true
    local league = fakeLeague({
        hostId = 0,
        members = {
            [0] = { votes = 5 },
            [1] = { votes = 3 },
            [2] = { votes = 4 }, -- minor; should not appear
            -- player 3 not in members
        },
    })
    local ordered = LeagueOverviewRow.orderedMembers(league)
    T.eq(#ordered, 2)
    T.eq(ordered[1].playerID, 0)
    T.eq(ordered[2].playerID, 1)
    teardown()
end

-- ===== Member row =======================================================

function M.test_member_row_includes_leader_civ_and_delegates()
    setup()
    local league = fakeLeague({
        hostId = 0,
        members = { [1] = { votes = 5, canPropose = false } },
    })
    local member = LeagueOverviewRow.orderedMembers(league)[1]
    local row = LeagueOverviewRow.formatMember(league, member, 0)
    T.truthy(row:find("BISMARCK", 1, true), "row should contain leader key: " .. row)
    T.truthy(row:find("GERMANY", 1, true), "row should contain civ key: " .. row)
    T.truthy(row:find("5 delegates", 1, true), "row should pluralize delegates: " .. row)
    T.truthy(row:sub(-1) == ".", "row should end with a period: " .. row)
    teardown()
end

function M.test_member_row_singular_delegate_phrase()
    setup()
    local league = fakeLeague({
        hostId = 0,
        members = { [1] = { votes = 1 } },
    })
    local member = LeagueOverviewRow.orderedMembers(league)[1]
    local row = LeagueOverviewRow.formatMember(league, member, 0)
    T.truthy(row:find("1 delegate", 1, true), "should singularize: " .. row)
    T.falsy(row:find("1 delegates", 1, true), "should not say '1 delegates': " .. row)
    teardown()
end

function M.test_member_row_self_marker_for_active_player()
    setup()
    local league = fakeLeague({
        hostId = 1,
        members = { [0] = { votes = 5 } },
    })
    local member = LeagueOverviewRow.orderedMembers(league)[1]
    local row = LeagueOverviewRow.formatMember(league, member, 0)
    T.truthy(row:find("(you)", 1, true), "row should mark active player: " .. row)
    teardown()
end

function M.test_member_row_host_marker_even_when_first_in_sort()
    setup()
    local league = fakeLeague({
        hostId = 1,
        members = { [1] = { votes = 5 } },
    })
    local member = LeagueOverviewRow.orderedMembers(league)[1]
    T.truthy(member.isHost)
    local row = LeagueOverviewRow.formatMember(league, member, 0)
    T.truthy(row:find("host", 1, true), "host marker present even for first row: " .. row)
    teardown()
end

function M.test_member_row_can_propose_marker()
    setup()
    local league = fakeLeague({
        hostId = 0,
        members = { [1] = { votes = 5, canPropose = true } },
    })
    local member = LeagueOverviewRow.orderedMembers(league)[1]
    local row = LeagueOverviewRow.formatMember(league, member, 0)
    T.truthy(row:find("can propose", 1, true), "should mark propose-eligible: " .. row)
    teardown()
end

-- During a session the engine's first delegation sub-line shows
-- remaining + spent rather than the precomputed starting total. The parent
-- row should track that so the two read consistent numbers when a vote pool
-- shifts mid-session.
function M.test_member_row_uses_remaining_plus_spent_when_in_session()
    setup()
    local league = fakeLeague({
        hostId = 0,
        inSession = true,
        members = { [1] = { votes = 99 } }, -- starting count; should be ignored in session
    })
    function league:GetRemainingVotesForMember(_pid)
        return 4
    end
    function league:GetSpentVotesForMember(_pid)
        return 3
    end
    local member = LeagueOverviewRow.orderedMembers(league)[1]
    local row = LeagueOverviewRow.formatMember(league, member, 0)
    T.truthy(row:find("7 delegates", 1, true), "in-session row should sum remaining+spent: " .. row)
    T.falsy(row:find("99", 1, true), "starting count should not appear: " .. row)
    teardown()
end

-- ===== Vote-state formatters =============================================

function M.test_yes_no_vote_state_abstain_at_zero()
    setup()
    local s = LeagueOverviewRow.formatYesNoVoteState(0)
    T.eq(s, "abstain")
    teardown()
end

function M.test_yes_no_vote_state_singular_yea_and_nay()
    setup()
    T.eq(LeagueOverviewRow.formatYesNoVoteState(1), "1 Yea")
    T.eq(LeagueOverviewRow.formatYesNoVoteState(-1), "1 Nay")
    teardown()
end

function M.test_yes_no_vote_state_plural_yea_and_nay()
    setup()
    T.eq(LeagueOverviewRow.formatYesNoVoteState(3), "3 Yea")
    T.eq(LeagueOverviewRow.formatYesNoVoteState(-2), "2 Nay")
    teardown()
end

function M.test_major_civ_vote_state_abstain_when_no_choice()
    setup()
    -- 3 votes assigned but no civ picked yet (transient state during picker open)
    local s = LeagueOverviewRow.formatMajorCivVoteState(3, nil)
    T.eq(s, "abstain")
    teardown()
end

function M.test_major_civ_vote_state_abstain_when_zero_with_choice()
    setup()
    local s = LeagueOverviewRow.formatMajorCivVoteState(0, 1)
    T.eq(s, "abstain")
    teardown()
end

function M.test_major_civ_vote_state_singular_for_one_vote()
    setup()
    local s = LeagueOverviewRow.formatMajorCivVoteState(1, 1)
    T.truthy(s:find("1 for", 1, true), "should say '1 for ...': " .. s)
    T.truthy(s:find("BISMARCK", 1, true), "should include leader key: " .. s)
    T.truthy(s:find("GERMANY", 1, true), "should include civ key: " .. s)
    teardown()
end

function M.test_major_civ_vote_state_plural_for_multi_votes()
    setup()
    local s = LeagueOverviewRow.formatMajorCivVoteState(3, 2)
    T.truthy(s:find("3 for", 1, true), "should say '3 for ...': " .. s)
    T.truthy(s:find("MONGOL", 1, true), "should reference civ 2: " .. s)
    teardown()
end

-- ===== Resolution name + proposal row ====================================

function M.test_resolution_name_enact_prefix()
    setup()
    local league = fakeLeague()
    local s = LeagueOverviewRow.formatResolutionName(league, "RES_X", -1, -1, "Enact")
    T.truthy(s:find("Enact:", 1, true), "should prepend Enact direction: " .. s)
    teardown()
end

function M.test_resolution_name_repeal_prefix()
    setup()
    local league = fakeLeague()
    local s = LeagueOverviewRow.formatResolutionName(league, "RES_X", 42, -1, "Retract")
    T.truthy(s:find("Repeal:", 1, true), "should prepend Repeal direction: " .. s)
    teardown()
end

function M.test_proposal_row_includes_proposer_clause_for_other_civ()
    setup()
    local league = fakeLeague()
    local proposal = {
        Type = "RES_EMBARGO",
        ID = 7,
        ProposerDecision = -1,
        Direction = "Enact",
        ProposalPlayer = 1, -- Bismarck of Germany
        OnHold = false,
    }
    local row = LeagueOverviewRow.formatProposal(league, proposal, 0)
    T.truthy(row:find("Proposed by", 1, true), "should include proposer clause: " .. row)
    T.truthy(row:find("BISMARCK", 1, true), "should name the proposing leader: " .. row)
    teardown()
end

function M.test_proposal_row_includes_you_clause_for_self_proposed()
    setup()
    local league = fakeLeague()
    local proposal = {
        Type = "RES_X",
        ID = 1,
        ProposerDecision = -1,
        Direction = "Enact",
        ProposalPlayer = 0,
        OnHold = false,
    }
    local row = LeagueOverviewRow.formatProposal(league, proposal, 0)
    T.truthy(row:find("Proposed by you", 1, true), "should mark self-proposed: " .. row)
    teardown()
end

function M.test_proposal_row_omits_proposer_clause_when_no_proposer()
    setup()
    local league = fakeLeague()
    local proposal = {
        Type = "RES_X",
        ID = 1,
        ProposerDecision = -1,
        Direction = "Enact",
        ProposalPlayer = -1, -- engine-generated (e.g. World Leader vote)
        OnHold = false,
    }
    local row = LeagueOverviewRow.formatProposal(league, proposal, 0)
    T.falsy(row:find("Proposed by", 1, true), "no proposer clause for engine-generated: " .. row)
    teardown()
end

function M.test_proposal_row_appends_on_hold_marker()
    setup()
    local league = fakeLeague()
    local proposal = {
        Type = "RES_X",
        ID = 1,
        ProposerDecision = -1,
        Direction = "Enact",
        ProposalPlayer = 1,
        OnHold = true,
    }
    local row = LeagueOverviewRow.formatProposal(league, proposal, 0)
    T.truthy(row:find("On hold", 1, true), "on-hold marker should appear: " .. row)
    teardown()
end

function M.test_proposal_row_appends_vote_state_in_vote_mode()
    setup()
    local league = fakeLeague()
    local proposal = {
        Type = "RES_X",
        ID = 1,
        ProposerDecision = -1,
        Direction = "Enact",
        ProposalPlayer = 1,
        OnHold = false,
    }
    local row = LeagueOverviewRow.formatProposal(league, proposal, 0, "3 Yea")
    T.truthy(row:find("your vote: 3 Yea", 1, true), "should append vote-state suffix: " .. row)
    teardown()
end

function M.test_proposal_row_no_vote_state_when_voteState_nil()
    setup()
    local league = fakeLeague()
    local proposal = {
        Type = "RES_X",
        ID = 1,
        ProposerDecision = -1,
        Direction = "Enact",
        ProposalPlayer = 1,
        OnHold = false,
    }
    local row = LeagueOverviewRow.formatProposal(league, proposal, 0)
    T.falsy(row:find("your vote", 1, true), "no vote-state suffix when nil: " .. row)
    teardown()
end

-- filterTooltip: clauses without trailing punctuation get a period inserted
-- before the [NEWLINE] separator so screen readers pause naturally between
-- them; clauses that already end in terminal punctuation keep the plain
-- space. Trailing [NEWLINE] (no content after) does not produce a spurious
-- terminal period.

function M.test_filter_tooltip_inserts_period_between_unpunctuated_clauses()
    setup({})
    local out = LeagueOverviewRow.filterTooltip("1 from membership[NEWLINE]2 from World Wonders")
    T.eq(out, "1 from membership. 2 from World Wonders")
    teardown()
end

function M.test_filter_tooltip_preserves_existing_period_between_clauses()
    setup({})
    local out = LeagueOverviewRow.filterTooltip("session ends.[NEWLINE]1 from membership")
    T.eq(out, "session ends. 1 from membership")
    teardown()
end

function M.test_filter_tooltip_preserves_existing_colon_between_clauses()
    setup({})
    local out =
        LeagueOverviewRow.filterTooltip("Their top choices for the current proposals:[NEWLINE]Unknown for ENACT")
    T.eq(out, "Their top choices for the current proposals: Unknown for ENACT")
    teardown()
end

function M.test_filter_tooltip_does_not_append_period_for_trailing_newline()
    setup({})
    local out = LeagueOverviewRow.filterTooltip("production city[NEWLINE]")
    T.eq(out, "production city")
    teardown()
end

function M.test_filter_tooltip_handles_consecutive_unpunctuated_clauses()
    setup({})
    local out = LeagueOverviewRow.filterTooltip("Wine[NEWLINE]Unknown for ENACT[NEWLINE]Arts Funding")
    T.eq(out, "Wine. Unknown for ENACT. Arts Funding")
    teardown()
end

function M.test_filter_tooltip_handles_nil_input()
    setup({})
    T.eq(LeagueOverviewRow.filterTooltip(nil), "")
    teardown()
end

-- formatDelegationBreakdown: drops the engine header (parent row already
-- speaks the leader/civ/total), keeps only the bulleted per-source list, and
-- injects "Delegates" on the first bullet to give context to the bare counts
-- that follow.

function M.test_delegation_breakdown_drops_header_and_injects_delegates_on_first_bullet()
    setup({})
    local raw = "Shaka of The Zulus commands a total of 8 Delegates.  Once in session, the amount is fixed until the session ends."
        .. "[NEWLINE][ICON_BULLET]4 from membership"
        .. "[NEWLINE][ICON_BULLET]2 from previous World Leader attempts"
        .. "[NEWLINE][ICON_BULLET]2 from City-States (2 per ally)"
    local out = LeagueOverviewRow.formatDelegationBreakdown(raw)
    T.falsy(out:find("commands a total", 1, true), "header should be dropped: " .. out)
    T.falsy(out:find("session ends", 1, true), "fixed-in-session disclaimer should be dropped: " .. out)
    T.truthy(out:find("4 Delegates from membership", 1, true), "first bullet should inject Delegates: " .. out)
    T.truthy(out:find("2 from previous World Leader attempts", 1, true), "later bullets stay bare: " .. out)
    T.truthy(out:find("2 from City%-States %(2 per ally%)"), "CS bullet preserved: " .. out)
    -- only the first bullet gets "Delegates"; the others must not.
    local _, count = out:gsub("Delegates", "")
    T.eq(count, 1, "only one Delegates injection: " .. out)
    teardown()
end

function M.test_delegation_breakdown_handles_host_for_clause()
    setup({})
    -- HOST_VOTES uses "for" instead of "from". Injection should still apply
    -- to the first bullet's count regardless of preposition.
    local raw = "header text[NEWLINE][ICON_BULLET]2 for being the current host"
        .. "[NEWLINE][ICON_BULLET]4 from membership"
    local out = LeagueOverviewRow.formatDelegationBreakdown(raw)
    T.truthy(out:find("2 Delegates for being the current host", 1, true), "host-bullet first: " .. out)
    T.truthy(out:find("4 from membership", 1, true), "second bullet stays bare: " .. out)
    teardown()
end

function M.test_delegation_breakdown_returns_empty_when_no_bullets()
    setup({})
    -- Member with zero delegates from any source: engine emits the header but
    -- no bullets. Drill should skip this section entirely so the parent row's
    -- "0 delegates" stands on its own.
    local raw = "Someone of Somewhere commands a total of 0 Delegates.  Once in session..."
    T.eq(LeagueOverviewRow.formatDelegationBreakdown(raw), "")
    teardown()
end

function M.test_delegation_breakdown_handles_nil_input()
    setup({})
    T.eq(LeagueOverviewRow.formatDelegationBreakdown(nil), "")
    teardown()
end

-- appendTooltip: flattening helper for rows that would otherwise be a Group
-- with a single Text child. Joins the lead label and the appended tooltip
-- with a single space when the label already ends in terminal punctuation,
-- otherwise inserts ". " so the two clauses read as separate sentences.
-- Empty / nil tooltip returns the label unchanged.

function M.test_append_tooltip_inserts_period_when_label_unpunctuated()
    setup({})
    T.eq(LeagueOverviewRow.appendTooltip("Enact: Ban Luxury", "This would..."), "Enact: Ban Luxury. This would...")
end

function M.test_append_tooltip_uses_space_when_label_ends_in_period()
    setup({})
    T.eq(
        LeagueOverviewRow.appendTooltip("Darius I of Persia, host.", "Darius commands 3 Delegates."),
        "Darius I of Persia, host. Darius commands 3 Delegates."
    )
end

function M.test_append_tooltip_uses_space_when_label_ends_in_colon()
    setup({})
    T.eq(LeagueOverviewRow.appendTooltip("Note:", "extra info"), "Note: extra info")
end

function M.test_append_tooltip_returns_label_unchanged_for_empty_tooltip()
    setup({})
    T.eq(LeagueOverviewRow.appendTooltip("just a label", ""), "just a label")
    T.eq(LeagueOverviewRow.appendTooltip("just a label", nil), "just a label")
end

return M
