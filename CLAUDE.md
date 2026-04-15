# Civ-V-Access — Claude Code Instructions

Civ-V-Access is an accessibility layer for Sid Meier's Civilization V that makes the game playable for blind users. It reaches into the game through a `lua51_Win32.dll` proxy that binds Tolk as a global `tolk` table inside every Lua context, plus a fake DLC (shipped as `Assets/DLC/CivVAccess/`) that installs UI handlers via `ContextPtr`, `Events.X`, and `LuaEvents.X`. Packaging as a DLC (rather than a mod under `Documents/My Games/.../MODS/`) is what lets the engine natively ingest our `<GameData><Text>` XML and keeps the session off the mod-hash list for multiplayer. Speech output is the sole interface — there is no visual fallback. Every decision should be weighed against the fact that if something fails silently or speaks stale data, the player has no way to know.

## Build

`build.ps1` at the repo root compiles the proxy DLL and deploys the proxy stack + DLC into the game install in one step. Always use the script; never invoke `cl.exe` / `lua` / copy commands directly. Use `-SkipBuild` when only the Lua payload changed (proxy stage is reused as-is). Use `-SkipDeploy` to validate a compile without touching the game install. Use `-Uninstall` to remove the DLC, restore the original `lua51_Win32.dll`, and clean up any legacy `MODS/Civ-V-Access (v 1)/` directory. Pass `-GameDir` to override auto-detection when the Civ V install is in an unusual location.

