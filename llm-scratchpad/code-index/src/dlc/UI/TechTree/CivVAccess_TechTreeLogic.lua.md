# `src/dlc/UI/TechTree/CivVAccess_TechTreeLogic.lua`

417 lines · Pure logic library for TechTreeAccess covering DAG graph construction, status determination, landing speech, queue speech, grid navigation, era boundary prefixes, commit eligibility, and initial cursor placement; testable offline.

## Header comment

```
-- Pure helpers for TechTreeAccess. No ContextPtr / Events surface so
-- offline tests can exercise status determination, landing-speech shape,
-- queue-row composition, and NavigableGraph wiring without dofiling the
-- install-side access file.
--
-- buildGraph caches adjacency at screen-open time. Engine-side tech data
-- (GameInfo.Technology_PrereqTechs, GridY, ID) is static across a session,
-- so memoization is safe; the NavigableGraph cursor still honors the
-- lambda-per-call contract at its abstraction level.
--
-- Status tokens describe the baseline game state (researched / current /
-- available / unavailable / locked), independent of mode. Mode-specific
-- rejection messages live in commitEligibility; the tree landing speech
-- does not filter by mode so browsing stays predictable across all three.
```

## Outline

- L16: `TechTreeLogic = {}`
- L18: `local function sortTechs(list)`
- L30: `function TechTreeLogic.buildGraph()`
- L72: `function TechTreeLogic.statusKey(player, techID)`
- L92: `local function unlocksProse(techID, techName)`
- L103: `function TechTreeLogic.buildSearchCorpus()`
- L119: `function TechTreeLogic.seedCursorSiblings(cursor, tech, graph)`
- L132: `function TechTreeLogic.buildLandingSpeech(techID, player)`
- L163: `function TechTreeLogic.buildQueueRows(player)`
- L181: `function TechTreeLogic.buildQueueRowSpeech(row, player)`
- L203: `function TechTreeLogic.currentMode(player, stealingTargetID)`
- L227: `function TechTreeLogic.commitEligibility(player, techID, mode, stealingTargetID)`
- L272: `function TechTreeLogic.buildGrid()`
- L300: `function TechTreeLogic.gridNeighbor(grid, tech, axis, dir, intendedGridY)`
- L346: `function TechTreeLogic.eraID(techID)`
- L356: `function TechTreeLogic.eraName(techID)`
- L375: `function TechTreeLogic.eraPrefix(prevEraID, newTechID)`
- L395: `function TechTreeLogic.pickInitialCursor(player, graph)`
- L416: `return TechTreeLogic`

## Notes

- L72 `TechTreeLogic.statusKey`: returns a `TXT_KEY_*` string (not the localized text) so callers control the speech composition; `buildLandingSpeech` resolves the key via `Text.key`.
- L119 `TechTreeLogic.seedCursorSiblings`: when a tech has no parents (root), uses `graph.getRoots()` as the sibling set; otherwise uses the children of the first parent, matching what the user would get by navigating down from that parent.
- L227 `TechTreeLogic.commitEligibility`: normal mode allows techs whose prereqs are not yet met because `Network.SendResearch` auto-queues unmet prereqs; only `HasTech` (already researched) and `!CanEverResearch` (locked) are hard rejects in normal mode.
- L375 `TechTreeLogic.eraPrefix`: when the new era exists but its `Description` key is missing, still advances `prevEraID` to the new era so a subsequent move into a third, fully-described era doesn't falsely announce twice.
- L300 `TechTreeLogic.gridNeighbor`: for `axis = "row"` (Left/Right), tiebreaks equal-distance candidates by preferring smaller `GridY` (visually higher), which is free because `byColumn` is already sorted ascending.
