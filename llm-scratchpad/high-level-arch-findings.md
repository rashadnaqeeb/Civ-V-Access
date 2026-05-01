# Architecture & Lifecycle Fragility Findings

Senior-engineer review of mod-authored code (src/dlc, src/proxy, src/engine).
Findings are scoped to architectural / cross-file concerns; low-level dedup
candidates already enumerated in `current_status.md`'s deferred section are
intentionally omitted.

Ranked highest-impact first. Risk and confidence are independent: risk is the
chance the proposed fix introduces a regression; confidence is how sure I am
that the finding is real.

---

## 1. Engine-fork method calls silently degrade with no log

**Files:**
- `src/dlc/UI/InGame/CivVAccess_UnitTargetMode.lua:90,93,377,384,586`
- `src/dlc/UI/InGame/CivVAccess_UnitControlMovement.lua:431`
- (callers of `Plot:CanSeePlotPureLoS` and `Game.GetCycleUnits` if any)

**Why it matters:** The mod treats engine-fork bindings inconsistently. The
`GameEvents.CivVAccess*` registrations (MultiplayerRewards, ForeignClearWatch,
RevealAnnounce, UnitControlCombat, UnitControlMovement) all gate on
`if GameEvents ~= nil and GameEvents.CivVAccessFoo ~= nil then ... else
Log.warn("... engine fork not deployed?") end`. That's the right shape.

But fork-added method bindings — `Unit:GeneratePath`, `Unit:GetPath`,
`Unit:GetBestBuildRoute`, `Game.GetBuildRoutePath`, `Plot:CanSeePlotPureLoS` —
are called bare (no pcall, no feature check). On a vanilla DLL deploy, vanilla
ships `Unit:GeneratePath` as `luaL_error("NYI")` and the others aren't
registered at all (so calls raise "attempt to call a nil value"). Either way
the call throws a Lua error; it's caught by the engine's per-listener / per-
input-handler catch and silently disappears unless `LoggingEnabled=1` is set
and the contributor reads Lua.log.

Concrete failure mode: a contributor runs `./deploy.ps1 -SkipEngine` (which
the build pipeline actively encourages for "fast Lua-only iterations") on a
machine that has never had the fork DLL installed. Move-target preview, route
preview, build-route preview, and ranged-strike LoS all throw silently. The
user hears nothing where they expected speech and has no signal that the
fork is missing.

**Proposed fix:** at Boot, do one feature probe: a single dofile-time check
that calls the fork-added Lua functions in a pcall and logs a single
INFO/WARN line summarizing what's available. Something like
`Log.info("engine fork bindings: GeneratePath=ok GetBuildRoutePath=ok
CanSeePlotPureLoS=ok")` or `Log.warn("engine fork DLL not deployed —
move/route preview disabled")`. The probe runs once at boot; contributors
diagnosing missing speech see the boot log immediately.

**Risk:** low (single boot-time probe, no behavior change for happy path).
**Confidence:** high.

---

## 2. Inconsistent listener-error handling — promote `safeListener` to Log

**Files:** 98 `Events.X.Add(...)` call sites across 55 files. Today only
`StagingRoomAccess.lua:880` defines a `safeListener(name, fn)` wrapper that
pcalls and logs. Most other Access wrappers and InGame modules pass listeners
directly: `Events.UnitMoveCompleted.Add(onUnitMoveCompleted)`.

**Why it matters:** CLAUDE.md's "No silent failures" rule says "every pcall /
error branch must log through the mod's log wrapper". The convention is
ubiquitous *inside* listener bodies (the manual `local ok, err = pcall(fn);
if not ok then Log.error(...)` pattern recurs ~103 times). But the *outer*
listener — the one Events.X actually invokes — is rarely wrapped. When the
listener body has an unhandled throw (a typo, a missing field on a game
struct after a patch, a race during MP), the engine's per-listener catch
swallows it; nothing reaches Lua.log unless `LoggingEnabled=1`.

This is a long-term fragility: when the next Civ V minor patch (unlikely but
not impossible — there have been workshop hotfixes) shifts an event payload's
shape, listeners start crashing silently and the user has no signal.

**Proposed fix:** promote `safeListener` to `Log.safeListener(scope, fn)` (or
similar name). One line per registration: `Events.X.Add(Log.safeListener
("MyModule.onX", onX))`. The deferred list mentions a similar `Log.tryCall`
helper for explicit pcall sites — these are different patterns (one wraps
the listener, the other wraps a single inner call) but both belong on Log.

