# `src/dlc/UI/InGame/Popups/CivVAccess_GenericPopupAccess.lua`

137 lines · Accessibility wrapper for the GenericPopup Context, monkey-patching AddButton/ClearButtons to capture per-slot callbacks and exposing up to four buttons plus a CloseButton via BaseMenu.

## Header comment

```
-- GenericPopup accessibility. One BaseMenu handler covers all 16 popups
-- dispatched through PopupLayouts (AnnexCity, PuppetCity, LiberateMinor,
-- ReturnCivilian, ConfirmCommand, ConfirmCityTask, ConfirmGift,
-- ConfirmImprovementRebuild, ConfirmPolicyBranch, DeclareWarMove,
-- DeclareWarRangeStrike, BarbarianRansom, MinorCivEnterTerritory,
-- MinorCivGold, NetworkKicked, CityPlotManagement).
--
-- Buttons: the XML declares Button1..Button4 + CloseButton; each layout
-- unhides and labels a subset via AddButton. We monkey-patch AddButton /
-- ClearButtons to record the per-slot click callback and preventClose flag,
-- then expose each slot as a BaseMenuItems.Button. Slot visibility falls
-- out of _control:IsHidden, so items for unused slots drop out of
-- navigation automatically; the CloseButton item behaves the same way
-- (layouts that want it call Controls.CloseButton:SetHide(false)).
--
-- Timing: OnDisplay runs ClearButtons -> layout (SetPopupText + AddButton
-- calls) -> ShowWindow. ShowWindow's QueuePopup triggers our ShowHide,
-- which pushes the handler; by that point PopupText and the visible
-- buttons are already set, so onActivate reads fresh state. No refresh
-- listener needed.
--
-- Escape: priorInput chains to the base InputHandler, which dispatches to
-- PopupInputHandlers[type]. Popups with a handler dismiss on Esc/Return.
-- Popups without one consume keys without acting (matches base; sighted
-- users in that path also have to click a button). Enter on the focused
-- menu item activates it, giving blind users a reliable keyboard path for
-- every popup regardless of whether a PopupInputHandler is registered.
```

## Outline

- L51: `Log.info("GenericPopupAccess: wiring BaseMenu over PopupLayouts dispatch")`
- L53: `local priorInput = InputHandler`
- L63: `local baseAddButton    = AddButton`
- L64: `local baseClearButtons = ClearButtons`
- L66: `local buttonCallbacks    = {}`
- L67: `local buttonPreventClose = {}`
- L68: `local buttonTooltips     = {}`
- L69: `local nextButtonIdx      = 1`
- L71: `AddButton = function(buttonText, buttonClickFunc, strToolTip, bPreventClose)`
- L81: `ClearButtons = function()`
- L91: `local function invokeSlot(idx)`
- L105: `local function labelForSlot(idx)`
- L109: `local items = { ... }`
- L131: `BaseMenu.install(ContextPtr, { ... })`
