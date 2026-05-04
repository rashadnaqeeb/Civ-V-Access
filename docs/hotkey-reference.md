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
| `Ctrl+Shift+R` | Worker route-to (auto-build road along path) |
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

`passthroughKeys` carves out the minimum the engine still gets to handle from the map: `F1`-`F11` (advisor screens, strategic view, quick save/load, Ctrl+F10 select-capital, Ctrl+F11 quick-load all live on F-row keycodes) and `Escape` (pause menu, which our GameMenuAccess layers over). `F12` is intentionally absent — InputRouter's pre-walk hook claims it for the Settings overlay, and the engine has no native F12 binding. Popups stacked above Baseline set their own `capturesAllInput` with no passthrough list, so even F-keys and Escape correctly stop at the dialog instead of reaching the map underneath.

Practical consequence: every entry in the earlier tables — whether a `CIV5Controls.xml` global, a `CIV5Commands.xml` unit command (Wake, Upgrade, Cancel, Delete), a `CIV5Missions.xml` action (Sleep / Fortify / Garrison, Alert, Heal, Embark / Disembark, Set up, Ranged attack, Pillage, Air intercept, Rebase, Skip turn), a `CIV5Automates.xml` toggle, a `CIV5Builds.xml` worker / Great Person build, or a `CIV5InterfaceModes.xml` modal cursor — is suppressed on the map unless a row below re-exposes it. When an entry below says "replaces engine X", the replacement is unconditional: the engine X doesn't leak through on a different selection state or a different modifier because the whole map-input channel is gated by Baseline. The same key can still mean something different inside a non-Baseline context (picker screens, menus, the scanner handler above Baseline), which is why each row names the context it applies to.

