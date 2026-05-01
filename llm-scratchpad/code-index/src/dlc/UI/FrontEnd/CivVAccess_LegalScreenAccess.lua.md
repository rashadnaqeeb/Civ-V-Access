# `src/dlc/UI/FrontEnd/CivVAccess_LegalScreenAccess.lua`

22 lines · Accessibility wiring for the Legal Screen, concatenating the EULA and ESRB text bodies into a single spoken preamble with a Continue button.

## Header comment

```
-- LegalScreen accessibility wiring. The game file registers an anonymous
-- callback on ContinueButton that dequeues the popup; we duplicate that
-- one-line body here rather than trying to reach into local scope.
-- Two static text bodies (EULA + ESRB) are joined into a single preamble
-- so the user hears both before the Continue button is announced.
```

## Outline

- L8: `BaseMenu.install(ContextPtr, { ... })`