**Risk:** low — pure additive change at each call site; no behavior change
for the happy path. Mid for the cleanup itself (98 sites, easy to miss
some), but the conversion is mechanical and the existing wrappers can stay
in until each is touched.

**Confidence:** high.

---

## 3. FrontEnd Access wrappers use install-once guards that the InGame side forbids

**Files:**
- `src/dlc/UI/FrontEnd/CivVAccess_FrontEndPopupAccess.lua:31`
  (`_frontEndPopupRefreshInstalled`)
- `src/dlc/UI/FrontEnd/CivVAccess_JoiningRoomAccess.lua:24`
  (`_joiningRoomListenersInstalled`)
- `src/dlc/UI/FrontEnd/CivVAccess_LoadScreenAccess.lua:179`
  (`loadScreenReadyListenerInstalled`)
- `src/dlc/UI/FrontEnd/CivVAccess_StagingRoomAccess.lua:889-893`
  (`_stagingListenersInstalled`)

**Why it matters:** CLAUDE.md is unambiguous about the in-game rule: never
gate `Events.X.Add` with a `civvaccess_shared.flagInstalled` boolean, because
the flag persists across game transitions but the listener it gated is
stranded with a dead env. The exception explicitly listed is
"shared resource — the metatable, the audio bank — survives the env kill".

The four FrontEnd wrappers above all use the install-once pattern. The
`FrontEndPopupAccess` header even acknowledges the Context "can be re-
instantiated by the engine" and tries to handle that with a stash-and-resolve
pattern (`civvaccess_shared._frontEndPopupHandler` reassigned every include,
listener dynamically reads it). But the listener body still runs in the
*old* env — its references to `Log`, `pcall`, `Events` are captured upvalues
of a dead env. If the FrontEnd Context env gets wiped on a transition that
re-instantiates the Context (the documented gotcha for InGame), the
listener's body would silent-throw on first global access and the new
include is blocked from registering a fresh one.

I cannot positively confirm FrontEnd Contexts have the env-wipe behavior
without testing in-game. But:
- The InGame doc takes the "register fresh every include" stance even though
  it costs accumulated dead listeners, on the principle that a stranded
  install-once listener is a worse failure mode than redundant registration.
- The FrontEnd Context lifecycle is at least *similar* — Contexts come and
  go as the user navigates main menu / multiplayer / load. The same hazard
  could apply.
- The fact that one developer wrote `FrontEndPopupAccess` with the dynamic-
  resolve mitigation suggests they suspected the env-wipe issue. They just
  didn't follow through to "register fresh every include".

**Proposed fix:** drop the four install-once guards. Each Access wrapper's
file-scope code re-runs every include and registers a fresh listener; that's
the same accumulation tradeoff the InGame side accepts. If the user reports
no observable misbehavior in current testing, that's not evidence the guard
is harmless — it's evidence the env-wipe scenario hasn't been triggered yet.

**Alternative fix (lower-conviction):** if the user can confirm in-game that
FrontEnd Contexts don't re-init like InGame ones do, document that exemption
in CLAUDE.md so the difference becomes a deliberate architectural choice
rather than drift.

**Risk:** low — duplicate listeners on shared Events.X are the cost; the
engine's per-listener-catch limits the blast radius (latest live listener
still fires). Mid for FrontEnd's load-screen-during-load flow where multiple
listeners refresh the same handler; deferred-resolve pattern means they all
look up `civvaccess_shared._fooHandler` and act on the same fresh handler,
so the redundancy is wasted CPU not duplicate speech.
**Confidence:** medium — high that the install-once pattern is suspect, low
that the failure mode actually triggers in current play.

---

## 4. `civvaccess_shared.modules` is published only at InGame boot — popup Access wrappers `nil`-guard reads

**Files:**
- `src/dlc/UI/InGame/CivVAccess_Boot.lua:135-144` (publish)
- `src/dlc/UI/InGame/Popups/CivVAccess_DeclareWarPopupAccess.lua:87,105`
  (consumes via `civvaccess_shared.modules and civvaccess_shared.modules.UnitControl`)
- `src/dlc/UI/InGame/Popups/CivVAccess_CityStateDiploPopupAccess.lua:192,212`
  (same shape for `GiftMode`)
- `src/dlc/UI/Shared/CivVAccess_CameraTracker.lua:126` (Cursor)

