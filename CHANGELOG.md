# Changelog

All notable changes to Civ V Access are recorded here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The installer parses this file to show players the entries between the version
they had installed and the one they are updating to. Each version section must
start with `## [X.Y.Z] - YYYY-MM-DD` on its own line for the parser to find it.

## [Unreleased]

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
