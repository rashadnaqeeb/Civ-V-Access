# `src/dlc/UI/InGame/Popups/CivVAccess_DiploRelationshipsAccess.lua`

595 lines · Accessibility wrapper for the Relations tab of DiploOverview, listing met major civs and city-states with diplomatic state, trade data, score, and city-state influence.

## Header comment

```
-- DiploRelationships accessibility. The Relations tab of DiploOverview;
-- lists major civs the active player has met (with diplomatic state,
-- score, and trade-availability strip) and met city-states (with trait,
-- personality, ally, resources). Activation opens AI trade / PvP trade
-- for majors, CityStateDiploPopup for minors.
--
-- Tab / Shift+Tab cycle to the sibling tabs. The sibling panels' base
-- switch functions (OnDeals / OnGlobal) are published on
-- civvaccess_shared by CivVAccess_DiploOverviewBridge; calling them
-- flips panel visibility, which fires ShowHide on both panels, popping
-- our BaseMenu and pushing the sibling's.
--
-- Esc falls through BaseMenu to the Context's priorInput (base
-- DiploRelationships has none) and bubbles up to DiploOverview, which
-- closes the popup.
```

## Outline

- L42: `local function pendingDealFragment(iUs, iOther)`
- L55: `local function teammateResearchFragment(pOther)`
- L69: `local function scoreBreakdownFragments(pOther)`
- L96: `local function majorState(iUs, pUsTeam, iOther, pOther)`
- L129: `local function relationshipStrings(iUs, iOther)`
- L165: `local function tradeableResources(iUs, iOther)`
- L194: `local function tradeFragments(iUs, iOther)`
- L228: `local function majorCivItem(iUs, pUs, pUsTeam, iOther)`
- L273: `local function minorPersonality(pOther)`
- L290: `local function minorNearbyResources(iOther, pOther)`
- L333: `local function minorStatusFragment(iUs, iOther)`
- L345: `local function minorInfluenceFragments(iUs, pOther)`
- L365: `local function minorBonusFragments(iUs, pOther)`
- L402: `local function minorExportsFragment(pOther)`
- L418: `local function minorOpenBordersFragment(iUs, pOther)`
- L428: `local function minorOtherAllyFragment(iUs, pOther)`
- L446: `local function minorQuestsFragment(iUs, iOther, pOther)`
- L462: `local function minorBullyableFragment(iUs, pOther)`
- L472: `local function minorCivItem(iUs, pUsTeam, iOther)`
- L522: `local function buildItems()`
- L564: `BaseMenu.install(ContextPtr, { ... })`

## Notes

- L96 `majorState`: For the common case (non-war, non-denouncing, non-liberated), speaks the AI's approach-towards-us guess - a value the base UI computes but never displays to sighted players.
- L446 `minorQuestsFragment`: Replaces `[NEWLINE]` with `, ` before returning so multi-quest tooltips read as a flat comma list rather than collapsing into a run-on.
