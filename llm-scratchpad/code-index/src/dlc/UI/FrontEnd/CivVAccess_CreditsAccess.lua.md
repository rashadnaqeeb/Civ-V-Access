# `src/dlc/UI/FrontEnd/CivVAccess_CreditsAccess.lua`

49 lines · Accessibility wiring for the Credits screen, parsing the raw credits blob from `UI.GetCredits` into a speakable preamble since the visual scroll cannot be tracked by speech.

## Header comment

```
-- Credits accessibility wiring. Scrolling-text splash with one BackButton.
-- The visual list scrolls at a fixed rate that speech can't keep pace with,
-- so the preamble reads the credits content at announce time (parsing the
-- same \r\n-delimited blob UI.GetCredits returns, skipping spacer lines and
-- joining title / entry content with periods). Esc routes through priorInput
-- to the base OnBack; Enter is consumed by the handler's VK_RETURN binding.
```

## Outline

- L10: `local priorShowHide = ShowHideHandler`
- L11: `local priorInput = InputHandler`
- L16: `local function buildCreditsText()`
- L42: `BaseMenu.install(ContextPtr, { ... })`
