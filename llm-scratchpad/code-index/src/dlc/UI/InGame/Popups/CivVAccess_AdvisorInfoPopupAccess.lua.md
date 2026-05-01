# `src/dlc/UI/InGame/Popups/CivVAccess_AdvisorInfoPopupAccess.lua`

201 lines · Accessibility wrapper for BUTTONPOPUP_ADVISOR_INFO that supports in-place concept navigation, Alt+Left/Right history traversal, and Civilopedia hand-offs.

## Header comment

```
-- AdvisorInfoPopup accessibility wiring. Fired by
-- Events.SerialEventGameMessagePopup with Type=BUTTONPOPUP_ADVISOR_INFO and
-- Text=<concept key>. Base OnPopup populates the screen via ShowConcept(key)
-- and pushes itself onto the popup stack; the user can drill into any
-- related concept (same screen redraws in place), navigate Back/Forward
-- through an in-popup history, jump to the matching Civilopedia page, or
-- search the Civilopedia by description.
--
-- Speech model: displayName is the live concept title (Controls.TitleLabel)
-- and changes on every navigation; the preamble joins AdvisorLabel (which
-- advisor category this concept belongs to) with DescriptionLabel (the body
-- text). Items are rebuilt per-concept and contain the related-concept
-- choices followed by the two Civilopedia hand-offs and Close.
--
-- In-place nav: ShowConcept writes Controls directly with no ShowHide
-- transition, so wrapping it is the only way to notice the concept changed.
-- The wrap captures the key, rebuilds items, and re-runs onActivate when the
-- Context is already visible (post-first-open). On the initial popup show
-- ShowConcept fires first (still hidden) and the subsequent ShowHide handles
-- the announce naturally; we guard the re-announce path with IsHidden().
--
-- Related-concept buttons are InstanceManager-created and have no stable
-- Controls.X entry, so we use BaseMenuItems.Choice (control-less). Activation
-- calls AddToHistory + ShowConcept directly rather than base ConceptSelected:
-- ConceptSelected indexes into base's local g_strConceptList (which our
-- iteration order has to match exactly) whereas going through the history
-- helpers is ordering-independent.
```

## Outline

- L51: `local priorInput = InputHandler`
- L52: `local priorShowHide = ShowHideHandler`
- L57: `local currentConceptKey = nil`
- L59: `local function buildPreamble()`
- L75: `local function buildItems()`
- L132: `local handler = BaseMenu.install(ContextPtr, { ... })`
- L166: `local function onConceptChanged()`
- L195: `local basePriorShowConcept = ShowConcept`
- L196: `function ShowConcept(strConceptKey)`

## Notes

- L196 `ShowConcept`: wraps the base-file global of the same name so every caller path (initial open, related-concept pick, Back/Forward) routes through `onConceptChanged`; reassigning the global is the only intercept mechanism available since base defines it without `local`.
- L166 `onConceptChanged`: clears `handler._initialized` and calls `handler.onActivate` directly to force a fresh-show announce when the concept changes in-place without a ShowHide transition.
