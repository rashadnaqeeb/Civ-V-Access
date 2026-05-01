# High-Level Cross-Cutting Abstraction Findings

Scope: mod-authored Lua only (`src/dlc/UI/**/CivVAccess_*.lua`, ~234 files, ~62k lines). Vendor base-game overrides excluded.

This pass looks for **architecture-scale** opportunities — patterns spanning 5+ files where a small abstraction would change the codebase's shape, not just save lines. The deferred list in `current_status.md` already enumerates pairwise / triple-wise dedup; I avoided re-proposing those and focused on the eight areas the parent specified, then added two cross-cutting concerns.

Format per finding: summary, scope, proposed shape, cost, savings, verdict, risk/confidence.

---

## 1. "Access wrapper" shape — LEAVE ALONE

**Summary.** ~60 `CivVAccess_*Access.lua` files share a top-of-file shape: 21 `include()` lines + `priorInput`/`priorShowHide` capture + a `BaseMenu.install` (or `TabbedShell.install`) call. The variation per file is exactly the part that has to be hand-written: the items list, the show/hide hooks, the screen-specific Esc behavior.

**Why not abstract further.** The factory shape `AccessWrapper.create({contextName, builder, lifecycle, ...})` collapses ~30 lines of preamble per file but changes the readable surface from "do these things in this order" to "fill in this configuration table." Three significant costs:
1. Civ V's per-Context env wipe on load-from-game is real; closures in builders captured at module-load time can be silently dead. Today the `BaseMenu.install` call sits at module-load time inside the Context's own file, so the closures it captures live in that Context's env and get rebuilt when the engine re-inits the Context. A factory accepting a `builder` callback executed inside Shared would land closure capture in Shared's env, which is a different lifecycle. Debugging that is hard.
2. The Access wrapper is the contract between vanilla game code and our mod. A reader chasing a popup misbehavior wants to see *exactly* the wiring on one screen; a 5-line factory call hides what `priorInput` is, what `priorShowHide` does, what `deferActivate` means. Today every wrapper is a near-spec-conformant document.
3. The PopupBoot include-bundle deferred item already addresses the boilerplate that *can* be safely lifted (just the include lines). Beyond that, what's left per file is genuinely different per screen.

**Verdict.** Pursue the PopupBoot deferred item; do not lift the install pattern further.

**Confidence.** High that further abstraction would be a regression.

---

## 2. Scanner backend uniformity — ALREADY GOOD; OPTIONALLY HARDEN THE CONTRACT

**Summary.** `ScannerCore.registerBackend(backend)` already enforces the `{ Scan, ValidateEntry, FormatName }` contract at registration; each backend is one self-contained file ending with `ScannerCore.registerBackend(...)`. Eight backends in 60-200 lines apiece, all conform.

**What's good.** The contract is small (3 functions), the entry shape is documented in `ScannerCore.lua` with field-by-field meaning, the registration is decentralized (each backend file is the unit of cohesion), and the backends self-register so adding `ScannerBackendBarbarianCamps` would be a new file + a Boot include.

**What could be sharper.** `ScannerBackendCities.scanCities` re-implements the "iterate alive non-barb players, gate by IsHasMet, partition by team relation" walk that ScannerBackendUnits also does (verified by the deferred `ForeignUnitSnapshot` already lifted in the previous pass for ForeignUnitWatch / RevealAnnounce). A `ScannerCore.eachMetForeignPlayer(activePlayer, activeTeam, fn)` helper plus a `ScannerCore.classifyOwner(ownerId, activePlayer, activeTeam)` returning "my" / "neutral" / "enemy" / nil would absorb that loop in 2-3 backends.

**Cost.** Low — pure helper, no capture concern. Risk: must keep the iteration identical to `Map.GetNumPlots()` order in the Cities/Units backends so the entry order in scanned snapshots stays stable across builds.

