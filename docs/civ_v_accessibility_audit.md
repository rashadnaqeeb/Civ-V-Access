# Civilization V Accessibility Audit

A tour of every surface a Civ V player encounters, in roughly the order they meet it, and what coverage this mod gives each one. The point of this document is to let you read straight through and feel the shape of the work: what is reachable to a blind player today, what is partially reachable, and what still has nothing.

Status word at the top of each section says where it sits. "Done" means a screen-reader user can drive the surface end to end. "Partial" means some of it is spoken or navigable but specific gaps remain — the gap is named in the body. "Not started" means the surface produces no speech at all and a sighted player would do something there that a blind player cannot. "Not applicable" means the surface is non-interactive (logos, splash animations, voice-over) or simply does not exist in shipped Civ V.

Coverage is for Brave New World only. The mod ships a single BNW-only DLC manifest; base-game and Gods and Kings sessions activate no accessibility layer at all by design.

---

# Phase 1: Application Launch and Main Menus

## 1.1 Legal, logo, and title splash — Not applicable

The 2K, Firaxis, and Aspyr logo movies auto-advance. The legal screen has a single Continue button to clear the EULA. The animated title backdrop is decorative. The legal screen is wired through the mod's standard menu handler so the Continue advances on Enter.

## 1.2 Main menu — Done

The vertical button stack — Single Player, Multiplayer, Mods, Options, Other, Expansion Rules, Exit — is read out and navigable. Sub-menus open and announce themselves on focus.

## 1.3 Single player submenu — Done

Play Now, Set Up Game, Load Game, Scenarios, Tutorial, Back. Each opens its child screen, all of which are covered below.

## 1.4 Other submenu — Done

Latest News, Civilopedia, Hall of Fame, View Replays, Credits, Leaderboard, Back. The submenu itself is fully accessible. The Hall of Fame and Leaderboard screens it opens are not (see 1.10 and 1.11). The Civilopedia is.

## 1.5 Tutorial launcher — Done

The tutorial picker. Lets the player choose one of the scripted tutorial scenarios and launch it. The in-game tutorial advisor banner that the chosen scenario uses is read; see 3.13.

## 1.6 Options menu — Done

The shared in-game / front-end tabbed options screen — Game, Interface, Video, Audio, Multiplayer. Tabs cycle, every checkbox / pulldown / slider / edit is reachable, and value changes are spoken. Civ V has no key-rebinding tab; nothing to cover there.

## 1.7 Mods menu — Done

The full mod flow: the mods root, the installed-mods panel, the workshop browser, error popups, the EULA acceptance, custom-mod launches, and the mod-specific single-player and multiplayer screens. The list rows speak mod name, author, version, and enabled state, and per-row actions (enable, disable, options) are reachable. Workshop browser entries speak title, author, rating.

## 1.8 Load game — Done

The save list with sort pulldown and the per-save detail panel. Selecting a save speaks its name, leader and civ, the date saved, era and turn count, and the game type. The metadata icons (civ, map type, size, difficulty, speed) are read. Delete and Back are reachable.

## 1.9 Replay viewer — Partial

The replay picker that lists saved replays is accessible. The actual replay viewer screen — the animated map playback with turn slider, info pulldown, and graph data set selector — is not yet read. A blind player can find a replay and select it but cannot meaningfully consume it.

## 1.10 Hall of Fame — Not started

The list of past completed games (leader, civ, score, victory type, date, difficulty, map, speed) is unread.

## 1.11 Leaderboards — Not started

The Steam-backed online rankings are unread.

## 1.12 Credits — Not applicable

Auto-scrolling text. Back interrupts the scroll and returns.

## 1.13 Multiplayer type selector — Done

Internet, Local Network, Hot Seat, Pitboss, Reconnect, Back. Each is read; opening one routes to the appropriate lobby or staging room.

## 1.14 Multiplayer lobby — Done

The internet / LAN / pitboss server browser. Game rows speak server name, host, map, turn, civs in play, ping. Host Game, Join, Refresh, sort headers, and the IP-connect field (pitboss) are reachable.

## 1.15 Joining room — Done

The transient connecting splash. Status text is announced; cancel works.

## 1.16 Multiplayer staging room — Done

The two-tab pre-game lobby (Players, Game Options). Per-slot rows speak leader, civ, team, slot type, handicap, and ready state. The host's invite, kick, swap, lock, and enable controls are reachable. The Game Options tab mirrors Advanced Setup and shares its coverage. Chat is reachable. Ready, Launch, and Back are wired.

## 1.17 Hot Seat password and player change — Done

The handoff popups between hot-seat players. Both speak the new player's identity and accept the password edit.

## 1.18 Dedicated server (Pitboss host) — Not started

The Pitboss host control panel — uptime, players connected, turn, autosave timing, kick, save now, return to menu — is unread.

## 1.19 Content and expansion switching — Done

The mod-and-DLC enable confirmation prompt and the premium-content grid (per-DLC enable/disable, Launch). Both are reachable.

## 1.20 Generic front-end popup and exit confirm — Done

The single-Close informational popup, the Yes/No exit-to-desktop confirm, and the multi-button generic confirm popup. All read body text, announce buttons, and accept Enter / Escape.

---

# Phase 2: New Game Setup

## 2.1 Quick game setup screen — Done

The five large choice buttons (Civilization, Map Type, Map Size, Difficulty, Game Speed), the randomize and advanced shortcuts, and Start. Each choice button speaks its current value when focused; activating it opens the corresponding picker.

## 2.2 Civilization and leader picker — Done

Scrollable civ list with a Random entry. The unique units, unique buildings or improvements, and leader trait panels read out for the focused civ. Pedia shortcut works.

## 2.3 Map type picker — Done

Map script list with description panel. Each entry speaks name and a one-line summary.

## 2.4 Map size picker — Done

The six size options with their tile-count and recommended-civ blurbs.

## 2.5 Difficulty picker — Done

The eight difficulty levels with the per-level production / gold / happiness / AI summary.

## 2.6 Game speed picker — Done

Quick / Standard / Epic / Marathon with per-pace summaries.

## 2.7 Advanced setup — Done

The full custom panel. Map type, size, handicap, pace, era, turn mode, max-turns, victory toggles, all rule toggles, the city-state slider, and the per-script options are all reachable. The player slot list — Add AI, Remove, civ pulldown, team pulldown, edit-name, handicap pulldown — is fully wired. Defaults and Start work.

## 2.8 Set civilization names — Done

Per-slot edit boxes for civ name, leader name, civ adjective, city list prefix and suffix, and (multiplayer) password. Each field is announced on focus.

## 2.9 Scenarios menu — Partial

