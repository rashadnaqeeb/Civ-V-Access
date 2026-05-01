# High-Level Test Architecture Findings

Scope: `tests/*` and `src/dlc/UI/InGame/CivVAccess_Polyfill.lua`. Focus is on suite-wide architecture, not per-test issues.

## Executive Summary

The test architecture is in good shape: the polyfill / run.lua / support.lua split is well-thought-out and comments explain the boundaries. The previous low-level pass already absorbed the easiest helpers (`T.captureSpeech`, `T.installLocaleStrings`, `T.fakePlayer` extension) so most local fixture builders that remain are either feature-specific (legitimate) or kept for deliberate test-independence reasons.

Three findings rise above the noise:

1. **Menu setup duplicate (~510 lines across 4 suites).** The four `menu_*_test.lua` files share a word-for-word identical setup block (lines 8-180; diff is 4 lines of header comment). With four copies that's ~510 dup lines and a guaranteed drift surface — any change to the BaseMenu dofile chain or the civvaccess_shared zeroing has to happen in four places. This is the single biggest test-architecture cleanup available.

2. **5 suites bypass the real SpeechPipeline by stubbing its public API.** `foreign_unit_watch_test`, `foreign_clear_watch_test`, `reveal_announce_test`, `baseline_handler_test`, `input_router_test` install custom `SpeechPipeline.speakInterrupt` / `speakQueued` rather than monkey-patching the lower `_speakAction` seam (i.e. `T.captureSpeech`). The three watcher suites (foreign_*, reveal_*) actively assert on spoken text and would catch more regressions if they exercised the real TextFilter chain. The other two only need a no-op and happen to use the same shape.

3. **CivilopediaCore (1226 lines) has weak test coverage.** Only the flat-search corpus is unit-tested (`civilopedia_flat_search_test`, ~9 tests). The rest of the module — picker tree generation, history navigation, RELATIONSHIP_DEFS, harvestBBText / harvestFreeFormText (which the low-level cleanup just refactored) — is unverified. This is the largest substantive logic module in the mod with no behavioral safety net.

The rest is small. Detailed findings below.

---

## Finding 1: Menu suite setup duplication

**Files:** `tests/menu_widgets_test.lua`, `tests/menu_interactions_test.lua`, `tests/menu_lifecycle_test.lua`, `tests/menu_structure_test.lua` — all lines 8-180.

**Diff between any two of the four files in the lines 8-180 range:** 4 lines (header comment differs; setup body is identical).

**Total duplicated lines:** ~170 × 4 copies = ~680 lines of which ~510 are pure duplication.

**What's duplicated:**
- `_test_pd_mt` plus `resetPDMetatable()` (lines 14-31)
- `setup()` itself (lines 33-105) — Log stubs, UI key stubs, sounds capture, SpeechPipeline reset and `_speakAction` capture, ~15 dofiles for the BaseMenu chain, civvaccess_shared zeroing, ~10 CivVAccess_Strings entries, `resetPDMetatable()`
- `populateControls`, `patchProbeFromPullDown`, `makePullDownWithMetatable`, `registerSliderCallback`, `registerCheckHandler` (lines 109-138)
- `makeCtrl`, `setCtrls`, `makeContextPtr` (lines 142-178)

**Why it matters:** Any change to the BaseMenu module chain (new dofile, new shared field to zero, new mod-string the suite reads) has to land in four files. This already trips developers — the comments at the top of each file explicitly note the duplication is deliberate, but "deliberate" doesn't make it cheap.

**Proposed fix:** Lift the shared block to a new `tests/menu_test_setup.lua` module exposing one function — say `MenuTestSetup.fresh()` — that runs all the dofile/zero/string-register work and returns a context table `{ resetPDMetatable, makePullDownWithMetatable, makeCtrl, setCtrls, makeContextPtr, populateControls, registerSliderCallback, registerCheckHandler }`. Each of the four suites then opens with `local M = require("menu_test_setup").fresh()`.

