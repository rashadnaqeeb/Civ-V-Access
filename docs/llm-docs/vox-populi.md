# Vox Populi support reference

Durable reference for the Vox Populi (VP) layer of Civ V Access. Hand-authored, not extracted; the canonical sources are the code and tooling it points at (grep `CIVVACCESS:` in the fork, read `tools/vendoring/manifest.json`, read the deploy scripts). This file holds the facts that stay true across releases. Anything dated, version-pinned, or framed as "remaining work" belongs in working notes, not here. The current supported VP version is recorded as `supported_vp` in `versions.json`, not in prose.

## Support model

VP support reuses the entire vanilla accessibility layer (proxy, Tolk, DLC payload, wrappers, speech pipeline) and adds three things on top:

- A fork of LoneGazebo/Community-Patch-DLL in place of our vanilla engine fork. VP loads its gameplay DLL from `MODS\(1) Community Patch\CvGameCore_Expansion2.dll` (or the embedded copy inside a modpack), so that is where the fork is placed, not the game-install root. The fork inherits VP's GUID and never changes it.
- The EngineData seam, which absorbs every read whose value or shape differs between vanilla and VP, plus every binding only the fork adds.
- A per-engine vendor-override tree, generated from a manifest rather than hand-edited, so the same screen wrapper compiles against vanilla or VP bodies.

Packaging stays a DLC, as on vanilla. There are two VP delivery shapes: a mod overlay (our DLC plus our files overlaid into the installed CP and VP mod folders, because mod-shipped stems shadow DLC overrides in the VFS) and a baked DLC modpack (CP and VP merged into `Assets/DLC`, launched from Single Player). The modpack is the multiplayer-capable endgame and dissolves the mod-beats-DLC VFS problem; the mod overlay is the lighter iteration path. Multiplayer for VP uses the modpack; sighted partners install the fork DLL plus an empty-DLC manifest. Stock-VP partners (no fork) are not a goal.

## Install states are mutually exclusive

A machine is in exactly one install state at a time: vanilla, VP mod-overlay, or VP modpack. The deploy scripts flip between them. The running session type must match the last deploy. The dangerous direction is a VP-state install run as a vanilla (or wrong-mode) session: the VP-sourced overrides call VP-only bindings and the player hears silent wrong numbers rather than a loud failure. Always re-state which deploy an install last received before trusting its speech.

The VP modpack is the only play/test state for VP. The VP mod-overlay is now a maintainer-only build step, used during a re-pin to generate the merged database and smoke-test the fork; it is not a play state. Its saves cannot be loaded by the modpack (different active DLC and mod set), and a player who lands in it by accident gets a hard crash on loading a modpack save. To enforce this, `deploy-vp.ps1` refuses to install without `-RepinBuild` (`-Uninstall` is exempt); `resync-vp.ps1` passes the flag during a re-pin and ends by flipping back to modpack state via its `modpack` phase. Players and testers only ever run `deploy-modpack.ps1`.

## The EngineData seam

`CivVAccess_EngineData.lua` is the single chokepoint for engine-divergent data. The vanilla body is at `src/dlc/UI/InGame/CivVAccess_EngineData.lua`; deploy swaps in `src/vp/CivVAccess_EngineData.lua` under the same include stem for VP. Rules:

- Only named intents cross the seam. No engine constant, raw getter name, or times-100 convention leaks through it in either direction. A consumer asks the seam for a meaning ("approval summary", "support used", "owned religion"); the seam body knows the engine-specific getter.
- Extension bindings (anything only the fork registers) are gated on `forkPresent()`, so a stock-VP install with no fork DLL degrades to a reduced-but-numerically-correct beta instead of erroring.
- `tests/engine_data_vp_test.lua` pins set parity between the two bodies plus the VP conversions. Add a new seam function to both bodies and to that test together.
- The lint seam guard (in `lint.ps1`) fails the build on a raw drifted-getter or fork-binding call made outside EngineData. It is two-tier: a per-file `civvaccess-seam-exempt` marker on a VP-only screen waives the drift sweep only, never the fork sweep. When a re-pin newly drifts a getter, add its name to the guard's list.

When in doubt about whether a read needs the seam: if the value, its scale, or its meaning can differ under VP, route it; if it is identical CP-and-vanilla data, read it directly.

