# `src/dlc/UI/FrontEnd/CivVAccess_ModListPreamble.lua`

23 lines · Shared preamble factory that builds a spoken enabled-mods list for the three Mods* menu screens, queried at speech time rather than cached.

## Header comment

```
-- Shared preamble builder for the three Mods* menus. Returns a function
-- the Access file can hand to BaseMenu as spec.preamble so the
-- enabled-mods list is queried at speech time, never cached.
```

## Outline

- L5: `ModListPreamble = {}`
- L7: `local function build()`
- L20: `function ModListPreamble.fn()`

## Notes

- L20 `ModListPreamble.fn`: returns the `build` function itself (a closure), not the result of calling it; BaseMenu calls the returned function at speech time.
