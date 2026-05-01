# `src/dlc/UI/InGame/Popups/CivVAccess_VictoryProgressAccess.lua`

929 lines · Accessibility wrapper for the F8 Victory Progress popup, presenting a cross-civ score ranking plus five drillable section groups (My Score, Domination, Science, Diplomatic, Cultural) with exports for offline testing.

## Header comment

```
-- Victory Progress accessibility (F8 / Who is winning). Wraps the engine
-- VictoryProgress popup as a single BaseMenu landing page: the cross-civ
-- score ranking populates the top of the list, then five Group items
-- (My Score, Domination, Science, Diplomatic, Cultural) drill into per-
-- victory-condition flat lists. Right or Enter on a Group drills in;
-- Left walks back up; Esc closes the popup outright; F8 toggles it shut
-- (matches the engine's own Data1==1 toggle behavior).
--
-- Strict vanilla parity per section: every line corresponds to something
-- the vanilla F8 main panel or its detail subscreen shows. Diplomatic has
-- no per-civ list because vanilla's was commented out; Cultural reports
-- influence percent (the engine grid's tooltip) without trend or turns-
-- to-influential, since those live on CultureOverview, not F8.
--
-- Top-level rows rebuild on every show via onShow -> setItems so the
-- score ranking tracks the engine across turn ends. Section Group items
-- carry cached=false so each drill rebuilds its child list from a fresh
-- query (matches the no-cache rule).
--
-- Engine integration: ships an override of VictoryProgress.lua (verbatim
-- BNW copy + an include for this module). The engine's OnPopup, OnBack,
-- ShowHideHandler, InputHandler, and GameplaySetActivePlayer wiring stay
-- intact; BaseMenu.install layers our handler on top via priorInput /
-- priorShowHide chains.
```

## Outline

- L47: `local priorInput = InputHandler`
- L48: `local priorShowHide = ShowHideHandler`
- L49: `VictoryProgressAccess = VictoryProgressAccess or {}`
- L53: `local function activePlayerId()`
- L57: `local function activeTeamId()`
- L61: `local function isMP()`
- L69: `local function playerHasMet(pPlayer)`
- L74: `local function stripColon(s)`
- L85: `local function civDisplayName(pPlayer)`
- L106: `local function leaderPediaNameFor(pPlayer)`
- L119: `local function eachMajorEverAlive()`
- L140: `local function scoreRowText(rank, pPlayer)`
- L150: `local function buildScoreRowItems()`
- L173: `local function scoreLine(labelKey, valueFn)`
- L186: `local function remainingTurns()`
- L194: `local function buildMyScoreItems()`
- L239: `local function dominationState()`
- L288: `local function dominationLeadingLine(state)`
- L334: `local function dominationCivSentence(pPlayer, dominatingPlayerId)`
- L456: `local function capitalsHeldByPlayer(state, iPlayer)`
- L469: `local function appendTeamSuffix(line, pPlayer)`
- L477: `local function buildDominationItems()`
- L525: `local g_TechPreReqList = {}`
- L526: `local g_TechPreReqSet = {}`
- L528: `local function collectPrereqs(techType)`
- L543: `local function activeTeamPrereqsResearched()`
- L556: `local function projectThreshold(typeKey)`
- L563: `local function teamPartCount(pTeam, projTypeKey)`
- L580: `local function partsBuiltSummary(pTeam)`
- L607: `local function teamApolloAndParts(pTeam)`
- L618: `local function scienceCivLine(pPlayer)`
- L632: `local function buildScienceItems()`
- L715: `local function buildDiplomaticItems()`
- L802: `local function influencePercentOf(otherPlayerId)`
- L812: `local function buildCulturalItems()`
- L853: `local function sectionGroup(buttonKey, builder, pediaKey)`
- L869: `local function buildLandingItems()`
- L886: `VictoryProgressAccess.scoreRowText = scoreRowText`
- L887: `VictoryProgressAccess.civDisplayName = civDisplayName`
- L888: `VictoryProgressAccess.dominationState = dominationState`
- L889: `VictoryProgressAccess.dominationLeadingLine = dominationLeadingLine`
- L890: `VictoryProgressAccess.dominationCivSentence = dominationCivSentence`
- L891: `VictoryProgressAccess.partsBuiltSummary = partsBuiltSummary`
- L892: `VictoryProgressAccess.influencePercentOf = influencePercentOf`
- L893: `VictoryProgressAccess.buildLandingItems = buildLandingItems`
- L894: `VictoryProgressAccess.stripColon = stripColon`
- L899: `BaseMenu.install(ContextPtr, { ... })`

## Notes

- L239 `dominationState`: Returns a table with leading-team analytics computed in a single pass; `capitalOwner` maps original-owner player ID to current-holder player ID.
- L334 `dominationCivSentence`: Uses vanilla's TXT_KEY_VP_DIPLO_TT_* strings verbatim so the spoken sentences match sighted tooltip text exactly.
- L525-L541 `g_TechPreReqList` / `collectPrereqs`: Computed once at file-load time (Apollo prereq tree is static); the guard at L539 skips collection when the Apollo project doesn't exist (scenario maps).
- L886-L894: Public exports on the `VictoryProgressAccess` global table for offline test coverage.
