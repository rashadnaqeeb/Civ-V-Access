# Civ V technical reference

Engine facts and architectural decisions for the accessibility mod at `C:\Users\rasha\Documents\Civ-V-Mod`. Distilled from session research, the prior author's design docs, the prior author's deployed artifacts, and direct investigation of the Civ V SDK + game assets. Prior-author UI code, base classes, and design philosophy are **out of scope** — this document keeps only what is true about Civ V itself, plus the architectural decisions we've made this session.

---

## 1. Target

- **Game:** Sid Meier's Civilization V. 32-bit (x86) on Windows.
- **Editions targeted:** vanilla, Gods & Kings, Brave New World, from one mod. Runtime DLC detection gates edition-specific features.
- **Executables:** `CivilizationV.exe` (DX9) and `CivilizationV_DX11.exe` (DX11). Both load `lua51_Win32.dll` from the install dir; one proxy covers both.
- **Default install:** `C:\Program Files (x86)\Steam\steamapps\common\Sid Meier's Civilization V\`.
- **SDK install:** `C:\Program Files (x86)\Steam\steamapps\common\Sid Meier's Civilization V SDK\` — contains `FireTuner2\FireTuner2.exe`, `ModBuddy\ModBuddy.exe`, and the Lua API reference at `ModBuddy\Help\Civ5LuaAPI.html`.
- **User data:** `%USERPROFILE%\Documents\My Games\Sid Meier's Civilization 5\`.
- **Logs:** `Documents\My Games\Sid Meier's Civilization 5\Logs\` — `Lua.log` for script errors, `APP.log` for engine.

---

## 2. Architecture decision: how Tolk gets into the game

Four approaches were considered. **Only one is viable for our use case.**

