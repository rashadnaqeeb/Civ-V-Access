# Changelog

All notable changes to Civ V Access are recorded here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The installer parses this file to show players the entries between the version
they had installed and the one they are updating to. Each version section must
start with `## [X.Y.Z] - YYYY-MM-DD` on its own line for the parser to find it.

## [Unreleased]

New Features and improvements:
- Alt+Home and Alt+End jump to the first or last section when reviewing an item with Alt+Up and Alt+Down.
- Removed the scanner's Ctrl+arrow direction scope.
- Vox Populi and Community Patch support now tracks Vox Populi 5.4.2.
- Under Vox Populi, Shift+R and Shift+P read the tech and policy cost breakdowns, including what one more city would add.
- Ctrl+N names the landmass or ocean at the cursor; the name is spoken when the cursor crosses onto it and replaces "Landmass N" in the scanner.
- When exploration shows two named masses were one all along, the older name wins and the merge is announced once.
- In the F2 city table, Production is now the last column, after Resource Demanded.

Bug fixes:
- Fighters, bombers, missiles and nukes now appear under Air in the scanner instead of Civilian.
- Reading one of your aircraft now includes its level and experience.
- Enter on a carrier or an air-stocked city lists aircraft with your military units instead of after your civilians.
- In LekMod, chariot archers, keshiks, war elephants, camel archers, paratroopers and XCOM squads now appear in the scanner's unit categories.
- Shift+R no longer lists a City-State science bonus that was a percentage, not per-turn science.
- The staging room player list now updates as soon as a player is kicked or disconnects.
- Typed search in the scanner and the Civilopedia with Ctrl+F now follows the keyboard layout, so accented and non-Latin characters work.
- Typing into a text field no longer triggers the help or settings overlays.
- Text fields release keyboard focus when editing ends, so stray typing can no longer scramble a scanner category or squad name.

## [2.2.1] - 2026-07-25

New Features and improvements:
- J, K, and L cycle through the first, second, and third custom scanner categories as one nearest-first list; Shift cycles backwards. Custom scanner categories are sorted alphabetically, which should help you properly place what you want on each key.
- M jumps the cursor to the current scanner entry, same as Home, to allow working these new keys with one hand.
- A new setting groups named units with unnamed units of their type in the scanner; for example a warrior named bob can be grouped with all other warriors rather than kept separate as it is today.

Bug fixes:
- The F2 Happiness tab under Vox Populi now reads the real happiness totals and source breakdowns instead of junk numbers.

## [2.2.0] - 2026-07-17

New Features and improvements:
- The F2 city table has a new Demand column: the resource the city demands, or the We Love the King Day turns remaining.
- New setting groups the scanner's cities by civilization: each civ becomes one entry and Alt+PageUp/Down steps through its cities.
- The F3 unit list has a new Hit Points column next to Strength.
- Civilopedia Ctrl+F results now speak the sentence containing the match after each article's name.

## [2.1.3] - 2026-07-10

New Features and improvements:
- Unit movement announcement toggles now split each category into military units and civilians; a category you had on stays fully on.

Bug fixes:
- Searching the Civilopedia with Ctrl+F now finds Vox Populi's effects text, such as which wonders grant Delegates.
- Searching the Civilopedia with Ctrl+F no longer matches Roads and Railroads for the word "help".

## [2.1.2] - 2026-07-10

New Features and improvements:
- Search Civilopedia article text with Ctrl+F: type a query, press Enter, and browse the matches in their usual categories; Escape restores the full Civilopedia.
- Unavailable Vox Populi spy missions now say "disabled" right after the mission name, before the reason.
- The settings menu ends with "Reset all settings to defaults", which asks for confirmation before restoring every preference.

Bug fixes:
- Sound cues and beacons recover after an audio device switch or suspension instead of staying silent.

## [2.1.1] - 2026-07-08

New Features and improvements:
- The game now keeps running while you're in another window; needs the game set to windowed mode from video options and the relevant mod setting turned on under f12. This sometimes breaks, especially if for example your computer goes to sleep, so use at your own risk. It is however very helpful for multiplayer, meaning not everyone has to be stranded in the window at all times.
- AI coding assistants like Claude code or Codex can now query your live game through a new MCP bridge. Clone the repo and have your agent of choice explain how to set this up. As with all LLM output, don't trust it entirely, but it can do things like explain the map to you and give you high level strategic info.

