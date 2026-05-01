# `src/dlc/UI/InGame/Popups/CivVAccess_WhosWinningPopupAccess.lua`

175 lines · Accessibility wrapper for the BUTTONPOPUP_WHOS_WINNING advisor popup, capturing player/city entries via monkey-patching AddPlayerEntry/AddCityEntry and presenting them as ranked Text items.

## Header comment

```
-- WhosWinningPopup accessibility. BUTTONPOPUP_WHOS_WINNING fires on the
-- engine's own schedule (no hotkey, no menu entry) with one randomly-chosen
-- ranking metric. Distinct from the F8 VictoryProgress screen, which is
-- the persistent victory-conditions advisor.
--
-- Header speech is the engine's three live labels in order: the framing
-- "<random historian> presents the list of:" line, the metric name, and
-- the metric's tooltip definition. All three change per-popup, so the
-- preamble is a function so F1 / refresh re-reads the latest. Tooltip is
-- read back via :GetToolTipString() rather than reaching into the base
-- file's locals (g_iListMode / g_tListModeText are local to that chunk
-- and unreachable from this include).
--
-- Capture strategy: monkey-patch base AddPlayerEntry / AddCityEntry so we
-- ride the same sorted iteration the base does (table.sort by score
-- descending). iRank == 1 marks the start of a fresh popup so we reset
-- captured state and remember which mode (player vs city) populated it.
-- Tourism mode populates city entries (owner identification added because
-- sighted users see the leader portrait next to the city name); every
-- other mode populates player entries. Pedia hookup (Ctrl+I) routes to
-- the entry's leader article; unmet-civ rows skip the hookup since the
-- placeholder name has no pedia target.
```

## Outline

- L47: `local priorInput = InputHandler`
- L48: `local priorShowHide = ShowHideHandler`
- L50: `local capturedEntries = {}`
- L51: `local capturedKind = nil`
- L52: `local baseAddPlayerEntry = AddPlayerEntry`
- L53: `AddPlayerEntry = function(iPlayerID, iScore, iRank)`
- L66: `local baseAddCityEntry = AddCityEntry`
- L67: `AddCityEntry = function(iPlayerID, iCityID, iScore, iRank)`
- L81: `local function isMet(iPlayerID)`
- L85: `local function leaderName(iPlayerID)`
- L89: `local function nameForPlayer(iPlayerID)`
- L99: `local function pediaForPlayer(iPlayerID)`
- L109: `local function buildPreamble()`
- L126: `local function buildItems()`
- L164: `BaseMenu.install(ContextPtr, { ... })`

## Notes

- L53 `AddPlayerEntry`: Monkey-patches the same global name as `LeagueProjectPopupAccess`; in a game session only one of these files is active per Context so there is no collision.
- L51 `capturedKind`: Distinguishes "player" vs "city" mode so `buildItems` knows which entry shape to format; tourism mode uses `AddCityEntry` while all other metrics use `AddPlayerEntry`.