| Key | Context | Action | Rationale |
|---|---|---|---|
| `F12` | Every Context that routes through InputRouter (front-end and in-game) | Open the mod-wide Settings overlay (audio cue mode, master volume, scanner auto-move). Press again or Esc to close. | No engine binding on `F12` (confirmed against all Controls / Commands / Missions / Automates / Builds / InterfaceModes XML). Steam's default screenshot key — users who haven't remapped it will trigger Steam alongside us. Wired as a pre-walk hook in `InputRouter.dispatch` next to the existing `Shift+?` help hook so it works at every depth of the stack without per-handler bindings. The Settings handler binds `F12` itself for symmetric close. |
| `Ctrl+Shift+F12` | Every Context that routes through InputRouter | Hotseat-mute toggle. Enter mute: speaks "mod paused", then silences all subsequent speech, audio cues, and key interception so the keyboard reaches the engine for a sighted hotseat partner. Exit mute: restores all three and speaks "mod resumed". | No engine binding on any `F12` chord. Wired as the first pre-walk hook in `InputRouter.dispatch` so the toggle works in both states; gates dispatch on `civvaccess_shared.muted` so HandlerStack push/pop continue (observers, ChatBuffer, NotificationAnnounce, RevealAnnounce keep their state current) and unmuting resumes from a live stack. SpeechPipeline and `AudioCueMode.isCueEnabled` read the same shared flag so every Context's speech and the cursor's per-hex audio cues are silenced uniformly. Order invariant: the pause announcement speaks before the flag flips, the resume after it clears, so SpeechPipeline's gate doesn't swallow either. 200 ms debounce against held-key repeat (Windows fires WM_KEYDOWN ~30/s while held; without the debounce a brief hold would silently cycle the toggle). |
| `Ctrl+Up` / `Ctrl+Down` | Accessible Civilopedia, reader tab | Move to the previous / next article in the picker's flat display order (no wrap) | No engine binding on either combo (confirmed against all Controls / Commands / Missions / Automates / Builds / InterfaceModes XML). Lets the user flip through articles without round-tripping back to the picker. |
| `Alt+Left` / `Alt+Right` | Accessible Civilopedia, reader tab | Step back / forward through the base pedia's article-history list (browser-style). Speaks "Start of history." / "End of history." at the boundary. | No engine binding on either combo. Our picker-Enter, follow-link, and Ctrl+Up/Down all drive base `SelectArticle` with addToList=1, so history populates for free; Alt+Left/Right just replays it via the pedia's native history cursor. Reader tab only so the picker's tree browsing isn't confused by back/forward semantics that don't apply there. |
| `Alt+Left` / `Alt+Right` | Advisor Info popup (BUTTONPOPUP_ADVISOR_INFO) | Step back / forward through the popup's concept-history list. Speaks "Start of history." / "End of history." at the boundary. | Same chord, same semantic as the pedia reader's article history, but the popup's history is owned by the base popup's own `g_HistoryList` (built as the user follows related-concept links within the popup) rather than the pedia's global one. Hooked at the BaseMenu spec level rather than a tab hook because the popup has no tabs. Guards `CanGoForwardInHistory()` ourselves on the forward path to work around a base defect where `ForwardInHistory` checks the function reference instead of calling it. |
| `F2` | Multiplayer Staging Room | Toggle the accessible chat panel (Messages + Compose tabs) | Engine binds `F2` to Domestic Advisor in-game only; no front-end screen claims it and StagingRoom's own InputHandler doesn't either. Chat is essential to MP coordination but the engine's chat UI is visual scrolling only, so a dedicated panel with history + compose mode is the minimum viable access path. Panel auto-closes on screen hide. |
| `F2` | LeaderHeadRoot / DiscussionDialog / DiploTrade | Speak a prose description of the AI leader's portrait (setting, dress, symbolism) | Engine's `F2` is Domestic Advisor, bound via `CIV5Controls.xml` at the map layer. These three diplo Contexts install `BaseMenu` with `capturesAllInput = true` so Baseline's `F2` passthrough never reaches the engine from inside the screen. Sighted players see the animated leader art on every AI message; a blind player sees only the leader's title. The description covers what the portrait is actually showing. |
| `Q` / `E` / `A` / `D` / `Z` / `C` | Baseline in-game | Move the screen-reader hex cursor by one tile (Q nw, E ne, A w, D e, Z sw, C se) | Replaces engine bindings on `Q` (Quarry build, only fires for selected workers on quarry-eligible plots), `E` (Embark mission, Automate explore, Polder build), `A` (Alert mission, Automate worker), `D` (Disembark mission), `Z` (Feitoria/Chateau BNW build), `C` (Center on selected unit). Cursor cluster is the primary navigation surface for blind play; mouse-based unit issuance the engine bindings supported isn't usable without sight, so losing those is acceptable. The HandlerStack pre-empts the engine before it sees the keypress. |
| `S` | Baseline in-game | Speak the top unit on the cursor tile (military unit first, civilian fallback) | Replaces `Set up for ranged attack`, `Air strike`, `Scrub fallout` -- all unit/worker missions that fire only when a relevant unit is selected. Reading the cursor tile's occupant is the single most-pressed query during navigation, so it takes the modifier-free slot; the previous plain-S binding (orient to capital) moves to Shift+S. |
| `Shift+S` | Baseline in-game | Speak distance and direction from the cursor to the player's capital | No engine binding on Shift+S. Inherits the orient-to-capital announcement that plain S used to own; kept one modifier away so the cursor-key vocabulary stays intact. |
| `Ctrl+S` | Baseline in-game (bound from `Bookmarks.getBindings`) | Jump the hex cursor to the active player's current capital city. Speaks "no capital" when no capital has been founded yet, and "here" when the cursor is already on the capital tile (rather than re-running the full glance -- a no-op press is a fast confirmation, not a re-read). | Engine's `Ctrl+S` is `Save game`, already swallowed by Baseline's `capturesAllInput` (passthroughKeys covers only F1-F11 and Escape) so this fills a dead key rather than displacing engine behaviour; Save remains reachable via the Esc menu. Routes through `ScannerNav.jumpCursorTo`, the shared mark-then-jump primitive used by Bookmarks Shift+digit and scanner Home -- so the at-target SCANNER_HERE short-circuit and the scanner Backspace return path are common across all three jumps. Targets the current capital (`player:GetCapitalCity`) rather than the original capital that `Shift+S` is anchored to via `HexGeom.activeOriginalCapital` -- "go home" reads as "where I currently rule from" and matches `Cursor.init`'s initial-placement choice. |
| `1` | Baseline in-game | Speak the cursor city's identity and combat info (name, status flags, population, defense, HP, garrison) | No engine binding on the top-row digit keys (confirmed absent from all Controls / Commands / Missions / Automates / Builds / InterfaceModes XML). City readouts mirror the BNW CityBannerManager tiers; three keys (1/2/3) split the banner's information load so each press stays short. |
| `2` | Baseline in-game | Speak the cursor city's production and growth (current build, progress, per-turn rates, food status) | No engine binding. Team-only readout -- non-team cities speak "not visible" rather than leaking internal numbers. |
| `3` | Baseline in-game | Speak the cursor city's politics (warmonger / liberation previews when at war, religion, our spies / diplomats in the city) | No engine binding. Warmonger and liberation previews reuse the engine's own preview strings so the player hears the same consequences a sighted player would see. |
| `W` | Baseline in-game | Speak economy details (yields, fresh water, trade route, working city, build progress) | Replaces `Cycle units on current plot`, which is mouse-driven anyway and not useful without unit-flag visuals. |
| `X` | Baseline in-game | Speak combat details (zone of control, defense modifier) | `X` is among the only two truly unbound letters in the engine (per the unbound-keys list below); no engine action lost. |
| `T` | Baseline in-game | Speak turn number and calendar date; appends unit-supply over-cap when `GetUnitProductionMaintenanceMod` is non-zero (the panel's UnitSupplyString icon trigger), then any strategic-resource shortages as `, no <resource>` per resource where `GetNumResourceAvailable < 0`. Maya-calendar civs also speak the Maya date string. | No engine binding on plain `T` (engine's `Alt+T` is `Pause` in MP, no plain-T bindings in any XML). Reuses the same `TXT_KEY_TP_TURN_COUNTER` + `TXT_KEY_TIME_BC` / `_AD` path as `Turn.lua`'s `ActivePlayerTurnStart` announcement so the spoken format matches every other surface that names the date. Strategic shortages live here rather than on `G` because they bear on what units can be built this turn. |
| `R` | Baseline in-game | Speak the active research as `<turns> turns to <tech>, science +<rate>`; falls back to `<tech> done, science +<rate>` (just-finished, no successor picked) or `No research, science +<rate>`. Honours the `NO_SCIENCE` game option (`Science off`). | Replaces engine's `R` mission cluster (Rebase / Road / Railroad — Alt build / Remove Route / Resources / Route-to), all of which fire only for a selected unit or worker on a build-eligible plot and are unreachable through Baseline's letter wall. Joins TopPanel's science readout with TechPanel's current-research display in one line. |
| `Shift+R` | Baseline in-game | Speak the per-source science breakdown the engine's `ScienceTipHandler` shows on TopPanel hover, dropping only the `+<rate> Science per Turn` line bare `R` already spoke. Anarchy prefix, budget-deficit penalty, and the `each city raises tech cost by N%` basic-help trailer all surface verbatim. Items joined with `", "`, sections joined with `". "`. | No engine binding on `Shift+R`. Reuses engine `TXT_KEY_TP_*` keys directly so the spoken text matches what sighted players see in the tooltip. Player can disable the basic-help trailers via `Game Options → Show Basic Help`. |
| `G` | Baseline in-game | Speak gold per turn, total, and used / available trade routes. Format: `+<rate> gold, <total> total, <used> of <avail> trade routes` (or `minus <rate> gold, ...` when `CalculateGoldRate` is negative). | No engine binding on plain `G` (no XML row claims it). Strategic-resource shortages used to ride here; they moved to bare `T` because the supply question fits the turn-level readout better. |
| `Shift+G` | Baseline in-game | Speak the per-source income, expense breakdown, and deficit-eats-science warning the engine's `GoldTipHandler` shows on TopPanel hover, dropping only the treasury (`TXT_KEY_TP_AVAILABLE_GOLD`) and `<num> Total Income` lines bare `G` already implied. Includes the `Gold buys units...` basic-help trailer when that option is on. | No engine binding on `Shift+G`. Same reuse-engine-keys pattern as `Shift+R`. |
| `H` | Baseline in-game | Speak empire happiness, the count of luxuries currently providing happiness (resources where `GetHappinessFromLuxury > 0`), then golden-age state, in that fixed order regardless of GA active vs progressing. Happiness branch: `+<excess> happiness` / `Unhappy minus <deficit>` / `Very unhappy minus <deficit>` (driven by `IsEmpireUnhappy` / `IsEmpireVeryUnhappy`). GA branch: `golden age for <turns> turns` when `GetGoldenAgeTurns > 0`, else `<cur> of <threshold> to golden age`. Honours `NO_HAPPINESS` (`Happiness off`). | Replaces engine's `H` mission cluster (Heal mission / Camp / Customs House build / Select-healthy Ctrl-control), all narrow / contextual / unreachable through Baseline's letter wall. Luxury count is "connected" rather than "owned" — engine returns 0 from `GetHappinessFromLuxury` when the source is lost, traded away, or unrouted. Fixed order at user request — predictable shape on every press. |
| `Shift+H` | Baseline in-game | Speak the per-source happiness breakdown, the unhappiness breakdown, the basic-help trailer, and the golden-age addition / loss / effect / carnival lines, mirroring the engine's `HappinessTipHandler` and `GoldenAgeTipHandler` joined. Drops only the total-happiness / total-unhappiness / golden-age-headline lines bare `H` already covered. The per-luxury enumeration (`+<n> from <luxury>` per connected resource) is the long-form expansion of bare `H`'s luxury count. | No engine binding on `Shift+H`. Folds two engine handlers (happiness and golden age) because bare `H` reads both headlines, so the detail extends both. |
| `F` | Baseline in-game | Speak `+<rate> faith, <total> total`. Honours `NO_RELIGION` (`Religion off`). | Replaces engine's `F` mission cluster (Wake command / Sleep-Fortify-Garrison mission / Fishing Boats build / Fort Ctrl-build / Fishing Boats No Kill BNW build), already swallowed by Baseline. We re-expose Fortify / Sleep on `Alt+S` and Wake on `Alt+W`, leaving plain `F` open for the empire-status readout that matches the letter mnemonically. |
| `Shift+F` | Baseline in-game | Speak the per-source faith breakdown, prophet / pantheon / religions-left timing, and (in the industrial era) the list of buyable Great People — mirroring the engine's `FaithTipHandler`. Drops only the `<num> Faith stored` line bare `F` already spoke. | No engine binding on `Shift+F`. Same pattern as `Shift+R` / `Shift+G`. |
| `P` | Baseline in-game | Speak `+<rate> culture, <turns> turns to policy`, where `<turns>` is `ceil((cost - stored) / rate)`. Variants: `no policies left` when `GetNextPolicyCost <= 0`; `no culture, <stored> of <cost> to next policy` when culture per turn is zero or negative. Honours `NO_POLICIES` (`Policies off`). | Replaces engine's `P` cluster (`Shift+P` Pillage / Paradrop mode / Pasture / Plantation builds / Repair Ctrl-build / Religion Overview Ctrl-control). Pillage we re-expose on `Alt+P`; the rest are mouse / contextual. The CultureString panel item itself opens the Choose-Policy popup, so plain `P` reads the same policy-timing data the panel surfaces. |
| `Shift+P` | Baseline in-game | Speak the basic-help block (`<n> Culture stored`, `<n> Culture for next Policy`) followed by the per-source culture breakdown and the `each city raises policy cost by N%` trailer, mirroring the engine's `CultureTipHandler`. Drops only the `Next Policy in <turns> turns` line bare `P` already spoke. Anarchy short-circuits the source list the same way the engine does. | No engine binding on `Shift+P`. Engine's `Shift+P` is `Pillage`, swallowed by Baseline's letter wall and re-exposed at `Alt+P`. |
| `I` | Baseline in-game | Speak `+<rate> tourism`, optionally suffixed with `, influential on <count> civs`, or `, influential on <count> of <total> civs` when within two of a culture victory (`(total - count) <= 2`). Iterates `0..GameDefines.MAX_CIV_PLAYERS - 1`, filtered to alive non-minor others, counting those at `>= INFLUENCE_LEVEL_INFLUENTIAL`. | Replaces engine's `I` cluster (Air Intercept patrol mission / Irrigate / Farm builds), already swallowed by Baseline. `Ctrl+I` (cursor pedia, BaseMenu pedia) is on a different chord and unaffected. Tourism in isolation is information-thin; the influential-civ count turns the readout into a culture-victory tracker. |
| `Shift+I` | Baseline in-game | Speak the great-works count and empty-slot count from the engine's `TourismTipHandler` (`<n> Great Works`, `<n> empty slots`), plus the `Influential on <n> of <total> civs` line — but only when bare `I`'s within-reach branch did NOT already speak the same `X of Y` phrasing. The headline-skip rule is conditional here because tooltip 3 itself is conditional on `PreGame.IsVictory(VICTORY_CULTURAL)`. | No engine binding on `Shift+I`. The conditional skip preserves the rule that no Shift readout repeats what the bare key already said. |
| `Shift+T` | Baseline in-game | Speak the active entries from the engine's task list (status 0; completed and failed are dropped), text concatenated with `". "` and run through `TextFilter.filter`. Silent when no active tasks exist. | No engine binding on `Shift+T`. The task list (engine `TaskList.lua`, fed by `Events.TaskListUpdate` from C++) is a scenario-driven objective tracker ("Capture Constantinople by turn 100"); without a readout key blind players had no path to its contents. There is no engine API to query tasks, so a synchronously-updated mirror in `civvaccess_shared.tasks` is the only available source — same shape as the engine's own `TaskList.lua`. |
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
| `Home` | Scanner in-game | Jump the hex cursor to the current scanner entry's plot; remembers the pre-jump cell for Backspace. Speaks "here" when the cursor is already on the entry's plot rather than re-running the full glance. | Replaces `Next city`. The scanner's Cities category with owner subcategories is a strict superset of the engine's city cycle; losing it costs nothing. Routes through `ScannerNav.jumpCursorTo`, the shared mark-then-jump primitive used by Bookmarks Shift+digit and Ctrl+S jump-to-capital -- so the at-target SCANNER_HERE short-circuit and the Backspace anchor capture are common across all three jumps. |
| `End` | Scanner in-game | Speak distance and direction from the hex cursor to the current scanner entry | Replaces `Previous city`, same rationale as Home. Format matches the `S` key's capital orientation exactly, via the shared `HexGeom.directionString` helper. |
| `Shift+End` | Scanner in-game | Toggle auto-move-cursor (off by default) — when on, every successful cycle jumps the cursor to the entry's plot | No engine binding on `Shift+End`. Persists via `Prefs.setBool("ScannerAutoMove", ...)`; the same toggle is also reachable from the F12 Settings overlay. |
| `Ctrl+F` | Scanner in-game | Open the type-ahead search input handler; on Enter the scanner shows a filtered snapshot of matching entries | Replaces `Build Fort`, a worker-mission build that only fires when a worker is selected on a fort-eligible plot. Search is scanner's discoverability path; Fort is mouse-first and contextual, losing it is acceptable. |
| `Backspace` | Scanner in-game | Return the hex cursor to the cell saved by the most recent scanner-driven jump (Home or auto-move) or bookmark jump (Shift+digit) | Replaces `Cancel current action` / `Stop automation`. Both are mouse-first unit-command flows that do not fit a keyboard-driven blind player's loop; the scanner's jump/return loop is a primary navigation pattern and the natural reassignment target. Bookmark jumps share the same anchor via `ScannerNav.markPreJump` so one Backspace key returns from either source. |
| `Ctrl+1` through `Ctrl+0` | Bookmarks in-game | Save the cursor's current cell into the matching slot (1-9, 0). Speaks "bookmark added"; subsequent saves to the same slot overwrite. | No engine binding on any modifier-combined top-row digit (confirmed absent from all CIV5 XML). Slots are session-only — they live on `civvaccess_shared.bookmarks` and are wiped on every `LoadScreenClose`. Civ V's save format has no mod-controlled extension hook and any custom payload would risk multiplayer hash drift, so persistence is intentionally out of scope. |
| `Shift+1` through `Shift+0` | Bookmarks in-game | Jump the hex cursor to the saved cell in the matching slot, speaking the destination glance the same way a cursor move would. Empty slots speak "no bookmark"; the cursor already on the saved cell speaks "here" rather than re-running the full glance. | No engine binding on any modifier-combined top-row digit. Routes through `ScannerNav.jumpCursorTo`, the shared mark-then-jump primitive used by scanner Home / Ctrl+S jump-to-capital -- so the at-target SCANNER_HERE short-circuit and the Backspace anchor capture are common across all three jumps. |
| `Alt+1` through `Alt+0` | Bookmarks in-game | Speak distance and direction from the cursor to the saved cell in the matching slot, plus the capital-relative coord when the scanner-coord setting is on. Empty slots speak "no bookmark". | No engine binding on any modifier-combined top-row digit. Direction format is byte-identical to the scanner's `End` readout (shared `HexGeom.directionString`); the coord segment reads `civvaccess_shared.scannerCoords` so users get one consistent vocabulary across scanner and bookmark spatial queries. |
| `[` / `]` | MessageBuffer in-game | Step backward / forward by one entry in the session-scoped review buffer of speech-worthy events across the categories the buffer ingests (currently notifications, reveals, foreign-unit-watch, combat, multiplayer chat). Position is sticky across presses; `]` from the uninitialized state is at the forward edge and speaks "newest" (or "no messages" on an empty buffer / filter), `[` enters the buffer at the newest matching entry. Edge presses speak "oldest" / "newest" without moving position. | No engine binding on either bracket (confirmed against all CIV5 XML; both listed in the unbound-keys section below as candidate-safe punctuation). The buffer is the only review path for messages that scrolled off mid-turn — without bracket nav, blind players cannot recover a missed notification or combat readout. The plain bracket pair takes the most-used axis (single-step) per the modifier-ladder convention used by the scanner cycle. |
| `Ctrl+[` / `Ctrl+]` | MessageBuffer in-game | Jump to the oldest / newest entry in the active filter, speaking that entry. Empty filter speaks "no messages". | No engine binding on either combo. End-jumps mirror the scanner's snap-to-end pattern (no Home/End on punctuation, so Ctrl + the nav pair is the natural extension). Use case is "what's the oldest thing still in the buffer" or "snap to the most recent message after navigating away". |
| `Shift+[` / `Shift+]` | MessageBuffer in-game | Cycle the active filter category backward / forward through `all` -> `notification` -> `reveal` -> `combat` -> `chat`. On change, position resets to the newest matching entry; speaks "<filter name>, <newest entry>" or "<filter name>, no messages". | No engine binding on either combo. Filter cycle uses the modifier-ladder convention (Shift = different axis than plain) and matches the scanner's Shift-modifier-changes-axis pattern. Filter change is a deliberate context switch, so resetting to newest is preferable to preserving the absolute index across filters with very different sparseness. |
| `\` | Baseline in-game | Toggle the multiplayer chat panel (Messages tab + Compose tab wrapping `Controls.ChatEntry` from DiploCorner). Single-player and hot-seat speak "Chat is multiplayer only" and no-op (`Game:IsNetworkMultiPlayer()` returns false in both). Esc or `\` again closes. | Backslash is unbound by every CIV5 XML (Controls / Commands / Missions / Automates / Builds / InterfaceModes); the chord is free across base / G&K / BNW. ChatAccess is seated in DiploCorner's env (via our DiploCorner.lua override) so `Controls.ChatEntry`, `OnChatToggle`, and `SendChat` are reachable; the receive listener (`ChatBuffer`, in WorldView's env) feeds civvaccess_shared._inGameChatLog plus the MessageBuffer "chat" category so the user can review chat history through `[` / `]` regardless of whether the panel is open. |
| `F10` | Baseline in-game | Open the advisor counsel popup (`BUTTONPOPUP_ADVISOR_COUNSEL`) with an accessible four-tab wrapper, one tab per advisor, each tab paginating the advisor's counsel entries as menu items | Replaces `Toggle strategic view`. The engine's native hotkey for this popup is `V` (`CONTROL_ADVISOR_COUNSEL`) but Baseline's letter-capture wall swallows it; strategic view is a visual-only feature blind players do not use, so F10 is reassigned. F10 stays in `passthroughKeys` so the plain-F10 binding wins first while Ctrl+F10 (select-capital) still reaches the engine via InputRouter's keycode-only passthrough. |
| `Ctrl+C` | Baseline in-game | Open the Culture Overview popup (`BUTTONPOPUP_CULTURE_OVERVIEW`) with an accessible four-tab wrapper (Your Culture, Swap Great Works, Culture Victory, Player Influence). Speaks "Culture Overview is disabled in this game" when `GAMEOPTION_NO_CULTURE_OVERVIEW_UI` is set. | Culture Overview has no engine hotkey at all — sighted players reach it from the top-bar tourism icon and the DiploCorner button — so without a chord blind players cannot reach the screen. Plain `C` is the cursor SE binding; `Ctrl+C` is distinct under `(key, mods)` dispatch. The engine's `Ctrl+C` (`CONTROL_SELECT_OF_TYPE` and Citadel for Great Generals) is already swallowed by Baseline's letter wall, so the chord is free for us. |
| `Ctrl+T` | Baseline in-game | Open the Trade Route Overview popup (`BUTTONPOPUP_TRADE_ROUTE_OVERVIEW`) with an accessible three-tab wrapper (Your trade routes, Available trade routes, Trade routes with you). Each tab is a flat list of route Groups; drilling into a route surfaces the engine's `BuildTradeRouteToolTipString` split per `[NEWLINE]` line. | Trade Route Overview has no engine hotkey at all — sighted players reach it from the trade-unit panel button and the DiploCorner button — so without a chord blind players cannot reach the screen. Plain `T` is empire-status turn / date / supply readout; `Ctrl+T` is distinct under `(key, mods)` dispatch and unbound by every CIV5 XML, so the chord is free. |
| `Ctrl+L` | Baseline in-game | Open the World Congress / United Nations overview popup (`BUTTONPOPUP_LEAGUE_OVERVIEW`) with an accessible three-tab wrapper (Status: members and session pill; Proposals: View / Propose / Vote modes; Effects: ongoing resolutions). Vote rows are slider-shaped — Left/Right adjust by 1, Shift+Left/Right by 5; Enter on a major-civ resolution opens the civ picker. Looks up the active league's ID via `Game.GetActiveLeague` and passes it as `Data1`; `-1` when no league exists, in which case both engine UI and our wrapper speak the no-league fallback. | Replaces engine `Ctrl+L` (`Load game in-game`). In-game load remains reachable via the Esc menu's Load entry. League Overview has engine entry points (Diplomacy "World Congress" button, Additional Information dropdown, league notifications) but no engine hotkey, so blind players had no keyboard path to the screen. Baseline's `capturesAllInput` wall already swallowed the engine's `Ctrl+L` so the chord was de-facto free; this binding formalizes the reuse. |
| `Ctrl+R` | Baseline in-game | Open the Religion Overview popup (`BUTTONPOPUP_RELIGION_OVERVIEW`) with an accessible three-tab wrapper (Your Religion: status / beliefs / faith readout / possible great people / automatic-purchase pulldown; World Religions: one row per founded religion plus an OVERALL STATUS footer; Beliefs: every active belief in the world). `Data1=1` toggles the popup closed when already visible (matches the Culture / Trade Route Overview pattern). Speaks "Religion off" when `GAMEOPTION_NO_RELIGION` is set. | Replaces engine `Ctrl+R` (`CONTROL_RESOURCE_ALL`, toggles the resource-icon overlay) — visual-only, same overlay-toggle category as the `Ctrl+L` reassignment. Engine has a native `Ctrl+P` for the same screen but `Ctrl+P` collides with worker `BUILD_REPAIR` (engine disambiguates by selection context); `Ctrl+R` is mnemonic and conflict-free across CIV5Controls / Builds / Missions / Interface-Modes (bare `R` is BUILD_ROAD; `Alt+R` is RAILROAD / REBASE; `Ctrl+Alt+R` is REMOVE_ROUTE; `Ctrl+Shift+R` is ROUTE_TO — none dispatch on `Ctrl+R` alone). |
| `Ctrl+E` | Baseline in-game | Open the Espionage Overview popup (`BUTTONPOPUP_ESPIONAGE_OVERVIEW`, BNW only) with an accessible three-tab wrapper (Agents: flat list, drill into a spy for View City / Stage Coup / Move actions; Cities: Your / Their groups, drill into a city for civ / name / potential / population / spy presence with engine tooltips; Intrigue: flat list of intrigue messages, most-recent first). Move flow surfaces a city picker with a hideout button and Diplomat-vs-Spy fork on enemy capitals. `Data1=1` toggles closed when already visible. Speaks "Espionage is disabled in this game" when `GAMEOPTION_NO_ESPIONAGE` is set. | Re-fires the engine's native `Ctrl+E` binding (added in G&K, kept in BNW for this same popup) which Baseline's `capturesAllInput` wall would otherwise swallow. Plain `E` is the cursor NE binding; `Ctrl+E` is distinct under `(key, mods)` dispatch and the engine has no other action on it. |
| `Ctrl+Space` | Baseline in-game | End turn. On no blocker, calls `CONTROL_ENDTURN`; the ActivePlayerTurnEnd listener announces "Turn ended" when the engine confirms. On a blocker, announces the blocker label (same TXT_KEY the engine's end-turn button displays) and dispatches the engine's take-me-to-the-blocker action (`UI.ActivateNotification` for screen blockers; `UI.SelectUnit` + `UI.LookAt` for unit / stacked-unit / promotion / range-attack blockers). In multiplayer, pressing after submission un-readies the turn and announces "Waiting for players". | Overrides the engine's vanilla `Ctrl+Space` alt-end-turn (`CIV5Controls.xml`) so the announcement pipeline can own every end-turn attempt. The Baseline capture-by-default also swallows `Return` / `Numpad Enter` / `Shift+Return`, the engine's primary and force-end bindings, so Ctrl+Space is the single end-turn path from the map — no silent engine bypass. |
| `Ctrl+Shift+Space` | Baseline in-game | End turn past the units-need-orders prompt. On `ENDTURN_BLOCKING_NONE` or `ENDTURN_BLOCKING_UNITS`, calls `CONTROL_FORCEENDTURN` (the ActivePlayerTurnEnd listener announces "Turn ended"). For any other blocker — research, policy, production, promotion, religion, votes, ideology, archaeology, stacked units, city range attack, steal tech — falls through to the same announce-and-open path as `Ctrl+Space`, because the engine's `CONTROL_FORCEENDTURN` handler at `CvGame.cpp:3712` is gated on `(eBlock == NO_ENDTURN_BLOCKING_TYPE \|\| eBlock == ENDTURN_BLOCKING_UNITS) && allAICivsProcessedThisTurn() && allUnitAIProcessed()` and silently no-ops otherwise. | Mirrors the engine's `Shift+Return` (same semantics, not "bypass everything" despite the common "force end" label). Two-modifier chord is deliberate friction against fatfinger force-end over plain `Ctrl+Space`. |
| `Alt+F` | Baseline in-game (selected unit) | Sentry: sleep until an enemy comes into sight (`MISSION_ALERT`). | No engine binding on `Alt+F`. The natural plain-`A` for Alert is unreachable through Baseline's letter wall and is also our cursor-direction key. |
| `Alt+S` | Baseline in-game (selected unit) | Fortify a military unit, sleep a civilian. Routes through `UnitActionMenu.commitByType` against `MISSION_FORTIFY` then `MISSION_SLEEP`, so the engine picks by unit type the same way plain `F` does in vanilla. | Replaces engine's `Alt+S` (`Air Sweep` interface mode, only fires for an air unit with sweep). Mnemonic: `S` for sleep. The engine's plain `F` for fortify is unreachable through Baseline's letter wall. |
| `Alt+W` | Baseline in-game (selected unit) | Wake a sleeping / fortified / alerted unit, or cancel a queued move / automation. Walks `COMMAND_WAKE`, `MISSION_WAKE`, `COMMAND_CANCEL`, `COMMAND_STOP_AUTOMATION` in that order — only one is ever currently available, so caller order is documentation, not precedence. | No engine binding on `Alt+W`. Mnemonic for "wake." Pairs with `Alt+F` and `Alt+S` so the hold-position cluster has its own undo. The engine's `Backspace` for cancel / stop-automation is taken by the scanner. |
| `Alt+Space` | Baseline in-game (selected unit) | Skip the unit's turn (`MISSION_SKIP`). | Replaces nothing — engine's plain `Space` is `MISSION_SKIP` but Baseline doesn't pass it through. `Alt+Space` is unbound by the engine. |
| `Alt+H` | Baseline in-game (selected unit) | Heal until full (`MISSION_HEAL`). | Replaces nothing usable — engine's plain `H` is Heal / Camp / Customs House (mission + worker builds), all in narrow contexts and unreachable through Baseline's letter wall. |
| `Alt+R` | Baseline in-game (selected unit) | Open the ranged-attack target picker (`INTERFACEMODE_RANGE_ATTACK` for ground / naval, falling through to `INTERFACEMODE_AIRSTRIKE` for air units). Routes through `UnitActionMenu.commitByType`, which calls `Game.HandleAction` (sets the engine's interface mode) and pushes `UnitTargetMode` so cursor keys aim, space previews, enter commits. | Replaces engine `Alt+R` (`Railroad` worker build + `Rebase` air-unit interface mode). Both are narrow and contextual; mnemonic "R for ranged" beats the engine's plain `B` (Ranged Attack / Found City / Brazilwood) which is one of the most overloaded keys in the game. |
| `Alt+M` | Baseline in-game (selected unit) | Open the move target picker (`INTERFACEMODE_MOVE_TO`). Routes through `UnitActionMenu.commitByType` -- same `Game.HandleAction` + `UnitTargetMode` push the action menu's "Move To" entry uses, so cursor keys aim, space previews, enter commits, Shift+Enter queues. Units that can't move (air units, which use rebase instead) speak "Move To not available" via the action's TextKey label. | Replaces engine `Alt+M` (`INTERFACEMODE_MOVE_TO_ALL`, the Shift+click "move all selected units on plot" interface mode). The engine binding is mouse-first and already swallowed by Baseline's letter wall; the keyboard equivalent here drives the single selected unit, matching the Tab menu's plain Move To. Mnemonic "M for move" parallels Alt+R for ranged. |
| `Alt+P` | Baseline in-game (selected unit) | Pillage the unit's tile (`MISSION_PILLAGE`). | No engine binding on `Alt+P`. Mnemonic matches engine `Shift+P` for the same mission. |
| `Alt+U` | Baseline in-game (selected unit) | Upgrade the unit (`COMMAND_UPGRADE`). | No engine binding on `Alt+U`. Mnemonic matches engine plain `U`. The `CanHandleAction` gate handles the gold / territory / tech preconditions, so a non-upgradeable unit hears "Upgrade Unit not available." |
| `Alt+N` | Baseline in-game (selected unit) | Open the rename-unit popup (`BUTTONPOPUP_RENAME_UNIT`) on the selected unit. The accessible wrapper at `CivVAccess_SetUnitNameAccess.lua` handles the textfield plus Accept / Cancel. | No engine binding on `Alt+N`. Mnemonic for "name." Engine exposes the same popup via a pencil button on UnitPanel that's only shown for promotable (military) units, but the popup itself accepts any selected unit; we open it for whatever's selected so workers, settlers, and great people can also be renamed via keyboard. |
| `Ctrl+I` | Every BaseMenu item (menus, pickers, popups, CityView hub, scanner modals) | Open Civilopedia for the focused item by calling `Events.SearchForPediaEntry(item.pediaName)`. Items without a `pediaName` / `pediaNameFn` silently no-op. | No engine binding on `Ctrl+I` (plain `I` is the Irrigate / Farm worker-build hotkey, Ctrl+I is absent from every XML). The binding is installed in `BaseMenuCore` so every menu inherits it without per-screen wiring. Gated on `Events.SearchForPediaEntry` so FrontEnd Contexts (where the event doesn't exist) skip the binding. |
| `Ctrl+I` | Baseline in-game (hex cursor) | Enumerate everything at the cursor's plot with a Civilopedia article (units, world wonders in the city on the tile, improvement, resource, regular feature, river, lake, terrain, hills, mountain, route), dedupe by pedia name so a carrier's four fighters collapse to one Fighter entry, and either open the pedia directly on a single result or pop a picker. The picker skips its header announcement on open so the user hears the first result immediately; F1 still reads "Articles at tile". Unrevealed plots no-op. | Mirrors the BaseMenu `Ctrl+I` key (same "open pedia" verb, parallel surface) at the cursor level rather than a menu item level. No engine binding on map `Ctrl+I`; plain `I` is the Irrigate / Farm worker-build hotkey and is captured by Baseline's letter wall anyway. Hills / mountain / river / lake come from plot-type booleans and FakeFeatures respectively (not `GetFeatureType` / `GetTerrainType`), which is why they need explicit detection. World wonders only (not national / team wonders) match what a sighted player would look up from the tile; national wonders are easier to reach from the city screen's wonder list. |
| `Ctrl+/` | Baseline in-game (selected unit) | Recenter the hex cursor on the selected unit's plot via `Cursor.jumpTo`, speaking the destination tile glance the same way a cursor move would. Silent on no-unit, matching every other selection-keyed binding. | No engine binding on `Ctrl+/` (absent from every XML). Plain `/` is the engine's Cycle-Workers hotkey, swallowed by Baseline and re-exposed as our unit-info readout. Ctrl extends the slash family with the cursor-snap counterpart to the auto-jump that already runs on `UnitSelectionChanged` — useful when the cursor has wandered and the user wants back to the unit without re-cycling. |
| `Return` / `Numpad Enter` | CityView hex-map sub | Toggle the cursor plot's citizen assignment (`TASK_CHANGE_WORKING_PLOT`) if the plot is in the working area; buy the plot (`SendCityBuyPlot`) if it's purchasable and affordable; speak the cost key if purchasable but unaffordable. City-center tile is a no-op. | No engine binding conflict: the base `CityView` screen has no Enter binding (mouse-driven plot clicks do the same tasks). CityView's hex sub is pushed above the CityView hub, so this Enter is scoped to the sub and doesn't touch Baseline's Enter (cursor activate → open city / diplomacy). Mirrors the single action a sighted player performs on any clickable in-city plot button. |
| `,` / `.` | ChooseProduction popup (BUTTONPOPUP_CHOOSEPRODUCTION) | Cycle to the previous / next city's ChooseProduction popup via `CONTROL_PREVCITY` / `CONTROL_NEXTCITY`, then re-fire `SerialEventGameMessagePopup` with the new city's id so our intercept rebuilds both tabs against the fresh context. Announces "no previous city" / "no next city" in single-city empires. Preserves the original `Option1` / `Option2` flags across cycle so append-mode and the initial-tab choice carry forward. | Engine binds plain `,` to "Reselect last active unit" and plain `.` to "Alternate cycle units" on the map (`CIV5Controls.xml`), but those bindings only fire while map input reaches the engine. Inside the popup Context our BaseMenu.install wrapper owns input; the engine's map-layer bindings cannot fire until the popup closes, so this claim is local to the popup and does not shadow the on-map unit cycle. |
| `Shift+Return` | UnitTargetMode (selected unit, target picker on the stack) | Queue the targeted move: appends the mission to the unit's queue via `bShift=true` on `GAMEMESSAGE_PUSH_MISSION`, leaves the target picker active so additional shift+enter presses chain more legs, skips the combat-pending / move-pending registration that plain enter installs (a queued move doesn't necessarily resolve this turn). Melee-attack interface modes are rejected with "cannot queue attack". | Replaces engine `Shift+Return` (`CONTROL_FORCEENDTURN`) only while UnitTargetMode is on the stack — the handler's `capturesAllInput=false` lets the engine's force-end fire normally everywhere else. Force-ending a turn while the user is mid-target-picker is the wrong action regardless; the override is the right behavior even if it happened by accident. Mirrors base WorldView.lua's mouse-shift-click which uses the same `bShift` net-message arg. |

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
- **Punctuation:** `` ` ``, `[`, `]`, `;`, `'` (`\` is now bound by the mod for multiplayer chat toggle)
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
