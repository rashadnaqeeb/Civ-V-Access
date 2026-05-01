# `src/dlc/UI/InGame/LeaderHead/CivVAccess_DiploTradeAccess.lua`

100 lines · Thin Context wrapper that configures and installs the AI-trade (DiploTrade) screen's accessibility handler by delegating to the shared TradeLogicAccess module.

## Header comment

```
-- DiploTrade (BNW AI-trade) accessibility. Included by DiploTrade.lua's
-- verbatim override after TradeLogic's own includes and event wiring have
-- finished, so TradeLogic globals (g_Deal, g_iUs, g_iThem, g_iDiploUIState)
-- resolve inside the shared logic module's closures.
--
-- This wrapper only sets up the Context-specific descriptor (leader name
-- source, discussion-text preamble, silent-first-open for the voice clip)
-- and hands off to TradeLogicAccess.install. All item-building lives in
-- the shared module.
```

## Outline

- L36: `local priorInput = InputHandler`
- L37: `local priorShowHide = OnShowHide`
- L43: `local function composePreamble()`
- L59: `local function titleFn()`
- L74: `local handler = TradeLogicAccess.install(ContextPtr, priorInput, priorShowHide, { ... })`
- L97: `LeaderDescription.bindF2(handler, function() return g_iThem end)`

## Notes

- L59 `titleFn`: reads `g_iThem` rather than `Controls.NameText` because `NameText` can still hold the previous leader's name when `QueuePopup` fires its synchronous `ShowHide` - `g_iThem` is updated at the top of `LeaderMessageHandler` before any popup work.
- L74 `handler`: `deferActivate = true` is set so the first-open announcement runs after `LeaderMessageHandler` has finished writing the fresh discussion text to `Controls.DiscussionText`.
