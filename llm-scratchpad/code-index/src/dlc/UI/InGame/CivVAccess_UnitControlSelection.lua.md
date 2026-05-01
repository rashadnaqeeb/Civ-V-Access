# `src/dlc/UI/InGame/CivVAccess_UnitControlSelection.lua`

280 lines · Unit cycle / info / recenter bindings and the UnitSelectionChanged listener, including a time-windowed user-vs-engine selection-origin discriminator.

## Header comment

```
-- Unit selection / cycling / info-readout half of the unit-control split.
-- Owns the two cycle bindings (./,) and their Ctrl variants (whole-list
-- cycling that ignores the engine's ReadyToSelect filter), the ? info
-- key, and the Ctrl+? recenter-cursor-on-selected-unit binding. Also
-- owns the UnitSelectionChanged listener that announces newly selected
-- units, including the user-vs-engine origin discriminator.
--
-- Speech policy: user-initiated selection (cycle keys) interrupts;
-- engine-driven selection (turn start, unit death, end of move/combat
-- reselection) queues. UnitSelectionChanged fires for both, so cycle
-- sites stamp a short-lived "user-initiated" timestamp the listener
-- consumes if fresh. Time-based staleness (USER_SELECTION_WINDOW_SECONDS)
-- handles the case where the engine drops the selection request
-- (Game.CycleUnits with no eligible target) so the flag doesn't leak
-- into a later engine-driven selection.
```

## Outline

- L17: `UnitControlSelection = {}`
- L19: `local MOD_NONE = 0`
- L20: `local MOD_CTRL = 2`
- L23: `local VK_OEM_COMMA = 188`
- L24: `local VK_OEM_PERIOD = 190`
- L25: `local VK_OEM_2 = 191`
- L27: `local USER_SELECTION_WINDOW_SECONDS = 0.1`
- L28: `local _userSelectionAt = -math.huge`
- L31: `function UnitControlSelection.markUserInitiatedSelection()`
- L35: `local function consumeUserInitiatedSelection()`
- L43: `local function speakInterrupt(text)`
- L50: `local function speakQueued(text)`
- L57: `local function selectedUnit()`
- L66: `function UnitControlSelection.cycleAll(forward)`
- L77: `function UnitControlSelection.cycleAllUnits(forward)`
- L145: `local function speakInfo()`
- L165: `local function recenterOnUnit()`
- L173: `local function onUnitSelectionChanged(playerID, unitID, _hexI, _hexJ, _hexK, isSelected)`
- L227: `local bind = HandlerStack.bind`
- L229: `function UnitControlSelection.getBindings()`
- L269: `function UnitControlSelection.installListeners()`

## Notes

- L66 `UnitControlSelection.cycleAll`: wraps `Game.CycleUnits`; the `forward=true` direction maps to "next" in the base-game cycling sense (CycleLeft button), not leftward spatially.
- L77 `UnitControlSelection.cycleAllUnits`: uses the engine fork's `Game.GetCycleUnits()` to bypass the ReadyToSelect filter, allowing cycling over already-moved units; walks the list manually via `UI.SelectUnit`.
- L173 `onUnitSelectionChanged`: suppressed while `CityRangeStrike` is the top handler to avoid stealing focus from strike-target readout during a delayed engine re-select; also unwinds `UnitTargetMode` if the newly selected unit differs from the target-mode actor.
