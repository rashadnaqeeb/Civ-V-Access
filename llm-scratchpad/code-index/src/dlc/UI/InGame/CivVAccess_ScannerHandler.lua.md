# `src/dlc/UI/InGame/CivVAccess_ScannerHandler.lua`

132 lines · Creates the HandlerStack handler for the scanner, wiring PageUp/Down chord bindings to ScannerNav entry points and publishing help entries for BaselineHandler.

## Header comment

```
-- Scanner handler. Sits directly above Baseline on the HandlerStack;
-- capturesAllInput=false so unbound keys (Q/A/S/W/X/... cursor cluster)
-- fall through to Baseline unchanged. Every binding here is an engine-
-- overriding choice documented in docs/hotkey-reference.md and listed
-- in the design doc section 6 rationale column.
--
-- Axis cycles are authored outer-to-inner in the four-level hierarchy:
-- Ctrl (category) above Shift (subcategory) above unmodified (item) above
-- Alt (instance). The binding list, the HELP_ENTRIES list, and the order
-- BaselineHandler surfaces them in all follow the same progression so the
-- user learns one modifier ladder.
--
-- Help entries live on the module (HELP_ENTRIES) rather than the returned
-- handler because BaselineHandler composes the full map-mode help list in
-- the order {movement/info, surveyor, scanner, function keys}. Scanner is
-- always stacked above Baseline in-game (Boot.lua pushes both at
-- LoadScreenClose), so surfacing scanner keys from Baseline lets the user
-- see them in the middle of Baseline's list rather than at the top (which
-- is what a top-down HandlerStack.collectHelpEntries walk would otherwise
-- produce). The returned handler.helpEntries is set to {} to opt in
-- explicitly and silence the "bindings without helpEntries" push warning.
```

## Outline

- L23: `ScannerHandler = {}`
- L25: `local MOD_NONE = 0`
- L26: `local MOD_SHIFT = 1`
- L27: `local MOD_CTRL = 2`
- L28: `local MOD_ALT = 4`
- L30: `local function speak(s)`
- L37: `local bind = HandlerStack.bind`
- L39: `local function cycle(entryPoint, dir)`
- L45: `local function call(entryPoint)`
- L51: `ScannerHandler.HELP_ENTRIES = { ... }`
- L90: `function ScannerHandler.create()`

## Notes

- L39 `cycle`: returns a closure that calls `entryPoint(dir)` and speaks the result; the `dir` argument is captured at definition time, not call time.
- L45 `call`: same pattern as `cycle` but for zero-argument entry points (Home, End, Ctrl+F, Backspace).
