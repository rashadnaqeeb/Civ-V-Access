# `src/dlc/UI/InGame/CivVAccess_UnitTargetMode.lua`

853 lines · HandlerStack handler pushed when an action menu commits a targeted action; owns Space (preview), Enter (commit), Shift+Enter (queue), Escape (cancel), Tab (switch verb), and no-op blocks for Alt+QAZEDC and Alt-letter quick actions.

## Header comment

```
-- Target-mode handler. Pushed above the baseline stack when the action
-- menu commits a targeted action (attack, range strike, move-to, etc.).
-- The actor is the selected unit; the cursor is the target. Space speaks
-- a per-mode trial preview; Enter commits; Esc cancels; Tab reopens the
-- action menu to switch verb.
--
-- capturesAllInput = false: cursor movement (QAZEDC), cursor info queries
-- (S/W/X/1/2/3 and the Shift-letter surveyor cluster), and scanner cycling
-- fall through to Baseline / Scanner unchanged. Only keys whose target-
-- mode behavior must differ from Baseline are bound here. Alt+QAZEDC and
-- the Alt-letter quick actions (F/S/W/H/P/R/U, Alt+Space) are bound as
-- no-ops [...].
--
-- Preview math clones base-game EnemyUnitPanel.lua:655-707 (bidirectional
-- GetCombatDamage for melee, GetRangeCombatDamage for ranged). The move-
-- to preview runs Unit:GeneratePath / Unit:GetPath (engine fork bindings)
-- and speaks MP cost + turn count.
```

## Outline

- L28: `UnitTargetMode = {}`
- L30: `local MOD_NONE = 0`
- L31: `local MOD_SHIFT = 1`
- L32: `local MOD_ALT = 4`
- L37: `local MOVE_DECLARE_WAR = 0x00000020`
- L43: `local _currentActorID = nil`
- L45: `function UnitTargetMode.currentActorID()`
- L49: `local function restoreSelection()`
- L53: `local function speakInterrupt(text)`
- L60: `local function cursorPlot()`
- L76: `local function formatMP(mp60ths)`
- L85: `local function movePathPreview(actor, targetPlot)`
- L196: `local function rangedPreview(actor, defender, targetPlot, targetX, targetY)`
- L209: `local function defenderAt(plot, ranged, actor)`
- L264: `local function enemyCityAt(plot)`
- L286: `local function isRangeAttackMode(mode)`
- L290: `local function isMeleeAttackMode(mode)`
- L294: `local function isMoveMode(mode)`
- L300: `local function isRouteMode(mode)`
- L310: `local function legalityPreview(canTarget, illegalKey, plot)`
- L325: `local function airSweepPreview(actor, plot)`
- L350: `local function plotBuildTurns(plot, buildId, routeValue, extraRate, isStartPlot)`
- L368: `local function routePathPreview(actor, targetPlot)`
- L414: `local function combatPreviewAt(actor, plot, tx, ty, ranged)`
- L432: `local function buildPreview(self)`
- L561: `local function willCauseCombat(actor, plot, mode)`
- L586: `local function commitFailureReason(actor, mode, plot, tx, ty)`
- L697: `local function commitAtCursor(self, queued)`
- L775: `local bind = HandlerStack.bind`
- L782: `function UnitTargetMode.enter(actor, iAction, mode)`

## Notes

- L432 `buildPreview`: named "build" in the sense of composing/assembling the preview string, not worker build actions.
- L697 `commitAtCursor`: `queued=true` corresponds to Shift+Enter (waypoint append); the first shift+enter with an empty queue is silently treated as a plain push to work around an engine quirk where bAppend on an empty queue leaves no active head mission.
- L209 `defenderAt`: peaceful rivals are excluded by the at-war filter and require a manual fallback scan for ranged mode only; melee and move modes intentionally omit the fallback.
