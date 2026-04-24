-- Domain-agnostic DAG cursor. Four directional moves collapse the graph:
-- Up to a parent, Down to a child, Left / Right cycle among siblings.
-- "Sibling" is the list produced by the last vertical move (children of
-- the node we came from after Down, parents after Up). At a root, the
-- sibling list is the full root set so Left / Right walks across the
-- top. Nodes are opaque values; callers supply three lambdas that agree
-- on node identity, and all neighbor lookups go through the lambdas on
-- demand (no adjacency caching). If the underlying graph mutates between
-- moves, the cursor sees the new shape on the next call.
--
-- Built as a constructor so independent cursors can coexist (tech tree,
-- policy tree, etc. each keep their own state without a shared upvalue).
--
-- Config lambdas, all returning arrays in stable caller-chosen order:
--   getParents(node)  -> list of nodes (empty for roots)
--   getChildren(node) -> list of nodes
--   getRoots()        -> list of nodes
--
-- Methods:
--   current()                       the current node (nil before first moveTo)
--   moveTo(node)                    set cursor, drop sibling context
--   moveToWithSiblings(node, list)  set cursor and seed siblings (use at
--                                   init when landing on a root so Left /
--                                   Right immediately walks the root set)
--   navigateUp()                    returns new current, or nil at root
--   navigateDown()                  returns new current, or nil at leaf
--   cycleSibling(dir)               returns (new current, wrapped); returns
--                                   (nil, false) when there are fewer than
--                                   two siblings
--   hasParents / hasChildren / hasSiblings
--                                   booleans; hasSiblings requires > 1

NavigableGraph = {}

local function findIndex(list, node)
    for i, v in ipairs(list) do
        if v == node then
            return i
        end
    end
    return 1
end

function NavigableGraph.new(config)
    assert(type(config) == "table", "NavigableGraph.new: config table required")
    assert(type(config.getParents) == "function", "NavigableGraph.new: config.getParents required")
    assert(type(config.getChildren) == "function", "NavigableGraph.new: config.getChildren required")
    assert(type(config.getRoots) == "function", "NavigableGraph.new: config.getRoots required")

    local getParents = config.getParents
    local getChildren = config.getChildren
    local getRoots = config.getRoots

    local self = {
        _current = nil,
        _siblings = nil,
        _siblingIndex = 0,
    }

    function self.current()
        return self._current
    end

    function self.hasParents()
        if self._current == nil then
            return false
        end
        return #getParents(self._current) > 0
    end

    function self.hasChildren()
        if self._current == nil then
            return false
        end
        return #getChildren(self._current) > 0
    end

    function self.hasSiblings()
        return self._siblings ~= nil and #self._siblings > 1
    end

    function self.moveTo(node)
        self._current = node
        self._siblings = nil
        self._siblingIndex = 0
    end

    function self.moveToWithSiblings(node, siblings)
        self._current = node
        self._siblings = siblings
        self._siblingIndex = findIndex(siblings, node)
    end

    function self.navigateDown()
        if self._current == nil then
            return nil
        end
        local children = getChildren(self._current)
        if #children == 0 then
            return nil
        end
        self._siblings = children
        self._siblingIndex = 1
        self._current = children[1]
        return self._current
    end

    -- Root-swap special case: when the new current is itself a root, its
    -- natural sibling list (parents of the old current) is wrong for
    -- Left / Right navigation — the user expects to walk roots, not one-off
    -- parent lists. Swap siblings to getRoots() so Left / Right cycles the
    -- root set.
    function self.navigateUp()
        if self._current == nil then
            return nil
        end
        local parents = getParents(self._current)
        if #parents == 0 then
            return nil
        end
        local newCurrent = parents[1]
        if #getParents(newCurrent) == 0 then
            local roots = getRoots()
            self._siblings = roots
            self._siblingIndex = findIndex(roots, newCurrent)
        else
            self._siblings = parents
            self._siblingIndex = 1
        end
        self._current = newCurrent
        return newCurrent
    end

    function self.cycleSibling(dir)
        if self._siblings == nil or #self._siblings < 2 then
            return nil, false
        end
        local n = #self._siblings
        local nextIdx = self._siblingIndex + dir
        local wrapped = false
        if nextIdx < 1 then
            nextIdx = n
            wrapped = true
        elseif nextIdx > n then
            nextIdx = 1
            wrapped = true
        end
        self._siblingIndex = nextIdx
        self._current = self._siblings[nextIdx]
        return self._current, wrapped
    end

    return self
end

return NavigableGraph
