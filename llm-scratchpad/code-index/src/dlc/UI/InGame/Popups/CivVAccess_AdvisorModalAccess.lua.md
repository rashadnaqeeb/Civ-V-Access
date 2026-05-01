# `src/dlc/UI/InGame/Popups/CivVAccess_AdvisorModalAccess.lua`

89 lines · Accessibility wrapper for BUTTONPOPUP_ADVISOR_MODAL (combat-interrupt warning) exposing Confirm, Cancel, and a DontShowAgain checkbox.

## Header comment

```
-- AdvisorModal accessibility. Combat-interrupt popup fired by the engine
-- (BUTTONPOPUP_ADVISOR_MODAL) when the active player queues a move the AI
-- judges as a bad attack or an attack against a city. Binary choice:
-- Confirm proceeds with the queued move (Game.SetCombatWarned +
-- Game.SelectionListMove against the referenced plot), Cancel abandons.
-- A DontShowAgainCheckbox suppresses future warnings of the same flavour
-- (city-attack vs bad-attack, keyed off g_bAttackingCity in the base file);
-- the base Close() reads the checkbox synchronously and calls the matching
-- Game.SetAdvisor*Interrupt(false), so our items just delegate to the base
-- callbacks and the checkbox toggle only flips the control state.
--
-- TitleLabel / DescriptionLabel are populated by the base OnPopup with
-- the scenario-specific banner (e.g. "This Attack May Not End Well") and
-- body text; we surface both as the preamble so the user hears why the
-- warning fired before the first item. DisplayName is the static
-- "Combat Information" header.
```

## Outline

- L40: `local priorInput = InputHandler`
- L41: `local priorShowHide = ShowHideHandler`
- L43: `local function buildPreamble()`
- L59: `BaseMenu.install(ContextPtr, { ... })`

## Notes

- L76 `DontShowAgainCheckbox` activateCallback: intentionally a no-op; the base `Close()` reads the checkbox state at dismiss time rather than on toggle, so no action is needed here.
