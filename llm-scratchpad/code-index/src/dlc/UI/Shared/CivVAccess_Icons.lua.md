# `src/dlc/UI/Shared/CivVAccess_Icons.lua`

96 lines · Icon spoken-text registry that maps `[ICON_*]` bracket tokens to localized spoken forms and registers them with `TextFilter`, including typo-variant aliases.

## Header comment

```
-- Icon spoken-text registry. Maps [ICON_*] tokens to TXT_KEY_CIVVACCESS_ICON_*
-- strings, then hands the resolved text to TextFilter.registerIcon. After this
-- include runs the filter's substituteIcons pass replaces bracket tokens in
-- speech with the localizable spoken form (e.g. "[ICON_PRODUCTION]" ->
-- "production"). Unregistered icons fall through to the catch-all bracket
-- stripper and vanish silently.
--
-- Policy: we only register icons that carry information the surrounding text
-- does not repeat. The diagnostic: an icon is worth speaking when it appears
-- alone or after a bare number ("120 [ICON_RESEARCH]" or "+3 [ICON_HAPPINESS_1]"),
-- because there the icon IS the label. Icons that sit next to the word they
-- represent ("[ICON_RES_COW] Cows", "[ICON_RELIGION_ISLAM] Islam",
-- "[ICON_GOLDEN_AGE] Golden Age") are purely decorative for sighted players;
-- speaking them doubles the noun ("cattle Cows", "Islam Islam") without
-- adding information. Those categories are left out of the registry on
-- purpose: the filter's catch-all strips them to nothing.
--
-- Include order requirement: must load AFTER CivVAccess_TextFilter,
-- CivVAccess_<Context>Strings_<locale>, and CivVAccess_Text so Text.key can
-- resolve the TXT_KEYs into mapped strings at registration time. Loading it
-- earlier registers "TXT_KEY_CIVVACCESS_ICON_X" as the literal spoken form,
-- which is worse than the default strip behavior.
--
-- Base-game text ships with occasional typo variants of icon names
-- (HAPPINES_4, STRENGHT, CULTUR). We map those to the same TXT_KEY as their
-- correctly-spelled counterpart so the screen-reader user never hears a typo
-- or a dropped token.
```

## Outline

- L29: `local ICON_KEYS = { ... }`
- L80: `local ALIAS_KEYS = { ... }`
- L87: `for name, key in pairs(ICON_KEYS) do ... end`

## Notes

- L29 `ICON_KEYS`: intentionally omits decorative icons (religion glyphs, resource icons, golden age) that always appear adjacent to their spoken label, relying on `TextFilter`'s catch-all to strip them.
- L80 `ALIAS_KEYS`: keyed by primary `TXT_KEY` rather than `ICON_` name so typo-variant entries (e.g. `ICON_HAPPINES_4`) inherit their canonical icon's aliases without duplication.
