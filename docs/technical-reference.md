# Civ V technical reference

Engine facts, gotchas, and architectural decisions for the accessibility mod at `C:\Users\rasha\Documents\Civ-V-Mod`. Scope: behavior and call-ordering that isn't derivable by grepping the shipped Lua, plus load-bearing decisions we've made. Function/method inventories live in `docs/llm-docs/lua-api/`; event lists in `docs/llm-docs/events-catalog.md` and `luaevents-catalog.md`; screen paths in `docs/llm-docs/screen-inventory.md`. Implementation detail of code that already exists in the repo is **not** documented here — read the code.

---

## 1. Target

- **Game:** Sid Meier's Civilization V. 32-bit (x86) on Windows.
- **Editions:** vanilla, Gods & Kings, Brave New World, from one mod. Runtime DLC detection gates edition-specific features.
- **Executables:** `CivilizationV.exe` (DX9) and `CivilizationV_DX11.exe` (DX11). Both load `lua51_Win32.dll` from the install dir; one proxy covers both.
- **Default install:** `C:\Program Files (x86)\Steam\steamapps\common\Sid Meier's Civilization V\`.
- **SDK install:** `C:\Program Files (x86)\Steam\steamapps\common\Sid Meier's Civilization V SDK\` — contains `FireTuner2\FireTuner2.exe`, `ModBuddy\ModBuddy.exe`, and the Lua API reference at `ModBuddy\Help\Civ5LuaAPI.html` (incomplete stub — supplemented by `docs/llm-docs/lua-api/`).
- **User data:** `%USERPROFILE%\Documents\My Games\Sid Meier's Civilization 5\`.
- **Logs:** `Documents\My Games\Sid Meier's Civilization 5\Logs\` — `Lua.log` for script errors (requires `LoggingEnabled=1` in `config.ini`), `APP.log` for engine. Our proxy writes `proxy_debug.log` next to the DLL in the game install.

---

## 2. Tolk injection: the decision

Four approaches were considered; only the `lua51_Win32.dll` proxy is viable.

