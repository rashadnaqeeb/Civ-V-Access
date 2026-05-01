# `src/dlc/UI/InGame/LeaderHead/CivVAccess_DiscussionDialogAccess.lua`

365 lines · Accessibility handler for the BNW DiscussionDialog screen, including three overlay sub-handlers (DenounceConfirm, WarConfirm, LeaderPanel) and AILeaderMessage-driven preamble refresh.

## Header comment

```
-- DiscussionDialog (BNW) accessibility. Follow-up screen to LeaderHeadRoot:
-- the AI has spoken, and the human picks from up to 8 response buttons
-- whose text, tooltips, and visibility are recomputed per DiploUIState.
--
-- Same open-speech and F1 contract as LeaderHeadRoot: on show we speak
-- the leader title (onShow populates handler.displayName from
-- Controls.TitleText) plus the live preamble (mood + leader speech).
-- The leader speech changes as the AI sends follow-up AILeaderMessage
-- events; the function preamble resolves fresh each open / F1 press so
-- the user always gets the current text. The engine's voice clip is a
-- constructed-language line that doesn't match the subtitle, so Tolk
-- overlapping the clip is the accessible behavior.
--
-- Three sibling overlays exist on this screen that BaseMenu can't model
-- as items directly: DenounceConfirm (yes/no denounce modal), WarConfirm
-- (yes/no war modal, reachable from the CONFRONT_YOU_KILLED_MY_SPY
-- state), and LeaderPanel (scrolling list of co-op-war targets). Each
-- opens as a visual overlay when the user picks the button that opens
-- it; we push a child BaseMenu handler whose onDeactivate hides the
-- overlay so Esc closes both handler and overlay in one step. The
-- child's activate either fires the base commit fn (Yes / No, pick a
-- leader) and pops the handler, or the user escapes out via escapePops.
--
-- Per-button activate dispatches to the base OnButton1..8 handlers;
-- afterActivate() checks whether any overlay just became visible and
-- pushes the matching child handler. The base button handlers remain
-- unchanged, so mouse-driven interaction keeps working for sighted
-- testers.
```

## Outline

- L53: `local priorInput = InputHandler`
- L54: `local priorShowHide = OnShowHide`
- L58: `local function composePreamble()`
- L74: `local function readTooltip(ctrl)`
- L92: `local DENOUNCE_SUB_NAME = "DiscussionDialog/DenounceConfirm"`
- L94: `local function pushDenounceConfirmSub()`
- L132: `local WAR_SUB_NAME = "DiscussionDialog/WarConfirm"`
- L134: `local function pushWarConfirmSub()`
- L174: `local LEADER_PANEL_SUB_NAME = "DiscussionDialog/LeaderPanel"`
- L176: `local function buildLeaderItems()`
- L193: `local function pushLeaderPanelSub()`
- L224: `local function hasSub(name)`
- L233: `local function afterActivate()`
- L255: `local currentAIPlayer = -1`
- L256: `local function onAILeaderMessage(iPlayer)`
- L259: `Events.AILeaderMessage.Add(onAILeaderMessage)`
- L261: `local buttonFns = { OnButton1, ... OnButton8 }`
- L272: `local function makeButtonItem(idx)`
- L294: `local items = { makeButtonItem(1), ..., BackButton }`
- L316: `local handler = BaseMenu.install(ContextPtr, { ... })`
- L354: `Events.AILeaderMessage.Add(function() ... handler.setItems(items); handler.refresh() ... end)`
- L362: `LeaderDescription.bindF2(handler, function() return currentAIPlayer end)`

## Notes

- L259 `Events.AILeaderMessage.Add(onAILeaderMessage)`: captures the AI player id into `currentAIPlayer` because the base module's `g_iAIPlayer` is a chunk-local upvalue unreachable from this include.
- L354 `Events.AILeaderMessage.Add`: a second listener on the same event that calls `handler.setItems` then `handler.refresh` to re-clamp the cursor and re-read the preamble when the AI sends a follow-up message while the screen is already open.