## [2.1.0] - 2026-06-29

New Features and improvements:
- The turn key (T) now reports the time left when a multiplayer turn timer is running.
- A tick sounds each second during the last 15 seconds of your turn timer.
- Pressing Escape in the multiplayer staging room now asks to confirm before leaving the game.
- The multiplayer host can kick a player from the far-right column of the F8 score list; Enter twice to confirm.
- In simultaneous multiplayer, a reminder repeats each minute if your turn end gets canceled while everyone is waiting on you.

Bug fixes:
- Sending a multiplayer chat message no longer delivers it twice.
- In multiplayer, discovering a natural wonder now names it instead of only announcing that a wonder was found.
- Kicking a player from the multiplayer staging room now asks for confirmation and no longer leaves the screen silent and unresponsive.
- In multiplayer, meeting a city-state now speaks the first-contact gift you received.
- Opening a trade with a player from the F4 list no longer reads the previous trade partner's name first.

## [2.0.7] - 2026-06-25

New Features and improvements:
- When choosing production, building entries now speak Vox Populi's projected per-city yields, not just the base yields.

Bug fixes:
- Moving a squad with escort in multiplayer no longer desyncs the game.

## [2.0.6] - 2026-06-23

New Features and improvements:
- A sort set on a table screen now stays in effect when you reopen that screen later in the session.
- Cycling squads with Up and Down now reaches an add-new-squad option; Alt+Right there creates a squad with the selected unit.

Bug fixes:
- City-state quests are back to being a single line  entry; step through each quest's description and reward with Alt+Up/Down.
- On the diplomacy overview's city-states tab, Alt+Up and Down step through each quest in the Quests column one at a time.
- Pressing Enter on a city held by barbarians no longer crashes the game.

## [2.0.5] - 2026-06-22

Bug fixes:
- City-state quests now read one at a time instead of as a single block.
- A trade item already in the deal no longer reappears in the available list, preventing duplicate offers and a crash from adding a second luxury.
- The diplomat's military unit list in the espionage view now opens under Vox Populi instead of doing nothing.

## [2.0.4] - 2026-06-22

New Features and improvements:
- Unit info (/) now names the squad the selected unit belongs to.
- The Military Overview (F3) Units tab now has a Squad column; sort it to group squadmates together.

Bug fixes:
- After sending a chat message in LekMod, keystrokes no longer keep typing into the chat box and Enter no longer re-sends.
- The Military Overview (F3) no longer reads a supply count under LekMod, which has no unit supply limit.
- The trade route overview screen now opens under LekMod instead of coming up empty.
- Cycling squad units with Left and Right now speaks each unit's direction the same way as the rest of the game.
- A targeting key pressed while already aiming a unit move, squad move, gift, or city strike no longer opens a second targeting mode on top.
- Alt+Right on a unit already in the focused squad now says "already in" instead of falsely reporting another add and disrupting the squad.

## [2.0.3] - 2026-06-21

New Features and improvements:
- In a squad, Alt+/ now selects the focused member so you can give it orders directly.
- Alt+Down on a squad now opens its menu (rename, delete, settings) directly from the map.
- Alt+Left now deletes the focused squad when it is already empty.
- With no squads yet, Alt+Right now creates one, adds the selected unit, and opens its menu to set it up.
- Alt+Up now reads a squad's move in progress; press again to cancel that move and pick a new destination.

## [2.0.2] - 2026-06-21

New Features and improvements:
- In Vox Populi, you can now invest Gold in a building from its slot in a city's production queue, not just from the production chooser.

Bug fixes:
- In the city production menu, pressing Tab to switch between Produce and Purchase now keeps your place in the list instead of jumping to the top.
- On reward popups such as a researched technology or built wonder, Alt+Up and Alt+Down now step through the details one section at a time.
- Repeatedly pressing Alt+Up while moving a squad no longer leaves you stuck in stacked move modes.
- Closing a screen now brings the camera back to the hex cursor.
- Announcements such as selecting a unit no longer sometimes read twice until you restart the game.

