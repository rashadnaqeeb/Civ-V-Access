# Civ V Access

Civ V Access is an accessibility layer for Sid Meier's Civilization V that makes the game fully playable through a screen reader. You get the same game a sighted player gets: every screen, every option, every event on the map, all reachable through speech.

Civilization V is a turn-based strategy game in which you take a civilization from the dawn of humanity into the space age. You wage war, conduct diplomacy, research technologies, build wonders, and compete against rival civilizations led by figures from history like Gandhi, Napoleon, and Catherine the Great. Combat plays out on a hex grid, city-states sit between the major civilizations as a third diplomatic axis, and there is no time pressure within a turn. A full game runs fifteen to forty hours.

The mod requires the Brave New World expansion.

## Installing and updating the mod

TBD. The installer is not yet written; this section will cover where to download the mod, how to run the installer, and how to update to a new version once that flow exists.

## Getting help

**Shift+/** (question mark) opens a list of every key active in the current context. The list itself is a regular menu: type-ahead search, Up/Down to navigate, Esc to close.

**Ctrl+I** opens the Civilopedia entry for whatever is currently focused, when one exists.

## Menus

Every menu in the game uses the same interface. When a menu opens, you hear a description of it, then the first item on the list.

- **Up / Down** -- previous / next item; wraps with a click sound at the top and bottom
- **Home / End** -- first / last item
- **Enter / Space** -- activate the focused item, or drill into a submenu
- **Right** -- drill into a submenu, or adjust a slider
- **Left** -- step out one level, or adjust a slider
- **Shift+Left / Shift+Right** -- adjust a slider in larger steps
- **Ctrl+Up / Ctrl+Down** -- jump between groups of items
- **Tab / Shift+Tab** -- next / previous tab on tabbed screens
- **F1** -- re-read the menu's description; also reads spoken dialogue through your screen reader
- **A-Z, 0-9** -- type-ahead search within the current list
- **Esc** -- close the menu (closes every level at once if you've drilled in)

A short blip plays when the focused item has a submenu, so you know Right will drill into it.

## Why can't I use arrow keys on this map?

After starting a new game, you find yourself on the world map. This is where you'll spend most of your time, moving units, exploring, founding cities, and fighting battles. The first thing you'll notice is that arrow keys don't move anything on it.

Civilization V uses hexagon tiles instead of square tiles. A hexagon is a six-sided shape, so each tile has six neighbors that you can choose to move to.

If you've played audiogames like Tactical Battle or Castaways, you've used square grids. Squares have four neighbors. Arrow keys handle that naturally.

Hexagons have six directions, and six doesn't fit the arrow key layout. So this mod uses six different keys: Q, A, Z on the left side, to move northwest, west, and southwest, and E, D, C on the right side, to move northeast, east, and southeast. The S key is the center. It represents where you currently are. Press one of the other six keys to move in that direction.

Two things will feel strange at first.

1. Hexes don't have a "straight north" or "straight south" direction. You cannot move directly up or down in a single step. To travel directly north, you have to travel northeast, then northwest, bringing you two tiles north of where you started.

2. If instead you move northeast, then southeast, you've actually traveled only one tile east, and one press of A will bring you back to where you started.

This is all you need to know to play, but if you're interested in understanding why this is the case, you can read the next section.

## The math

A square tile only has four neighbors, the ones sharing an edge with it. If everything only ever happened in straight lines, this would be fine. But the second you start introducing diagonals into the mix, things start to fall apart.

Imagine an archer that can shoot 5 tiles away. Can it hit a target 4 tiles directly north? Yes, 4 is less than 5. Can it hit a target 4 tiles northeast? Your intuition says yes, but the math (and our old friend Pythagoras) says that target is actually 5.66 units away (4 squared plus 4 squared equals 32, and the square root of 32 is approximately 5.66).

The inconsistency gets worse as distances increase, and it gets harder and harder to understand how movement and combat will work. Strategy game designers solved this by introducing hex grids, where all six directions are exactly equidistant, with no weird corner interactions.

The catch is that hex directions don't match compass directions. On a compass, northeast is 45 degrees east of north, halfway between them. On a hex grid, northeast is only 30 degrees east of north, much closer to north than to east. The names are borrowed from the compass but describe different angles, and this mismatch is why new players constantly expect moves to go somewhere else.

Picture the six directions on a clock face. East is 3 o'clock, west is 9 o'clock. The four hex diagonals are at the remaining odd hours: northeast at 1, southeast at 5, southwest at 7, northwest at 11. There's no 12 or 6. Due north and south don't exist as single steps. Each direction is 60 degrees from the next.

Now, here's the confusing part. Imagine starting at the center of the clock face. When you move northeast then northwest, you're moving from 1 o'clock to 11 o'clock, barely moving around the clock at all, just trading one side for the other while staying near the top. Your north movements stack up, and your side-to-side movements cancel out, leaving you two tiles north. When you move northeast then southeast, you're moving from 1 o'clock to 5 o'clock, moving much farther around the clock. Your east movements stack up, and your up-and-down movements cancel out, but since you're traveling across so much of the clock, you only end up one tile east.

This mod tries to make it easier to visualize by breaking the x (horizontal) coordinate into half steps. Let's imagine we're at 0, 0. Moving northeast brings us to 0.5, 1. Southeast would then bring us to 1, 0. West from here would bring us back to 0, 0. Now let's do the northwest/northeast case. Northwest brings us to -0.5, 1. Then northeast brings us to 0, 2.

## The cursor

The cursor is your position on the map, independent of any selected unit. Movement keys (Q, A, Z, E, D, C) step it one hex at a time, and each move announces what's on the new hex: terrain, ownership, units, improvements, and so on.

- **S** -- read the units on the current tile
- **W** -- read economic info (yields, what's being worked)
- **X** -- read combat info
- **1** -- on a city tile, read its identity and combat stats
- **2** -- on a city tile, read its production and growth
- **3** -- on a city tile, read its religion
- **4** -- on a city tile, read its diplomatic notes
- **Enter** -- activate the tile (open a city you own, open diplomacy with a foreign capital, attack with a selected unit, or pick from multiple units on the tile)
- **Shift+S** -- coordinates relative to your capital
- **Ctrl+S** -- jump the cursor to your capital
- **Ctrl+I** -- open the Civilopedia entry for whatever's on the tile

## The surveyor

The surveyor answers questions about a circle around the cursor: how many sheep are nearby, how many enemy units are within striking range, where the closest city is. Use it to scout an area before founding a city, to check threats around an exposed unit, or to monitor your borders.

- **Shift+W / Shift+X** -- grow or shrink the radius (1-5)
- **Shift+Q** -- sum yields in range
- **Shift+A** -- count resources in range
- **Shift+Z** -- count terrain and features in range
- **Shift+E** -- list your own units in range
- **Shift+D** -- list enemy units in range
- **Shift+C** -- list cities in range, closest first

## The scanner

The scanner finds a specific thing on the map: the city of Madrid, an iron deposit, the enemy frigate someone said was near your coast.

Entries are organized into a hierarchy of categories (cities, units, resources, terrain, and so on), subcategories (your cities versus enemy, strategic versus luxury resources), items, and instances (multiple iron deposits all called "iron").

- **PageUp / PageDown** -- cycle items within a subcategory
- **Shift+PageUp / Shift+PageDown** -- cycle subcategories
- **Ctrl+PageUp / Ctrl+PageDown** -- cycle categories
- **Alt+PageUp / Alt+PageDown** -- cycle instances of the same item
- **Home** -- jump the cursor to the current entry
- **Backspace** -- return the cursor to its position before the jump
- **End** -- repeat distance and direction from the cursor
- **Shift+End** -- toggle auto-jump (cursor follows every entry as you cycle)
- **Ctrl+F** -- search all scanner entries by name

Each entry is announced with its distance and direction from the cursor.

## Bookmarks

Bookmarks are ten saved cursor positions, one per number key. They survive saves and reloads.

- **Ctrl+1-0** -- save the cursor's current position to that slot
- **Shift+1-0** -- jump the cursor to the saved location (Backspace returns)
- **Alt+1-0** -- speak distance and direction from the cursor to the saved location

## Beacons

Beacons turn a bookmark into a spatial-audio marker. While active, a looping sound plays from the bookmark's location with the cursor as listener: pan tells you east versus west, pitch tells you north versus south, volume tells you how close (silent past about 30 hexes). Multiple beacons can be active at once.

- **Ctrl+Shift+1-0** -- toggle the beacon for that bookmark slot

## Units

Units are everything you move and command: workers, settlers, scouts, warriors, and so on. You start with two and build more from your cities.

### Selecting a unit

- **Period (.) / Comma (,)** -- cycle to the next or previous unit that still needs orders
- **Ctrl+Period / Ctrl+Comma** -- cycle through every unit you own, including those done for the turn
- **Enter** on a tile -- select a unit there (picker opens if multiple)
- **Ctrl+Slash** -- recenter the cursor on the selected unit
- **Slash** -- read the selected unit's info: type, hit points, moves left, promotions, special abilities

### Action menu

**Tab** opens the action menu, a list of every action the selected unit can do right now. Only available actions appear. Use the standard menu keys to navigate; Enter commits.

Alt-letter shortcuts skip the menu for common actions:

- **Alt+S** -- fortify a military unit, or sleep a civilian
- **Alt+F** -- sentry (sleep until an enemy comes into sight)
- **Alt+W** -- wake a sleeping unit, or cancel a queued move or automation
- **Alt+X** -- skip the unit's turn
- **Alt+H** -- heal until full
- **Alt+P** -- pillage the current tile
- **Alt+U** -- upgrade
- **Alt+N** -- rename
- **Alt+M** -- move to a target (target mode, below)
- **Alt+R** -- ranged attack (target mode, below)

### Movement

**Alt** plus a movement key (Q, A, Z, E, D, C) moves the selected unit one hex in that direction. The mod tells you where you ended up and how many moves remain, or why the move was refused.

If the target hex has an enemy, the first press speaks a combat preview. The second press commits the attack. Two presses prevent accidental attacks.

### Target mode

**Alt+M** (or "Move to" from the action menu) opens target mode. The cursor acts as your aim; cursor, surveyor, and scanner queries still work normally.

- **Space** -- preview the move from the unit to the cursor (path, cost, turns to arrive)
- **Enter** -- commit
- **Shift+Enter** -- queue the move so the unit keeps walking across turns
- **Esc** -- cancel
- **Tab** -- reopen the action menu to pick a different action

The pathfinder routes around obstacles. Unrevealed terrain costs full turns to cross since the unit can't see ahead.

Target mode is also used by Alt+R ranged attacks and any action menu item that needs a target (airlift, paradrop, gift unit, and so on).

## Empire status

These keys read one slice of your empire in a single press. Shift+letter (where present) gives a per-source breakdown.

- **T** -- turn and date; appends unit-supply over-cap and strategic-resource shortages when applicable
- **R** -- current research, turns to completion, science per turn
- **Shift+R** -- per-source science breakdown
- **G** -- gold per turn, treasury total, trade routes in use
- **Shift+G** -- per-source gold income and expenses
- **H** -- happiness and golden-age state, luxury inventory
- **Shift+H** -- happiness and golden-age breakdown
- **F** -- faith per turn and total
- **Shift+F** -- faith breakdown
- **P** -- culture per turn and turns to next policy
- **Shift+P** -- culture breakdown
- **I** -- tourism per turn and influential-civ count
- **Shift+I** -- tourism breakdown
- **Shift+T** -- read active scenario tasks (silent if none)

## Notifications and the message buffer

Engine notifications (research done, city captured, foreign actions, and so on) are announced as they arrive. The mod also keeps a scrollable history of those announcements, navigable with the bracket keys.

- **[** / **]** -- previous / next message in the buffer
- **Ctrl+[** / **Ctrl+]** -- oldest / newest message
- **Shift+[** / **Shift+]** -- cycle the filter (all, notifications, reveals, combat, chat)

The buffer resets when you load a game.

## Ending your turn

- **Ctrl+Space** -- end the current turn. If something still wants attention, the mod announces what and opens the matching screen.
- **Ctrl+Shift+Space** -- force-end the turn, ending it even with pending blockers.

In multiplayer, Ctrl+Space submits to the turn wave; "Waiting for players" plays until everyone is done. Pressing Ctrl+Space again before the wave completes un-readies you.

## Opening screens and menus

These keys open the in-game screens. The screens themselves are regular menus.

- **F1** -- Civilopedia
- **F2** -- Economic Advisor
- **F3** -- Military Advisor
- **F4** -- Diplomacy Advisor
- **F5** -- Social Policies
- **F6** -- Tech Tree
- **F7** -- Turn and event log
- **F8** -- Victory Progress
- **F9** -- Demographics
- **F10** -- Advisor Counsel
- **F12** -- Mod settings
- **Ctrl+C** -- Culture Overview
- **Ctrl+T** -- Trade Route Overview
- **Ctrl+R** -- Religion Overview
- **Ctrl+L** -- World Congress
- **Ctrl+E** -- Espionage Overview
- **Backslash** -- Multiplayer chat panel
- **Esc** -- Game menu (save, load, options, quit)

## Troubleshooting

If you hit a bug or a crash, please zip the log folder at `%USERPROFILE%\Documents\My Games\Sid Meier's Civilization 5\Logs\` and send it to me with a brief description of what happened.

## Credits

TBD.
