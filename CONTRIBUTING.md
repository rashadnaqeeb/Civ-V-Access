# Contributing to Civ V Access

Civ V Access is an accessibility layer that makes Sid Meier's Civilization V
playable for blind players. Speech is the only interface. There is no visual
fallback, so anything that speaks the wrong thing, or speaks stale data, is a
failure the player cannot see.

Please read this before opening a pull request. The short version: **open an
issue first, and for new features, strongly prefer an issue over a PR.**

## Start with an issue

The most useful thing you can send is a well-described GitHub issue. For new
features it is almost always better than a pull request.

For a feature, describe:

- The real problem you hit as a player. What were you trying to do, and what
  did the mod fail to tell you or let you do?
- What you wish had happened instead, in plain terms.

Describe the problem, not an implementation. I need to agree the problem is
worth solving, and that the approach fits a speech-only game, before any code
should exist. A feature built without that step usually solves the wrong
question, reads too verbosely to be usable, or duplicates something the mod
already does in a different way. At that point your work and my review are both
wasted. A two-paragraph issue avoids all of it.

For a bug, an issue with steps to reproduce is more valuable than a patch. The
fix usually depends on conventions and engine quirks that aren't visible from
the affected file, so a description of the broken behavior lets me fix it in
the right place.

## If you do send a pull request

Most contributors here drive a coding agent rather than editing by hand. That's
fine, but the agent will not know this project's rules unless you point it at
them.

- **Point the agent at `CLAUDE.md` first.** It is the source of truth for build,
  test, conventions, and the architecture gotchas, and it overrides the agent's
  default behavior. Most of the mistakes below come from agents that never read
  it.
- **One change per PR.** No unrelated files, no `.gitignore` tweaks, no personal
  planning or design notes, no drive-by edits to things your change didn't need.
  If the diff touches files your feature has no reason to touch, it will be sent
  back.
- **Do not edit the non-English locale files.** Edit only the `en_US` strings.
  The other locales are kept in sync through a dedicated translation pipeline
  that I run before a release. Hand-translated strings, even well-meant ones,
  tend to be word-for-word and not idiomatic, and they get redone anyway. Adding
  English-only keys to `en_US` is correct and complete on your end.
- **Don't fork shared infrastructure for a one-off.** If a feature seems to need
  a change to a shared widget or the announcement pipeline, that's usually a sign
  the approach is off. Raise it in the issue first.
- **Keep speech concise and routed correctly.** All spoken text comes from a
  `TXT_KEY` lookup through the text wrapper, never inline literals. All speech
  goes through the announcement pipeline, never `tolk` directly. Never cache game
  state; re-query it at speech time.
- **The gates must be clean.** Run `bash lint.sh` and `./test.ps1`; both must
  pass, and new logic needs tests. New engine bindings need an engine build,
  which uses the VC9 compiler from the Windows SDK 7.0 (set up once by
  `build/sdk7-install/install.cmd`); most contributions don't touch the engine.
- **Make the PR description true.** If it claims it follows a rule, it must
  actually follow it. A description that contradicts its own diff costs trust and
  review time.

## Translations

Please don't submit translation edits as part of a feature PR. If you want to
help with a specific language, making a PR touching that language's strings files only is fine.
