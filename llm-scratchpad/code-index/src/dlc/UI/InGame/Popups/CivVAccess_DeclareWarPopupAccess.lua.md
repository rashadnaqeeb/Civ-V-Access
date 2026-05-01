# `src/dlc/UI/InGame/Popups/CivVAccess_DeclareWarPopupAccess.lua`

149 lines · Accessibility wrapper for the DeclareWarPopup Context, exposing Yes/No confirmation buttons via BaseMenu and coordinating with UnitControl's pending-move tracker.

## Header comment

```
-- DeclareWarPopup (BNW) accessibility. Yes / No confirmation for declaring
-- war by moving onto rival territory, range-striking a rival, or plundering
-- a trade route.
--
-- Structure mirrors GenericPopup (AddButton / ClearButtons / HideWindow /
-- SetPopupText, Button1..N + per-slot callbacks), but DeclareWarPopup lives
-- in its own Context with a local PopupLayouts table -- GenericPopup's
-- dispatch never reaches it. Same monkey-patch trick captures per-slot
-- callbacks so each BaseMenuItems.Button slot can invoke the recorded click
-- and then dismiss via HideWindow. The XML only defines Button1 / Button2;
-- extra slots would be ignored (resolveControl nil-guards isNavigable).
--
-- PopupText holds the reason line set by each PopupLayouts entry
-- ("Are you sure you wish to declare war on X?" plus open-borders /
-- city-state / plunder variants); surfaced as the preamble.
--
-- DECLAREWARMOVE-only coordination with UnitControl's pending-move
-- tracker: the popup intercepts a move that already registered pending,
-- so the engine's two-tick expiry would falsely speak "action failed"
-- under the popup. UnitControl freezes pending into a deferred slot on
-- popup show; we re-arm it on Yes (slot 1) so the engine's re-issued
-- Game.SelectionListMove gets announced normally, or drop it on No /
-- Esc (the popup itself was the user's resolution). Other DeclareWar
-- popup variants (range-strike, plunder) don't touch the deferred slot
-- because their commit paths skip pending registration.
```

## Outline

- L49: `local priorInput = InputHandler`
- L50: `local priorShowHide = ShowHideHandler`
- L54: `local baseAddButton    = AddButton`
- L55: `local baseClearButtons = ClearButtons`
- L56: `local baseHideWindow   = HideWindow`
- L58: `local buttonCallbacks    = {}`
- L59: `local buttonPreventClose = {}`
- L60: `local nextButtonIdx      = 1`
- L65: `local _clicked = false`
- L67: `AddButton = function(buttonText, buttonClickFunc, strToolTip, bPreventClose)`
- L76: `ClearButtons = function()`
- L83: `HideWindow = function()`
- L98: `local function invokeSlot(idx)`
- L127: `local function labelForSlot(idx)`
- L131: `BaseMenu.install(ContextPtr, { ... })`

## Notes

- L65 `_clicked`: Tracks whether the popup closed via a button click vs Esc/external dismissal, so `HideWindow` can decide whether to call `UnitControl.notifyCommitCanceled`.
- L83 `HideWindow`: Monkey-patches the engine global to inject UnitControl cancel notification on non-click closes of BUTTONPOPUP_DECLAREWARMOVE; all other popup types are unaffected.