Alternative: stash the helpers on `T` itself (`T.menuSetup()`). Slight pollution of the support module since helpers are menu-specific, but a single module already exposes scanner / cursor / locale helpers, so the pattern's there.

**Risk:** Medium. Worth testing carefully — accidentally drifting a dofile order would cascade across all four suites at once.

**Confidence:** High that this should happen. Medium on which of the two factoring shapes (sibling module vs. T method).

---

## Finding 2: Five suites stub SpeechPipeline public API

**Files and patterns:**
- `tests/foreign_unit_watch_test.lua:122` — full replacement, captures speakInterrupt + speakQueued for assertions on text content
- `tests/foreign_clear_watch_test.lua:59` — same pattern
- `tests/reveal_announce_test.lua:135` — same pattern
- `tests/baseline_handler_test.lua:109` — `SpeechPipeline.speakInterrupt = function(_) end` no-op
- `tests/input_router_test.lua:445` — captures speakInterrupt to read `civvaccess_shared.muted` at speak time

**Why the seam choice matters:** The three watcher suites (`foreign_*`, `reveal_*`) are testing the aggregation / formatting of speech text. By replacing `SpeechPipeline.speakInterrupt` they bypass the real `TextFilter.scrub`, the markup-strip pipeline, and the SpeechPipeline gating logic. If `Text.format` ever started returning markup tokens (or the watcher started concatenating something with `[NEWLINE]` etc.) the tests would still pass while production speech was broken. Switching them to `T.captureSpeech()` (which patches `_speakAction`) keeps the real production stack alive end-to-end.

**Why two of the five are different cases:**
- `baseline_handler_test` only asserts on bindings table shape; the SpeechPipeline stub is just to keep the dofile from crashing. Could move to a no-op `T.silenceSpeech()` helper, or just delete the stub if dofile doesn't need it.
- `input_router_test` specifically captures `civvaccess_shared.muted` *at the moment of the speak call* (line 447) to verify the mute toggle's flag-flip ordering. `T.captureSpeech` only records text + interrupt flag; the test wants more. Keep the inline stub here.

**Proposed fix:**
- Convert the three watcher suites (foreign_unit_watch, foreign_clear_watch, reveal_announce) to use `T.captureSpeech()`. Each test that asserts `SpeechPipeline._calls[i].text` becomes `spoken[i].text`. The watchers must still call real `Text.format` / `Text.key` — verify that the test-installed `Text` shim plays nicely with the real SpeechPipeline.
- Delete the `SpeechPipeline.speakInterrupt = function(_) end` line in `baseline_handler_test` if unused — or replace with `SpeechPipeline = SpeechPipeline or {}` no-op.
- Leave `input_router_test` alone — it has a load-bearing reason to stub the public API.

**Risk:** Low. The behavioral diff is "now exercises TextFilter on the spoken strings"; if anything that strengthens the tests.

**Confidence:** High.

---

## Finding 3: Coverage gap on CivilopediaCore (1226 lines)

**Module:** `src/dlc/UI/Shared/CivVAccess_CivilopediaCore.lua` (1226 lines).

**Existing coverage:** `tests/civilopedia_flat_search_test.lua` — 9 tests, exercises only the `buildFlatCorpus` / `moveTo` flat-search path. It dofile-loads the full module but only verifies one function family.

