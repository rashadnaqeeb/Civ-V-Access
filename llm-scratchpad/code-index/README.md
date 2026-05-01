# Code index

Per-file declaration outlines for every mod-authored source file in this repo. Generated during the `code-directory-construction.md` step of the refactoring workflow at `https://github.com/ahicks92/llm-mod-refactoring-prompts`. The index is a navigation aid: open any `<source-path>.md` to see the file's top-of-file comment, its declarations in order with line numbers, and notes on anything subtle.

## What's indexed

292 files total:

- `src/proxy/proxy.c` (1) — the Lua 5.1 proxy DLL.
- `src/dlc/UI/**/CivVAccess_*.lua` (228) — every mod-authored Lua file under the DLC payload, including Shared infra, FrontEnd Access wrappers, InGame top-level, Popups, sub-dirs (CityView, LeaderHead, Menus, WorldView), TechTree, and the SkinProbe sentinel shims.
- `tests/*.lua` (64) — every test suite plus the runner (`run.lua`) and the shared helpers (`support.lua`).

Scope mirrors the source tree exactly. `<repo>/src/dlc/UI/Shared/CivVAccess_Log.lua` indexes to `code-index/src/dlc/UI/Shared/CivVAccess_Log.lua.md`.

## What's NOT indexed, and why

- **Vendor base-game overrides** under `src/dlc/UI/` (110 files: `WorldView.lua`, `InGame.lua`, `ToolTips.lua`, `CivilopediaScreen.lua`, `CityView.lua`, `TradeLogic.lua`, the Popups originals, etc.). These are verbatim copies of base Civ V files with a single `include("CivVAccess_X")` line appended; the bodies are vendor code we never refactor. Read them in place when needed.
- **Engine fork overlay** under `src/engine/CvGameCoreDLL_Expansion2/` (~12 files). Same logic: verbatim Firaxis SDK source with our `// CIVVACCESS:` patches. The patches themselves are catalogued at `docs/llm-docs/lua-api/_civvaccess_fork.md`; grep `CIVVACCESS:` in `src/engine/` for the canonical list.
- **Build scripts, lint config, third-party DLLs, dist artifacts.** Not source we author.

## Format

Each `.md` file follows:

```
# `<source path>`

<line count> lines · <one-sentence purpose>

## Header comment

<verbatim top-of-file comment block, or "(none)">

## Outline

- L<N>: <symbol declaration>
...

## Notes
- L<N> `<symbol>`: <note when name is misleading or behavior is non-obvious>
```

The `Notes` section is omitted entirely when there's nothing subtle to flag.

For locale string files (`CivVAccess_*Strings_*.lua`), the Outline is abbreviated to a count of string assignments rather than enumerating each.

## When to regenerate

This index is workflow scratch — it stays accurate only as long as the source files don't drift much. The right time to rerun is at the start of a future refactoring pass, not on every commit. Live grep against the source is always authoritative; the index is for orientation.
