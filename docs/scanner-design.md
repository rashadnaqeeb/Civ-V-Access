# Scanner — Design

The scanner answers a single question: *where on the map is this specific thing?* The hex cursor tells the player what is at a plot; the scanner tells them where something is. It is the counterpart to the cursor and expected to become a primary navigation surface.

This document is the authoritative design spec for the feature. It is standalone — a future session implementing the scanner should need nothing else to start coding.

---

## 1. Hierarchy

Four fixed levels. Each instance of data on the map lives at exactly one leaf in this tree.

1. **Category** — highest-level bucket (Cities, Enemy Units, Resources, ...).
2. **Subcategory** — partition within a category (civs / city-states, melee / ranged / naval, strategic / luxury / bonus).
3. **Item** — name-grouped bucket within a subcategory. All instances sharing the same spoken label (e.g. "Swordsman", "Iron") collapse into one item.
4. **Instance** — a single location. One `plotIndex` + whatever backend reference is needed to validate and re-describe it.

Per category, the subcategory at index 0 is the literal string `all`, which holds shared item references drawn from every named subcategory beneath it. Removing an instance from a named subcategory automatically removes it from `all` because the item object is shared, not copied.

## 2. Categories and subcategories

Seven categories. Subcategory lists below are fixed per category; the `all` entry is implicit at index 0 of each.

### Cities
- `My` — cities owned by the active player.
- `Neutral` — cities of civs and city-states the active team is at peace with.
- `Enemy` — cities of civs and city-states the active team is at war with.
- `Barbarian Camps` — not strictly cities, but the closest hostile-settlement analogue. Placed here because they occupy the same mental slot.

### My Units / Neutral Units / Enemy Units

Three sibling top-level categories. Subcategories are identical across all three, except Enemy Units adds a `Barbarians` subcategory for roaming barb combat units.

- `Melee` — `CombatClass` in `{MELEE, GUN, ARMOR, RECON}`, land domain.
- `Ranged` — `CombatClass == ARCHER`, land domain. Includes mounted archers (Chariot Archer, Keshik) — the game classifies them as Archer, not Mounted.
- `Siege` — `CombatClass == SIEGE`.
- `Mounted` — `CombatClass in {MOUNTED, HELICOPTER}`. The Helicopter Gunship is Domain=LAND with fast-attack behavior, so it belongs with mounted, not air.
- `Naval` — `Domain == SEA`. One subcategory for all naval classes (the base game uses a single `UNITCOMBAT_NAVAL`; expansions split into `NAVALMELEE`/`NAVALRANGED`/`SUBMARINE`/`CARRIER`). Using domain rather than combat class sidesteps the split.
- `Air` — `Domain == AIR`. Fighters and bombers.
- `Civilian` — `IsCombatUnit() == false` and `SpecialUnitType != SPECIALUNIT_PEOPLE`. Workers, settlers, missionaries, inquisitors, great prophets-qua-founders, caravans, cargo ships, archaeologists.
- `Great People` — `SpecialUnitType == SPECIALUNIT_PEOPLE`. Check this before Civilian (both match by no-combat).
- (Enemy Units only) `Barbarians` — `Players[owner]:IsBarbarian()`. Individual roaming barbarian combat units. Barbarian encampments live under Cities.

**Recon choice:** `UNITCOMBAT_RECON` (scout, explorer) is folded into Melee for v1. They have combat stats, function as frontline skirmishers, and splitting them out inflates the subcategory list beyond the eight slots budgeted above. Future revision can add a dedicated Recon sub if players want.

### Resources
- `Strategic` — `GameInfo.Resources[t].ResourceUsage == 1`.
- `Luxury` — `ResourceUsage == 2`.
- `Bonus` — `ResourceUsage == 0`.

Use `plot:GetResourceType(activeTeam)` to read the resource. The team-aware overload returns `-1` for plots that are unrevealed *or* whose resource is gated by a tech the team doesn't have. This one call handles both gates.

### Improvements
Owner-based, using the same three-way split as Cities.
- `My` — `plot:GetRevealedImprovementOwner(activeTeam) == activePlayer`.
- `Neutral` — owner is a civ or city-state at peace with the active team.
- `Enemy` — owner is at war with the active team.

