# Civ-V-Access — Claude Code Instructions

Civ-V-Access is an accessibility layer for Sid Meier's Civilization V that makes the game playable for blind users. It reaches into the game through three components: a `lua51_Win32.dll` proxy that binds Tolk as a global `tolk` table inside every Lua context; a fake DLC (deployed to `Assets/DLC/DLC_CivVAccess/` in the game install) that installs UI handlers via `ContextPtr`, `Events.X`, and `LuaEvents.X`; and a forked `CvGameCore_Expansion2.dll` (BNW engine) that exposes additional Lua bindings for engine APIs the stock DLL keeps internal. Packaging as a DLC (rather than a mod under `Documents/My Games/.../MODS/`) is what layers our UI files into the engine's Contexts via `<UISkin>` and keeps the session off the mod-hash list for multiplayer. Speech output is the sole interface — there is no visual fallback. Every decision should be weighed against the fact that if something fails silently or speaks stale data, the player has no way to know.

## Build

The pipeline is three standalone scripts at the repo root. Each one is run only when its own piece of the codebase has changed; the build outputs are committed, so deploys don't require a prior build.

- `build-proxy.ps1` — compiles `lua51_Win32.dll` from `src/proxy/` to `dist/proxy/lua51_Win32.dll` (committed). Picks the latest Visual Studio install with C++ build tools via `vswhere -latest -products *` and invokes its `cl.exe` through `vcvarsall.bat x86`. Re-run only when `src/proxy/` changes.
- `build-engine.ps1` — compiles the engine DLL fork (`CvGameCore_Expansion2.dll`) from the Civ V Modding SDK source plus our overlay in `src/engine/`, output to `dist/engine/CvGameCore_Expansion2.dll` (committed). Uses VC9 (Visual C++ 2008 SP1) supplied by Windows SDK 7.0's `vc_stdx86` MSI. Engine builds take 1-2 minutes; re-run only when `src/engine/` changes.
- `deploy.ps1` — copies the committed artifacts into the game install: `dist/proxy/lua51_Win32.dll`, the Tolk runtime DLLs from `third_party/tolk/dist/x86/`, the `src/dlc/` payload into `Assets/DLC/DLC_CivVAccess/`, `sounds/*.wav` into the DLC's `Sounds/`, and `dist/engine/CvGameCore_Expansion2.dll`. The engine DLL deploys by default (pass `-SkipEngine` for fast Lua-only iterations); on first install it backs up the vanilla DLL to `build/CvGameCore_Expansion2.vanilla.dll.bak`. `-Uninstall` reverses everything (restoring the vanilla engine DLL if a backup exists).
- `deploy-sighted-multiplayer.ps1` — minimal deploy for a sighted MP partner playing against a Civ-V-Access host. Copies only the engine DLL (GUID match) and `CivVAccess_2.Civ5Pkg` with empty UI directories (DLC-list match), no proxy / Tolk / Lua payload. Run on the partner's machine, not the host's.

Daily iteration when only Lua / DLC payload changed: `./deploy.ps1`. After touching `src/proxy/`: `./build-proxy.ps1; ./deploy.ps1`. After touching `src/engine/`: `./build-engine.ps1; ./deploy.ps1`. Always use the scripts; never invoke `cl.exe` / `lua` / copy commands directly.

The engine fork toolchain (VC9 + Windows SDK 7.0) is set up by `build/sdk7-install/install.cmd`, which the maintainer runs once after downloading the SDK 7.0 ISO. Contributors who only want to deploy can skip that and use the prebuilt engine DLL.

