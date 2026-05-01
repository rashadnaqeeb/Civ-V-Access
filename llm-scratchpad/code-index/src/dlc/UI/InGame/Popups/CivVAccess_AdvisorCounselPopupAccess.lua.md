# `src/dlc/UI/InGame/Popups/CivVAccess_AdvisorCounselPopupAccess.lua`

128 lines · Accessibility wrapper for BUTTONPOPUP_ADVISOR_COUNSEL that presents each advisor's counsel pages as tabs in a BaseMenu.

## Header comment

```
-- AdvisorCounselPopup accessibility. BUTTONPOPUP_ADVISOR_COUNSEL shows all
-- four advisors' current counsel on one screen (2x2 grid); each advisor has
-- its own list of counsel pages paginated via per-advisor Prev/Next buttons.
-- Engine-reachable on the `V` hotkey (CONTROL_ADVISOR_COUNSEL); Baseline
-- swallows `V` so our own F10 binding (BaselineHandler) is the keyboard
-- entry point.
--
-- Tabbed BaseMenu, one tab per advisor in the visual reading order
-- (Economic, Military, Foreign, Science). Each tab's items are the counsel
-- pages for that advisor, one Text item per page. Page label is prefixed
-- with "i/N" when N > 1 so the user hears their position; single-page
-- advisors skip the prefix. Empty advisors render a single "no counsel"
-- placeholder so Tab does not land on nothing.
--
-- Visual sync: each page item's announce wrap calls ShowAdvisorText(advisor,
-- pageIndex) before returning the label. ShowAdvisorText is a global in the
-- base popup that rewrites the visible body label, per-advisor page counter,
-- and Prev/Next enable states -- so a sighted observer watching the screen
-- sees the same page the blind user is being read. On Tab into a new
-- advisor the first item's pageIndex is 0, so the visible panel resets to
-- page 1 for that advisor automatically.
--
-- Counsel data source: Game.GetAdvisorCounsel() in onShow. Base OnPopup has
-- already populated its own local AdvisorCounselTable via UpdateAdvisorSlots
-- by the time our ShowHide wrapper fires, so our independent call reads the
-- same state; we cannot reach the base's local directly. No caching across
-- opens -- onShow rebuilds for every popup appearance.
```

## Outline

- L51: `local priorInput = InputHandler`
- L52: `local priorShowHide = ShowHideHandler`
- L54: `local Advisors = { ... }`
- L61: `local function emptyItem()`
- L65: `local function buildItemsForAdvisor(counselTable, advisorType)`
- L105: `local function onShow(handler)`
- L112: `local tabs = {}`
- L120: `BaseMenu.install(ContextPtr, { ... })`

## Notes

- L65 `buildItemsForAdvisor`: iterates `pageIndex` from 0 not 1 because `AdvisorCounselTable` is 0-indexed in the engine; the inner announce wrap calls the base global `ShowAdvisorText` to sync the sighted panel.
