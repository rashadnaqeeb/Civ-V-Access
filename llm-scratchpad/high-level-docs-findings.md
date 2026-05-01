# High-level cleanup: documentation & comment health findings

Scope: mod-authored code in `src/dlc`, `src/proxy`, `src/engine`, plus the root and `docs/llm-docs/` CLAUDE.md indexes. Vendor base-game files (no `CivVAccess_` prefix in `src/dlc/UI`) are out of scope. User-facing speech wording is also out of scope.

Findings are ranked by impact. "Risk" describes what could go wrong if we apply the proposed fix incorrectly; "confidence" is how sure I am the finding is real.

## 1. Change-history phrasing in recently-split file headers (medium impact, low risk, high confidence)

Eight Lua files plus four test files lead with phrasing that describes how they came to be (post-split / "peeled out of") rather than what they currently do. Per CLAUDE.md "Common LLM Antipatterns ▶ Comments referring to what changed", the file-state should stand alone; the migration is no longer load-bearing for a future contributor.

Affected files and offending phrasing (line numbers approximate):

- `src/dlc/UI/InGame/CityView/CivVAccess_CityViewHexMap.lua:1` — "Peeled out of CivVAccess_CityViewAccess.lua. Owns: ..."
- `src/dlc/UI/InGame/CityView/CivVAccess_CityViewProduction.lua:1` — "Peeled out of CivVAccess_CityViewAccess.lua. Owns: ..."
- `src/dlc/UI/InGame/CityView/CivVAccess_CityViewAccess.lua:8` — "This phase wires only the hub scaffold ... Hub items and sub-handlers are added in later phases." (also doubly stale; see finding 5)
- `src/dlc/UI/InGame/CityView/CivVAccess_CityViewAccess.lua:48` — "buildHubItems below references in place of the old local pushProductionQueue / pushHexMap closures"
- `src/dlc/UI/InGame/CivVAccess_UnitControlCore.lua:37` — "Re-exports: every public method previously on UnitControl, surfaced through the orchestrator so existing callers ... keep working without touching them."
- `src/dlc/UI/InGame/CivVAccess_UnitControlCore.lua:62` — "Composed bindings list, in the same order BaselineHandler used to see before the split"
- `src/dlc/UI/InGame/CivVAccess_TradeLogicAccess.lua:221,237` — "file-locals in the pre-split file" + "Re-exports so any caller that previously reached for ... still works"
- `src/dlc/UI/InGame/CivVAccess_TradeLogicAvailable.lua:1` — "Available-tab item builder for the diplomacy trade screen, peeled out ..."
- `src/dlc/UI/InGame/CivVAccess_TradeLogicOffering.lua:1` — "Offering-tab item builder for the diplomacy trade screen, peeled out ..."
- `src/dlc/UI/InGame/CivVAccess_CursorActivate.lua:16` — "matches what Cursor.activate used to do inline"
- `src/dlc/UI/InGame/CivVAccess_UnitTargetMode.lua:575` — "Replaces a blanket UI.CanDoInterfaceMode gate ..."
- `src/dlc/UI/InGame/CivVAccess_UnitControlMovement.lua:495` — "Replaces the prior 2-tick frame-count expiry timer ..."
- `tests/menu_widgets_test.lua:1` — "Peeled out of menu_test.lua ..."
- `tests/menu_lifecycle_test.lua:1` — "Peeled out of menu_test.lua ..."
- `tests/menu_interactions_test.lua:1` — "Peeled out of menu_test.lua."
- `tests/menu_structure_test.lua:1` — "Peeled out of menu_test ..."

Why it matters: These rationale-by-history blocks make a future reader (or future Claude session) look up files that no longer exist or no longer matter. The information that *is* load-bearing — what the file owns, why a given choice was made — is usually preserved in the surrounding sentences, so the cuts are surgical.

The two `Replaces ...` blocks in `UnitTargetMode` and `UnitControlMovement` are the most rationale-rich cases: each one explains a real, current invariant (commitFailureReason returns nil/key/false specifically because UI.CanDoInterfaceMode returns false for queued moves; the move-result listener uses dispatch-event filtering specifically because the prior frame-count timer false-fired in MP). The current-state explanation can stay; the "Replaces ..." framing should be rewritten as forward-facing rationale.

Proposed fix: rewrite each header to describe the file's current responsibility and any non-obvious invariants, dropping the "peeled out / pre-split / replaces / used to" framing. Keep the technical content where it explains a current invariant (e.g. the MP-network race rationale in UnitControlMovement). Single commit per file is fine; or one bundled "drop change-history comments" commit. Tests don't need to change, so the menu_*_test edits are pure header rewrites.

