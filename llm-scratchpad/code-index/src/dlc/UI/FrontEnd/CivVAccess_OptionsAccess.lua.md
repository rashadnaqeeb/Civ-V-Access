# `src/dlc/UI/FrontEnd/CivVAccess_OptionsAccess.lua`

602 lines · Accessibility wiring for the five-tab OptionsMenu screen, including inline modal popup handling for the GraphicsChangedPopup and Countdown widgets via wrapped engine globals.

## Header comment

```
-- OptionsMenu accessibility wiring. Five-tab form. The screen's own
-- OnCategory(which) toggles panel visibility and highlight boxes; we reuse
-- it directly rather than duplicate SetHide chains.
--
-- Tooltip keys are read from OptionsMenu.xml's ToolTip attribute on each
-- control (or its parent Label for widgets whose tooltip is on the grouping
-- container). Missing tooltips are fine -- BaseMenu just appends nothing.
--
-- Items are ordered roughly top-to-bottom, left-to-right as they appear in
-- the shipped UI. Hidden-by-platform widgets (tablet-only sliders, LAN-
-- specific controls when multiplayer category is off) are still listed --
-- BaseMenu's isNavigable skips them when IsHidden() returns true, so the user
-- never lands on something that would not accept input.
--
-- The three bottom buttons (Defaults / Cancel / Accept) live outside every
-- per-tab Container and stay visible regardless of which tab is active, so
-- they are appended to each tab's item list below. The GraphicsChangedPopup
-- and Countdown modals that OnOK / OnApplyRes raise are nested widgets in
-- the same Context; their handlers are pushed on top of the form handler
-- and driven by wrapping the engine's show / close globals (below).
```

## Outline

- L24: `local priorShowHide = ShowHideHandler`
- L25: `local priorInput = InputHandler`
- L29: `local function commonButtons()`
- L57: `local function withButtons(items)`
- L64: `BaseMenu.install(ContextPtr, { ... })`
- L472: `local countdownUserAction`
- L474: `local graphicsPopup = BaseMenu.create({ ... })`
- L492: `local countdownPopup = BaseMenu.create({ ... })`
- L526: `local function maybePushGraphicsPopup()`
- L532: `local origShowResolutionCountdown = ShowResolutionCountdown`
- L533: `function ShowResolutionCountdown()`
- L538: `local origShowLanguageCountdown = ShowLanguageCountdown`
- L539: `function ShowLanguageCountdown()`
- L544: `local origOnCountdownYes = OnCountdownYes`
- L545: `function OnCountdownYes()`
- L559: `local origOnCountdownNo = OnCountdownNo`
- L560: `function OnCountdownNo()`
- L586: `local origOnOK = OnOK`
- L587: `function OnOK()`
- L597: `local origOnGraphicsChangedOK = OnGraphicsChangedOK`
- L598: `function OnGraphicsChangedOK()`

## Notes

- L472 `countdownUserAction`: module-level sentinel that distinguishes user-triggered countdown close from timer-expiry close; nil means expiry, non-nil means user clicked Yes or No.
- L560 `OnCountdownNo`: snapshots widget visibility before calling the base because the base always calls `OnCountdownNo` defensively on every Esc, even when no countdown was ever raised; the snapshot guards against speaking or popping when nothing was showing.
