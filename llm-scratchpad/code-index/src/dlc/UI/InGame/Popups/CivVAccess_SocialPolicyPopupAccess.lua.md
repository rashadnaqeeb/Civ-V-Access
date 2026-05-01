# `src/dlc/UI/InGame/Popups/CivVAccess_SocialPolicyPopupAccess.lua`

639 lines · Accessibility wrapper for the BUTTONPOPUP_CHOOSEPOLICY screen, providing a two-tab BaseMenu (Policies and Ideology) with confirm sub-menus for branch/policy/tenet adoption and ideology switching.

## Header comment

```
-- SocialPolicyPopup accessibility. BUTTONPOPUP_CHOOSEPOLICY wraps the BNW
-- social-policy screen as a two-tab BaseMenu: Policies (9 classical branches,
-- each drillable for its policies in unlock-order) and Ideology (3 level
-- groups of tenet slots, plus public opinion and switch-ideology). Tab 2 is a
-- no-op "not yet embraced" placeholder when the player has no ideology, and a
-- disabled notice when GAMEOPTION_NO_POLICIES is set.
--
-- Pure helpers (branch status, tier ordering, slot gating, speech composition,
-- preamble) live in CivVAccess_SocialPolicyLogic for offline-test coverage.
-- This file owns install-side wiring: item builders, activation dispatch,
-- confirm-sub pushes for the four game overlays (PolicyConfirm, ChooseTenet,
-- TenetConfirm, ChangeIdeologyConfirm), event listeners, and the priorShowHide
-- wrap that cleans up subs on hide.
--
-- Confirm subs are local helpers rather than ChooseConfirmSub because this
-- screen has no Controls.ConfirmText (ChooseConfirmSub's preamble source) and
-- its button names are Yes/No (not ConfirmYes/ConfirmNo). Each helper spells
-- out its overlay's Yes/No control names and hides the overlay on every exit
-- path via onDeactivate so Esc/No/Yes all leave a clean state.
--
-- popupInfo.Data2 == 2 opens to the Ideology tab. The SerialEventGameMessagePopup
-- listener captures that into _openToIdeologyTab and calls setInitialTabIndex
-- before install's onShow runs (the listener fires synchronously during the
-- base OnPopupMessage dispatch, well before UIManager:QueuePopup's ShowHide).
--
-- Load-from-game: popup Contexts re-initialize, so the listeners register
-- fresh on every include with no install-once guards. Dead prior-game
-- listeners throw on first global access and the engine catches them per-
-- listener; the current live one fires.
```

## Outline

- L54: `local priorInput = InputHandler`
- L55: `local priorShowHide = ShowHideHandler`
- L57: `local TAB_POLICIES = 1`
- L58: `local TAB_IDEOLOGY = 2`
- L60: `local SUB_POLICY_CONFIRM = "PolicyConfirm"`
- L61: `local SUB_TENET_PICKER = "TenetPicker"`
- L62: `local SUB_TENET_CONFIRM = "TenetConfirm"`
- L63: `local SUB_CHANGE_IDEOLOGY = "ChangeIdeologyConfirm"`
- L68: `local _openToIdeologyTab = false`
- L70: `local mainHandler`
- L72: `local function currentPlayer()`
- L76: `local function currentIdeology()`
- L92: `local function pushPolicyConfirm(name, isBranch, successKey)`
- L140: `local function pushTenetConfirm(name)`
- L185: `local function pushTenetPicker(level)`
- L237: `local function pushChangeIdeologyConfirm()`
- L299: `local function activatePolicy(policyRow, branchRow)`
- L322: `local function activateBranchUnlock(branchRow)`
- L342: `local function activateSlot(level, slotIndex)`
- L363: `local function activateSwitchIdeology()`
- L377: `local function buildBranchChildren(branchRow)`
- L439: `local function buildLevelChildren(level)`
- L463: `local function closeItem()`
- L473: `local function buildPoliciesTabItems()`
- L491: `local function buildIdeologyTabItems()`
- L562: `local function wrappedPriorShowHide(bIsHide, bIsInit)`
- L577: `mainHandler = BaseMenu.install(ContextPtr, { ... })`
- L614: `Events.SerialEventGameMessagePopup.Add(...)`
- L621: `Events.EventPoliciesDirty.Add(...)`

## Notes

- L299 `activatePolicy`: Guards `IsPolicyBlocked` before calling `PolicySelected` because a blocked-adoptable policy triggers a branch-switch popup flow that bypasses `Controls.PolicyConfirm`, which would cause the pushed confirm sub to operate on a stale `m_gPolicyID`.
- L562 `wrappedPriorShowHide`: Removes all confirm sub-handlers silently on hide so orphan subs don't steal input after the popup closes.
