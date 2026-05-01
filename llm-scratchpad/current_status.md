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

1. `high-level-cleanup.md` (paused on user instruction). The user asked the workflow to stop after the low-level cleanup completes; advancing to high-level requires explicit go-ahead.
2. `finalization.md` (last per the workflow's chain — `high-level-cleanup.md`'s "Up Next" footer).

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
