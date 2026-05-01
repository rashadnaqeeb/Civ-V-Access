# `src/dlc/UI/InGame/CivVAccess_RevealAnnounce.lua`

550 lines · Announces reveal, hide, and gone events after unit moves so blind players know what just entered or left their line of sight.

## Header comment

```
-- Speaks reveal and hide lines after a unit move (or any visibility-
-- change source) so blind players know what just appeared on or
-- disappeared from the map. The base game has no equivalent feedback:
-- sighted players see new terrain / units / cities slide into view
-- (and old ones slide back into fog) while a screen-reader user has
-- nothing to react to.
--
-- Three readouts in one flush. Reveal lists tiles that came into view
-- with their foreign-unit / foreign-city / resource payload. Hide
-- lists foreign units that left view because the active player's
-- actions retracted LOS (a unit moved away, a unit died, a city was
-- lost). Gone lists barbarian camps and ancient ruins that were on a
-- plot the active team had previously revealed but are no longer
-- there -- cleared by someone the team couldn't see at the moment
-- of clearing; the diff fires only on revisit because first-reveal
-- plots have no prior state to compare. Cities and resources are
-- excluded from the hide direction: once discovered they stay
-- revealed -- only unit positions actually become unknown again. A
-- single move can emit any subset of these three lines; reveal
-- speaks first, then hide, then gone.
-- [... continues through line 66 ...]
```

## Outline

- L68: `RevealAnnounce = {}`
- L75: `local FLUSH_DELAY_FRAMES = 6`
- L77: `local _firstReveals = {}`
- L78: `local _nowVisible = {}`
- L79: `local _flushTargetFrame = -1`
- L95: `local _campOrRuinKind = {}`
- L97: `local function classifyImprovementAsCampOrRuin(improvementType)`
- L119: `local function bootstrapCampOrRuinSnapshot()`
- L143: `local _visibleUnits = {}`
- L144: `local function isEnabled()`
- L148: `local function scheduleFlush()`
- L156: `function RevealAnnounce._maybeFlush()`
- L168: `local function recordFirstReveal(eTeam, iX, iY)`
- L183: `local function recordNowVisible(hexPos, _fowType, bWholeMap)`
- L205: `local function shouldSkipPlot(plot)`
- L235: `local function unitOwnerBucket(ownerId, activePlayerId, activeTeam)` -> "enemy" / "other" / nil
- L253: `local function resourceName(resourceId)`
- L261: `local function buildVisibleForeignUnits()` -> ForeignUnitSnapshot.collect(unitOwnerBucket)
- L267: `function RevealAnnounce._flush()`
- L274: `function RevealAnnounce._flushBody()`
- L501: `function RevealAnnounce._onTurnStart()`
- L514: `function RevealAnnounce.installListeners()`

## Notes

- L79 `_flushTargetFrame`: Set to -1 when no flush is pending; `scheduleFlush` sets it to current frame + `FLUSH_DELAY_FRAMES` so both the synchronous `CivVAccessPlotRevealed` and the deferred `HexFOWStateChanged` events land in the same buffer before speaking.
- L205 `shouldSkipPlot`: Suppresses natural wonders, goody huts, and barbarian camps from the reveal *payload* (not the count) because the engine fires its own popups for those; the tile still increments the revealed-tile headline count.
- L274 `RevealAnnounce._flushBody`: The "gone" diff reads `GetImprovementType()` (live) and compares to the Lua snapshot rather than `GetRevealedImprovementType()` because `setRevealed` synchronously overwrites the engine's revealed-type before `HexFOWStateChanged` dispatches.
- L501 `RevealAnnounce._onTurnStart`: Silently rebuilds `_visibleUnits` at turn start so the first flush after the player's first move doesn't re-announce units that walked into fog during the AI turn.
- Visibility walk and metadata recording live in `CivVAccess_ForeignUnitSnapshot.lua`; this file owns the per-bucket vocabulary ("enemy" / "other") and the reveal/hide diff logic. The plot-walk path in `_flushBody` builds metadata via `ForeignUnitSnapshot.metadata(unit, ownerId, bucket)` since it discovers units one plot at a time rather than via the global slot walk in `collect()`.
