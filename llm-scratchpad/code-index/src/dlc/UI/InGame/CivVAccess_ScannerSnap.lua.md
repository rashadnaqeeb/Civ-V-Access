# `src/dlc/UI/InGame/CivVAccess_ScannerSnap.lua`

276 lines · Snapshot builder that turns a flat ScanEntry list into the nested category/subcategory/item/instance tree, plus locate-by-key and prune-by-instance for mid-snapshot validation.

## Header comment

```
-- Snapshot builder. Turns a flat list of ScanEntry tables into the
-- nested category -> subcategory -> item -> instance structure the
-- navigator walks. Also owns prune-by-instance for the mid-snapshot
-- validation path (ValidateEntry returns false on the current instance).
--
-- Sort order (design section 5):
--   instances within an item      distance ascending (live cursor at
--                                 build time), then sortKey, then
--                                 plotIndex as a stable tiebreaker
--   items within a subcategory    nearest-instance distance ascending
--   subcategories                 taxonomy order with `all` at index 1
--   categories                    taxonomy order
--
-- Shape returned: [...]
--
-- `all` subcategory shares item references with the named sibling that
-- first produced each item. Pruning an item from a named sub also
-- removes it from `all` by identity; ScannerSnap.pruneInstance does the
-- bookkeeping.
--
-- Two emission modes for backends:
--   1. Named-sub: entry.subcategory is one of the category's declared
--      named subs. The item lands in that sub AND gets shared into
--      `all` by reference.
--   2. All-direct: the category has `subcategories = {}` and entries
--      emit `subcategory = "all"`. The item lands in `all` only; there
--      is no named-sib share step because there are no siblings.
```

## Outline

- L51: `ScannerSnap = {}`
- L53: `local function newCategory(catDef)`
- L83: `local function sortSnapshot(snapshot)`
- L112: `function ScannerSnap.build(entries, cursorX, cursorY)`
- L205: `function ScannerSnap.locate(snapshot, key, hintCatIdx, hintSubIdx)`
- L247: `function ScannerSnap.pruneInstance(snapshot, catIdx, subIdx, itemIdx, instIdx)`

## Notes

- L205 `ScannerSnap.locate`: checks the hint (catIdx, subIdx) first so a user in a named sub stays there even though the same item also exists in the shared `all` sub.
- L247 `ScannerSnap.pruneInstance`: when an item empties out it is removed from every sub in the same category that holds it by identity, maintaining the `all`-shares-refs invariant.