## [2.0.1] - 2026-06-20

New Features and improvements:
- LekMod games now install Lekmap, LekMod's own map scripts, so you can play on the maps LekMod is balanced around.

## [2.0.0] - 2026-06-20

New Features and improvements:
-This update will require you to redownload the installer if you wish to play with any of the newly supported mods.
-Added full support for the Community Patch and Vox populi mods. The community patch is a community driven effort to fix many outstanding bugs in the game, and to generally make the AI a better player of the game. Vox Populi builds on this project to completely change and rebalance the game, adding countless new features. Please note that the Vox Populi mod only works in English, it is not actively translated into any other languages.
- If playing with Community Patch or Vox Populi, you can now use squads: F11 opens a menu to create and configure squads, and Alt with the arrow keys groups, moves, and reports them from the map. Full information in the read me.
-added support for Lekmod, the most commonly used multiplayer mod. This mod completely rebalances policies, pantheons and religions as well as adding 60+ new civs. It attempts to reuse localised game strings where possible so theoretically should work in non-English languages, but no promises.
- Alt plus Up or Down in any menu, table, or list reads the current item one section at a time, so long entries with tooltips can be reviewed piece by piece.
- Typing to search the tech tree now opens a list of every matching tech to arrow through, instead of jumping straight to the first match.
- Typing on a table screen now filters it to the matching rows to arrow through, instead of jumping between matches.
- The scanner in city view has a new Yields category that ranks the city's tiles by each yield, so you can quickly find your best food or production tile.
- F1 on the new technology popup now also reads the details of each unit, building, and ability the tech unlocks.
- The production chooser lists civilian units first, then land, sea, and air, and national wonders ahead of world wonders.
- Melee attack previews count the Impi's opening spear volley in the predicted damage ("includes 9 volley"), which the game's own preview omits.
- F2 on the Great Work popup now also describes the image for great works of writing and music.

Bug fixes:
- Multiplayer chat messages no longer read twice once you are in the game.
- The multiplayer screens got a thorough accessibility pass. In the staging room: players are announced as they join, leave, or are kicked; the roster stays readable after you ready up; you are told when the host clears your ready or when you cannot ready up; empty seats are read when a host reloads a save; hot-joins and a waiting Launch button are explained; the host can save the setup and is warned about private or oversized games; and the dedicated-server, email-password, and Strategic View controls are reachable. The server browser announces when the game list is refreshing and when it settles, and flags servers you cannot join for lack of required DLC. Turn-timer values now read their unit, seconds or hours.
- The ranged attack target cursor no longer says "unseen" on a tile the unit can actually strike, for example if it has the indirect fire upgrade.
- The turn estimate for building a road or railroad is no longer sometimes 1 turn too low, both in the route preview and when reading a worker building one.
- The city screen's Defense list now includes unique defensive buildings like the Walls of Babylon.

## [1.4.4] - 2026-06-13

Bug fixes:
- Loading a multiplayer save no longer stalls the turn when units have queued moves.

## [1.4.3] - 2026-06-11

New Features and improvements:
- F2 on the World Congress session and project popups reads a description of the splash painting.
- F2 on the new era popup reads a description of the era's splash painting.

Bug fixes:
- Declarations of friendship in the F4 foreign relations column were missing how many turns they have left.
- F2 descriptions of wonder splash paintings and victory screens now speak in your language instead of English.

## [1.4.2] - 2026-06-10

New Features and improvements:
- F2 on the Great Work popup reads a description of the painting for great works of art.
- F2 on the natural wonder discovery popup reads a description of the wonder's portrait.
- F2 on the wonder completion popup reads a description of the wonder's splash painting.
- F2 on the end-of-game screen reads a description of the victory or defeat painting.

Bug fixes:
- Leader scene descriptions read more naturally, with clearer wording and a few corrected details.

## [1.4.1] - 2026-06-09

Bug fixes:
- The "Your queued moves" setting again announces your units on automated orders like auto-explore.
- Caravans and cargo ships no longer clutter the moving-units announcements and the F7 Unit Moves log.

