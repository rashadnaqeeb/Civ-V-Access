-- NavigableGraph cursor tests. Exercises the sibling-context rule, the
-- root-swap on navigateUp, cycle wrap semantics, and the lambda-on-demand
-- contract (the cursor re-calls lambdas for every neighbor lookup, so a
-- mutation between calls is visible to the next move).

local T = require("support")
local M = {}

local function setup()
    Log = Log or {
        debug = function() end,
        info = function() end,
        warn = function() end,
        error = function() end,
    }
    dofile("src/dlc/UI/Shared/CivVAccess_NavigableGraph.lua")
end

-- Build a cursor over a caller-provided adjacency map. Nodes are the
-- string keys of the map; each entry holds `parents` and `children` arrays
-- of sibling strings in caller-declared order. The roots list is computed
-- from entries whose parents is empty, preserving map-insertion order by
-- accepting a rootsOrder override.
local function buildCursor(adj, rootsOrder)
    local roots = {}
    if rootsOrder ~= nil then
        for _, name in ipairs(rootsOrder) do
            roots[#roots + 1] = name
        end
    else
        for name, rec in pairs(adj) do
            if #rec.parents == 0 then
                roots[#roots + 1] = name
            end
        end
        table.sort(roots)
    end
    return NavigableGraph.new({
        getParents = function(node)
            return adj[node].parents
        end,
        getChildren = function(node)
            return adj[node].children
        end,
        getRoots = function()
            return roots
        end,
    })
end

-- Diamond with a second root to exercise root-cycle and rejoin:
--       A       E
--       |       |
--       B       F
--      / \     /
--     C   D   /
--      \ / \ /
--       G   H
local function diamond()
    return {
        A = { parents = {},            children = { "B" } },
        E = { parents = {},            children = { "F" } },
        B = { parents = { "A" },       children = { "C", "D" } },
        F = { parents = { "E" },       children = { "H" } },
        C = { parents = { "B" },       children = { "G" } },
        D = { parents = { "B" },       children = { "G", "H" } },
        G = { parents = { "C", "D" },  children = {} },
        H = { parents = { "D", "F" },  children = {} },
    }, { "A", "E" }
end

-- ===== Constructor validation =====

function M.test_new_requires_all_three_lambdas()
    setup()
    local ok = pcall(NavigableGraph.new, {
        getParents = function() return {} end,
        getChildren = function() return {} end,
    })
    T.falsy(ok, "constructor must reject missing getRoots")
end

-- ===== Basic movement =====

function M.test_navigateDown_sets_current_and_seeds_siblings()
    setup()
    local adj, rootsOrder = diamond()
    local c = buildCursor(adj, rootsOrder)
    c.moveTo("B")
    local n = c.navigateDown()
    T.eq(n, "C", "Down lands on first child")
    T.eq(c.current(), "C")
    T.truthy(c.hasSiblings(), "siblings seeded to B's children")
    -- Right cycles among the siblings (C, D).
    local r, wrapped = c.cycleSibling(1)
    T.eq(r, "D")
    T.falsy(wrapped)
    local r2, wrapped2 = c.cycleSibling(1)
    T.eq(r2, "C", "cycle wraps from last back to first")
    T.truthy(wrapped2, "wrap flag set on rollover")
end

function M.test_navigateUp_from_leaf_seeds_parents_as_siblings()
    setup()
    local adj, rootsOrder = diamond()
    local c = buildCursor(adj, rootsOrder)
    c.moveTo("G")
    local n = c.navigateUp()
    T.eq(n, "C", "Up lands on first parent")
    T.truthy(c.hasSiblings())
    -- Right cycles among parents of G: C, D.
    local r = c.cycleSibling(1)
    T.eq(r, "D")
end

function M.test_navigateDown_returns_nil_at_leaf()
    setup()
    local adj, rootsOrder = diamond()
    local c = buildCursor(adj, rootsOrder)
    c.moveTo("G")
    T.eq(c.navigateDown(), nil, "leaves return nil on Down")
    T.eq(c.current(), "G", "cursor unchanged when no move is possible")
end

function M.test_navigateUp_returns_nil_at_root()
    setup()
    local adj, rootsOrder = diamond()
    local c = buildCursor(adj, rootsOrder)
    c.moveTo("A")
    T.eq(c.navigateUp(), nil, "roots return nil on Up")
    T.eq(c.current(), "A", "cursor unchanged at root boundary")
end

-- ===== Root-swap special case =====

function M.test_navigateUp_to_root_swaps_siblings_to_root_set()
    setup()
    local adj, rootsOrder = diamond()
    local c = buildCursor(adj, rootsOrder)
    c.moveTo("B")
    local n = c.navigateUp()
    T.eq(n, "A", "Up from B lands on root A")
    -- If we didn't swap, siblings would be B's parents ({A}) and Right would
    -- be a no-op. With the swap, siblings = getRoots() = {A, E}.
    T.truthy(c.hasSiblings(), "root-swap seeds siblings to full root set")
    local r = c.cycleSibling(1)
    T.eq(r, "E", "cycle on a root walks across roots")
end

-- ===== moveTo / moveToWithSiblings =====

function M.test_moveTo_drops_sibling_context()
    setup()
    local adj, rootsOrder = diamond()
    local c = buildCursor(adj, rootsOrder)
    c.moveTo("B")
    c.navigateDown() -- lands on C with siblings {C, D}
    T.truthy(c.hasSiblings())
    c.moveTo("D")
    T.falsy(c.hasSiblings(), "moveTo clears sibling context")
    local r, wrapped = c.cycleSibling(1)
    T.eq(r, nil, "Left/Right is a no-op until next vertical move")
    T.falsy(wrapped)
end

function M.test_moveToWithSiblings_seeds_context()
    setup()
    local adj, rootsOrder = diamond()
    local c = buildCursor(adj, rootsOrder)
    c.moveToWithSiblings("A", { "A", "E" })
    T.truthy(c.hasSiblings(), "caller-seeded siblings are immediately usable")
    local r = c.cycleSibling(1)
    T.eq(r, "E", "cycle walks the seeded list")
end

function M.test_moveToWithSiblings_finds_cursor_index_in_list()
    setup()
    local adj, rootsOrder = diamond()
    local c = buildCursor(adj, rootsOrder)
    -- Land on the second root; cycle forward should wrap to the first.
    c.moveToWithSiblings("E", { "A", "E" })
    local r, wrapped = c.cycleSibling(1)
    T.eq(r, "A", "cycle resumes from the seeded node's position")
    T.truthy(wrapped, "forward from last element wraps")
end

-- ===== Introspection =====

function M.test_introspection_reflects_structure()
    setup()
    local adj, rootsOrder = diamond()
    local c = buildCursor(adj, rootsOrder)
    c.moveTo("B")
    T.truthy(c.hasParents())
    T.truthy(c.hasChildren())
    T.falsy(c.hasSiblings(), "moveTo leaves no siblings")
    c.moveTo("A")
    T.falsy(c.hasParents(), "roots have no parents")
    T.truthy(c.hasChildren())
    c.moveTo("G")
    T.truthy(c.hasParents())
    T.falsy(c.hasChildren(), "leaves have no children")
end

-- ===== Lambda-on-demand contract =====

function M.test_lambdas_are_called_per_move_not_cached()
    setup()
    -- A -> B -> C. We'll mutate children of B between two Down calls: the
    -- first Down goes through, then we add D to B's children, then another
    -- Down after moving back to B should see D instead of only C.
    local adj = {
        A = { parents = {},      children = { "B" } },
        B = { parents = { "A" }, children = { "C" } },
        C = { parents = { "B" }, children = {} },
        D = { parents = { "B" }, children = {} },
    }
    local c = buildCursor(adj, { "A" })
    c.moveTo("B")
    T.eq(c.navigateDown(), "C", "first descent lands on the only child")
    -- Mutate adjacency and move back up.
    adj.B.children = { "D", "C" }
    adj.D.parents = { "B" }
    c.moveTo("B")
    T.eq(c.navigateDown(), "D", "second descent sees the mutated child list")
end

return M
