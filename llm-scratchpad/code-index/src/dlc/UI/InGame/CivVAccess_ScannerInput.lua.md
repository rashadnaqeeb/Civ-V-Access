# `src/dlc/UI/InGame/CivVAccess_ScannerInput.lua`

88 lines · Text-capture handler pushed on top of ScannerHandler when the user presses Ctrl+F, buffering typed characters until Enter commits the search query or Escape cancels.

## Header comment

```
-- Text-capture handler pushed on top of ScannerHandler when the user
-- presses Ctrl+F. Printable keystrokes append to an internal buffer
-- silently; the user's screen reader provides typing echo. Enter
-- commits the query and speaks the result, Escape cancels.
--
-- Driven by InputRouter's handleSearchInput hook -- the same pre-walk
-- path BaseMenu's type-ahead uses -- so no per-letter bindings table is
-- needed. capturesAllInput=true stops any key we don't consume from
-- falling through into ScannerHandler's cycle bindings during a typed
-- query.
```

## Outline

- L12: `ScannerInput = {}`
- L14: `local function charForLetter(vk)`
- L21: `local function charForDigit(vk)`
- L28: `function ScannerInput.create()`

## Notes

- L50 `self.handleSearchInput`: defined as a field on the returned handler table (not a module-level function); InputRouter calls it by name on the active handler when a keydown arrives before the bindings walk.
