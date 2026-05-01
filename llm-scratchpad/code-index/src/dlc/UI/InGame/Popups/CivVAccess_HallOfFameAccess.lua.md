# `src/dlc/UI/InGame/Popups/CivVAccess_HallOfFameAccess.lua`

185 lines · Accessibility wrapper for the Hall of Fame screen (front-end), presenting each saved game result as a flat Text row with score, leader/civ, outcome, winner, map setup, and era/turn.

## Header comment

```
-- HallOfFame accessibility. Local game-result archive loaded synchronously
-- via UI.GetHallofFameData() in the vanilla ShowHide. Each row is flattened
-- to a single Text entry whose announce string carries the full XML row in
-- visual order: score, leader and civ, victory/defeat, winner + victory
-- type, map and setup icons, start era + winning turn, end time. When the
-- player won, the "winner" cell speaks "you" rather than naming the civ
-- (vanilla's flavor — keeps "I won this one" obvious while skimming).
--
-- Empty list reads as a single Text item built from
-- TXT_KEY_HALL_OF_FAME_EMPTY so arrow-key nav lands on the empty notice
-- rather than silence.
--
-- Loaded as a child LuaContext of the front-end OtherMenu (no in-game
-- entry point), which is why our DLC manifest extends <Skin> with
-- UI/InGame/Popups so this override is visible at front-end resolution
-- time. We pull the front-end include chain (locale strings live there)
-- rather than the in-game CivVAccess_InGameStrings_en_US which isn't
-- routed through the front-end Skin.
```

## Outline

- L21: `include("CivVAccess_FrontendCommon")`
- L23: `local priorInput = InputHandler`
- L24: `local priorShowHide = ShowHideHandler`
- L26: `local function joinNonEmpty(parts)`
- L44: `local function leaderCivText(v)`
- L71: `local function winnerText(v)`
- L84: `local function victoryTypeText(v)`
- L95: `local function lookupDescription(tbl, key)`
- L106: `local function mapTypeText(v)`
- L117: `local function eraTurnText(v)`
- L125: `local function statusText(v)`
- L131: `local function scoreText(v)`
- L135: `local function rowLabel(v)`
- L152: `local function buildItems()`
- L176: `BaseMenu.install(ContextPtr, { ... })`

## Notes

- L21: Uses `CivVAccess_FrontendCommon` instead of `CivVAccess_InGameStrings_en_US` because this context is loaded under the front-end Skin, not the in-game Skin.
