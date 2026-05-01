# `src/dlc/UI/Shared/CivVAccess_BaseMenuNumberEntry.lua`

167 lines · Modal number-entry sub-handler that owns a Lua-side digit buffer for entering integers when no live XML EditBox is available.

## Header comment

```
-- Modal number-entry sub-handler pushed above a BaseMenu when the user must
-- enter an integer without a live XML EditBox. Used by the diplomacy trade
-- screen's Available tab: gold / gold-per-turn / strategic amounts don't have
-- an EditBox until the item is placed, so BaseMenuItems.Textfield and
-- BaseMenuEditMode (both driven off a live control) don't fit.
--
-- Owns a Lua-side digit buffer and speaks the running total on each keystroke
-- because there is no engine HWND text control for the screen reader to echo
-- against. capturesAllInput = true so digit keys don't leak into type-ahead
-- search or nav bindings on the menu below.
-- [... distinction from BaseMenuEditMode documented ...]
```

## Outline

- L24: `BaseMenuNumberEntry = {}`
- L26: `local SUB_NAME = "NumberEntry"`
- L31: `local function speakBuffer(buffer)`
- L39: `function BaseMenuNumberEntry.push(opts)`
- L59: `local function cancel()`
- L70: `local function commit()`
- L93: `local function appendDigit(ch)`
- L98: `local function backspace()`
- L167: `return BaseMenuNumberEntry`

## Notes

- L70 `commit`: invokes `onCommit` before popping the handler so any caller-driven item rebuild (setItems) completes before the parent's reactivation announcement fires.
- L39 `BaseMenuNumberEntry.push`: binds both top-row and numpad digit keys separately so users whose screen reader remaps the numpad still have a working input path.
