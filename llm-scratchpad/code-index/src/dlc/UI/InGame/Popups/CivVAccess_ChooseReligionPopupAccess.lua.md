# `src/dlc/UI/InGame/Popups/CivVAccess_ChooseReligionPopupAccess.lua`

480 lines · Accessibility wrapper for BUTTONPOPUP_FOUND_RELIGION covering both the founding and enhance phases, with drillable belief slots, a religion picker, a rename sub, and a ChooseConfirm sub.

## Header comment

```
-- ChooseReligionPopup accessibility. Shares one Context across two phases
-- (BUTTONPOPUP_FOUND_RELIGION; Option1=true=founding, Option1=false=enhance):
-- founding picks Pantheon / Founder / Follower + optional Bonus (Byzantines)
-- and lets the player name the religion; enhance picks Follower 2 + Enhancer
-- on the already-founded religion.
--
-- Layout:
--   religion row     Group (founding) -> religion-list drill; Choice
--                    (enhance) -> read-only display of the player's own
--                    religion. Gated on visibility of ReligionPanel so the
--                    user doesn't land on it before one is picked.
--   name row         Choice; activate opens ChangeReligionName sub in
--                    founding mode, no-op in enhance mode. Gated on
--                    ReligionPanel.
--   6 belief slots   Group each; itemsFn (cached=false) rebuilds the
--                    candidate-belief list on every drill and applies the
--                    v ~= g_Beliefs[N] dedup guards base's On*BeliefClick
--                    handlers use. Locked slots (already-committed,
--                    "available later", Byzantines-only) fall out as empty
--                    children whose drill just re-announces the label.
--   confirm          Button bound to Controls.FoundReligion; its IsDisabled
--                    mirrors CheckifCanCommit so the "disabled" narration
--                    tracks commit readiness without us replicating the
--                    gating logic.
--
-- Confirm overlay: after FoundReligion fires the engine's ChooseConfirm
-- prompt, we push ChooseConfirmSub with control names Yes/No (the overlay
-- uses those, not the ConfirmYes/ConfirmNo that other Choose* popups use).
--
-- Rename sub: ChangeReligionName opens the engine's ChangeNamePopup
-- overlay; we push a sub-handler with Textfield + ChangeNameOKButton /
-- ChangeNameDefaultButton / ChangeNameCancelButton. OK calls
-- OnChangeNameOK; if that leaves ChangeNameError visible (empty-name
-- rejection), we speak the error and stay in the sub; on success the
-- overlay hides and the sub pops. Cancel / Esc hide the overlay through
-- the sub's onDeactivate.
```

## Outline

- L61: `local priorInput = InputHandler`
- L62: `local priorShowHide = ShowHideHandler`
- L64: `local mainHandler`
- L71: `local SLOT_PANTHEON = { ... }`
- L77: `local SLOT_FOUNDER = { ... }`
- L83: `local SLOT_FOLLOWER = { ... }`
- L89: `local SLOT_FOLLOWER2 = { ... }`
- L95: `local SLOT_ENHANCER = { ... }`
- L101: `local SLOT_BONUS = { ... }`
- L111: `local function slotState(slot, pPlayer)`
- L143: `local function slotLabel(slot)`
- L163: `local function buildBeliefChoices(slot)`
- L203: `local function buildSlotItem(slot)`
- L237: `local function buildReligionChoices()`
- L300: `local function religionPickerLabel()`
- L307: `local function buildReligionPickerItem(isFounding)`
- L326: `local function nameRowLabel()`
- L330: `local function pushNameEditSub()`
- L392: `local function buildNameRowItem(isFounding)`
- L409: `local function confirmLabel(c)`
- L413: `local function buildConfirmItem()`
- L432: `local function buildItems(popupInfo)`
- L449: `local function preambleText()`
- L456: `mainHandler = BaseMenu.install(ContextPtr, { ... })`
- L466: `Events.SerialEventGameMessagePopup.Add(...)`

## Notes

- L64 `mainHandler`: forward-declared nil so `buildBeliefChoices` can call `mainHandler._goBackLevel()` before the `BaseMenu.install` assignment at L456.
- L111 `slotState`: classifies a slot as "editable", "committed", "later", or "byzantines_only" by replicating the logic in base's `RefreshExistingBeliefs`; drives both label text and whether the drill-in itemsFn returns choices or an empty list.
- L330 `pushNameEditSub`: calls the base global `ChangeReligionName()` to open the overlay before pushing the sub; on OK, detects rejection by checking whether `ChangeNamePopup` is still visible after `OnChangeNameOK` returns.