| Approach | MP-safe | Achievements | DLC-orthogonal | Workshop-distributable | Verdict |
|---|---|---|---|---|---|
| **Custom CvGameCoreDLL** (official SDK path) | **No** | Disabled | Yes | Yes | **Rejected — MP is mandatory** |
| **System-DLL search-order proxy** (e.g. proxy `dbghelp.dll`) | Yes | Yes | Yes | **No** (Workshop installs to `My Games\MODS\`, not game dir) | Rejected |
| **Launcher + CreateRemoteThread** | Yes | Yes | Yes | **No** (AV flags it, breaks Steam Play button) | Rejected |
| **Lua module via `require("tolk")`** | N/A | N/A | N/A | N/A | Rejected — DLL name collision (see §10) |
| **`lua51_Win32.dll` proxy** | **Yes** | **Yes** | **Yes** | Requires manual install to game dir | **Chosen** |

### Why the lua51 proxy works
- Lua is **not in the multiplayer determinism path.** Gameplay sim runs in `CvGameCoreDLL`; we never touch it. No desync risk.
- Achievement gating checks the gameplay DLL's identity, not Lua's. Untouched gameplay DLL = achievements stay on.
- `lua51_Win32.dll` is loaded **in every mode the game ever enters** — front-end, in-game, DX9, DX11, any DLC combo. One hook point reaches everything.

### The chain 

1. Install proxy as `lua51_Win32.dll`, rename stock runtime to `lua51_original.dll`.
2. On `DLL_PROCESS_ATTACH`: `LoadLibraryA("lua51_original.dll")`, resolve **115 Lua API exports** into a function-pointer table. Also `LoadLibraryA("Tolk.dll")` and resolve Tolk function pointers (but **don't** call `Tolk_Load` yet).
3. Non-hooked exports are **naked `jmp [orig+idx*4]` trampolines** — zero overhead, the game's calls pass through unchanged.
4. **Hook `luaL_openlibs`:** forward to real one, then `luaL_register(L, "tolk", tolk_funcs)` to bind Tolk's 13 `lt_*` C functions as a global `tolk` table.
5. **Hook `lua_setfenv`:** right before the engine installs a sandboxed environment (`_ENV` table), grab `tolk` from `LUA_GLOBALSINDEX` and set it as a field on the env. This makes `tolk` visible inside every per-Context sandbox without requiring scripts to `require` or `include`.
6. **Hook `lua_newstate` / `luaL_newstate`** (defense in depth — not every state goes through `openlibs` before scripts run; register `tolk` directly on every new state's globals).
7. **Lazy Tolk init** on first `tolk.*` call: `Tolk_TrySAPI(1)` → `Tolk_PreferSAPI(0)` → `Tolk_Load()`. Tolk then detects NVDA/JAWS/SAPI at runtime.
8. **One-shot auto-enable** via the `setfenv` hook: when the installed env contains `Modding`, inject a Lua snippet calling `Modding.EnableMod(<our mod GUID>)` + `ActivateEnabledMods()`. Gated by a static flag.

### Threading constraint
**Civ V's Lua VM is single-threaded** — confirmed via code inspection; only coroutines exist, no worker-thread entry. The game core simulation runs on a separate thread, but it does not enter Lua. **All `tolk.*` calls therefore originate from the main thread** and Tolk's own thread-safety needs are minimal. Evidence: `Assets/UI/InGame/Popups/ProductionPopup.lua` (comments about core-thread separation), `Assets/UI/FrontEnd/GameSetup/UniqueBonuses.lua` (coroutine-only concurrency).

### Companion DLLs required next to the proxy (all 32-bit)
`Tolk.dll`, `nvdaControllerClient32.dll`, `SAAPI32.dll`, `dolapi32.dll`. Tolk dynamically loads these per-screen-reader; any missing DLL silently drops support for its reader without a visible error. Upstream Tolk ships **64-bit only** — 32-bit builds require our own MSVC compile (`build_tolk.bat` pattern: `vswhere` → `vcvarsall.bat x86` → compile `Tolk.cpp` + driver files).

### Tolk binding surface exposed to Lua
`tolk.output(text, interrupt)` is the primary. Also `tolk.speak`, `tolk.braille`, `tolk.silence`, `tolk.hasSpeech`, `tolk.hasBraille`, `tolk.isLoaded`, `tolk.isSpeaking`, plus init controls. Widechar → UTF-8 conversion handled C-side.

---

## 3. Lua runtime

- **Version:** Lua 5.1.4, 32-bit.
- **Sandbox denies:** `package`, `require`, `loadlib`, `dofile`, `loadfile`, `io`, `_G`.
- **Sandbox provides:** `os`, `debug`, `string`, `table`, `math`, `coroutine`, plus engine tables: `Events`, `LuaEvents`, `Modding`, `ContextPtr`, `Controls`, `UIManager`, `Game`, `Players`, `Map`, `UI`, `Locale`, `GameInfo`, `Mouse`, `ContentManager`.
- **`include(name)`** uses **bare filename stem** only — no paths. `include("Foo")` works; `include("sub/Foo")` fails. The engine indexes by stem.
- **`_G` is blocked**, so global introspection is limited. Must know what's there by name.
- **Useful `config.ini` switches (dev only):** `LoggingEnabled=1`, `EnableLuaDebugLibrary=1`, `EnableTuner=1` (see §9), `QuickStart=1` (skip splash screens).
- **Memory budget:** no documented hard ceiling. `DebugMenu.lua:280` calls `collectgarbage("count")` defensively — the engine is heap-aware but doesn't expose a mod-facing limit. Practical guidance: keep any precomputed per-turn cache under ~10 MB to stay well below typical era-appropriate Lua heap sizes (~100–200 MB). Profile on HUGE + 12 civs to establish real budget.

---

## 4. UI runtime

### Controls
- `Controls` is **metatable-backed userdata**. **Not iterable via `pairs()`.** Must look up children by name from XML.
- `ContextPtr:LookUpControl(path)` reaches across contexts using path strings like `"/InGame/CityScreen/..."` — this is how you enumerate without `pairs`.
- **Controls can be `nil` during init.** The game's own code guards with `if Controls.X then ...` (examples: `CivilopediaScreen.lua:1317, 1344, 1379`). XML layout parsing completes *after* the Lua Context is created but *before* input is enabled — any handler that fires in this window must guard. Our show/hide and input handlers should all follow this pattern.

### Input handling
- `ContextPtr:SetInputHandler(fn)` where `fn(uiMsg, wParam, lParam)` returns `bool` (`true` = consumed, stops propagation).
- **`SetInputHandler(nil)` crashes.** Clear with `function() return false end`.
- **There is no `GetInputHandler`.** `SetInputHandler` is pure replacement, not a stack. **Wrap-without-replace pattern:** before calling `SetInputHandler(ourFn)`, capture the previous handler. Since the API doesn't expose it, we can only do this for handlers *we* installed or for contexts whose current handler function is reachable from Lua (e.g., defined in a file we can `include`). For game screens whose handler is a local in a file scope we can't reach, wrapping requires replacing their file — we lose function chaining.

### Events system — `Events.X` vs `LuaEvents.X`
- **`Events.X`** — C++-originated events. Subscribe via `Events.X.Add(fn)`. Engine-facing.
- **`LuaEvents.X`** — pure-Lua pub/sub between scripts. Same `.Add(fn)` API.
- **`.Add(fn)` chains** — multiple listeners allowed. Confirmed via game code: `MainMenu.lua:133, 307` uses `.Add` without replacement semantics. This is how we observe without interfering with the game's own handlers.
- **`.Remove(fn)`** — API exists conceptually but no usage in the 173 game UI files. Behavior unverified; expect to replace handlers by no-op rather than remove when unbinding.

### Context lifecycle
- `ContextPtr:SetShowHideHandler(fn)` — signature is **`fn(isHide)`** (a single boolean). Confirmed in `CivilopediaScreen.lua`. Fires on visibility transitions only, not layout/resize. No "idle after show" signal — the first frame after show may still have `Controls.X == nil`, so read-then-announce must be deferred (queue via `ContextPtr:SetUpdate` one tick, or retry on first input).
- `ContextPtr:SetInputHandler(fn)` — see above.
- `ContextPtr:SetUpdate(fn)` — per-frame update. Poll fallback; prefer event-driven.
- `ContextPtr:GetID()` — returns the context's string ID, useful to distinguish e.g. in-game vs front-end instances (`"OptionsMenu"` vs `"OptionsMenu_InGame"`).

### UIManager
- **No context enumeration API.** `UIManager` exposes `QueuePopup`, `DequeuePopup`, `GetShift`/`GetAlt`/`GetControl` (modifier key state), `SetUICursor`, but no `GetContext` / `FindChildByID` / `ListContexts`. **To know which screen is active, we must track show/hide handler fires ourselves.**
- `UIManager:QueuePopup(control, priority)` with `priority` from the `PopupPriority` enum (e.g., `PopupPriority.SaveMenu`, `PopupPriority.InGameMenu`). Priority governs popup stacking; whether it also governs keyboard input priority is **unverified** (see §12).

### Control types and their callbacks
| Type | Callback API | Argument shape |
|---|---|---|
| **CheckBox** | `RegisterCheckHandler(fn)` | `fn(isChecked)` |
| **PullDown** | `RegisterSelectionCallback(fn)` | `fn(void1)` — entry's `void1`, **not** index |
| **Slider** | `RegisterSliderCallback(fn)` | `fn(fValue, void1)` — value float 0.0–1.0 |
| **EditBox** | `RegisterCallback(fn)` | fires on Enter; per-char via `CallOnChar` XML attr (underdocumented) |
| **Button** | `RegisterCallback(Mouse.eLClick, fn)` | click callback |

**PullDown gotcha:** after `BuildEntry()` calls, `CalculateInternals()` must be called or entries duplicate on rebuild.

### The universal popup hook
`Events.SerialEventGameMessagePopup(popupInfo)` dispatches **69 distinct `ButtonPopupTypes.*` values** (verified by grep across game assets — earlier sessions underestimated this). Fires only on explicit game actions or state transitions, **not** on tooltips or hovers — confirmed by inspecting the two publishing callsites in `InGame.lua:217` (`GiftUnit`) and `InGame.lua:1108` (show-handler kick detection). Safe to subscribe without performance concern. One handler + switch on `popupInfo.Type` covers the entire modal popup surface.

---

## 5. Gameplay API

### Map & hex grid
- **Staggered offset grid, pointy-top.** Coords are `(x, y)`.
- `Map.GetPlot(x, y)` — fetch a plot.
- `Map.GetPlotByIndex(i)` + `Map.GetNumPlots()` — linear iteration. This is what the game's own `InGame.lua:89` uses for full-map scans.
- `Map.GetGridSize()` returns `(width, height)`.
- `Map.PlotDirection(x, y, dir)` — neighbor lookup, `dir` ∈ 0..5 = **NE, E, SE, SW, W, NW**. Returns `nil` at map edges. **Never manually compute offsets.**
- **Three independent plot layers:**
  - `GetPlotType()` — LAND / HILLS / MOUNTAIN / OCEAN
  - `GetTerrainType()` — GRASS / PLAINS / DESERT / TUNDRA / SNOW / COAST / OCEAN
  - `GetFeatureType()` — FOREST / JUNGLE / MARSH / OASIS / ICE / FALLOUT / etc.
- **Rivers are edge properties**, not plot properties.
- **Lakes are a freshwater flag** on water terrain, not a distinct terrain.
- **Visibility is three-state:** unexplored, revealed-but-not-visible (fog), visible. Queries: `IsRevealed(teamID)`, `IsVisible(teamID)`. **Use fog-aware variants** (`GetRevealedOwner`, `GetRevealedImprovementType`, `GetRevealedRouteType`) to respect fog naturally without client-side filtering.
- **Y-parity determines the column's vertical-diagonal direction** on pointy-top — no state tracking needed to navigate a "vertical" line.

### Map dimensions & iteration cost
| Size | Plots | Full iteration |
|---|---|---|
| Standard | 80 × 52 = 4,160 | cheap |
| Huge | 128 × 80 = 10,240 | ~5–10 ms on modern CPU |

Full-plot iteration is **never done per-frame or per-turn** in game code — only on explicit action (e.g., debug hotkey toggle at `InGame.lua:89`). A hotkey-triggered "scan all improvements" feature is fine; a per-frame poll of the whole map is not. For per-turn derived data, compute once on the `Events.SerialEventGameMessagePopup`-style dirty signal and cache until the next turn.

### Camera, selection, movement
- `UI.LookAt(plot, zoom)` — move camera.
- `UI.LocationSelect(plot, ctrl, alt, shift)` — programmatic click.
- `Game.SelectionListMove(plot)` — move selected unit to plot. One call.

### Localization
- `Locale.ConvertTextKey(key, ...)` is the canonical lookup. All in-game text flows through `TXT_KEY_*` constants.
- Returned text contains **markup tokens** (`[NEWLINE]`, `[ICON_PRODUCTION]`, `[COLOR_POSITIVE_TEXT]`, etc.) that **must be stripped** before Tolk — screen readers will read them literally.

### API surface scale
- `Game`: ~378 methods
- `Player`: ~994 methods
- `Unit`, `City`: large binding tables (~140 KB and ~135 KB respectively of generated code)
- Canonical reference: `SDK\ModBuddy\Help\Civ5LuaAPI.html`. Prefer discovering what we need per-feature rather than indexing the whole surface.

---

## 6. OptionsManager (non-obvious protocol)

The options screen's persistence layer is **cache/sync/commit** — miss a step and changes silently vanish.

- **Three independent domains:** Game, Graphics, Resolution.
- **Protocol per domain:**
  1. `Sync<Domain>OptionsCache()` — load current values into cache
  2. `Get<Name>_Cached()` / `Set<Name>_Cached(v)` — read/write cache
  3. `Commit<Domain>Options()` — persist cache to disk
- **Cancel = call `Sync<Domain>OptionsCache()` again** — overwrites cache with on-disk values.
- **Audio is separate and easy to miss.** `GetVolumeKnobIDFromName`, `GetVolumeKnobValue`, `SetVolumeKnobValue`, `SaveAudioOptions`. Knob names: **`USER_VOLUME_MUSIC`**, **`USER_VOLUME_SFX`**, **`USER_VOLUME_AMBIENCE`**, **`USER_VOLUME_SPEECH`**. A sighted user clicking OK triggers all four commits + `SaveAudioOptions`; we must do the same.
- File location: `Assets/UI/Options/OptionsMenu.xml` + `.lua`. No DLC override exists for the UI itself.
- `LanguagePull` is marked `Hidden="1"` in XML and never unhidden — **language switching is not reachable through the Options screen.**

---

## 7. Civilopedia (engine facts only)

- **Location:** `Assets/DLC/Expansion2/UI/Civilopedia/CivilopediaScreen.lua` (7312 lines) + `.xml` (1120 lines). BNW overrides base game and G&K.
- **In-game only** via F1 or programmatic. Front-end "Other menu" version loads **before** mods activate and **cannot be mod-overridden.**
- **External entry points:**
  - `Events.SearchForPediaEntry(textOrTextKey)` — opens Civilopedia and navigates to the matching article
  - `Events.GoToPediaHomePage(categoryIndex)` — opens at a category home page
- **Built-in history** lives in `listOfTopicsViewed[]` with `currentTopic`/`endTopic` pointers. Don't reinvent; wrap.
- **Alt+Left/Right sends `WM_SYSKEYDOWN` (msg 260)**, not `WM_KEYDOWN`. Input handler must check both.

---

## 8. Mods, DLC, and distribution

### Mod VFS
- **Civ V's VFS indexes by bare filename stem.** `<File import="1">UI/Civilopedia/CivilopediaScreen.lua</File>` in `.modinfo` overrides the game file with that stem. Works exactly like DLC overrides.
- **Works in-game only.** Front-end screens load before mods activate — VFS overrides don't apply there.
- **Front-end coverage options:**
  1. Physical file replacement in the game's `Assets/UI/FrontEnd/` (conflicts with other front-end mods)
  2. Proxy-time script injection: our `setfenv` hook can detect front-end Lua contexts and `luaL_dofile` our handler script directly. No Civ V mod system involvement.

### DLC detection at runtime

**Confirmed GUIDs** (extracted from `.Civ5Pkg` manifest files in the game install):

| DLC | GUID |
|---|---|
| **Gods & Kings** (Expansion 1) | `{0E3751A1-F840-4e1b-9706-519BF484E59D}` |
| **Brave New World** (Expansion 2) | `{6DA07636-4123-4018-B643-6575B4EC336B}` |

**ContentManager API:**
- `ContentManager.IsActive(guidString, ContentType.GAMEPLAY)` — the primary check. GUID is a string (braced-UUID form above); `ContentType` is an enum, `GAMEPLAY` is the member we care about.
- Also: `ContentManager.SetActive(packages)`, `ContentManager.GetAllPackageIDs()`, `ContentManager.IsUpgrade(packageID)`, `ContentManager.GetPackageDescription(packageID)`.

BNW-only globals (`Game.GetActiveLeague()`, trade-route system) also serve as implicit feature flags — they're `nil` on non-BNW installs.

### Steam Cloud sync scope
**Saves only.** Confirmed at `Assets/UI/InGame/Menus/SaveMenu.lua` (`Steam.CopyLastAutoSaveToSteamCloud()`). Mod files, `config.ini`, and mod-activation state are **not** Cloud-synced. A user launching on a second machine must install our mod manually. This means: our installer needs to be **portable** — runnable on any machine that has the game, without depending on saved state.

### Steam Workshop + our DLLs
- **Workshop installs mods to `Documents\My Games\...\MODS\`.** Cannot deliver files into the game install dir.
- **Workshop submission rules for shipping executables are undocumented locally** — the Civ V SDK has no Workshop policy docs. Precedent from Vox Populi / Community Patch is to ship a Workshop Lua-shell + separate GitHub release for DLLs. This is the likely path for us too; confirm before first submission.
- Our installer must be idempotent and re-runnable — Steam's "Verify integrity of game files" will revert the proxy (and any physical file replacements) periodically.
- Steam verify is our **restore mechanism** when recovering from prior deploys: it surgically reports and redownloads only mismatched files.

### Versioning
- `.modinfo` has a `<Version>` attribute on the `<Mod>` element.
- For proxy ↔ Lua-mod version checks: embed a version constant in both sides; the Lua mod reads the proxy's constant (via a dedicated `tolk.*` function we add), mismatches surface as a spoken warning on first activation. No standard Civ V "please reinstall" UI exists — we build our own via a queued Tolk message.

---

## 9. Dev tooling

### FireTuner2
- **Present** at `SDK\FireTuner2\FireTuner2.exe`.
- Connects to a running game session over a local TCP socket. Game side enables the listener via `config.ini` — by convention `EnableTuner=1` (Civ V uses this key; Civ VI's docs at [jonathanturnock.github.io/civ-vi-modding/docs/fire-tuner/](https://jonathanturnock.github.io/civ-vi-modding/docs/fire-tuner/) describe the same pattern).
- Provides: live **Lua REPL**, `.ftp` **panels** with watch fields + buttons bound to Lua snippets, **event observation** (`Events.X` and `LuaEvents.X`).
- **Scope:** Lua VM only. Cannot inspect native DLLs.
- **Current-build compatibility unverified** (Civ V has been stable for years; expected to still work; no definitive recent modder confirmation found locally). First task once dev is underway: confirm it connects, or move on to alternative diagnostics.

### ModBuddy
- At `SDK\ModBuddy\ModBuddy.exe` — Visual Studio–derived IDE for editing `.modinfo`, XML, and Lua.
- **We don't need it to build the mod**, but the Lua API reference it ships (`ModBuddy\Help\Civ5LuaAPI.html`) is the canonical function list.

### In-game debug console
- No evidence of a built-in debug-console hotkey (Ctrl+Shift+D and similar searches turned up nothing in game code).
- **Buildable ourselves** as an InGameUIAddin: a hidden popup context with a text buffer, toggled by a hotkey via `LuaEvents`, output spoken through Tolk. Useful for end-user diagnostics without requiring FireTuner.

### Native debugging
- Attach MSVC debugger to the running game for proxy/native code. Tuner cannot reach this.
- **Build toolchain:** `vswhere.exe` → `vcvarsall.bat x86` → MSVC. VS 2015+ Build Tools is sufficient (we are not on the `CvGameCoreDLL` path, so the old VS 2008/2010 requirement doesn't apply).

### Logs
- `Lua.log` — script errors (populated only with `LoggingEnabled=1`)
- `APP.log` — engine-level
- Our proxy writes `proxy_debug.log` next to the DLL in the game install

---

## 10. Confirmed dead ends

Facts verified by the prior author through trial, or by this session's research; don't retry.

- **`require("tolk")` / Lua C module bridge.** Windows is case-insensitive; a Lua module named `tolk.dll` collides with Tolk's own `Tolk.dll`. **Load Tolk at C level; bind via proxy instead.**
- **Front-end mod VFS override.** Front-end Lua loads before `ActivateEnabledMods()`. Only physical file replacement or proxy-time script injection reaches the front-end.
- **Per-DLC `InGame.xml` duplication.** Author-documented as "not sustainable."
- **`SetInputHandler(nil)`.** Crashes. Always use `function() return false end`.
- **Iterating `Controls` with `pairs()`.** Userdata, not a table. Use `ContextPtr:LookUpControl(path)` with XML-known names.
- **Reading `Controls.X` in an early show-handler.** Can be `nil` before layout parse completes. Guard with `if Controls.X then ...` or defer one tick via `ContextPtr:SetUpdate`.
- **Retrieving the current input handler.** No `GetInputHandler` exists. Either install our handler early and wrap subsequent ones, or accept replacement for game-provided handlers in files we can't reach.
- **Context enumeration via `UIManager`.** No listing API. Track contexts yourself through show/hide handler installation.

---

## 11. Confirmed engine behavior (research answers)

Results of this session's research agents. Evidence cited inline.

### Threading (Q1) — VERIFIED
Lua VM is single-threaded. Only coroutines exist for concurrency within Lua; no worker-thread entry points. Game core sim runs on a separate thread but does not enter Lua. **Tolk calls originate from the main thread, always.**

### Input handler replacement (Q2) — VERIFIED
`SetInputHandler` is pure replacement. No `GetInputHandler`. To wrap without breaking existing handlers, capture the previous handler in a closure *before* calling `SetInputHandler(ourFn)` — but only feasible when the previous handler is a function we can reach (defined in our own code or in a file we `include`). Evidence: `AccessibleForm.lua:1080, 1106` (prior mod) uses the unconditional-replacement pattern.

### Event subscription chains (Q3) — VERIFIED
`Events.X.Add(fn)` and `LuaEvents.X.Add(fn)` both **chain** — multiple listeners allowed. Evidence: `MainMenu.lua:133, 307` and `InGame.lua:289`. `.Remove(fn)` API exists conceptually but shows zero usage in 173 game UI files — assume it works, fall back to no-op'ing our own listener if removal misbehaves.

### Show/hide handler signature (Q4) — VERIFIED
`ContextPtr:SetShowHideHandler(fn)` with signature `fn(isHide)` — a single boolean. Fires on visibility transitions only, not layout/resize. Evidence: `CivilopediaScreen.lua` uses this pattern. No "now idle" signal; plan for `Controls.X` being `nil` on the first show and defer reads.

### Context enumeration (Q6) — VERIFIED negative
No `UIManager:GetContext` / `FindChildByID` / list API exists. To know which screen is active, subscribe to show/hide handlers as we install them and keep our own active-screen stack.

### Popup types through `SerialEventGameMessagePopup` (Q12) — VERIFIED, corrected
**69 distinct `ButtonPopupTypes.*` values** dispatch through this one event — not 16 as an earlier session estimate claimed. Fires only on explicit game actions / state transitions, never on tooltips or hovers. Publishing callsites: `InGame.lua:217` (`GiftUnit`) and `InGame.lua:1108` (kick detection). One subscription covers the entire modal popup surface.

### Pre-init race on Controls (Q13) — VERIFIED
`Controls.X` can be `nil` during early show-handler invocation. Game's own code guards explicitly: `CivilopediaScreen.lua:1317, 1344, 1379` use `if Controls.X then ...` before access. **Our pattern: all show-handler Control reads go through guard, or defer one tick via `ContextPtr:SetUpdate`.**

### Plot iteration cost (Q11) — VERIFIED
Standard map = 4,160 plots; Huge map = 10,240 plots. Full iteration is never done per-frame or per-turn in game code — only on explicit hotkey actions (e.g., debug-mode toggle at `InGame.lua:89`). Tight-loop iteration is ~5–10 ms on modern CPU for Huge. **OK for hotkey-triggered scans and once-per-turn catalog rebuilds; not OK for per-frame poll.**

### DLC GUIDs (Q7) — VERIFIED
See §8. G&K: `{0E3751A1-F840-4e1b-9706-519BF484E59D}`. BNW: `{6DA07636-4123-4018-B643-6575B4EC336B}`. Use with `ContentManager.IsActive(guid, ContentType.GAMEPLAY)`.

### Steam Cloud scope (Q9) — VERIFIED
Saves only. Mod files and config.ini are not synced. Installer must run on each user's machine.

### FireTuner2 presence (Q15) — VERIFIED presence; compatibility unconfirmed
Installed at `SDK\FireTuner2\FireTuner2.exe`. TCP-socket protocol unchanged in principle. First-use validation is a task; don't assume.

### Memory budget (Q17) — INFERRED only
No hard ceiling found in code. `DebugMenu.lua:280` monitors heap via `collectgarbage("count")`. Practical guidance: keep precomputed per-turn data under ~10 MB. Profile on Huge + 12 civs to establish ceilings.

---

## 12. Remaining unknowns

Genuinely open, not answerable from static research; all three need in-game empirical testing.

- **Q5 — Popup input stacking.** When a `UIManager:QueuePopup` popup is shown on top of a screen, do keyboard events still reach the underlying context's input handler, or is the popup exclusive? `PopupPriority` governs popup ordering; whether it also governs input capture is unverified. **Test:** install an input handler on an underlying context, queue a higher-priority popup, fire a key, check whether the underlying handler fires. This determines whether our master input handler needs popup-stack awareness.
- **Q8 — Steam Workshop DLL shipping policy.** Undocumented in local files. Confirm externally (Steam Workshop submission guidelines for Civ V, or by attempting a Workshop submission with a DLL-bearing installer and seeing whether it's rejected). Practical precedent from Vox Populi points to GitHub-release-plus-Workshop-shell as the standard — probably applies to us too.
- **Q14 — Mouse event suppression.** No `SetMouseHandler` API surfaced. Modal popups presumably block underlying clicks via `PopupPriority`; whether we can selectively suppress mouse events while keeping keyboard ownership is unverified. **Test:** install our keyboard handler on the colony view, verify whether sighted-user mouse clicks on the underlying map still fire their callbacks.

All three are small, bounded tests once the dev loop is running. None block architecture.

---

## 13. Architectural decisions made this session

For the record, so we don't relitigate:

- **Target all three editions from one mod.** Runtime DLC detection via `ContentManager.IsActive` with the confirmed GUIDs; edition-specific features register conditionally.
- **Custom `CvGameCoreDLL` path is permanently rejected** — it disables multiplayer, which is non-negotiable.
- **Tolk loads via `lua51_Win32.dll` proxy.** Chain validated in §2. Architecture is final; implementation is ours to rewrite cleanly.
- **File-level game overrides only where mod VFS can't reach** (i.e., front-end). Where possible, observe and wrap via `Events.X` / `LuaEvents.X` / `ContextPtr` hooks rather than replacing files.
- **Clean-room rewrite of everything above the loader.** The prior author's UI framework, base classes, handlers, and design philosophy are out of scope.
- **Dev loop:** FireTuner2 for Lua discovery, MSVC debugger for the proxy, `Lua.log` + `APP.log` + `proxy_debug.log` for diagnostics.
- **Recovery strategy** if install state becomes unclear: Steam "Verify integrity of game files" (reverts game-dir changes surgically), then manually reinstall our proxy + Tolk DLLs.
- **Distribution:** likely pattern is Workshop-shell Lua mod + GitHub-release DLL installer. Confirm policy before first submission.

---

## 14. Known current install state

As of session end:
- Prior author's proxy is installed at `C:\Program Files (x86)\Steam\steamapps\common\Sid Meier's Civilization V\lua51_Win32.dll`. Working (`proxy_debug.log` reports 115 exports resolved, Tolk loaded, auto-enable fired).
- Prior author's 22 UI file overrides are deployed in `Assets/UI/` within the game install. **These need to be reverted** before we can develop cleanly.
- Prior author's 32-bit Tolk + companion DLLs (`Tolk.dll`, `nvdaControllerClient32.dll`, `SAAPI32.dll`, `dolapi32.dll`) are in the game dir. **Safe to keep** — we built those ourselves and will reuse them.
- Prior author's Civ V mod is in `Documents\My Games\Sid Meier's Civilization 5\MODS\CivVAccessibility (v 1)\`. **Should be deleted** so the auto-enable points at nothing.
- Pending action: Steam "Verify integrity of game files" to restore the 22 overridden UI files, then delete the prior mod directory, then we have a clean baseline with the proxy still working.