When a build fails on a Lua API or engine behavior, look it up in `docs/llm-docs/` (see below) or read the game's own UI Lua under `Sid Meier's Civilization V\Assets\` before guessing at fixes. The SDK's `Civ5LuaAPI.html` is an unfinished stub — ignore it; the grep-extracted reference in `docs/llm-docs/lua-api/` supersedes it.

## Project Structure

- `docs/hotkey-reference.md` — every engine-defined keybinding across base / G&K / BNW, plus screen-reader collision notes and candidate-safe keys.
- `docs/llm-docs/` — derived reference material (Lua API per class, Events / LuaEvents catalogs, screen inventory, external resource pointers). Load on demand. See `docs/llm-docs/CLAUDE.md` for what's in each file and when to consult it.
- `src/proxy/` — `lua51_Win32.dll` proxy source (C). Only job is injecting `tolk` + `luaL_openlibs` hooks; no mod activation.
- `src/dlc/` — fake-DLC payload. `CivVAccess.Civ5Pkg` is the manifest. `Gameplay/XML/Text/en_US/CivVAccess_Text.xml` holds TXT_KEY rows (add new locales as sibling dirs: `de_DE/`, `fr_FR/`, etc.). `UI/InGame/` holds all `CivVAccess_*.lua` feature modules and a verbatim copy of the base-game override target that includes `CivVAccess_Boot`. `UI/FrontEnd/` holds the front-end override target and `CivVAccess_FrontendBoot.lua`.

## Code Style

- All speech goes through the central announcement pipeline, never call `tolk.output` / `tolk.speak` directly from feature code
- All logging goes through the mod's log wrapper, never use bare `print` or raw `Events.AppLog` calls
- All user-facing text goes through `Text.key` / `Text.format`, never call `Locale.ConvertTextKey` directly. The wrapper logs missing keys; raw Locale silently returns the key name and the user hears it spelled out.
- Lua files: one feature per file where possible; file name matches the `include` stem (Civ V's VFS indexes by bare stem).

## Test

Offline Lua harness lives at `tests/`, invoked by `test.ps1` against the bundled interpreter at `third_party/lua51/lua5.1.exe` (matches the game's Lua 5.1 exactly). Tests are modules returning a table of `test_*` functions; `tests/run.lua` aggregates across suites into a single exit code. No game launch, no network, no Tolk.

- Every test should have a plausible failure mode not covered by another test — don't test the same invariant twice
- Always test real code paths; never test local helpers that simulate production behavior
- Exception: text-filter / markup-stripping regression suites keep full coverage (chain of replacements where any change can break unrelated cases)
- Guard speech-boundary code even when it looks simple — a wrong value reaching Tolk is a silent failure

### Polyfill pattern for engine globals
When a feature needs to be tested but depends on engine globals (`Game`, `Controls`, `Events`, `LuaEvents`, `Locale`, etc.), do **not** build a test-only mock. The canonical polyfill lives at `src/dlc/UI/InGame/CivVAccess_Polyfill.lua` and self-disables in-game via `if ContextPtr ~= nil then return end`. `ContextPtr` is present in every Civ V UI Context and absent from the offline test harness, so the guard fires in tests and no-ops in the game. `CivVAccess_Boot.lua` `include`s the polyfill first, and `tests/run.lua` `dofile`s it before registering suites. Grow the polyfill only as new modules need new globals; every stub is a place production and test can diverge. Log and SpeechEngine intentionally stay as test-owned stubs in `run.lua` (not in the polyfill) because suites need a monkey-patch seam to inspect calls. Pattern borrowed from FactorioAccess's `polyfill.lua`; their sentinel is `script`, ours is `ContextPtr`.

## Project Rules

### Reuse game data, avoid hardcoding
Use the game's localized text (`Locale.ConvertTextKey("TXT_KEY_*")`), UI state from live `Controls`, and entity data wherever possible. Hardcoded text becomes stale across game updates and DLC combinations, and blocks localization for non-English players. Only hardcode when no game data source exists.

### Never cache game state
Do not copy game data into mod-side tables, fields, or upvalues for later use. Always re-query the game when you need a value. A sighted player can see when the screen contradicts itself; a blind player trusts speech absolutely. Stale data is worse than no data. The only acceptable "cache" is holding a reference to a live `Controls.X` userdata or a plot/unit/city handle and reading its properties at speech time. Per-turn derived catalogs (e.g. "all my improvements") are the sole exception — rebuild them on turn transition, never hold across turns.

### No inline non-punctuation string literals
All user-facing text must come from a `TXT_KEY_*` lookup or a mod-authored string constant. Never inline string literals for text that gets spoken. Prefer the game's existing `TXT_KEY_*` entries — check `docs/llm-docs/txt-keys/ui-text-keys.md` (extracted index of UI labels across base + DLC) before adding mod-authored strings. The game already has keys for common labels ("Close", "Cancel", "Next Turn", etc.). Only add mod-authored strings when no game equivalent exists; namespace them `TXT_KEY_CIVVACCESS_*` to avoid collision with game/DLC/other-mod keys in the global text table.

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
Civ V has extensive hotkeys, many engine-bound and some reassignable via `Assets/DLC/.../ActionInfos.xml`-style data. Many are useless to blind players and can be overwritten. But every overwrite is a deliberate decision; document what the original hotkey did and why it's being replaced. Hotkey decisions are documented at `docs/hotkey-reference.md`.

### No silent failures
This mod runs on a C-level proxy, Lua `pcall`-susceptible callbacks, and engine events whose error reporting is weak (`Lua.log` only exists with `LoggingEnabled=1`, and even then some errors never reach it). A swallowed error in an event handler means the feature silently stops working and the user has no idea why. **Every `pcall` / error branch must log through the mod's log wrapper with enough context to locate the failure.** Never drop an error on the floor, never catch-and-return-default without logging. If something fails, the player log must say what and where. A logged failure is actionable; a silent one is invisible.

### Handler conventions
A handler is a plain Lua table describing a UI screen or mode on the `HandlerStack`. Shape:

- `name` (string, required): unique-ish; used by `removeByName` and debug logs.
- `capturesAllInput` (bool, default false): barrier for InputRouter's top-down walk. Defaults to false and should stay false for almost all handlers. Set true only for modal-like contexts (popups, confirmation dialogs, in-mod overlays) that should swallow unbound keys rather than let them fall through.
- `bindings` (array, optional): `{key, mods, fn, description}` entries. The handler on the stack owns its bindings; there is no central binding registry.
- `onActivate` / `onDeactivate` (fn(self), optional): fired on push / exposure and removal respectively.
- `tick` (fn(self), optional): called every frame by TickPump on the active handler only.
- `helpEntries` (array, optional): overrides `bindings` as the source for `collectHelpEntries`.

Push the handler onto `HandlerStack` when the screen opens; `removeByName` it when the screen closes. `HandlerStack` state is per-Context until the proxy shared-state table lands (followup plan), so for now all handler pushes happen in the Boot Context.

## Architecture Gotchas

- **`Controls.X` can be `nil` during early show** — XML layout parsing completes after the Lua Context is created but before input is enabled. Show-handler code must guard (`if Controls.X then ...`) or defer one tick via `ContextPtr:SetUpdate`. The game's own code does this — follow suit.
- **`SetInputHandler(nil)` crashes.** To clear, pass `function() return false end`.
- **`Controls` is userdata, not a table.** `pairs()` does not iterate it. Look up children by name from XML via `ContextPtr:LookUpControl(path)`.
- **`include` uses bare filename stems only.** `include("Foo")` works; `include("sub/Foo")` fails. The engine indexes by stem.
- **`_G` is blocked by the sandbox.** Cannot enumerate globals for discovery — know what you're looking for by name, or find it in the game's UI Lua.
- **`.Add(fn)` chains on both `Events.X` and `LuaEvents.X`.** Prefer adding listeners over replacing — multiple listeners coexist and we don't evict the game's own handlers. `.Remove(fn)` is unverified in the wild; assume best-effort.
- **`Alt+Left/Right` sends `WM_SYSKEYDOWN` (msg 260)**, not `WM_KEYDOWN`. Input handlers must check both to catch Alt-chorded keys.
- **The DLC bootstraps by overriding two base-game UI files**: `Assets/UI/InGame/TaskList.{lua,xml}` (in-game entry) and `Assets/UI/FrontEnd/ToolTips.{lua,xml}` (front-end entry). Both are copied verbatim into `src/dlc/UI/{InGame,FrontEnd}/` with an `include("CivVAccess_Boot")` or `include("CivVAccess_FrontendBoot")` appended. A pure `.Civ5Pkg` cannot declare a net-new Context, so the bootstrap has to piggy-back on an override. After any Civ V patch, re-diff our copy against the patched base file and re-apply the append.

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

## Response Formatting

These rules govern how you write responses to me in chat, not how you write code or documentation.

- No tables. Use prose or short bullet lists. Tables render poorly in the screen reader I use and force me to navigate cell by cell for information that reads fine as a sentence.
- Minimize special characters. Avoid emdashes, smart quotes, fancy arrows, box-drawing characters, and ASCII art. Plain hyphens, straight quotes, and words for "to" / "leads to" / "maps to" are fine.
- No emoji unless I ask.
- Prefer prose over deeply nested bullets. One level of bullets is usually enough; two is the ceiling.
- Don't pad. If there are no problems, say "no issues." Don't present two options as equally valid when one is clearly better. Recommend the better one and move on.
- Don't invent concerns to appear thorough.
