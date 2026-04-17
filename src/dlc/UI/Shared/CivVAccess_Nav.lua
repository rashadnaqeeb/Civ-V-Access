-- Small nav primitive used by Menu. Walks a list of items with wrap-around,
-- skipping non-navigable entries and bounding iterations at #items so an
-- all-invalid list terminates instead of spinning.
--
-- Nav.next(items, start, step, isNavigable)
--   items        array of resolved item tables
--   start        starting index; pass 0 with step=+1 to find first valid,
--                or #items+1 with step=-1 to find last valid
--   step         +1 or -1
--   isNavigable  fn(item) -> bool; the caller-supplied predicate

Nav = {}

function Nav.next(items, start, step, isNavigable)
    local n = #items
    if n == 0 then return nil end
    local i = start
    for _ = 1, n do
        i = i + step
        if i > n then i = 1 end
        if i < 1 then i = n end
        if isNavigable(items[i]) then return i end
    end
    return nil
end
