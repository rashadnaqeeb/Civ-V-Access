# Changelog

All notable changes to Civ V Access are recorded here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The installer parses this file to show players the entries between the version
they had installed and the one they are updating to. Each version section must
start with `## [X.Y.Z] - YYYY-MM-DD` on its own line for the parser to find it.

## [Unreleased]
New Features and improvements:
- Civilopedia: cross-reference entries inside an article (related techs, units, buildings, resources, etc.) now announce "link" at the end when verbose mode is on, so you can tell at a glance which entries jump to another article and which are read-only.
- Read subtitles is now on by default, because many players were confused that the advisor intros weren't being read out automatically. Only applies to fresh installs; if you already have the mod, your existing setting is preserved.
Bug fixes:
- Help screen during unit move / attack / paradrop / range strike / gift target picks now lists the Space (preview), Enter (commit) and Shift+Enter (queue, move/route only) chords at the top, where you would expect them when the picker is on top of the stack. Previously the help screen during a unit target pick showed only the baseline map keys; the gift and city ranged-strike pickers were already listing their own keys but with mode-specific wording.
- Shift+T (read active tasks) is no longer listed in the help screen. The key only does anything inside scenarios, which the mod does not yet support, so trying it from a normal game and hearing silence was confusing. The binding stays in place and will return to help once scenarios are wired up.
- Move-target mode no longer reveals enemy units hidden in fog. Pressing Space on a fogged plot used to speak the defender's type, HP, and combat strength when the engine's pathfinder still routed there; now it reads the path and turn count the same way it would for an empty tile, and combat is announced after it resolves.
- Alt+M while already in move-target mode is now a no-op, instead of stacking another target-mode handler on top. An accidental double-press could previously leave you several copies deep, each one needing its own Esc to back out.
- Alt+X while in move-target or gift-target mode is now a no-op. Previously the keypress fell through to Baseline and skipped the actor's turn mid-pick, silently zeroing its movement points.
- Production chooser, production queue, and the in-city built buildings list now read each building / unit / project's full effect description, matching what sighted players see in the tooltip. They previously spoke a "strategy" blurb that omitted gameplay rules; for example, the Granary's +1 food from worked Wheat, Bananas, and Deer was missing. The strategy paragraph is still spoken as a fallback for the entries that ship with no effect text in the game data.
- Deleting a save in the Load Game and Save Game menus no longer leaves you stranded on a blank "Save deleted." panel. Focus now jumps back to the save list, and the Save Menu also fixes a stale "Delete" announcement that fired after confirmation.
- Ctrl+I from a popup screen (F1 Empire Status, F2 Economic Overview, F3 Military Overview, F4 Diplomacy, F8 Victory Progress, etc.) now returns you to the same tab and cursor position when you close the Civilopedia. Previously you landed back at the first tab, first item.
- Civilopedia opened directly to an article (via Ctrl+I, the cursor pedia hotkey, or a tooltip hyperlink) now closes on a single Esc press instead of bouncing through the category picker first. The bounce-back behaviour returns as soon as you tab to the picker, follow a link, step through article history, or navigate to a different article.
- Route-to target mode: pressing Space on a target plot now speaks the path length and build-turn count as intended. The preview was crashing silently in the input dispatcher, so the press did nothing audible.

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
