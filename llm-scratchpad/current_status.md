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
8. `high-level-cleanup.md` — four parallel analysis forks (architecture/lifecycle, abstractions, docs, test architecture) plus the deferred-list candidates from the low-level pass synthesized into a curated proposal at `llm-scratchpad/high-level-proposal.md`. User opted into the "strongly recommend" + "recommend with caveats" sets. Net diff vs the post-low-level tip: 91 files changed, **~1500 lines removed**. The 9 cleanups, in commit order:
   1. **A1.** CLAUDE.md: document Access wrapper convention; restructure "Bootstrap override surfaces" to lead with the general convention (~110 vendor files appended with one include) and then describe the 4 bootstrap-special overrides as a sub-case. Notes the TradeLogic.lua exception. Pure docs.
   2. **A2 + A3.** Drop change-history phrasing from 12 source-file headers + 4 menu_*_test headers ("peeled out of...", "replaces...", etc.). Fix CivVAccess_TaskList header that misleadingly claimed the listener registers "matching the engine's TaskList.lua" — actually runs in WorldView's env via Boot.
   3. **B1.** Boot: probe engine-fork bindings at WorldView Context include time. Tests Game.GetBuildRoutePath / Game.GetCycleUnits as canaries; emits one log line ("engine fork bindings present" or "fork DLL not deployed -- features will silently fail; run ./deploy.ps1") so a contributor diagnosing missing speech sees the line at the top of Lua.log.
   4. **C1.** Text: add `Text.joinNonEmpty(parts, sep)` and `Text.joinVisibleControls(controlNames, sep)`. Lifts ~16 hand-rolled join sites including the differently-named copies in DiploCommon (joinParts) and HoF/Leaderboard (local joinNonEmpty). ~98 lines removed.
   5. **B2.** Log: add `Log.installEvent(dispatcher, eventName, handler, scope, missingMsg)`. Codifies the "no install-once guards / register fresh every game" rule in code instead of scattered comments. 22 listener-registration sites converted across InGame / Shared / TechTree / WorldView; several callers also gained feature-gate safety they didn't have (NotificationAnnounce, CivilopediaAccess, AdvisorsAccess, TechTreeAccess called Events.X.Add bare). ~141 lines removed.
   6. **B3.** Log: add `Log.safeListener(scope, fn)`. Promotes StagingRoomAccess's local safeListener (4 listeners) to the canonical surface and consolidates 3 inline pcall-wrapped listener bodies (Boot LoadScreenClose, CityViewAccess SerialEventCityScreenDirty, ChatAccess CivVAccessChatToggle). The mechanical sweep over the remaining ~94 listeners that don't currently pcall-wrap is intentionally not done -- each conversion would scatter scope strings with little expected payoff.
   7. **B4.** Log: add `Log.tryCall(label, fn, ...)`. Convert ~22 high-frequency Shared pcall sites (BaseMenuInstall, TabbedShell, TickPump, BaseMenuTabs, HandlerStack drainAndRemove escBinding). ~37 lines removed. Skipped HandlerStack.invoke / fireOnActivate (their domain-specific local helpers carry handler.name + abortVerb context that would be awkward to inline) and BaseMenuEditMode's local `safe` helper (captures errCtx once, reused 7 times).
   8. **E1.** Add CivVAccess_PopupBoot bundle; collapse 51 popup preambles. The 21-line include preamble that every Popups/*Access.lua wrapper opened with is now a single `include("CivVAccess_PopupBoot")`. ~1008 lines removed. Stem name verified collision-free against CLAUDE.md's stem-prefix gotcha. Popups with extras (Civilopedia*, ChooseConfirmSub, CameraTracker, TabbedShell, BaseTableCore, DiploCommon, the Choose* logic modules, the LeagueOverview*Row modules, TradeRouteRow, PullDownProbe) keep them as additional includes after the bundle reference.
   9. **E3.** Drop civvaccess_shared install-once guards from four FrontEnd Access files (FrontEndPopup, JoiningRoom, LoadScreen, StagingRoom). The flag persisted across Context re-inits and would lock the mod to a stranded prior-Context listener. Two patterns applied: file-scope-only installs (FrontEndPopup, LoadScreen) drop the guard entirely; inside-priorShowHide installs (JoiningRoom, StagingRoom) replace the civvaccess_shared flag with a file-scope local that resets on Context re-include.

   **Skipped from the proposal:**
   - **D1, D2 (test architecture)** — left for the next agent to pick up after the F-list (see "Pending high-level cleanup work" below). Per user mid-pass: "I am actually going to suggest skipping the test set improvements. I don't care about them, we'll come back for them some other time."
   - **E2 (BaseInstall scaffold lift)** — examined BaseMenuInstall (150 lines) and TabbedShell (130 lines) side-by-side. Truly identical scaffold is ~15 lines (spec-field reads, pendingPush, runDeferredPush, TickPump.install conditional). Substantive differences are not flag-shaped: BaseMenu has edit-mode Enter claim, type-ahead Esc clear, and suppressReactivateOnHide that TabbedShell genuinely doesn't need; their bIsInit guards differ; their removeByName flags differ; TabbedShell has resetTabsForNextOpen on hide. A shared `BaseInstall.install(ContextPtr, handler, spec, hooks)` taking 5+ hook callbacks to differentiate would save ~40 net lines but make each call site require cross-referencing the shared scaffold to understand behavior. The arch fork's "load-from-game discipline lives in one place" framing was the main argument -- but that discipline is documented in CLAUDE.md and applied via the new Log.installEvent helper, not via the install scaffold. Senior-engineer call: leave the two install functions as parallel, locally-readable implementations.

9. **F-list + D-list pass.** Walked F1-F11 and D1-D2 in order. Of 13 items, 9 landed; 4 skipped (F2, F9, F10 because the per-site form was already locally readable, plus F2 because F1 absorbed two of its sites). Net effect across the pass: ~-700 lines of code + tests. Per-item summary, in commit order:
   1. **F1.** New helpers on `SavedGameShared`: `appendStandardHeaderLeaves`, `pushRequirementsSub`, `pushDeleteConfirmSub`, `sortedFileIndices`, `makeSortByGroup`. LoadMenu / SaveMenu / LoadReplay reader-tab header builders, plus the LoadMenu/LoadReplay requirements / delete-confirm / sort-by group / sortedFileIndices duplicates, all collapse through these. Net -202 lines.
   2. **F3.** New `CivVAccess_ChoosePopupCommon` module exposes `selectionStub`, `preambleText`, `install(opts)`. ChooseFreeItem / ChooseGoodyHutReward / ChooseFaithGreatPerson / ChooseMayaBonus pass popupType / handlerName / displayKey / buildItems. Per-popup eligibility / source / commit-key / close-mechanism stays in each caller's buildItems. Each wrapper drops ~25 scaffold lines.
   3. **F4.** New `DiploCommon.applyTabBindings(spec, nextSibling, prevSibling)` mutates a BaseMenu.install spec with the Tab cycle / Esc bubble / `_switching`-aware suppressReactivateOnHide block. DiploCurrentDeals / DiploGlobalRelationships / DiploRelationships each save ~12 lines and the rationale comments move to one docstring.
   4. **F5.** New `CivVAccess_GameResultRow` Shared module hosts the always-shared row formatters (`lookupDescription`, `victoryTypeText`, `mapTypeText`, `eraTurnText`, `statusText`, `scoreText`) and parameterizes the diverging cases (`leaderCivFromCivType(civKey)`, `winnerText(v, honorPlayerWon)`). HallOfFame wraps `leaderCivFromCivType` with its LeaderName / CivilizationName override branch.
   5. **F6.** New `CivVAccess_OverviewCivLabels` module exposes `activePlayerId / activePlayer / activeTeamId / activeTeam / isMP / playerHasMet / civDisplayName`. Demographics / VictoryProgress / CultureOverview drop their local copies. Side-effect: VictoryProgress and CultureOverview previously passed the raw `"TXT_KEY_POP_VOTE_RESULTS_YOU"` to `Text.format` (relying on engine-side recursive substitution); the shared form is the explicit `Text.key`-then-`format` pattern. Behavior identical, call site no longer ambiguous.
   6. **F7.** New `HandlerStack.appendAltBlocks(bindings, opts)` appends Alt+QAZEDC direct-move blocks (when `opts.directMove`) and Alt+letter quick-action blocks (when `opts.quickActions`). UnitTargetMode and GiftMode pass both; CityRangeStrikeMode passes only directMove. The local `MOD_ALT` constants and `noop` helpers also dropped from each caller.
   7. **F8.** Promoted `enemyCityAt` to `UnitControlMovement.enemyCityAt` and surfaced via `UnitControl.enemyCityAt`; UnitTargetMode aliases it. Lifted `legalityPreview` to `PlotComposers.legalityPreview` (it composes a per-plot preview string on top of `PlotComposers.glance`); UnitTargetMode and GiftMode alias it.
   8. **F11.** Boot tracks `civvaccess_shared.bootCount` across the session; engine-fork probe and LoadScreenClose-registration log lines now tag with `(install)` for the first include and `(re-init #N)` for subsequent ones. Distinguishes a contributor's first run from a re-init in Lua.log.
   9. **D1.** Lifted setup / helpers / state from the four `menu_*_test.lua` suites (~180 dup lines per file) to a new `tests/menu_test_setup.lua` exposing `Setup.fresh()` plus all helpers and shared state tables (warns / errors / speaks / sounds / ctrlState). Each suite aliases what it needs at file top. The `speaks = {}` mid-test reset pattern (which would silently break under the alias) became `clearArr(speaks)`. Net -400 lines.
   10. **D2.** foreign_unit_watch_test, foreign_clear_watch_test, and reveal_announce_test switched their custom `SpeechPipeline.speakInterrupt` / `speakQueued` capture stubs to `T.captureSpeech()`. Each setup() now dofiles the real TextFilter + SpeechPipeline; the production filter / dedupe / mute gates are exercised end-to-end. baseline_handler_test (no-op stub) and input_router_test (load-bearing inline reason — captures `civvaccess_shared.muted` at speak time) stay unchanged per the pass instructions.

   **Skipped:**
   - **F2 (`pushConfirmSub` shared helper).** F1 absorbed the LoadMenu and LoadReplay delete-confirm sites via `SavedGameShared.pushDeleteConfirmSub`. The remaining InstalledPanelCore sites (Disable / Delete / Unsubscribe) are structurally distinct: Disable has informational prefix leaves before the Yes/No, Delete has a conditional third "Delete with user data" choice, Unsubscribe carries a preamble. Lifting SaveMenuCore.pushConfirmSub to absorb only Unsubscribe is one call site of marginal lift.
   - **F9 (UnitSpeech meleePreview / rangedPreview skeleton).** The two functions differ in non-trivial ways: different strength computations, different defender-strength fallback chain (embarked / sea / support-fire branching for ranged), different damage formulas, different format keys, different support vs retaliate vs interceptor side-lines. A single `previewSkeleton(kind)` would branch internally in 5+ places. The proposal flagged this as higher risk; per-site form is locally readable.
   - **F10 (civvaccess_shared.modules getter).** Marginal lift (~5 chars saved per call × 5 sites). The proposal explicitly flagged this as "future-proofing rather than line count." Existing pattern reads cleanly enough that adding indirection doesn't pay off.

## Prompts pending

1. `finalization.md` (next, per the workflow's chain).

## Coverage gap (information only)

`CivVAccess_CivilopediaCore.lua` (1226 lines) is the largest substantive logic module without a behavioral test suite. Only the flat-search corpus is unit-tested (`tests/civilopedia_flat_search_test.lua`, 9 tests). The recently-refactored `stepHistory` (history stack + boundary keys) and `harvestTextStack` (markup-stripping correctness) are unverified. Picker-tree generation is also untested. Flagged for future attention.

## Resuming after compaction

The next agent picking up should:
1. Re-read `/tmp/llm-mod-refactoring-prompts/llm-entrypoint.md`.
2. Read `/tmp/llm-mod-refactoring-prompts/prompts/finalization.md` and follow it.
3. The deploy script's proxy-DLL copy step will fail while the user has Civ V running (file-locked); the Lua payload still copies on a normal deploy, and tests pass independently. If deploy errors, ask whether the game is open before debugging.
4. This project's commit harness rejects the standard `Co-Authored-By: Claude` trailer (per `reference_commit_no_coauthor.md`); follow the convention.

## Files in llm-scratchpad

- `current_status.md` — this file. Tracks branch, prompts run, splits committed, pending work, and resume context.
- `claude_md_audit.md` — audit memo for the root CLAUDE.md changes (3 substantive corrections during the information-gathering stage).
- `llm_docs_audit.md` — audit memo for the docs/llm-docs/CLAUDE.md index changes (4 corrections).
- `code-index/` — 291 per-file outline `.md` files mirroring the source tree, plus a top-level `README.md`. The index has been kept current through every split; UnitControl, TradeLogic, CityView, and menu_test entries reflect the post-split file layout. Note: not updated for the high-level cleanup (file contents changed but file set didn't).
- `high-level-arch-findings.md`, `high-level-abstraction-findings.md`, `high-level-docs-findings.md`, `high-level-test-findings.md` — the four analysis-fork outputs that drove the high-level proposal.
- `high-level-proposal.md` — the synthesized proposal of A/B/C/D/E/F items and explicit leave-alones that drove the high-level pass.
- `convert_popups.py` — one-shot used for the E1 PopupBoot conversion. Kept as a record of the bulk operation.

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
- All commits to `claude-mod-cleanup`. Final merge to `main` is the workflow's last step (per `finalization.md`).
- Treat in-built memory as read-only during this workflow per entrypoint guidance.
- This project's commit harness rejects the standard `Co-Authored-By: Claude` trailer (per the user's memory `reference_commit_no_coauthor.md`); commits in this branch follow that convention.