The scenario list itself is wired: each entry exposes its display name and description, Start and Back are activatable. What is not wired is the per-scenario setup popup that opens after Start — every Firaxis scenario ships its own Custom-entry-point Lua/XML for choosing difficulty, civ (when the scenario lets you pick one, e.g., the 10-civ roster in Conquest of the New World), and any scenario-specific options. Those popups are mod-defined per scenario and currently inaccessible, so the player can pick a scenario but lands in the post-Start screen with no way to confirm or change defaults before the game launches.

## 2.10 Multiplayer game setup — Done

The host's customization panel reached from the staging room. Mirrors Advanced Setup and adds Turn Timer and Max Turns multiplayer fields.

---

# Phase 3: Core In-Game HUD

The in-game HUD is the persistent chrome around the world view: top status bar, end turn button, unit panel, minimap, notifications, advisor prompts. The mod replaces or supplements each of these with keyboard-driven equivalents rather than reading the chrome itself, so coverage shape varies by surface.

## 3.1 Top panel — Done

Bare T, R, G, H, F, P, and I read the seven empire-status numbers the panel exists for: turn and date (Maya long-form calendar where applicable, unit-supply over-cap when the maintenance mod is non-zero), current research with turns and science per turn, gold rate and total with trade-route slot use and any strategic-resource shortages, happiness state with golden age progress or active turns, faith per turn and total, culture per turn and turns to the next policy, tourism per turn with the influential-civ count (named against the denominator within two of a culture victory). The engine's "off" game options (no science, no happiness, no religion, no policies) are honored on the relevant keys. The hover tooltips that break each readout into its sources (science from buildings vs trade routes vs Great Scientist, etc.) are not separately surfaced; the headline numbers are.

## 3.2 Minimap panel — Not useful

Every control in the panel changes rendering only: the minimap image, Strategic View, the overlay dropdown (owner, religion, trade, ideology), the icon-layer dropdown, and the show-features / show-fog / show-grid / show-trade / show-yield / show-resources / hide-recommendations checkboxes all route through `UI.Set*VisibleMode`, `StrategicViewShow*`, or `SetStrategicView*` and affect nothing the engine exposes to query. The underlying data those overlays paint on the world (owner, religion, trade, ideology, resources, yields) is reached through the cursor and scanner. Strategic View's F10 has been rebound to open the advisor counsel popup.

## 3.3 Notification panel — Done

Incoming notifications are spoken as they arrive. A burst of three or more in a short window collapses to a single "N new notifications" announcement so a turn rollover doesn't bury the player. F7 opens the notification log with two tabs — Active for the live undismissed stack, Dismissed for history. Activating an entry in the Active tab fires the engine's normal click action (opens the relevant chooser, pans the camera, etc.) and rides the camera pan to drop the cursor on whatever plot the engine landed on, so notifications that point at a place put you there. Tab switches between active and dismissed.

## 3.4 End turn button and flow — Done

Ctrl+Space ends the turn. If something is blocking — a city needs production, no research is set, a unit needs orders, a policy is waiting, a religion or ideology choice is pending, a spy needs to pick a tech to steal, a Great Person is waiting on faith, a World Congress proposal or vote is open — the mod speaks the blocker name and routes the player to whatever screen resolves it. Ctrl+Shift+Space mirrors the engine's force-end (gets past unit-action blockers but no others) and announces what it cannot bypass. Multiplayer un-ready works through the same key.

The "Turn N, year" line speaks at the start of every turn including the first. Turn-end fires "Turn ended" so the state transition is audible.

## 3.5 Tech panel — Done

The current-research compact readout (icon, name, progress bar, turns remaining, banked free-tech slots) sits permanently below the top panel. The tech tree it opens and the chooser popups it triggers are both fully covered. Bare R speaks the current research with turns and science per turn (see 3.1), so the HUD readout is queryable without opening the tree.

## 3.6 Social policies and culture progress indicator — Done

The chooser popup is fully covered, and bare P speaks culture per turn and turns to the next policy (see 3.1), covering the HUD progress label without a screen open. Ideology adoption is gated through a blocking notification and the choice popup, both of which are covered.

## 3.7 Unit panel — Done

The selected-unit panel populates on selection and the mod speaks the unit's name, type, movement, strength, ranged strength, hit points, experience, and status flags (fortified, sleeping, sentry, alert, embarked, garrisoned, automated, in foreign territory). The panel auto-re-announces when selection changes; the user can re-read it manually. Cycle-next and cycle-previous work, and the unit's earned promotions can be queried.

## 3.8 Unit action panel — Done

Tab opens a menu of every action legal for the current unit on the current plot. Disabled actions are filtered out (the engine flags both "could be available" and "is available right now"; the menu only shows actions where both are true). Promotions and worker builds nest into sub-groups so the top-level list stays short. Self-plot actions (fortify, sleep, alert, build) commit immediately; targeted actions (move, attack, range strike) drop into the target-mode handler described in 4.3 and 4.4.

The most common actions are also bound to Alt+letter quick keys: Alt+F sleep-or-fortify, Alt+S sentry, Alt+W wake, Alt+H heal-fortify, Alt+P pillage, Alt+R ranged attack, Alt+Space skip turn, Alt+U upgrade. These bypass the menu when the player knows what they want.

## 3.9 Diplomacy corner — Not useful

The bottom-left persistent buttons (Diplomacy, Culture Overview, Social Policies, Espionage, Multiplayer Chat, End Game) are chrome — what matters is the screens they open. Those are reached by dedicated hotkeys, wired in separately, rather than by simulating button presses on the corner itself.

## 3.10 Info corner and sidebar lists — Not started

The five sidebar lists (City List, Unit List, Great People List, Resource List, Diplo List) are how a sighted player gets a sortable, filterable view of every owned city, every owned unit, Great Person progress, the resource ledger, and known civs. None is currently reachable. The Diplo List entry is partly covered by the Diplomacy Overview's Relations tab (Phase 7), but the four others are not addressed.

## 3.11 Tooltip layer — Done

Civ V's hex tooltip — owner, working city, terrain and feature, resource, improvement, yields, movement cost, defensive bonus, river crossings, units on the plot — is replaced rather than read. The cursor handler uses Q/A/Z/E/D/C to move a virtual cursor around the map and reads each plot on arrival. S, W, X (and 1, 2, 3) ask focused questions about the cursor tile. The surveyor cluster (Shift-letter keys) walks a radius around the cursor and reports counts, yields, or specific instances. Together these substitute for hover-driven inspection.

## 3.12 Advisor system — Done

The four themed advisors (Economic, Foreign, Military, Science) and their three popup forms (the floating in-world prompt, the brief overview popup, and the full counsel popup) are all read. The blocking advisor confirm (the "are you sure?" before a costly action) reads its body and announces both options. F10 has been rebound from Strategic View to open the counsel popup; recommendation tags on production rows are spoken when the production chooser is open.

