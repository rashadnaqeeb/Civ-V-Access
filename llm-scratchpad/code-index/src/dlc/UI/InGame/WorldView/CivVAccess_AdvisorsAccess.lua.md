# `src/dlc/UI/InGame/WorldView/CivVAccess_AdvisorsAccess.lua`

229 lines · Accessibility handler for the tutorial advisor banner (Advisors Context), with silentFirstOpen to avoid double-narration with the engine's voice clip and an AdvisorDisplayShow listener to handle in-place tutorial updates.

## Header comment

```
-- Advisors (tutorial banner) accessibility. Fired by Events.AdvisorDisplayShow
-- from TutorialEngine.ProcessActiveTutorialQueue with eventInfo =
-- {IDName, Advisor, TitleText, BodyText, ActivateButtonText, Concept1/2/3,
-- Modal}. Body is short tutorial advice ("This is a good place to start a
-- city..."). Up to three Question buttons drill into a Concept (each opens
-- BUTTONPOPUP_ADVISOR_INFO, a separate Context not yet wired); an optional
-- Activate button fires a generic help popup; a Don't-show-again checkbox
-- and Thank-you dismiss complete the layout. Question4String exists in the
-- XML but base lua never wires it, so we omit it too.
--
-- Speech overlap: the engine plays a pre-recorded advisor voice clip for
-- every tutorial listed in Sounds/XML/AdvisorSoundConnections.xml (covers
-- essentially every base-game tutorial). That clip narrates the same text
-- our preamble would speak, so reading the preamble on push produces a
-- double-narration. AdvisorSoundConnections is not exposed through
-- GameInfo, so we can't reliably detect "voice will play" per-tutorial.
-- Resolution: silentFirstOpen = true. On fresh show BaseMenu speaks only
-- the dynamic displayName (the live advisor title) and nothing else. The
-- body text stays reachable through F1 (readHeader) so the user can opt
-- in. Tradeoff: a tutorial added without voice (mod content, unusual
-- base case) will be silent until the user presses F1 -- matches the
-- stated preference for silence-plus-F1 over spam.
--
-- DontShowAgainCheckbox has no click callback wired in base code: base
-- AdvisorClose() reads its state synchronously at dismiss time and calls
-- UI.SetAdvisorMessageHasBeenSeen(g_TutorialQueue[1].IDName, true). Our
-- Checkbox item uses a no-op activateCallback so PullDownProbe's "callback
-- not captured" warning stays quiet; toggling only flips the control state,
-- which is all base code reads anyway.
--
-- Re-show while visible: when a tutorial queues behind one already on
-- screen, base OnAdvisorDisplayShow overwrites the Controls text in place
-- and calls AdvisorOpen(), whose SetHide(false) on an already-visible
-- Context does not fire ShowHide. The AdvisorDisplayShow listener below
-- detects this case via a freshShow flag that onShow sets: if the flag is
-- false when the listener runs, the Context was already visible, so force
-- a full re-announce by clearing _initialized and re-running onActivate.
-- The flag also guards against double-announcing in the normal fresh-show
-- path (where ShowHide + onShow + push already announced before our
-- listener runs).
--
-- Escape routing: vanilla InputHandler calls AdvisorClose() directly, which
-- pops Advisors.lua's g_TutorialQueue and hides the Context but never fires
-- Events.AdvisorDisplayHide. TutorialEngine's HandleAdvisorUIHide listens
-- on that event and is the only thing that pops g_ActiveTutorialQueue and
-- calls ProcessActiveTutorialQueue(), so vanilla Escape leaves the engine
-- stuck on the same tutorial -- the banner closes but the next queued
-- tutorial never shows. onEscape below routes Escape through
-- OnAdvisorDismissClicked (the Thank-You button's handler) which fires the
-- event, matching the advance-to-next behavior the mouse path has.
```

## Outline

- L75: `local priorInput = InputHandler`
- L76: `local priorShowHide = ShowHideHandler`
- L78: `local function controlText(control)`
- L102: `local function readAdvisorTitle()`
- L110: `local function buildPreamble()`
- L126: `local freshShow = false`
- L128: `local handler = BaseMenu.install(ContextPtr, { name = "Advisors", silentFirstOpen = true, ..., items = { Question1-3, ActivateButton, DontShowAgainCheckbox, AdvisorDismissButton } })`
- L206: `Events.AdvisorDisplayShow.Add(function() ... end)`

## Notes

- L126 `freshShow`: a flag set by `onShow` and cleared by the `AdvisorDisplayShow` listener to distinguish a fresh `ShowHide`-triggered show (where BaseMenu already announced) from an in-place tutorial update that didn't fire `ShowHide`.
- L206 `Events.AdvisorDisplayShow.Add`: when `freshShow` is false and the Context is visible, forces a re-announce by resetting `handler._initialized` and calling `handler.onActivate` directly, because `SetHide(false)` on an already-visible Context doesn't fire `ShowHide`.
- L188 `ActivateButton` item: calls `CameraTracker.followAndJumpCursor()` after `OnAdvisorHelpClicked()` so camera-panning tutorial actions move the cursor to the panned location.
