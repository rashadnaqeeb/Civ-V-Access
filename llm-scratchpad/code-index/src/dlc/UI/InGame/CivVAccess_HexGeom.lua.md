# `src/dlc/UI/InGame/CivVAccess_HexGeom.lua`

284 lines · Shared hex-grid math: direction string decomposition, run-length-encoded path step strings, capital-relative coordinate strings, cube distance, clockwise-from-E direction rank, and range ring plot enumeration.

## Header comment

```
-- Shared hex-grid math. directionString turns a (from) to (to) delta
-- into the spoken cardinal form ("4e, 5ne") that the scanner's End key
-- and the surveyor rely on. coordinateString turns a plot's offset
-- coords into a capital-relative (x, y) pair for Shift+S, the optional
-- cursor-move prefix, and the optional scanner coord splice. Composition
-- in one place guarantees byte-identical output across callers; a future
-- format change lands here and applies to all of them.
--
-- directionString contract: identical endpoints return the empty
-- string. Each caller supplies its own "at origin" TXT_KEY
-- (SCANNER_HERE for the scanner) rather than overloading this module
-- with a zero-delta token that every caller would want to override.
```

## Outline

- L14: `HexGeom = {}`
- L16: `local function offsetToCube(col, row)`
- L26: `local function cubeToOffset(x, _y, z)`
- L37: `local function decomposeCube(dx, dy, dz)`
- L56: `local OUTPUT_ORDER = {...}`
- L68: `local function dirKey(dir)`
- L87: `function HexGeom.directionString(fromX, fromY, toX, toY)`
- L110: `function HexGeom.stepListString(directions)`
- L136: `local NEIGHBOR_DIRS = {...}`
- L144: `function HexGeom.stepListFromPath(path)`
- L177: `local MAX_PLAYER_INDEX_FOR_CAPITAL = ...`
- L179: `local function activeOriginalCapital()`
- L206: `function HexGeom.coordinateString(x, y)`
- L227: `function HexGeom.cubeDistance(x1, y1, x2, y2)`
- L238: `local DIRECTION_RANK = { E = 1, SE = 2, SW = 3, W = 4, NW = 5, NE = 6 }`
- L240: `function HexGeom.directionRank(cx, cy, tx, ty)`
- L261: `function HexGeom.plotsInRange(cx, cy, r)`

## Notes

- L110 `stepListString`: Distinct from directionString - this takes an ordered list of step directions (from a pathfinder node chain) and run-length-encodes them; directionString decomposes a single endpoint-to-endpoint delta.
- L179 `activeOriginalCapital`: Searches across all player city lists for IsOriginalCapital() + GetOriginalOwner() == active player, so it finds the original capital even if it was captured by an enemy.
