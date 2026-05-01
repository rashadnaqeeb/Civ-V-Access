# `src/dlc/UI/InGame/Popups/CivVAccess_ChooseTechLogic.lua`

234 lines · Pure helpers for tech-popup entry building, mode filtering, advisor compositing, help-text cleaning, and label assembly; no ContextPtr or Events surface.

## Header comment

```
-- Pure helpers for ChooseTechPopupAccess. Same split as ChooseProductionLogic:
-- this module has no ContextPtr / Events / InputHandler surface so offline
-- tests can exercise mode filtering, advisor compositing, and label shape
-- against stubbed Players / GameInfo / Game tables.
```

## Outline

- L6: `ChooseTechLogic = {}`
- L12: `ChooseTechLogic.ADVISORS = { ... }`
- L22: `function ChooseTechLogic.advisorSuffix(techID)`
- L40: `local function isEligible(player, tech, mode, targetTeam)`
- L58: `function ChooseTechLogic.buildEntries(playerID, mode, stealingTargetID)`
- L100: `function ChooseTechLogic.cleanHelpText(filteredHelp, techName)`
- L140: `function ChooseTechLogic.filterHelpText(rawHelp, techName)`
- L164: `function ChooseTechLogic.buildPreamble(player, mode, stealingTargetID)`
- L199: `function ChooseTechLogic.buildLabel(entry, player)`
- L233: `return ChooseTechLogic`

## Notes

- L22 `advisorSuffix`: requires `Game.SetAdvisorRecommenderTech(playerID)` to have been called by the caller before invoking.
- L100 `cleanHelpText`: strips the leading uppercased tech name, collapses dash-divider runs to commas, normalizes whitespace, and protects locale thousand-separators with a sentinel to prevent comma-space injection into numbers like "10,164".
- L140 `filterHelpText`: pre-converts `[NEWLINE]` to ", " before running through `TextFilter.filter` so that help-text section breaks survive as audible pauses rather than being collapsed to spaces.
- L58 `buildEntries`: returns `(entries, currentEntry)` where `currentEntry` is non-nil only in free/stealing modes (so the access layer can pin it as a read-only Text item above the choice list).
