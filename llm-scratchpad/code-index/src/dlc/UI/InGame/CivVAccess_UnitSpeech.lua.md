# `src/dlc/UI/InGame/CivVAccess_UnitSpeech.lua`

1261 lines · Pure stateless formatters that turn unit handles and combat payloads into speech strings: selection/info readouts, melee/ranged/city combat previews and results, move outcome, self-plot action confirms, and nuclear strike summaries.

## Header comment

```
-- Pure formatters that turn a unit (and action payloads) into speech.
-- No event registration, no listeners, no state -- every call re-reads
-- the unit so stale speech can't leak through a cached format.
--
-- The selection / info functions own the shape of "what the player hears
-- about a unit." UnitControl's UnitSelectionChanged handler calls
-- selection() with the pre-move cursor coords so the direction prefix
-- ("3e, 2se warrior ...") lets the user keep their spatial orientation
-- even when the camera jumps to a newly-activated unit mid-turn.
--
-- Status cascade mirrors base-game UnitList.lua:147-200, which is the
-- canonical ordering across every vanilla / Expansion2 build:
--     garrisoned -> automated -> healing -> alert -> fortified ->
--     sleeping -> building -> queued move. [...] "queued move" is
--     mod-added: base UnitList has no rung for a unit mid-execution on
--     a multi-turn mission [...]
```

## Outline

- L26: `UnitSpeech = {}`
- L45: `local function unitName(unit)`
- L65: `local function nameWithEmbarked(unit)`
- L87: `local function formatMoves(sixtieths)`
- L100: `local function movesFraction(unit)`
- L115: `local function airRangeToken(unit)`
- L121: `local function isAir(unit)`
- L125: `local function reachToken(unit)`
- L132: `local function hpFraction(unit)`
- L137: `local function isFriendly(unit)`
- L148: `local function airOutOfMovesToken(unit)`
- L166: `local function isOutOfAttacks(unit)`
- L178: `local function statusToken(unit)`
- L254: `local function cargoAircraftCount(carrier)`
- L275: `function UnitSpeech.cargoAircraftToken(unit)`
- L290: `local function cityMaxAir(city)`
- L305: `local function cityAircraftCount(plot)`
- L320: `function UnitSpeech.cityAircraftToken(plot)`
- L332: `function UnitSpeech.selection(unit, prevX, prevY)`
- L371: `local function promotionList(unit)`
- L402: `function UnitSpeech.info(unit)`
- L476: `function UnitSpeech.combatantName(playerId, unitId)`
- L490: `function UnitSpeech.cityCombatantName(playerId, cityId)`
- L509: `local COMBAT_PREDICTION_KEYS = { ... }`
- L519: `local function predictionLabel(actor, defender)`
- L530: `local function pushMod(list, value, key, ...)`
- L552: `local function attackerMods(actor, defender, targetPlot, bRanged)`
- L740: `local function defenderMods(actor, defender, targetPlot)`
- L888: `function UnitSpeech.meleePreview(actor, defender, targetPlot)`
- L939: `function UnitSpeech.rangedPreview(actor, defender, targetPlot)`
- L1006: `function UnitSpeech.cityMeleePreview(actor, city, targetPlot)`
- L1053: `function UnitSpeech.cityRangedPreview(actor, city, targetPlot)`
- L1102: `function UnitSpeech.combatResult(args)`
- L1161: `function UnitSpeech.nuclearStrikeResult(buf)`
- L1208: `function UnitSpeech.moveResult(unit, targetX, targetY, turnsToArrival)`
- L1224: `local CONFIRM_KEYS = { ... }`
- L1238: `function UnitSpeech.selfPlotConfirm(token, payload)`
- L1255: `UnitSpeech.statusToken = statusToken`
- L1260: `UnitSpeech.unitName = unitName`

## Notes

- L1255 `UnitSpeech.statusToken`: exposes the private local so PlotSectionUnits can reuse the ownership-gated rung cascade without duplicating it.
- L1260 `UnitSpeech.unitName`: exposes the private local so PlotSectionUnits can build the named-unit form using the same civ-tagged base all other speech paths use.
- L530 `pushMod`: silently skips zero values and empty labels so callers don't need to pre-filter modifier lists.