When a build fails on a Lua API or engine behavior, look it up in `docs/llm-docs/` or read the game's own UI Lua under `Sid Meier's Civilization V\Assets\` before guessing. The SDK's `Civ5LuaAPI.html` is an unfinished stub; the grep-extracted reference in `docs/llm-docs/lua-api/` supersedes it.

## Project Structure

- `docs/hotkey-reference.md` — every engine-defined keybinding across base / G&K / BNW, plus screen-reader collision notes and candidate-safe keys.
- `docs/llm-docs/` — derived reference material (Lua API per class, Events / LuaEvents catalogs, screen inventory, external resource pointers). Load on demand. See `docs/llm-docs/CLAUDE.md` for what's in each file and when to consult it.
- `src/proxy/` — `lua51_Win32.dll` proxy source (C). Only job is injecting `tolk` + `luaL_openlibs` hooks; no mod activation.
- `src/engine/` — overlay against the Firaxis SDK source for `CvGameCore_Expansion2.dll`. `build-engine.ps1` mirrors the SDK source to `build/engine/source/` and copies any files under `src/engine/` on top before compile. The diff against vanilla lives entirely under this directory; the fork's job is exposing engine APIs (pathfinder, mission queue, unit cycler) the stock DLL doesn't bind to Lua, plus a fresh `CvDllVersion.h` GUID. **Never rotate the GUID** — changing it after release splits multiplayer compatibility across mod versions.
- `src/dlc/` — fake-DLC payload. Three sibling manifests sharing one GUID (`CivVAccess_0/1/2.Civ5Pkg`, one per UISkin set: BaseGame, Expansion1, Expansion2); only `CivVAccess_2.Civ5Pkg` (`<UISkin set="Expansion2">`) carries the functional payload, the other two are CTD-prevention sentinels — see the "One Civ5Pkg manifest" gotcha below. Per-Context UI under per-Context directories (e.g. `UI/InGame/`, `UI/FrontEnd/`, `UI/TechTree/`) routed by the manifest's `<Skin>` (front-end) and `<GameplaySkin>` (in-game) directives, and cross-Context infra under `UI/Shared/` (listed under both directives so either Context can `include` from it). Mod-authored locale strings live in per-Context files with distinct include stems because `include()` caches by bare stem on the shared lua_State. BNW is a hard requirement: if the active UISkin isn't Expansion2 the functional payload never loads — no fallback to base / G&K.

## Code Style

- All speech goes through the central announcement pipeline, never call `tolk.output` / `tolk.speak` directly from feature code
- All logging goes through the mod's log wrapper, never use bare `print` or raw `Events.AppLog` calls
- All user-facing text goes through `Text.key` / `Text.format`, never `Locale.ConvertTextKey` directly. The wrapper logs missing keys; raw Locale silently returns the key name and the user hears it spelled out. Mod-authored keys (`TXT_KEY_CIVVACCESS_*`) go in `UI/InGame/CivVAccess_InGameStrings_<locale>.lua` or `UI/FrontEnd/CivVAccess_FrontEndStrings_<locale>.lua`, whichever Context consumes them (both, if both do).
- Lua files: one feature per file where possible; file name matches the `include` stem (Civ V's VFS indexes by bare stem).
- Access wrappers: `CivVAccess_XAccess.lua` lives next to every overridden vendor `X.lua` and is what the appended `include("CivVAccess_XAccess")` line at the bottom of `X.lua` reaches. Wrappers capture `priorInput` / `priorShowHide` from the vendor file's globals, then call `BaseMenu.install(ContextPtr, spec)` (or `TabbedShell.install` for tabbed screens). Spec fields are documented in the headers of `src/dlc/UI/Shared/CivVAccess_BaseMenuInstall.lua` and `CivVAccess_BaseMenuCore.lua`.

## Test

Offline Lua harness lives at `tests/`, invoked by `test.ps1` against the bundled interpreter at `third_party/lua51/lua5.1.exe` (matches the game's Lua 5.1 exactly). Tests are modules returning a table of `test_*` functions; `tests/run.lua` aggregates across suites into a single exit code. No game launch, no network, no Tolk.

- Every test should have a plausible failure mode not covered by another test — don't test the same invariant twice
- Always test real code paths; never test local helpers that simulate production behavior
- Exception: text-filter / markup-stripping regression suites keep full coverage (chain of replacements where any change can break unrelated cases)
- Guard speech-boundary code even when it looks simple — a wrong value reaching Tolk is a silent failure

### Polyfill pattern for engine globals
Engine globals that tested modules touch are polyfilled in `src/dlc/UI/InGame/CivVAccess_Polyfill.lua`. It self-disables in-game via `if ContextPtr ~= nil then return end`; `tests/run.lua` dofiles it before suites run. Never build a test-only mock instead — every stub is a place production and test can diverge. Grow the polyfill only as new modules need new globals. (Log and SpeechEngine stay as test-owned stubs in `run.lua` because suites need a monkey-patch seam to inspect calls.)

## Project Rules

### Reuse game data, avoid hardcoding
Use the game's localized text (`Locale.ConvertTextKey("TXT_KEY_*")`), UI state from live `Controls`, and entity data wherever possible. Hardcoded text blocks localization for non-English players. Only hardcode when no game data source exists.

### Never cache game state
Do not copy game data into mod-side tables, fields, or upvalues for later use. Always re-query the game when you need a value. A blind player trusts speech absolutely, so stale data is worse than no data. The only acceptable "cache" is holding a reference to a live `Controls.X` userdata or a plot/unit/city handle and reading its properties at speech time.

### No inline non-punctuation string literals
All user-facing text must come from a `TXT_KEY_*` lookup. Never inline string literals for text that gets spoken. Prefer the game's existing keys — check `docs/llm-docs/txt-keys/ui-text-keys.md` before adding a mod-authored one. Common labels ("Close", "Cancel", "Next Turn", etc.) already exist. Only add mod-authored strings when no game equivalent exists.

### Concise announcements
**These rules apply to mod-authored text only; never alter, truncate, or reword game text beyond markup stripping.** Users are experienced screen reader users. Strip fluff, never strip information.
- No positional item counts ("3 of 10")
- No navigation hints ("press Enter to select") unless unusual controls.
- No redundant context ("You are now in...")
- No type suffixes when obvious ("Next Turn button")
- DO include all gameplay-relevant details (terrain, features, yields, unit HP, city production). Concise means no fluff, not less information
- The sooner a message's varying part appears, the faster the user can keep going. Put the distinguishing word first.
  - WRONG: "plot grass" / "plot desert" — user must listen through "plot" before hearing the difference.
  - CORRECT: "grass" / "desert" — first syllable already differs.
- Avoid emdash. Screen readers announce it as "dash" which breaks the flow of speech

### Conscious hotkey management
Civ V has many engine-bound hotkeys. Many are useless to blind players and can be overwritten. But every overwrite is a deliberate decision; document what the original hotkey did and why it's being replaced. Hotkey decisions are documented at `docs/hotkey-reference.md`.

### No silent failures
This mod runs on a C-level proxy, Lua `pcall`-susceptible callbacks, and engine events whose error reporting is weak (`Lua.log` only exists with `LoggingEnabled=1`, and even then some errors never reach it). A swallowed error in an event handler means the feature silently stops working and the user has no idea why. **Every `pcall` / error branch must log through the mod's log wrapper with enough context to locate the failure.** Never drop an error on the floor, never catch-and-return-default without logging. If something fails, the player log must say what and where. A logged failure is actionable; a silent one is invisible.

### Handler conventions
Handler table shape and push/pop rules are documented in the header of `src/dlc/UI/Shared/CivVAccess_HandlerStack.lua`. Read it before adding a new screen or mode.

## Architecture Gotchas

- **Engine bindings added by the fork only resolve on a fork deploy.** Any Lua method `src/engine/` adds (look for `CIVVACCESS:` comments — currently spread across the Lua bindings under `CvGameCoreDLL_Expansion2/Lua/` plus a few core engine files where the binding's implementation lives) is missing or stubbed in the vanilla DLL — `Unit:GeneratePath` is shipped as `luaL_error("NYI")`, the others aren't registered at all. Lua callers that depend on these must either be guarded by a feature check or the contributor must run `deploy.ps1` (after `build-engine.ps1` if the overlay was just changed; engine deploys by default unless `-SkipEngine` is passed). When adding a new binding, grep `CIVVACCESS:` for the registration pattern; the overlay is full-file replacement (no patch mechanism), so the file you modify must be a verbatim copy of the SDK source plus your additions.
- **`civvaccess_shared` is the cross-Context state table** the proxy injects into every Lua sandbox in the session's lua_State. Use it for state that must be visible across Contexts or must outlast a single Context's lifetime. HandlerStack lives on it; so do published module refs (`civvaccess_shared.modules.Cursor` etc.), the cursor position, the scanner snapshot. Do not use it to gate `Events.X.Add` registrations — see the no-install-once-guards gotcha below.
- **`Events.LoadScreenClose` is the "really in a game" signal.** In-game Contexts boot during the pre-game setup flow too (one lua_State for the whole session, no state-level discriminator). Defer any "we are actually playing" work to `LoadScreenClose` rather than running it at Boot include time.
- **Load-game-from-game kills every in-game Context's env.** When the user loads a save while already in a game, the engine clears the env table of every in-game Context — every global in that env, including engine builtins like `UI` / `Game` / `Events`, becomes nil to any closure still holding that env. The engine then re-initializes some Contexts with a fresh env (WorldView, InGame, SaveMenu, GenericPopup, CityView — their include chains re-run and their new envs are populated) and not others (TaskList — its include never re-runs, so there is no path back to a live env for code that was seated there). Either way, closures created before the transition are dead forever: the env table they reference is empty, globals resolve to nil, and they silently throw on first access when the engine dispatches to them.
- **No install-once guards on Events listeners that must survive load-from-game.** The natural pattern is to gate `Events.X.Add` with a `civvaccess_shared.flagInstalled` boolean. Do not. The flag persists across game transitions (civvaccess_shared is a shared table, not per-env), but the listener it gated is dead. An install-once guard locks the mod to a stranded game-1 closure forever. Instead, register a fresh listener on every Context include (or every `installListeners()` call from `onInGameBoot`). Dead listeners accumulate — `Events.X.Remove` is unverified — but they throw on first global access and the engine catches per-listener, so the most recent live listener still fires. The same rule applies to handler-stack entries; game-1 handlers have dead-env closures, so `onInGameBoot` does `removeByName` + `push` fresh each game. Distinct from metatable patches (`PullDownProbe`) and engine resource loads (`PlotAudio.loadAll`): those *should* stay install-once because the shared resource — the metatable, the audio bank — survives the env kill.
- **The boot seat must live on a Context that re-initializes on load-from-game.** Even with fresh listeners, the re-registration only happens when the Context containing the registration code runs again. TaskList never runs again after load-from-game; WorldView does. That's why `include("CivVAccess_Boot")` is appended to our WorldView.lua override and not to TaskList.lua.
- **`Controls.X` can be `nil` during early show** — XML layout parsing completes after the Lua Context is created but before input is enabled. Show-handler code must guard (`if Controls.X then ...`) or defer one tick via `ContextPtr:SetUpdate`. The game's own code does this — follow suit.
- **`SetInputHandler(nil)` crashes.** To clear, pass `function() return false end`.
- **`Controls` is userdata, not a table.** `pairs()` does not iterate it. Look up children by name from XML via `ContextPtr:LookUpControl(path)`.
- **`include` uses bare filename stems only.** `include("Foo")` works; `include("sub/Foo")` fails. The engine indexes by stem.
- **`include` stems must not share a prefix.** Civ V's stem index silently drops the shorter of two stems when one is a prefix of the other. `include("Foo")` becomes a no-op in every Context whenever a sibling `Foo*.lua` (e.g. `FooItems.lua`) is also in the VFS: the file is never executed, the include returns without error, and any globals it would have defined stay `nil`. Pick stems that don't share prefixes; a `Core` / `Extra` suffix is the cheapest disambiguator. (Why `CivVAccess_BaseMenuCore.lua` is not `CivVAccess_BaseMenu.lua`: the latter collides with `CivVAccess_BaseMenuItems.lua`.)
- **`_G` is blocked by the sandbox.** Cannot enumerate globals for discovery — know what you're looking for by name, or find it in the game's UI Lua.
- **`.Add(fn)` chains on both `Events.X` and `LuaEvents.X`.** Prefer adding listeners over replacing — multiple listeners coexist and we don't evict the game's own handlers. `.Remove(fn)` is unverified in the wild; assume best-effort.
- **Civ V's Lua `ipairs` yields `(0, t[0])` when `t[0]` exists.** Standard Lua 5.1 ipairs starts at index 1 and treats `[0]` as unreachable; the engine's does not. Base-game code relies on this: `AdvancedSetup.lua MapTypes.FullSync` seeds `mapScripts[0] = Random`, then iterates with `for i, script in ipairs(mapScripts)`, producing N+1 `BuildEntry` calls (Random first). When pairing our own labels / indices against a pulldown that base built with this pattern, iterate the same way — the pulldown entry index is 1-based and starts with whatever lives at `[0]`. Generalize: if you see `t[0] = ...` next to an `ipairs(t)` in base code, ipairs includes it; don't assume standard behavior.
- **`Alt+Left/Right` sends `WM_SYSKEYDOWN` (msg 260)**, not `WM_KEYDOWN`. Input handlers must check both to catch Alt-chorded keys.
- **Three `Civ5Pkg` manifests, one shared GUID, only the BNW manifest carries a payload.** `CivVAccess_2.Civ5Pkg` is the functional one (`<UISkin name="Expansion2Primary" set="Expansion2">`, all the real `<Skin>` / `<GameplaySkin>` directories); `CivVAccess_0.Civ5Pkg` (BaseGame) and `CivVAccess_1.Civ5Pkg` (Expansion1) are sentinels pointing at empty `UI/SkinProbeBase/` and `UI/SkinProbeG/` directories. Without those two siblings the engine CTDs on entering any built-in tutorial or vanilla-era scenario when our DLC is active; mechanism unverified, see `CivVAccess_0.Civ5Pkg`'s header comment. Base-game and G&K *sessions* still load no accessibility code because our payload only lives under the Expansion2 directives. `<TextData>` is omitted from all three — fake-DLC text ingestion is broken in the engine, so mod strings are served from Lua via `Text.key` / `Text.format`.
- **luacheck W113 (undefined variable) is silenced for `*Access.lua` / `*Core.lua` / `*Shared.lua` wrappers** since they reach into dozens of base-game globals that aren't worth whitelisting. A typo like `OnBakc` in a wrapper won't be flagged — rely on manual review. W113 stays active in pure-mod modules (ScannerCore, SpeechPipeline, etc.) where it's still useful.

### Vendor file overrides

A pure `.Civ5Pkg` cannot declare a net-new Context, so the mod piggy-backs on overriding base files. Each override is a verbatim copy of the game's file with one or more `include()` lines appended to the Lua. We do not ship XML overrides we don't need — if our DLC doesn't provide a file, the engine loads whichever copy (base or BNW) the active UISkin resolves to naturally.

The general convention. ~110 vendor `.lua` files under `src/dlc/UI` are overridden, each with a single `include("CivVAccess_XAccess")` appended at the bottom. The wrapper file (`CivVAccess_XAccess.lua`) lives next to the vendor file and carries the entire mod payload for that screen: locale strings, includes for shared infra, a `BaseMenu.install` (or `TabbedShell.install`) call against the screen's `ContextPtr`, plus any listeners. The vendor file's appended include is a one-line stub; the wrapper does the work. (One exception: `WorldView/TradeLogic.lua` doesn't include its wrapper directly because the wrapper is loaded through sibling Contexts — `SimpleDiploTrade` and `DiploTrade` — that depend on it.)

Bootstrap-special overrides. The four below carry *additional* include lines beyond the standard wrapper tail because they own the mod's load sequence or its global key dispatch:

- `WorldView/WorldView.{lua,xml}` — in-game boot seat (module loads, LoadScreenClose wiring) plus pre-InGame key interception. Appends `include("CivVAccess_Boot")` first, then `include("CivVAccess_WorldViewKeys")`. Sourced from `Assets/DLC/Expansion2/UI/...`; BNW overrides.
- `InGame.lua` — in-game keyboard dispatch. Sourced from `Assets/DLC/Expansion2/UI/...`; BNW overrides it, so shipping from base would shadow BNW's behavior. The companion `InGame.xml` is not overridden because we don't change the layout.
- `ToolTips.{lua,xml}` — front-end. Sourced from `Assets/UI/...`; BNW leaves it untouched.

The Context split is deliberate. WorldView hosts Boot because load-game-from-game kills every Context's env (see the Architecture Gotchas entry on this) and the mod needs a Context that re-initializes afterwards so a fresh LoadScreenClose listener can be registered against a live env. WorldView does re-init; TaskList (the original boot seat) does not, which is what originally broke load-from-game.

WorldView sits earlier than InGame in the dispatch chain and its DefaultMessageHandler swallows VK_PRIOR / VK_NEXT / arrows / OEM_PLUS / OEM_MINUS by returning true before InGame sees them; our WorldView hook dispatches through HandlerStack first so scanner PageUp/PageDown bindings (with any modifier) fire before the engine's camera pan / zoom does, falling through on a miss so sighted testers keep camera control. InGame is the root Context whose InputHandler receives every global key (that's how base Esc opens the game menu), and is the only in-game seat from which `return true` can suppress an engine binding for keys that reach that far; our InGame hook catches what WorldView declines.

## Game Log

- `Lua.log` — Lua errors and `print` output, at `%USERPROFILE%\Documents\My Games\Sid Meier's Civilization 5\Logs\Lua.log`. Only populated when `config.ini` has `LoggingEnabled=1`.
- `APP.log` — engine-level, same directory.
- `proxy_debug.log` — our proxy's own log, written next to the DLL in the game install directory. Records export resolution and Tolk load.

## Common LLM Antipatterns

### Comments referring to what changed
Comments should describe the current state, not the change history. Consider whether a comment is needed at all.

**WRONG**: `-- Removed the old announcement queue. Now speaks immediately.`
**WRONG**: `-- Changed to use ContextPtr. Now handles force_close`
**CORRECT**: `-- Can be closed with the controller`

### Defensive nil handling
Excessive validation hides bugs. Only nil-check where nil is a legitimate, expected state (e.g., after a lookup that can genuinely miss, at public API boundaries, or for `Controls.X` during early show). Let code crash otherwise — a crash reaches `Lua.log`, a silently swallowed nil does not. Trust private callers.

**WRONG** — silently returning empty instead of crashing:
```lua
if plot == nil then return {} end
local owner = plot:GetOwner()
if owner == nil then return {} end
```

**WRONG** — chained `and` guards on things that should never be nil:
```lua
local name = unit and unit:GetUnitType() and GameInfo.Units[unit:GetUnitType()] and GameInfo.Units[unit:GetUnitType()].Description or "default"
```

**CORRECT**:
```lua
local name = GameInfo.Units[unit:GetUnitType()].Description or "default"
```