Unowned improvements (forts in no-man's-land without a prior claim) fall under Neutral. Roads and railroads are excluded — they'd dwarf every other entry by count.

Revealed improvement type is read via `plot:GetRevealedImprovementType(activeTeam)` so the scanner shows what the player last saw even under current fog, matching the engine's own rendering.

### Special
- `Natural Wonders` — `GameInfo.Features[feature].NaturalWonder == 1`. Iterate plots, check the plot's feature.
- `Ancient Ruins` — plots whose revealed improvement is `IMPROVEMENT_GOODY_HUT`. Referenced by the engine-defined constant name (same pattern the mod already uses for well-known single entities).

**Why World Wonders are not here:** world wonders are buildings inside cities, not map objects. Finding a wonder means finding the city that has it; that lives in the city announcement, not the scanner.

**Why Terrain is not here:** intentionally dropped. Terrain features (forests, mountains, rivers, oases) were considered and cut as noise-heavy for v1.

---

## 3. Classification is flag-derived

No hardcoded lists of improvement names, resource names, or unit names. Every bucket decision above reads a column on `GameInfo` or an API flag. The engine-defined single-entity constants `IMPROVEMENT_BARBARIAN_CAMP` and `IMPROVEMENT_GOODY_HUT` are references to named singletons, not enumerations — consistent with how the mod already addresses single well-known entities.

The one non-flag choice is the `Barbarians` subcategory under Enemy Units, which exists because new players ask "where are the barbs" more often than "where's the enemy archer." It is flag-driven (`IsBarbarian()`); it is just a UX concession to surface them prominently.

---

## 4. Backends

Five backend modules, each exposing the same three-method interface. They are stateless between refreshes — they query the game fresh in `Scan` and return a flat list of `ScanEntry` tables. No clustering (the biggest Civ V maps are on the order of 10,000 plots, small enough to iterate twice per refresh without perceptible delay).

### Interface

Every backend table exports:
- `Scan(activePlayer, activeTeam) -> table of ScanEntry` — produce entries.
- `ValidateEntry(entry, cursorPlotIndex) -> bool` — is this entry still current? Called immediately before announcing an instance. Returning false drops the entry from the snapshot.
- `FormatName(entry) -> string` — spoken label for this instance, localised, text-key based.

### ScanEntry shape

```
{
    plotIndex   = number,    -- Map.GetPlotByIndex index
    backend     = <backend>, -- for dispatch to ValidateEntry / FormatName
    data        = <opaque>,  -- backend-specific payload (plot coords, unit ID, city ID, ...)
    category    = string,    -- key into ScannerTaxonomy.Categories
    subcategory = string,    -- key into ScannerTaxonomy.Subcategories
    itemName    = string,    -- spoken item label (the name collapsed across instances)
    sortKey     = number,    -- primary sort; falls through to distance on tie
}
```

### Backend list

1. **ScannerBackendCities** (`CivVAccess_ScannerBackendCities.lua`).
   - Source: iterate `Players[p]:Cities()` across all players the active team has met (`Teams[t]:IsHasMet`), plus barbarian improvement scan for camps.
   - Cities gated by `plot:IsRevealed(activeTeam)`.
   - Camps gated by `plot:GetRevealedImprovementType(activeTeam) == GameInfoTypes.IMPROVEMENT_BARBARIAN_CAMP`.
   - Item name for cities: localised city name. Capital status is part of the spoken line during announcement, not a separate subcategory.
   - Validation: city still exists and is still owned by the same player; plot still revealed.

2. **ScannerBackendUnits** (`CivVAccess_ScannerBackendUnits.lua`).
   - Source: iterate `Players[p]:Units()` across all players; partition by ownership (active player / at-peace / at-war) into the three top-level unit categories.
   - Units gated by `plot:IsVisible(activeTeam)` — the engine does not render units under fog and neither do we.
   - Role subcategory derived from `GetDomainType` and `GetUnitCombatType` per the table in section 2.
   - Item name: localised unit description (`TXT_KEY_UNIT_X`), read from `GameInfo.Units[type].Description`.
   - Validation: unit handle still valid (`unit` not nil and `IsDead` false) and current plot still visible.

3. **ScannerBackendResources** (`CivVAccess_ScannerBackendResources.lua`).
   - Source: iterate all plots. For each, `plot:GetResourceType(activeTeam)`. Skip `-1`.
   - Subcategory from `GameInfo.Resources[t].ResourceUsage`.
   - Item name: resource description text key.
   - Validation: same plot still returns the same resource type for the same team.

4. **ScannerBackendImprovements** (`CivVAccess_ScannerBackendImprovements.lua`).
   - Source: iterate all plots. `plot:GetRevealedImprovementType(activeTeam)`. Skip `NO_IMPROVEMENT`, barb camp, goody hut (handled by Cities and Special respectively), and `IMPROVEMENT_ROAD` / `IMPROVEMENT_RAILROAD`.
   - Subcategory from plot owner vs active team war state.
   - Item name: improvement description text key.
   - Validation: same plot still has an improvement of the same type for the same team; owner classification unchanged.

5. **ScannerBackendSpecial** (`CivVAccess_ScannerBackendSpecial.lua`).
   - Source: iterate all plots. Emit natural wonder entries for plots whose feature is a natural wonder and which are revealed. Emit ancient ruin entries for plots whose revealed improvement is the goody-hut constant.
   - Item name: feature description or the goody-hut text key.
   - Validation: feature or improvement still present and revealed.

Plot iteration sweeps for backends 3, 4, and 5 all scan the same `Map.GetNumPlots()` range. They run independently (each pass is cheap) rather than sharing a single pass — clarity trumps the micro-optimisation.

---

## 5. Snapshot

Built from the flat list of entries returned by all backends concatenated.

### Sort
- Instances within an item: ascending by `Map.PlotDistance` from the hex cursor.
- Items within a subcategory: by nearest-instance distance (each item's first instance after sort).
- Subcategories: fixed taxonomy order defined in `ScannerTaxonomy`, with `all` always at index 0.
- Categories: fixed taxonomy order defined in `ScannerTaxonomy`.

### Lifetime
Rebuild triggers — exactly two:
1. **Category change** (`Ctrl+PageUp/Down`). The user cycling across the top level is the signal that any freshness cost is acceptable.
2. **Turn start**, lazy. Subscribe to `Events.ActivePlayerTurnStart` and mark the snapshot stale. The next scanner keypress that needs the snapshot rebuilds. Do not rebuild eagerly on the event itself — users who aren't interacting with the scanner should not pay the cost.

No rebuild on subcategory change, item change, or instance change. That is deliberate: rebuilding on sub/item change would make the player constantly lose their place when the closest-first sort reshuffles after even tiny cursor movements.

### Between rebuilds
`ValidateEntry` is called on the current instance every time the user navigates to it. If it returns false, the entry is pruned from the snapshot and the navigator advances to the next valid instance within the same item (or wraps up the hierarchy if the item empties out). This keeps the snapshot honest about units dying, cities falling, plots going back under fog, without a full rebuild.

### Position preservation after a rebuild
After a category-change rebuild, the category index stays where the cycle left it. Subcategory / item / instance all reset to 0 — the user asked for a new category; the sub/item/instance position from the old category is meaningless.

After a turn-start rebuild, preserve the category and subcategory by name where possible (match the previous name string in the new snapshot; fall back to index 0 if the name no longer exists). Reset item and instance to 0.

---

## 6. Navigation axes and keys

Four cycle axes plus seven single-purpose keys, mapped to the `PageUp`/`PageDown` pair with modifier layers. The per-axis layering is:

- `PageUp` / `PageDown` (no modifier) — cycle **item** within the current subcategory.
- `Shift+PageUp` / `Shift+PageDown` — cycle **subcategory** within the current category.
- `Ctrl+PageUp` / `Ctrl+PageDown` — cycle **category**. Triggers a rebuild.
- `Alt+PageUp` / `Alt+PageDown` — cycle **instance** within the current item.
- `Home` — move the hex cursor to the current instance's plot (jump). Records the pre-jump cell for `Backspace`.
- `End` — speak distance and direction from the hex cursor to the current instance. The output must match the capital-finder (`S` key via `Cursor.orient`) **exactly in format**: same cube-coordinate decomposition, same six directions in the same `ORIENT_OUTPUT_ORDER`, same `<count><short-token>` per-direction construction (tokens `e`, `ne`, `se`, `sw`, `w`, `nw` from `TXT_KEY_CIVVACCESS_DIR_*`), same `, ` separator. The only two differences from the S key are (a) the origin is the hex cursor instead of the capital, so the decomposition is `entry_cube - cursor_cube`, and (b) the zero-distance short-circuit speaks `TXT_KEY_CIVVACCESS_SCANNER_HERE` instead of `TXT_KEY_CIVVACCESS_AT_CAPITAL`. There is no other divergence — both callers drive the same shared helper (section 10) and the only caller-specific code is the at-origin check and the key passed to it.
- `Ctrl+F` — open the search input handler (section 8).
- `Backspace` — restore the hex cursor to the pre-jump cell saved by the most recent scanner-driven jump, whether the jump was explicit (`Home`) or auto-move-driven (section 9). No-op if no scanner jump has happened since the last restore.

Hotkeys that override engine bindings — all deliberate, none reversible from a blind player's workflow:

- `PageUp` / `PageDown` — base game zooms the world camera. Blind players don't use zoom; losing it costs nothing.
- `Ctrl+F` — base game builds a Fort when a worker is selected on a fort-eligible plot. Contextual and mouse-first; losing it is acceptable.
- `Home` / `End` — base game cycles cities (next / previous). The scanner's Cities category with owner subs is a strict superset; losing the engine's city cycle costs nothing.
- `Backspace` — base game cancels a selected unit's action or stops automation. Both are mouse-first flows that don't fit a blind player's keyboard-driven loop.

Add entries in `docs/hotkey-reference.md` under the CivVAccess additions table for every key above, with the rationale column filled in.

---

## 7. Announcements

Every speech path routes through `SpeechPipeline`. No direct `tolk.*` calls from scanner code.

### Cycle item (most common)
Spoken on `PageUp` / `PageDown` after a successful item change:
```
<item name>. <distance/direction from cursor>. <instance index + 1> of <instance count>.
```

Example: *"Swordsman. 3e, 2se. 1 of 4."* (The direction tokens are the same short forms — `e`, `ne`, `se`, `sw`, `w`, `nw` — that `Cursor.orient` already uses.)

**About the positional count:** the mod's concise-announcement rule forbids "N of M" counts for menus because "Play button, 1 of 8" is not actionable — you already know it's Play. For scanner entities it *is* actionable: "Swordsman, 1 of 8" tells the player they have eight swordsmen and this is the closest. The count conveys real information, so the rule has an explicit carve-out here. Document this carve-out in a comment above the announcement formatter so future readers understand why this differs from menu rules.

### Cycle subcategory
Spoken on `Shift+PageUp` / `Shift+PageDown`:
```
<subcategory label>. <item announcement for the first item, as above>
```

### Cycle category
Spoken on `Ctrl+PageUp` / `Ctrl+PageDown`, after rebuild:
```
<category label>. <item announcement for the first item>
```

If the rebuild produces no entries for the new category, speak `<category label>` followed by the empty token (new mod-authored TXT_KEY).

### Cycle instance
Spoken on `Alt+PageUp` / `Alt+PageDown`, after a successful instance change:
```
<item name>. <distance/direction from cursor>. <instance index + 1> of <instance count>.
```

(Same format as cycle-item; only which axis advanced differs.)

### Home (jump, explicit)
On successful jump: speak `<cursor's new plot glance>` — the same text `Cursor.move` produces after a directional step. The user knows they teleported because they just pressed Home; re-announcing the entry name would be redundant.

### Auto-move jumps (implicit, during a cycle)
When auto-move is on and a cycle jumps the cursor as a side effect, the jump is **silent**. The cycle's own announcement (`<item name>. <distance/direction>. <n> of <m>.`) already tells the user where they are and what they're on. Speaking the plot glance on top would double the audio for every cycle keypress. This differs from explicit `Home` (which speaks the glance) on purpose: Home has no cycle announcement to cover for it.

### End (distance readout)
Speak the distance/direction string produced by the shared `HexGeom.directionString` helper (section 10), byte-identical in format to what the `S` key already speaks for the capital. Zero-distance case speaks `TXT_KEY_CIVVACCESS_SCANNER_HERE`, the scanner's analogue of `TXT_KEY_CIVVACCESS_AT_CAPITAL`.

### Empty states
If the scanner is invoked with no snapshot and the implicit rebuild produces no entries for the selected category: speak the empty token. If an item's instances have all been pruned by validation: speak the empty token. If the whole snapshot is empty (no entries across all categories): speak the empty token. One consistent token for all empty cases.

---

## 8. Search

`Ctrl+F` pushes a **ScannerInputHandler** onto the HandlerStack on top of the ScannerHandler. This handler:

- Captures printable characters, Backspace, Escape, and Enter via the InputRouter's existing `handleSearchInput` hook (the same path BaseMenu's type-ahead already uses). Each keystroke speaks the buffered query so the user hears what they've typed.
- On `Enter`: build a filtered snapshot from the full set of backend entries, using the match logic from `CivVAccess_TypeAheadSearch.lua` (prefix / word-start / substring tiers, keyed off the item name). Pop the input handler. Entries appear in a single synthetic category whose subcategories are the entries' original categories — so a search for "iron" produces one category with Strategic / My-Units / whatever subs containing the matches. Subcategory for a synthetic result is the entry's original `category` string; this aligns with the taxonomy pattern and needs no new data paths.
- On `Escape`: pop without building; the existing snapshot (if any) stays active.
- Search results persist until the next `Ctrl+PageUp` / `Ctrl+PageDown` (the category-change signal), which discards the search snapshot and rebuilds into the normal category the user cycled to. No other key clears search results.

Search does not overlap with the snapshot the normal navigation produces — during search, the navigator's snapshot is a search snapshot, replacing whatever was there. After the user cycles out, search is gone for good until the next `Ctrl+F`.

---

## 9. Auto-move-cursor toggle

The first persistent user setting in the mod. For v1: session-only.

- Stored on `civvaccess_shared.scannerAutoMove` (boolean), initialised to `false` on first read. The shared table already survives Context re-instantiation, which is the session-scope we want. Default is off because auto-move yanks the cursor off the user's working cell every cycle; users who want the behavior opt in with Shift+End.
- Toggled by `Shift+End`. On toggle, speak an on/off TXT_KEY line.
- When `true`: every successful cycle (item / subcategory / category / instance) ends by jumping the hex cursor to the current entry's plot, as if the user pressed Home. The pre-jump cell is still captured so Backspace can return.
- When `false`: cursor stays where the player left it; jumps only happen on explicit `Home`.

Persistence across sessions is explicitly out of scope for v1. When the mod grows a settings layer, that layer persists this value and reads it at boot. Until then, users re-toggle once per launch — acceptable trade against building a config subsystem now.

Add a one-line note in the plan's follow-up section of the implementation task list: *persistent settings layer, scanner auto-move toggle is the first consumer.*

---

## 10. File layout

All new files under `src/dlc/UI/InGame/`. Civ V's VFS indexes Lua files by bare stem and drops the shorter of any two stems in a prefix relationship — every stem below differs from every other at a character before any becomes a prefix, so the index stays clean.

- `CivVAccess_ScannerCore.lua` — `ScanEntry` doc, `ScannerTaxonomy` (category / subcategory ordering tables), backend interface contract. No game calls.
- `CivVAccess_HexGeom.lua` — shared cube-coord direction helper, single exported `directionString` function (see section 10 shared helper refactor). Used by both `Cursor.orient` (S key) and scanner `End`.
- `CivVAccess_ScannerNav.lua` — navigation state machine. Owns category / subcategory / item / instance indices. Entry points called from handler bindings: `cycleCategory(dir)`, `cycleSubcategory(dir)`, `cycleItem(dir)`, `cycleInstance(dir)`, `jumpToEntry()`, `distanceFromCursor()`, `toggleAutoMove()`, `returnToPreJump()`. Subscribes to `Events.ActivePlayerTurnStart` for lazy invalidation.
- `CivVAccess_ScannerSnap.lua` — snapshot building from a flat entry list, pruning.
- `CivVAccess_ScannerSearch.lua` — filter existing entry list through the type-ahead matcher, produce a synthetic snapshot.
- `CivVAccess_ScannerHandler.lua` — handler table pushed on top of Baseline. Bindings for `PageUp/Down` with all four modifier layers, `Home`, `End`, `Shift+End`, `Ctrl+F`, `Backspace`. Help entries for the ? overlay.
- `CivVAccess_ScannerInput.lua` — the Ctrl+F text-capture handler. The `InputRouter` routes every `WM_KEYDOWN` through the top handler's `handleSearchInput` method if present, so this handler implements that one method and handles printable characters, Backspace, Enter, and Escape inside it. No separate `bindings` table needed; `capturesAllInput = true` blocks anything not consumed by the hook from falling through.
- `CivVAccess_ScannerBackendCities.lua`
- `CivVAccess_ScannerBackendUnits.lua`
- `CivVAccess_ScannerBackendResources.lua`
- `CivVAccess_ScannerBackendImprovements.lua`
- `CivVAccess_ScannerBackendSpecial.lua`
- `CivVAccess_ScannerStrings_en_US.lua` — mod-authored TXT_KEYs for what the game doesn't provide.

### Bootstrap and manifest updates

- `src/dlc/UI/InGame/CivVAccess_Boot.lua`: add `include` lines for each scanner file. Include order is not strictly ordered at load time — every scanner module defines globals that other scanner modules only touch at call time through closures, so any order Boot already uses is fine. The Strings file should be included before any module whose load-time code calls `Text.key` on a scanner key (none of the modules above do so at load time). Push the ScannerHandler onto the HandlerStack in `onInGameBoot` after the Baseline push.
- All three manifest files (`CivVAccess_0/1/2.Civ5Pkg`): add entries for each new Lua file under the appropriate `<GameData>` / `<LuaFile>` section. Strings file is per-Context but only needed in-game here.

### Shared helper refactor

The cube-coord direction composition in `CivVAccess_Cursor.lua` (`offsetToCube`, `decomposeCube`, `ORIENT_OUTPUT_ORDER`, and the per-direction assembly loop in `Cursor.orient`) must be shared with the scanner so both callers produce byte-identical distance strings. Extract these into a dedicated geometry helper `CivVAccess_HexGeom.lua` with a single exported function along the lines of:

```
HexGeom.directionString(fromX, fromY, toX, toY) -> string
```

The function converts both endpoints to cube coords, computes `to - from`, decomposes the delta into the six-direction counts via the existing `decomposeCube`, walks `ORIENT_OUTPUT_ORDER`, concatenates `<n><short-token>` with `, ` separators, and returns the result. Returns an empty string when the endpoints are identical — callers handle the zero-distance short-circuit themselves so each can supply its own "at origin" TXT_KEY.

Both callers then become thin wrappers:

- `Cursor.orient` — if cursor is on the capital plot, return `TXT_KEY_CIVVACCESS_AT_CAPITAL`; otherwise call `HexGeom.directionString(capX, capY, cursorX, cursorY)`.
- Scanner `End` — if cursor is on the entry plot, return `TXT_KEY_CIVVACCESS_SCANNER_HERE`; otherwise call `HexGeom.directionString(cursorX, cursorY, entryX, entryY)`.

Nothing else about the format differs between the two. A future change to the direction format — switching `, ` to ` `, spelling out "east" instead of `e`, adding a total-distance prefix — lands in one file and applies to both callers automatically.

---

## 11. Text keys

### Reuse game-provided keys verbatim

The mod rule is "reuse the game's localised text." These keys already exist in the shipped game XML and produce exactly the labels the scanner wants:

- `TXT_KEY_CITIES_HEADING1_TITLE` → Cities
- `TXT_KEY_UNITS_HEADING1_TITLE` → Units (stem for My/Neutral/Enemy if we prefix with mod-authored owner label)
- `TXT_KEY_MAP_OPTION_RESOURCES` → Resources
- `TXT_KEY_RESOURCES_STRATEGIC_HEADING2_TITLE` → Strategic Resources
- `TXT_KEY_RESOURCES_LUXURY_HEADING2_TITLE` → Luxury Resources
- `TXT_KEY_RESOURCES_BONUS_HEADING2_TITLE` → Bonus Resources
- `TXT_KEY_ADVISOR_RANGED_UNIT_DISPLAY` → Ranged Units
- `TXT_KEY_ADVISOR_SIEGE_UNIT_DISPLAY` → Siege Units
- `TXT_KEY_ADVISOR_COMBAT_NAVAL_UNIT_DISPLAY` → Naval Units
- `TXT_KEY_UNITS_AIR_HEADING3_TITLE` → Air Units
- `TXT_KEY_ADVISOR_GREAT_PERSON_DISPLAY` → Great People
- `TXT_KEY_ADVISOR_DISCOVERED_NATURAL_WONDER_DISPLAY` → Natural Wonders
- `TXT_KEY_IMPROVEMENT_GOODY_HUT` → Ancient Ruins
- `TXT_KEY_ADVISOR_BARBARIAN_CAMP_DISPLAY` → Barbarian Camp (singular is acceptable for the subcategory label)

Using game keys means the user hears "Ranged Units" rather than the more concise "Ranged." That is intentional: CLAUDE.md is explicit that game text must not be reworded, and the concise-announcement rule applies to mod-authored strings only. Consistency with game phrasing outweighs terseness here.

### Mint mod-authored keys

Add to `CivVAccess_ScannerStrings_en_US.lua`. All keys prefixed `TXT_KEY_CIVVACCESS_SCANNER_`:

- `CATEGORY_CITIES_MY`, `CATEGORY_CITIES_NEUTRAL`, `CATEGORY_CITIES_ENEMY`, `CATEGORY_CITIES_BARB_CAMPS` — ownership-prefixed city category labels.
- `CATEGORY_UNITS_MY`, `CATEGORY_UNITS_NEUTRAL`, `CATEGORY_UNITS_ENEMY` — the three top-level unit categories.
- `CATEGORY_IMPROVEMENTS`, `CATEGORY_SPECIAL` — where no clean game key exists for the full category name.
- `SUB_MELEE`, `SUB_MOUNTED`, `SUB_CIVILIAN`, `SUB_BARBARIANS`, `SUB_MY`, `SUB_NEUTRAL`, `SUB_ENEMY` — subcategories without a clean game key. (Ranged / Siege / Naval / Air / Great People / Strategic / Luxury / Bonus / Natural Wonders / Ancient Ruins use game keys above.)
- `INSTANCE_COUNT` — `Text.format` template for the "N of M" tail of a cycle announcement. Placeholders for current index and total, so localisation can reorder them.
- `HERE` — zero-distance response to `End`.
- `EMPTY` — empty-snapshot / empty-item response.
- `SEARCH_PROMPT` — speech when `Ctrl+F` activates the input handler.
- `SEARCH_NO_MATCH` — speech when `Enter` commits a query that matched nothing.
- `AUTO_MOVE_ON`, `AUTO_MOVE_OFF` — toggle feedback.
- `JUMP_NO_RETURN` — speech when `Backspace` is pressed but no scanner jump has been recorded.

Every mod-authored lookup goes through `Text.key` / `Text.format`, never through `Locale.ConvertTextKey` directly, per existing project convention.

---

## 12. Handler wiring

ScannerHandler sits on the HandlerStack directly above the Baseline cursor handler, at a stack position of 2 when nothing modal is open. It sets `capturesAllInput = false`, so any key it doesn't bind falls through to Baseline — cursor movement (`Q/E/A/D/Z/C`), `S`, `W`, `X` all continue to work unchanged while the scanner is active.

Popups and overlays pushed on top (which do set `capturesAllInput = true`) pre-empt both Baseline and Scanner without either needing coordination. When the popup closes and pops, Scanner becomes active again automatically.

ScannerInput, when open for `Ctrl+F` text capture, pushes on top of Scanner. It sets `capturesAllInput = true` so stray keys while typing a query don't fire scanner bindings. On `Enter` / `Escape` it pops itself.

`CivVAccess_Boot.lua` installs both handlers: first the existing Baseline push, then a ScannerHandler push. `HandlerStack.removeByName("Scanner")` before the push for the same reason Baseline does — Context re-entry must not stack duplicates.

---

## 13. Testing

Tests live under `tests/`, run by `test.ps1` against `third_party/lua51/lua5.1.exe`. Engine globals used by tested modules get polyfilled in `CivVAccess_Polyfill.lua`; never introduce test-only mocks.

### Suites to add

- `tests/test_scanner_taxonomy.lua` — sort order invariants for categories and subcategories.
- `tests/test_scanner_classification.lua` — the per-backend flag-to-bucket decisions: unit role buckets given fixtures for each `UNITCOMBAT_*`, resource usage integer to subcategory, improvement owner to subcategory, feature-is-natural-wonder flag, goody-hut improvement constant. This is the place where a silent misbucket would otherwise slip past other suites.
- `tests/test_scanner_snapshot.lua` — snapshot construction, sort, `all` subcategory shares item refs, prune-when-item-empty drops subcategories cleanly.
- `tests/test_scanner_search_filter.lua` — query against a synthetic entry list produces the expected subset with the expected tier ordering (piggy-backs on existing TypeAheadSearch tier semantics).
- `tests/test_scanner_navigation.lua` — cycle indices wrap correctly, category change triggers rebuild, turn-start event invalidates, validation pruning advances through empty items correctly without infinite-looping on an all-invalid list.
- `tests/test_scanner_announcement.lua` — formatter produces the documented "name, distance, N of M" shape; empty / here tokens fire in the right cases.

### Polyfill extensions

New globals that need polyfilling for tests to run modules without a live game:
- `Map.GetPlotByIndex`, `Map.GetNumPlots`, `Map.PlotDistance`.
- `Players[]:Cities`, `Players[]:Units`, `Players[]:IsBarbarian`, `Players[]:GetCapitalCity`.
- `Teams[]:IsHasMet`, `Teams[]:IsAtWar`.
- `plot:IsVisible`, `plot:IsRevealed`, `plot:GetOwner`, `plot:GetResourceType`, `plot:GetRevealedImprovementType`, `plot:GetRevealedImprovementOwner`, `plot:GetFeatureType`, `plot:GetX`, `plot:GetY`.
- `unit:GetPlot`, `unit:GetDomainType`, `unit:GetUnitCombatType`, `unit:GetSpecialUnitType`, `unit:IsCombatUnit`, `unit:GetUnitType`, `unit:GetOwner`, `unit:IsDead`.
- `city:Plot`, `city:GetOwner`, `city:GetNameKey`, `city:IsCapital`.
- `Events.ActivePlayerTurnStart.Add` (already commonly stubbed; verify).
- `GameInfo.Units`, `GameInfo.Resources`, `GameInfo.Features`, `GameInfo.Improvements`, `GameInfo.SpecialUnits` — table shape that tests can populate.
- `DomainTypes.DOMAIN_LAND/SEA/AIR`, `GameInfoTypes.IMPROVEMENT_BARBARIAN_CAMP`, `GameInfoTypes.IMPROVEMENT_GOODY_HUT`.

Grow the polyfill as suites need these; do not introduce a test-only alternate path in production modules.

---

## 14. Build order

A rough sequence for implementation. Each step should be landable on its own.

1. **Foundation.** ScannerCore (taxonomy, entry shape, interface). Extract the cube-coord direction math from `CivVAccess_Cursor.lua` into `CivVAccess_HexGeom.lua` and rewrite `Cursor.orient` to call through the shared helper. Verify the S key speaks byte-identical output before and after the refactor (the cursor tests should catch any drift). No user-visible behaviour change yet.
2. **Snapshot + nav + empty backends.** Snap, Nav, Handler, Input wired with stub backends returning empty lists. Scanner cycles produce "empty" announcements. No entries yet but all key bindings function end-to-end.
3. **Cities backend.** First real backend, first announcements of real data. Validates the shape end-to-end.
4. **Units backend.** Three top-level categories all populated at once.
5. **Resources backend.**
6. **Improvements backend.**
7. **Special backend.** Natural wonders and ancient ruins.
8. **Search.** Ctrl+F flow, ScannerInput handler, filtered snapshot.
9. **Auto-move toggle.** Shift+End, session-persisted on `civvaccess_shared`.
10. **Hotkey doc update.** Add all scanner bindings to `docs/hotkey-reference.md` with rationale.

---

## 15. Open items for future iterations

- Persistent settings layer. Auto-move toggle is the first consumer; a second consumer (whatever it is) justifies building it.
- Recon subcategory under Units, if folding into Melee turns out to annoy players who use scouts heavily.
- Terrain category. Dropped from v1 as noise-heavy; may deserve revisiting once players live with the current set.
- Rivers. Plot-edge rather than plot-contained, needs a different model to enumerate; out of v1 scope.
- Direction earcons for spatial audio. Useful but requires an audio system the mod doesn't yet have.
- Trade routes, great works, religion markers. Each is a whole category's worth of work; revisit post-v1.