**Savings.** ~30 lines across 2 backends + a clear primitive that backends like a future `ScannerBackendCityStateRoutes` could reuse.

**Verdict.** Worth doing as a small-scoped follow-up but lower priority than the deferred items. Not a shape-changing abstraction.

**Confidence.** Medium-high that the helper is correct; low expected payoff.

---

## 3. Plot section composers — boundary is correct; one small dedup

**Summary.** `PlotSectionsCore` defines per-section `Read(plot, ctx) -> tokens` objects; `PlotSectionUnits` and `PlotSectionRiver` are siblings defining their own `Read` (they're sized large enough or domain-different enough to live in their own files); `PlotComposers` orchestrates by calling sections in order and `table.concat`-ing.

**The boundary is correct.** Sections are stateless data → tokens; composers gate visibility and order. That separation is genuinely useful: the Cursor reads the same sections in a different order than the W/X detail keys, so factoring per-composer logic into per-section `Read` would couple the sections to consumers.

**One small dedup.** `readSection(section, plot, ctx, out)` lives in `PlotComposers.lua` (lines 13-20) and is implicitly re-implemented by callers that want to read a single section into a fresh tokens list (`PlotComposers.glance`, `PlotComposers.economy`, `PlotComposers.combat`). The `YIELD_KEYS`/`YIELD_ORDER` table is intentionally duplicated between `PlotComposers` and `SurveyorCore` (per the latter's comment "stays in sync... by design"). That duplication is conscious; both reference the canonical speech order. Promoting to a single `PlotComposers.YIELD_ORDER` and having `SurveyorCore` `require`/read it would save 6 lines and an alignment risk; small win.

**Verdict.** Optional ~10 line cleanup; the architecture is already right.

**Confidence.** High.

---

## 4. Cursor / Surveyor / Scanner — three distinct subsystems, kept distinct

**Summary.** Three subsystems answer three different questions per the project memory: Cursor "what's here", Surveyor "what's in radius", Scanner "find a specific thing." They share `HexGeom`, `PlotComposers`, the Plot sections, and `ScannerNav` for go-to.

**The shape is correct.** The three are deliberately *parallel but distinct* — the user has explicitly memorized this distinction (`feature_spatial_awareness_purposes.md`). Forcing a common abstraction would muddle the mental model. Each owns its own bindings file, its own announcement style, and its own state. The only things they share — radius math, hex iteration, formatters — are already in `HexGeom` and `PlotComposers`.

**Note on shared state.** All three subsystems read `civvaccess_shared.cursorPosition` (set by Cursor). Surveyor reads it; ScannerSnap reads it as a tiebreaker via PlotDistance. That's already a clean dependency graph: Cursor produces position, the others consume it.

**Verdict.** Leave as-is. The user-facing distinction reflects in the code.

**Confidence.** High.

---

## 5. "Push a submenu listing X" — partial pattern, not worth a generic helper

**Summary.** `pushCitySub(name, displayName, items)` exists in `CityViewAccess.lua` for the local "every CityView sub shares the same BaseMenu spec" case. Outside CityView, the few direct `HandlerStack.push(BaseMenu.create({...}))` call sites diverge meaningfully: each sets a different `escapePops`, `capturesAllInput`, `onActivate`, `onDeactivate`, and item shape.

**Inventory.** Direct push of an inline `BaseMenu.create` happens in 3 files (CityViewAccess, CityViewProduction, MilitaryOverviewAccess), plus `pushCitySub` (CityView only) and `ChooseConfirmSub.push` (already lifted). Around 8 distinct push sites total.

**Why not abstract.** The differences are not flag-shaped — each push has its own activation lifecycle. A generic helper would devolve to "pass through every BaseMenu.create kwarg," which is what `BaseMenu.create` already is. The CityView-local `pushCitySub` makes sense because it factors out the *shared* `escapePops=true, capturesAllInput=false` policy that's specific to CityView's sub navigation.

**Verdict.** Leave as-is. The CityView-local helper is the right scope.

**Confidence.** High.

---

## 6. Speech composition skeleton — genuinely one-shot per composer

**Summary.** Speech composers (`PlotComposers.glance`, `UnitSpeech.selection/info/meleePreview/rangedPreview`, `CitySpeech`, `EmpireStatus.bindings`, every per-civ speech line in Diplo*Access) all use the same primitive: `local parts = {}; parts[#parts+1] = X; return table.concat(parts, ", ")`. Around 80-100 sites.

**Why a SpeechBuilder DSL is wrong.** Each composer's logic is genuinely different: branchy gates (visibility, fog, distance), conditional decorators (embarked prefix, named-unit parens, cargo aircraft suffix), per-unit cascade (status priority order). A builder API like `Speech.builder():withName(unit):withMoves(unit):build()` would either be a thin wrapper around `parts[#parts+1] = ...` (saves 1 character, costs a method call), or it would model each composer's domain logic as builder methods (which means the builder grows to N×M methods for N composers).

**The one primitive worth lifting.** `Text.joinNonEmpty(parts, sep)` (or `Text.compose(parts, sep)`) — drop nil/empty tokens, concatenate with sep. Already exists as `DiploCommon.joinParts` (used in DiploRelationships / DiploGlobalRelationships) and `joinNonEmpty` (HoF / Leaderboard locals). The deferred list already mentions `joinVisibleControlTexts` for the control-name variant; this is the abstract `parts -> string` helper that everyone is hand-rolling.

**Inventory.** I count ~25 hand-rolled "iterate parts, drop empty, concat" loops across PlotComposers (one local), Demographics, VictoryProgress, several Choose* preambles, AdvisorInfoPopup, etc. Promote to `Text.joinNonEmpty(parts, sep)` and use everywhere; saves ~5-7 lines per site, ~120 lines total. **Stronger than the deferred `joinVisibleControlTexts` because the latter only handles the Controls case.** A generic `Text.joinNonEmpty` plus a thin `Text.joinVisibleControls(controlNames, sep)` wrapper would handle both.

**Verdict.** Worth doing. **Recommended.** Small, mechanical, no lifecycle risk, observable savings.

**Confidence.** High.

---

## 7. PluralRules — inconsistently consulted

**Summary.** `Text.formatPlural(key, count, ...)` exists and dispatches through `PluralRules.select(count)` which handles per-locale CLDR-style plural categories. 34 mod-authored sites use it.

**Audit.** I scanned for `count > 1` / `count == 1` / `n == 1` patterns outside `PluralRules.lua`. The hits are mostly innocent index comparisons (`if idx == 1`, `if CurrentPanelIndex == 1`), with one **legitimate non-`formatPlural` count handler in `ForeignUnitSnapshot.formatList`**:

```lua
if b.count > 1 then
    pieces[#pieces + 1] = tostring(b.count) .. " " .. b.civ .. " " .. b.unit
else
    pieces[#pieces + 1] = b.civ .. " " .. b.unit
end
```

The header comment says: "No plural form -- Civ V text data has no TXT_KEY_UNIT_*_PLURAL keys, and screen readers parse '3 Warrior' as plural from context." That's an intentional decision: the unit name comes from game data which has no plural key, and the user-facing convention is to drop the count when it's 1. Routing through `Text.formatPlural` would require synthesizing an artificial plural-aware key, which is more cost than benefit. The decision is correct; the comment is sufficient documentation.

**No other hand-rolled pluralizers.** PluralRules is consistently used where plural keys exist.

**Verdict.** No action. The single non-`formatPlural` site is a documented exception.

**Confidence.** High.

---

## 8. Module publishing pattern — small but real opportunity

**Summary.** Boot exposes 9 in-game modules via `civvaccess_shared.modules.X = X` (plus the bootstrap of `civvaccess_shared.modules = civvaccess_shared.modules or {}`). Three consumer files read them with `local X = civvaccess_shared.modules and civvaccess_shared.modules.X` and nil-guard before use.

**The publish side is already minimal.** 11 lines in Boot.lua for 9 modules; trivial.

**The consume side is verbose and slightly inconsistent.** Five sites today: CameraTracker (Cursor), CityStateDiploPopupAccess (GiftMode, twice), DeclareWarPopupAccess (UnitControl, twice), UnitControlCore (header comment only). Each does:

```lua
local X = civvaccess_shared.modules and civvaccess_shared.modules.X
if X == nil then return end
```

A `Boot.module(name)` helper (in Boot.lua or a new tiny `CivVAccess_ModuleRegistry.lua`) would be:

```lua
function ModuleRegistry.get(name)
    local mods = civvaccess_shared.modules
    return mods and mods[name]
end
```

Saves 2 lines per consumer site (~10 lines total), but more importantly normalizes the access pattern. If we later add a debug-mode warn-on-missing or want to enforce a known-modules whitelist, there's one place.

**Trade-off.** Small absolute size (~10 lines saved across 5 sites). Worth doing for the future-proofing rather than the line count.

**Verdict.** Low-value but easy. Either do it or don't; it's not a shape-changer. Skip if there's anything more valuable on the list.

**Confidence.** High.

---

## 9. (Cross-cutting) Engine-Events install helper — RECOMMENDED

This was on the deferred list (`Log.installEvent`); I'm re-flagging it because **the parent prompt asked for architecture-scale opportunities and this is one**. The pattern `if Events ~= nil and Events.X ~= nil then Events.X.Add(handler) else Log.warn(...) end` recurs in the `installListeners` of 15 InGame modules plus several install/init sites elsewhere. Around 60-80 sites total when counting non-installListener locations.

**Architectural significance.** Beyond line savings, a `Log.installEvent(scope, eventName, handler, opts)` would be the canonical surface for the "register a fresh listener every game (don't install-once)" rule that's load-bearing per CLAUDE.md. Today every site re-implements the rule; new contributors have to grep for the pattern. Centralizing it gives one documented entry point that encodes the no-install-once-guard rule in code instead of in scattered comments.

**Cost.** The explicit form is sometimes more debuggable. Mitigation: have the helper accept an optional `mode = "Events" | "GameEvents" | "LuaEvents"` so the dispatch surface is visible at the call site.

**Savings.** ~80-100 lines and one architectural entry point.

**Verdict.** **Recommended.**

**Confidence.** High.

---

## 10. (Cross-cutting) `Log.tryCall(label, fn, ...)` — RECOMMENDED for high-frequency Shared/HandlerStack sites; SKIP for one-offs

Also on the deferred list. The pattern `local ok, err = pcall(fn, arg); if not ok then Log.error("X.Y failed: " .. tostring(err)) end` recurs 50+ times.

**Where it's worth doing.** Inside Shared modules that pcall *user-supplied callbacks* (HandlerStack lifecycle hooks: onActivate / onDeactivate / activate / onShow / onEscape; BaseMenuInstall's priorShowHide and priorInput; TabbedShell's tab.onTabActivated / onTabDeactivated; TickPump's runOnce). These are by far the densest concentration — `BaseMenuInstall.lua` has 4 in 209 lines, `TabbedShell.lua` has 10 in 577 lines. A `Log.tryCall(label, fn, ...)` returning `(ok, ...)` would let those collapse to a one-liner each. ~40 lines saved across 6-8 Shared files.

**Where it's not worth doing.** Per-feature pcalls in InGame modules (e.g., `SocialPolicyPopupAccess` has 14 unique-context pcalls). Each carries its own contextual `"X failed: "` label; converting them to `Log.tryCall("SocialPolicyPopup.fooBar", fn)` is 1 line saved at the cost of scattering label strings further from the call site.

**Verdict.** Add the helper, convert ~6-8 high-frequency Shared sites only. Don't aggressively convert. **Recommended (selective).**

**Confidence.** High.

---

## 11. (Cross-cutting) `BaseInstall.install` lifecycle scaffold — RECOMMENDED

Already on the deferred list as the BaseMenu.install / TabbedShell.install scaffold lift. Re-elevating because this is the single largest *architecture-scale* commonality I see.

**Reading `BaseMenuInstall.lua` (209 lines) and `TabbedShell.lua` (lines 448-575, 130 lines):** they share roughly 60 lines of identical scaffold:
- `priorShowHide` / `priorInput` capture
- `tickOwner` flag + `TickPump.install` gating
- `pendingPush` state + `runDeferredPush` closure
- `SetShowHideHandler` skeleton: prior-pcall, bIsInit gating, removeByName on hide, shouldActivate gate, onShow pcall, deferActivate vs immediate push
- `SetInputHandler` skeleton: Esc / non-Esc dispatch through InputRouter, onEscape hook, fall-through to priorInput

Differences are well-shaped:
- BaseMenu has the type-ahead Esc clear, the `_editMode` Enter-KEYUP claim, and the `bIsInit AND bIsHide` skip refinement (vs TabbedShell's plain `bIsInit` skip)
- TabbedShell has `resetTabsForNextOpen` on hide
- BaseMenu has `suppressReactivateOnHide`; TabbedShell does not

A `BaseInstall.install(ContextPtr, handler, hooks)` taking the per-implementation `hooks = { onShowHidePrelude, onShowHidePostlude, onInputClaim }` callbacks would absorb the scaffold while letting BaseMenu and TabbedShell each layer their specific behavior on top.

**Why this is architecture-scale, not pairwise.** This is the lifecycle integration point between every Civ V Context our mod attaches to and our handler abstraction. Centralizing it means the load-from-game discipline (no install-once guards, fresh-listener rule, dead-env defense) is encoded in one wrapper instead of two parallel implementations that drift. Today an architectural change (e.g., adding telemetry on lifecycle transitions, adding a debug-mode handler-stack dump on every Esc) has to be made in two places.

**Cost.** Touches load-bearing init. The two install paths are tested only via the test suite and in-game; a regression here is not test-caught for the harder lifecycle cases (load-game-from-game with a popup mid-open). Risk requires careful manual play-testing.

**Savings.** ~50-60 lines + one architectural surface.

**Verdict.** **Recommended, with explicit testing call-out.** Do this *after* the safer items.

**Confidence.** High that it's worth doing; medium-high that the implementation will be clean (the hook-spec API needs careful design).

---

## Summary recommendations

**Top 3 architectural improvements to pursue:**

1. **Engine-Events install helper (`Log.installEvent`).** Codifies the no-install-once rule in code, collapses 80+ sites, lowest risk. Already in deferred list — re-emphasize.
2. **`Text.joinNonEmpty(parts, sep)` primitive.** Replaces ~25 hand-rolled join-non-empty loops + the existing `DiploCommon.joinParts` + `joinNonEmpty` HoF/Leaderboard locals. Cleanest, highest-density savings (~120 lines), zero lifecycle risk.
3. **`BaseInstall.install` scaffold lift.** The biggest architecture-scale finding: the lifecycle integration point between every Context and our handler model is duplicated between BaseMenu.install and TabbedShell.install. Centralizing encodes the load-from-game discipline in one place. Higher risk, larger payoff. **Do this after the safer items.**

**Secondary:** Selective `Log.tryCall` (high-frequency Shared sites only); `ModuleRegistry.get` helper (small).

**One notable LEAVE ALONE:** the "Access wrapper" shape itself. Don't lift `BaseMenu.install` calls into a factory — the per-Context env-wipe semantics make module-load-time installation a feature, not boilerplate. The PopupBoot include-bundle lifts what *can* safely be lifted; the rest stays per-file.