## [1.4.0] - 2026-06-08

New Features and improvements:
- A new pair of settings can widen the scanner and the tile readout to show queued waypoints for every unit, not just the selected one.
- Custom scanner categories can hold search keywords, each becoming a subcategory of everything whose name matches it.
- Custom scanner categories can be renamed from their editor, and are listed and cycled in alphabetical order by name.
- The relationship breakdown on the F4 diplomacy screen now groups each civ's opinion modifiers by how much they help or hurt, from very pleased to very displeased.
- The F3 units table now opens sorted nearest-first by distance.
- A moving unit's status on the F3 units table now shows the turns remaining to reach its destination.
- Cursoring over one of your moving units now reads its full queued path and ETA, not just "queued move", even when the unit isn't selected.
- A city production queue slot now offers Move to top and Move to bottom alongside Move up and Move down.
- The F12 settings menu renames the UI group to General and gathers volume and audio-cue controls under a new Audio group.
- Unit movement readouts now appear in the message buffer reviewed with the bracket keys, under a new Movement filter.
- Producing an international project (World's Fair, International Games, Space Station) now reads its global progress and your contribution, in the production menu and on the city's production readout with 2.
- In move mode, Shift plus space previews the path from the last queued waypoint to the target, the leg Shift plus enter would add.

Bug fixes:
- A worker's queued road turn estimate now counts the tile it starts on, no longer under-reporting when that tile still needs the road.
- Incoming multiplayer chat is no longer announced and buffered two or three times.
- The bracket-key message buffer now matches what was spoken: combat and reveal lines you have set not to announce no longer appear in it.
- The Warn when adjacent to enemy setting now reads its label, not a raw key name, when settings are opened from the main menu.
- Adjusting the number of city states in a custom game now advances one city state per keypress instead of repeating the same number.

## [1.3.2] - 2026-06-06

New Features and improvements:
- AZERTY, QWERTZ, and Italian keyboards keep the in-game key cluster in its physical position; a Keyboard layout setting under UI settings overrides the detected layout.

Bug fixes:
- Enabling or disabling a mod in the mods list now updates the open entry immediately instead of only after returning to the list.

## [1.3.1] - 2026-06-05

New Features and improvements:
- Scope the scanner to one compass direction with Ctrl plus arrow keys; press the same direction again to clear.
- Settings has a Long compass directions toggle that speaks directions in full ("northeast" instead of "ne") everywhere they are announced.
- Unit movement announcements now have a separate on/off toggle per owner: your queued moves, hostile civs, neutral civs, city-states, barbarians, and teammates.

Bug fixes:
- A caravan or cargo ship you renamed keeps its name when a trade route starts or ends. Game bug, but fixed it as it was easy and annoying.

## [1.3.0] - 2026-06-05

New Features and improvements:
- The Slash unit readout now leads with HP, moves, and status, with promotions last, so the most time-sensitive details come first.
- In the F7 Turn Log, activating a combat entry jumps the cursor to the tile where it happened.
- In the F7 Turn Log, units that entered view this turn are listed individually under their group, and activating one jumps the cursor to it.
- The F4 Diplomatic Overview's relationship cell now lists what is driving each AI's stance toward you, the same breakdown as the game's stance tooltip.
- Upgrade in a unit's Tab menu now reads the target unit and gold cost, and stays listed when you can't afford it, explaining what is blocking it.
- A unit's Tab menu now reads the Alt+letter shortcut after each action that has one, so you can learn the quick keys as you browse.
- Foreign and rival units moving within your sight can now be announced as they move and collect under a new Unit Moves group in the F7 Turn Log; an F12 Notifications setting turns the speech off, on, or on only in simultaneous multiplayer.
- A unit you sent on a multi-turn move is now announced as it continues on later turns, under the same Unit Moves setting.

Bug fixes:
- The F7 Turn Log now logs combat from your own turn, not just the AI's.
- Foreign units revealed or hidden by your own units' movement now update the F7 Turn Log as you move.
- Combat preview against a garrisoned enemy city now reflects an attack on the city rather than the garrisoned unit.
- City yields now refresh when you reopen them after changing worker focus or specialists, instead of showing stale numbers until the city screen is reopened.
- Assigning an unemployed citizen in the city screen now reports the remaining unemployed count.
- Active deals in the diplomacy screen now report turns left until each item expires instead of the duration it was signed for.
- Shift+S reports the distance to your capital as a direction, like other readouts, rather than as coordinates if you have coordinates turned off.

## [1.2.0] - 2026-06-01

New Features and improvements:
- The surveyor's terrain count with Shift+Z now also reports how many tiles in range have river access.
- The cursor tile and the scanner's current target are now highlighted on screen for sighted players; toggle in Settings.
- Ctrl+B switches the number-key bookmarks between map tiles and your own units, allowing you to reuse the same keys to bookmark units instead of tiles.
- Build custom scanner categories from the F12 Scanner settings to cluster the filters you use most into one place.
- Ctrl+M opens a Map settings menu containing visual-only options for the hex grid, yield and resource icons, trade routes, tile recommendations, and strategic view.
- The help menu now ends with a More Help group with links to open the mod read me or join the mod Discord server in your browser.
- The scanner's new Geography category lists contiguous land and water masses you can see, each numbered outward from your capital with its tile count and whether it's fully revealed. As you clear fog of war, these may become combined as connections are revealed between them.

Bug fixes:
- Trading away a city you took the same turn no longer leaves the turn stuck demanding production for a city you no longer own. This was a game bug, not a mod bug, but I've decided to fix it anyways due to it being save breaking and easy to fix.
- Checking gold with G no longer also toggles the map's visual grid overlay.
- In hotseat, keys now reach the player switch screen when it opens over another full-screen event instead of the hidden event behind it.

## [1.1.13] - 2026-05-26

New Features and improvements:
- R now also tells you your current era.
- pressing 1 on a city now tells you how many tiles are controlled by that city.
- Surveyor adds Control plus Shift plus A for improvements in range, Control plus Shift plus D for neutral units in range, and Control plus Shift plus Z for tile ownership in range.
- W on a tile inside civ borders but not worked by any city now says "in your territory" or "in Arabian territory" instead of skipping ownership.
- The scanner now lists contiguous unexplored tiles as a single entry under Terrain, Base Terrain, with the count of tiles in each unknown region.

Bug fixes:
- Ability and Civilopedia descriptions no longer double a word when an icon repeats its label, such as "Movement moves" or "culture Cultural". This may be buggy across languages, so do let me know if it doesn't work in your language.
- Escape now reliably closes overview screens (Ctrl+C Culture, F2-F8 advisors, Ctrl+T Trade Routes) when the screen opens around a turn transition.
- The scanner now identifies lake tiles as lakes instead of coast.

## [1.1.12] - 2026-05-20

New Features and improvements:
- End turn now also responds to Control+Enter, and force end turn to Control+Shift+Enter.
- Military Overview Units tab adds an Adjacent enemies column.

Bug fixes:
- Switching cities with comma or period in the Choose Production popup no longer traps you in a city screen Escape cannot close.

## [1.1.11] - 2026-05-20

New Features and improvements:
- Pressing Space with a unit selected now previews its path and movement cost to the cursor tile, without entering move mode first.
- Selecting a unit with a queued move now reads each stop on its path in order, so you can hear where it will pause along the way instead of just the final destination.
- Selecting a worker with a queued route now reads "queued road" or "queued railroad" with the total build turns and each tile the worker will stop on to build, instead of describing it as a regular move with movement-only turn count.
- The optional adjacent-enemy warning now tells you how many enemies are nearby instead of just "enemy near".

Bug fixes:
- Military Overview units that have used their moves no longer show as idle; they read as out of moves or moving.
- Drilling into a yield on the city stats screen no longer reads out a row of dashes between the sources and the total.
- Alt-modified hotkeys now work with the right Alt key on non-US keyboard layouts.
- Route-to no longer says "no route available" on Space or Enter when the worker is standing on a tile that already has the best route (or in a city); it now reads the path the engine will actually commit.

## [1.1.10] - 2026-05-17

New Features and improvements:
- The Diplomatic Overview's Relations tab now has a Declare War column in multiplayer, with one row per major civ. Find it on the far right. 
- Pressing T now also tells you who must still end their turn in multiplayer.

Bug fixes:
- Adding a Declaration of Friendship to a multiplayer trade deal now works, whoops.
- The trade screen no longer reads a turn count on items that aren't turn-timed (Allow Embassy, Declaration of Friendship).
- Discovering a natural wonder in multiplayer now reads the wonder name/yield if worked.
- The end-of-turn announcement no longer cuts off other speech that is still playing.

## [1.1.9] - 2026-05-17

New Features and improvements:
- Added a setting in the cursor section to warn when the cursor lands next to an enemy unit.
- Added a brief Tips and tricks section to the README: https://github.com/rashadnaqeeb/Civ-V-Access/blob/main/README.md#tips-and-tricks

Bug fixes:
- The scanner now lists cities of civilizations you have not yet met, so a city revealed by an ancient ruins map can be found in the cities list.
- Pressing X on a fogged tile now reports enemy zone of control when a visible enemy combat unit stands on a visible neighbor.

## [1.1.8] - 2026-05-16

New Features and improvements:
- Rename city, rename unit, and rename world congress dialogs now open ready to type, no need to activate the name field first.
- Added a setting in the notifications section to play a tone when your turn starts in single player, mirroring the multiplayer behaviour. Useful in late game when turns can take quite a while to resolve.

Bug fixes:
- Editing a leader, civilization, short name, or adjective in the custom civ name screen no longer reads the field as blank after Escape or after navigating away and back.

## [1.1.7] - 2026-05-15

New Features and improvements:
- Written language can now be changed from inside the game: Options, Interface Options tab, Written language pulldown. The list includes any third-party language packs you've installed.
- The mod now speaks Brazilian Portuguese when paired with the Civ5-PTBR community language pack.

Bug fixes:
- Pressing Enter to commit a move that can't make any progress (an embarked unit pointing across deep ocean without Astronomy, with no reachable tile beyond the one it's on) now reads the actual obstacle instead of "action failed".

