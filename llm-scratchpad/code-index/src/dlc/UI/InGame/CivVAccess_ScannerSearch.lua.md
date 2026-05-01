# `src/dlc/UI/InGame/CivVAccess_ScannerSearch.lua`

158 lines · Builds a synthetic snapshot from a type-ahead query against all backend entries, organizing results into per-original-category subcategories sorted by match tier then distance.

## Header comment

```
-- Scanner search filter. Runs every backend entry's itemName through
-- TypeAheadSearch.matchTier against a user query and emits a synthetic
-- snapshot: one category ("search"), with subcategories keyed by the
-- entries' original category. Items sort by (match tier ascending, then
-- nearest-instance distance), so start-of-string hits surface before
-- substring hits within each original-category bucket.
--
-- The synthetic snapshot has the same shape as ScannerSnap.build output so
-- ScannerNav walks it with no special-case code. The `isSearch` flag lets
-- Nav know the current snapshot should be discarded on the next category
-- cycle rather than preserved across rebuilds (section 8).
```

## Outline

- L13: `ScannerSearch = {}`
- L15: `local function newSub(key, label)`
- L26: `function ScannerSearch.build(entries, query, cursorX, cursorY)`

## Notes

- L26 `ScannerSearch.build`: returns nil (not an empty snapshot) when no entries match, so the caller can speak the no-match token without installing a dead snapshot.
