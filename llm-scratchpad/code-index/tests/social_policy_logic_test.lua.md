# `tests/social_policy_logic_test.lua`

803 lines · Tests for `CivVAccess_SocialPolicyLogic` covering branch iteration, policy tier sort, branch/policy/slot status resolution, speech composition (branch, policy, preamble, slot, tenet picker), and sequential + cross-level slot gating.

## Header comment

```
-- SocialPolicyLogic tests. Exercises branch iteration, policy tier sort,
-- branch / policy / slot status resolution, speech composition (branch,
-- policy, preamble, slot, tenet picker), and the sequential + cross-level
-- slot gating that gets reproduced from the base game's UpdateDisplay.
```

## Outline

- L6: `local T = require("support")`
- L7: `local M = {}`
- L11: `local function branchRow(opts)`
- L27: `local function policyRow(opts)`
- L42: `local function installDB(branches, policies, prereqs, eras)`
- L98: `local function fakePlayer(opts)`
- L178: `local function installTeams(currentEra)`
- L190: `local function setup(opts)`
- L263: `local function tradition()`
- L291: `function M.test_classicalBranches_excludes_PurchaseByLevel()`
- L305: `function M.test_classicalBranches_preserves_data_order()`
- L320: `function M.test_sortBranchPolicies_opener_by_FreePolicy()`
- L328: `function M.test_sortBranchPolicies_finisher_by_FreeFinishingPolicy()`
- L336: `function M.test_sortBranchPolicies_interior_by_GridY_then_GridX()`
- L351: `function M.test_sortBranchPolicies_excludes_other_branches()`
- L371: `function M.test_adoptedCount_excludes_opener_and_finisher()`
- L385: `function M.test_branchStatus_finished_wins_over_opened()`
- L394: `function M.test_branchStatus_blocked_when_unlocked_and_blocked()`
- L403: `function M.test_branchStatus_opened_when_unlocked_not_blocked()`
- L411: `function M.test_branchStatus_adoptable_when_CanUnlock()`
- L419: `function M.test_branchStatus_locked_era_reports_era_type()`
- L435: `function M.test_branchStatus_locked_religion_when_no_religion_founded()`
- L448: `function M.test_branchStatus_plain_locked_when_religion_founded_but_unaffordable()`
- L461: `function M.test_branchStatus_plain_locked_when_no_reason_matches()`
- L476: `function M.test_policyStatus_opener_identified()`
- L484: `function M.test_policyStatus_finisher_identified()`
- L492: `function M.test_policyStatus_adopted_when_HasPolicy()`
- L500: `function M.test_policyStatus_adoptable_when_CanAdopt()`
- L508: `function M.test_policyStatus_blocked_beats_locked()`
- L516: `function M.test_policyStatus_locked_returns_missing_prereq_names()`
- L527: `function M.test_policyStatus_locked_lists_all_AND_prereqs()`
- L554: `function M.test_buildBranchSpeech_starts_with_branch_description()`
- L567: `function M.test_buildBranchSpeech_includes_count_and_flavor()`
- L583: `function M.test_buildPolicySpeech_locked_includes_all_prereqs()`
- L593: `function M.test_buildPolicySpeech_adoptable_has_no_prereq_noise()`
- L601: `function M.test_buildPolicySpeech_strips_leading_name_from_help()`
- L631: `function M.test_buildPreamble_culture_clause_always_present()`
- L640: `function M.test_buildPreamble_omits_turns_when_per_turn_is_zero()`
- L647: `function M.test_buildPreamble_appends_free_policies_and_free_tenets()`
- L663: `function M.test_buildPreamble_skips_zero_free_counts()`
- L674: `function M.test_slotStatus_filled_when_tenet_present()`
- L682: `function M.test_slotStatus_available_level1_slot1_when_affordable()`
- L687: `function M.test_slotStatus_blocked_sequential_when_prior_empty()`
- L694: `function M.test_slotStatus_level2_blocked_crosslevel_when_level1_next_empty()`
- L703: `function M.test_slotStatus_level3_blocked_crosslevel_on_level2()`
- L711: `function M.test_slotStatus_locked_culture_when_gate_open_but_broke()`
- L720: `function M.test_slotStatus_level2_opens_when_level1_next_is_filled()`
- L740: `function M.test_buildSlotSpeech_filled_speaks_name_and_effect()`
- L751: `function M.test_buildSlotSpeech_filled_name_only_when_help_empty()`
- L762: `function M.test_buildSlotSpeech_available_says_available()`
- L767: `function M.test_buildSlotSpeech_blocked_sequential_names_prior_slot()`
- L773: `function M.test_buildSlotSpeech_crosslevel_names_level_and_slot()`
- L780: `function M.test_buildTenetPickerChoice_name_and_effect()`
- L788: `function M.test_buildTenetPickerChoice_name_only_when_no_effect()`
- L795: `return M`

## Notes

- L601 `test_buildPolicySpeech_strips_leading_name_from_help`: Monkey-patches `Locale.ConvertTextKey` mid-test to inject a help string that leads with the policy name, verifying the strip logic; restores the original after.
- L190 `setup`: Installs a partial `CivVAccess_Strings` registry inline rather than loading the production strings file, so key-resolution assertions read raw template strings.
