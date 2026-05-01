# `src/dlc/UI/InGame/CivVAccess_ForeignUnitWatch.lua`

303 lines · Snapshot-diff watcher that announces foreign units entering or leaving the active team's view at each TurnStart, split into hostile-entered, hostile-left, neutral-entered, neutral-left lines.

## Header comment

```
-- Speaks up to four lines at the start of every player turn covering
-- foreign units that entered or walked out of the active team's view
-- during the AI turn just past. Splits hostile (at-war + barb) from
-- neutral (every foreign owner you can see who isn't at war with you,
-- civilians included). The same lines (as a flat array of non-empty
-- strings) are parked on civvaccess_shared so NotificationLogPopupAccess
-- can prepend them at the top of F7 for the duration of the player's
-- turn.
-- [...]
```

## Outline

- L59: `ForeignUnitWatch = {}`
- L63: `local _snapshot = {}`
- L65: `local function globalKey(ownerId, unitId)`
- L71: `local function classifyOwner(ownerId, activePlayerId, activeTeam)`
- L96: `local function unitMetadata(unit, ownerId, bucket)`
- L113: `local function buildVisibleSet()`
- L150: `local function formatList(entries)`
- L180: `local function formatLine(entries, txtKey)`
- L187: `function ForeignUnitWatch._onTurnEnd()`
- L197: `function ForeignUnitWatch._onTurnStart()`
- L289: `function ForeignUnitWatch.installListeners()`

## Notes

- L63 `_snapshot`: Module-local; dies on env reload (load-from-game). installListeners primes it from current visibility so the first diff doesn't announce every visible foreign unit as newly entered.
- L187 `_onTurnEnd`: Takes the snapshot (not clears it); `_onTurnStart` does the diff and then replaces `_snapshot` with the fresh current set.