Risk: low. If we accidentally delete a comment that was actually load-bearing rationale, a reviewer should catch it during the diff. No code changes are involved.

## 2. CLAUDE.md doesn't document the canonical Access wrapper shape (medium-high impact, medium confidence)

87 files in `src/dlc/UI` follow the same shape:

```
-- <one-line purpose>
include("CivVAccess_Polyfill")        -- (or FrontendCommon for FE)
include("CivVAccess_Log")
... include chain ...
local priorInput = InputHandler
local priorShowHide = ShowHideHandler
BaseMenu.install(ContextPtr, {
    name, displayName, preamble, priorInput, priorShowHide, items, ...
})
```

Every overridden vendor `.lua` file appends a single `include("CivVAccess_XAccess")` line at the bottom (108 files do this, not the 4 listed in the "Bootstrap override surfaces" section).

Where this is documented: the BaseMenu spec is in the header of `src/dlc/UI/Shared/CivVAccess_BaseMenuInstall.lua` (and `CivVAccess_BaseMenuCore.lua`), which is excellent doc but discoverable only by knowing where to look.

Where it isn't documented: root CLAUDE.md says the mod "installs UI handlers via ContextPtr, Events.X, and LuaEvents.X" but never describes the wrapper shape, never points at BaseMenuInstall as the canonical install entry point, and never mentions the vendor-file-include convention by name.

Why it matters: a contributor adding the 88th wrapper has to read example wrappers first. CLAUDE.md is the place a future contributor or LLM session looks for project conventions, and conventions repeated 87 times deserve a sentence there. This is the single most leveraged docs gap I found.

Proposed fix: add a short "Access wrappers" subsection under "Project Structure" or "Code Style" in root CLAUDE.md, naming:

- The wrapper file lives next to the vendor file (`src/dlc/UI/.../CivVAccess_XAccess.lua` next to `X.lua`).
- The vendor file appends one line (`include("CivVAccess_XAccess")`) at the bottom; this is how the mod loads.
- The wrapper captures `priorInput` / `priorShowHide` from the vendor file's globals, then calls `BaseMenu.install(ContextPtr, spec)`.
- Read `CivVAccess_BaseMenuInstall.lua`'s header for the spec fields.

Risk: low. Pure docs change. The wrapper shape is real and consistent enough across 87 files to call it canonical.

## 3. "Bootstrap override surfaces" section is misleadingly narrow (medium impact, high confidence)

