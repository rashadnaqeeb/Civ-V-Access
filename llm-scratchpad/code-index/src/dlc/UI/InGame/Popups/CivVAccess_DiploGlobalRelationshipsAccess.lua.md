# `src/dlc/UI/InGame/Popups/CivVAccess_DiploGlobalRelationshipsAccess.lua`

240 lines · Accessibility wrapper for the Global Politics tab of DiploOverview, listing met major civs with era, war/denounce flags, policies, wonders, and third-party relationships.

## Header comment

```
-- DiploGlobalRelationships accessibility. The Global Politics tab of
-- DiploOverview; lists major civs with era, war-with-us / we-denounced
-- flags, policy counts per branch, wonders owned, and a third-party
-- strip (civs at war with each other, DoFs, denunciations, CS alliances).
-- Activation opens AI trade / PvP trade, matching base LeaderSelected.
--
-- Tab / Shift+Tab cycle to sibling tabs (Relations / Deals); see
-- CivVAccess_DiploOverviewBridge for the cross-Context mechanism.
```

## Outline

- L35: `local function thirdPartyName(iThird, iUs)`
- L46: `local function policyFragment(pOther)`
- L69: `local function wondersFragment(pOther)`
- L84: `local function thirdPartyFragments(iUs, iOther, pUsTeam, pOtherTeam, pOther)`
- L151: `local function majorCivItem(iUs, pUs, pUsTeam, iOther)`
- L196: `local function buildItems()`
- L215: `BaseMenu.install(ContextPtr, { ... })`
