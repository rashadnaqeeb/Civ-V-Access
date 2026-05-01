# `src/dlc/UI/InGame/CivVAccess_UnitControlCombat.lua`

499 lines · Two-tap melee-confirm state, preflight attack gates, and engine-event listeners for combat / air-sweep / nuclear / city-capture announcements.

## Header comment

```
-- Combat-resolution half of the unit-control split. Owns the two-tap
-- melee-attack confirm state (consumed by Movement's directMove), the
-- preflight-attack gates that compose combat-preview text, and every
-- engine-event listener for combat / nuke / city-capture announcements.
-- No bindings of its own.
--
-- Combat moves don't register a pending. The engine fork's
-- CivVAccessCombatResolved GameEvent fires synchronously from
-- CvUnitCombat::ResolveCombat for every unit-attacker melee / ranged
-- combat against units and cities, regardless of Quick Combat, with a
-- payload covering both sides' damage / final HP / max HP. The Lua
-- listener (onCombatResolved below) is the sole speech path for combat;
-- there is no fallback timer, no per-side snapshot, and no Events
-- listener race. The engine's own Events.EndCombatSim and
-- SerialEventCitySetDamage signals are not subscribed to -- they would
-- only double-speak the result the hook already announced.
--
-- Nuclear strikes are accumulated between NukeStart and NukeEnd so a
-- single composed speech line covers the whole strike rather than per-
-- entity speech (verbose) or just the header (loses info). Names are
-- resolved at hook-fire time because destroyed cities lose their handle
-- when the engine's pkCity->kill() runs after NukeCityAffected.
```

## Outline

- L24: `UnitControlCombat = {}`
- L26: `local COMBAT_CONFIRM_WINDOW_SECONDS = 1.0`
- L31: `local _combatConfirm = { dir = nil, clock = 0 }`
- L33: `function UnitControlCombat.clearCombatConfirm()`
- L42: `function UnitControlCombat.consumeCombatConfirm(dir)`
- L51: `function UnitControlCombat.armCombatConfirm(dir)`
- L56: `local function speakQueued(text)`
- L73: `function UnitControlCombat.preflightAttack(unit)`
- L117: `function UnitControlCombat.preflightAttackTarget(unit, target)`
- L158: `local function onCombatResolved(...)`
- L267: `local function onAirSweepNoTarget(attackerPlayer, _attackerUnit)`
- L287: `local _nukeBuffer = nil`
- L295: `local function nukeCityDisplayName(playerId, cityId)`
- L307: `local function onNukeStart(...)`
- L342: `local function onNukeUnitAffected(defenderPlayer, defenderUnit, damageDelta, finalDamage, maxHP)`
- L358: `local function onNukeCityAffected(...)`
- L383: `local function nukeBufferInvolvesActivePlayer(buf, activePlayer)`
- L400: `local function onNukeEnd(_attackerPlayer)`
- L419: `local function onCityCaptured(_hexPos, oldOwner, cityId, newOwner)`
- L447: `function UnitControlCombat.installListeners()`

## Notes

- L31 `_combatConfirm`: module-local so a Context re-entry drops any in-flight confirm window; not stored on `civvaccess_shared`.
- L42 `UnitControlCombat.consumeCombatConfirm`: returns true and clears on a direction match within the window; returns false without arming on a miss (caller must call `armCombatConfirm` separately to start the window).
- L158 `onCombatResolved`: AI-vs-AI combat on a plot visible to the active team is announced only when at least one side is known; both sides invisible on a visible plot stays silent. The `attackerCity` field covers city-as-attacker (e.g., city bombardment) so `attackerUnit` alone is insufficient for attacker identity.
- L287 `_nukeBuffer`: module-local accumulator; `onNukeStart` allocates it, `onNukeUnitAffected` / `onNukeCityAffected` append, `onNukeEnd` flushes and nils; a Context re-entry drops any half-flushed buffer.
