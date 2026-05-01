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

## Prompts pending

1. `low-level-cleanup.md` (just started, NOT yet executed) — paused before launching subagents. The plan was to spawn 6 area-based subagents (Shared+proxy, FrontEnd, InGame top-level, Popups, InGame sub-dirs+TechTree, tests) to scan for high-impact / low-risk cleanup candidates, synthesize a curated top-15 list, present to user for approval, then execute. The user requested compaction before launching.
2. `high-level-cleanup.md` (after low-level)
3. `finalization.md` (last per the workflow's chain — verify by checking each prompt's "Up Next" footer)

## Resuming after compaction

The user will prompt with something like "resume the refactoring workflow". When that happens:
1. Re-read `/tmp/llm-mod-refactoring-prompts/llm-entrypoint.md` if needed.
2. Re-read `/tmp/llm-mod-refactoring-prompts/prompts/low-level-cleanup.md` (the next stage).
3. Confirm with user whether to launch the analysis subagents (per the plan above) or take a different approach.

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
