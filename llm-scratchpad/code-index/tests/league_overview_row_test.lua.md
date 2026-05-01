# tests/league_overview_row_test.lua — 627 lines
Tests LeagueOverviewRow pure formatting functions: status pill, member ordering, member row composition, vote state, proposal row, tooltip filtering.

## Header comment

```
-- Row formatter tests for the League Overview screen. Covers status pill
-- (pre-session / in-session / special / UN-Diplomatic suffix), member-row
-- ordering and tag composition, vote-state suffixes (yes/no signed and
-- major-civ choice), proposal-row composition (proposer clause, on-hold
-- marker, Vote-mode vote-state appendage), and resolution-name direction
-- prefixes. Pure functions — no menu / handler stack involvement.
```

## Outline

```
  4  local T = require("support")
  5  local M = {}
 10  local origPlayers, origGameInfo, origGameDefines, origGame, origPreGame, origConvertTextKey
 18  local ENGINE_STRINGS = { ... }   -- verbatim format strings from CIV5GameTextInfos_Leagues_Expansion2.xml
 30  local function fakeLeague(opts)
    local function setup(opts)
    local function teardown()
193  function M.test_status_pill_pre_session_speaks_turns_until_session()
201  function M.test_status_pill_in_session_normal()
209  function M.test_status_pill_in_special_session_strips_to_label()
220  function M.test_status_pill_negative_turns_clamps_to_zero()
229  function M.test_status_pill_un_active_without_diplo_victory_no_world_leader_suffix()
240  function M.test_status_pill_un_active_with_diplo_victory_appends_world_leader_clauses()
253  function M.test_ordered_members_host_first_then_votes_desc_then_id_asc()
273  function M.test_ordered_members_filters_dead_minor_and_non_members()
295  function M.test_member_row_includes_leader_civ_and_delegates()
310  function M.test_member_row_singular_delegate_phrase()
323  function M.test_member_row_self_marker_for_active_player()
335  function M.test_member_row_host_marker_even_when_first_in_sort()
348  function M.test_member_row_can_propose_marker()
360  function M.test_member_row_diplomat_marker_only_on_other_civs()
381  function M.test_yes_no_vote_state_abstain_at_zero()
388  function M.test_yes_no_vote_state_singular_yea_and_nay()
395  function M.test_yes_no_vote_state_plural_yea_and_nay()
402  function M.test_major_civ_vote_state_abstain_when_no_choice()
410  function M.test_major_civ_vote_state_abstain_when_zero_with_choice()
417  function M.test_major_civ_vote_state_singular_for_one_vote()
426  function M.test_major_civ_vote_state_plural_for_multi_votes()
436  function M.test_resolution_name_enact_prefix()
444  function M.test_resolution_name_repeal_prefix()
452  function M.test_proposal_row_includes_proposer_clause_for_other_civ()
469  function M.test_proposal_row_includes_you_clause_for_self_proposed()
485  function M.test_proposal_row_omits_proposer_clause_when_no_proposer()
501  function M.test_proposal_row_appends_on_hold_marker()
517  function M.test_proposal_row_appends_vote_state_in_vote_mode()
533  function M.test_proposal_row_no_vote_state_when_voteState_nil()
555  function M.test_filter_tooltip_inserts_period_between_unpunctuated_clauses()
562  function M.test_filter_tooltip_preserves_existing_period_between_clauses()
569  function M.test_filter_tooltip_preserves_existing_colon_between_clauses()
577  function M.test_filter_tooltip_does_not_append_period_for_trailing_newline()
584  function M.test_filter_tooltip_handles_consecutive_unpunctuated_clauses()
591  function M.test_filter_tooltip_handles_nil_input()
603  function M.test_append_tooltip_inserts_period_when_label_unpunctuated()
608  function M.test_append_tooltip_uses_space_when_label_ends_in_period()
616  function M.test_append_tooltip_uses_space_when_label_ends_in_colon()
621  function M.test_append_tooltip_returns_label_unchanged_for_empty_tooltip()
627  return M
```
