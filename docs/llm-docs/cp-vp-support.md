# Community Patch / Vox Populi support reference

Durable reference for the Community-Patch-DLL support layer of Civ V Access. It covers two play targets that share one engine fork, one EngineData seam body, and one vendor manifest: Vox Populi (VP, the full balance overhaul) and Community-Patch-only (CP-only, the bug-fix/AI DLL with the balance overhaul off). The single most important rule that separates them: the same Community Patch DLL is loaded in both, so DLL-level behavior (binding signatures, times-100 storage, supply, religion transfer, war score, vassalage) is identical; only the *balance data and model* differ, and those differences gate on `Game.IsCustomModOption("BALANCE_VP")`, never on bare CP-DLL presence.

Hand-authored, not extracted; the canonical sources are the code and tooling it points at (grep `CIVVACCESS:` in the fork, read `tools/vendoring/manifest.json`, read the deploy scripts). This file holds the facts that stay true across releases. Anything dated, version-pinned, or framed as "remaining work" belongs in working notes, not here. The current supported version is `supported_vp` in `versions.json`, not in prose; CP-only pins to the same release (it shares the fork DLL and the CP body).

## Support model

VP support reuses the entire vanilla accessibility layer (proxy, Tolk, DLC payload, wrappers, speech pipeline) and adds three things on top:

- A fork of LoneGazebo/Community-Patch-DLL in place of our vanilla engine fork. VP loads its gameplay DLL from `MODS\(1) Community Patch\CvGameCore_Expansion2.dll` (or the embedded copy inside a modpack), so that is where the fork is placed, not the game-install root. The fork inherits VP's GUID and never changes it.
- The EngineData seam, which absorbs every read whose value or shape differs between vanilla and VP, plus every binding only the fork adds.
- A per-engine vendor-override tree, generated from a manifest rather than hand-edited, so the same screen wrapper compiles against vanilla or VP bodies.

Packaging stays a DLC, as on vanilla. There are two VP delivery shapes: a mod overlay (our DLC plus our files overlaid into the installed CP and VP mod folders, because mod-shipped stems shadow DLC overrides in the VFS) and a baked DLC modpack (CP and VP merged into `Assets/DLC`, launched from Single Player). The modpack is the multiplayer-capable endgame and dissolves the mod-beats-DLC VFS problem; the mod overlay is the lighter iteration path. Multiplayer for VP uses the modpack; sighted partners install the fork DLL plus an empty-DLC manifest. Stock-VP partners (no fork) are not a goal.

Community-Patch-only ships as a third delivery: a baked DLC modpack embedding the `(1) Community Patch` folder alone (no `(2) Vox Populi`, no VPUI), with the Community-Patch-only addin set and the cp vendor tree. It reuses the same fork DLL and the same seam body; the body feature-detects the balance mode at runtime, so one body is numerically correct under both. There is no CP mod-overlay shape, the CP modpack is the only CP-only state. CP-only is a beta target: it surfaces what Community Patch provides and degrades the rest (notably, the event subsystem's UI loads but has no data, since events are VP content, and the happiness model is the vanilla surplus model).

## Install states are mutually exclusive

A machine is in exactly one install state at a time: vanilla, VP mod-overlay, VP modpack, or CP modpack. The deploy scripts flip between them, and each flip removes the other states' artifacts (e.g. `deploy.ps1` removes both modpack packages, the modpack deploys remove both packages before placing the active one, so the package list never carries two engines' Override databases at once). The running session type must match the last deploy. The dangerous direction is a modded-state install run as the wrong mode: the engine merges a mismatched database (the `no such column: Type` on `Natural_Wonder_Placement` signature) or the overrides call bindings that resolve to the wrong values, and the player hears silent wrong numbers or a hard crash rather than a clean failure. Always re-state which deploy an install last received before trusting its speech. The install manifest (`Assets/DLC/DLC_CivVAccess/CivVAccess.install.json`) records the `variant` (`vanilla` / `modpack` / `modpack-cp`).

