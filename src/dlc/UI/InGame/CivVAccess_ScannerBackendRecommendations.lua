-- Scanner backend: AI tile recommendations. Mirrors the on-map anchor
-- markers the game places for Settlers and Workers by calling the same
-- Player:GetRecommendedFoundCityPlots / GetRecommendedWorkerPlots APIs
-- the engine uses in GenericWorldAnchor.lua.
--
-- All the gating, list, membership, and reason logic lives in
-- CivVAccess_RecommendationsCore.lua (Recommendations.*) because the
-- plot-section path (cursor-land "recommendation: X" announcement)
-- needs the same helpers. This file is just the scanner shape: map
-- those helpers onto ScanEntry tuples.
--
-- Gating mirrors InGame.lua's anchor-fire pipeline:
--   * OptionsManager.IsNoTileRecommendations()  player-toggleable hide
--   * UI.CanSelectionListFound() + player has     settler-rec emit gate
--     at least one city
--   * UI.CanSelectionListWork()                   worker-rec emit gate
--   * player:CanFound(x, y) per settler plot      drops plots that
--                                                 became unfoundable
--                                                 (mirrors the same
--                                                 guard in HandleSettlerRecommendation)
--
-- Category declares subcategories = {}; entries target the implicit
-- `all` sub. Settler and worker recs rarely coexist in one selection
-- frame (the engine only populates each kind behind its matching
-- UI.CanSelectionList* gate), and splitting would add a navigation
-- step with no payoff when only one kind is live.

ScannerBackendRecommendations = {
    name = "recommendations",
}

local CITY_SITE_KEY = "TXT_KEY_CIVVACCESS_SCANNER_RECOMMENDATION_CITY_SITE"

local function buildItemName(buildType)
    local row = GameInfo.Builds and GameInfo.Builds[buildType]
    if row == nil or row.Description == nil then
        Log.warn(
            "ScannerBackendRecommendations: worker rec has no GameInfo.Builds row for buildType " .. tostring(buildType)
        )
        return nil
    end
    return Text.key(row.Description)
end

local function emitSettlerEntries(player, out)
    local cityLabel = Text.key(CITY_SITE_KEY)
    for _, plot in ipairs(Recommendations.settlerPlots(player)) do
        if plot ~= nil then
            local x, y = plot:GetX(), plot:GetY()
            if player:CanFound(x, y) then
                local plotIdx = plot:GetPlotIndex()
                out[#out + 1] = {
                    plotIndex = plotIdx,
                    backend = ScannerBackendRecommendations,
                    data = { kind = "settler" },
                    category = "recommendations",
                    subcategory = "all",
                    itemName = cityLabel,
                    key = "recommendations:settler:" .. plotIdx,
                    sortKey = 0,
                }
            end
        end
    end
end

local function emitWorkerEntries(player, out)
    for _, rec in ipairs(Recommendations.workerPlots(player)) do
        local plot = rec and rec.plot
        local buildType = rec and rec.buildType
        if plot ~= nil and buildType ~= nil then
            local name = buildItemName(buildType)
            if name ~= nil then
                local plotIdx = plot:GetPlotIndex()
                out[#out + 1] = {
                    plotIndex = plotIdx,
                    backend = ScannerBackendRecommendations,
                    data = { kind = "worker", buildType = buildType },
                    category = "recommendations",
                    subcategory = "all",
                    itemName = name,
                    key = "recommendations:worker:" .. plotIdx,
                    sortKey = 0,
                }
            end
        end
    end
end

function ScannerBackendRecommendations.Scan(activePlayer, _activeTeam)
    local out = {}
    if not Recommendations.allowed() then
        return out
    end
    local player = Players and Players[activePlayer]
    if player == nil then
        return out
    end
    if Recommendations.settlerActive(player) then
        emitSettlerEntries(player, out)
    end
    if Recommendations.workerActive() then
        emitWorkerEntries(player, out)
    end
    return out
end

-- ValidateEntry re-runs the gating and checks whether the plot is still
-- in the fresh rec list. Membership rather than just-CanFound for
-- settlers because a city going up within the min-city-distance circle
-- could keep CanFound true at (x, y) while the engine's strategic
-- assessment drops the plot from the rec list; for workers because the
-- recommended build on a plot can change (e.g. Farm -> Pasture when a
-- cattle resource is revealed by tech).
function ScannerBackendRecommendations.ValidateEntry(entry, _cursorPlotIndex)
    if not Recommendations.allowed() then
        return false
    end
    local plot = Map.GetPlotByIndex(entry.plotIndex)
    if plot == nil then
        return false
    end
    local player = Players and Players[Game.GetActivePlayer()]
    if player == nil then
        return false
    end
    local x, y = plot:GetX(), plot:GetY()
    if entry.data.kind == "settler" then
        if not Recommendations.settlerActive(player) then
            return false
        end
        if not player:CanFound(x, y) then
            return false
        end
        return Recommendations.settlerContains(player, x, y)
    elseif entry.data.kind == "worker" then
        if not Recommendations.workerActive() then
            return false
        end
        return Recommendations.workerContains(player, x, y, entry.data.buildType)
    end
    return false
end

function ScannerBackendRecommendations.FormatName(entry)
    return entry.itemName
end

ScannerCore.registerBackend(ScannerBackendRecommendations)