**Why it matters:** The pattern is fine in concept (cross-Context module
publishing). But the consumers all use `civvaccess_shared.modules and
civvaccess_shared.modules.X` chained guards, then silently no-op if the
module is missing. That's a "defensive nil handling" antipattern per
CLAUDE.md: if `civvaccess_shared.modules.UnitControl` is genuinely nil, the
DeclareWarPopup feature breaks silently and there's nothing in Lua.log.

Two architectural concerns:
- **Publish location.** `Boot.lua` runs at WorldView Context include, but
  the popup Contexts whose Access wrappers consume `civvaccess_shared.
  modules` may run at different Context-load orderings. The `nil`-guards
  are protecting against "popup Context loads before WorldView's Boot
  completed". That ordering is presumably stable in practice but it's a
  brittle invariant — never explicitly asserted.
- **Failure mode.** Where `nil` happens, the popup just doesn't get the
  feature. The user gets less speech than expected with no signal why.

**Proposed fix:**
- Replace the `and`-chained guards with a single `getModule(name)` helper on
  the publish side that logs once per missing-module-fetch and returns
  whatever it finds. Consumers do `local UC = civvaccess_shared.getModule
  ("UnitControl")`; if it's nil, the helper has already logged.
- (Optional) at Boot, after publishing, log once: `Log.info("published
  modules: Cursor, ScannerNav, ..., UnitControl")` so a Lua.log reader
  can see what's available at boot vs what was missing at popup time.

**Risk:** low.
**Confidence:** medium — the pattern is suspect but I haven't seen a real
failure trace. The maintainer may have tried direct access and observed
real `nil` reads, hence the guards.

---

## 5. CLAUDE.md doc drift — TaskList comment refers to "TaskList Context"

**File:** `src/dlc/UI/InGame/CivVAccess_TaskList.lua:15-22`

