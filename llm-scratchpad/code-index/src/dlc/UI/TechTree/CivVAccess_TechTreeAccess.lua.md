# `src/dlc/UI/TechTree/CivVAccess_TechTreeAccess.lua`

741 lines · TabbedShell accessibility handler for the TechTree popup, combining a hand-rolled spatial/DAG navigation tree tab with a BaseMenu queue tab, type-ahead search, era boundary announcements, and three commit modes (normal, free, stealing).

## Header comment

```
-- Tech Tree screen accessibility. Wraps the in-game TechTree Context
-- (BUTTONPOPUP_TECH_TREE) as a TabbedShell with two tabs:
--
--   Tree    hand-rolled tab object; two arrow-key navigation modes that
--           the user toggles with Space.
--             grid (default) walks the visual layout: Up/Down through the
--             era column at the cursor's GridX (skipping rows with no tech
--             at that GridX, silent at edges); Left/Right step exactly one
--             column at a time, snapping to whichever tech in the adjacent
--             column is nearest a sticky "intended row" the user committed
--             to with their last Up/Down move (silent when no tech at all
--             exists in the adjacent column). Spatial nav is path-
--             independent so the user can cut across to a peer tech they
--             remember without retracing prereq edges; the intended-row
--             stickiness keeps a horizontal run anchored to the chosen
--             row instead of drifting away through ragged columns.
--             tree walks the prereq DAG: Right to a child (dependent
--             tech), Left to a parent (prerequisite), Up/Down across
--             siblings (children of the parent we descended from, or the
--             parents of the child we ascended to). NavigableGraph owns
--             the pure DAG cursor; tech-specific adjacency lambdas,
--             label composition, and commit eligibility live in
--             CivVAccess_TechTreeLogic so offline tests can exercise them
--             without dofiling this wrapper.
--           Mode toggle preserves the cursor; siblings are reseeded so
--           tree mode's Up/Down has a fresh sibling list around wherever
--           the cursor is. Help entries swap on toggle: only the active
--           mode's arrow descriptions are listed under ?.
--           Enter / Shift+Enter commits via Network.SendResearch in
--           either mode. Type-ahead search across tech name + unlocks
--           prose works in either mode.
--           Era boundary announcement: when an arrow move lands on a
--           tech in a different era than the previous cursor position,
--           the era display name prefixes the landing speech ("Classical
--           Era. Banking, available, ..."). Same-era moves don't repeat
--           it. Skipped on search-driven jumps (the search target is
--           usually far from the prior cursor; the era word adds noise),
--           but _prevEraID is updated silently so the next arrow move
--           compares against the searched-to era.
--   Queue   TabbedShell.menuTab over a BaseMenu list. Items are rebuilt
--           on every onTabActivated so the queue reflects post-commit
--           state when the user Tabs over after queuing a tech. Era
--           announcement is tree-tab-only -- the queue is a flat list
--           ordered by queue slot, not era.
-- ...
```

## Outline

- L107: `local priorInput = InputHandler`
- L108: `local priorShowHide = ShowHideHandler`
- L110: `local MOD_NONE = 0`
- L111: `local MOD_SHIFT = 1`
- L112: `local MOD_CTRL = 2`
- L115: `local _stealingTargetID = -1`
- L119: `local _graph = nil`
- L120: `local _cursor = nil`
- L121: `local _corpus = nil`
- L122: `local _search = nil`
- L123: `local _grid = nil`
- L126: `local _navMode = "grid"`
- L133: `local _prevEraID = nil`
- L142: `local _intendedGridY = nil`
- L146: `local _shellHandler = nil`
- L150: `local _gridHelpEntries = nil`
- L151: `local _treeHelpEntries = nil`
- L153: `local _treeTab = nil`
- L155: `local function currentPlayer()`
- L159: `local function currentMode()`
- L165: `local function speakLanding(techID)`
- L176: `local function speakLandingNoEra(techID)`
- L186: `local function commit(shift)`
- L244: `local function clearSearch()`
- L250: `local function buildSearchable()`
- L272: `local function gridMove(axis, dir)`
- L285: `local function treeRight()`
- L292: `local function treeLeft()`
- L299: `local function treeUp()`
- L306: `local function treeDown()`
- L313: `local function onUp()`
- L322: `local function onDown()`
- L331: `local function onLeft()`
- L340: `local function onRight()`
- L351: `local function onToggleMode()`
- L406: `local function openPediaForCurrent()`
- L416: `local function closer()`
- L421: `local function treeHandleSearchInput(_handler, vk, mods)`
- L448: `local bind = HandlerStack.bind`
- L453: `local function buildBaseHelpEntries()`
- L486: `local function withModeNav(modeDescKey)`
- L499: `local function buildTreeTab()`
- L574: `local function buildQueueItems()`
- L615: `local function buildQueueTab()`
- L644: `local function setupForShow()`
- L672: `local function wrappedPriorShowHide(bIsHide, bIsInit)`
- L700: `TabbedShell.install(ContextPtr, { name = "TechTreeScreen", tabs = { buildTreeTab(), buildQueueTab() }, ... })`
- L735: `Events.SerialEventGameMessagePopup.Add(function(popupInfo) ... _stealingTargetID = popupInfo.Data2 ... end)`

## Notes

- L115 `_stealingTargetID`: captured via a `SerialEventGameMessagePopup` listener (L735) because the stock `TechTree.lua`'s `OnDisplay` keeps the target in a chunk-local that is unreachable from this appended include.
- L133 `_prevEraID`: initialized to `nil` on each screen open so the very first landing always announces the era; updated by every speech path (arrow, search, mode toggle) so subsequent comparisons are correct.
- L142 `_intendedGridY`: the "sticky row" for grid-mode horizontal nav - updated only on Up/Down moves, consulted but not changed on Left/Right moves, so a horizontal run through ragged columns doesn't drift.
- L272 `gridMove`: `axis = "column"` is Up/Down (within one GridX column); `axis = "row"` is Left/Right (stepping to an adjacent GridX column). The axis names are relative to the grid layout, not the keyboard direction.
- L421 `treeHandleSearchInput`: Space is only forwarded to the search buffer when a search is already active; an empty-buffer Space falls through to the binding for `onToggleMode`.