## [1.1.6] - 2026-05-15

Bug fixes:
- Unavailable improvements in the unit action menu no longer read a doubled period between the reason and the improvement's effect.
- Volume settings now apply on the main menu instead of staying at the default until you enter a game.
- Pressing Space to preview a path no longer names a unit blocking on a fogged tile; it just says "blocked".
- Space and Enter in build-route mode now give clearer, less confusing information.
- Shift+Enter on the first leg of a move or route reads the path summary instead of just "queued"; later legs in the chain still read "queued" because the path depends on prior queued legs finishing first.
- Closest reachable tile on a failed move preview no longer names a tile your unit can't actually enter (such as one in another civ's closed borders).

## [1.1.5] - 2026-05-13
New Features and improvements:
- Scanner terrain category now includes a Fresh Water subcategory listing every revealed tile with river or lake access.
- Audio beacons sound warmer and less harsh while still giving clear stereo direction.
- Scanner direction beep now pans audibly left and right instead of sitting nearly centered.
- Tab on a worker now also lists improvements you can't build yet, after the buildable ones, with the reason.

Bug fixes:
- City religion breakdown now uses the player's chosen religion name instead of the default (for example it used to read "Buddhism" when you'd renamed it "Sun Worship").
- Beacon volume slider now adjusts the beacon volume on its own instead of as a fraction of the hex audio volume, whoops.

