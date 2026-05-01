# `src/dlc/UI/InGame/CivVAccess_MessageBuffer.lua`

313 lines · Session-scoped scrollable review buffer for speech-worthy events, navigable with [ / ] (prev/next), Ctrl+[/] (oldest/newest), and Shift+[/] (cycle category filter).

## Header comment

```
-- Session-scoped scrollable history of speech-worthy events. Producers
-- (NotificationAnnounce, RevealAnnounce, ForeignUnitWatch, UnitControl
-- combat hooks) call MessageBuffer.append at the same callsite they hand
-- text to the speech pipeline; the user navigates the buffer with [ / ]
-- (with shift / ctrl modifiers) to review what's been spoken across the
-- session.
--
-- Append is opt-in per producer: cursor reads, scanner navigation, UI
-- chatter all flow through SpeechPipeline too, but they don't belong in
-- the buffer (the user invoked them directly and won't want to scroll
-- back to them). New producers must explicitly add an append() call to
-- show up in the buffer.
--
-- State lives on civvaccess_shared so cross-Context producers (chat in
-- multiplayer, eventually) can call append without re-including this
-- module's globals. Reset on every onInGameBoot: load-game-from-game
-- would otherwise carry entries from a different game (different units,
-- different turns, no relation to the current map state). Cap evictions
-- shift position by one so the cursor tracks the same logical entry; an
-- evicted-out-of-band cursor clamps to the new oldest rather than
-- becoming "uninitialized" which would feel like losing your place.
```

## Outline

- L23: `MessageBuffer = {}`
- L31: `local _cap = 5000`
- L37: `local FILTER_CYCLE = { "all", "notification", "reveal", "combat", "chat" }`
- L43: `local CATEGORIES = {...}`
- L50: `local function state()`
- L59: `local function matches(entry, filter)`
- L68: `local function walk(entries, filter, fromIdx, direction)`
- L80: `local function newestMatching(entries, filter)`
- L84: `local function oldestMatching(entries, filter)`
- L88: `local function speakText(text)`
- L92: `local function speakKey(key)`
- L100: `local function speakFilterChange(filter, entry)`
- L105: `function MessageBuffer.append(text, category)`
- L132: `function MessageBuffer.next()`
- L156: `function MessageBuffer.prev()`
- L177: `function MessageBuffer.jumpFirst()`
- L188: `function MessageBuffer.jumpLast()`
- L205: `local function rotateNonEmpty(entries, currentFilter, direction)`
- L232: `local function applyFilter(s, direction)`
- L248: `function MessageBuffer.cycleFilterForward()`
- L252: `function MessageBuffer.cycleFilterBackward()`
- L256: `function MessageBuffer._reset()`
- L262: `function MessageBuffer.installListeners()`
- L267: `function MessageBuffer._setCap(n)`
- L271: `function MessageBuffer._snapshot()`
- L275: `local VK_OEM_4 = 219`
- L276: `local VK_OEM_6 = 221`
- L278: `local MOD_NONE = 0`
- L279: `local MOD_SHIFT = 1`
- L280: `local MOD_CTRL = 2`
- L282: `local bind = HandlerStack.bind`
- L288: `function MessageBuffer.getBindings()`

## Notes

- L132 `next`: "Next" moves toward newer entries (higher index); position 0 means uninitialized and both next/prev enter at the newest matching entry on first press.
- L205 `rotateNonEmpty`: Skips empty filter categories; if the buffer is fully empty it exhausts all slots and returns nil so applyFilter speaks the bare empty marker.
