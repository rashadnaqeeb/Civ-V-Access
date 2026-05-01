# `src/dlc/UI/Shared/CivVAccess_NavigableGraph.lua`

157 lines · Domain-agnostic DAG cursor with four directional moves (Up/Down/Left/Right as parent/child/sibling) built as a constructor so independent cursors can coexist.

## Header comment

```
-- Domain-agnostic DAG cursor. Four directional moves collapse the graph:
-- Up to a parent, Down to a child, Left / Right cycle among siblings.
-- "Sibling" is the list produced by the last vertical move (children of
-- the node we came from after Down, parents after Up). At a root, the
-- sibling list is the full root set so Left / Right walks across the
-- top. Nodes are opaque values; callers supply three lambdas that agree
-- on node identity, and all neighbor lookups go through the lambdas on
-- demand (no adjacency caching). If the underlying graph mutates between
-- moves, the cursor sees the new shape on the next call.
-- [... full contract comment ...]
```

## Outline

- L33: `NavigableGraph = {}`
- L35: `local function findIndex(list, node)`
- L44: `function NavigableGraph.new(config)`
- L61: `function self.current()`
- L65: `function self.hasParents()`
- L72: `function self.hasChildren()`
- L78: `function self.hasSiblings()`
- L82: `function self.moveTo(node)`
- L88: `function self.moveToWithSiblings(node, siblings)`
- L94: `function self.navigateDown()`
- L113: `function self.navigateUp()`
- L134: `function self.cycleSibling(dir)`
- L152: `return self`
- L156: `return NavigableGraph`

## Notes

- L113 `self.navigateUp`: when the new current is itself a root, swaps the sibling list to `getRoots()` so Left/Right walks the root set rather than the one-off parent list of the previous node.
- L134 `self.cycleSibling`: returns `(nil, false)` when there are fewer than two siblings rather than silently wrapping to the same node.
