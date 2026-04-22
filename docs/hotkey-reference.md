# Civ V Hotkey Reference

Engine-defined keyboard bindings in Sid Meier's Civilization V, extracted from the game's action XML under `Assets/Gameplay/XML/` (base game) and `Assets/DLC/Expansion/` + `Assets/DLC/Expansion2/` (Gods & Kings, Brave New World). Purpose: know what the engine already owns, so every hotkey we reassign in the accessibility mod is a conscious choice.

Authoritative source: the XML files listed at the bottom. Where the [fandom wiki's Control bindings page](https://civilization.fandom.com/wiki/Control_bindings_(Civ5)) disagrees with the XML, the XML wins. A few wiki claims describe keys that do not appear in any XML file and are probably hardcoded in the engine; those are flagged as "wiki, unverified" and should be confirmed at runtime before we assume anything.

Scope notes:
- Defaults only. The Options menu rebinds most of these at runtime — do not assume the user is on defaults in shipped builds; read the current binding where possible.
- Context-sensitive entries (unit missions, interface modes, worker builds) only fire when the relevant unit or screen is active. Key reuse across contexts is normal (e.g. `F` means Wake / Sleep / Fortify / Garrison / Fishing Boats / Fort depending on state).

---

## Global controls (`CIV5Controls.xml`)

### Unit selection & camera
| Key | Action | Notes |
|---|---|---|
| `C` / `Numpad 5` | Center on selected unit | |
| `Ctrl+C` / `Ctrl+Numpad 5` | Select units of same type on plot | |
| `Alt+C` / `Alt+Numpad 5` | Select all units of same type | |
| `Insert` | Select / cycle city | Conflicts with screen-reader modifier keys — see §Screen reader conflicts |
| `Ctrl+F10` | Select capital city | |
| `Home` / `Numpad +` | Next city | |
| `End` / `Numpad -` | Previous city | |
| `Ctrl+.` / `Numpad *` | Next unit needing orders | |
| `Ctrl+,` / `Numpad /` | Previous unit needing orders | |
| `W` / `Numpad Enter` | Cycle units on current plot | |
| `.` / `Numpad 5` | Alternate cycle units | |
| `,` | Reselect last active unit | |
| `/` | Cycle workers | |

Wiki additionally claims `Page Up` / `Page Down` and `+` / `-` zoom the camera and `G` toggles the hex grid. None appear in any XML — likely hardcoded. Verify at runtime before relying on them being available or unavailable.

### Turn & automation
| Key | Action |
|---|---|
| `Return` / `Numpad Enter` | End turn |
| `Ctrl+Space` | End turn (alternate) |
| `Shift+Return` / `Shift+Numpad Enter` | Force end turn |
| `Ctrl+A` | Toggle unit automation (`CONTROL_AUTOMOVES`) |

### Display overlays
| Key | Action |
|---|---|
| `Y` | Toggle yield icons |
| `Ctrl+R` | Toggle all resource icons |
| `Alt+U` | Toggle unit icons |
| `F10` | Toggle strategic view |

### Advisor / info screens
| Key | Action |
|---|---|
| `F1` | Civilopedia |
| `F2` | Domestic (Economic) Advisor |
| `F3` | Military Advisor |
| `F4` | Foreign (Diplomacy) Advisor |
| `F5` | Social Policies |
| `F6` | Tech tree |
| `F7` | Turn / event log |
| `F8` | Victory progress |
| `F9` | Info screen (demographics / top cities) |

### Game management
| Key | Action |
|---|---|
| `Ctrl+S` | Save game |
| `Ctrl+Alt+S` | Save unit group (Hall of Fame) |
| `F11` | Quick save |
| `Ctrl+F11` | Quick load |
| `Ctrl+L` | Load game |
| `Ctrl+O` | Options menu |
| `Alt+Q` | Retire from game |
| `Ctrl+H` | Select healthy units |
| `V` | Advisor counsel |
| `Escape` | In-game menu / cancel current UI |

---

## Unit commands (`CIV5Commands.xml`)

| Key | Action |
|---|---|
| `U` | Upgrade unit |
| `F` | Wake sleeping unit |
| `Backspace` | Cancel current action (`COMMAND_CANCEL`) |
| `Backspace` | Stop automation (`COMMAND_STOP_AUTOMATION` — same key, different command, engine picks by unit state) |
| `Shift+Backspace` | Cancel all queued actions |
| `Delete` | Delete unit |

---

## Unit missions (`CIV5Missions.xml`)

Fires only when the selected unit supports the mission. Many keys are reused across missions — the engine picks the mission matching the current unit's state.

| Key | Mission(s) |
|---|---|
| `Space` / `Numpad 0` | Skip turn (unit) |
| `F` / `Numpad .` | Sleep / Fortify / Garrison (context-dependent) |
| `A` | Alert (wait for enemy in sight) |
| `H` | Heal / rest |
| `E` | Embark onto water |
| `D` | Disembark |
| `S` | Set up for ranged attack / Air sweep |
| `B` | Ranged attack / Found city |
| `Shift+P` | Pillage |
| `I` | Air intercept patrol |
| `R` | Rebase air unit |
| `K` | Unit death animation (debug) |

---

## Unit automation (`CIV5Automates.xml`)

| Key | Action |
|---|---|
| `A` | Automate worker build |
| `E` | Automate explore |

---

## Worker builds (`CIV5Builds.xml` + DLC)

Only active when a worker (or worker-equivalent Great Person) is selected and the selected plot supports the build. Many keys overlap with missions and with each other — the engine disambiguates by unit type and plot state.

### Base game workers
| Key | Build |
|---|---|
| `R` | Road |
| `Alt+R` | Railroad |
| `Ctrl+Alt+R` | Remove route |
| `I` | Farm |
| `N` | Mine |
| `T` | Trading post |
| `L` | Lumber mill |
| `P` | Pasture |
| `P` | Plantation |
| `H` | Camp |
| `Q` | Quarry |
| `O` | Well |
| `O` | Offshore platform |
| `F` | Fishing boats |
| `Ctrl+F` | Fort |
| `Alt+C` | Remove jungle / forest / marsh (three builds, same key) |
| `S` | Scrub fallout |
| `Ctrl+P` | Repair improvement |

### Great Person constructions
| Key | Build | Great Person |
|---|---|---|
| `A` | Academy | Great Scientist |
| `H` | Customs House | Great Merchant |
| `M` | Manufactory | Great Engineer |
| `Ctrl+C` | Citadel | Great General |
| `L` | Landmark | Great Artist |
| `L` | Holy Site (G&K / BNW) | Great Prophet |

### BNW unique-improvement workers
| Key | Build | Civilization |
|---|---|---|
| `Ctrl+A` | Archaeology dig | any (Archaeologist) |
| `B` | Brazilwood camp | Brazil |
| `K` | Kasbah | Morocco |
| `Z` | Feitoria | Portugal |
| `Z` | Chateau | France |
| `F` | Fishing boats (no kill) | various |
| `E` | Polder (G&K) | Netherlands |

---

## Interface modes (`CIV5InterfaceModes.xml`)

Modal cursor states — the next click on the map is interpreted as the mode's target.

| Key | Mode |
|---|---|
| `M` | Move to tile |
| `Ctrl+M` | Move (same-type units on plot) |
| `Alt+M` | Move (all units on plot) |
| `Ctrl+A` | Attack |
| `B` | Ranged attack (unit) |
| `B` | City ranged attack (same key, distinct mode) |
| `S` | Air strike |
| `Alt+S` | Air sweep |
| `Ctrl+Shift+R` | Establish trade / supply route |
| `Shift+A` | Airlift |
| `N` | Nuclear strike |
| `P` | Paradrop |
| `Alt+R` | Rebase air unit |
| `K` | Embark / disembark |

G&K and BNW ship empty `CIV5InterfaceModes_Expansion*.xml` files (no new mode bindings).

---

## Expansion additions (Controls)

Both G&K and BNW redefine `CIV5Controls.xml` with the same contents plus these two entries. Neither key is "BNW-only" or "G&K-only" — both expansions define both.

| Key | Action | Added in |
|---|---|---|
| `Ctrl+E` | Espionage Overview | G&K (kept in BNW) |
| `Ctrl+P` | Religion Overview | G&K (kept in BNW) |

Note that `Ctrl+P` here collides with `BUILD_REPAIR` in `CIV5Builds.xml`. The engine disambiguates by context (worker selected and standing on damaged improvement vs. anywhere else).

---

## CivVAccess additions

Hotkeys this mod binds on top of the engine defaults. Each must be a conscious choice: audit against the tables above before adding, and record the rationale here.

### Baseline "capture by default" on the map

The in-game Baseline handler (`src/dlc/UI/InGame/CivVAccess_BaselineHandler.lua`) sits at the bottom of the HandlerStack with `capturesAllInput = true`. Every keypress that isn't explicitly bound by Baseline or a handler stacked above it is swallowed before the engine sees it, because the engine's map-layer input dispatcher is one surface — the same keydown reaches unit commands, missions, worker builds, automates, interface modes, and the global controls (end turn, advisor screens, camera) depending on selection state. A handler that sat above only the subset we care about would still let the rest leak, so Baseline takes the floor and the mod re-exposes what the user needs.

`passthroughKeys` carves out the minimum the engine still gets to handle from the map: `F1`-`F12` (advisor screens, strategic view, quick save/load, Ctrl+F10 select-capital, Ctrl+F11 quick-load all live on F-row keycodes) and `Escape` (pause menu, which our GameMenuAccess layers over). Popups stacked above Baseline set their own `capturesAllInput` with no passthrough list, so even F-keys and Escape correctly stop at the dialog instead of reaching the map underneath.

Practical consequence: every entry in the earlier tables — whether a `CIV5Controls.xml` global, a `CIV5Commands.xml` unit command (Wake, Upgrade, Cancel, Delete), a `CIV5Missions.xml` action (Sleep / Fortify / Garrison, Alert, Heal, Embark / Disembark, Set up, Ranged attack, Pillage, Air intercept, Rebase, Skip turn), a `CIV5Automates.xml` toggle, a `CIV5Builds.xml` worker / Great Person build, or a `CIV5InterfaceModes.xml` modal cursor — is suppressed on the map unless a row below re-exposes it. When an entry below says "replaces engine X", the replacement is unconditional: the engine X doesn't leak through on a different selection state or a different modifier because the whole map-input channel is gated by Baseline. The same key can still mean something different inside a non-Baseline context (picker screens, menus, the scanner handler above Baseline), which is why each row names the context it applies to.

| Key | Context | Action | Rationale |
|---|---|---|---|
| `Ctrl+Up` / `Ctrl+Down` | Accessible Civilopedia, reader tab | Move to the previous / next article in the picker's flat display order (no wrap) | No engine binding on either combo (confirmed against all Controls / Commands / Missions / Automates / Builds / InterfaceModes XML). Lets the user flip through articles without round-tripping back to the picker. |
| `Alt+Left` / `Alt+Right` | Accessible Civilopedia, reader tab | Step back / forward through the base pedia's article-history list (browser-style). Speaks "Start of history." / "End of history." at the boundary. | No engine binding on either combo. Our picker-Enter, follow-link, and Ctrl+Up/Down all drive base `SelectArticle` with addToList=1, so history populates for free; Alt+Left/Right just replays it via the pedia's native history cursor. Scoped to the reader tab only so the picker's tree browsing isn't confused by back/forward semantics that don't apply there. |
| `F2` | Multiplayer Staging Room | Toggle the accessible chat panel (Messages + Compose tabs) | Engine binds `F2` to Domestic Advisor in-game only; no front-end screen claims it and StagingRoom's own InputHandler doesn't either. Chat is essential to MP coordination but the engine's chat UI is visual scrolling only, so a dedicated panel with history + compose mode is the minimum viable access path. Panel auto-closes on screen hide. |
| `Q` / `E` / `A` / `D` / `Z` / `C` | Baseline in-game | Move the screen-reader hex cursor by one tile (Q nw, E ne, A w, D e, Z sw, C se) | Replaces engine bindings on `Q` (Quarry build, only fires for selected workers on quarry-eligible plots), `E` (Embark mission, Automate explore, Polder build), `A` (Alert mission, Automate worker), `D` (Disembark mission), `Z` (Feitoria/Chateau BNW build), `C` (Center on selected unit). Cursor cluster is the primary navigation surface for blind play; mouse-based unit issuance the engine bindings supported isn't usable without sight, so losing those is acceptable. The HandlerStack pre-empts the engine before it sees the keypress. |
| `S` | Baseline in-game | Speak the top unit on the cursor tile (military unit first, civilian fallback) | Replaces `Set up for ranged attack`, `Air strike`, `Scrub fallout` -- all unit/worker missions that fire only when a relevant unit is selected. Reading the cursor tile's occupant is the single most-pressed query during navigation, so it takes the modifier-free slot; the previous plain-S binding (orient to capital) moves to Shift+S. |
| `Shift+S` | Baseline in-game | Speak distance and direction from the cursor to the player's capital | No engine binding on Shift+S. Inherits the orient-to-capital announcement that plain S used to own; kept one modifier away so the cursor-key vocabulary stays intact. |
| `1` | Baseline in-game | Speak the cursor city's identity and combat info (name, status flags, population, defense, HP, garrison) | No engine binding on the top-row digit keys (confirmed absent from all Controls / Commands / Missions / Automates / Builds / InterfaceModes XML). City readouts mirror the BNW CityBannerManager tiers; three keys (1/2/3) split the banner's information load so each press stays short. |
| `2` | Baseline in-game | Speak the cursor city's production and growth (current build, progress, per-turn rates, food status) | No engine binding. Team-only readout -- non-team cities speak "not visible" rather than leaking internal numbers. |
| `3` | Baseline in-game | Speak the cursor city's politics (warmonger / liberation previews when at war, religion, our spies / diplomats in the city) | No engine binding. Warmonger and liberation previews reuse the engine's own preview strings so the player hears the same consequences a sighted player would see. |
| `W` | Baseline in-game | Speak economy details (yields, fresh water, trade route, working city, build progress) | Replaces `Cycle units on current plot`, which is mouse-driven anyway and not useful without unit-flag visuals. |
| `X` | Baseline in-game | Speak combat details (zone of control, defense modifier) | `X` is among the only two truly unbound letters in the engine (per the unbound-keys list below); no engine action lost. |
| `Shift+W` / `Shift+X` | Baseline in-game (surveyor) | Grow / shrink the surveyor radius (clamped 1 to 5) | No engine binding on either combo. Shift+W and Shift+X join the surveyor's Shift-letter cluster; radius announcements append "min" / "max" when clamped. |
| `Shift+Q` | Baseline in-game (surveyor) | Speak summed non-zero yields across plots within the radius | No engine binding on `Shift+Q` (engine's Alt+Q is Retire from game). Reuses the cursor's yield ordering so per-tile and per-radius speech cadences match. |
| `Shift+A` | Baseline in-game (surveyor) | Speak count-sorted resource buckets within the radius | Replaces `Airlift` interface mode, which only fires for a selected unit that can airlift. Loses nothing for keyboard-only play since airlift targets are selected with the mouse anyway. |
| `Shift+Z` | Baseline in-game (surveyor) | Speak count-sorted terrain and feature tokens within the radius | No engine binding on `Shift+Z` (engine's plain `Z` is the BNW Feitoria / Chateau worker build, which fires only for a selected worker). Survey output reuses the plot terrainShape rules so single-terrain features suppress terrain and natural wonders stand alone. |
| `Shift+E` | Baseline in-game (surveyor) | List own units in the radius, ordered by cube distance then CW-from-E direction | No engine binding on `Shift+E`. Own-unit listing is the surveyor's primary "where are my forces" axis. |
| `Shift+D` | Baseline in-game (surveyor) | List visible enemy units in the radius, prefixed by civ adjective | No engine binding on `Shift+D`. Mirrors `Shift+E` with the hostile-team filter and the invisible-unit / fogged-plot gates from the scanner's units backend. |
| `Shift+C` | Baseline in-game (surveyor) | List cities in the radius, closest first, as `<city-name> <direction>` per instance | No engine binding on `Shift+C` (engine's `Ctrl+C` is Select-of-type / Citadel; `Alt+C` is Select-all / Remove-jungle). Cube-distance ordering puts the nearest city first, which is what a player asking "what cities are near me" actually wants to hear. |
| `Page Up` / `Page Down` | Scanner in-game | Cycle to the previous / next item within the current subcategory | Replaces the engine's world-camera zoom (wiki claim, not in XML — probably engine-hardcoded). Blind players do not use zoom; losing it costs nothing. Scanner's item cycle is its single most-pressed axis and the plain keys are the right affordance for it. |
| `Shift+Page Up` / `Shift+Page Down` | Scanner in-game | Cycle to the previous / next subcategory within the current category | No engine binding on the Shift variant. Layers on top of the item cycle so the modifier ladder reads naturally (no mod → item, Shift → sub, Ctrl → category, Alt → instance). |
| `Ctrl+Page Up` / `Ctrl+Page Down` | Scanner in-game | Cycle to the previous / next category; triggers a full snapshot rebuild | No engine binding on the Ctrl variant. Category change is the designated rebuild signal — every other cycle preserves the snapshot to keep the user's place. |
| `Alt+Page Up` / `Alt+Page Down` | Scanner in-game | Cycle to the previous / next instance within the current item | No engine binding on the Alt variant. Instance is the innermost axis of the four-level hierarchy. |
| `Home` | Scanner in-game | Jump the hex cursor to the current scanner entry's plot; remembers the pre-jump cell for Backspace | Replaces `Next city`. The scanner's Cities category with owner subcategories is a strict superset of the engine's city cycle; losing it costs nothing. |
| `End` | Scanner in-game | Speak distance and direction from the hex cursor to the current scanner entry | Replaces `Previous city`, same rationale as Home. Format matches the `S` key's capital orientation exactly, via the shared `HexGeom.directionString` helper. |
| `Shift+End` | Scanner in-game | Toggle auto-move-cursor (off by default) — when on, every successful cycle jumps the cursor to the entry's plot | No engine binding on `Shift+End`. Session-scoped on `civvaccess_shared.scannerAutoMove`; first consumer of what will become the persistent settings layer. |
| `Ctrl+F` | Scanner in-game | Open the type-ahead search input handler; on Enter the scanner shows a filtered snapshot of matching entries | Replaces `Build Fort`, a worker-mission build that only fires when a worker is selected on a fort-eligible plot. Search is scanner's discoverability path; Fort is mouse-first and contextual, losing it is acceptable. |
| `Backspace` | Scanner in-game | Return the hex cursor to the cell saved by the most recent scanner-driven jump (Home or auto-move) | Replaces `Cancel current action` / `Stop automation`. Both are mouse-first unit-command flows that do not fit a keyboard-driven blind player's loop; the scanner's jump/return loop is a primary navigation pattern and the natural reassignment target. |
| `Ctrl+N` | Baseline in-game | Open the notification log (`BUTTONPOPUP_NOTIFICATION_LOG`) with an accessible two-tab wrapper (Active / Dismissed) over the engine's per-player notification list | No engine binding on `Ctrl+N`. The engine's own DiploCorner menu exposes the log via mouse only (no hotkey); our Ctrl+N gives a keyboard path to the complete notification history, which is the only surface that lists dismissed entries. |
| `Ctrl+Space` | Baseline in-game | End turn. On no blocker, calls `CONTROL_ENDTURN`; the ActivePlayerTurnEnd listener announces "Turn ended" when the engine confirms. On a blocker, announces the blocker label (same TXT_KEY the engine's end-turn button displays) and dispatches the engine's take-me-to-the-blocker action (`UI.ActivateNotification` for screen blockers; `UI.SelectUnit` + `UI.LookAt` for unit / stacked-unit / promotion / range-attack blockers). In multiplayer, pressing after submission un-readies the turn and announces "Waiting for players". | Overrides the engine's vanilla `Ctrl+Space` alt-end-turn (`CIV5Controls.xml`) so the announcement pipeline can own every end-turn attempt. The Baseline capture-by-default also swallows `Return` / `Numpad Enter` / `Shift+Return`, the engine's primary and force-end bindings, so Ctrl+Space is the single end-turn path from the map — no silent engine bypass. |
| `Ctrl+Shift+Space` | Baseline in-game | End turn past the units-need-orders prompt. On `ENDTURN_BLOCKING_NONE` or `ENDTURN_BLOCKING_UNITS`, calls `CONTROL_FORCEENDTURN` (the ActivePlayerTurnEnd listener announces "Turn ended"). For any other blocker — research, policy, production, promotion, religion, votes, ideology, archaeology, stacked units, city range attack, steal tech — falls through to the same announce-and-open path as `Ctrl+Space`, because the engine's `CONTROL_FORCEENDTURN` handler at `CvGame.cpp:3712` is gated on `(eBlock == NO_ENDTURN_BLOCKING_TYPE \|\| eBlock == ENDTURN_BLOCKING_UNITS) && allAICivsProcessedThisTurn() && allUnitAIProcessed()` and silently no-ops otherwise. | Mirrors the engine's `Shift+Return` (same semantics, not "bypass everything" despite the common "force end" label). Two-modifier chord is deliberate friction against fatfinger force-end over plain `Ctrl+Space`. |

---

## Key conflicts inside the engine

Some keys carry multiple meanings depending on unit, plot, or screen context. Not our problem to fix — just don't assume a key is "free" because one meaning doesn't apply today.

- `F` — Wake (command), Sleep / Fortify / Garrison (mission), Fishing Boats (build), Fort (Ctrl build), Fishing Boats No Kill (BNW build)
- `S` — Set up ranged / Air sweep (mission), Air strike (mode), Scrub fallout (build), Save (Ctrl)
- `B` — Ranged attack / Found city (mission), Ranged-attack mode, City ranged-attack mode, Brazilwood (BNW build)
- `K` — Embark / disembark (mode), unit die animation (mission), Kasbah (BNW build)
- `A` — Alert (mission), Automate build (automate), Attack (Ctrl mode), Toggle automation (Ctrl control), Academy (build), Archaeology (Ctrl build, BNW), Airlift (Shift mode)
- `E` — Embark (mission), Automate explore (automate), Espionage Overview (Ctrl control), Polder (G&K build)
- `P` — Pillage (Shift mission), Paradrop (mode), Pasture / Plantation (build), Repair (Ctrl build), Religion Overview (Ctrl control)
- `R` — Rebase (mission, also Alt mode), Road (build), Railroad (Alt build), Remove Route (Ctrl+Alt build), Resources (Ctrl control), Route-to (Ctrl+Shift mode)
- `L` — Load game (Ctrl), Lumber mill / Landmark / Holy Site (build)
- `H` — Heal (mission), Select healthy (Ctrl control), Camp / Customs House (build)
- `C` — Center (control), Select type (Ctrl) / all (Alt) / Citadel (Ctrl build), Remove jungle/forest/marsh (Alt build)
- `M` — Move mode, Manufactory (build)
- `N` — Nuke (mode), Mine (build)
- `O` — Options (Ctrl), Well / Offshore platform (build)

---

## Screen reader conflicts

Blind users run a screen reader in the background while playing. Reader modifier keys must stay out of the game's way, and the game's use of those same keys can fire reader commands by accident.

- `Insert` — NVDA and JAWS both use Insert as their primary modifier key ("NVDA key" / "JAWS key"). Civ V binds plain `Insert` to select-city cycling. Expect drive-by conflicts when a user presses Insert+anything to fire a reader command and the Civ input handler also sees the Insert. Mitigation: consider rebinding `CONTROL_SELECTCITY` away from Insert in our mod's default keymap, or documenting the conflict so users remap via Options.
- `Caps Lock` — NVDA's secondary modifier (configurable, widely used) and JAWS's secondary modifier. Also Narrator's primary modifier (`CapsLock+arrows`, `CapsLock+Space`, etc.). Civ V does not bind Caps Lock by default — safe from the engine side, but any mod hotkey we pick with Caps Lock will collide with every screen reader on the planet. Do not bind anything to Caps Lock.
- `Numpad Insert` (Numpad 0 with NumLock off) — NVDA's laptop-layout modifier. Civ V uses `Numpad 0` (NumLock on) as an alt for `MISSION_SKIP`, but the reader modifier form fires only with NumLock off. Reserve for reader use and avoid binding either variant ourselves.
- Narrator — `CapsLock+arrows/space/Enter/Esc` trigger scan mode. Users on Narrator will conflict with any binding we put on those combos.

---

## Unbound keys (candidate safe keys for mod bindings)

Letters that appear in NO XML binding, under any modifier. Verify at runtime before binding — engine-hardcoded keys and user remaps can still claim them.

- **Letters:** `J`, `X` (only these two are truly absent from all XML). `G` is not in the XML either but is widely reported to toggle the hex grid — treat as unverified / probably engine-hardcoded.
- **Numbers:** `1`–`0` (top row) — no default XML bindings.
- **Numpad:** `Numpad 1`, `2`, `3`, `4`, `6`, `7`, `8`, `9` (NumLock on). `Numpad 0` and `Numpad 5` and `Numpad Enter` and `Numpad . / + / - / * / /` are all taken as Control / Mission alts.
- **Punctuation:** `` ` ``, `[`, `]`, `\`, `;`, `'`
- **`Tab`** — no default binding; candidate for screen-reader-style focus cycling

**Previously listed as safe but actually bound** (removed from candidate list after XML audit): `G` (wiki claim of hex grid), `L` (Lumber mill / Landmark / Holy Site / Ctrl+L load), `O` (Well / Offshore / Options), `Q` (Quarry / Alt+Q retire), `T` (Trading post). `Z` is free in base and G&K but taken by BNW for Feitoria / Chateau — safe only if targeting no-BNW installs.

Modifier-combined keys (`Ctrl+`, `Shift+`, `Alt+`) that are unused in the tables above are available, but audit case-by-case — many Ctrl-letter combos are claimed (see conflicts above).

---

## Source files

Base game, under `C:\Program Files (x86)\Steam\steamapps\common\Sid Meier's Civilization V\Assets\`:
- `Gameplay\XML\Units\CIV5Controls.xml` — global UI controls, advisor screens
- `Gameplay\XML\Units\CIV5Commands.xml` — direct unit commands
- `Gameplay\XML\Units\CIV5Missions.xml` — unit mission hotkeys
- `Gameplay\XML\Units\CIV5Automates.xml` — automation hotkeys
- `Gameplay\XML\Units\CIV5Builds.xml` — worker / Great Person build hotkeys
- `Gameplay\XML\Interface\CIV5InterfaceModes.xml` — interface-mode hotkeys

Expansions (same `Assets\` root):
- G&K Controls: `DLC\Expansion\Gameplay\XML\Units\CIV5Controls.xml`
- G&K Missions: `DLC\Expansion\Gameplay\XML\Units\CIV5Missions.xml`
- G&K Builds: `DLC\Expansion\Gameplay\XML\Units\CIV5Builds.xml` + `CIV5Builds_Expansion.xml`
- G&K Interface Modes: `DLC\Expansion\Gameplay\XML\Interface\CIV5InterfaceModes_Expansion.xml` (empty)
- BNW Controls: `DLC\Expansion2\Gameplay\XML\Units\CIV5Controls.xml`
- BNW Missions: `DLC\Expansion2\Gameplay\XML\Units\CIV5Missions.xml`
- BNW Builds: `DLC\Expansion2\Gameplay\XML\Units\CIV5Builds.xml` + `CIV5Builds_Expansion2.xml` + `CIV5Builds_Inherited_Expansion2.xml`
- BNW Interface Modes: `DLC\Expansion2\Gameplay\XML\Interface\CIV5InterfaceModes_Expansion2.xml` (empty)

When in doubt, grep these files for `<HotKey>`, `<HotKeyAlt>`, `<CtrlDown>`, `<ShiftDown>`, `<AltDown>` — the schema is consistent across all files. Engine-internal bindings (camera zoom, hex grid) are not in these XML files and can only be confirmed by runtime testing.
