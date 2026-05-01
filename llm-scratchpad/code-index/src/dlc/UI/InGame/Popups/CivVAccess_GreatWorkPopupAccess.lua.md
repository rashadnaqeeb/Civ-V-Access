# `src/dlc/UI/InGame/Popups/CivVAccess_GreatWorkPopupAccess.lua`

124 lines · Accessibility wrapper for the GreatWorkPopup, silently deferring the first-open announcement for literature works (which trigger an engine voice clip) while speaking normally for art and music.

## Header comment

```
-- GreatWorkPopup accessibility. Title holds either the great work's artist
-- (from Game.GetGreatWorkArtist) or TXT_KEY_GREAT_WORK_POPUP_WRITTEN_ARTIFACT
-- for archaeology-only works; LowerCaption holds the work's Description;
-- Quote holds the flavor quote and is hidden when the work has no quote.
-- Single Close button dismisses via OnClose.
--
-- Speech model: silentFirstOpen is conditional on the great work's class.
-- Writings (GREAT_WORK_LITERATURE) come with a Quote and the engine plays a
-- narrated voice clip of that quote when the popup is shown — Tolk stays
-- silent on first open so the two don't compete. Art and music popups have
-- no narrated quote, so first-open speaks the preamble normally. The work's
-- name (LowerCaption) is rolled into displayName via onShow so the silent-
-- first-open path still tells the user which work was completed; F1 reads
-- artist + quote on demand.
--
-- The class lookup uses popup info captured from
-- SerialEventGameMessagePopupShown, which fires from inside the engine's
-- ShowHideHandler before priorShowHide returns. By the time onShow runs and
-- silentFirstOpen evaluates inside HandlerStack.push, the captured type is
-- current. Capturing in SerialEventGameMessagePopup (queue time) would race
-- when multiple great works finish on the same turn.
```

## Outline

- L45: `local priorInput = InputHandler`
- L46: `local priorShowHide = ShowHideHandler`
- L48: `local function labelOf(name)`
- L62: `local capturedGWType = nil`
- L64: `Events.SerialEventGameMessagePopupShown.Add(function(popupInfo) ... end)`
- L76: `local function isLiterature()`
- L86: `local function preamble()`
- L99: `BaseMenu.install(ContextPtr, { ... })`

## Notes

- L64 `Events.SerialEventGameMessagePopupShown.Add`: Captures the great work type at show time (not queue time) to avoid a race when multiple great works complete on the same turn.
- L76 `isLiterature`: Used as `silentFirstOpen` callback so the suppression decision is deferred until push time, after `capturedGWType` is set by the show event.