## 3.13 Tutorial advisor banner — Done

Covered transparently by 3.12. The engine drives every tutorial message through Events.AdvisorDisplayShow into the same Advisors Context the counsel popup uses, so reading that Context covers tutorial text too. The advisor banner's Activate button (which the engine uses to "point at" a unit, plot, or follow-up popup) is wired to follow the camera with the cursor on activation. This applies both to the in-game "main game" tutorial (Tutorial_MainGame.lua, the periodic hints that fire during normal play) and to the five scripted tutorials launched from the Tutorial picker (Movement, Cities, Improvements, Combat, Diplomacy), which each ship their own TutorialInfo table in the Civilization Tutorials mod and route through the same advisor channel.

## 3.14 Task list — Not started

The task list (TaskList.lua) is a separate stack of objective strings driven by Events.TaskListUpdate from C++. Used mostly by scenarios for objective tracking ("Capture Constantinople by turn 100"); status flips between incomplete / complete / failed per task. Currently no listener and no readout key.

---

# Phase 4: World Interaction

The world is the center of the screen. Plots have terrain, features, resources, improvements, owners, and any units or city occupying them. Sighted interaction is mouse-driven. The mod replaces every world interaction with a keyboard equivalent, splitting work across the cursor (what's here), the surveyor (what's around), and the scanner (where is X).

## 4.1 Plot inspection — Done

The cursor cluster moves a virtual selection around the hex grid one tile at a time and speaks each tile on arrival: terrain, feature, river edges, resource, improvement (including pillaged state), owner, working city, units on the plot, yields. Per-tile audio cues layer on top so a fast traverse over the map produces a tactile sense of terrain mix without each tile being fully spoken (configurable from speech, speech-plus-cue, or cue-only).

## 4.2 Unit selection — Done

Selecting a unit (cursor-Enter on a plot, period to cycle to the next that needs orders, comma to cycle backward) populates the unit panel and announces the unit. Stack cycling steps through every unit on the plot. Deselection and reselection are spoken. Promotions are listed on demand.

## 4.3 Unit movement targeting — Done

After a move action commits, the cursor enters target-mode: free movement around the map with each tile inspected on arrival, Space speaks a per-mode preview (cost in movement points and turn count to reach), Enter commits, Escape cancels. The path preview uses a Lua-side A* (the engine's pathfinder isn't reachable from Lua) that ports the engine's tile-cost rules including river crossings and embark / disembark costs.

## 4.4 Attack and ranged targeting — Done

Both melee and ranged attack enter the same target-mode harness. The combat preview speaks attacker and defender strength after every modifier, expected damage in both directions, and (for air strikes) the visible interceptor count and intercept-probability warnings. City range strikes are a separate handler with the same shape — the cursor jumps to a valid target on entry, the player walks the map freely from there, Space says "out of range" or names the target, Enter commits.

## 4.5 City banners — Done

Friendly, foreign, and city-state banners are all reached through the same cursor pipeline. The plot scan announces civ owner and city name as the cursor lands. Identity (1) speaks population, defense strength, HP, capital flag, status cascade (razing, resistance, occupied, puppet, blockaded), and for city-states the trait token and friendship tier. Politics (3) speaks at-war warmonger and liberation previews, religion, and our spies stationed in that city. Development (2) is suppressed on non-team cities, matching what the banner shows a sighted player. Enter dispatches per ownership: own city opens the city screen (annex popup first when applicable), city-state opens the read-only city screen, foreign major opens diplomacy or the deal screen against a human opponent, unmet is a deliberate no-op. The banner-level fast actions a sighted player has on own cities (production icon click, eject garrison, range-strike from the banner) are reached through the city screen one hop deeper.

## 4.6 Stacked-unit cycling and unit flags — Done

Plots with multiple units expose every unit through cursor inspection (the units section reads all unit identities and counts) and through the engine's repeat-click-to-cycle behavior on the cursor's Enter activation. Strategic-view flag visibility is irrelevant — the cursor reads the underlying state directly.

## 4.7 Workable-tile overlay — Done

The 21-plot ring around a city is exposed through the city screen's Hex hub item. Each plot is reachable, speaks its yields and worked / locked / blockaded state, and supports lock and forced-work toggles plus tile purchase.

## 4.8 Worker build menu — Done

Worker actions appear in the unit action menu. Available builds are filtered by terrain, tech, and plot state. Disabled builds are omitted from the menu rather than spoken with a reason — the user gets the actionable subset directly.

## 4.9 Auto-explore and auto-worker toggles — Done

Both automation actions appear in the unit action menu when the unit type qualifies. Activating speaks a confirmation; the unit's status line then includes the automation label on every selection. The Wake action and any manual order cancel automation.

## 4.10 Route and path preview — Partial

Movement path preview uses the Lua-side Pathfinder that target-mode commits through; Space speaks MP cost, turn count, and MP remaining at end. Worker route-to (Ctrl+Shift+R, INTERFACEMODE_ROUTE_TO) reaches the same target-mode harness via the action menu and uses RoutePathfinder.findPath, which speaks tile count and total build turns. Hazards along the path (ZoC, Great Wall borders) and border-crossing implications (open-borders entry, will-declare-war on move) are folded into the MP number rather than called out, so the player gets a correct cost but not a textual warning. The BNW trade route preview is not reached — covered under Phase 8.7.

## 4.11 Other world interaction modes — Partial

The action menu routes every INTERFACEMODE_* into target-mode and the cursor's plot becomes the commit target. Real previews exist for move-to (and its same-type / all-on-plot variants), melee attack, range attack, air strike, and route-to — these speak combat damage, MP, turns, or build turns as appropriate. Every other mission-backed mode (paradrop, airlift, rebase, air sweep, nuke, embark, disembark) commits on Enter but the preview is silent ("no target here"); the player has no readout before committing and relies on the engine's legality gate to refuse illegal targets. Air sweep does not share air-strike's preview; intercept warnings (which interceptors will fire on the target tile and at what damage) are not surfaced for any air mode, including air strike. Three engine modes have <Mission>NONE — gift-tile-improvement (G&K Great General citadel-on-foreign-tile), gift-unit, and purchase-plot — and short-circuit in commitAtCursor's mission lookup; they need dedicated handlers calling the right engine API rather than the generic PUSH_MISSION path. City range attack is wired but through CivVAccess_CityRangeStrikeMode and dispatched from the city banner, not the unit action menu.

---

# Phase 5: City Management

The city screen is the densest in the game. Opening one pauses normal input and scopes interaction to the city, its workable hexes, and its choosers. The mod's city screen is built as a single hub menu with sub-handlers for each section; opening the city speaks a preamble (name, population, growth, production, all yields) and the player walks the hub by category.

