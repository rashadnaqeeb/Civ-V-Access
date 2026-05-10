# Changelog

All notable changes to Civ V Access are recorded here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The installer parses this file to show players the entries between the version
they had installed and the one they are updating to. Each version section must
start with `## [X.Y.Z] - YYYY-MM-DD` on its own line for the parser to find it.

## [Unreleased]

- Comma immediately before a period (",." or ", .") now reads as just the period, mirroring the existing ".," collapse so adjacent comma/period pairs always pick the sentence-ender's pause.
- Verbose-mode control-type tags renamed: checkboxes now announce as "toggle" (was "checkbox") and grouped items as "submenu" (was "drillable").
- Localized mod strings now follow your text language (e.g. Traditional Chinese) instead of your audio language. Players who set the game's text language to a translated locale but kept English voice acting were previously hearing English mod text.

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
