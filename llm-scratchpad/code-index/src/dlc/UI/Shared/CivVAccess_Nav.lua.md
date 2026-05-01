# `src/dlc/UI/Shared/CivVAccess_Nav.lua`

34 lines · Minimal list-navigation primitive used by `BaseMenu`: walks an item array with wrap-around, skipping non-navigable entries, bounded to `#items` iterations.

## Header comment

```
-- Small nav primitive used by BaseMenu. Walks a list of items with wrap-around,
-- skipping non-navigable entries and bounding iterations at #items so an
-- all-invalid list terminates instead of spinning.
--
-- Nav.next(items, start, step, isNavigable)
--   items        array of resolved item tables
--   start        starting index; pass 0 with step=+1 to find first valid,
--                or #items+1 with step=-1 to find last valid
--   step         +1 or -1
--   isNavigable  fn(item) -> bool; the caller-supplied predicate
```

## Outline

- L12: `Nav = {}`
- L14: `function Nav.next(items, start, step, isNavigable)`
