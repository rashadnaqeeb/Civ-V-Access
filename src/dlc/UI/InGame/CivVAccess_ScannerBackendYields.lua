-- Scanner backend: every candidate tile of the head-selected city, ranked
-- by yield. Answers "what's my best production tile" -- the `yields`
-- category's named subs (food / production / gold / science / culture /
-- faith) re-sort the same tiles by one yield descending, and its `all` sub
-- ranks every tile by total yield so the first item is the best overall.
--
-- Like worked_tiles, the category only exists while CityView's "Manage
-- territory" sub is the active handler (it installs civvaccess_shared.mapScope
-- and we gate on it). Unlike worked_tiles, this lists every plot in the
-- city's work ring, not just the currently-worked ones: the player is
-- comparing candidates, not auditing assignments. The ScannerNav scope
-- filter (civvaccess_shared.mapScope == CityView's hexMapScope) trims the
-- ring to the player-facing set -- tiles in this city's borders plus
-- purchasable plots -- so we don't re-derive that rule here.
--
-- This is a `resort` category (ScannerCore / ScannerSnap): each tile emits
-- one `all` entry sorted by total yield AND one entry per non-zero yield
-- into that yield's named sub, and ScannerSnap ranks items by sortKey
-- descending instead of distance. itemName is the comma-joined yield string,
-- led by the sub's yield in a named sub ("5 production, 3 food") and in the
-- default PlotComposers order in `all` ("3 food, 5 production"), so equal
-- tiles collapse into one item the user steps through with Alt+PageUp/Down.
-- Foreign cities emit nothing, matching worked_tiles.

ScannerBackendYields = {
    name = "yields",
}

-- Yield order and labels match PlotComposers.readYields / worked_tiles. `sub`
-- is the ScannerCore named-subcategory key each yield ranks under.
local YIELD_KEYS = {
    { id = YieldTypes.YIELD_FOOD, key = "TXT_KEY_CIVVACCESS_ICON_FOOD", sub = "food" },
    { id = YieldTypes.YIELD_PRODUCTION, key = "TXT_KEY_CIVVACCESS_ICON_PRODUCTION", sub = "production" },
    { id = YieldTypes.YIELD_GOLD, key = "TXT_KEY_CIVVACCESS_ICON_GOLD", sub = "gold" },
    { id = YieldTypes.YIELD_SCIENCE, key = "TXT_KEY_CIVVACCESS_ICON_SCIENCE", sub = "science" },
    { id = YieldTypes.YIELD_CULTURE, key = "TXT_KEY_CIVVACCESS_ICON_CULTURE", sub = "culture" },
    { id = YieldTypes.YIELD_FAITH, key = "TXT_KEY_CIVVACCESS_ICON_FAITH", sub = "faith" },
}

local YIELD_BY_ID = {}
for _, y in ipairs(YIELD_KEYS) do
    YIELD_BY_ID[y.id] = y
end

-- Comma-joined non-zero yields. When leadY is set its yield heads the list
-- (and is included even past the loop's non-zero filter, because a named-sub
-- entry only exists for tiles where it's non-zero anyway); the remaining
-- yields follow in PlotComposers order. leadY nil produces the default-order
-- "all" label.
local function buildLabel(plot, leadY)
    local parts = {}
    if leadY ~= nil then
        local n = plot:CalculateYield(leadY.id, true)
        parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_YIELD_COUNT", n, Text.key(leadY.key))
    end
    for _, y in ipairs(YIELD_KEYS) do
        if leadY == nil or y.id ~= leadY.id then
            local n = plot:CalculateYield(y.id, true)
            if n > 0 then
                parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_YIELD_COUNT", n, Text.key(y.key))
            end
        end
    end
    return table.concat(parts, ", ")
end

local function isForeign(city, activePlayer)
    return city:GetOwner() ~= activePlayer
end

function ScannerBackendYields.Scan(activePlayer, _activeTeam)
    if civvaccess_shared.mapScope == nil then
        return {}
    end
    local city = UI.GetHeadSelectedCity()
    if city == nil then
        return {}
    end
    if isForeign(city, activePlayer) then
        return {}
    end
    local cityOwner, cityID = city:GetOwner(), city:GetID()
    local cityX, cityY = city:GetX(), city:GetY()
    local out = {}
    for i = 0, city:GetNumCityPlots() - 1 do
        local plot = city:GetCityIndexPlot(i)
        if plot ~= nil then
            local px, py = plot:GetX(), plot:GetY()
            if not (px == cityX and py == cityY) then
                local plotIndex = plot:GetPlotIndex()
                local data = { cityOwner = cityOwner, cityID = cityID, leadId = nil }
                local total = 0
                for _, y in ipairs(YIELD_KEYS) do
                    local n = plot:CalculateYield(y.id, true)
                    total = total + n
                    if n > 0 then
                        out[#out + 1] = {
                            plotIndex = plotIndex,
                            backend = ScannerBackendYields,
                            data = { cityOwner = cityOwner, cityID = cityID, leadId = y.id },
                            category = "yields",
                            subcategory = y.sub,
                            itemName = buildLabel(plot, y),
                            key = "yields:" .. y.id .. ":" .. plotIndex,
                            sortKey = n,
                        }
                    end
                end
                -- The total-yield "all" entry. A tile with no yield at all
                -- (an unimproved mountain bought for a wonder adjacency, say)
                -- contributes nothing to rank, so skip it rather than seed an
                -- empty-label item.
                if total > 0 then
                    out[#out + 1] = {
                        plotIndex = plotIndex,
                        backend = ScannerBackendYields,
                        data = data,
                        category = "yields",
                        subcategory = "all",
                        itemName = buildLabel(plot, nil),
                        key = "yields:all:" .. plotIndex,
                        sortKey = total,
                    }
                end
            end
        end
    end
    return out
end

function ScannerBackendYields.ValidateEntry(entry, _cursorPlotIndex)
    local plot = Map.GetPlotByIndex(entry.plotIndex)
    if plot == nil then
        return false
    end
    -- Re-resolve by stored owner/ID rather than UI.GetHeadSelectedCity, for
    -- the same reason worked_tiles does: the snapshot was built against a
    -- specific city and the user may have cycled to another since.
    local owner = Players[entry.data.cityOwner]
    if owner == nil then
        return false
    end
    local city = owner:GetCityByID(entry.data.cityID)
    if city == nil then
        return false
    end
    -- Still a candidate iff the tile is in the player's borders or remains
    -- purchasable -- the same owned-or-purchasable test the scope filter
    -- applies on rebuild, so a tile lost or bought away drops out.
    if plot:GetOwner() == entry.data.cityOwner then
        return true
    end
    return city:CanBuyPlotAt(plot:GetX(), plot:GetY(), true)
end

function ScannerBackendYields.FormatName(entry)
    -- Live-query the label: yields shift as the city works/unworks tiles and
    -- as buildings change tile output, so the build-time itemName is only the
    -- grouping key. leadId picks the named-sub lead yield; nil is the `all`
    -- default-order label.
    local plot = Map.GetPlotByIndex(entry.plotIndex)
    if plot == nil then
        return entry.itemName
    end
    return buildLabel(plot, entry.data.leadId and YIELD_BY_ID[entry.data.leadId] or nil)
end

ScannerCore.registerBackend(ScannerBackendYields)
