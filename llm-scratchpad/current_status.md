# Current Status

Working branch: `claude-mod-cleanup`
Source workflow: `https://github.com/ahicks92/llm-mod-refactoring-prompts` (cloned to `/tmp/llm-mod-refactoring-prompts`)

## Prompts completed

1. `sanity-checks-setup.md` — branch created, scratchpad seeded.
2. `information-gathering-and-checking.md` — root CLAUDE.md and `docs/llm-docs/CLAUDE.md` audited and corrected; `docs/llm-docs/lua-api/_civvaccess_fork.md` regenerated from current `CIVVACCESS:` markers in `src/engine/`. VS toolchain naming clarified after user check.
3. `code-directory-construction.md` — built `llm-scratchpad/code-index/` covering all 291 mod-authored source files (1 proxy.c + 227 src/dlc Lua + 64 tests). Vendor base-game overrides and the engine fork overlay are deliberately excluded; see `code-index/README.md` for scope rationale.

## Prompts pending

1. `large-file-handling.md` — chosen because the indexing pass found multiple files over 2000 lines.
2. (subsequent prompts as named by each prompt's "Up Next")

## Files in llm-scratchpad

- `current_status.md` — this file. Tracks branch, prompts run, and other scratchpad files.
- `claude_md_audit.md` — audit memo for the root CLAUDE.md changes.
- `llm_docs_audit.md` — audit memo for the docs/llm-docs/CLAUDE.md index changes.
- `code-index/` — 291 per-file outline `.md` files mirroring the source tree, plus a top-level `README.md`. See the README for format and scope.

## Notes

- Project: Civ-V-Access — accessibility mod for Civilization V (speech-only interface for blind users).
- Default branch: `main` (was 2 commits ahead of `origin/main` at start; clean tree).
- Treat in-built memory as read-only during this workflow per entrypoint guidance.

## Files >2000 lines (route into `large-file-handling.md`)

Mod-authored:
- `tests/menu_test.lua` (4276)
- `tests/cursor_test.lua` (2202)
- `src/dlc/UI/InGame/CivVAccess_InGameStrings_en_US.lua` (2456) — locale data
- `src/dlc/UI/InGame/CivVAccess_InGameStrings_fr_FR.lua` (2267) — locale data
- `src/dlc/UI/InGame/CityView/CivVAccess_CityViewAccess.lua` (2001)

Vendor (excluded from refactor scope, listed for completeness):
- `src/dlc/UI/InGame/CivilopediaScreen.lua` (7341)
- `src/dlc/UI/InGame/WorldView/TradeLogic.lua` (3469)
- `src/dlc/UI/InGame/CityView/CityView.lua` (2736)
- `src/dlc/UI/InGame/Popups/CultureOverview.lua` (2221)
- `src/dlc/UI/FrontEnd/Multiplayer/StagingRoom.lua` (2021)
