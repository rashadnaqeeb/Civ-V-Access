# `src/dlc/UI/InGame/LeaderHead/CivVAccess_LeaderHeadRootAccess.lua`

170 lines · Accessibility handler for the BNW LeaderHeadRoot diplomacy screen, wiring preamble (mood + speech), four action buttons, and AILeaderMessage-driven refresh.

## Header comment

```
-- LeaderHeadRoot (BNW) accessibility. The diplomacy screen that shows when
-- an AI leader speaks to you: mood text, the spoken line, and action
-- buttons (Discuss / Trade / Demand / War-or-Peace). Back is reached via
-- Esc, falling through to the base InputHandler's OnReturn.
--
-- displayName is the leader title (populated from Controls.TitleText in
-- onShow, after LeaderMessageHandler has written it for the current
-- leader). The screen opens speaking title + mood + speech via the
-- function preamble, resolved live each call so a new AILeaderMessage
-- coming back from a sub-screen (Trade, DiscussionDialog, etc.)
-- re-reads the latest text. The engine's voice clip plays a
-- constructed-language line that doesn't match the subtitle text, so
-- letting Tolk overlap the clip is the accessible behavior -- the
-- subtitle is the only canonical content. F1 re-reads on demand.
```

## Outline

- L39: `local priorInput = InputHandler`
- L40: `local priorShowHide = OnShowHide`
- L51: `local function composePreamble()`
- L71: `local function warButtonTooltip(ctrl)`
- L88: `local currentAIPlayer = -1`
- L89: `local function onAILeaderMessage(iPlayer)`
- L92: `Events.AILeaderMessage.Add(onAILeaderMessage)`
- L94: `local handler = BaseMenu.install(ContextPtr, { name = "LeaderHeadRoot", ..., items = { DiscussButton, TradeButton, DemandButton, WarButton } })`
- L161: `Events.AILeaderMessage.Add(function() ... handler.refresh() ... end)`
- L167: `LeaderDescription.bindF2(handler, function() return currentAIPlayer end)`

## Notes

- L92 `Events.AILeaderMessage.Add(onAILeaderMessage)`: captures the current AI player into a module upvalue because the base module's `g_iAIPlayer` is an unreachable upvalue; this id is then passed to `LeaderDescription.bindF2` for F2 portrait reads.
- L161 second `Events.AILeaderMessage.Add`: calls `handler.refresh()` to re-read mood + speech on follow-up messages while the screen is already open; gated on `_initialized` so transitions that hide this screen don't speak seed text on the way out.
