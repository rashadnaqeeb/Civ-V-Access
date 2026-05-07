-- Scanner backend: worked tiles of the head-selected city. The category
-- only exists while the CityView "Manage territory" sub is the active
-- handler -- that sub installs civvaccess_shared.mapScope and we gate on
-- it. Outside of CityView, mapScope is nil and Scan emits nothing, so
-- categoryHasItems / Nav skip the category in cycle order.
--
-- itemName composition: comma-joined non-zero yields ("3 food, 2 production"),
-- using the same TXT_KEY_CIVVACCESS_YIELD_COUNT shape as PlotComposers so
-- the worked-tile readout matches the rest of the mod's plot speech.
-- Tiles with the same yield string collapse into one item with multiple
-- instances; the user steps through equivalents with Alt+PageUp/Down.
--
-- Foreign cities (espionage panel / spy peek): vanilla CityView has no
-- list-worked-tiles surface for foreign cities and we don't synthesize
-- one. Scan returns empty when the head-selected city is foreign --
-- viewing-mode-on-own (peeks at our own city) is fine because the data
-- is already the player's.

ScannerBackendWorkedTiles = {
    name = "worked_tiles",
}

-- Yield order matches PlotComposers.readYields. Culture and faith sit
-- after the four "primary" yields because they're rarer per-tile and
-- a tile that only produces them is the exception, not the norm.
local YIELD_KEYS = {
    { id = YieldTypes.YIELD_FOOD, key = "TXT_KEY_CIVVACCESS_ICON_FOOD" },
    { id = YieldTypes.YIELD_PRODUCTION, key = "TXT_KEY_CIVVACCESS_ICON_PRODUCTION" },
    { id = YieldTypes.YIELD_GOLD, key = "TXT_KEY_CIVVACCESS_ICON_GOLD" },
    { id = YieldTypes.YIELD_SCIENCE, key = "TXT_KEY_CIVVACCESS_ICON_SCIENCE" },
    { id = YieldTypes.YIELD_CULTURE, key = "TXT_KEY_CIVVACCESS_ICON_CULTURE" },
    { id = YieldTypes.YIELD_FAITH, key = "TXT_KEY_CIVVACCESS_ICON_FAITH" },
}

local function buildYieldLabel(plot)
    local parts = {}
    for _, y in ipairs(YIELD_KEYS) do
        local n = plot:CalculateYield(y.id, true)
        if n > 0 then
            parts[#parts + 1] = Text.format("TXT_KEY_CIVVACCESS_YIELD_COUNT", n, Text.key(y.key))
        end
    end
    return table.concat(parts, ", ")
end

local function isForeign(city, activePlayer)
    return city:GetOwner() ~= activePlayer
end

function ScannerBackendWorkedTiles.Scan(activePlayer, _activeTeam)
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
    local cityX, cityY = city:GetX(), city:GetY()
    local out = {}
    for i = 0, city:GetNumCityPlots() - 1 do
        local plot = city:GetCityIndexPlot(i)
        if plot ~= nil and city:IsWorkingPlot(plot) then
            local px, py = plot:GetX(), plot:GetY()
            if not (px == cityX and py == cityY) then
                local label = buildYieldLabel(plot)
                if label ~= "" then
                    local plotIndex = plot:GetPlotIndex()
                    out[#out + 1] = {
                        plotIndex = plotIndex,
                        backend = ScannerBackendWorkedTiles,
                        data = {
                            cityOwner = city:GetOwner(),
                            cityID = city:GetID(),
                        },
                        category = "worked_tiles",
                        subcategory = "all",
                        itemName = label,
                        key = "worked_tiles:" .. plotIndex,
                        sortKey = 0,
                    }
                end
            end
        end
    end
    return out
end

function ScannerBackendWorkedTiles.ValidateEntry(entry, _cursorPlotIndex)
    local plot = Map.GetPlotByIndex(entry.plotIndex)
    if plot == nil then
        return false
    end
    -- Re-resolve the city by stored owner/ID rather than UI.GetHeadSelectedCity --
    -- the snapshot was built against a specific city, and validating against
    -- whichever city happens to be selected now would silently flip semantics
    -- if the user cycled to a different city without rebuilding.
    local owner = Players[entry.data.cityOwner]
    if owner == nil then
        return false
    end
    local city = owner:GetCityByID(entry.data.cityID)
    if city == nil then
        return false
    end
    return city:IsWorkingPlot(plot)
end

function ScannerBackendWorkedTiles.FormatName(entry)
    return entry.itemName
end

ScannerCore.registerBackend(ScannerBackendWorkedTiles)
