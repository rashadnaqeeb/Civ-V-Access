# `src/dlc/UI/Shared/CivVAccess_TextFilter.lua`

159 lines · Strips Civ V markup tokens (`[NEWLINE]`, `[COLOR_*]`, `[ICON_*]`, etc.), substitutes registered icons with spoken text, and normalizes whitespace for screen-reader output.

## Header comment

```
-- Markup stripping for Civ V text. Strips engine tokens ([NEWLINE], [COLOR_*],
-- [ICON_*], etc.), substitutes registered icons with spoken text, and
-- normalizes whitespace. Never invents or rewords content.
```

## Outline

- L6: `TextFilter = {}`
- L8: `local _iconMap = {}`
- L15: `function TextFilter.registerIcon(name, spoken, aliases)`
- L20: `local function stripControl(s)`
- L25: `local function escapePattern(s)`
- L40: `local function _matchesAfter(after, phrase)`
- L48: `local function _matchesBefore(before, phrase)`
- L56: `local function substituteIcons(s)`
- L97: `function TextFilter.filter(text)`

## Notes

- L15 `TextFilter.registerIcon`: `aliases` only participate in the duplicate-speech adjacency check; the icon is always substituted with `spoken`, never an alias.
- L56 `substituteIcons`: collapses an icon to the empty string (rather than its spoken form) when the spoken form or an alias already appears adjacent in the surrounding text, preventing doubled speech.
- L97 `TextFilter.filter`: has a fast path that skips all processing when the string contains no brackets, emdash, or control characters.
