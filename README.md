# Civ V Access

Civ V Access is an accessibility layer for Sid Meier's Civilization V that makes the game fully playable through a screen reader.

Civilization V is a turn-based strategy game in which you take a civilization from the dawn of humanity into the space age. You wage war, conduct diplomacy, research technologies, build wonders, and compete against rival civilizations led by figures from history like Gandhi, Napoleon, and Catherine the Great. The game is completely turn based, so you can play at whatever pace suits you. The average standard game lasts 5-6 hours.

The mod requires the Brave New World expansion, and will not work without it. However, in practice it is cheaper to buy the complete bundle than it is to buy the base game plus Brave New World expansion, so I suggest you do that instead.

## Installing and updating the mod

The installer handles installing the mod, updating it, and uninstalling it. [Click here to download the installer](https://github.com/rashadnaqeeb/Civ-V-Access/raw/main/dist/installer/CivVAccessInstaller.exe).

You may wish to disable the Steam overlay, from Steam settings/in game/enable Steam overlay. This is an overlay that is inaccessible and intercepts the Shift+Tab key, and makes accessibility mods in general very difficult to use. You may also wish to disable the F12 Steam screenshot key, from the same menu, which regularly interferes with mod keys across games.

## Getting help

**Shift+/** (question mark) opens a list of every key active in the current context. If ever you're unsure of what keys will work on any given screen, start here. It's a searchable list, so you can also type the name of the action you're looking for and you'll usually find it.

**Ctrl+I** opens the Civilopedia (in-game help) entry for whatever is currently focused, when one exists. Use this if you want to look up, for example, what the current unit under the cursor does.

## Menus

Every menu in the game uses the same interface. It's quite straightforward.

- **Up / Down** — previous / next item; wraps with a click sound at the top and bottom
- **Home / End** — first / last item
- **Enter** — activate the focused item
- Sliders: Left/Right to adjust by single increments, Shift+Left/Right to adjust by larger increments
- Submenus: indicated by a blip sound. Use Right arrow to drill in, and Left arrow to drill out
- **Tab / Shift+Tab** — next / previous tab on tabbed screens
- **F1** — re-read the menu's description; also used to read back spoken dialogue
- Type ahead: every menu in the mod supports searching using type ahead. Simply start typing and you will be matched as you type. You can use Up/Down arrow to scroll through results

**F12** opens mod settings, where you can turn off increased menu verbosity if you prefer.

## In-game controls

Let's address the elephant in the room first.

### Why can't I use arrow keys on this map?

Civilization V uses hexagon tiles instead of square tiles. A hexagon is a six-sided shape, so each tile has six neighbors that you can choose to move to.

If you've played audiogames like Tactical Battle or Castaways, you've used square grids. Squares have four neighbors. Arrow keys handle that naturally.

Hexagons have six directions, and six doesn't fit the arrow key layout. So this mod uses six different keys: Q, A, Z on the left side, to move northwest, west, and southwest, and E, D, C on the right side, to move northeast, east, and southeast. The S key is the center. It represents where you currently are. Press one of the other six keys to move in that direction.

The numpad mirrors this cluster, with 5 in the center as S.

Two things will feel strange at first.

1. Hexes don't have a "straight north" or "straight south" direction. You cannot move directly up or down in a single step. To travel directly north, you have to travel northeast, then northwest, bringing you two tiles north of where you started.

2. If instead you move northeast, then southeast, you've actually traveled only one tile east, and one press of A will bring you back to where you started.

This is all you need to know to play, but if you're interested in understanding why this is the case, you can read the next section.

#### The math

A square tile only has four neighbors, the ones sharing an edge with it. If everything only ever happened in straight lines, this would be fine. But the second you start introducing diagonals into the mix, things start to fall apart.

Imagine an archer that can shoot 5 tiles away. Can it hit a target 4 tiles directly north? Yes, 4 is less than 5. Can it hit a target 4 tiles northeast? Your intuition says yes, but the math (and our old friend Pythagoras) says that target is actually 5.66 units away (4 squared plus 4 squared equals 32, and the square root of 32 is approximately 5.66).

The inconsistency gets worse as distances increase, and it gets harder and harder to understand how movement and combat will work. Strategy game designers solved this by introducing hex grids, where all six directions are exactly equidistant, with no weird corner interactions.

The catch is that hex directions don't match compass directions. On a compass, northeast is 45 degrees east of north, halfway between them. On a hex grid, northeast is only 30 degrees east of north, much closer to north than to east. The names are borrowed from the compass but describe different angles, and this mismatch is why new players constantly expect moves to go somewhere else.

Picture the six directions on a clock face. East is 3 o'clock, west is 9 o'clock. The four hex diagonals are at the remaining odd hours: northeast at 1, southeast at 5, southwest at 7, northwest at 11. There's no 12 or 6. Due north and south don't exist as single steps. Each direction is 60 degrees from the next.

Now, here's the confusing part. Imagine starting at the center of the clock face. When you move northeast then northwest, you're moving from 1 o'clock to 11 o'clock, barely moving around the clock at all, just trading one side for the other while staying near the top. Your north movements stack up, and your side-to-side movements cancel out, leaving you two tiles north. When you move northeast then southeast, you're moving from 1 o'clock to 5 o'clock, moving much farther around the clock. Your east movements stack up, and your up-and-down movements cancel out, but since you're traveling across so much of the clock, you only end up one tile east.

This mod tries to make it easier to visualize by breaking the x (horizontal) coordinate into half steps. Let's imagine we're at 0, 0. Moving northeast brings us to 0.5, 1. Southeast would then bring us to 1, 0. West from here would bring us back to 0, 0. Now let's do the northwest/northeast case. Northwest brings us to -0.5, 1. Then northeast brings us to 0, 2.

### The cursor

The cursor is your position on the map, independent of any selected unit. Movement keys (Q, A, Z, E, D, C, or the numpad equivalents) step it one hex at a time, and each move announces what's on the new hex: terrain, ownership, units, improvements, and so on.

- **S** — read the units on the current tile
- **W** — read the tile's yield
- **X** — read the tile's movement and combat modifiers
- **1** — on a city tile, read its identity and combat stats
- **2** — on a city tile, read its production and growth
- **3** — on a city tile, read its religion
- **4** — on a city tile, read its diplomatic notes
- **Enter** — activate the tile (open a city you own, open diplomacy with a foreign capital, attack with a selected unit, or pick from multiple units on the tile)
- **Shift+S** — coordinates relative to your capital
- **Ctrl+S** — jump the cursor to your capital

### The surveyor

The surveyor answers questions about a circle around the cursor: how many sheep are nearby, how many enemy units are within striking range, where the closest city is. Use it to scout an area before founding a city or to check threats around an exposed unit. All keys use Shift plus a cluster key, and the numpad works as a substitute here too, though it's worth noting that NVDA may interfere with Shift+Numpad keys.

- **Shift+W / Shift+X** (or **Shift+Numpad 8 / Shift+Numpad 2**) — grow or shrink the scanned radius (1-5)
- **Shift+Q** (or **Shift+Numpad 7**) — sum yields of all tiles in range
- **Shift+A** (or **Shift+Numpad 4**) — count resources in range
- **Shift+Z** (or **Shift+Numpad 1**) — count terrain and features in range
- **Shift+E** (or **Shift+Numpad 9**) — list your own units in range
- **Shift+D** (or **Shift+Numpad 6**) — list enemy units in range
- **Shift+C** (or **Shift+Numpad 3**) — list cities in range, closest first

### The scanner

Where the surveyor is for figuring out what's around you, the scanner is for finding a specific thing. You'd use it to figure out where to find Iron on your map, for example, or where the city of London is.

Entries are organized into a hierarchy of categories (cities, units, resources, terrain, and so on), subcategories (your cities versus enemy, strategic versus luxury resources), items, and instances (multiple iron deposits all called "iron"). If you've used the Rimworld scanner, it's laid out exactly the same.

- **Ctrl+PageUp / Ctrl+PageDown** — cycle categories
- **Shift+PageUp / Shift+PageDown** — cycle subcategories
- **PageUp / PageDown** — cycle items within a subcategory
- **Alt+PageUp / Alt+PageDown** — cycle instances of the same item
- **Home** — jump the cursor to the current entry
- **Backspace** — return the cursor to its position before the jump
- **End** — repeat distance and direction from the cursor
- **Ctrl+F** — search all scanner entries by name

Each entry is announced with its exact hex distance and direction from the cursor.

### Bookmarks

Bookmarks are ten saved cursor positions, one per number key. They survive saves and reloads.

- **Ctrl+1-0** — save the cursor's current position to that slot
- **Shift+1-0** — jump the cursor to the saved location (Backspace returns)
- **Alt+1-0** — speak distance and direction from the cursor to the saved location

#### Beacons

Beacons turn a bookmark into a spatial-audio marker. While active, a looping sound plays from the bookmark's location with the cursor as listener: pan tells you east versus west, pitch tells you north versus south, volume tells you how close (silent past about 30 hexes).

- **Ctrl+Shift+1-0** — toggle the beacon for that bookmark slot

## Units

Units are everything you move and command: workers, settlers, scouts, warriors, and so on. Every game starts you with a Warrior and a Settler.

### Selecting a unit

- **Period (.) / Comma (,)** — cycle to the next or previous unit that still needs orders
- **Ctrl+Period / Ctrl+Comma** — cycle through every unit you own, including those done for the turn
- **Enter** on a tile — select a unit there (picker opens if multiple)
- **Ctrl+Slash** — recenter the cursor on the selected unit
- **Slash** — read the selected unit's info: type, hit points, moves left, promotions, special abilities

### Action menu

**Tab** opens the action menu, a list of every action the selected unit can do right now. Only available actions appear.

Alt-letter shortcuts skip the menu for common actions:

- **Alt+S** (or **Alt+Numpad 5**) — fortify a military unit, or sleep a civilian
- **Alt+F** — sentry (sleep until an enemy comes into sight)
- **Alt+W** (or **Alt+Numpad 8**) — wake a sleeping unit, or cancel a queued move or automation
- **Alt+X** (or **Alt+Numpad 2**) — skip the unit's turn
- **Alt+H** — heal until full
- **Alt+P** — pillage the current tile
- **Alt+U** — upgrade
- **Alt+N** — rename
- **Alt+M** — move to a target
- **Alt+R** — ranged attack

### Movement

**Alt** plus a movement key (Q, A, Z, E, D, C, or the numpad equivalents) moves the selected unit one hex in that direction. The mod tells you where you ended up and how many moves remain, or why the move was refused.

If the target hex has an enemy, the first press speaks a combat preview. The second press commits the attack.

### Target mode

If instead of using the quick movement keys you choose move to from the action menu, or press Alt+M, you will be placed in targeting mode.

- **Space** — preview the move from the unit to the cursor (path, cost, turns to arrive); on an enemy, previews the combat result instead
- **Enter** — commit
- **Shift+Enter** — queue the move so the unit keeps walking across turns

Target mode is also used by Alt+R ranged attacks and any action menu item that needs a target (airstrikes, nuking things, and so on). In that case Space provides relevant previews for the selected mode.

## Empire status keys

These keys are used to get quick status updates about your empire. All this information is available in menu form on various screens, if you prefer.

- **T** — turn and date
- **R** — current research status
- **G** — gold per turn, treasury total, trade routes in use
- **H** — happiness and golden-age state, luxury inventory
- **F** — faith per turn and total
- **P** — culture per turn and turns to next policy
- **I** — tourism per turn and influential-civ count

All of these keys can be combined with Shift to receive a per-source breakdown, though it may be easier to parse from within various menus, rather than as a single block.

## Notifications and the message buffer

The game has a notification panel, accessible with F7. You should check it regularly. Additionally, if you hit Tab on that screen, you will find a turn log, kept by the mod, summarising what happened on the last turn, specifically any combat that took place and any units that have entered or exited tiles you can see on the map.

All these messages are further collected into a buffer, accessible with left and right brackets, for quick review. Multiplayer chat messages are also logged here.

- **[** / **]** — previous / next message in the buffer
- **Ctrl+[** / **Ctrl+]** — oldest / newest message
- **Shift+[** / **Shift+]** — apply a filter

The buffer resets when you load a game.

## Ending your turn

- **Ctrl+Space** — end the current turn. If something still wants attention, the mod announces what and opens the matching screen.
- **Ctrl+Shift+Space** — end the turn even if you have unmoved units.

## Tables

Several screens present data as a table of rows and columns, like the city list on F2 or the unit list on F3. Arrow keys move between cells. The row above row 1 is a header row, and pressing Enter on a column header cycles its sort, which is how you resort the table by a different column. For example, on the F2 city table you can sort by the production column to see your cities ordered from highest output to lowest, or by the food column to find the city that's losing food fastest. Type-ahead matches against whole rows, not individual cells.

## Game screens

These keys open the in-game screens. The screens themselves are regular menus or tables.

- **F1** — Civilopedia: the in-game wiki, with strategy tips and a reference for everything in the game. If you have a game mechanics question, the answer is probably in here somewhere.
- **F2** — Economic Overview. 4 tabs: a table of all your cities, a treasury breakdown, a happiness breakdown, and a list of accessible resources.
- **F3** — Military Overview. 2 tabs: a table of all your units, and a list of progress toward each great person type.
- **F4** — Diplomacy. 3 tabs: major civs, city-states, and current deals (active and historical).
- **F5** — Social Policies. 2 tabs: social policies, and, later in the game, ideologies.
- **F6** — Tech Tree. Science happens here. Space switches between grid view (default) and a tree view that walks the prerequisite graph. Tab switches to the research queue.
- **F7** — Notifications. 2 tabs: active notifications, and a turn log summarising the previous turn.
- **F8** — Victory Progress. 2 tabs: a score table, and a breakdown of progress toward each victory condition.
- **F9** — Demographics. A mostly flavour screen for getting a sense of how well you're doing.
- **F10** — Advisors. One tab per advisor, 4 in total. They're not very good.
- **F12** — Mod settings.
- **Ctrl+C** — Culture Overview. 4 tabs: placing great works in your own buildings, swapping great works with other civs, progress toward a cultural victory, and tourism influence between civs (use the left column to change perspectives).
- **Ctrl+T** — Trade Route Overview. 3 tabs: your active routes, routes you can establish, and routes other civs have running with you.
- **Ctrl+R** — Religion Overview. 3 tabs: your own religion, the spread of all religions, and the beliefs each religion has taken.
- **Ctrl+L** — World Congress. 3 tabs: league status (host, members, delegates), proposals to make and vote on, and active effects.
- **Ctrl+E** — Espionage Overview. 3 tabs: managing your spies, city status and spying potential, and a log of intrigue learned over the course of the game.
- **Backslash** — Multiplayer chat panel.
- **Esc** — Game menu (save, load, options, quit).

## Trade and negotiation

When you initiate a trade or other negotiation with another civilisation, or one of them initiates with you, you land on a screen with two buttons: **your offer** and **their offer**. Your offer is what you're giving away. Their offer is what they're giving you.

Pressing either button opens a two-tab screen. The first tab lists what's currently on the table for that side. The second tab, **available**, lists everything that side could put on the table; much of it is gated by technology, and the tooltip on each entry explains the gating.

Below the two offer buttons sits a balance button that asks the AI to make the deal fair. Its label changes with context, things like "what would you give me for this", "what would make this deal work", or "what do you want for this", but they're all the same button. Pressing it locks the deal as read-only and applies the AI's proposed adjustment.

When the AI initiates the deal, the available tab is locked from the start. You can still open both offer buttons to read what's on each side, but you can only accept or decline; you can't change the terms.

At any point while you're talking to a leader, **F2** speaks their full description. Note that these descriptions were generated by AI using still images of the animated leader scenes, so are not perfect.

## Multiplayer

Civ V supports both hotseat (passing one computer back and forth) and networked multiplayer.

**Hotseat.** Press **Ctrl+Shift+F12** to pause the mod when the sighted player takes their turn, and again to resume for yours.

**Networked play.** Hosting on your local network just works. On Steam's public matchmaking, regional filters can hide games hosted by friends in other regions; the workaround is to host the game yourself and invite friends through your Steam friends list, which bypasses the filter.

If you want to play online with sighted friends, they must run the mod installer on their machine and choose "As a sighted player who plays multiplayer against a blind user". This installs the minimum needed for their game to match yours; no speech code runs on their side.

## Tips and tricks

A few habits and settings that aren't obvious but make the game noticeably smoother.

- **Search the tech tree by what it unlocks.** On the **F6** tech tree, type-ahead matches both tech names and the things each tech makes available, so you can often just type the name of the unit, building, or wonder you're after and land on the tech that unlocks it. It's not perfect, but it usually works. And if you press Enter on a tech you don't have the prereqs for yet, the game queues all the missing prerequisites ahead of it for you automatically.
- **Turn off subtitle reading if you prefer.** A few screens (the opening cinematic, leader dialogue, advisor intros) have the screen reader speak their text over the engine's own narration audio. If you'd rather hear the narration alone, turn off **Read subtitles** in **F12** settings, under the UI settings group. **F1** reads any spoken text back regardless of the setting, so you can still have text read back on demand. This is especially useful for advisor dialogues where the advisors often only speak a part of what's on screen.
- **Name your units.** **Alt+N** opens a rename prompt for the selected unit. The new name reads back whenever you cycle to that unit, and the unit becomes findable by name in the scanner with **Ctrl+F**. Useful for tracking units over time, especially if you've sent them off on long moves and forgotten about them.
- **Unit selection behavior.** Two related annoyances have separate settings. If you don't want the cursor jumping to a unit when you select it or after it finishes a move, turn off **Cursor follows selected unit** in **F12** settings, under the Cursor group. Separately, the game itself auto-cycles to the next unit after you issue an order; that's a vanilla setting called **Auto Unit Cycle**, found in the game's Options, on the Interface tab.
- **Sort any table.** Arrow up to the header row above row 1 and press **Enter** on the column you want to sort by. Repeated presses cycle descending, ascending, and back to default. On the **F4** Diplomacy table, for instance, you can sort by the Score column to see leaders ranked from highest score to lowest.
- **Press Enter on table rows as a shortcut.** On the **F2** city table, Enter on most cells sends the cursor to that city, and Enter on the Production cell opens that city's production picker directly — by far the fastest way to change what a city is building. The **F3** unit table works similarly: Enter on any row jumps the cursor to that unit and selects it for you.
- **Try Ctrl+I almost anywhere.** Most everything in this game has a Civilopedia entry, including individual cells in tables. **Ctrl+I** on a column header, a resource cell, a leader row, or whatever else is focused usually opens the article for it, even in places you wouldn't expect the binding to work.
- **Switch cultural perspectives.** On a cultural-victory run, the fourth tab of the **Ctrl+C** Culture Overview lets you change perspective using the left column. Each entry repivots the table to show that civ's tourism influence on every other civ, which is how you find out who else is close to a cultural win.

## Troubleshooting

If you hit a bug or a crash, please zip the log folder at `%USERPROFILE%\Documents\My Games\Sid Meier's Civilization 5\Logs\` and send it to me with a brief description of what happened.

## Credits

- **aaronr7734** — His work on Rimworld Access, and my shameless copying of it, is a big part of why this mod is at all fun to play. Who knows, maybe next time I'll name a setting after him too.
- **Lord Lundin** — Originally started the mod and gracefully allowed me to take over his work.
- **Austin Hicks (ahicks)** — My mods continue to be inspired by the example of Factorio Access. His new project, Seentell, helped provide the descriptions for the opening cinematic.
- **Brad Renshaw (chaosbringer216)** — For suffering through my endless complaining about mod-related problems and somehow parsing them into good ideas. And also for telling me to make everything a table. He was right!
- **Keltosh_** — Kind enough to teach me about audio and sound design while tolerating my horrible French.