**What's untested:**
- The 17 RELATIONSHIP_DEFS and the picker-tree they generate
- History navigation (`stepHistory`, the back/forward stack — recently refactored in low-level cleanup #9, no new tests)
- Free-form / BB text harvesting (`harvestTextStack`, also from low-level cleanup #9)
- The picker tab definitions (categories, group construction)
- Keyword selectors per article kind

**Why it matters:** This is the largest substantive logic module in the mod that doesn't have a dedicated test suite. Recent low-level cleanups touched the history navigation and text harvesting; tests would have caught any drift introduced. The flat search test exercises only a small dimension of the public surface.

**Proposed fix:** Out of scope for the high-level cleanup pass per the prompt's "don't add tests in this pass" guidance, but flag it as a known gap. If the user wants to spend effort here, the highest-value first cuts would be (a) `stepHistory` (history stack + boundary keys), (b) `harvestTextStack` (markup-stripping correctness), (c) one or two picker-tree generation tests with mocked GameInfo.

**Risk:** N/A (information only).

**Confidence:** High.

---

## Finding 4: Polyfill discipline is mostly clean — one ambiguity

**File:** `src/dlc/UI/InGame/CivVAccess_Polyfill.lua` (722 lines).

**Organization:** Engine-global stubs at the top (Locale, UI, Map, Game, Players, Teams, GameInfo, OptionsManager, Events, then enums: PlotTypes, FeatureTypes, YieldTypes, DomainTypes, CombatPredictionTypes, GameDefines, ActivityTypes, Mouse, Keys), widget factories at the bottom (`Polyfill.make*`). Logical and well-commented.

**Ambiguity:** The `Polyfill` global (line 438) lumps two semantically different things:
1. Engine globals (Locale, UI, Map, ...) — *replacements* for in-game globals
2. Widget factories (`Polyfill.makeButton` etc.) — *test fixture builders*, not engine replacements

The comments do call this out ("Widget factories for BaseMenu + BaseMenuItems unit tests" — line 432). But the file's name and top comment say "Stubs engine globals," and the widget factories are neither stubs nor engine globals. They're test fixtures that happen to live alongside the polyfill so they self-disable in-game.

**Why it matters:** Mild. A new contributor reading the file may be confused about whether `Polyfill.makeButton` is something production calls (it isn't). The current placement is convenient — the `if ContextPtr ~= nil then return end` sentinel covers both — but the name `Polyfill` doesn't communicate "test-only widget builder."

**Proposed fix (low priority):** Rename the widget table or move it. Three options:
- Move widget factories to `tests/widget_fixtures.lua` — but then they need their own `if ContextPtr ~= nil` sentinel (the polyfill's sentinel doesn't help if the file isn't dofiled at all).
- Keep them in Polyfill.lua but expose under a `TestWidgets` global instead of `Polyfill` — clearer name, same file location.
- Leave as-is and update the file's top comment to make the dual purpose explicit.

**Risk:** Low (rename only).

**Confidence:** Medium — this is a naming nit that may not be worth the churn.

---

## Finding 5: 5 suites manually re-init `civvaccess_shared = {}` at setup top

**Files:** `tests/combat_log_test.lua`, `tests/hotseat_message_buffer_test.lua`, `tests/message_buffer_test.lua`, `tests/multiplayer_rewards_test.lua` (twice), `tests/scanner_announcement_test.lua`, `tests/scanner_navigation_test.lua`, `tests/settings_test.lua`, `tests/volume_control_test.lua`.

**Pattern:** Top of `setup()`: `civvaccess_shared = {}` (or `civvaccess_shared = civvaccess_shared or {}`).

**Why it matters:** Mild. A `T.resetSharedState()` (or implicit reset in `T.captureSpeech` / similar) would centralize the discipline. But each suite has slightly different needs: some want a clean wipe, others want to preserve a few keys.

**Proposed fix:** Skip. Marginal value, easy to misuse if helper does something tests don't expect.

**Confidence:** Don't recommend.

---

## Finding 6: 12 inline `SpeechPipeline._speakAction = function ...` after T.captureSpeech landed

**Files:** `tests/type_ahead_test.lua`, `tests/menu_*_test.lua` (4), `tests/tabbed_shell_test.lua`, `tests/settings_test.lua`, `tests/scanner_navigation_test.lua`, `tests/multiplayer_rewards_test.lua`, `tests/speech_pipeline_test.lua`, `tests/base_table_test.lua`, `tests/help_test.lua`, `tests/number_entry_test.lua`, `tests/scanner_announcement_test.lua`, `tests/picker_reader_test.lua`, `tests/menuitem_textfield_test.lua`, `tests/scanner_search_filter_test.lua`.

**Status per current_status.md:** "High-reset-count suites (menu_*, base_table, tabbed_shell, picker_reader, number_entry) keep their inline pattern intentionally" (8 files). `speech_pipeline_test` is the SUT and obviously inline.

**Remainder that could adopt T.captureSpeech() but didn't:** type_ahead, multiplayer_rewards, scanner_navigation, scanner_announcement, settings, help, menuitem_textfield, scanner_search_filter.

**Why it matters:** Low. These suites work; the inline pattern is well-understood. T.captureSpeech doesn't dramatically improve them.

**Proposed fix:** Skip unless folded into a larger pass. Not worth a dedicated commit.

**Confidence:** Don't recommend on its own.

---

## Finding 7: Per-feature `make*` fixture builders — mostly fine

Surveyed against support.lua's `T.fakePlayer/Plot/Unit/City/Team`:

- `cursor_test.lua:1755` `makeCity` / `makePlayer` — extends T.fakePlayer/City with annex/diplo specifics. Comment explains why (lines 1752-1754). **Keep.**
- `foreign_unit_watch_test.lua:14,37` — local `makeUnit` plus `makePlayer` thin wrapper around T.fakePlayer. The thin wrapper is borderline noise; `makeUnit` covers ~4 methods T.fakeUnit has. Could go to T.fakeUnit if the team accepts a few extra methods on the shared fake.
- `reveal_announce_test.lua:11,42` — same pattern as foreign_unit_watch. Same call.
- `scanner_classification_test.lua:66` `makeUnit` — needs `GetUnitCombatType`, `GetSpecialUnitType`, `IsDead`, which T.fakeUnit doesn't have. **Keep local.**
- `hotseat_cursor_test.lua:22,33,46` `makePlot` / `makeUnit` / `makePlayer` — minimal 2-3-method shapes. Going through T.fakePlot/Unit/Player would add noise. **Keep local.**
- `hotseat_message_buffer_test.lua:19` `makePlayer` — 1-method shape. **Keep local.**
- `tech_tree_logic_test.lua:50,104` `fakePlayer` / `fakeTeam` — research-specific methods, no overlap with T.fakePlayer's domain. **Keep local.**
- `social_policy_logic_test.lua:98` — same as tech_tree.
- `suite_unit_speech.lua:13` `mkUnit` — ~30 unit methods, far beyond T.fakeUnit's surface. **Keep local.**

**Conclusion:** Three thin-wrapper makePlayers (foreign_unit_watch, reveal_announce, plus optionally hotseat_message_buffer) could be folded by extending T.fakePlayer with `adj` re-export — but that's micro-cleanup, not architecture. Skip.

**Confidence:** Don't recommend a sweeping pass; case-by-case dedup if other work touches these files.

---

## Finding 8: Cross-suite dofile chain duplication

10 suites dofile the same BaseMenu stack (TextFilter / SpeechPipeline / Text / HandlerStack / InputRouter / TickPump / Nav / PullDownProbe / BaseMenuItems / TypeAheadSearch / BaseMenuHelp / BaseMenuTabs / BaseMenuCore plus optional BaseMenuInstall / BaseMenuEditMode):

`menu_widgets_test`, `menu_interactions_test`, `menu_lifecycle_test`, `menu_structure_test`, `tabbed_shell_test`, `settings_test`, `economic_overview_test`, `help_test`, `picker_reader_test`, `menuitem_textfield_test`.

**Why it matters:** Each new module added to the BaseMenu stack has to be added to 10 dofile chains. The 4 menu suites would already collapse via Finding 1. The remaining 6 (tabbed_shell, settings, economic_overview, help, picker_reader, menuitem_textfield) each have somewhat different prefixes around the chain.

**Proposed fix:** A `T.loadBaseMenuStack()` helper that dofiles the chain. Suites can still dofile their feature-specific module on top. Tradeoff: tests become less explicit about what's loaded; a contributor reading a single suite has to chase the helper.

**Risk:** Low. Reversal is trivial.

**Confidence:** Medium. Worth proposing; reasonable to decline.

---

## Finding 9: ContextPtr = nil in economic_overview_test

`tests/economic_overview_test.lua` has `ContextPtr = nil` somewhere in setup. The polyfill already self-disables when ContextPtr is set, but if a prior suite set ContextPtr on the shared lua_State the polyfill stays inert. economic_overview_test seems to be defending against this.

**Why it matters:** Indicates suite-order coupling. If suites are ever reordered (or run individually), this defense becomes load-bearing or unnecessary inconsistently. No test currently sets ContextPtr to non-nil that I found, so the defense is theoretical — but the comment trail is unclear.

**Proposed fix:** Verify no suite sets `ContextPtr = anything-non-nil`; if confirmed, delete the line as dead defense.

**Risk:** Low.

**Confidence:** Medium. Worth a one-line cleanup pass.

---

## Finding 10: Test-naming convention drift

64 test suites; naming is mostly `feature_test.lua` but 3 use `suite_*` prefix (`suite_unit_speech.lua`, `suite_city_speech.lua`, `suite_city_stats.lua`).

The `suite_*` files are the largest single-feature ones (1295 / 768 / wo). The naming is presumably a holdover (perhaps an experimental convention before the others stabilized on `_test.lua`). `tests/run.lua` registers them with `T.register("unit_speech", require("suite_unit_speech"))` — note the registered name drops the `suite_` prefix to match the others.

**Why it matters:** Cosmetic. Renaming `suite_unit_speech.lua` to `unit_speech_test.lua` would be one-line touches in 3 places (the file itself, run.lua, and any other reference). Aligns with the 61 other suites.

**Proposed fix:** Rename the three `suite_*` files to `*_test.lua`.

**Risk:** Trivial. Pure rename.

**Confidence:** High that it's worth doing if folded into a larger naming pass; low standalone value.

---

## Coverage gap inventory (information only)

Mod-authored modules >100 lines without a dedicated test file (verified by grep across `tests/*.lua` for module name):

- `CivVAccess_CivilopediaCore.lua` (1226) — only flat-search covered (Finding 3)
- `CivVAccess_CameraTracker.lua` (190) — no tests
- `CivVAccess_ChatBuffer.lua` (96) — no tests
- `CivVAccess_AudioCueMode.lua` (57) — no tests (small)
- `CivVAccess_PlotComposers.lua` (253) — exercised transitively via cursor_test (1700+ lines), no dedicated suite
- `CivVAccess_PlotSectionsCore.lua` (315) — exercised transitively via cursor_test
- Most `*Access.lua` files (FrontEnd / Popups) — these are thin engine-binding adapters and don't get unit tests by design (correct decision)

Per the prompt, this is an inventory for the user, not a proposed action.

---

## Things that look fine and were verified

- `tests/run.lua` structure: one-line dofile chain at top, monkey-patch surface (Log + SpeechEngine) clearly delineated with comments explaining why they're test-owned vs polyfill-owned.
- `T.fakePlayer/Plot/Unit/City/Team` shapes: sensible defaults, opts-driven extension, post-low-level-cleanup parity with what most callers actually need.
- `T.installLocaleStrings` / `T.captureSpeech` are used cleanly where adopted.
- `T.installMap` / `T.installRecPlayer` / `T.installRecGlobals` / `T.installOriginalCapital` / `T.mkEntry` are used by 1-3 suites each — correctly scoped.
- The polyfill's enum values (PlotTypes, DirectionTypes, etc.) are documented as "values are placeholders — production reads the engine's real ids and tests compare by reference" — discipline is consistent and explicit.
- No suite I sampled tests local helpers instead of production code (the prior CLAUDE.md concern). The closest cases (foreign_*, reveal_*) test production via a stubbed seam — Finding 2 covers improving the seam choice.
- T.fakeUnit / T.fakePlayer extensions for foreign / reveal: `IsAlive`, `Units`, `GetUnitByID`, `barb` / `alive` / `units` opts (added in low-level cleanup #15) — used cleanly in the 3 suites that switched.