**Why it matters:** The header comment says the listener "registers at file
scope (matching the engine's TaskList.lua)". But our `CivVAccess_TaskList`
is included from `CivVAccess_Boot`, which is in turn included from
WorldView. So the listener actually runs in WorldView's env, not TaskList's.
The "matching the engine's TaskList.lua" claim is misleading — the engine's
TaskList Context is exactly the one CLAUDE.md says we must NOT seat boot
code on, because it doesn't re-init on load-from-game.

The actual rationale (file is re-evaluated on every WorldView include →
fresh-env closure supplants the prior one) is correct, but the comment
mis-locates the registration site.

**Proposed fix:** rewrite the header to say "registers at WorldView Context
include time (Boot pulls TaskList in)" rather than "matching engine's
TaskList.lua". Mention that the engine's TaskList Context is dead for our
purposes, and that's why we mirror via WorldView.

**Risk:** none (comment-only).
**Confidence:** high.

---

## 6. PopupAccess preamble of 21-22 includes is uniform across ~40 files (deferred-list item, validated)

This finding is already captured in current_status.md's deferred section as
"PopupBoot include bundle (~1000 lines)". I verified it: every popup Access
wrapper opens with the same Polyfill + Log + TextFilter + en_US strings +
PluralRules + Text + Icons + SpeechEngine + SpeechPipeline + HandlerStack +
InputRouter + TickPump + Nav + BaseMenuItems + TypeAheadSearch + BaseMenuHelp
+ BaseMenuTabs + BaseMenuCore + BaseMenuInstall + BaseMenuEditMode + Help
sequence. A single `CivVAccess_PopupBoot.lua` shared include bundle would
collapse ~1000 lines.

The stem-prefix collision risk (CLAUDE.md gotcha) needs a deliberate name
choice — `CivVAccess_PopupBoot` is collision-free against the current tree
but a future contributor could regress this by adding `CivVAccess_PopupBootX`
or similar. A sub-second `luacheck`-style check that no two include stems
share a prefix would harden this; possibly worth adding to test.ps1.

**Risk:** low.
**Confidence:** high.

---

## 7. `NotificationAnnounce` and similar use `installed` log lines but no idempotency mechanism

**Files:**
- `src/dlc/UI/InGame/CivVAccess_NotificationAnnounce.lua:157`
  (`Log.info("NotificationAnnounce: installed, snapshotted ...")`)
- `src/dlc/UI/InGame/CivVAccess_HotseatCursorRestore.lua:94`
- `src/dlc/UI/InGame/CivVAccess_HotseatMessageBufferRestore.lua:60`
- `src/dlc/UI/InGame/CivVAccess_InGameKeys.lua:42`
- (others log similar "installed" lines)

**Why it matters:** Reading Lua.log on a load-from-game session, a
contributor sees N consecutive "installed" lines (one per game). That's
*correct* behavior per the "register fresh every include" rule — but a
new contributor reading the log might think the duplicates indicate a bug.
No signal in the log distinguishes "first install ever" from "re-install
after env wipe".

**Proposed fix:** include a "(re)install" indicator in the log line, and/or
include the WorldView Context include count if cheaply available
(`civvaccess_shared.bootSequence = (civvaccess_shared.bootSequence or 0) + 1`).
Trivial change; pays off the next time a contributor stares at Lua.log.

**Risk:** none.
**Confidence:** medium (utility is real; severity is minor).

---

## 8. Implicit invariant: include order in Boot.lua is load-bearing and not codified

**File:** `src/dlc/UI/InGame/CivVAccess_Boot.lua:1-124`

**Why it matters:** The 124-line include chain has multiple ordering
constraints sprinkled in comments:
- StringsLoader before strings file (line 6-8)
- RecommendationsCore before PlotSectionsCore (line 22-23)
- WaypointsCore before PlotSectionsCore (line 24-25)
- SurveyorStrings before SurveyorCore (line 34-37)
- Strings before ScannerCore (line 75-77)
- BaselineHandler concatenates `Turn.getBindings()` and
  `EmpireStatus.getBindings()` at create time → both must be loaded first
  (line 65-71)
- MessageBuffer before HotseatMessageBuffer (line 102-104)

Some of these are commented; some aren't. When a future contributor adds
a new module that depends on, say, `Cursor`, they'd have to know to put
their `include` after `CivVAccess_CursorCore`. The dependency graph is
implicit.

**Proposed fix (low-conviction):** introduce a `Boot.includeAll(graph)`
helper that takes a flat list of `{name, deps}` entries and resolves
ordering. That's heavier than current and probably overkill for ~50
includes. A lower-effort alternative: turn the implicit comments into a
single block-doc at the top of Boot.lua that names all the ordering
constraints, so a contributor doesn't need to grep through 100 lines of
includes to find "wait, why is this above that?"

**Risk:** low (doc-only) to mid (graph helper).
**Confidence:** low (real but a judgment call).

---

## 9. Test architecture — strings_loader's load behavior and run.lua's manual dofile chain

**Files:** `tests/run.lua:8-22`

**Why it matters:** `tests/run.lua` manually `dofile`s certain production
files (Polyfill, en_US strings, PluralRules, UserPrefs, HexGeom) before
requiring suites. The order is documented in comments. But adding a new
suite that depends on, say, `Text` would require the contributor to know
that the en_US strings file pre-populates the `CivVAccess_Strings` table
that Text reads from. This is a similar implicit-graph problem to Boot.lua
above.

The polyfill's role is documented in CLAUDE.md ("Never build a test-only
mock instead — every stub is a place production and test can diverge").
But the manual dofile chain in run.lua is itself a form of test-only setup
that doesn't run in production. The line between "polyfill (production
self-disables)" and "test-only setup chain" is a bit blurred.

**Proposed fix:** modest — extract the manual dofile chain into a
`tests/setup.lua` (separate from `tests/support.lua`'s test helpers), so
the seam is explicit. Doc what each dofile is for. Probably not worth a
big refactor; called out for completeness.

**Risk:** low.
**Confidence:** low — judgment call, not a real bug.

---

## Out of scope but observed

These are *not* architectural findings, but were noticed during the review;
flagging for the parent's awareness so they aren't lost:

- The deferred list's "Generic `Log.tryCall(label, fn, ...)` helper" is the
  correct shape for the inner-pcall pattern. It's complementary to
  finding #2's outer-listener wrapper. Both belong on `Log`.
- `WaypointsCore`, `RecommendationsCore`, `PlotSectionsCore` form an
  ordering chain that's brittle but documented. Not worth touching unless
  a new dependency is added.
- `BaselineHandler.create()` reads `Turn.getBindings()` and
  `EmpireStatus.getBindings()` at creation time. If a future contributor
  adds a third module that contributes bindings to Baseline, the pattern
  is OK but not abstracted. Possibly a low-priority cleanup target.

---

## Summary

Highest-impact items: **#1** (engine-fork degradation logging),
**#2** (`safeListener` consistency), **#3** (FrontEnd install-once guards).
Each is a real architectural concern with a concrete failure mode. #1 is
near-trivial to fix; #2 is mechanical but touches many files; #3 is the
riskiest because it requires a behavior change in the FrontEnd lifecycle
and the failure mode is not currently observable.

Everything else (#4-#9) is medium-to-low priority and can be deferred or
dropped depending on user preference.