## Capability probes

Prefer feature detection over engine flags. The three probes, in increasing specificity:

- `forkPresent()` — our fork DLL is loaded (our bindings resolve).
- `Game.IsCustomModOption ~= nil` — the Community Patch DLL is present. True under BOTH CP-only and full VP, so it does not distinguish balance-on from balance-off.
- `Game.IsCustomModOption("BALANCE_VP")` — VP balance mode is actually on. This is the precise discriminator; the vendor UIs gate on it too.

Beyond these, probe for the concrete capability you need: function presence, control presence, DLL-injected enum tables. A bare "CP present" probe used where "balance on" was meant is the classic conflation bug.

## VP engine facts that constrain work

These are properties of VP's engine and data; they do not change between our releases.

- Happiness is an approval model, not a surplus model. Vanilla's surplus getters are gutted under VP (zeros, or a 0-100 percentage). The seam crosses this as a tagged summary whose consumers branch on mode; the legacy surplus-breakdown getters error loudly if reached under VP balance.
- Yields, culture, tourism, faith, science, influence, and combat XP are stored times-100 internally. Most bare legacy getters already divide and floor (matching what VP's own panels show), so reading the bare getter is usually correct. The exceptions are the raw times-100 getters (notably city base tourism); those cross the seam raw and the consumer divides. When touching a city-yield speaker, audit for the truncation either way.
- Path nodes differ: VP's per-node turn is 0-based (vanilla is 1-based; conversions add 1), and VP's "invisible" node field is current visibility, not revealedness, so revealed state is re-queried live at conversion time. VP's stock path bindings do not accept flags, so path intents are name-validated but cannot always be applied; pathfinding degrades accordingly on stock VP.
- Defender-side fire support is disabled by default in VP; the attacker-side volley exists on both engines and is spoken on both.
- Columns that are nil-clean on vanilla can be nil under VP's data: several VP uniques replace nothing, so LEFT-JOIN "replaces" columns come back nil for playable civs. Treat vanilla-verified-non-nil DB columns as nullable until checked against VP's database.

VP's merged game and text databases are queryable offline after a modded session at `cache/Civ5DebugDatabase.db` (gameplay) and `cache/Localization-Merged.db` (text). Offline DB queries beat in-game guessing for root-causing nil reads and text bugs.

## Patterns to carry forward

- CP/VP screens often auto-focus an EditBox where vanilla did not. A focused EditBox eats arrows, Tab, and letters until Enter releases it. Symptom: navigation dead on open, alive after pressing Enter. Fix: remove the focus trap in the screen's show path (check the engine copy for a TakeFocus call).
- CP screens may own `ContextPtr:SetUpdate`, which is replace-semantics and can unhook the deferred-speech tick pump. When wrapping a CP screen that calls SetUpdate, re-arm the tick from the screen's own update scheduler.
- Promote vendor locals via an edit recipe rather than mirroring their data. Mirrored tables drift across re-pins; promoted vendor functions and tables cannot, and a recipe fails loudly at generate time when a re-pin moves its anchor (that is the designed signal).
- Vendor labels stay vendor labels. VP's own text bugs are visible to sighted players too; leave them for an upstream fix. Accessibility is not curation.
- Regenerate vendor overrides from pristine sources. A deployed install carries our overlay, so `generate --engine vp` must source from the clone (or a freshly re-synced MODS tree). The clone is the single pristine reference for both generation and overlay restore.
- Read the engine copies (CP body, vanilla body, our wrapper) in full before any design decision. Agent fan-out summaries orient; they do not decide, and they have missed load-bearing facts on refit screens.
- The engine ignores modinfo md5 attributes, so overlaid mod files activate without md5 rewriting.
- Run the DLL canary (`py tools/vp_dll_canary.py <dll>`) after every engine rebuild; it guards a clang/VC9 varargs miscompile. GOOD or the DLL does not ship.
- Known noise, do not chase: the VPUI_loader Runtime Error at context init is stock-VP behavior (the DLL probes for an optional loader no component ships).

## The vendoring tool

`tools/vendoring/vendor.py` plus `tools/vendoring/manifest.json` model every vanilla override as prefix plus verbatim engine body plus byte-exact edit recipes plus suffix, with per-engine `vp` sub-objects where VP/CP bytes differ from vanilla. Net-new mod Contexts (no vanilla counterpart) are manifest entries scoped with an `engines` list. Commands:

- `verify` reproduces the committed vanilla override tree byte-for-byte; it is the regression gate that vanilla stays green.
- `generate --engine vp --mods "<clone path>"` stages the full VP tree into `build/vendor/vp` with a provenance file and a drift report.

Do not hand-edit a generated vendor override. To change a CP-divergent screen, edit its manifest entry (convert to a generated entry with a hand-authored `vp` sub-object), then regenerate. Feature-detect in the wrapper so the same wrapper is inert on vanilla. Byte-identical XML overrides are dropped outright rather than carried.

## Modpack bake

`tools/modpack/` bakes CP and VP into a single DLC modpack. `dump_db.py` dumps the engine-merged cache DB (the byproduct of a normal modded session) to the merged Override XML; it reads the already-merged DB and never re-implements merge semantics. `build_modpack.py` assembles the package: the Override (dump plus the committed blanking/aux stubs under `tools/modpack/`), the embedded CP and VP mod folders from the clone with the fork DLL, an `InGame.lua` carrying explicit `LoadNewContext` appends for the net-new addin contexts, and the manifest. The modpack DLC wins over the embedded mod copies by a `<Priority>` bump (priority dominates package sort-order). For the modpack path the per-stem overlay content moves into the DLC (the DLC ships the CP/VP-bodied accessible versions, not vanilla placeholders), because there is no MODS overlay to supply them.

## Re-sync runbook

When VP ships a new stable release, re-pin in one cycle. `resync-vp.ps1` (repo root) orchestrates it in resumable phases (`-Phase engine|mods|vendor|finish|modpack`):

1. Engine: rebase the fork's `civvaccess` branch onto the new tag (with a backup snapshot and conflict-abort-and-restore), rebuild with the clang/SDK build script, and run the canary. The canary must report GOOD before the DLL is committed. If upstream bumps its DLL version number, bump our version-immediate to match (the script gates on this).
2. Mods: mirror the installed MODS folders to the clone byte-identical, handling deletions, so the clone stays the pristine reference.
3. Vendor: re-run `verify` (vanilla stays green) then `generate`, and read the drift report.
4. Finish: deploy the VP mod-overlay (passing `-RepinBuild`) and record the new pin (requires an explicit review-confirmed flag). This leaves the install in the transient mod-overlay state, used for the next step.
5. Modpack (terminal): after playing one clean CP+VP session through the Mods menu to produce a fresh merged database (`build-modpack` refuses a modpack-launch cache), `-Phase modpack` bakes the modpack and deploys it, returning the install to the player-facing modpack state where the play audit runs. This is a separate phase because the merged-DB session is a manual step the script cannot perform.

What actually breaks on a re-pin is rarely the C++ rebase. It is the vendoring drift report (new overlaps, signature drift, anchors moved) and the value audit of the Lua-binding diff between the old and new tags (new balance guards in getters we speak). Newly drifted getters go into the lint seam guard's name list.

## Reference inventory

- Fork clone: a sibling checkout of Community-Patch-DLL on branch `civvaccess` (= the pinned Release tag plus a build-script fix plus a small set of port commits: Lua bindings, hooks, the trade-unit name fix). Build from the clone root with the clang/SDK build script, LLVM on PATH.
- Committed artifacts: fork DLL at `dist/engine-vp/`; VP seam body at `src/vp/CivVAccess_EngineData.lua`; vendoring tool and manifest at `tools/vendoring/`; modpack tooling at `tools/modpack/`; canary at `tools/vp_dll_canary.py`. The pin is `supported_vp` in `versions.json`.
- Staged, not committed: `build/vendor/vp/` (vendor stage plus provenance plus drift report); regenerate as above.
- Deploy scripts: `deploy.ps1` (vanilla state), `deploy-vp.ps1` (VP mod-overlay state), `deploy-modpack.ps1` (VP modpack state), plus the sighted-multiplayer variants. The states are mutually exclusive.
- VP logs: `CustomMods.log` is the fork heartbeat (its banner plus the balance cache line prove the fork booted); `modding.log` shows activation cycles; `Lua.log` carries Lua errors and print output.