## [1.1.4] - 2026-05-13
Bug fixes:
- Submenu landing cue no longer goes silent in-game.
- Purchase in a Venice puppet city no longer silently fails.

## [1.1.3] - 2026-05-13
New Features and improvements:
- AI trade offers now include your stock for items on your side (gold, gold per turn, resources), so you can judge whether you can afford the deal.
Bug fixes:
- Trade Agreement no longer appears in the diplomacy trade list; it was a leftover Firaxis disabled before shipping and could never be offered.
- Possibly fixed the numpad this time.

## [1.1.2] - 2026-05-12
Bug fixes:
- Numpad cluster keys now work with Shift held and with NumLock off.
- Reading the unit on a fogged tile with S no longer leaks the unit hiding there.
- Happiness icon no longer doubles its label when the engine prefixes a qualifier (e.g. "Very Unhappy").
- City specialist slot tooltips now name the great-person kind generated (e.g. "+3 Great Scientist Points").
- Cursor and scanner direction abbreviations now localize in Russian, Spanish, French, Italian, and Korean.

## [1.1.1] - 2026-05-12
New Features and improvements:
- Economic Overview resource tab now shows a "From city-states" column, so allied-minor imports are clearly identified.
Bug fixes:
- Added a possible fix to the rare bug where the options menu would not appear.