Root CLAUDE.md lines 99-111 describe four overridden vendor files (WorldView, InGame, ToolTips, plus the implicit FrontEnd setup). The section header and text invite the read "these are the files we override." In fact `src/dlc/UI` ships 108+ overridden vendor files (find: any non-`CivVAccess_*` `.lua` file in `src/dlc/UI` that includes a `CivVAccess_*` module — that's the count).

The section is technically correct: it's about *bootstrap-special* overrides — the ones that carry additional `include` lines beyond the standard `include("CivVAccess_XAccess")` tail. But a contributor reading the section in isolation would not know that.

Why it matters: combined with finding 2, a contributor who reads CLAUDE.md and then looks at the FE Access wrapper directory sees ~40 unfamiliar-looking files and has to reverse-engineer the override convention from scratch. The section also doubles as the explanation for *why* `WorldView/WorldView.lua` is special (boot seat, env-wipe survival), which is the high-value content; folding the general convention in here gives that content room to breathe.

Proposed fix: rename the section to something like "Vendor override conventions" and split into two parts:

1. The convention: every `CivVAccess_XAccess.lua` is reached by appending `include("CivVAccess_XAccess")` to a verbatim copy of `X.lua`. There are ~108 such overrides; the wrappers themselves drive everything (the appended include line is the only mod content in the vendor file).
2. The bootstrap-special overrides: WorldView (Boot seat + key interception), InGame (key dispatch), ToolTips (frontend bootstrap reach). These are special because they carry *additional* `include` lines beyond the standard tail and because their Context lifetime matters for env-wipe handling.

Risk: low. Pure docs change. Could be combined with finding 2 in one commit.

## 4. FrontEnd has FrontendCommon for include-bundling; InGame Popups don't (medium impact, high confidence)

`src/dlc/UI/FrontEnd/CivVAccess_FrontendCommon.lua` collapses the front-end include chain, and 39 FrontEnd Access files start with a single `include("CivVAccess_FrontendCommon")` line.

`src/dlc/UI/InGame/Popups/` has ~50 wrappers, each of which duplicates the same ~21-line include chain (Polyfill / Log / TextFilter / locale strings / Text / Icons / SpeechEngine / SpeechPipeline / HandlerStack / InputRouter / TickPump / Nav / BaseMenuItems / TypeAheadSearch / BaseMenuHelp / BaseMenuTabs / BaseMenuCore / BaseMenuInstall / BaseMenuEditMode / Help / etc.). No equivalent `CivVAccess_PopupCommon.lua` exists.

This is the same finding the low-level fork raised as a deferred item. The docs angle is that CLAUDE.md doesn't acknowledge the asymmetry. Either:

- The asymmetry is intentional (some Popups need different load orders or extra includes), in which case it should be documented.
- It's incidental, in which case the deferred PopupBoot refactor item gets ratified.

Why it matters: a contributor adding a popup wrapper sees 21 lines of boilerplate at the top of every existing popup, copies the pattern, and the new file is the 51st copy. The boilerplate is also the place where stem-prefix-collision bugs hide (see CLAUDE.md "include stems must not share a prefix"); centralizing it once means correctness is checked once.

Proposed fix: ship the deferred `CivVAccess_PopupBoot.lua` (or `CivVAccess_InGameCommon.lua`, choose a name that won't prefix-collide). This is a refactor, not a pure docs change, but the docs gap motivates it. Risk: medium — must verify the new stem doesn't prefix-collide with any existing file in any Context's VFS (CLAUDE.md gotcha); and a few popups have additional includes (Civilopedia*, etc.) that would need to live alongside the bundle reference.

If we don't do the refactor, the docs gap should still be filled with a one-liner in CLAUDE.md noting the asymmetry and pointing future contributors at the reason.

## 5. Stale "this phase wires only ..." language in CityViewAccess.lua header (low impact, low risk)

`src/dlc/UI/InGame/CityView/CivVAccess_CityViewAccess.lua:6-8`:

> This phase wires only the hub scaffold: preamble announcement, F1 re-read, Esc close, next / previous city hotkeys, and auto-re-announce on city-change. Hub items and sub-handlers are added in later phases.

This was true during initial development but is wholly stale now — the file is fully developed with hub items and sub-handlers all in place (the file has 1188 lines and references buildHubItems further down). The phrase "This phase ... in later phases" reads like a placeholder a developer left during incremental implementation.

This is a subset of finding 1 (it's a CityView header issue) and would be covered by the same rewrite pass.

## 6. Misc verified-clean items (no fix needed)

These were checked and are healthy; calling them out so the user knows the audit reached them.

- **TXT_KEY discipline**: 146 SpeechPipeline calls across 53 files. Zero use bare string literals; every call passes a `Text.key` / `Text.format` result, a `Locale.ConvertTextKey` result, or a Controls:GetText handle. CLAUDE.md "no inline non-punctuation string literals" is upheld.
- **Comments referring to current task / fix / "added for X flow"**: zero matches in mod-authored code. Clean.
- **TODO/FIXME/XXX/HACK markers**: zero in `src/dlc/UI/CivVAccess_*.lua` and zero in `tests/`. Vendor files have a handful (LoadMenu, StagingRoom, OptionsMenu, Lobby, DiploCorner) which we don't own.
- **Files lacking a top-of-file header**: only Boot.lua and FrontendBoot.lua. Both are clearly entry-points and have well-commented inline rationale at the relevant points.
- **docs/llm-docs/_civvaccess_fork.md** matches current `CIVVACCESS:` markers in `src/engine/` (regenerated during information-gathering per current_status.md).
- **HandlerStack header, BaseMenuInstall header, PullDownProbe header, Polyfill header**: all model documentation. They describe current invariants, list spec fields, and explain the non-obvious mechanisms (env-wipe, metatable patching, sandbox boundaries) without history references.

## Recommended order if landing fixes

1. Findings 2 + 3 in one commit — purely additive CLAUDE.md edits, no code change.
2. Finding 1 in one or two commits — header rewrites across ~12 files. Tests don't change. Single commit is fine since each file is small.
3. Finding 4 either as the deferred PopupBoot refactor (a separate, larger work item) or as a one-line CLAUDE.md note acknowledging the asymmetry. The user should choose.

## Items NOT raised (deliberately out of scope)

- Wording / string content of mod-authored speech output. Out per llm-entrypoint.
- Code refactors beyond docs concerns. The PopupBoot refactor surfaces here only because the docs gap motivates it; the actual refactor work is a separate decision.
- Vendor-base-game files. Out per the directive.
- The `// CIVVACCESS:` markers in the engine fork — already current per `_civvaccess_fork.md`.
