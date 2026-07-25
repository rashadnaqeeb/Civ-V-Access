-- Scanner search filter. Runs every backend entry's itemName (and its
-- instanceName alias, when grouped entries carry one) through
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
    local trimmed = Text.trim(query)
    if #trimmed == 0 then
        return nil
    end
    -- Locale.ToLower, not string.lower: queries arrive from an engine
    -- EditBox in whatever case and script the keyboard layout produced,
    -- and only the engine's lowering folds non-ASCII (Cyrillic, accented
    -- Latin) so those match case-insensitively like ASCII does.
    local lowerQuery = Locale.ToLower(trimmed)

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
        local tier = TypeAheadSearch.matchTier(Locale.ToLower(entry.itemName or ""), lowerQuery)
        -- instanceName is the per-entity alias of a grouped entry (the
        -- city under a civ-name item). The better of the two tiers drives
        -- the match, so searching a city name still finds the city when
        -- the group-by-civ toggle has moved it under its civ's item.
        if entry.instanceName ~= nil then
            local aliasTier = TypeAheadSearch.matchTier(Locale.ToLower(entry.instanceName), lowerQuery)
            if aliasTier >= 0 and (tier < 0 or aliasTier < tier) then
                tier = aliasTier
            end
        end
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
                    -- Identity-keyed grouping, matching ScannerSnap's
                    -- placeEntry: itemKey separates same-named entries and
                    -- collapses grouped ones; the displayed name stays
                    -- itemName.
                    local itemId = entry.itemKey or entry.itemName
                    local item = sub._itemsByName[itemId]
                    if item == nil then
                        item = {
                            name = entry.itemName,
                            instances = {},
                            _tier = tier,
                        }
                        sub._itemsByName[itemId] = item
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
