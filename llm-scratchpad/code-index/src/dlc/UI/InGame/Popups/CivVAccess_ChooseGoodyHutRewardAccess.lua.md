# `src/dlc/UI/InGame/Popups/CivVAccess_ChooseGoodyHutRewardAccess.lua`

139 lines · Accessibility wrapper for BUTTONPOPUP_CHOOSE_GOODY_HUT_REWARD that mirrors the base single-select/commit scaffold without touching the sighted SelectionAnim.

## Header comment

```
-- ChooseGoodyHutReward accessibility. Own-Context popup opened via
-- Events.SerialEventGameMessagePopup with BUTTONPOPUP_CHOOSE_GOODY_HUT_REWARD.
-- Base's PopulateItems["GoodyHutBonuses"] walks GameInfo.GoodyHuts in index
-- order, filters each by pPlayer:CanGetGoody(pPlot, iGoodyType, pUnit), and
-- spawns one Button per eligible bonus inside Controls.ItemStack. Selection
-- is tracked in a global SelectedItems = {{iGoodyType, controlTable}};
-- ConfirmButton stays disabled until g_NumberOfFreeItems == #SelectedItems
-- (always 1 today -- the base errors hard on > 1), and fires
-- CommitItems["GoodyHutBonuses"] which sends Network.SendGoodyChoice.
--
-- Our listener fires after base's on the same popup event. We rebuild a
-- parallel BaseMenu item list: one Choice per eligible GoodyHut plus a
-- trailing Confirm Button targeting the real ConfirmButton control. Enter
-- on a Choice replaces SelectedItems with {{iGoodyType, stub}} and enables
-- Confirm (matching base's single-select branch without touching the
-- sighted SelectionAnim, which the blind player cannot observe anyway).
-- Enter on Confirm runs the base's CommitItems closure (which reads
-- pUnit / pPlot from base's file locals) and hides the popup.
--
-- deferActivate=true on install means the push fires next tick via
-- TickPump, so onActivate reads items that our listener populates after
-- base's listener returns but before the next frame's push.
```

## Outline

- L46: `local priorInput = InputHandler`
- L47: `local priorShowHide = ShowHideHandler`
- L53: `local function selectionStub()`
- L57: `local function preambleText()`
- L70: `local mainHandler = BaseMenu.install(ContextPtr, { ... })`
- L80: `local function buildItems(popupInfo)`
- L128: `Events.SerialEventGameMessagePopup.Add(...)`

## Notes

- L53 `selectionStub`: fake control-table keeping `SelectedItems` in the shape the base popup expects; prevents nil access if base's own click handler fires while our sub is active.
- L96 `iGoodyType`: incremented manually with `iIndex` because `GameInfo.GoodyHuts()` iterator does not expose the numeric ID directly; the index must match the position the base uses when calling `Network.SendGoodyChoice`.