## 5.1 City view entry and exit — Done

Entering speaks the preamble. Exiting (Escape) returns to the world. Next-city / previous-city cycles auto-re-announce the new city's preamble. Foreign-city read-only entry through espionage uses the same screen with write actions disabled.

## 5.2 City header readouts — Done

The preamble covers name, population, turns to next citizen (with stagnation / starvation flags), capital indicator, occupation / puppet / razing state, resistance turns remaining, We Love The King Day countdown, and city damage. F1 re-reads the preamble at any time without leaving the current sub-handler.

## 5.3 Yields panel — Done

Per-turn food (net of citizens), production, gold, science, faith, tourism, and culture are all in the preamble. The detailed source-by-source breakdown a sighted player gets on tooltip hover is not yet a separate drill-down — the aggregate number is what's read.

## 5.4 Citizen focus and workforce management — Done

The Worker Focus hub item is a radio list (Default, Food, Production, Gold, Science, Culture, Faith, Great Person). Reset Tiles, Avoid Growth toggle, and the Manual Specialist Control toggle are all reachable. Selection auto-updates and the new state speaks back.

## 5.5 Worked tiles ring — Done

The Hex hub item walks the workable ring around the city. Each tile speaks its yield, worked / unworked / locked / blockaded state, the citizen icon overlay, and (if eligible) the buy-plot cost. Activating a worked tile locks it; an unworked tile bumps a lower-priority one; a buyable tile prompts purchase confirm.

## 5.6 Unemployed citizens and specialist allocation — Done

Unemployed citizen count is in the preamble and the Specialists hub. The Specialists hub lists each building with specialist slots, slot fill state, and per-slot yield. Activation toggles assignment.

## 5.7 Buildings list — Done

The Buildings hub is a flat alphabetical list of every non-wonder building in the city. Each entry speaks name, effect summary, and (where eligible) sell refund. Activation on a sellable building pushes a confirm; non-sellable buildings (wonders and any-already-sold-this-turn) are silently inactive.

## 5.8 Great works slots and themes (BNW) — Done

The Great Works hub lists every great-work-capable building, its slot count, and what's in each slot — work name, author, era, origin civ — or whether the slot is empty. Theming bonus and tourism-per-work are spoken on the building. Swapping is initiated from the slot, which routes into the swap flow.

## 5.9 Production chooser — Done

The Production hub item opens the chooser. Tabs cover Units, Buildings, Wonders, Other (processes, league projects). Each row speaks name, per-turn cost, total cost, turns remaining at current production, and the unlocking-prereq line if not yet buildable. Construction advisor recommendations are appended where applicable. Produce Research and Produce Gold shortcuts are reachable.

## 5.10 Production queue — Done

Queue mode appends instead of replacing. Add to Queue, per-slot move-up / move-down / remove are wired. Queue order is read on demand.

## 5.11 Purchase with gold panel — Done

The gold-purchase mode of the chooser. Each row speaks gold cost and enabled / disabled state with the engine's reason on disabled. Confirmation popup is read.

## 5.12 Purchase with faith panel (G&K+) — Done

Same shape as the gold panel, filtered to faith-eligible items. Religious units, religion-specific buildings unlocked by belief, and Great People (post-Industrial) all surface here with faith cost and the unlocking belief named.

## 5.13 Buy tile panel — Done

Tile purchase is reached through the Hex hub. Eligible adjacent plots speak their cost; insufficient gold is announced; turns until next free border growth is queryable.

## 5.14 City connection, resource demand, and WLTKD — Partial

Resource-demanded and WLTKD active state surface in the preamble where present. Connected-to-capital state is not yet flagged on every preamble — a newly captured or freshly settled disconnected city should announce that fact unprompted.

## 5.15 Capture decision popup — Partial

The capture-gold announcement and the choose-disposition popup (Annex / Puppet / Raze / Liberate / View City) are read through the generic popup handler — body text and button list both speak. The detailed tradeoff summary a player needs to make this decision (current empire happiness, what razing actually destroys, what liberation gives you diplomatically) is not synthesized; the user hears the engine's tooltip text only on demand and not as a unified readout.

## 5.16 Razing, annex, and puppet state transitions — Done

Razing is started from the city screen; UnRaze and turns-until-destroyed are reachable. Annex (from puppet) is a confirm in the same place. Puppet-mode constraints (production chooser disabled, focus disabled) are honored — the disabled hub items don't appear.

## 5.17 City banner and city list quick access — Partial

Map-based banner click works through the cursor + Enter. The City List sidebar (sorted, filterable list of all cities with per-row production and range-strike shortcuts) is not reachable.

## 5.18 Rename and self-raze controls — Done

The Rename hub item edits the city name with type-and-Enter. Raze (voluntary self-raze) is a separate hub item; the engine's disabled-because-capital and disabled-because-no-razing rules apply.

## 5.19 Foreign city view (espionage scouting) — Partial

Opening through espionage uses the same screen with write actions hidden. Read-only inspection of buildings, great works, garrison, and yields works the same way it does on owned cities. Espionage-side spy management (which is the way you reach this view) is the gap, covered in Phase 10.

---

# Phase 6: Research and Progression

## 6.1 Tech chooser popup — Done

When research completes or the game starts with no tech selected, the chooser opens. Each tech row speaks name, base cost, turns at current science output, and a bullet list of what the tech unlocks (units, buildings, wonders, abilities, resource reveals). Banked free-tech slots appear at the top. The tree shortcut is reachable without committing.

## 6.2 Tech tree (full screen) — Done

The full eight-era tree is navigable as a sorted-by-era list. Each node speaks name, era, cost, current status (locked, available, current research, researched), and the same unlocks summary as the chooser. Researched nodes route to the pedia entry on activation; reachable nodes start research; banked free-tech slots are exposed at the header.

## 6.3 Research overview (TechPanel) — Partial

The HUD-side panel (current tech, progress bar, turns, free-tech indicators) duplicates the chooser data and isn't bound to its own hotkey — the player reaches the same information through the tree.

## 6.4 Tech award popup — Done

Fires on tech completion. Reads tech name, flavor quote, and unlocks. Continue dismisses. Chained awards play in sequence.

## 6.5 Free tech popup — Done

The "pick any one tech" grant popup (Great Scientist bulb, Oxford, research agreement, Liberty finisher, certain ruins). Same per-tech information shape as the chooser; Confirm commits, Close cancels without consuming the charge.

## 6.6 Social policy screen — Done

