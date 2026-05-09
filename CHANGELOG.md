# Changelog

All notable changes to Civ V Access are recorded here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The installer parses this file to show players the entries between the version
they had installed and the one they are updating to. Each version section must
start with `## [X.Y.Z] - YYYY-MM-DD` on its own line for the parser to find it.

## [Unreleased]

- Updates after this release reliably skip unchanged components. (1.0.1 introduced the per-component skip but its packaging produced byte-different zips for unchanged components, so the installer redownloaded everything anyway.)

## [1.0.1] - 2026-05-09

- The main menu now speaks "Your mod is out of date. Please run the installer." about a second after the boot announcement when a newer release is available on GitHub.
- The main-menu boot announcement now speaks the mod version (e.g. "Accessibility mod v1.0.0 ready") so players know which version they're running.
- Updates only redownload components that actually changed. Previously, every update redownloaded all five components, including the ~110 MB cinematics, even when only the Lua payload differed.
- The installer's update-succeeded screen now shows the changelog entries between your previous version and the one you just installed, in a read-only text field.

## [1.0.0] - 2026-05-09

Initial public release.
