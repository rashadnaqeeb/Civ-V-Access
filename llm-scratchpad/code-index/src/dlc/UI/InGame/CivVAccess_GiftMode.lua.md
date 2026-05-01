# `src/dlc/UI/InGame/CivVAccess_GiftMode.lua`

332 lines · Modal HandlerStack handler for city-state gift targeting (unit or tile-improvement kind), with Space legality preview, Enter commit, Esc cancel, and Alt-key blocks matching CityRangeStrikeMode.

## Header comment

```
-- Gift-unit / gift-tile-improvement target picker. Pushed above Baseline
-- after the city-state diplo popup commits to OnGiftUnit / OnGiftTile-
-- Improvement (which dequeues the popup and sets INTERFACEMODE_GIFT_UNIT
-- or INTERFACEMODE_GIFT_TILE_IMPROVEMENT). Structurally a sibling to
-- CityRangeStrikeMode: free Q/E/A/D/Z/C cursor movement via Baseline,
-- Space speaks a kind-specific legality preview ("can gift" via the plot's
-- glance, or "cannot gift here"), Enter commits, Esc cancels. Alt+QAZEDC
-- and the Alt-letter quick actions are swallowed to block Baseline's
-- direct-move and quick-action handlers from firing against an unrelated
-- unit while the engine holds a gift interface mode.
-- [...]
```

## Outline

- L29: `GiftMode = {}`
- L31: `local MOD_NONE = 0`
- L32: `local MOD_ALT = 4`
- L34: `local KIND_UNIT = "unit"`
- L35: `local KIND_IMPROVEMENT = "improvement"`
- L37: `local bind = HandlerStack.bind`
- L39: `local function speakInterrupt(text)`
- L46: `local function cursorPlot()`
- L56: `local function firstOwnUnit(plot)`
- L72: `local function canGiftUnitFromPlot(plot, toPlayerID)`
- L80: `local function canGiftImprovementAtPlot(x, y, toPlayerID)`
- L95: `local function findFirstUnitTarget(toPlayerID)`
- L108: `local function findFirstImprovementTarget(toPlayerID)`
- L142: `local function legalityPreview(canTarget, illegalKey, plot)`
- L153: `local function commitUnit(toPlayerID)`
- L177: `local function commitImprovement(toPlayerID)`
- L196: `local function abandonEntry()`
- L200: `function GiftMode.enter(toPlayerID, kind)`

## Notes

- L56 `firstOwnUnit`: Iterates with GetUnit (not GetLayerUnit) and overwrites on each match, so the *last* own unit on the plot wins - matching the InGame.lua GiftUnit loop behavior.