The combined policies-and-ideology screen. Header reads next-policy cost, current culture, culture per turn, turns to next, free-policies counter. Each branch (Tradition, Liberty, Honor, Piety, Aesthetics, Patronage, Commerce, Exploration, Rationalism, plus the ideology branches) is navigable; per-policy name, branch, effect, and state are spoken. Blocked-branch reasons (mutual-exclusion, era requirement, culture cost, opposing branch) are read. The branch-confirm and policy-confirm sub-popups are wired.

## 6.7 Ideology selection (BNW) — Done

The Freedom / Order / Autocracy choose-one popup. Each card speaks name, tenet-count summary, and the adoption-order bonus. A View Tenets sub-popup lists all tenets by level with effect text. The choose-confirm sub-popup is read. Subsequent tenet picks reuse the social policy screen on its ideology tab; level gating (need two L1s before L2 unlocks, etc.) is honored.

## 6.8 Great Person selection popups — Done

The Great Person reward popup (portrait, name, born-in-city, dismiss), the faith-purchase Great Person picker (cost in faith per type, confirm), the Liberty free-Great-Person picker (any of the six civilian types), and the Great Admiral home-port picker are all wired.

## 6.9 Wonder race notifications — Done

Started-by-someone-else and built-by-someone notifications speak through the regular notification path. The wonder-completion splash (own or rival) reads name, quote, effect, and dismiss. The Hermitage / Uffizi / Louvre Great Work slot assignment popup is reached.

---

# Phase 7: Diplomacy

Diplomacy is the most dialog-heavy subsystem. It runs through leader-head animations, a structured trade screen, city-state interactions, and the World Congress.

## 7.1 Leader head root — Done

The full-screen diplomacy root that opens on every contact. Title (Gandhi of India, Caesar of Rome) is read. Mood word (At War, Hostile, Guarded, Afraid, Friendly, Neutral, etc.) is spoken. The leader's spoken line — the engine-composed text that drives the whole conversation — is read on every state change. Action buttons (Discuss, Demand, Trade, War, Back) are reachable. The 3D leader head animation is not surfaced as text; the speech is what carries the conversation.

## 7.2 Discuss leader menu — Done

The Opinion / Like / Dislike / Attack / Back submenu (base game). Reads each option, speaks the AI response.

## 7.3 Discussion dialog — Done

The omnibus multi-choice dialog used for AI-initiated conversations. Up to eight contextual buttons; the button labels match the engine's per-state composition. The denounce confirm sub-popup, the AI-warns / accept-decline shapes, the demand-tribute path, and the resource-or-luxury request path all surface. The leader's response replaces the prior speech on commit.

## 7.4 Diplomacy trade screen — Done

The structured exchange screen. Both pockets (player and AI) and both tables list every tradeable item — gold lump, gold per turn, luxury and strategic resources, votes (BNW), embassy, open borders, defensive pact, research agreement, cities, peace treaty, declaration of friendship, declare-war-on / make-peace-with third parties. Each item speaks its label and any quantity. Submenus for resources, cities, and other-players are walkable. Commit row buttons (What do you want, What will you give, Make this work, End conflict, etc.) are reachable; the AI's valuation tooltip is not currently spoken. Make Deal / Cancel / Equalize / Clear table all work.

The simple-trade variant (AI-initiated single-item deals) shares this coverage.

## 7.5 Diplomacy overview — Done

The three-tab overview reached from the diplomacy corner. Relations lists every known civ with relationship status. Deals tab walks current and historic deals with full per-deal breakdown. Global Politics tab reads the cross-civ matrix one cell at a time.

## 7.6 City-state greeting popup — Done

First-contact splash. Speaks the city-state's name, type (Cultural, Maritime, Militaristic, Mercantile, Religious), initial trait, the first-meet bonus or reward, and routes to the diplomacy popup for next steps.

## 7.7 City-state diplomacy popup — Done

Status (Allied, Friend, Neutral, Afraid, Angry, At War), active quest list, current ally if any, type and personality, shared resources if allied, influence value and resting point. The action stack — Peace, Give, Pledge to Protect, Revoke, Take (bully), War, Stop Unit Spawning, Buyout — is fully wired. Gift submenu (small / medium / large gold, gift unit, gift improvement) and bully submenu (gold tribute, unit tribute) both walk; bully-confirm sub-popup is read.

## 7.8 Declare war popup — Done

The pre-declaration summary (BNW) reads who will be upset, who has pledged to protect the target, which city-states will declare war on you, which active deals will break, which trade routes will be lost. Yes / Cancel both work. The pre-BNW Generic-popup variants (declare-war-move, declare-war-range-strike, declare-war-plunder-trade-route) all surface through the generic popup path with at least body text and buttons.

## 7.9 Denunciation flow — Done

Denounce opens through the discussion dialog with a confirm sub-popup. Target's immediate response speech replaces the dialog line. Side-effects (everyone-met gets a notification, target opinion drops) surface through normal notifications.

## 7.10 Peace negotiation flow — Done

Peace is a trade-screen flow with the End Conflict commit button as the entry point. Treaty terms appear on both tables as locked items. Post-peace closing speech is read.

## 7.11 Embassy exchange — Done

Embassy is a one-way trade item in the trade screen and is reachable like any other item.

## 7.12 World Congress overview (LeagueOverview) — Not started

The full World Congress / United Nations session screen — host, member list with delegate counts, active resolutions with effects, proposed resolutions with vote-up / vote-down steppers and choice-target grids, session-phase indicator, propose button, host election — is unread. This is the only place the player can cast votes outside the simple ballot popup, and it is BNW's most important late-game system. The covered pieces around it (League Project popup, League Splash, Vote Results) are below.

## 7.13 League project popup — Done

When a World Fair, International Games, or International Space Station resolution passes, this popup describes the project. Reads name, description, per-civ contribution thresholds for Bronze / Silver / Gold, global progress, and per-tier rewards.

## 7.14 League splash — Done

The founded-or-upgraded splash. Reads the title (World Congress founded, United Nations established) and the flavor body.

## 7.15 Vote results popup — Done

Per-resolution result rows: name, enacted or failed, yes-no tallies. The Diplomatic Victory outcome row reads when applicable.

## 7.16 Diplo vote popup — Not started

The pre-BNW UN ballot and the BNW host-election / Diplomatic Victory ballot — a scrollable per-civ list of vote targets — is unread. This is distinct from in-session voting (which lives on the LeagueOverview screen, also unread); it's the dedicated single-question ballot.

## 7.17 Who's winning popup — Done

The pre-vote preview of the diplomatic-win round. Reads the projected vote count for each civ heading into the ballot.

## 7.18 Global relations — Done

Covered as a tab of 7.5.

## 7.19 Gift unit and liberate city options — Partial

