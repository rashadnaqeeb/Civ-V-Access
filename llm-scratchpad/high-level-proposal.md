# High-level cleanup proposal

Synthesis of the four analysis forks (architecture/lifecycle, abstractions, docs, test-architecture) plus the deferred-from-low-level-cleanup list in current_status.md. Items are grouped by theme, then ranked within each group by strength of recommendation.

## Strongly recommend (high impact, low-to-moderate risk)

### A. Documentation gaps

**A1. CLAUDE.md gaps around the canonical Access wrapper shape.** The most leveraged docs fix found. Root CLAUDE.md describes the proxy/DLC/engine architecture but never names the wrapper shape that 87 mod files share, or the vendor-include convention (every overridden vendor `.lua` ends in `include("CivVAccess_XAccess")` — 108 files, not the 4 listed in "Bootstrap override surfaces"). Add a short "Access wrappers" subsection and restructure "Bootstrap override surfaces" to separate (1) the general convention from (2) the bootstrap-special overrides. One commit, pure docs.

**A2. Drop change-history phrasing in 12-16 file headers.** "Peeled out of X.lua", "Re-exports so any caller that previously...", "Replaces the prior 2-tick frame-count expiry timer", "This phase wires only the hub scaffold... in later phases" (literally stale placeholder in CityViewAccess.lua). Per CLAUDE.md's own antipattern rule, headers describe current state, not migration history. Surgical rewrites; the rationale-rich comments (UnitTargetMode, UnitControlMovement) keep their current-state explanation, just lose the "Replaces..." framing. Files: CityViewHexMap, CityViewProduction, CityViewAccess, UnitControlCore, TradeLogicAccess/Available/Offering, CursorActivate, UnitTargetMode, UnitControlMovement, plus 4 menu_* test headers. One commit.

**A3. TaskList header comment fix.** CivVAccess_TaskList.lua's header says "registers at file scope (matching the engine's TaskList.lua)" — but the listener actually runs in WorldView's env, and the engine's TaskList Context is the dead-on-load-from-game one CLAUDE.md says we explicitly avoid. Trivial rewrite. Could fold into A2.

### B. Lifecycle correctness

**B1. Engine-fork boot probe with degradation log.** `Unit:GeneratePath`, `Unit:GetBestBuildRoute`, `Game.GetBuildRoutePath`, `Plot:CanSeePlotPureLoS` are called bare across UnitTargetMode and UnitControlMovement — no pcall, no feature check. On a `./deploy.ps1 -SkipEngine` deploy or a vanilla-DLL machine, those throw silently. Move-target preview, route preview, build-route preview, and ranged-strike LoS all break with no Lua.log signal unless `LoggingEnabled=1`. Fix: one boot-time pcall per fork-added function, single INFO/WARN line summarizing what's available. Near-trivial; high confidence.

**B2. `Log.installEvent(scope, eventName, handler)` helper.** The pattern `if Events ~= nil and Events.X ~= nil then Events.X.Add(handler) else Log.warn(...) end` recurs 60-80 times across InGame modules. More importantly, it's the canonical surface for the "register fresh every game (don't install-once)" rule that's load-bearing per CLAUDE.md. Today the rule is in scattered comments; the helper would encode it in code. Saves ~80-100 lines and gives one architectural entry point. Low risk per site, mechanical conversion.

**B3. `Log.safeListener(scope, fn)` outer-listener wrapper.** Distinct from B2: B2 wraps the registration, B3 wraps the listener body. Today only StagingRoomAccess.lua defines a `safeListener` helper. Most other 98 listeners pass directly to `Events.X.Add(...)`. When a future game patch shifts a payload's shape, listeners crash silently. Promote the existing `safeListener` to `Log.safeListener`. Mechanical conversion at 98 sites; happy-path is identical.

**B4. `Log.tryCall(label, fn, ...)` helper for high-frequency Shared sites only.** The pattern `local ok, err = pcall(fn, arg); if not ok then Log.error(label..": "..tostring(err)) end` recurs ~50 times. Convert ~6-8 high-frequency Shared sites (HandlerStack lifecycle hooks, BaseMenuInstall priorShowHide/priorInput, TabbedShell tab transitions, TickPump runOnce); leave InGame per-feature pcalls alone (each carries its own contextual label, conversion would scatter labels). ~40 lines saved, low risk. Already on deferred list.

### C. Cross-cutting helpers (low risk)

**C1. `Text.joinNonEmpty(parts, sep)` primitive.** Hand-rolled "iterate parts, drop nil/empty, concat" loops occur ~25 times across PlotComposers, Demographics, VictoryProgress, AdvisorInfoPopup, several Choose* preambles, plus two existing differently-named copies (`DiploCommon.joinParts`, `joinNonEmpty` in HoF/Leaderboard locals). Promote to `Text.joinNonEmpty`. Saves ~120 lines, zero lifecycle risk. The deferred-list `joinVisibleControlTexts` becomes a thin wrapper around this for the Controls-name case.

