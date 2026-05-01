# `src/dlc/UI/InGame/Popups/CivVAccess_LeagueOverviewAccess.lua`

592 lines · Accessibility wrapper for the LeagueOverview popup (World Congress), presenting a three-tab TabbedShell for status/members, proposals (View/Vote/Propose modes), and ongoing effects.

## Header comment

```
-- Accessibility wrapper for the engine's LeagueOverview popup
-- (BUTTONPOPUP_LEAGUE_OVERVIEW). Three-tab TabbedShell over what the engine
-- presents as a single non-tabbed screen: tab 1 status / members, tab 2
-- current proposals (View / Propose / Vote modes), tab 3 ongoing effects.
--
-- The screen is opened by the engine's existing entry points (Diplomacy
-- "World Congress" button, additional-info dropdown, league notifications)
-- and by our Ctrl+L binding on BaselineHandler. The engine's OnClose path
-- already closes the popup on Events.GameplaySetActivePlayer (line 124),
-- so we do not register our own listener -- the close cascades through
-- ShowHide which pops our handler.
--
-- Engine integration: ships an override of LeagueOverview.{lua,xml} (verbatim
-- BNW copies plus an include for this module). The engine's OnPopup,
-- InputHandler, ShowHideHandler, Update, View, RenameLeague, OnClose, and
-- the entire VoteController / ProposalController chain stay intact;
-- TabbedShell.install layers our handler on top via priorInput / priorShowHide
-- chains. We replicate the controller logic mod-side (see
-- CivVAccess_LeagueOverviewVote / _Proposal) so we never trigger the engine
-- ChooseProposalPopup / ResolutionChoicePopup / ChangeNamePopup overlays --
-- only the ChooseConfirm overlay (commit confirmation) is reused via
-- ChooseConfirmSub since its Controls.ConfirmYes / ConfirmNo wiring is
-- exactly what the shared sub-handler expects.
--
-- Refresh on Events.SerialEventLeagueScreenDirty rebuilds all three tabs
-- from live league state. Vote-mode preservation is handled inside the
-- vote controller's syncToCurrent: pending allocations survive across
-- refreshes for proposals whose IDs still appear; vanished proposals drop
-- their entries; new proposals get fresh entries with votes = 0.
```

## Outline

- L59: `local priorInput = InputHandler`
- L60: `local priorShowHide = ShowHideHandler`
- L65: `local m_statusTab`
- L66: `local m_proposalsTab`
- L67: `local m_effectsTab`
- L68: `local m_leagueId = -1`
- L69: `local m_voteController = nil`
- L70: `local m_proposalController = nil`
- L78: `local function findLeagueIdFor(pLeague)`
- L90: `local function activeLeague()`
- L101: `local function modeFor(pLeague, activePlayer)`
- L120: `local function noLeagueFallbackText()`
- L136: `local function pushRenameSub(activePlayer, leagueId)`
- L189: `local function memberDetailsTooltip(pLeague, member, activePlayer)`
- L193: `local function buildStatusTabItems(pLeague, activePlayer, leagueId)`
- L232: `local function buildViewAllResolutionRow(pLeague, candidate, activePlayer)`
- L244: `local function buildViewAllSection(headerKey, candidates, pLeague, activePlayer)`
- L258: `local function pushViewAll(pLeague, activePlayer)`
- L303: `local function pushCommitConfirm(unspentDelegates, onConfirm)`
- L317: `local function onClose()`
- L328: `local function readOnlyProposalRow(pLeague, proposal, activePlayer)`
- L337: `local function buildActionsLine(mode, pLeague, activePlayer)`
- L355: `local function buildViewAllButton(pLeague, activePlayer)`
- L365: `local rebuildAllTabs = function() end`
- L377: `local function buildVoteFooter(pLeague, activePlayer)`
- L415: `local function buildProposeFooter(pLeague, activePlayer)`
- L455: `local function buildProposalsTabItems(pLeague, activePlayer)`
- L518: `local function buildEffectsTabItems(pLeague, activePlayer)`
- L535: `if type(ContextPtr) == "table" and type(ContextPtr.SetShowHideHandler) == "function" then`
- L549: `rebuildAllTabs = function()`
- L558: `TabbedShell.install(ContextPtr, { ... })`
- L583: `Events.SerialEventLeagueScreenDirty.Add(function() ... end)`

## Notes

- L365 `rebuildAllTabs`: Initialized as a no-op stub so `buildVoteFooter`/`buildProposeFooter` closures (which call it on Reset) can capture it before the install block assigns the real function at L549.
- L101 `modeFor`: Pure derivation from live league state with no cached mode variable; the mode transition (session start/end, proposals exhausted) takes effect automatically on the next dirty-refresh.
- L78 `findLeagueIdFor`: League handles have no `GetID` method; this walks `Game.GetLeague(i)` by index to find the matching handle and return its integer ID for Network commit calls.