Gifting a unit to a city-state is reachable through the city-state diplo popup's unit-gift submenu. Liberating a captured city is offered as one of the buttons in the capture decision popup, which surfaces through the generic popup handler — the button is announced and works, but the diplomatic-bonus preview a sighted player gets in the tooltip isn't synthesized.

## 7.20 Tribute demands between major civs — Done

The discuss / demand path on a weaker civ (or by an AI on the player) presents Give / Refuse / Counter-offer through the discussion dialog and is read.

## 7.21 Minor civ territory entry — Partial

The Yes / No "leave or stay" popup when a non-scout enters a city-state territory surfaces through the generic popup path with body and buttons. The Influence-cost number is not pulled out as a distinguishing readout.

## 7.22 Minor civ gold popup — Partial

The accept-or-decline gold-from-minor popup surfaces generically.

## 7.23 Return civilian popup — Partial

Captured-civilian return / keep popup surfaces generically.

## 7.24 Barbarian ransom popup — Partial

The pay / abandon popup for a barbarian-held civilian is read through the generic popup path. Camp-cleared splash is a dedicated handler and is fully read.

## 7.25 Trade route diplomatic implications — Not started

Trade-route opinion modifiers (active route to a civ, plundered route penalty) live in tooltip text on the leader-head mood indicator and are not surfaced.

## 7.26 Espionage-diplomacy intersection — Not started

Spy-caught reaction speeches, shared-intrigue dialog options, and the rig-election diplomatic side-effects are tied to the espionage system and inherit its lack of coverage (Phase 10).

## 7.27 Leader voice-over — Not applicable

The recorded leader voice plays automatically and does collide with screen-reader speech. The mod doesn't currently duck it. This is content rather than UI.

---

# Phase 8: Economy and Logistics

The empire-wide economic surface — gold breakdown, happiness ledger, demographics, trade routes, resource tracking — is split across several full-screen overviews reached from the top bar and diplomatic corner. Most of it is unread.

## 8.1 Economic overview shell — Not started

The two-tab shell (General Information, Happiness and Resources) is unread.

## 8.2 Economic general info tab — Not started

The two-column gold-totals-and-per-city table — treasury, net per turn, gross income, expenses, the city-by-city breakdown with per-city food / production / gold / science / culture / faith / tourism columns and a current-build cell — is unread.

## 8.3 Happiness info tab — Not started

The three-column happiness / unhappiness / resources ledger. The single most actionable place in the game for understanding why the empire is at the happiness level it's at, and the canonical "what can I trade away" list. Unread.

## 8.4 Military overview — Done

The two-table all-units roster (combat and civilian) with sortable columns (name, status, movement, max moves, strength, ranged strength) and the supply breakdown header (handicap baseline, per-city, per-population, cap, in-use, deficit penalty). Great General and Great Admiral progress meters read. Row activation jumps to the unit.

## 8.5 Demographics screen — Not started

The per-civ rank table across population, GNP, manufactured goods, crop yield, land area, soldiers, approval, literacy, life expectancy, military might. Unread.

## 8.6 Trade route overview (BNW) — Not started

The three-tab trade-route table (your routes, available, with you) with per-route yields to both sides, religion pressure direction, expiry. Unread.

## 8.7 Trade route chooser popup (BNW) — Not started

The destination picker that opens when a caravan or cargo ship needs an assignment. Unread. A blind player cannot meaningfully steer the trade-route system today: caravans build but there is no path to assign them to a destination, so they sit idle.

## 8.8 Rebase trade unit popup (BNW) — Done

The "move this caravan to a new home city" popup reads its city list and confirm.

## 8.9 Annex and puppet city popups — Partial

The puppet-to-annex popup reads its body and buttons through the generic popup path. The detail breakdown a sighted player needs (current empire unhappiness, the consequence of annex resistance) isn't synthesized.

## 8.10 Resource tracking — Not started

The Resource List sidebar (luxuries, strategics, bonuses with counts and trade status) is unread. Strategic-resource deficit — the state where units start disbanding next turn if a trade expires or a source is pillaged — is the most actionable signal in the system and is not flagged.

## 8.11 Gold income breakdown — Not started

Both surfaces — the top-panel hover tooltip aggregate and the General Info tab's expand-in-place city / trade / building rows — are unread. The science-rate penalty that triggers when treasury hits zero is the critical warning state and is not surfaced.

---

# Phase 9: Religion

Added in Gods and Kings, extended in Brave New World. Faith generation, pantheon, religion founding, enhancement, and reformation are all blocking flows and must be resolved before End Turn completes.

## 9.1 Pantheon selection popup — Done

Lists every unclaimed pantheon belief with name and effect. Yes / No / Close (defer). Deferring re-fires next turn.

## 9.2 Found religion popup — Done

The default religion name with optional rename, the pantheon belief shown read-only as the carried-over slot, and the founder-belief and follower-belief picker lists. Confirm is gated until both picks are made.

## 9.3 Enhance religion popup — Done

The enhance variant of the same screen. Existing beliefs read-only; second follower belief and enhancer belief picker.

## 9.4 Reformation popup (BNW) — Done

The reformation variant. Bonus belief picker with the smaller reformation-only pool.

## 9.5 Religion overview panel — Not started

The three-tab religion overview (Your Religion, World Religions, Beliefs) is unread. The auto-faith-purchase pulldown that controls passive faith spending is also unreached.

## 9.6 Religion display in city view — Partial

Religious buildings are correctly relabeled via the engine's religion-name substitution (a Mosque reads "Mosque of Islam" rather than bare "Mosque"). Majority religion and per-religion follower counts are reachable through the cursor's city query but are not part of the standard preamble. Pressure direction and Inquisitor block-spread state are not synthesized.

## 9.7 Missionary unit actions — Done

Spread Religion is in the action menu. Charges-remaining and religious-strength are spoken with the unit. The post-spread follower-count and majority-after preview is computed by the engine on hover; the action menu speaks the action label but not yet the predicted outcome.

## 9.8 Inquisitor unit actions — Done

Remove Heresy is in the action menu. The passive block-spread state is implicit and is not specifically called out when the Inquisitor is garrisoned.

## 9.9 Great Prophet unit actions — Done

Found / Enhance / Reformation are state-driven and only the relevant one appears in the menu. Build Holy Site and Spread Religion are always available. All three popup paths are wired.

## 9.10 Faith purchase panel — Done

Covered in 5.12.

## 9.11 Religion in diplomacy display — Partial

Civ entries in the known-civs list don't currently flag founded religion as a separate readout. The discussion option to ask another civ to stop spreading is reachable through the discussion dialog text but isn't surfaced as a distinct affordance.

---

# Phase 10: Espionage (G&K, BNW)

The entire espionage system is unread. Spies unlock at the Renaissance era and become a significant part of late-game play; for a blind player today they are invisible.

