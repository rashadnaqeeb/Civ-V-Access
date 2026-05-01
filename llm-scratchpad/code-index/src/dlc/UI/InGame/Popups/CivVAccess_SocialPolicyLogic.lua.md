# `src/dlc/UI/InGame/Popups/CivVAccess_SocialPolicyLogic.lua`

389 lines · Pure logic module (no ContextPtr/Events) for social-policy branch status, policy and tenet slot gating, and speech-string composition; testable offline.

## Header comment

```
-- Pure helpers for SocialPolicyPopupAccess. No ContextPtr / Events surface so
-- offline tests can exercise branch status, unlock ordering, slot gating, and
-- speech composition against a stubbed GameInfo + fakePlayer without dofiling
-- the install-side access file.
--
-- Branch policies are ordered by GridY (then GridX, then ID). In BNW the
-- visual grid aligns with the prereq DAG (Firaxis draws each policy one row
-- below its prereqs), so a GridY sort matches what sighted players see and
-- also produces unlock-wave tiers for AND-merge branches (Commerce, Aesthetics,
-- Patronage). BFS over Policy_PrereqPolicies would give the same ordering in
-- practice but without the match-sighted-UI guarantee.
--
-- Opener / finisher identity is read from branchRow.FreePolicy and
-- branchRow.FreeFinishingPolicy (BNW column names). Both are Type strings
-- resolved against GameInfo.Policies at speech time.
--
-- Blocker name: the engine's IsPolicyBranchBlocked returns a boolean without
-- exposing which branch did the blocking, and the game's own tooltip doesn't
-- name the blocker either, so the status word is just "blocked". Matches what
-- sighted players see.
```

## Outline

- L22: `SocialPolicyLogic = {}`
- L28: `SocialPolicyLogic.IDEOLOGY_LEVEL_SLOTS = { 7, 4, 3 }`
- L34: `function SocialPolicyLogic.classicalBranches()`
- L55: `function SocialPolicyLogic.sortBranchPolicies(branchRow)`
- L84: `function SocialPolicyLogic.adoptedCount(player, branchRow)`
- L102: `function SocialPolicyLogic.branchStatus(player, branchRow)`
- L141: `function SocialPolicyLogic.policyStatus(player, policyRow, branchRow)`
- L175: `function SocialPolicyLogic.slotStatus(player, ideologyID, level, slotIndex)`
- L210: `local function statusSpeechBranch(status, payload)`
- L236: `local function stripLeadingName(text, name)`
- L246: `local function filterHelp(helpKey, name)`
- L257: `function SocialPolicyLogic.buildBranchSpeech(player, branchRow)`
- L271: `function SocialPolicyLogic.buildPolicySpeech(player, policyRow, branchRow)`
- L302: `function SocialPolicyLogic.buildPreamble(player)`
- L331: `function SocialPolicyLogic.buildSlotSpeech(player, ideologyID, level, slotIndex)`
- L356: `function SocialPolicyLogic.buildTenetPickerChoice(policyRow)`
- L365: `function SocialPolicyLogic.buildPublicOpinionSpeech(player)`
- L388: `return SocialPolicyLogic`

## Notes

- L102 `SocialPolicyLogic.branchStatus`: Returns two values (status token, optional payload); the payload is an era type string only for the "locked-era" status.
- L175 `SocialPolicyLogic.slotStatus`: Returns two or three values (status token, p1, p2); the extra values carry slot indices and are only present for "blocked-sequential" and "blocked-crosslevel".
- L210 `statusSpeechBranch`: Private to the module (local); exposed indirectly through `buildBranchSpeech`.
- L236 `stripLeadingName`: Strips the name prefix that TextFilter leaves at the head of Help text to prevent the name from being announced twice.