## [1.1.0] - 2026-05-11
New Features and improvements:
- F12 Settings menu is now organized into  categories instead of a flat list, as it was getting quite unwieldy.
- Audio beacons now distinguish nearby beacons from far ones much more clearly. Pan and pitch scale per-hex with the displacement -- each hex east or west moves the beacon one step right or left in the stereo field, each hex north or south shifts it one semitone up or down -- so two beacons in similar directions from the cursor but at different distances sound visibly different instead of pegging to the same stereo position.
- New F12 setting "Beacon volume" lets you adjust the bookmark beacon  volume.
- Civilopedia: cross-reference entries inside an article now announce themselves as "link" when verbose mode is on.
- Read subtitles is now on by default, because many players were confused that the advisor intros weren't being read out automatically. Only applies to fresh installs; if you already have the mod, your existing setting is preserved.
- Scanner auto-move cursor is no longer bound to Shift+End. The setting remains in the F12 Settings overlay, and the saved on/off state is preserved.
- New F12 setting "Scanner uses compass direction" (off by default). When on, the scanner's direction segment switches from the hex-step decomposition ("1ne, 2e") to a single 8-point compass bearing paired with the hex distance ("3e"). Targets whose hex path would zigzag along symmetric axes collapse to the axis the player perceives spatially: a target two hexes due north of the cursor reads "2n" instead of "1ne, 1nw".
- New F12 setting "Scanner plays directional beep" (off by default). When on, every scanner cycle (item, instance, subcategory, category, search land, End-key distance probe) fires a short beep whose pan, pitch, and volume encode the displacement from the cursor to the cycled-to entry, using the same per-axis math as the audio beacons. East and west move the beep right and left in the stereo field, north and south shift it up and down by a semitone per hex, and distance fades the volume down to silence at the same audible range the beacons use. 
- Scanner now distinguishes your teammate's cities, units, and improvements from your own in same-team multiplayer.
Bug fixes:
- Puppet cities can now perform their ranged strike. Pick View City from the annex prompt, open the city hub, and Ranged Strike appears whenever the city has a valid target. Previously the option was suppressed during the viewing-mode peek and the mod had no other path to it.
- Move-target mode no longer reveals enemy units hidden in fog. Pressing Space on a fogged plot used to speak the defender's type, HP, and combat strength. whoops.
- Alt+M while already in move-target mode now does nothing, instead of stacking another target-mode handler on top. 
- Production chooser, production queue, and the in-city built buildings list now read each building / unit / project's full effect description, matching what sighted players see in the tooltip. They previously spoke a "strategy" blurb that omitted gameplay rules; for example, the Granary's +1 food from worked Wheat, Bananas, and Deer was missing. 
- Deleting a save in the Load Game and Save Game menus no longer leaves you stranded on a blank "Save deleted." panel. Focus now jumps back to the save list, and the Save Menu also fixes a stale "Delete" announcement that fired after confirmation.
- Ctrl+I from a popup screen now returns you to the same tab and cursor position when you close the Civilopedia. Previously you landed back at the first tab, first item.
- Civilopedia opened directly to an article now closes on a single Esc press instead of bouncing through the category picker first. 
- Route-to target mode: pressing Space on a target plot now speaks the path length and build-turn count as intended. 
- F12 now opens the settings overlay from everywhere, instead of a random selection of screens.

