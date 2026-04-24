-- Scanner backend: cities (My / Neutral / Enemy) and barbarian camps.
-- Iterates Players[p]:Cities() across every major + minor slot, gating each
-- player by Teams[activeTeam]:IsHasMet; partitions ownership against the
-- active team's war state. Barb camps come from a separate plot sweep for
-- IMPROVEMENT_BARBARIAN_CAMP -- they're improvements, not cities, but live
-- under Cities because that's the hostile-settlement mental slot.

ScannerBackendCities = {
    name = "cities",
}

local MAX_PLAYERS = (GameDefines and GameDefines.MAX_CIV_PLAYERS) or 64

-- Which Cities subcategory a non-barbarian city falls into, from the
-- active team's perspective. Returns nil if the owner team is the barb
-- slot (cities shouldn't exist there, but be defensive at the boundary).
local function citySubcategory(cityOwnerId, activePlayerId, activeTeam)
    if cityOwnerId == activePlayerId then
        return "my"
    end
    local owner = Players[cityOwnerId]
    if owner == nil then
        return nil
    end
    local ownerTeamId = owner:GetTeam()
    if ownerTeamId == activeTeam then
        return "my"
    end
    if Teams[activeTeam]:IsAtWar(ownerTeamId) then
        return "enemy"
    end
    return "neutral"
end

local function scanCities(activePlayer, activeTeam, out)
    for playerId = 0, MAX_PLAYERS - 1 do
        local player = Players[playerId]
        if player ~= nil and player:IsAlive() and not player:IsBarbarian() then
            local teamId = player:GetTeam()
            -- Active player is trivially "met" by themselves; IsHasMet may
            -- return false for own team in some edge cases, so short-circuit.
            local met = (playerId == activePlayer) or Teams[activeTeam]:IsHasMet(teamId)
            if met then
                local sub = citySubcategory(playerId, activePlayer, activeTeam)
                if sub ~= nil then
                    for city in player:Cities() do
                        local plot = city:Plot()
                        if plot ~= nil and plot:IsRevealed(activeTeam) then
                            local cityId = city:GetID()
                            out[#out + 1] = {
                                plotIndex = plot:GetPlotIndex(),
                                backend = ScannerBackendCities,
                                data = {
                                    kind = "city",
                                    ownerId = playerId,
                                    cityId = cityId,
                                },
                                category = "cities",
                                subcategory = sub,
                                itemName = Text.key(city:GetNameKey()),
                                key = "cities:city:" .. playerId .. ":" .. cityId,
                                sortKey = 0,
                            }
                        end
                    end
                end
            end
        end
    end
end

local function scanBarbCamps(activeTeam, out)
    if GameInfoTypes == nil then
        return
    end
    local campType = GameInfoTypes.IMPROVEMENT_BARBARIAN_CAMP
    if campType == nil then
        return
    end
    local campLabel = Text.key("TXT_KEY_ADVISOR_BARBARIAN_CAMP_DISPLAY")
    local isDebug = Game.IsDebugMode()
    for i = 0, Map.GetNumPlots() - 1 do
        local plot = Map.GetPlotByIndex(i)
        if plot ~= nil and plot:GetRevealedImprovementType(activeTeam, isDebug) == campType then
            out[#out + 1] = {
                plotIndex = i,
                backend = ScannerBackendCities,
                data = { kind = "camp" },
                category = "cities",
                subcategory = "barb",
                itemName = campLabel,
                key = "cities:camp:" .. i,
                sortKey = 0,
            }
        end
    end
end

function ScannerBackendCities.Scan(activePlayer, activeTeam)
    local out = {}
    scanCities(activePlayer, activeTeam, out)
    scanBarbCamps(activeTeam, out)
    return out
end

function ScannerBackendCities.ValidateEntry(entry, _cursorPlotIndex)
    local plot = Map.GetPlotByIndex(entry.plotIndex)
    if plot == nil then
        return false
    end
    local activeTeam = Game.GetActiveTeam()
    if entry.data.kind == "camp" then
        if not GameInfoTypes then
            return false
        end
        local campType = GameInfoTypes.IMPROVEMENT_BARBARIAN_CAMP
        if campType == nil then
            return false
        end
        local isDebug = Game.IsDebugMode()
        return plot:GetRevealedImprovementType(activeTeam, isDebug) == campType
    end
    -- City: still owned by the same player, still revealed.
    if not plot:IsRevealed(activeTeam) then
        return false
    end
    if not plot:IsCity() then
        return false
    end
    local city = plot:GetPlotCity()
    if city == nil then
        return false
    end
    return city:GetOwner() == entry.data.ownerId and city:GetID() == entry.data.cityId
end

function ScannerBackendCities.FormatName(entry)
    return entry.itemName
end

ScannerCore.registerBackend(ScannerBackendCities)