## 10.1 Espionage overview screen — Not started

The two-tab spy management screen (Overview spy roster, Intrigue intelligence log) is unread.

## 10.2 Spy assignment / relocation popup — Not started

The destination picker (own cities for counterspy, rival majors for steal / diplomat, city-states for elections / coups) is unread.

## 10.3 Intrigue discovered notifications — Not started

The eighteen distinct intrigue notification types — sneak attack alerts of varying precision, deception discoveries, wonder-construction intelligence — surface through the generic notification announce path. Their content reads but the severity gradient (an attack-against-you-known-city is the urgent one) is not flagged differently.

## 10.4 Tech stolen popup / chooser — Partial

The tech-steal chooser reuses the regular tech popup screen, which is fully covered. The triggering notification surfaces through the generic notification path. The blocking-on-end-turn behavior is honored.

## 10.5 Rigging elections result popup — Not started

The three election notifications (alert, success, failure) surface generically. The pre-election alert is the actionable one; nothing flags it as different from any other notification.

## 10.6 Coup attempt popup — Not started

The pre-commit confirm and the four result notifications surface generically. Coup odds and the displaced-ally context are present in the body text but aren't pulled out as distinguishing readouts.

## 10.7 Spy killed and spy promoted notifications — Not started

The five spy-lifecycle notifications surface generically.

## 10.8 Diplomat conversion (BNW only) — Not started

The per-spy switch-to-diplomat / switch-to-spy toggle is unreached.

## 10.9 Counterspy results — Not started

Spy-killed-a-spy notifications surface generically. The continuous counterspy kill-chance readout is unreachable.

## 10.10 Active mission status on spy rows — Not started

Reached through the espionage overview, also unread.

---

# Phase 11: Combat and Military

## 11.1 Unit panel selected-unit display — Done

Covered in 3.7.

## 11.2 Promotion chooser (inline flyout) — Done

When a promotion is available, the unit's status flag includes "promotion ready" and the Promotion sub-group of the action menu lists every eligible promotion with effect text. Activation commits.

## 11.3 Combat preview — Done

Covered in 4.4. The full modifier breakdown — over-river, amphibious, Great General adjacency, fort or citadel, empire-unhappy, strategic-resource deficit, policy bonus, golden age, city-state ally, flanking, promotions, fight-at-home, attack-in-friend-lands, support damage — composes into the spoken preview.

## 11.4 Combat resolution display — Done

There's no dedicated post-combat dialog in the engine; the mod hooks the EndCombatSim event and queues a result announcement (damage dealt and taken, kill or survive, promotion-pulse if earned). HP-bar updates on flags are irrelevant — the spoken outcome carries it.

## 11.5 Pillage confirmation — Done

The pillage confirm popup reads through the generic path with what's-being-pillaged, HP-gain, and gold-gain. Alt+P is the quick path.

## 11.6 City capture popups — Partial

Covered as 5.15.

## 11.7 Found, raze, and adjacent city prompts — Done

Founding a city has no popup; the city is created and the screen opens, both of which are covered. Raze is decided at capture time or through the city screen. The city-task confirm popup (buy tile, buy building, faith purchase) reads through generic.

## 11.8 Barbarian encounter popups — Done

Camp-cleared splash is a dedicated handler. Ransom popup reads through generic (covered in 7.24).

## 11.9 Nuke targeting mode — Not started

Entering nuke targeting from a unit's action menu commits but the blast-radius preview, the dimmed-invalid-hex set, and the war-declaration confirm-if-at-peace branch are not specifically wired. A blind player can fire a nuke but cannot inspect the valid-target set or preview the consequences.

## 11.10 Air mission interface — Partial

Air strike and air sweep target through the same target-mode harness as ground attacks. Intercept is a toggle and is reachable through the action menu. Rebase reaches a target-mode but the "valid friendly cities and carriers within rebase range" set isn't explicitly enumerated. Interceptor warnings are present in the combat preview.

## 11.11 Embarkation prompts — Partial

The first-time-this-turn embark confirm reads through generic. Embark / disembark state changes are flagged in the unit's status.

## 11.12 Naval unit special cases — Done

Naval units use the same action-menu / target-mode shape as land units. Ranged naval previews work the same way. Carrier cargo is reachable through the unit panel.

## 11.13 Military overview — Done

Covered as 8.4.

---

# Phase 12: Civilopedia and Reference Screens

## 12.1 Civilopedia screen — Done

The full reference. Categories — Game Concepts, Civilizations, Units, Buildings, Wonders, Policies, Religion (G&K+), Ideologies (BNW), Technologies, Terrain, Resources, Improvements, Great People, Eras, Worlds — are walkable; per-category article lists are walkable; article body reads with cross-reference link traversal so units, techs, buildings, resources all link to each other and to the techs / improvements / civs they relate to. Back walks the history stack.

## 12.2 Civilopedia from front-end — Done

Same screen, launched from Other → Civilopedia before any game has started. Identical coverage; Back returns to the front-end menu.

## 12.3 Demographics screen — Not started

Covered as 8.5.

## 12.4 Ranking / Info Addict graphs — Not started

The historical-score line graph and the multi-metric replay graphs (score, population, culture, gold, land, etc.) are visual by construction and are unread.

## 12.5 Victory progress screen — Not started

The "how close is everyone to each victory type" tabbed overview (domination, science, cultural, diplomatic, score) is unread. This is where a player tracks the win race in real time and is a serious gap.

## 12.6 Top 5 Cities — Not applicable

Doesn't exist as a discrete screen in shipped Civ V (Civ IV feature that didn't carry over).

## 12.7 Replay screen (post-game) — Not started

The map-history playback and per-civ graphs and message log (after-game version) is unread. The messages tab in particular is already text and would be the highest-leverage piece to surface.

## 12.8 Previous turn replay — Not applicable

Doesn't exist in shipped Civ V.

## 12.9 Hall of Fame — Not started

Covered as 1.10.

## 12.10 End game menu — Done

The endgame root with its four tabs (Game Over flavor, Demographics, Ranking, Replay) is reached and the GameOver tab is read in full — winner, victory type, the per-victory-type flavor body. Main Menu, Back (one more turn), and Beyond Earth (on science victories) are reachable. The three sub-tabs (Demographics, Ranking, Replay) inherit their not-started state from above.

---

# Phase 13: Interrupt Popups

The engine routes its sixty-nine kinds of modal popup through a single dispatcher. Each kind opens a specific screen. Coverage in this section is mostly cross-references to the screens that handle each kind.

## 13.1 Discovery and exploration popups — Done

Goody-hut splash, the BNW choose-goody-hut-reward variant, natural wonder discovery, barbarian camp cleared, and city-state first contact are all wired.