## [1.0.4] - 2026-05-10
New Features and improvements:
- Scanner category order: Improvements and Recommendations now sit directly after Cities (was further down the list).
Bug fixes:
- World Congress Yea/Nay votes now register on the side you cast them. Votes were being submitted to the engine without a Yea/Nay tag, so the resolution outcome was decided by the AI alone and your choice had no effect.
- Traditional Chinese (zh_Hant_HK): the city-view hub items Buildings, Specialists, Great Works, Production Queue, Manage Territory and Ranged Strike, plus the six compass-direction abbreviations spoken in cursor and scanner readouts, were left in English. They now display in Chinese.
- Various other localisation fixes across Russian, Polish, Italian, Korean, and Japanese.

## [1.0.3] - 2026-05-10
New Features and improvements:
- Scanner cities category now has a "City states" subcategory holding peaceful city-states, so they no longer crowd the neutral major-civ list. City-states you're at war with bucket into "Enemy cities" alongside hostile major civs.
Bug fixes:
- Type-ahead search no longer fires on screens with only one option to pick: the lone item used to get re-announced on every keystroke. Same screen with multiple options behaves as before.
- AI-initiated diplomacy popups (a leader greeting you, proposing a trade, or telling you something) now ignore type-ahead keystrokes for the first 0.2 seconds. Stops in-flight cursor letters (Q/W/E/A/S/D/Z/X/C) from leaking into the popup's search the moment it appears.
- Tabbed overview screens (F-key advisors, F6 tech tree, etc.): pressing Escape with an active typeahead search now clears the buffer instead of closing the screen, matching every other menu.
- "Choose one" popups (Shoshone Pathfinder ruin reward, Liberty free Great Person, faith-purchased Great Person, Maya baktun bonus) are now flat lists: pick a row to commit, no separate confirm step. The ruin-reward rows additionally lead with a short label before the vanilla flavor sentence.
- Automated workers now announce what they're currently building (e.g. "Build Farm 5 turns, automated Workers") instead of just "automated Workers", so you can tell whether an automated worker is making progress or sitting idle.
- Comma immediately before a period (",." or ", .") now reads as just the period, ending the annoying NVDA dot reading.
- Verbose-mode control-type tags renamed: checkboxes now announce as "toggle" (was "checkbox") and grouped items as "submenu" (was "drillable"). Better matching the windows UI.
- Localized mod strings now follow your text language (e.g. Traditional Chinese) instead of your audio language. Because Chinese, Japanese and Korean have no voice acting, their translations were never loading.

## [1.0.2] - 2026-05-09

- Scanner improvements category now has a "My pillaged" subcategory holding only your own pillaged improvements, so you can find what needs repairing without scanning your full improvement list. Pillaged improvements of yours move out of "My" into this sub; enemy and neutral pillaged improvements stay in their owner subs.
- Numpad now mirrors the Q/W/E/A/S/D/Z/X/C cursor cluster on the map (5=S; 7/8/9, 4/6, 1/2/3 fall out from there) with the same Shift/Ctrl/Alt modifiers, so cursor movement, tile readouts, surveyor radius queries, and Alt-cluster unit actions are all reachable from the numpad.
- Updates after this release reliably skip unchanged components. (1.0.1 introduced the per-component skip but its packaging produced byte-different zips for unchanged components, so the installer redownloaded everything anyway.)
- F4 diplomacy overview: open borders and embassy treaty rows no longer report the wrong direction (were saying "your borders are open to them" when only their borders were open to you, and vice versa for embassies).
- City stats yields: food and culture per-turn rates now lead with "+" when positive (e.g. "food +5, 12 of 22, grows in 2 turns") so the rate is unambiguous next to the storage fraction.

## [1.0.1] - 2026-05-09

- The main menu now speaks "Your mod is out of date. Please run the installer." about a second after the boot announcement when a newer release is available on GitHub.
- The main-menu boot announcement now speaks the mod version (e.g. "Accessibility mod v1.0.0 ready") so players know which version they're running.
- Updates only redownload components that actually changed. Previously, every update redownloaded all five components, including the ~110 MB cinematics, even when only the Lua payload differed.
- The installer's update-succeeded screen now shows the changelog entries between your previous version and the one you just installed, in a read-only text field.

## [1.0.0] - 2026-05-09

Initial public release.