The VP modpack is the only play/test state for VP, and the CP modpack the only state for CP-only. The VP mod-overlay is now a maintainer-only build step, used during a re-pin to generate the merged database and smoke-test the fork; it is not a play state. Its saves cannot be loaded by the modpack (different active DLC and mod set), and a player who lands in it by accident gets a hard crash on loading a modpack save. To enforce this, `deploy-vp.ps1` refuses to install without `-RepinBuild` (`-Uninstall` is exempt); `resync-vp.ps1` passes the flag during a re-pin and ends by flipping back to modpack state via its `modpack` phase. Players and testers only ever run `deploy-modpack.ps1` (VP) or `deploy-modpack-cp.ps1` (CP-only).

Producing a CP-only merged database is a manual step with no mod-overlay shortcut: flip to vanilla (`deploy.ps1`), enable ONLY `(1) Community Patch` through the Mods menu (Vox Populi disabled), start a game and let it load to the map, then quit. That writes a CP-only cache (`BALANCE_VP` off) the bake reads. The VP modpack's database comes from a CP+VP session instead, so the two modpacks cannot be baked from one cache run.

## The EngineData seam

`CivVAccess_EngineData.lua` is the single chokepoint for engine-divergent data. The vanilla body is at `src/dlc/UI/InGame/CivVAccess_EngineData.lua`; every CP-DLL deploy (VP mod-overlay, VP modpack, CP modpack) swaps in `src/vp/CivVAccess_EngineData.lua` under the same include stem. There is no separate CP-only body: the VP body branches internally on `balanceVP()` for the handful of reads that are balance-model-specific (the happiness summary, the legacy surplus-breakdown getters), so it is correct under CP-only as-is. Rules:

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

Beyond these, probe for the concrete capability you need: function presence, control presence, DLL-injected enum tables. A bare "CP present" probe used where "balance on" was meant is the classic conflation bug, and it is the dominant failure class when adding CP-only support to code written for VP. It is silent on VP (where both probes are true) and only bites under CP-only. Two concrete shapes seen and fixed:

- A wrapper surfaces a VP-balance-model value gated on `Game.IsCustomModOption ~= nil`. Under CP-only the value is computed but meaningless (the active model is different), so the player hears a wrong number. Examples: the per-city aggregated unhappiness (`GetUnhappinessAggregated`) spoken on the cursor and as the Economic Overview's third Cities column, and the CityView corporations group (corporations are a VP-only system). The fix is to gate on `BALANCE_VP` (or, in the Economic Overview, on the seam's `happinessSummary().mode == "approval"`). The discriminator for "is this a real DLL value or a balance-model artifact": read the DLL source, a value is DLL-level (keep the bare CP probe) if it is computed unconditionally; it is balance-level (needs `BALANCE_VP`) if it is `MOD_BALANCE`-guarded or only fed into the total under the balance model.
- A vendor edit recipe scoped to the `vp` sub-object silently skips CP-only, even when CP ships the identical body (Vox Populi does not override the file, so both engines resolve to the Community Patch copy). Generate succeeds, but the edit, e.g. a `local`-to-global promotion, never applies under cp, and the global is nil at runtime. The fix is the `cp: {"alias": "vp"}` mechanism (see the vendoring tool). Find these with the report-root comparison: any entry with `vp` edits where cp and vp resolve to the same root needs the alias.

## CP/VP engine facts that constrain work

These are properties of the engine and data; they do not change between our releases. Unless a bullet says "VP balance", the fact holds under CP-only too (same DLL).

