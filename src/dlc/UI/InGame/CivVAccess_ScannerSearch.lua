-- Scanner search filter. Runs every backend entry's itemName through
-- TypeAheadSearch.matchTier against a user query and emits a synthetic
-- snapshot: one category ("search"), with subcategories keyed by the
-- entries' original category. Items sort by (match tier ascending, then
-- nearest-instance distance), so start-of-string hits surface before
-- substring hits within each original-category bucket.
--
-- The synthetic snapshot has the same shape as ScannerSnap.build output so
-- ScannerNav walks it with no special-case code. The `isSearch` flag lets
-- Nav know the current snapshot should be discarded on the next category
-- cycle rather than preserved across rebuilds (section 8).

ScannerSearch = {}

local function newSub(key, label)
    return {
        key = key,
        label = label,
        items = {},
        _itemsByName = {},
    }
end

-- Returns a snapshot when at least one entry matches; nil otherwise so the
-- caller can speak the no-match token without installing a dead snapshot.
function ScannerSearch.build(entries, query, cursorX, cursorY)
    if query == nil then
        return nil
    end
    local trimmed = query:match("^%s*(.-)%s*$") or ""
    if #trimmed == 0 then
        return nil
    end
    local lowerQuery = string.lower(trimmed)

    -- Build per-original-category buckets in taxonomy order so the sub
    -- order in the synthetic snapshot mirrors the normal scanner ordering
    -- (cities first, then my units, neutral units, etc.).
    local subsByKey = {}
    local orderedCatKeys = {}
    for _, catDef in ipairs(ScannerCore.CATEGORIES) do
        subsByKey[catDef.key] = newSub(catDef.key, catDef.label)
        orderedCatKeys[#orderedCatKeys + 1] = catDef.key
    end

    local matchCount = 0
    for _, entry in ipairs(entries) do
        local tier = TypeAheadSearch.matchTier(string.lower(entry.itemName or ""), lowerQuery)
        if tier >= 0 then
            local plot = Map.GetPlotByIndex(entry.plotIndex)
            if plot == nil then
                Log.warn("ScannerSearch: entry with unresolved plotIndex " .. tostring(entry.plotIndex))
            else
                local sub = subsByKey[entry.category]
                if sub == nil then
                    Log.warn("ScannerSearch: entry with unknown category '" .. tostring(entry.category) .. "'")
                else
                    local px, py = plot:GetX(), plot:GetY()
                    local dist = Map.PlotDistance(cursorX, cursorY, px, py)
                    local instance = {
                        entry = entry,
                        key = entry.key,
                        plotX = px,
                        plotY = py,
                        distance = dist,
                    }
                    local item = sub._itemsByName[entry.itemName]
                    if item == nil then
                        item = {
                            name = entry.itemName,
                            instances = {},
                            _tier = tier,
                        }
                        sub._itemsByName[entry.itemName] = item
                        sub.items[#sub.items + 1] = item
                    elseif tier < item._tier then
                        -- Multiple entries can share a name across different
                        -- instances. Keep the best tier as the item's tier
                        -- so a single mid-substring hit doesn't demote an
                        -- item whose name also starts with the query.
                        item._tier = tier
                    end
                    item.instances[#item.instances + 1] = instance
                    matchCount = matchCount + 1
                end
            end
        end
    end

    if matchCount == 0 then
        return nil
    end

    -- Assemble non-empty subs in taxonomy order. The `all` sub holds shared
    -- item references across every named sub, matching ScannerSnap's
    -- convention (pruning from a named sub also removes from `all`).
    local namedSubs = {}
    for _, key in ipairs(orderedCatKeys) do
        local sub = subsByKey[key]
        if #sub.items > 0 then
            namedSubs[#namedSubs + 1] = sub
        end
    end

    for _, sub in ipairs(namedSubs) do
        for _, item in ipairs(sub.items) do
            table.sort(item.instances, function(a, b)
                if a.distance ~= b.distance then
                    return a.distance < b.distance
                end
                return a.entry.plotIndex < b.entry.plotIndex
            end)
        end
        table.sort(sub.items, function(a, b)
            if a._tier ~= b._tier then
                return a._tier < b._tier
            end
            return a.instances[1].distance < b.instances[1].distance
        end)
        sub._itemsByName = nil
    end

    local allSub = {
        key = "all",
        label = "TXT_KEY_CIVVACCESS_SCANNER_SUB_ALL",
        items = {},
    }
    for _, sub in ipairs(namedSubs) do
        for _, item in ipairs(sub.items) do
            allSub.items[#allSub.items + 1] = item
        end
    end
    table.sort(allSub.items, function(a, b)
        if a._tier ~= b._tier then
            return a._tier < b._tier
        end
        return a.instances[1].distance < b.instances[1].distance
    end)

    local subs = { allSub }
    for _, sub in ipairs(namedSubs) do
        subs[#subs + 1] = sub
    end

    return {
        cursorX = cursorX,
        cursorY = cursorY,
        isSearch = true,
        categories = {
            {
                key = "search",
                label = "TXT_KEY_CIVVACCESS_SCANNER_SEARCH_RESULTS",
                subcategories = subs,
            },
        },
    }
end
