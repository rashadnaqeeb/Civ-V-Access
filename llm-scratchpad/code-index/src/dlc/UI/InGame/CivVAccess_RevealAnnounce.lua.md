# `src/dlc/UI/InGame/CivVAccess_RevealAnnounce.lua`

642 lines · Announces reveal, hide, and gone events after unit moves so blind players know what just entered or left their line of sight.

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
- L232: `local function unitOwnerBucket(ownerId, activePlayerId, activeTeam)`
- L254: `local function resourceName(resourceId)`
- L262: `local function visibilityKey(ownerId, unitId)`
- L274: `local function unitVisibilityMetadata(unit, ownerId, bucket)`
- L291: `local function buildVisibleForeignUnits()`
- L324: `local function formatUnitList(entries)`
- L358: `function RevealAnnounce._flush()`
- L365: `function RevealAnnounce._flushBody()`
- L592: `function RevealAnnounce._onTurnStart()`
- L605: `function RevealAnnounce.installListeners()`
- L624: `GameEvents.CivVAccessPlotRevealed.Add(recordFirstReveal)`
- L631: `Events.HexFOWStateChanged.Add(recordNowVisible)`
- L636: `Events.ActivePlayerTurnStart.Add(RevealAnnounce._onTurnStart)`

## Notes

- L79 `_flushTargetFrame`: Set to -1 when no flush is pending; `scheduleFlush` sets it to current frame + `FLUSH_DELAY_FRAMES` so both the synchronous `CivVAccessPlotRevealed` and the deferred `HexFOWStateChanged` events land in the same buffer before speaking.
- L205 `shouldSkipPlot`: Suppresses natural wonders, goody huts, and barbarian camps from the reveal *payload* (not the count) because the engine fires its own popups for those; the tile still increments the revealed-tile headline count.
- L365 `RevealAnnounce._flushBody`: The "gone" diff reads `GetImprovementType()` (live) and compares to the Lua snapshot rather than `GetRevealedImprovementType()` because `setRevealed` synchronously overwrites the engine's revealed-type before `HexFOWStateChanged` dispatches.
- L592 `RevealAnnounce._onTurnStart`: Silently rebuilds `_visibleUnits` at turn start so the first flush after the player's first move doesn't re-announce units that walked into fog during the AI turn.