- Happiness is an approval model, not a surplus model. Vanilla's surplus getters are gutted under VP (zeros, or a 0-100 percentage). The seam crosses this as a tagged summary whose consumers branch on mode; the legacy surplus-breakdown getters error loudly if reached under VP balance.
- Yields, culture, tourism, faith, science, influence, and combat XP are stored times-100 internally. Most bare legacy getters already divide and floor (matching what VP's own panels show), so reading the bare getter is usually correct. The exceptions are the raw times-100 getters (notably city base tourism); those cross the seam raw and the consumer divides. When touching a city-yield speaker, audit for the truncation either way.
- Path nodes differ: VP's per-node turn is 0-based (vanilla is 1-based; conversions add 1), and VP's "invisible" node field is current visibility, not revealedness, so revealed state is re-queried live at conversion time. VP's stock path bindings do not accept flags, so path intents are name-validated but cannot always be applied; pathfinding degrades accordingly on stock VP.
- Defender-side fire support is disabled by default in VP; the attacker-side volley exists on both engines and is spoken on both.
- Columns that are nil-clean on vanilla can be nil under VP's data: several VP uniques replace nothing, so LEFT-JOIN "replaces" columns come back nil for playable civs. Treat vanilla-verified-non-nil DB columns as nullable until checked against VP's database.

The merged game and text databases are queryable offline after a modded session at `cache/Civ5DebugDatabase.db` (gameplay) and `cache/Localization-Merged.db` (text); a CP-only session writes a CP-only database the same way. Offline DB queries beat in-game guessing for root-causing nil reads, text bugs, and the DLL-level-vs-balance-level question (check whether a getter's data is present and whether an option's `BALANCE_VP` value is 0).

Community-Patch-only specifics (BALANCE_VP off, same DLL):

- Happiness is the vanilla surplus model. `happinessSummary().mode` is `surplus`; the vanilla-model breakdown getters are valid here (they error only under VP balance). Per-city aggregated unhappiness does not apply.
- DLL-level behavior is identical to VP and correct under CP-only: times-100 yield/tourism/culture storage, the supply model, religion control transfer with the holy city, war score, the vassalage mechanic, historic-event tourism, separate city ranged-strike strength, third-party defensive pacts, and the minor-allies / military-size victory-score components (those are part of `GetScore()` unconditionally). These read directly or through the seam with the bare CP probe.
- The event subsystem loads but is inert: Community Patch ships the event framework (the `GAMEOPTION_*_EVENTS` options, the popup and overview UI it registers) but the event content (the `Events` / `EventChoices` / `CityEvents` / `CityEventChoices` tables) is Vox Populi data, empty under CP-only. So no event ever fires, the Events Overview is a dead screen, and its tab-label keys (`TXT_KEY_EVENT_OVERVIEW` and siblings) are VP-text-only and render as raw keys, an upstream Community Patch quirk visible to sighted players too.
- Corporations and the random-victory popup are VP-only systems whose screens Community Patch does not register, so the CP modpack never loads them and their chords gate on `BALANCE_VP`. Vassalage is the inverse: the mechanic is in the CP DLL (works if the game option is on) but the VassalageOverview UI is a Vox Populi addin, so CP-only has the mechanic without the overview.
- Many overview screens (Economic, Military, Trade Route, Victory Progress, Diplo Relationships, Social Policy) ship a vanilla body under CP-only because Vox Populi, not Community Patch, overrides them; their wrappers were built inert-on-vanilla and degrade automatically. A few revert to a Community Patch body instead (EspionageOverview keeps the coup model, LeaderHeadRoot keeps its WarScore control, CityStateDiploPopup), where the wrapper's feature-detection (function/control presence) is what makes it adapt. The vendor report's root comparison (cp vs vp) is the authoritative list of which body a screen resolves to.

## Patterns to carry forward

- CP/VP screens often auto-focus an EditBox where vanilla did not. A focused EditBox eats arrows, Tab, and letters until Enter releases it. Symptom: navigation dead on open, alive after pressing Enter. Fix: remove the focus trap in the screen's show path (check the engine copy for a TakeFocus call).
- CP screens may own `ContextPtr:SetUpdate`, which is replace-semantics and can unhook the deferred-speech tick pump. When wrapping a CP screen that calls SetUpdate, re-arm the tick from the screen's own update scheduler.
- Promote vendor locals via an edit recipe rather than mirroring their data. Mirrored tables drift across re-pins; promoted vendor functions and tables cannot, and a recipe fails loudly at generate time when a re-pin moves its anchor (that is the designed signal).
- A `vp` edit recipe on a Community-Patch-shipped file must also apply under cp, since both engines resolve to that same CP body. Use `cp: {"alias": "vp"}` rather than duplicating the edits, so a re-pin maintains one recipe. The failure mode if you forget is silent (generate passes, the global is nil only at runtime under CP-only); the report-root comparison catches it offline.
- Vendor labels stay vendor labels. VP's own text bugs are visible to sighted players too; leave them for an upstream fix. Accessibility is not curation.
- Regenerate vendor overrides from pristine sources. A deployed install carries our overlay, so `generate --engine vp` must source from the clone (or a freshly re-synced MODS tree). The clone is the single pristine reference for both generation and overlay restore.
- Read the engine copies (CP body, vanilla body, our wrapper) in full before any design decision. Agent fan-out summaries orient; they do not decide, and they have missed load-bearing facts on refit screens.
- The engine ignores modinfo md5 attributes, so overlaid mod files activate without md5 rewriting.
- Run the DLL canary (`py tools/vp_dll_canary.py <dll>`) after every engine rebuild; it guards a clang/VC9 varargs miscompile. GOOD or the DLL does not ship.
- Known noise, do not chase: the VPUI_loader Runtime Error at context init is stock-VP behavior (the DLL probes for an optional loader no component ships).

## The vendoring tool

`tools/vendoring/vendor.py` plus `tools/vendoring/manifest.json` model every vanilla override as prefix plus verbatim engine body plus byte-exact edit recipes plus suffix, with per-engine `vp` and `cp` sub-objects where the modded bytes differ from vanilla. The engine source chains: `vp` resolves `(2) Vox Populi` then `(1) Community Patch` then VPUI then vanilla; `cp` resolves `(1) Community Patch` then vanilla only (no Vox Populi, no VPUI), so a file Vox Populi overrides but Community Patch does not falls through to its vanilla body under cp. Net-new mod Contexts (no vanilla counterpart) are manifest entries scoped with an `engines` list; CP ships fewer net-new screens than VP (it registers the event UI but not Corporations / Vassalage / RandomVC), so those entries list the engines they exist on. Commands:

- `verify` reproduces the committed vanilla override tree byte-for-byte; it is the regression gate that vanilla stays green.
- `generate --engine vp --mods "<clone path>" --clone "<clone path>"` stages the full VP tree into `build/vendor/vp` with a provenance file and a drift report.
- `generate --engine cp --mods "<clone path>" --out build/vendor/cp` stages the Community-Patch-only tree (no `--clone` needed; cp uses no VPUI).

A `cp` sub-object of `{"alias": "vp"}` reuses the vp recipe verbatim, for the files where both engines resolve to the identical Community-Patch-shipped body (a vp-only edit would otherwise silently skip cp, see the capability-probe and patterns sections). To find which entries need the alias on a re-pin, compare the per-file root in `build/vendor/cp/vendor-report.txt` against `build/vendor/vp`'s: an entry with `vp` edits where both reports show the same root needs the alias.

Do not hand-edit a generated vendor override. To change a CP-divergent screen, edit its manifest entry (convert to a generated entry with a hand-authored `vp`/`cp` sub-object), then regenerate. Feature-detect in the wrapper so the same wrapper is inert on vanilla (which makes it correct for free on the CP-only screens that revert to a vanilla body). Byte-identical XML overrides are dropped outright rather than carried.

## Modpack bake

`tools/modpack/` bakes the merged engine into a single DLC modpack. `dump_db.py` dumps the engine-merged cache DB (the byproduct of a normal modded session) to the merged Override XML; it reads the already-merged DB and never re-implements merge semantics. `build_modpack.py` assembles the package: the Override (dump plus the committed blanking/aux stubs under `tools/modpack/`), the embedded mod folders from the clone with the fork DLL, an `InGame.lua` carrying explicit `LoadNewContext` appends for the net-new addin contexts, and the manifest. The modpack DLC wins over the embedded mod copies by a `<Priority>` bump (priority dominates package sort-order). For the modpack path the per-stem overlay content moves into the DLC (the DLC ships the CP/VP-bodied accessible versions, not vanilla placeholders), because there is no MODS overlay to supply them.

`--community-patch-only` bakes the CP-only variant instead of full VP, and the four things that differ are all parameterized (not duplicated): the database check (CP DLL present with `BALANCE_VP` off, vs VP's `BALANCE_VP` on), the embedded mods (`(1) Community Patch` alone, vs CP+VP), the addin set (Community Patch's nine `InGameUIAddin` stems, vs the CP+VP union of sixteen), and the manifest name plus a distinct GUID (the two packages must never collide on the DLC list). The two packages bake to `build/modpack-out` and `build/modpack-cp-out`. A bake-time guard asserts every addin stem resolves to a file in the embedded mods, so a re-pin that renames or drops a context fails loudly rather than baking a dead `LoadNewContext`.

## Re-sync runbook

When a new stable release ships, re-pin in one cycle. `resync-vp.ps1` (repo root) orchestrates it in resumable phases (`-Phase engine|mods|vendor|finish|modpack|cp-modpack`). The fork DLL, the CP body, and the cp vendor stage are shared, so re-pinning VP re-pins the CP-only support too; only the final bake-and-deploy differs because the two modpacks read different merged databases.

1. Engine: rebase the fork's `civvaccess` branch onto the new tag (with a backup snapshot and conflict-abort-and-restore), rebuild with the clang/SDK build script, and run the canary. The canary must report GOOD before the DLL is committed. If upstream bumps its DLL version number, bump our version-immediate to match (the script gates on this).
2. Mods: mirror the installed MODS folders to the clone byte-identical, handling deletions, so the clone stays the pristine reference.
3. Vendor: re-run `verify` (vanilla stays green) then `generate` for both engines (`--engine vp` and `--engine cp`), and read the drift reports. A cp recipe break here is usually a `{"alias": "vp"}` reuse whose shared body moved.
4. Finish: deploy the VP mod-overlay (passing `-RepinBuild`) and record the new pin (requires an explicit review-confirmed flag). This leaves the install in the transient mod-overlay state, used for the next step.
5. Modpack (terminal): after playing one clean CP+VP session through the Mods menu to produce a fresh merged database (`build-modpack` refuses a modpack-launch cache), `-Phase modpack` bakes the VP modpack and deploys it, returning the install to the player-facing VP modpack state where the play audit runs.
6. CP-modpack (the other terminal): to keep the Community-Patch-only modpack current, produce a CP-only merged database (flip to vanilla, enable ONLY `(1) Community Patch`, play to the map, quit), then `-Phase cp-modpack` bakes and deploys it. Separate from phase 5 because the CP-only database is a distinct manual session.

Phases 4-6 are never part of an unattended run; the default run stops after vendor with a review checklist. What actually breaks on a re-pin is rarely the C++ rebase. It is the vendoring drift reports (new overlaps, signature drift, anchors moved) and the value audit of the Lua-binding diff between the old and new tags (new balance guards in getters we speak, those can newly conflate CP-only too). Newly drifted getters go into the lint seam guard's name list.

## Reference inventory

- Fork clone: a sibling checkout of Community-Patch-DLL on branch `civvaccess` (= the pinned Release tag plus a build-script fix plus a small set of port commits: Lua bindings, hooks, the trade-unit name fix). Build from the clone root with the clang/SDK build script, LLVM on PATH.
- Committed artifacts: fork DLL at `dist/engine-vp/` (shared by VP and CP-only); the CP/VP seam body at `src/vp/CivVAccess_EngineData.lua`; vendoring tool and manifest at `tools/vendoring/`; modpack tooling at `tools/modpack/`; canary at `tools/vp_dll_canary.py`. The pin is `supported_vp` in `versions.json`.
- Staged, not committed: `build/vendor/vp/` and `build/vendor/cp/` (vendor stages plus provenance plus drift report); `build/modpack-out/` and `build/modpack-cp-out/` (baked packages). Regenerate / rebake as above.
- Deploy scripts: `deploy.ps1` (vanilla state), `deploy-vp.ps1` (VP mod-overlay state), `deploy-modpack.ps1` (VP modpack state), `deploy-modpack-cp.ps1` (CP modpack state), plus the sighted-multiplayer variants. Bake scripts: `build-modpack.ps1` (VP), `build-modpack-cp.ps1` (CP). The `-cp` scripts are thin wrappers passing `-CommunityPatchOnly` to the shared implementation, so the two modpacks cannot drift. The install states are mutually exclusive.
- Logs: `CustomMods.log` is the fork heartbeat (its banner plus the balance cache line prove the fork booted; the line shows `BALANCE_VP=0` under CP-only); `modding.log` shows activation cycles; `Lua.log` carries Lua errors and print output; `Database.log`'s `no such column: Type` on `Natural_Wonder_Placement` is the signature of a database/state mismatch.
