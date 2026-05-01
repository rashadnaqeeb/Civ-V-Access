# `src/dlc/UI/InGame/CivVAccess_ForeignUnitSnapshot.lua`

110 lines · Shared helpers for walking visible-to-active-team foreign units into a keyed metadata snapshot.

## Header comment

```
-- Shared helpers for walking visible-to-active-team foreign units into a
-- keyed metadata snapshot. Used by both ForeignUnitWatch (turn-start
-- speech of foreign units that entered or left view during the AI turn)
-- and RevealAnnounce (post-move speech of newly visible / hidden units).
-- The two callers share the visibility filter (IsVisible AND not
-- IsInvisible, mirroring ScannerBackendUnits) and the {count} {civ adj}
-- {unit name} list rendering, but each owns its own per-unit bucket
-- vocabulary ("hostile" / "neutral" vs "enemy" / "other") because their
-- downstream consumers key on different strings.
```

## Outline

- L11: `ForeignUnitSnapshot = {}`
- L17: `function ForeignUnitSnapshot.unitKey(ownerId, unitId)` -> "<ownerId>:<unitId>"
- L25: `function ForeignUnitSnapshot.metadata(unit, ownerId, bucket)` -> per-unit { ownerId, unitId, civAdjKey, unitDescKey, bucket }
- L41: `function ForeignUnitSnapshot.collect(bucketFn)` -> { ["<ownerId>:<unitId>"] = metadata, ... }
- L84: `function ForeignUnitSnapshot.formatList(entries)` -> "{count} <civ adj> <unit name>" sorted, comma-joined

## Notes

- `bucketFn(ownerId, activePlayerId, activeTeam)` returns the per-unit bucket label (e.g. "hostile", "enemy") or nil to drop the unit.
- `collect()` already gates on the owner being alive, so per-bucket functions don't need their own IsAlive check.
- `metadata()` is exposed for the RevealAnnounce plot-walk path which collects units one plot at a time rather than via the slot walk.