### D. Test architecture

**D1. Menu suite setup deduplication (~510 dup lines across 4 suites).** menu_widgets/menu_interactions/menu_lifecycle/menu_structure share lines 8-180 word-for-word (4-line diff between any two — header comment only). Single biggest test cleanup available. Lift to `tests/menu_test_setup.lua` exposing one `fresh()` returning a context table. Drift surface is real today: any new BaseMenu dofile or shared field has to land in four places. Worth careful test execution after.

**D2. Switch 3 watcher suites to `T.captureSpeech()`.** foreign_unit_watch, foreign_clear_watch, reveal_announce all stub SpeechPipeline.speakInterrupt/speakQueued to assert on spoken text — bypassing the real TextFilter chain. If `Text.format` ever started returning markup tokens, tests would still pass while production speech broke. `T.captureSpeech` patches the lower `_speakAction` seam, exercising the production stack end-to-end. Low risk; strictly strengthens tests. baseline_handler_test (no-op stub) and input_router_test (load-bearing inline reason) stay as-is.

## Recommend with caveats (user judgment)

### E. Larger refactors with real arch impact

**E1. PopupBoot include bundle (~1000 lines saved).** Already on deferred list and validated by both the abstraction and docs forks. Every Popups/*.lua wrapper opens with the same 21-22 include lines. A new `CivVAccess_PopupBoot.lua` collapses ~1000 lines. Risk: stem-prefix collision (CLAUDE.md gotcha) — name must not be a prefix of any existing file or vice versa. A few popups (Civilopedia*) have additional includes that stay alongside. Worth doing; medium-risk because it touches 50 files.

**E2. `BaseInstall.install` scaffold lift (~60 lines + one architectural surface).** The single largest architecture-scale finding. BaseMenuInstall.lua and TabbedShell.lua share ~60 lines of lifecycle scaffold (priorShowHide/priorInput capture, TickPump.install gating, pendingPush/runDeferredPush, the SetShowHideHandler/SetInputHandler skeletons). This is the integration point between every Civ V Context our mod attaches to and our handler model. Centralizing means the load-from-game discipline (no install-once guards, fresh-listener rule, dead-env defense) lives in one place instead of two parallel implementations that drift. Higher risk — touches load-bearing init code; the harder lifecycle cases (load-from-game with popup mid-open) aren't test-caught. Do this *after* the safer items.

**E3. FrontEnd install-once guards drop.** Four FrontEnd Access files use `civvaccess_shared._fooListenersInstalled` flags to gate Events listeners — the exact pattern CLAUDE.md forbids in-game. FrontEndPopupAccess's header even acknowledges the Context "can be re-instantiated" and tries a stash-and-resolve mitigation, but the listener body's env is the issue, not the handler ref. Medium confidence: I can't verify the env-wipe scenario triggers in FrontEnd without in-game testing. Either drop the guards (matching the InGame discipline) or document the FrontEnd exemption in CLAUDE.md after the user confirms in-game that FrontEnd Contexts don't re-init.

## Recommend if you want more line savings

These are the deferred items not already absorbed into A-E above. Each is real cleanup but smaller in architectural impact than the items above. Recommend grouping if you decide to do several.

**F1. Load/Save/Replay menu reader-header consolidation (~250 lines).** `LoadMenuCore.buildReader`, `SaveMenuCore.buildReader`, `LoadReplayMenuCore.buildReader` carry near-identical 25-line stretches building the standard header leaves; differences are flag-shaped. Plus four further dups in this trio (pushRequirementsSub, pushDeleteConfirmSub, sortedFileIndices, sort-by Group construction, applySort, safeTooltipFn).

**F2. `pushConfirmSub` shared helper (~80-100 lines).** SaveMenuCore exposes `pushConfirmSub`; InstalledPanelCore (3 sites), LoadMenuCore (1), LoadReplayMenuCore (1) hand-roll the same yes/no confirm-sub against BaseMenu.create. Promote.

**F3. ChoosePopupCommon factory across 4 ChoosePopup files (~80-120 lines).** ChooseFreeItem, ChooseGoodyHutReward, ChooseFaithGreatPerson, ChooseMayaBonus share selectionStub/preambleText/install/SerialEventGameMessagePopup listener with only the eligibility predicate and popup type differing.

**F4. Diplo tab-cycle bindings helper (~36 lines).** DiploCurrentDealsAccess, DiploGlobalRelationshipsAccess, DiploRelationshipsAccess each carry the same Tab-cycle/Esc-bubble/suppressReactivateOnHide block.

**F5. HoF / Leaderboard GameResultRow shared module (~80 lines).** HallOfFameAccess and LeaderboardAccess share joinNonEmpty/lookupDescription/leaderCivText/winnerText/victoryTypeText/mapTypeText/eraTurnText/statusText/scoreText.

**F6. Demographics/VictoryProgress/CultureOverview OverviewCivLabels module (~50 lines).** Three popups each duplicate activePlayerId/activeTeamId/isMP/playerHasMet/civDisplayName/eachMajorAlive. Header comments claim duplication is needed for env-wipe — but pure functions (no captured state) are safe across env wipe. Plus a flagged inconsistency: Demographics's civDisplayName wraps `Text.key("TXT_KEY_POP_VOTE_RESULTS_YOU")`, VictoryProgress passes raw key to `Locale.ConvertTextKey`. Both work; one is drift.

**F7. Alt-block target-mode helper (~50 lines).** UnitTargetMode (14), GiftMode (14), CityRangeStrikeMode (6) carry verbatim lists of `bind(Keys.X, MOD_ALT, noop, "Block ...")`. An installAltBlocks(bindings, kinds) helper with flags collapses them.

**F8. enemyCityAt + legalityPreview cross-file dedup (~35 lines).** Both word-for-word duplicate between UnitTargetMode and UnitControlMovement (or GiftMode for legalityPreview). Either lift to a shared module or accept the duplication as locality.

**F9. UnitSpeech meleePreview/rangedPreview skeleton (~50 lines).** The two functions in UnitSpeech share a composition skeleton; the larger sibling pair attackerMods/defenderMods is harder.

**F10. `civvaccess_shared.modules` getter (~10 lines).** `local M = civvaccess_shared.modules and civvaccess_shared.modules.X` recurs at 5 sites. A getModule helper saves ~10 lines but normalizes the access pattern. Future-proofing rather than line count.

**F11. Engine "(re)install" indicator in install log lines.** Trivial change to make the load-from-game install-vs-reinstall distinction visible in Lua.log. Pays off the next time a contributor reads the log.

## Leave alone (explicit non-recommendations)

These were considered and explicitly recommended *against* by the abstraction fork:

- **Access wrapper factory.** Don't lift `BaseMenu.install` calls into an `AccessWrapper.create` factory. The per-Context env-wipe semantics make module-load-time installation in the wrapper file a feature, not boilerplate. The PopupBoot bundle (E1) already lifts what *can* be lifted safely. Beyond that, the per-file shape *is* the wiring spec for that screen.
- **Scanner backend further abstraction.** Already good — registerBackend contract is small, decentralized, well-documented. One small helper (eachMetForeignPlayer) could land if you do scanner work, but not a shape-change.
- **Cursor / Surveyor / Scanner unification.** Three deliberately distinct subsystems. Forcing a common abstraction would muddle the user-facing distinction the user has explicitly memorized.
- **Generic "push a submenu listing X" helper.** Each push has its own activation lifecycle; a generic helper would devolve to "pass through every BaseMenu.create kwarg."
- **SpeechBuilder DSL.** The `parts[#parts+1] = X; concat` pattern is correct for branchy, gated speech composition. Each composer's domain logic is genuinely different.
- **PluralRules.** Already used consistently. The one non-formatPlural site (ForeignUnitSnapshot) is a documented intentional exception.
- **Polyfill widget-factory rename.** Naming nit; not worth the churn.
- **Suite naming `suite_*` → `*_test`.** Cosmetic only.
- **Various small cleanup ideas.** civvaccess_shared = {} reset helper, inline _speakAction stubs in non-watcher suites, per-feature local fakes — all judged by the test fork as not worth the churn.

## Coverage gap (information only)

CivilopediaCore (1226 lines) has only flat-search test coverage. stepHistory and harvestTextStack — both refactored in low-level cleanup #9 — are unverified. Largest substantive logic module without a behavioral safety net. Per the prompt, no new tests in this pass; flagging for the user.

## Recommended order (if multiple items chosen)

1. **A1, A2, A3** — pure docs, no code change. Lowest risk; clear leverage. One or two commits.
2. **B1** — engine-fork boot probe. Tiny diff, concrete fragility fix.
3. **C1** (Text.joinNonEmpty), **B2** (Log.installEvent), **B3** (Log.safeListener), **B4** (selective Log.tryCall) — Log/Text helper additions, one commit per helper. Then mechanical conversion commits per logical group.
4. **D1, D2** — test architecture. Independent of the source code work.
5. **E1** (PopupBoot bundle) — biggest line savings, medium risk.
6. **E3** (FrontEnd install-once guards) — only if user confirms or commits to the "no install-once" discipline.
7. **E2** (BaseInstall scaffold lift) — biggest arch finding, riskiest. Last.
8. **F-series** — pick à la carte. Worth grouping into one or two combined commits.
