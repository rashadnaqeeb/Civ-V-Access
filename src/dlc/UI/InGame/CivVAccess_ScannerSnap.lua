-- Snapshot builder. Turns a flat list of ScanEntry tables into the
-- nested category -> subcategory -> item -> instance structure the
-- navigator walks. Also owns prune-by-instance for the mid-snapshot
-- validation path (ValidateEntry returns false on the current instance).
--
-- Sort order (design section 5):
--   instances within an item      distance ascending (live cursor at
--                                 build time), then sortKey, then
--                                 plotIndex as a stable tiebreaker
--   items within a subcategory    nearest-instance distance ascending
--   subcategories                 taxonomy order with `all` at index 1
--   categories                    taxonomy order
--
-- Shape returned:
--   {
--     cursorX, cursorY,           the (x, y) the build was sorted against
--     categories = { [i] = {
--       key, label,
--       subcategories = { [j] = {
--         key, label,
--         items = { [k] = {
--           name,                 the spoken label items collapse by
--           instances = { [l] = {
--             entry,              the original ScanEntry (ref)
--             plotX, plotY,       cached at build time for sorting only
--             distance,           PlotDistance from (cursorX, cursorY)
--                                 at build time
--           } }
--         } }
--       } }
--     } }
--   }
--
-- `all` subcategory shares item references with the named sibling that
-- first produced each item. Pruning an item from a named sub also
-- removes it from `all` by identity; ScannerSnap.pruneInstance does the
-- bookkeeping.

ScannerSnap = {}

local function newCategory(catDef)
    local subs = {}
    -- `all` is always first. Uses a mod-authored label; the other subs
    -- pull whatever key their taxonomy entry declared (game or mod).
    subs[1] = {
        key          = "all",
        label        = "TXT_KEY_CIVVACCESS_SCANNER_SUB_ALL",
        items        = {},
        _itemsByName = {},
    }
    for _, subDef in ipairs(catDef.subcategories) do
        subs[#subs + 1] = {
            key          = subDef.key,
            label        = subDef.label,
            items        = {},
            _itemsByName = {},
        }
    end
    local subsByKey = {}
    for _, sub in ipairs(subs) do subsByKey[sub.key] = sub end
    return {
        key           = catDef.key,
        label         = catDef.label,
        subcategories = subs,
        _subsByKey    = subsByKey,
    }
end

local function sortSnapshot(snapshot)
    for _, cat in ipairs(snapshot.categories) do
        for _, sub in ipairs(cat.subcategories) do
            for _, item in ipairs(sub.items) do
                table.sort(item.instances, function(a, b)
                    if a.distance ~= b.distance then
                        return a.distance < b.distance
                    end
                    local ka = a.entry.sortKey or 0
                    local kb = b.entry.sortKey or 0
                    if ka ~= kb then return ka < kb end
                    return a.entry.plotIndex < b.entry.plotIndex
                end)
            end
            table.sort(sub.items, function(a, b)
                -- Both items have at least one instance here because
                -- items are only created when an entry lands in them.
                return a.instances[1].distance < b.instances[1].distance
            end)
        end
    end
end

-- Build a fresh snapshot from entries and the cursor position to sort
-- distances against. Drops entries whose category / subcategory keys
-- don't match the taxonomy or whose plotIndex does not resolve; each
-- drop is logged because it would otherwise be a silent backend bug.
function ScannerSnap.build(entries, cursorX, cursorY)
    local catsByKey = {}
    local cats = {}
    for _, catDef in ipairs(ScannerCore.CATEGORIES) do
        local cat = newCategory(catDef)
        cats[#cats + 1] = cat
        catsByKey[cat.key] = cat
    end

    for _, entry in ipairs(entries) do
        local cat = catsByKey[entry.category]
        if cat == nil then
            Log.warn("ScannerSnap: entry with unknown category '"
                .. tostring(entry.category) .. "' from backend "
                .. tostring(entry.backend and entry.backend.name))
        else
            local sub = cat._subsByKey[entry.subcategory]
            if sub == nil then
                Log.warn("ScannerSnap: entry with unknown subcategory '"
                    .. tostring(entry.subcategory) .. "' under '"
                    .. tostring(entry.category) .. "'")
            else
                local plot = Map.GetPlotByIndex(entry.plotIndex)
                if plot == nil then
                    Log.warn("ScannerSnap: entry with unresolved plotIndex "
                        .. tostring(entry.plotIndex))
                else
                    local px, py = plot:GetX(), plot:GetY()
                    local dist = Map.PlotDistance(cursorX, cursorY, px, py)
                    local instance = {
                        entry    = entry,
                        plotX    = px,
                        plotY    = py,
                        distance = dist,
                    }
                    local item = sub._itemsByName[entry.itemName]
                    if item == nil then
                        item = { name = entry.itemName, instances = {} }
                        sub._itemsByName[entry.itemName] = item
                        sub.items[#sub.items + 1] = item
                        -- Share the ref into `all` so pruning a named
                        -- sub's item also removes the entry from `all`.
                        local all = cat.subcategories[1]
                        all.items[#all.items + 1] = item
                    end
                    item.instances[#item.instances + 1] = instance
                end
            end
        end
    end

    local snapshot = {
        cursorX    = cursorX,
        cursorY    = cursorY,
        categories = cats,
    }
    sortSnapshot(snapshot)

    -- Drop helpers after sorting; they'd otherwise retain references to
    -- items that get pruned later. Pruning walks cat.subcategories
    -- directly.
    for _, cat in ipairs(cats) do
        cat._subsByKey = nil
        for _, sub in ipairs(cat.subcategories) do
            sub._itemsByName = nil
        end
    end
    return snapshot
end

-- Drop (catIdx, subIdx, itemIdx, instIdx) from the snapshot. If the
-- item empties out, the item itself is removed from the sub AND from
-- every sibling sub (i.e. `all`) that still references it by identity.
-- Nav calls this when ValidateEntry returns false on the current
-- instance; the caller then re-reads the new counts to decide where
-- to land.
function ScannerSnap.pruneInstance(snapshot, catIdx, subIdx, itemIdx, instIdx)
    local cat = snapshot.categories[catIdx]
    if cat == nil then return end
    local sub = cat.subcategories[subIdx]
    if sub == nil then return end
    local item = sub.items[itemIdx]
    if item == nil then return end
    table.remove(item.instances, instIdx)
    if #item.instances > 0 then return end

    -- Empty item: remove it from this sub and every other sub in the
    -- same category that references the same item object.
    for _, other in ipairs(cat.subcategories) do
        for i = #other.items, 1, -1 do
            if other.items[i] == item then
                table.remove(other.items, i)
                break
            end
        end
    end
end