## 13.2 Production, growth, and wonder popups — Done

Production-finished and choose-production both go through the production chooser. Wonder-completed splashes (own and rival) read. Great Person reward popup reads. Liberty-style choose-Great-Person popup reads. BNW Great Work completed and Great Musician concert tour popups read. Archaeology-choice popup reads. City-name-change (founding and rename) reads.

## 13.3 Choice popups (tech, policy, religion, ideology) — Done

Choose Tech / tech tree, tech award, confirm policy, ideology choice, choose pantheon, choose religion (found / enhance / reformation), choose faith Great Person, choose Maya bonus, choose free item, set unit name, religion established announcement — all reachable.

## 13.4 Diplomacy popups (outside the leader screen) — Partial

Diplomacy dispatcher, declare-war confirm, war-state-change, opinion-change, deal-canceled, gossip (BNW), you-are-under-attack, city-state diplo, city-state quest, city-state investment, city-state gift-tile — every one of these surfaces at least through the generic popup path so the body reads and buttons announce. The dedicated handlers (declare-war, city-state diplo, leader head) carry richer coverage. The League Overview, Propose, Vote-Enact, Vote-Repeal, and ballot-style diplo-vote popups are unread.

## 13.5 Crisis and combat popups — Partial

City captured, resistance ended, barbarian ransom, confirm command, choose disband unit, unit upgrade, load / lead unit (transports), buy tile, choose city plot, espionage spy choice, coup result, rig election result — most surface generically. The unit upgrade popup with its before / after stat delta isn't specifically wired beyond the generic path.

## 13.6 Informational and milestone popups — Done

New era, generic text, notification log, alarm, confirm end turn, advanced start, civilopedia popup, map popup, in-game pause and options, league project, advisor counsel, advisor info, advisor modal — all reachable.

## 13.7 End-game trigger popups — Done

End game, civ defeated, extended game, who's winning all reach the appropriate screen.

## 13.8 Cross-cutting concerns — Done

The popup queue (multiple popups firing on the same turn rollover) plays in order; each new popup announces its identity on open. Focus handoff is handled by the handler stack — popups push above the world handler, pop on dismiss, and the handler under them takes over speech. Body text passes through the markup-stripping filter so glyph and color codes don't reach the speech engine. Choice popups all use the same item-list interaction shape (move-next, move-previous, read-current, activate, escape) so the user doesn't relearn navigation per popup.

---

# Phase 14: Endgame

## 14.1 Spaceship build screen — Not applicable

Civ V has no dedicated spaceship assembly panel; the parts are produced from city queues like any other item, and the city production chooser is covered.

## 14.2 Victory progress panel — Not started

Covered as 12.5.

## 14.3 Who is winning popup — Done

The periodic auto-firing summary that picks one of ten metrics (food, production, gold, science, culture, happiness, wonders, military might, cultural influence, top tourist cities) and reads each civ's rank in it.

## 14.4 Tourism threshold popup — Partial

Influential / Dominant transitions surface as standard notifications and read through the generic notification path. The transition from Popular to Influential is the cultural-victory trigger and is not specially flagged.

## 14.5 World Congress and UN vote flow — Partial

Vote Results reads. League Splash reads. League Project reads. The actual ballot popup (Diplo Vote) and the in-session voting screen (League Overview) are unread; both are what casts the actual votes.

## 14.6 Victory screen — Done

The win-flavor splash for each victory type (Domination, Science, Cultural, Diplomatic, Time) reads its body. Main Menu, One More Turn, and Beyond Earth (science only) are reachable.

## 14.7 Defeat screen — Done

The loss-flavor body reads. One More Turn is enabled or disabled per the engine's rules and the disabled state is honored. Hot-seat handoff to the next living human works through the same path.

## 14.8 Final scoreboard (Ranking) — Not started

The "you are comparable to historical-leader-X" score-insertion list is unread.

## 14.9 Replay / map-history playback — Not started

Covered as 12.7.

## 14.10 One more turn — Done

The button on the end game menu is reachable; activation calls the extended-game network message and drops back into play.

## 14.11 Post-game stats and demographics — Not started

Covered as 8.5 / 12.3.

## 14.12 Hall of Fame entry — Not started

Civ V doesn't pop a new-record splash at game end; the entry silently appends to the saved Hall of Fame and is read only by opening the screen from the main menu, which is also unread (1.10).

## 14.13 End-of-game event surface

The engine signals victory and defeat through a single end-game event whose type and team arguments together identify the outcome. The mod's end-game menu hook reads them off this event. Score and per-category breakdown queries are still available after the game ends, which is what makes a future demographics / ranking pass straightforward to add.

---

# Coverage summary

What the mod fully covers today: the front-end menu shell, every game-setup screen, the pause and save menus, the in-game cursor / surveyor / scanner stack for plot inspection, unit selection and the action menu, target-mode for moves and attacks, the city screen and its production / purchase / buildings / specialists / great-works / hex / rename / raze sub-handlers, the tech tree and every tech / policy / ideology / Great Person / pantheon / religion / reformation / Maya / free-item chooser, the leader head and trade screens with their full discussion / denounce / peace / embassy paths, the city-state diplomacy and greeting popups, the declare-war summary, the diplomacy overview's three tabs, every advisor popup, the notification announcement stream, the end turn flow, all production-finished and wonder-completion splashes, the natural wonder and goody hut splashes including the BNW choose-reward variant, the new era splash, the popup queue and dispatcher concerns, the military overview, the civilopedia, and the end game menu's win-or-lose splash.

What's partially covered: the city capture decision (body reads but tradeoff is not synthesized), the city status preamble (some load-bearing flags like connected-to-capital aren't on it), foreign city view (works but the espionage path that reaches it doesn't), several diplomacy mini-popups (return civilian, minor civ gold, minor civ territory entry — body and buttons through generic, no special flag), the religion overview and per-city religion display, air mission and nuke targeting, the unit upgrade preview, the embarkation prompt.

What's not started: the entire top panel and minimap toggle layer, every sidebar list (City List, Unit List, Great People List, Resource List), the diplomacy corner buttons themselves, the tutorial overlay and task list, the trade route system end to end (overview screen and chooser popup), the entire economic overview shell with its general info and happiness tabs, the demographics screen, the gold income breakdown, every espionage screen and popup, the religion overview panel, the World Congress overview screen and the diplo vote ballot popup, the victory progress screen, the in-game ranking and replay screens, the in-game and front-end hall of fame, the leaderboards, and the dedicated server panel.

The biggest gaps the player feels day to day are probably the empire-wide overviews — top panel, economic overview, happiness breakdown, resource list, victory progress — and the trade-route system in BNW. After those, the espionage system and the World Congress's full session screen are the two whole subsystems with no coverage at all.