| Approach | MP-safe | Achievements | DLC-orthogonal | Workshop-distributable | Verdict |
|---|---|---|---|---|---|
| **Custom CvGameCoreDLL** (official SDK path) | **No** | Disabled | Yes | Yes | Rejected — MP mandatory |
| **System-DLL search-order proxy** (e.g. proxy `dbghelp.dll`) | Yes | Yes | Yes | **No** (Workshop installs to `My Games\MODS\`, not game dir) | Rejected |
| **Launcher + CreateRemoteThread** | Yes | Yes | Yes | **No** (AV flags it, breaks Steam Play button) | Rejected |
| **Lua module via `require("tolk")`** | N/A | N/A | N/A | N/A | Rejected — `tolk.dll` collides with `Tolk.dll` on Windows case-insensitive FS |
| **`lua51_Win32.dll` proxy** | **Yes** | **Yes** | **Yes** | Requires manual install to game dir | **Chosen** |

### Why the lua51 proxy works
- Lua is **not in the multiplayer determinism path.** Gameplay sim runs in `CvGameCoreDLL`; we never touch it. No desync risk.
- Achievement gating checks the gameplay DLL's identity, not Lua's. Untouched gameplay DLL = achievements stay on.
- `lua51_Win32.dll` loads **in every mode the game enters** — front-end, in-game, DX9, DX11, any DLC combo. One hook point reaches everything.

Implementation lives at `src/proxy/proxy.c`. Hook summary: `luaL_openlibs` binds `tolk` as a global; `lua_setfenv` surfaces `tolk` into per-Context sandboxes and one-shot auto-enables our mod; `lua_newstate`/`luaL_newstate` are backstops. Tolk init is lazy on first `tolk.*` call.

### Threading constraint
Civ V's Lua VM is **single-threaded**. Only coroutines exist for concurrency within Lua; no worker-thread entry points. Game core sim runs on a separate thread but does not enter Lua. All `tolk.*` calls originate from the main thread. Evidence: `Assets/UI/InGame/Popups/ProductionPopup.lua` (core-thread separation comments), `Assets/UI/FrontEnd/GameSetup/UniqueBonuses.lua` (coroutine-only concurrency).

### Companion DLLs (all 32-bit, next to the proxy)
`Tolk.dll`, `nvdaControllerClient32.dll`, `SAAPI32.dll`, `dolapi32.dll`. Tolk dynamically loads these per-screen-reader; any missing DLL silently drops support for its reader without a visible error. Upstream Tolk ships 64-bit only; 32-bit build vendored at `third_party/tolk/dist/x86/`.

---

## 3. Lua runtime

- **Version:** Lua 5.1.4, 32-bit.
- **Sandbox denies:** `package`, `require`, `loadlib`, `dofile`, `loadfile`, `io`, `_G`.
- **Sandbox provides:** `os`, `debug`, `string`, `table`, `math`, `coroutine`, plus engine tables: `Events`, `LuaEvents`, `Modding`, `ContextPtr`, `Controls`, `UIManager`, `Game`, `Players`, `Map`, `UI`, `Locale`, `GameInfo`, `Mouse`, `ContentManager`.
- **`include(name)`** uses **bare filename stem** only. `include("Foo")` works; `include("sub/Foo")` fails. The engine indexes by stem.
- **`include()` requires `import="1"` in `.modinfo`.** Files with `import="0"` are copied into the mod folder but not registered in the VFS, so `include()` silently finds nothing. Entry-point files referenced by `<EntryPoints>` (e.g. `InGameUIAddin` Boot.xml/Boot.lua) work at `import="0"` because the engine loads them by path; everything pulled via `include()` must be `import="1"`.
- **`_G` is blocked**, so global introspection is limited. Know what's there by name, or find it in game UI Lua.
- **Useful `config.ini` switches (dev only):** `LoggingEnabled=1`, `EnableLuaDebugLibrary=1`, `EnableTuner=1` (see §8), `QuickStart=1` (skip splash screens).
- **Memory budget:** no documented hard ceiling. `DebugMenu.lua:280` monitors heap via `collectgarbage("count")`. Practical guidance: keep any per-turn precomputed cache under ~10 MB. Profile on Huge + 12 civs to establish real budget.

---

## 4. UI runtime behavior

Function inventories for `ContextPtr`, `UIManager`, `Controls` live in `docs/llm-docs/lua-api/`. This section covers behavior, call-ordering, and gotchas that aren't derivable from the call-shape listings.

### Controls userdata
- `Controls` is **metatable-backed userdata**. **Not iterable via `pairs()`.** Look up children by XML name via `ContextPtr:LookUpControl(path)`, which uses path strings like `"/InGame/CityScreen/..."` and reaches across contexts.
- **`Controls.X` can be `nil` during early show.** XML layout parsing completes *after* the Lua Context is created but *before* input is enabled. Game code guards explicitly: `CivilopediaScreen.lua:1317, 1344, 1379`. Our show-handler reads must guard (`if Controls.X then ...`) or defer one tick via `ContextPtr:SetUpdate`.

### PullDown rebuild gotcha
After `pullDown:BuildEntry(...)` calls, `pullDown:CalculateInternals()` must be called or entries duplicate on rebuild. Game code universally follows this pattern (see `lua-api/Controls.md` under `BuildEntry` / `CalculateInternals`).

### Input handling
- `ContextPtr:SetInputHandler(fn)` where `fn(uiMsg, wParam, lParam)` returns `bool` (`true` = consumed).
- **`SetInputHandler(nil)` crashes.** Clear with `function() return false end`.
- **No `GetInputHandler`.** `SetInputHandler` is pure replacement, not a stack. To wrap without replacing, capture the previous handler in a closure *before* calling `SetInputHandler` — but only feasible when the previous handler is a function we can reach (defined in our own code or in a file we `include`). For game screens whose handler is a file-local we can't reach, wrapping requires replacing the file.
- **Alt-chord keys send `WM_SYSKEYDOWN` (msg 260)**, not `WM_KEYDOWN`. Input handlers catching `Alt+Left/Right` and similar must check both messages.
- **`InGameUIAddin` contexts receive world-view keyboard events and their `return true` suppresses the engine's bound hotkey.** Verified by probe on an `InGameUIAddin`-registered Boot context: `SetInputHandler` saw `WM_KEYDOWN wParam=70` (F) while the world map was focused, and returning `true` prevented Find-next-unit from advancing the selection (confirmed by querying `UI.GetHeadSelectedUnit():GetID()` before and after repeated F presses — ID stable; comma/period unit-cycling still worked, proving the engine wasn't otherwise frozen). So InputRouter can install on any `InGameUIAddin` context's `SetInputHandler` and its consumption contract holds against engine hotkeys.
- **`Keys` letter constants are bare, not `VK_`-prefixed.** `Keys.F` (= 70), not `Keys.VK_F` (nil). Special keys keep the `VK_` prefix (`Keys.VK_RETURN`, `Keys.VK_ESCAPE`, `Keys.VK_F1`, `Keys.VK_LEFT`, `Keys.VK_OEM_3`, etc.).

### Events: `Events.X` vs `LuaEvents.X`
- `Events.X` are C++-originated; `LuaEvents.X` are pure-Lua pub/sub between scripts. Both use the same `.Add(fn)` API. Full catalogs at `docs/llm-docs/events-catalog.md` and `luaevents-catalog.md`.
- **`.Add(fn)` chains.** Multiple listeners allowed — this is how we observe without evicting game handlers. Evidence: `MainMenu.lua:133, 307`, `InGame.lua:289`.
- **`.Remove(fn)`** — API exists conceptually but zero usage in 173 game UI files. Assume best-effort; fall back to no-op'ing our own listener if removal misbehaves.

### Context lifecycle
- `ContextPtr:SetShowHideHandler(fn)` — signature is **`fn(isHide)`**, single boolean. Fires on visibility transitions only, not layout/resize. There is **no "now idle" signal** — the first frame after show may still have `Controls.X == nil`, so read-then-announce must be deferred (queue via `ContextPtr:SetUpdate` one tick, or retry on first input). Evidence: `CivilopediaScreen.lua` SetShowHideHandler registration.
- `ContextPtr:GetID()` — useful to distinguish e.g. in-game vs front-end instances (`"OptionsMenu"` vs `"OptionsMenu_InGame"`).

### Context enumeration
`UIManager` exposes **name-keyed** context queries (`GetNamedContextByIndex`, `GetNamedContextCount`, `GetVisibleNamedContext`, `IsModal`), but **no generic listing API** — you have to know the context name to ask. To track which arbitrary screens are active, subscribe to show/hide handlers ourselves as we install them.

### The universal popup hook
`Events.SerialEventGameMessagePopup(popupInfo)` dispatches the entire modal popup surface via `popupInfo.Type` (69 distinct `ButtonPopupTypes.*` values, enumerated at the top of `events-catalog.md`). Fires only on explicit game actions or state transitions, **not** on tooltips or hovers. One handler + switch-on-type covers every modal.

---

## 5. Gameplay API behavior

Function inventories for `Map`, `Plot`, `Game`, `UI`, `Player`, `Unit`, `City` live in `docs/llm-docs/lua-api/`. This section covers data-model shape, call-cost constraints, and markup conventions — things not derivable from the call-shape listings.

### Hex grid
- **Staggered offset grid, pointy-top.** Coords are `(x, y)`.
- Neighbor lookup is `Map.PlotDirection(x, y, dir)` with `dir` ∈ 0..5 = **NE, E, SE, SW, W, NW**; returns `nil` at map edges. **Never manually compute offsets** — y-parity determines the column's vertical-diagonal direction and the engine handles it.

### Plot data layers
Three independent queries on each plot:
- `GetPlotType()` → LAND / HILLS / MOUNTAIN / OCEAN
- `GetTerrainType()` → GRASS / PLAINS / DESERT / TUNDRA / SNOW / COAST / OCEAN
- `GetFeatureType()` → FOREST / JUNGLE / MARSH / OASIS / ICE / FALLOUT / etc.

Plus: **rivers are edge properties**, not plot properties. **Lakes are a freshwater flag** on water terrain, not a distinct terrain.

### Visibility
Three-state: unexplored, revealed-but-not-visible (fog), visible. Queries: `IsRevealed(teamID)`, `IsVisible(teamID)`. **Use fog-aware accessors** (`GetRevealedOwner`, `GetRevealedImprovementType`, `GetRevealedRouteType`) rather than the unfiltered versions — they respect fog naturally without client-side filtering.

### Iteration cost
| Size | Plots | Full iteration |
|---|---|---|
| Standard | 80 × 52 = 4,160 | cheap |
| Huge | 128 × 80 = 10,240 | ~5–10 ms on modern CPU |

Full-plot iteration is **never done per-frame or per-turn** in game code — only on explicit action (e.g. debug toggle at `InGame.lua:89`). Hotkey-triggered scans and once-per-turn catalog rebuilds are fine; per-frame polling of the whole map is not.

### Localization markup
`Locale.ConvertTextKey(key, ...)` is the canonical lookup; all in-game text flows through `TXT_KEY_*` constants (indexed at `docs/llm-docs/txt-keys/ui-text-keys.md`). Returned strings contain **markup tokens** (`[NEWLINE]`, `[ICON_PRODUCTION]`, `[COLOR_POSITIVE_TEXT]`, etc.) that **must be stripped** before Tolk — screen readers read them literally. Stripping lives in `CivVAccess_TextFilter`.

---

## 6. OptionsManager protocol

The function inventory and the cache/sync/commit protocol now live in `docs/llm-docs/lua-api/OptionsManager.md`, alongside the audio volume globals (which are bare globals, not on the `OptionsManager` table, and require their own `SaveAudioOptions()` — easy to miss).

The only architectural note beyond the catalog: a sighted user clicking OK on the options screen triggers all three domain commits **plus** `SaveAudioOptions()`. Any accessible replacement for the options flow must do the same or audio edits silently vanish.

---

## 7. Civilopedia

Screen file paths and the top-level control inventory are in `docs/llm-docs/screen-inventory.md`. External entry-point events (`Events.SearchForPediaEntry`, `Events.GoToPediaHomePage`) are in `docs/llm-docs/events-catalog.md`.

Architectural notes:

- **In-game only.** The front-end "Other menu" Civilopedia loads *before* mods activate and **cannot be mod-overridden** via the VFS. Reaching it requires physical file replacement or proxy-time script injection.
- **BNW overrides base game and G&K** at the VFS level. In-game instance-of-Civilopedia is the BNW file on any install that has BNW active.
- **Built-in navigation history** lives in `listOfTopicsViewed[]` with `currentTopic`/`endTopic` pointers inside `CivilopediaScreen.lua`. Wrap, don't reinvent.

---

## 8. Mods, DLC, and distribution

### Mod VFS
- **Civ V's VFS indexes by bare filename stem.** `<File import="1">UI/Civilopedia/CivilopediaScreen.lua</File>` in `.modinfo` overrides the game file with that stem. Works exactly like DLC overrides.
- **Works in-game only.** Front-end screens load before mods activate — VFS overrides don't apply there.
- **Front-end coverage options:**
  1. Physical file replacement in the game's `Assets/UI/FrontEnd/` (conflicts with other front-end mods).
  2. Proxy-time script injection via the `setfenv` hook for front-end Lua contexts. No Civ V mod system involvement.

### DLC detection
GUIDs and the `ContentManager.IsActive` pattern are in `docs/llm-docs/lua-api/ContentManager.md`. Use alongside the BNW-only globals (`Game.GetActiveLeague()`, trade-route system) as implicit feature flags on edition-conditional code paths.

### Steam Cloud
**Saves only.** Evidence: `Assets/UI/InGame/Menus/SaveMenu.lua` (`Steam.CopyLastAutoSaveToSteamCloud()`). Mod files, `config.ini`, and mod-activation state are not Cloud-synced. A user launching on a second machine must install our mod manually; the installer must be portable.

### Steam Workshop + our DLLs
- **Workshop installs mods to `Documents\My Games\...\MODS\`.** Cannot deliver files into the game install dir.
- **Workshop submission policy for shipping executables is undocumented locally.** Precedent from Vox Populi / Community Patch: Workshop Lua-shell + separate GitHub release for DLLs. Likely our path too; confirm before first submission.
- Installer must be idempotent. Steam's "Verify integrity of game files" will revert the proxy (and any physical file replacements) periodically — it's also our restore mechanism when recovering from prior deploys.

### Versioning
- `.modinfo` has `<Version>` on `<Mod>`. Civ V keys mod state on `(ModID, Version)`, so bumping version strands prior enable state and ModUserData under the old row. Version stays at 1 during development; bump on release only.
- Proxy ↔ Lua-mod version check: embed a version constant on both sides; the Lua mod reads the proxy's via a dedicated `tolk.*` function, mismatches surface as a spoken warning. No standard Civ V "please reinstall" UI exists — we build our own.

---

## 9. Dev tooling

### FireTuner2
- At `SDK\FireTuner2\FireTuner2.exe`. Connects to a running game session over a local TCP socket. Game side enables the listener via `config.ini` `EnableTuner=1` (Civ VI uses the same pattern; see [jonathanturnock.github.io/civ-vi-modding/docs/fire-tuner/](https://jonathanturnock.github.io/civ-vi-modding/docs/fire-tuner/)).
- Provides live **Lua REPL**, `.ftp` **panels** with watch fields + buttons bound to Lua snippets, and **event observation** for `Events.X` / `LuaEvents.X`.
- **Scope:** Lua VM only. Cannot inspect native DLLs.
- **Compatibility unverified.** First-use validation is a task; don't assume.

### ModBuddy
At `SDK\ModBuddy\ModBuddy.exe`. We don't need it to build. The Lua API reference it ships (`ModBuddy\Help\Civ5LuaAPI.html`) is an incomplete stub — use `docs/llm-docs/lua-api/` instead.

### In-game debug console
No built-in debug-console hotkey exists. Buildable ourselves as an `InGameUIAddin`: hidden popup context with a text buffer, toggled by hotkey via `LuaEvents`, output spoken through Tolk. Useful for end-user diagnostics without requiring FireTuner.

### Native debugging
Attach MSVC debugger to the running game for proxy/native code. VS 2015+ Build Tools is sufficient (we are not on the `CvGameCoreDLL` path, so the old VS 2008/2010 requirement doesn't apply).

---

## 10. Open questions

Need in-game empirical testing; not answerable from static research. None block architecture.

- **Popup input stacking.** When `UIManager:QueuePopup` shows a popup over a screen, do keyboard events still reach the underlying context's input handler, or is the popup exclusive? `PopupPriority` governs popup ordering; whether it also governs input capture is unverified. **Test:** install an input handler on an underlying context, queue a higher-priority popup, fire a key, check whether the underlying handler fires. Determines whether our master input handler needs popup-stack awareness.
- **Mouse event suppression.** No `SetMouseHandler` API surfaced. Modal popups presumably block underlying clicks via `PopupPriority`; whether we can selectively suppress mouse events while keeping keyboard ownership is unverified. **Test:** install our keyboard handler on the colony view, verify whether sighted-user mouse clicks on the underlying map still fire their callbacks.
- **Steam Workshop DLL shipping policy.** See §8.

---

## 11. Confirmed dead ends

Don't retry.

- **`require("tolk")` / Lua C module bridge.** DLL name collision with `Tolk.dll` on case-insensitive Windows FS. Load Tolk at C level instead.
- **Front-end mod VFS override.** Front-end Lua loads before `ActivateEnabledMods()`. Only physical file replacement or proxy-time script injection reaches the front-end.
- **Per-DLC `InGame.xml` duplication.** Prior author documented as "not sustainable."
- **`SetInputHandler(nil)`.** Crashes. Always use `function() return false end`.
- **Iterating `Controls` with `pairs()`.** Userdata, not a table. Use `ContextPtr:LookUpControl(path)` with XML-known names.
- **Retrieving the current input handler.** No `GetInputHandler` exists.
- **Generic context enumeration.** No listing API on `UIManager`; only name-keyed queries. Track arbitrary-context state via show/hide handler installation.

---

## 12. Architectural decisions

For the record, so we don't relitigate:

- **Target all three editions from one mod.** Runtime DLC detection via `ContentManager.IsActive` with the confirmed GUIDs; edition-specific features register conditionally.
- **Custom `CvGameCoreDLL` path permanently rejected** — disables multiplayer, which is non-negotiable.
- **Tolk loads via `lua51_Win32.dll` proxy.** Rationale in §2.
- **File-level game overrides only where mod VFS can't reach** (i.e. front-end). Where possible, observe and wrap via `Events.X` / `LuaEvents.X` / `ContextPtr` hooks rather than replacing files.
- **Dev loop:** FireTuner2 for Lua discovery, MSVC debugger for the proxy, `Lua.log` + `APP.log` + `proxy_debug.log` for diagnostics.
- **Recovery strategy** if install state becomes unclear: Steam "Verify integrity of game files" (reverts game-dir changes surgically), then reinstall our proxy + Tolk DLLs via `scripts/deploy.ps1`.
- **Distribution:** likely Workshop-shell Lua mod + GitHub-release DLL installer. Confirm policy before first submission.
