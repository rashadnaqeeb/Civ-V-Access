# `src/dlc/UI/InGame/CivVAccess_Turn.lua`

291 lines · Announces turn start/end and drives Ctrl+Space (end turn with blocker handling) and Ctrl+Shift+Space (force end turn), including multiplayer submit and un-ready speech.

## Header comment

```
-- Turn lifecycle announcements and the player's end-turn keybindings.
--
-- ActivePlayerTurnStart -> "Turn N, year". Fires on every turn start and on
-- the first turn after LoadScreenClose; no special-casing needed because
-- the first-turn announcement reads correctly as "game started at turn 0,
-- 4000 BC" on its own.
--
-- ActivePlayerTurnEnd -> "Turn ended". Covers our Ctrl+Space path plus any
-- engine-internal auto-end [...].
--
-- Ctrl+Space dispatches the same branches the base EndTurn button callback
-- runs [...]: read GetEndTurnBlockingType; on a blocker, announce the
-- matching TXT_KEY and delegate to the engine's "take me to the blocker"
-- action [...]; on no blocker, DoControl(CONTROL_ENDTURN) [...].
--
-- Ctrl+Shift+Space mirrors the engine's Shift+Return. [...] We read the
-- blocker in Lua first and, for the bypassable cases, call DoControl;
-- otherwise we fall through to the same announce-and-open path as
-- Ctrl+Space.
--
-- Multiplayer feedback: in networked MP, Events.ActivePlayerTurnEnd does
-- not fire on submit -- it fires when the wave actually completes -- so
-- the submit-time speech has to come from the dispatcher itself [...].
--
-- Multiplayer un-ready: if the player already submitted (HasSentNetTurn-
-- Complete) pressing Ctrl+Space un-readies them [...].
```

## Outline

- L43: `Turn = {}`
- L45: `local MOD_SHIFT = 1`
- L46: `local MOD_CTRL = 2`
- L47: `local MOD_CTRL_SHIFT = MOD_CTRL + MOD_SHIFT`
- L59: `local BLOCKER_TXT_KEY = { ... }`
- L89: `local UNIT_BLOCKERS = { ... }`
- L94: `local function speak(text)`
- L101: `local function blockerText(player, blockerType)`
- L122: `local function focusBlockerUnit(player, blockerType)`
- L145: `local function announceAndOpenBlocker(player, blockerType)`
- L157: `local function passEndTurnGates(player)`
- L182: `local function announceSubmitted()`
- L188: `local function endTurnDispatch()`
- L202: `local function forceEndTurn()`
- L223: `local function onActivePlayerTurnStart()`
- L240: `local function onActivePlayerTurnEnd()`
- L244: `local bind = HandlerStack.bind`
- L246: `function Turn.getBindings()`
- L269: `function Turn.installListeners()`
- L289: `Turn._endTurnDispatch = endTurnDispatch`
- L290: `Turn._forceEndTurn = forceEndTurn`

## Notes

- L289-290 `Turn._endTurnDispatch`, `Turn._forceEndTurn`: test seams exposing the private local functions.
