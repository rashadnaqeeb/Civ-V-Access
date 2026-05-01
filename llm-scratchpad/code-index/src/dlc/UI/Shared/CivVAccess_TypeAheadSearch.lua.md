# `src/dlc/UI/Shared/CivVAccess_TypeAheadSearch.lua`

507 lines · Type-ahead search engine with a six-tier match ranking (start-of-word whole-word down to arbitrary substring and space-delimited word-prefix abbreviation), used by `BaseMenu` and `BaseTable`.

## Header comment

```
-- Type-ahead search helper used by BaseMenu.
--
-- Tiers (lower wins):
--   0  start-of-string whole word ("wood" in "wood club")
--   1  start-of-string prefix     ("wood" in "wooden club")
--   2  mid-string whole word      ("wood" in "pine wood")
--   3  mid-string word prefix     ("wood" in "a wooden thing")
--   4  substring anywhere         ("wood" in "plywood")
--   5  space-delimited word-prefix abbreviation ("ga pi" in "gas pipe")
-- [... full tier/sort/consumer contract comment ...]
```

## Outline

- L47: `TypeAheadSearch = {}`
- L49: `local TIER_COUNT = 6`
- L53: `local function matchTier(lowerName, lowerPrefix)`
- L105: `function TypeAheadSearch._matchWordPrefixTokens(lowerName, lowerPrefix)`
- L156: `TypeAheadSearch.matchTier = matchTier`
- L160: `local Instance = {}`
- L161: `Instance.__index = Instance`
- L163: `function TypeAheadSearch.new()`
- L174: `function Instance:buffer()`
- L177: `function Instance:hasBuffer()`
- L180: `function Instance:isSearchActive()`
- L183: `function Instance:resultCount()`
- L187: `function Instance:selectedOriginalIndex()`
- L199: `function Instance:addChar(c)`
- L203: `function Instance:removeChar()`
- L210: `function Instance:clear()`
- L220: `local function isAllSameChar(s)`
- L230: `local function sortTier(indices, names, positions, sortLengths, inSegment, groups)`
- L264: `function Instance:search(itemCount, nameByIndex, moveTo, groupOf)`
- L375: `function Instance:_cycleStartsWithResults()`
- L396: `function Instance:navigateResults(direction)`
- L408: `function Instance:jumpToFirstResult()`
- L415: `function Instance:jumpToLastResult()`
- L423: `function Instance:_announceCurrentResult()`
- L440: `function Instance:handleChar(c, searchable)`
- L449: `local KEY_UP = 38`
- L450: `local KEY_DOWN = 40`
- L451: `local KEY_HOME = 36`
- L452: `local KEY_END = 35`
- L453: `local KEY_BACK = 8`
- L454: `local KEY_SPACE = 32`
- L457: `function Instance:handleKey(vk, ctrl, alt, searchable)`
- L506: `return TypeAheadSearch`

## Notes

- L264 `Instance:search`: when the buffer is a single repeated character (e.g. "aaa"), cycles within tier-0/1 results rather than re-running a full search, implementing "hold a key to cycle starters."
- L264 `Instance:search`: when `groupOf` is provided, group is the outermost sort axis (lower group number ranks before stronger-tier matches in a higher group).
- L105 `TypeAheadSearch._matchWordPrefixTokens`: exposed on the module table (not just local) as a test seam; rejects cross-comma-segment matches so position meaningfully identifies name vs description.
- L423 `Instance:_announceCurrentResult`: calls `self._moveTo` if set (the caller's cursor-move callback), falling back to `SpeechPipeline.speakInterrupt` on the result name only when no `moveTo` was provided.
