# `src/dlc/UI/InGame/Popups/CivVAccess_CityStateDiploPopupAccess.lua`

456 lines · Accessibility wrapper for BUTTONPOPUP_CITY_STATE_DIPLO with live dirty-rebuild, Give/Take drill sub-lists, and a BullyConfirm pushed sub; disabled actions shown as Text items rather than hidden.

## Header comment

```
-- CityStateDiploPopup accessibility. BUTTONPOPUP_CITY_STATE_DIPLO; single
-- Context, deferred items (payload-bound on popup event), live rebuild on
-- SerialEventGameDataDirty, Give / Take drills via setItems swap,
-- BullyConfirm as pushed sub.
--
-- Disabled actions are shown, not hidden: base renders them with warning-
-- color text plus a tooltip explaining why (need N influence, cooldown,
-- etc.), without calling SetDisabled on the button itself. The button's own
-- IsDisabled stays false; enablement is inferred from the anim-highlight
-- child (PledgeAnim, BuyoutAnim, SmallGiftAnim, etc.) which base hides in
-- the same branch that color-wraps the label. That anim hide is the
-- sighted cue and what we read.
--
-- BullyConfirm orchestration: base's Gold / Unit Tribute handlers set a
-- pending-action flag, show the overlay, and close TakeStack / restore
-- ButtonStack underneath. We rebuild root items BEFORE pushing the sub so
-- a No / Esc cancel lands on a menu that matches the visible stack. The
-- sub's onDeactivate hides the overlay as a belt-and-braces guard for the
-- Esc path, which bypasses base's Yes / No handlers.
--
-- Find On Map is skipped: the camera pan is a visual cue that doesn't
-- translate; a cursor-jump analogue would be scope expansion. Quest info
-- stays activatable but only for KILL_CAMP quests, matching base's own
-- narrow scope -- base only wires UI.LookAt for that quest type.
```

## Outline

- L49: `local priorInput = InputHandler`
- L50: `local priorShowHide = ShowHideHandler`
- L52: `local minorCivID = -1`
- L58: `Events.SerialEventGameMessagePopup.Add(...)`
- L64: `local function isVisible(controlName)`
- L69: `local function preambleText()`
- L81: `local mainHandler`
- L83: `local function infoRow(headerKey, textControl, tooltipControl, onActivate)`
- L101: `local function activateQuestInfo()`
- L122: `local function actionRow(spec)`
- L150: `local buildRootItems`
- L151: `local buildGiveItems`
- L152: `local buildTakeItems`
- L153: `local pushBullyConfirm`
- L155: `buildGiveItems = function()`
- L233: `buildTakeItems = function()`
- L271: `buildRootItems = function()`
- L379: `pushBullyConfirm = function()`
- L425: `mainHandler = BaseMenu.install(ContextPtr, { ... })`
- L445: `Events.SerialEventGameDataDirty.Add(...)`

## Notes

- L122 `actionRow`: infers enablement from whether an "anim" control is visible (the sighted highlight indicator), not from `IsDisabled`; returns a `Button` item when enabled and a `Text` item with a "disabled" label when not.
- L83 `infoRow`: renders a read-only status row that optionally calls an `onActivate` function on Enter (used only for quest info which jumps the cursor to a barbarian camp).
- L81 `mainHandler`: forward-declared nil because `buildGiveItems` and `buildTakeItems` reference it before `BaseMenu.install` at L425.
- L155-153: mutual recursion pattern -- `buildRootItems`, `buildGiveItems`, `buildTakeItems`, and `pushBullyConfirm` are forward-declared so each can call the others.
