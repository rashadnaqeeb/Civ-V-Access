# CLAUDE.md audit (root project file)

Branch: claude-mod-cleanup. No commit made; orchestrator will commit.

## Verified accurate

- All three build scripts at repo root (`build-proxy.ps1`, `build-engine.ps1`, `deploy.ps1`) exist and their descriptions match what they actually do.
- `dist/proxy/lua51_Win32.dll`, `dist/engine/CvGameCore_Expansion2.dll`, `third_party/tolk/dist/x86/`, `third_party/lua51/lua5.1.exe`, `build/sdk7-install/install.cmd` all exist as claimed.
- `tests/run.lua` exists and dofiles `src/dlc/UI/InGame/CivVAccess_Polyfill.lua` before suites.
- `CivVAccess_Polyfill.lua` self-disables in-game with the `if ContextPtr ~= nil then return end` sentinel (split across lines, semantics identical).
- `docs/hotkey-reference.md`, `docs/llm-docs/CLAUDE.md`, `docs/llm-docs/lua-api/`, `docs/llm-docs/txt-keys/ui-text-keys.md` all present.
- `src/dlc/UI/Shared/CivVAccess_HandlerStack.lua` exists; `CivVAccess_BaseMenuCore.lua` and the colliding `CivVAccess_BaseMenuItems.lua` both exist (the prefix-collision example is real).
- Bootstrap override surfaces: `src/dlc/UI/InGame/WorldView/WorldView.{lua,xml}` present and the lua tail does append `include("CivVAccess_Boot")` then `include("CivVAccess_WorldViewKeys")`. `src/dlc/UI/InGame/InGame.lua` present and appends `include("CivVAccess_InGameKeys")`. `src/dlc/UI/InGame/InGame.xml` correctly absent. `src/dlc/UI/FrontEnd/ToolTips.{lua,xml}` present and lua tail appends `include("CivVAccess_FrontendBoot")`.
- Vanilla SDK `CvLuaUnit.cpp` line 569 does ship `Unit:GeneratePath` as `luaL_error("NYI")` — confirmed against the installed SDK source.
- `civvaccess_shared` is set by the proxy (`src/proxy/proxy.c`).
- `Lua.log` is written to `%USERPROFILE%\Documents\My Games\Sid Meier's Civilization 5\Logs\Lua.log` — directory verified.

## Corrected

1. **"One BNW-only manifest" was wrong.** There are three sibling `.Civ5Pkg` files — `CivVAccess_0/1/2.Civ5Pkg` — sharing one GUID, one per UISkin set (BaseGame, Expansion1, Expansion2). Only `CivVAccess_2` carries the functional payload; the other two are empty-directory CTD-prevention sentinels (per the header comment in `CivVAccess_0.Civ5Pkg`, the engine CTDs in tutorials and vanilla-era scenarios when our DLC is active without all three manifests). Updated both the Project Structure entry for `src/dlc/` and the Architecture Gotchas "One Civ5Pkg manifest" bullet to describe the three-manifest pattern, the shared GUID, the sentinel role of the two probes, and that BNW-gating still applies to the *payload* even though the manifests themselves co-activate.

2. **`CIVVACCESS:` markers are not confined to two files.** CLAUDE.md said "currently in `CvLuaUnit.cpp` and `CvLuaGame.cpp`". Actual count: 29 markers across 10 files — the Lua bindings (`CvLuaUnit.cpp/h`, `CvLuaGame.cpp`, `CvLuaPlot.cpp/h`) plus core engine files where the binding implementations live (`CvUnit.cpp`, `CvPlayer.cpp`, `CvPlot.cpp`, `CvUnitCombat.cpp`, `CvDllNetMessageHandler.cpp`). Rewrote the gotcha to describe the category ("the Lua bindings under `CvGameCoreDLL_Expansion2/Lua/` plus a few core engine files where the binding's implementation lives") and tell readers to grep `CIVVACCESS:` rather than enumerating filenames. Per the user's "no stale-magnet enumerations" preference.

3. **`deploy-sighted-multiplayer.ps1` was undocumented.** Exists at the repo root with a substantive purpose (minimal MP-partner deploy: engine DLL + empty-UI manifest only). Added a fourth bullet under the Build section describing it.

## Flagged for user

Nothing blocking. A few things noted but left as-is:

- The Project Structure `src/dlc/` paragraph lists `UI/InGame/`, `UI/FrontEnd/`, `UI/TechTree/`, `UI/Shared/` as the per-Context dirs. Two more exist (`UI/SkinProbeBase/`, `UI/SkinProbeG/`) but they're each one-line probe scripts referenced only by the sentinel manifests — the corrected `src/dlc/` paragraph mentions them in passing. The `e.g.` qualifier in the original list still reads correctly.
- The Project Structure section also doesn't mention `tools/`, `sounds/`, `leader images/`, `lint.ps1`, `stylua.toml` at the repo root. None of these are referenced anywhere in CLAUDE.md and they're either obvious (sounds, lint) or already covered functionally (leader images is consumed by the leader-descriptions doc tooling). Not adding them would be padding the structure section into a snapshot rather than a guide.
- The `civvaccess_shared.flagInstalled` boolean named in the no-install-once-guards gotcha is illustrative — grep finds zero hits in `src/dlc/`, which is the *point* (the gotcha is telling future contributors not to introduce that pattern). Leave as-is.
- "VS 2026's `cl.exe`" in the build-proxy.ps1 description is an unusual phrasing (no Visual Studio 2026 release exists at the audit cutoff; user likely means the current VS build chain installed on this machine). Did not edit — this is the user's own toolchain naming and they would know if it's wrong.
