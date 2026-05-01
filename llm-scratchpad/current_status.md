# Current Status

Working branch: `claude-mod-cleanup`
Source workflow: `https://github.com/ahicks92/llm-mod-refactoring-prompts` (cloned to `/tmp/llm-mod-refactoring-prompts`, equivalently `C:/Users/rasha/AppData/Local/Temp/llm-mod-refactoring-prompts`)

## Prompts completed

1. `sanity-checks-setup.md` — branch created, scratchpad seeded.
2. `information-gathering-and-checking.md` — root CLAUDE.md and `docs/llm-docs/CLAUDE.md` audited and corrected; `docs/llm-docs/lua-api/_civvaccess_fork.md` regenerated from current `CIVVACCESS:` markers in `src/engine/`. VS toolchain naming clarified after user check (changed from "VS 2026's cl.exe" to "vswhere -latest -products *" wording in both CLAUDE.md and build-proxy.ps1's docstring).
3. `code-directory-construction.md` — built `llm-scratchpad/code-index/` covering all 291 mod-authored source files (1 proxy.c + 227 src/dlc Lua + 64 tests). Vendor base-game overrides and the engine fork overlay are deliberately excluded; see `code-index/README.md` for scope rationale.
4. `large-file-handling.md` — four splits, each verified by 1564 tests + deploy + in-game smoke test:
   - `CivVAccess_UnitControl.lua` (1367 lines) split into UnitControlSelection / UnitControlCombat / UnitControlMovement and a thin UnitControlCore orchestrator. File renamed to UnitControlCore.lua to avoid stem-prefix collision; Boot.lua and tests/unit_control_test.lua updated.
   - `CivVAccess_TradeLogicAccess.lua` (1397 lines) into TradeLogicOffering / TradeLogicAvailable + thin orchestrator. No rename needed (no prefix collision). Shared helpers (dealDuration, peaceDuration, turnsSuffix, sideIsUs, prefix, sidePlayer, pocketTooltipFn, isReadOnly, isHumanDemand, clearEngineTable, emptyPlaceholder, afterLocalDealChange) exposed on the TradeLogicAccess table.
   - `CivVAccess_CityViewAccess.lua` (2001 lines) into CityViewProduction / CityViewHexMap + trimmed orchestrator (~1188 lines). The orchestrator keeps the smaller section pushers (Wonders / Buildings / Specialists / Great Works / Great People / Worker Focus / Stats / Ranged Strike / Rename / Raze). isTurnActive and pushCitySub are duplicated as locals in the two new files rather than promoted to a shared table.
   - `tests/menu_test.lua` (4276 lines) into four self-contained suites: menu_widgets / menu_interactions / menu_lifecycle / menu_structure. The shared setup() and helpers are duplicated across all four files. tests/run.lua updated with four `T.register` lines replacing the single `T.register("menu", ...)`.
5. `input-handling.md` — no-op. The mod already has a mature input/UI abstraction (HandlerStack + InputRouter + BaseMenu with widgets/tabs/search/edit-mode/groups). The prompt explicitly says to skip when an existing system suffices. Recent splits worked with that system unchanged.
6. `string-builder.md` — no-op. The mod is partly a string-builder mod by definition (composing speech for a blind player), but the existing pattern (`local parts = {}; parts[#parts+1] = X; return table.concat(parts, sep)`) is appropriate for the deliberate, state-driven inclusion logic in the speech composers. CLAUDE.md's "don't introduce abstraction beyond what's needed" stance plus the user's fine-grained per-composer wording choices argue against a builder DSL refactor.
7. `low-level-cleanup.md` — six parallel analysis forks (Shared+proxy, FrontEnd, InGame top-level, Popups, CityView+WorldView+TechTree, tests) returned ranked findings; the user approved a curated top-15 plan. All 15 landed as separate commits, each verified against the 1564-test suite. Net diff vs the pre-cleanup tip: **65 files changed, 821 insertions(+), 1536 deletions(-)** — roughly 715 lines removed plus three silent-failure bugs fixed in FrontEnd preambles. The 15 cleanups, in commit order:
   1. Drop redundant `speak` / `speakInterrupt` / `speakQueued` wrappers across 12 InGame files (SpeechPipeline already filters nil/empty).
   2. Reuse `SavedGameShared.addField` in InstalledPanelCore + LobbyCore (added the include to the two FrontEnd Access wrappers).
   3. Promote `check(cond, msg)` from 6 Shared files to `Log.check`. tests/run.lua's Log stub gains a re-raising `check`.
   4. `Settings.lua` collapses 9 bool-pref pairs into `defineBoolPref(field, prefKey, default)`.
   5. `UserPrefs.lua` factors 6 typed get/set wrappers through private `getValue` / `setValue`.
   6. `PullDownProbe` factors 4 `ensureInstalled*` functions through `installProbe(label, flag, sample, primaryMethod, callbackField, buildInterceptors)`. `installFromControls` now iterates a kinds table.
   7. `CityStats` factors 6 build*Group helpers through `buildSimpleGroup(groupKey, rows, skipIfEmpty)`. `yieldTooltipFn` becomes an if-elseif chain; the duplicate `Locale.Compare` comparator is hoisted.
   8. `EmpireStatus` drives bindings and helpEntries from one `METRICS` table.
   9. `CivilopediaCore` factors `goBack` / `goForward` through `stepHistory(direction, label, boundaryKey)` and `harvestFreeFormText` / `harvestBBText` through `harvestTextStack`.
   10. Centralize `control:GetText` pcall into `Text.controlText(control, context)`. Eight Access wrappers use it; three formerly-pcall-less call sites (JoiningRoom, ModsError, FrontEndPopup) gained crash safety as a side benefit.
   11. `PickerReader.wrapRebuild(baseFn, getHandler, rebuilder, tabIndex)` collapses 5 monkey-patch wrappers (LoadMenu / LoadReplay / Lobby / InstalledPanel / PremiumContent).
   12. New `CivVAccess_ForeignUnitSnapshot.lua` shared module exposes `unitKey` / `metadata` / `collect(bucketFn)` / `formatList`. ForeignUnitWatch and RevealAnnounce both delegate to it; each keeps only its per-bucket vocabulary classifier.
   13. `HandlerStack` factors `warnIfMissingHelpEntries` and `fireOnActivate` between `push` and `insertAt`.
   14. `tests/support.lua` gains `T.installLocaleStrings(map)` and `T.captureSpeech()`. Six suites switch to the locale helper; six suites switch to the speech helper. High-reset-count suites (menu_*, base_table, tabbed_shell, picker_reader, number_entry) keep their inline pattern intentionally.
   15. `T.fakePlayer` extends with `IsAlive` / `Units` / `GetUnitByID` and `barb` / `alive` / `units` opts. foreign_unit_watch_test, reveal_announce_test, and scanner_classification_test drop their local makePlayer / installPlayer builders.

## Prompts pending

1. `finalization.md` (next).

## High-level cleanup landed (10 commits)

User opted into the "strongly recommend" + "recommend with caveats" sets from the synthesis proposal (llm-scratchpad/high-level-proposal.md). Test architecture (D1, D2) deferred per user. E2 (BaseInstall scaffold lift) skipped after deeper inspection -- see note below. Net diff vs the post-low-level tip: 91 files changed, **~1500 lines removed**.

1. **A1.** CLAUDE.md: document Access wrapper convention; restructure "Bootstrap override surfaces" to lead with the general convention (~110 vendor files appended with one include) and then describe the 4 bootstrap-special overrides as a sub-case. Notes the TradeLogic.lua exception. Pure docs.
2. **A2 + A3.** Drop change-history phrasing from 12 source-file headers + 4 menu_*_test headers ("peeled out of...", "replaces...", etc.). Fix CivVAccess_TaskList header that misleadingly claimed the listener registers "matching the engine's TaskList.lua" — actually runs in WorldView's env via Boot.
3. **B1.** Boot: probe engine-fork bindings at WorldView Context include time. Tests Game.GetBuildRoutePath / Game.GetCycleUnits as canaries; emits one log line ("engine fork bindings present" or "fork DLL not deployed -- features will silently fail; run ./deploy.ps1") so a contributor diagnosing missing speech sees the line at the top of Lua.log.
4. **C1.** Text: add `Text.joinNonEmpty(parts, sep)` and `Text.joinVisibleControls(controlNames, sep)`. Lifts ~16 hand-rolled join sites including the differently-named copies in DiploCommon (joinParts) and HoF/Leaderboard (local joinNonEmpty). ~98 lines removed.
5. **B2.** Log: add `Log.installEvent(dispatcher, eventName, handler, scope, missingMsg)`. Codifies the "no install-once guards / register fresh every game" rule in code instead of scattered comments. 22 listener-registration sites converted across InGame / Shared / TechTree / WorldView; several callers also gained feature-gate safety they didn't have (NotificationAnnounce, CivilopediaAccess, AdvisorsAccess, TechTreeAccess called Events.X.Add bare). ~141 lines removed.
6. **B3.** Log: add `Log.safeListener(scope, fn)`. Promotes StagingRoomAccess's local safeListener (4 listeners) to the canonical surface and consolidates 3 inline pcall-wrapped listener bodies (Boot LoadScreenClose, CityViewAccess SerialEventCityScreenDirty, ChatAccess CivVAccessChatToggle). The mechanical sweep over the remaining ~94 listeners that don't currently pcall-wrap is intentionally not done -- each conversion would scatter scope strings with little expected payoff.
7. **B4.** Log: add `Log.tryCall(label, fn, ...)`. Convert ~22 high-frequency Shared pcall sites (BaseMenuInstall, TabbedShell, TickPump, BaseMenuTabs, HandlerStack drainAndRemove escBinding). ~37 lines removed. Skipped HandlerStack.invoke / fireOnActivate (their domain-specific local helpers carry handler.name + abortVerb context that would be awkward to inline) and BaseMenuEditMode's local `safe` helper (captures errCtx once, reused 7 times).
8. **E1.** Add CivVAccess_PopupBoot bundle; collapse 51 popup preambles. The 21-line include preamble that every Popups/*Access.lua wrapper opened with is now a single `include("CivVAccess_PopupBoot")`. ~1008 lines removed. Stem name verified collision-free against CLAUDE.md's stem-prefix gotcha. Popups with extras (Civilopedia*, ChooseConfirmSub, CameraTracker, TabbedShell, BaseTableCore, DiploCommon, the Choose* logic modules, the LeagueOverview*Row modules, TradeRouteRow, PullDownProbe) keep them as additional includes after the bundle reference.
9. **E3.** Drop civvaccess_shared install-once guards from four FrontEnd Access files (FrontEndPopup, JoiningRoom, LoadScreen, StagingRoom). The flag persisted across Context re-inits and would lock the mod to a stranded prior-Context listener. Two patterns applied: file-scope-only installs (FrontEndPopup, LoadScreen) drop the guard entirely; inside-priorShowHide installs (JoiningRoom, StagingRoom) replace the civvaccess_shared flag with a file-scope local that resets on Context re-include.

### Skipped from the proposal

- **D1, D2 (test architecture).** Per user: "going to suggest skipping the test set improvements. I don't care about them, we'll come back for them some other time."
- **E2 (BaseInstall scaffold lift).** After examining BaseMenuInstall (150 lines) and TabbedShell (130 lines) side-by-side, the truly identical scaffold is ~15 lines (spec-field reads, pendingPush, runDeferredPush, TickPump.install conditional). The substantive differences are not flag-shaped: BaseMenu has edit-mode Enter claim, type-ahead Esc clear, and suppressReactivateOnHide that TabbedShell genuinely doesn't need; their bIsInit guards differ; their removeByName flags differ; TabbedShell has resetTabsForNextOpen on hide. A shared `BaseInstall.install(ContextPtr, handler, spec, hooks)` taking 5+ hook callbacks to differentiate would save ~40 net lines but make each call site require cross-referencing the shared scaffold to understand behavior. The arch fork's main argument was "load-from-game discipline lives in one place" -- but that discipline (no install-once guards, fresh-listener rule) is documented in CLAUDE.md and applied via the new Log.installEvent helper, not via the install scaffold. Honest senior-engineer call: leave the two install functions as parallel, locally-readable implementations.

## Deferred from low-level cleanup (candidates for high-level review)

The six analysis forks raised these items during low-level cleanup. They were *intentionally deferred* — either too large for a single-commit cleanup, requiring cross-file architectural change, or warranting individual user judgment. Surface them during the high-level review as options the user can accept or decline.

- **PopupBoot include bundle (~1000 lines).** Every Popups/*.lua wrapper opens with the same 21-22 `include()` lines (Polyfill, Log, TextFilter, locale strings, Text, Icons, SpeechEngine, SpeechPipeline, HandlerStack, InputRouter, TickPump, Nav, BaseMenuItems, TypeAheadSearch, BaseMenuHelp, BaseMenuTabs, BaseMenuCore, BaseMenuInstall, BaseMenuEditMode, Help). One shared `CivVAccess_PopupBoot.lua` that includes the bundle once and is then `include("CivVAccess_PopupBoot")`-ed by each wrapper would collapse roughly a thousand lines of boilerplate. Risk: the engine's stem-prefix collision rules (CLAUDE.md gotcha) — the new stem must not be a prefix of any existing file. Verify "CivVAccess_PopupBoot" is collision-free before committing. A few popups have additional includes (Civilopedia*, etc.) that must stay alongside the bundle reference. **LANDED in commit 8 above.**

## Deferred from low-level cleanup (candidates for high-level review)

The six analysis forks raised these items during low-level cleanup. They were *intentionally deferred* — either too large for a single-commit cleanup, requiring cross-file architectural change, or warranting individual user judgment. Surface them during the high-level review as options the user can accept or decline.

- **PopupBoot include bundle (~1000 lines).** Every Popups/*.lua wrapper opens with the same 21-22 `include()` lines (Polyfill, Log, TextFilter, locale strings, Text, Icons, SpeechEngine, SpeechPipeline, HandlerStack, InputRouter, TickPump, Nav, BaseMenuItems, TypeAheadSearch, BaseMenuHelp, BaseMenuTabs, BaseMenuCore, BaseMenuInstall, BaseMenuEditMode, Help). One shared `CivVAccess_PopupBoot.lua` that includes the bundle once and is then `include("CivVAccess_PopupBoot")`-ed by each wrapper would collapse roughly a thousand lines of boilerplate. Risk: the engine's stem-prefix collision rules (CLAUDE.md gotcha) — the new stem must not be a prefix of any existing file. Verify "CivVAccess_PopupBoot" is collision-free before committing. A few popups have additional includes (Civilopedia*, etc.) that must stay alongside the bundle reference.
- **Load/Save/Replay menu reader-header consolidation (~150 lines).** `LoadMenuCore.buildReader`, `SaveMenuCore.buildReader`, and `LoadReplayMenuCore.buildReader` each carry a near-identical 25-line stretch building the standard header leaves (leader+civ, era/turn, start era, game type, map/size/difficulty/speed). Differences are flag-shaped (skip date for cloud, omit game type in replay, replay's StartEra format key differs). A single `SavedGameShared.appendStandardHeaderLeaves(leaves, header, opts)` would absorb them; opts carries the per-screen flags. Same fork found four further dups in this trio (`pushRequirementsSub`, `pushDeleteConfirmSub`, `sortedFileIndices`, sort-by Group construction, `applySort`, `safeTooltipFn` for action buttons) totalling another ~100 lines.
- **`pushConfirmSub` shared helper (~80-100 lines).** `SaveMenuCore` already exposes a `pushConfirmSub` helper; `InstalledPanelCore` (3 sites: Disable / Delete / Unsubscribe), `LoadMenuCore` and `LoadReplayMenuCore` (1 each: Delete) each hand-roll the same yes/no confirm-sub against `BaseMenu.create`. Promote the existing helper to Shared and rewrite the five call sites in terms of it.
- **`BaseMenu.install` / `TabbedShell.install` scaffold lift (~50-70 lines).** The two install functions share a 60-line ContextPtr ShowHide+Input scaffold; differences are hide-time cleanup callback, Esc behavior, and bIsInit gating. A `BaseInstall.install(ContextPtr, handler, hooks)` taking per-implementation callbacks would collapse the duplication. Touches load-bearing init code; needs careful review.
- **Choose+SelectedItems scaffold across 4 ChoosePopup files (~80-120 lines).** `ChooseFreeItem`, `ChooseGoodyHutReward`, `ChooseFaithGreatPerson`, `ChooseMayaBonus` share `selectionStub` / `preambleText` / install / `Events.SerialEventGameMessagePopup` listener with only the `isEnabled` predicate and popup type differing. A `ChoosePopupCommon.install({popupType, displayKey, eligibilityFn, sourceTable, commitItemKey})` factory would compress them. Other Choose* popups (Pantheon, Ideology, Archaeology, AdmiralNewPort, TradeUnitNewHome, ChooseInternationalTradeRoute) follow a different (ChooseConfirmSub) pattern that's a separate consolidation candidate (~10-15 lines per file × 6 files).
- **`joinVisibleControlTexts` helper.** The "iterate a list of control names, drop nil/hidden, drop empty, table.concat with separator" pattern recurs in ChooseAdmiralNewPort, ChooseTradeUnitNewHome, ChooseInternationalTradeRoute, ChooseArchaeology, AdvisorInfoPopup, AdvisorModal, LeagueProjectPopup. ~12 lines × 7 = ~85 lines saved by lifting into Text or BaseMenu.
- **Diplo tab-cycle bindings helper (~36 lines).** `CivVAccess_DiploCurrentDealsAccess`, `CivVAccess_DiploGlobalRelationshipsAccess`, `CivVAccess_DiploRelationshipsAccess` each carry the same Tab-cycle / Esc-bubble / suppressReactivateOnHide block at install. A `DiploCommon.tabBindings(prevFn, nextFn)` returning the four-field bindings table collapses them.
- **HoF / Leaderboard `GameResultRow` shared module (~80 lines).** `HallOfFameAccess` and `LeaderboardAccess` share `joinNonEmpty` / `lookupDescription` / `leaderCivText` / `winnerText` / `victoryTypeText` / `mapTypeText` / `eraTurnText` / `statusText` / `scoreText`. The HoF variant honors player-supplied `LeaderName` / `CivilizationName`; otherwise the helpers are duplicates. A new `GameResultRow.lua` Shared module (analogous to `LeagueOverviewRow.lua` and `TradeRouteRow.lua`) could absorb the common subset.
- **Demographics / VictoryProgress / CultureOverview `OverviewCivLabels` shared module (~50 lines).** These three popup files each duplicate `activePlayerId` / `activeTeamId` / `isMP` / `playerHasMet` / `civDisplayName` / `eachMajorAlive`. The header comment in each claims duplication is needed "to avoid load-from-game env wipe", but pure module functions (no captured state) are safe across env wipe; only stored closure references aren't. The fork also flagged a possible inconsistency: Demographics's `civDisplayName` wraps `Text.key("TXT_KEY_POP_VOTE_RESULTS_YOU")`, VictoryProgress passes the raw key to `Locale.ConvertTextKey`. Both work, but one form is the right one and the other is drift.
- **Generic `Log.tryCall(label, fn, ...)` helper.** The pattern `local ok, err = pcall(fn, arg); if not ok then Log.error("X.fn failed: " .. tostring(err)) end` recurs ~50+ times across Shared and InGame modules (BaseMenuCore, BaseMenuItems, HandlerStack, TabbedShell, BaseMenuTabs, BaseMenuInstall, BaseMenuEditMode, TradeLogicAccess, ForeignClearWatch, ForeignUnitWatch, RevealAnnounce, etc.). Tradeoff: the explicit form is more debuggable; aggressive conversion would save 80-100 lines but obscure the call sites' error context. Worth proposing the helper, not aggressively converting.
- **Engine-Events install helper.** The boilerplate `if Events ~= nil and Events.X ~= nil then Events.X.Add(handler) else Log.warn(...) end` recurs in nearly every `installListeners()` across InGame modules. A `Log.installEvent(scope, eventName, handler, moduleName)` would collapse all of them to one-liners (~80-100 lines). Same low-mid risk as `Log.tryCall`.
- **Alt-block target-mode helper (~50 lines).** UnitTargetMode (14 entries), GiftMode (14 entries), CityRangeStrikeMode (6 entries) each carry a verbatim list of `bind(Keys.X, MOD_ALT, noop, "Block ...")` entries to suppress engine bindings during their target modes. An `installAltBlocks(bindings, kinds)` helper taking flags for the QAZEDC / F/S/W/H/P/R/U/Space sets would collapse them.
- **`enemyCityAt` cross-file dedup (~25 lines).** Identical 20-line at-war / active-team / owner check between `UnitTargetMode` and `UnitControlMovement`.
- **`legalityPreview` cross-file dedup (~10 lines).** Word-for-word duplicate between `UnitTargetMode` and `GiftMode`.
- **`UnitSpeech` `meleePreview` / `rangedPreview` skeleton (~50 lines).** The two functions in `CivVAccess_UnitSpeech.lua` share their composition skeleton (strengths, damages, name, prediction, support, intercept, mods); a `previewSkeleton(actor, defender, targetPlot, kind)` could subsume both. Higher risk for the larger sibling pair `attackerMods` / `defenderMods` (~80-150 lines, structurally mirror but with diverging engine method names).

## Resuming after compaction

The user will prompt with something like "resume the refactoring workflow". When that happens:
1. Re-read `/tmp/llm-mod-refactoring-prompts/llm-entrypoint.md` if needed.
2. Confirm with the user whether to advance to `high-level-cleanup.md`. The user previously paused the workflow at this checkpoint; do not proceed without explicit confirmation.
3. The deploy script's proxy-DLL copy step will fail while the user has Civ V running (file-locked); the Lua payload still copies on a normal deploy, and tests pass independently. If deploy errors, ask whether the game is open before debugging.

## Files in llm-scratchpad

- `current_status.md` — this file. Tracks branch, prompts run, splits committed, and resume context.
- `claude_md_audit.md` — audit memo for the root CLAUDE.md changes (3 substantive corrections during the information-gathering stage).
- `llm_docs_audit.md` — audit memo for the docs/llm-docs/CLAUDE.md index changes (4 corrections).
- `code-index/` — 291 per-file outline `.md` files mirroring the source tree, plus a top-level `README.md`. The index has been kept current through every split; UnitControl, TradeLogic, CityView, and menu_test entries reflect the post-split file layout.

## Files >2000 lines remaining (informational; user has decided which to split)

Mod-authored:
- `src/dlc/UI/InGame/CivVAccess_InGameStrings_en_US.lua` (2456) — locale data, single concern; not split per user preference and CLAUDE.md's "no abstraction beyond required" stance.
- `src/dlc/UI/InGame/CivVAccess_InGameStrings_fr_FR.lua` (2267) — same.
- `tests/cursor_test.lua` (2202) — single module's exhaustive tests, not split per user preference.

Vendor (excluded from refactor scope):
- `src/dlc/UI/InGame/CivilopediaScreen.lua` (7341)
- `src/dlc/UI/InGame/WorldView/TradeLogic.lua` (3469)
- `src/dlc/UI/InGame/CityView/CityView.lua` (2736)
- `src/dlc/UI/InGame/Popups/CultureOverview.lua` (2221)
- `src/dlc/UI/FrontEnd/Multiplayer/StagingRoom.lua` (2021)

## Notes

- Project: Civ-V-Access — accessibility mod for Civilization V (speech-only interface for blind users).
- Default branch: `main` (was 2 commits ahead of `origin/main` at start; clean tree).
- All splits committed to `claude-mod-cleanup`. Final merge to `main` is the workflow's last step (per `finalization.md`).
- Treat in-built memory as read-only during this workflow per entrypoint guidance.
- This project's commit harness rejects the standard `Co-Authored-By: Claude` trailer (per the user's memory `reference_commit_no_coauthor.md`); commits in this branch follow that convention.
