# Changelog

All notable changes to Civ V Access are recorded here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The installer parses this file to show players the entries between the version
they had installed and the one they are updating to. Each version section must
start with `## [X.Y.Z] - YYYY-MM-DD` on its own line for the parser to find it.

## [Unreleased]
New Features and improvements:
- Scanner category order: Improvements and Recommendations now sit directly after Cities (was further down the list).
Bug fixes:
- World Congress Yea/Nay votes now register on the side you cast them. Votes were being submitted to the engine without a Yea/Nay tag, so the resolution outcome was decided by the AI alone and your choice had no effect.
- Traditional Chinese (zh_Hant_HK): the city-view hub items Buildings, Specialists, Great Works, Production Queue, Manage Territory and Ranged Strike, plus the six compass-direction abbreviations spoken in cursor and scanner readouts, were left in English. They now display in Chinese.

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
