# llm-docs

Reference material extracted from the local Civ V install (game Lua, XML, SDK) and from community sources, intended to be loaded on demand by future sessions. Nothing here is hand-authored design — these are derived references. When the underlying game files change (patch, DLC, mod activation in the wrong slot), regenerate rather than edit.

## What's here

### Lua API surface — `lua-api/`
Per-class markdown of every method called on each engine class, extracted by scanning the entire shipped game Lua and binning calls by receiver name (`pPlayer:` to Player, `pUnit:` to Unit, etc.). At last extraction: 23 classes, ~1,900 distinct methods, ~54k classified call sites (per-class totals in `lua-api/README.md`). Signatures are real argument expressions from real call sites — argument names reflect what the game's own authors wrote.

Start at `lua-api/README.md` for the class index. Open the specific class file when you need a method (e.g. `lua-api/Player.md`). Each entry shows the method, its argument shape(s) (up to 5 distinct shapes shown), call site count, and one example `file:line` you can read for usage context.

Two classes are populated by method-name fingerprinting rather than receiver-name binning, since their call sites use too many different receiver names to enumerate:
- `Controls` — Control userdata methods (`SetHide`, `SetText`, `RegisterCallback`, etc.). The method set was learned from every `Controls.<X>:<Method>` call; calls on other receivers (`button`, `iconControl`, `instance.SubFoo`) using the same method names were folded into Controls.
- `InstanceManager` — the small fixed set (`new`, `GetInstance`, `ResetInstances`, `ReleaseInstance`) defined in `Assets/UI/InstanceManager.lua`. That file is short (~150 lines); read it directly for the constructor's contract.

`lua-api/_unbinned.md` is the top-100 leftover `:Method(` calls — mostly mod-side map generators (`MultilayeredFractal`, `AssignStartingPlots`, `start_plot_database`) and a long tail of typed handles whose receiver names weren't in the binning map. Useful for spotting genuine misses; the map-generator stuff is not engine API.

`lua-api/_extract.py` is the extractor itself. Re-run it (`py _extract.py` from `llm-docs/lua-api/`) when the shipped game Lua changes or when you extend the receiver map.

`lua-api/_civvaccess_fork.md` lists the Lua bindings and `GameEvents.CivVAccess*` hooks our engine fork adds (Unit, Plot, Game bindings plus the CivVAccess* GameEvents). The extractor scans shipped game Lua and our fork's bindings have no game-side callers, so they never show up in the per-class files. Hand-authored; canonical source is the `CIVVACCESS:` markers in `src/engine/`. Grep that marker if you suspect the doc has drifted from the engine.

### Events catalogs — `events-catalog.md` and `luaevents-catalog.md`
- `events-catalog.md` — 227 `Events.X` (engine-originated) at last extraction. Each entry tagged with **direction** (observable / fire-only / mixed) so you can triage at a glance: 147 observable, 54 fire-only, 26 mixed. Includes the 69-way `SerialEventGameMessagePopup` `ButtonPopupTypes` enumeration up front. Also lists inferred argument shape, example registration site, example fire site, and counts.
- `luaevents-catalog.md` — 25 `LuaEvents.X` (pure Lua pub/sub between scripts). Verified complete by independent grep — Civ V's UI relies on `Events.X` and direct globals far more than on Lua-to-Lua pub/sub, so the small count is real.

These are the primary discovery surface for "what can I observe without modifying game files." Filter to **observable** in events-catalog when looking for things to subscribe to.

### Screen inventory — `screen-inventory.md`
Map of every UI screen in `Assets/UI/` (base + G&K + BNW DLC dirs). 168 unique XML stems across all editions; the inventory has 162 screen entries plus 11 support/include entries (the gap is alt-layout XMLs like `*_small` and `CityStateGreetingPopupOpenCenter` that share Lua with their parent screen and are noted inline). Grouped by area: FrontEnd, InGame HUD, City screen, Diplomacy, Tech tree, Civilopedia, Popups, Options, Debug. For each screen: file path, one-line purpose, override status across editions, top-level interactive controls.

Use this when you need to find "where does X live" — it points you at the right `.lua`/`.xml` pair to read. Screen identity for `ContextPtr` lookup is the filename stem; XML root `ID=` attributes are unreliable and were stripped from the inventory.

### UI text key index — `txt-keys/ui-text-keys.md`
Extracted index of UI-label `TXT_KEY_*` entries from every shipped `en_US` text XML (base + Expansion + Expansion2 + DLC). ~5,000 keys filtered to UI chrome (buttons, menus, popups, tooltips, panel labels, advisor copy) — content-data labels (unit/building/civ/ability names) are intentionally excluded; read those from `GameInfo` directly. Each entry shows the key, the English text, and the source XML(s).

Use this before adding any mod-authored string. The project rule is "search the game's text XML before authoring," and this index is the searchable form of that — Ctrl-F a likely label ("Close", "Cancel", "End Turn") and grab the existing key. The text-key namespace is global, so any key here can be looked up via `Locale.ConvertTextKey` from any mod context.

`txt-keys/_extract.py` is the extractor. Re-run (`py _extract.py` from `llm-docs/txt-keys/`) when DLC changes or the include/exclude heuristics need tuning.

### External resources — `external-resources.md`
URLs for community references that supplement the local files: Civfanatics modiki, Whoward's BNW Lua reference (parsed from DLL C++, more authoritative than the SDK HTML stub), Vox Populi / EUI / IGE source repos.

## What's NOT here, and why

- **Game mechanics reference** (combat formulas, yield math, tech tree, policy effects). Not built — Claude's training data covers Civ V mechanics adequately, and the accessibility mod doesn't compute strategy. When mechanics matter, read the relevant `Assets/Gameplay/XML/` data file directly.
- **Hotkey reference.** Lives at `docs/hotkey-reference.md` — already comprehensive.
- **Game source.** Don't copy or summarize. Read it in place at `C:\Program Files (x86)\Steam\steamapps\common\Sid Meier's Civilization V\Assets\` when you need it.
- **SDK Lua API HTML.** It's an unfinished stub (method names only, no signatures). The grep-based `lua-api/` here supersedes it.

## When to regenerate

The grep-based extraction depends on the shipped game files. Regenerate when:
- A Civ V patch changes shipped Lua (rare — game has been stable for years).
- We add or remove DLC and want extraction scoped to the active set.
- The unbinned report reveals receiver classes worth promoting (edit the receiver map in `lua-api/_extract.py` and rerun).

The events / screen / external docs are not auto-regenerated; edit by hand if specific entries drift.
