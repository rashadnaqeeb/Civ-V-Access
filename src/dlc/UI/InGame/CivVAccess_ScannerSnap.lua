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
--             key,                copied from entry.key at build time so
--                                 Nav can re-find this instance across a
--                                 rebuild without holding an entry ref
--                                 (entries are freshly allocated by Scan)
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
--
-- Two emission modes for backends:
--   1. Named-sub: entry.subcategory is one of the category's declared
--      named subs. The item lands in that sub AND gets shared into
--      `all` by reference.
--   2. All-direct: the category has `subcategories = {}` and entries
--      emit `subcategory = "all"`. The item lands in `all` only; there
--      is no named-sib share step because there are no siblings.

ScannerSnap = {}

-- Fresh subcategory bucket. The implicit `all` and every named sub share
-- this shape; _itemsByName dedupes entries into items during build and is
-- dropped before the snapshot is returned.
local function newSub(key, label)
    return { key = key, label = label, items = {}, _itemsByName = {} }
end

local ALL_SUB_LABEL = "TXT_KEY_CIVVACCESS_SCANNER_SUB_ALL"

local function newCategory(catDef)
    -- `all` is always first. Uses a mod-authored label; the other subs
    -- pull whatever key their taxonomy entry declared (game or mod).
    local subs = { newSub("all", ALL_SUB_LABEL) }
    for _, subDef in ipairs(catDef.subcategories) do
        subs[#subs + 1] = newSub(subDef.key, subDef.label)
    end
    local subsByKey = {}
    for _, sub in ipairs(subs) do
        subsByKey[sub.key] = sub
    end
    return {
        key = catDef.key,
        label = catDef.label,
        subcategories = subs,
        _subsByKey = subsByKey,
    }
end

-- Place one entry into (cat, sub): get-or-create the item by name, append
-- a fresh instance, and share a newly-created item into the category's
-- `all` sub. Each call builds its own instance object, so the same entry
-- placed into a real category and a custom category gets independent
-- instances -- pruning one view never disturbs the other.
local function placeEntry(cat, sub, entry, px, py, dist)
    local instance = {
        entry = entry,
        key = entry.key,
        plotX = px,
        plotY = py,
        distance = dist,
    }
    local item = sub._itemsByName[entry.itemName]
    if item == nil then
        item = { name = entry.itemName, instances = {} }
        sub._itemsByName[entry.itemName] = item
        sub.items[#sub.items + 1] = item
        if sub.key ~= "all" then
            local all = cat.subcategories[1]
            all.items[#all.items + 1] = item
        end
    end
    item.instances[#item.instances + 1] = instance
end

-- Build a synthetic custom category from a customCategoryDefs() def. Its
-- subcategories are the user's selectors (plus the implicit `all` at index
-- 1); _selectorSubs carries the (sub, matchCat, matchSub) routing the
-- placement loop uses to mirror matching entries in. labelText overrides
-- the missing label key -- the spoken name is the positional "Custom N".
local function newCustomCategory(def)
    local subs = { newSub("all", ALL_SUB_LABEL) }
    local selectorSubs = {}
    for _, sel in ipairs(def.selectors) do
        local sub = newSub(sel.cat .. ":" .. sel.sub, sel.label)
        subs[#subs + 1] = sub
        selectorSubs[#selectorSubs + 1] = { sub = sub, matchCat = sel.cat, matchSub = sel.sub }
    end
    return {
        key = def.key,
        labelText = def.labelText,
        subcategories = subs,
        _selectorSubs = selectorSubs,
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
                    if ka ~= kb then
                        return ka < kb
                    end
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
-- customDefs (from ScannerFavorites.customCategoryDefs) synthesize the
-- user's "Custom N" categories: each entry is mirrored into every custom
-- selector sub it matches, and the custom categories sort to the front of
-- the cycle so a player reaches their clustered filters first. Custom
-- categories are skipped by Nav's categoryHasItems filter when empty.
function ScannerSnap.build(entries, cursorX, cursorY, customDefs)
    customDefs = customDefs or {}
    local catsByKey = {}
    local realCats = {}
    for _, catDef in ipairs(ScannerCore.CATEGORIES) do
        local cat = newCategory(catDef)
        realCats[#realCats + 1] = cat
        catsByKey[cat.key] = cat
    end

    local customCats = {}
    for _, def in ipairs(customDefs) do
        customCats[#customCats + 1] = newCustomCategory(def)
    end

    for _, entry in ipairs(entries) do
        local cat = catsByKey[entry.category]
        if cat == nil then
            Log.warn(
                "ScannerSnap: entry with unknown category '"
                    .. tostring(entry.category)
                    .. "' from backend "
                    .. tostring(entry.backend and entry.backend.name)
            )
        else
            local sub = cat._subsByKey[entry.subcategory]
            if sub == nil then
                Log.warn(
                    "ScannerSnap: entry with unknown subcategory '"
                        .. tostring(entry.subcategory)
                        .. "' under '"
                        .. tostring(entry.category)
                        .. "'"
                )
            else
                local plot = Map.GetPlotByIndex(entry.plotIndex)
                if plot == nil then
                    Log.warn("ScannerSnap: entry with unresolved plotIndex " .. tostring(entry.plotIndex))
                else
                    local px, py = plot:GetX(), plot:GetY()
                    local dist = Map.PlotDistance(cursorX, cursorY, px, py)
                    placeEntry(cat, sub, entry, px, py, dist)
                    -- Mirror into every custom category whose selector
                    -- matches. A selector of `all` catches every entry in
                    -- its category (including those that match no named
                    -- sub); a named selector catches only its own sub.
                    for _, customCat in ipairs(customCats) do
                        for _, selSub in ipairs(customCat._selectorSubs) do
                            if
                                selSub.matchCat == entry.category
                                and (selSub.matchSub == "all" or selSub.matchSub == entry.subcategory)
                            then
                                placeEntry(customCat, selSub.sub, entry, px, py, dist)
                            end
                        end
                    end
                end
            end
        end
    end

    local cats = {}
    for _, cat in ipairs(customCats) do
        cats[#cats + 1] = cat
    end
    for _, cat in ipairs(realCats) do
        cats[#cats + 1] = cat
    end

    local snapshot = {
        cursorX = cursorX,
        cursorY = cursorY,
        categories = cats,
    }
    sortSnapshot(snapshot)

    -- Drop helpers after sorting; they'd otherwise retain references to
    -- items that get pruned later. Pruning walks cat.subcategories
    -- directly.
    for _, cat in ipairs(cats) do
        cat._subsByKey = nil
        cat._selectorSubs = nil
        for _, sub in ipairs(cat.subcategories) do
            sub._itemsByName = nil
        end
    end
    return snapshot
end

-- Find the instance with the given key and return its (catIdx, subIdx,
-- itemIdx, instIdx) tuple, or nil when no instance in the snapshot
-- carries that key. Nav uses this to re-seat the user's cursor on the
-- same entity after a rebuild sorts everything differently.
--
-- The hint (catIdx, subIdx) is checked first so a user in a named sub
-- stays there even though the shared-ref invariant means the same item
-- also lives in `all`. Without the hint we'd deterministically surface
-- the `all` entry (sub index 1) and silently move the user off their
-- chosen sub.
function ScannerSnap.locate(snapshot, key, hintCatIdx, hintSubIdx)
    local function scanSub(sub, ci, si)
        for ii, item in ipairs(sub.items) do
            for ini, inst in ipairs(item.instances) do
                if inst.key == key then
                    return ci, si, ii, ini
                end
            end
        end
        return nil
    end
    if hintCatIdx ~= nil and hintSubIdx ~= nil then
        local cat = snapshot.categories[hintCatIdx]
        if cat ~= nil then
            local sub = cat.subcategories[hintSubIdx]
            if sub ~= nil then
                local ci, si, ii, ini = scanSub(sub, hintCatIdx, hintSubIdx)
                if ci ~= nil then
                    return ci, si, ii, ini
                end
            end
        end
    end
    for ci, cat in ipairs(snapshot.categories) do
        for si, sub in ipairs(cat.subcategories) do
            if not (ci == hintCatIdx and si == hintSubIdx) then
                local fci, fsi, fii, fini = scanSub(sub, ci, si)
                if fci ~= nil then
                    return fci, fsi, fii, fini
                end
            end
        end
    end
    return nil
end

-- Drop (catIdx, subIdx, itemIdx, instIdx) from the snapshot. If the
-- item empties out, the item itself is removed from the sub AND from
-- every sibling sub (i.e. `all`) that still references it by identity.
-- Nav calls this when ValidateEntry returns false on the current
-- instance; the caller then re-reads the new counts to decide where
-- to land.
function ScannerSnap.pruneInstance(snapshot, catIdx, subIdx, itemIdx, instIdx)
    local cat = snapshot.categories[catIdx]
    if cat == nil then
        return
    end
    local sub = cat.subcategories[subIdx]
    if sub == nil then
        return
    end
    local item = sub.items[itemIdx]
    if item == nil then
        return
    end
    table.remove(item.instances, instIdx)
    if #item.instances > 0 then
        return
    end

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
