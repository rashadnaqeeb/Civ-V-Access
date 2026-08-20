-- Scanner backend: cities (My / Teammate / City States / Neutral / Enemy)
-- and barbarian camps. Iterates Players[p]:Cities() across every major,
-- minor and barbarian slot and partitions ownership against the active
-- team's war state. Barb camps come from a separate plot sweep for
-- IMPROVEMENT_BARBARIAN_CAMP -- they're improvements, not cities, but live
-- under Cities because that's the hostile-settlement mental slot.

ScannerBackendCities = {
    name = "cities",
}

-- Inclusive bound: BARBARIAN_PLAYER is MAX_CIV_PLAYERS itself, the slot
-- straight after the last minor civ, and barbarians keep the cities they
-- capture, so the sweep has to reach that slot.
local MAX_PLAYER_INDEX = (GameDefines and GameDefines.MAX_CIV_PLAYERS) or 63

-- Which Cities subcategory a city falls into, from the active team's
-- perspective. War check leads so an at-war city-state bucks into enemy
-- alongside hostile major civs (the relationship the user is acting on is
-- "they're shooting at me"); city-states at peace get their own bucket so
-- they don't crowd the major-civ neutral list. Same-team-but-different-
-- player owners route into `teammate` rather than `my` so cycling through
-- your own cities isn't padded with cities you can't manage.
--
-- Barbarians hold what they take rather than razing it, so their slot owns
-- real cities and routes by ORIGINAL owner, not current. A city-state the
-- barbarians overran stays under city_states: recapturing it resurrects
-- the city-state (CvPlayer::CanLiberatePlayerCity resolves the now-dead
-- original owner through CanLiberatePlayer), so it is still the same
-- city-state the player was tracking, on the same spot, and it would
-- otherwise drop out of the list the moment it fell. Anything else the
-- barbarians hold is an enemy city -- you are always at war with them.
-- Either way the entry's name carries the barbarian marker, so the bucket
-- never implies the city is in friendly hands.
local function citySubcategory(city, cityOwnerId, owner, activePlayerId, activeTeam)
    if owner:IsBarbarian() then
        local originalOwner = Players[city:GetOriginalOwner()]
        if originalOwner ~= nil and originalOwner:IsMinorCiv() then
            return "city_states"
        end
        return "enemy"
    end
    if cityOwnerId == activePlayerId then
        return "my"
    end
    local ownerTeamId = owner:GetTeam()
    if ownerTeamId == activeTeam then
        return "teammate"
    end
    if Teams[activeTeam]:IsAtWar(ownerTeamId) then
        return "enemy"
    end
    if owner:IsMinorCiv() then
        return "city_states"
    end
    return "neutral"
end

-- No IsHasMet gate: a revealed city plot is already public information.
-- The cursor announces the civ name from plot:GetRevealedOwner the moment
-- you step onto a revealed foreign tile, and a sighted player sees the
-- owner's border color and city banner immediately on reveal. Gating the
-- scanner on diplomatic meeting would hide cities the player can already
-- locate by walking the cursor over them (e.g. goody-hut map reveal that
-- surfaces a foreign city before any unit-adjacency meeting has happened
-- -- setRevealed alone does not call kTeam.meet, see CvPlayer.cpp goody
-- map branch). Per-plot IsRevealed is the only visibility gate needed.
--
-- With the F12 group-by-civ toggle on, every major civ's cities collapse
-- into one item (itemKey per owner, so identically-named duplicate civs
-- in MP stay apart; itemName is the civ's short description) and the
-- individual cities become that item's instances, each speaking its own
-- name via instanceName. City-states keep one item per city: they are
-- one-city civs, and grouping would announce their only city as
-- "<state>. <same state's city>" noise. Barbarian holdings stay ungrouped
-- for the mirror-image reason -- they are not a polity the player tracks
-- as one thing but a set of separate recapture targets, and collapsing
-- them would seat a "Barbarians" item inside City States that hides which
-- city-state is under the boot.
local function scanCities(activePlayer, activeTeam, out)
    local groupByCiv = civvaccess_shared.scannerGroupCitiesByCiv == true
    for playerId = 0, MAX_PLAYER_INDEX do
        local player = Players[playerId]
        if player ~= nil and player:IsAlive() then
            local isBarb = player:IsBarbarian()
            local civName, civItemKey
            if groupByCiv and not player:IsMinorCiv() and not isBarb then
                civName = Text.key(player:GetCivilizationShortDescriptionKey())
                civItemKey = "civ:" .. playerId
            end
            for city in player:Cities() do
                local plot = city:Plot()
                if plot ~= nil and plot:IsRevealed(activeTeam) then
                    local cityId = city:GetID()
                    local cityName = Text.key(city:GetNameKey())
                    if isBarb then
                        cityName = Text.format("TXT_KEY_CIVVACCESS_SCANNER_CITY_BARBARIAN_HELD", cityName)
                    end
                    out[#out + 1] = {
                        plotIndex = plot:GetPlotIndex(),
                        backend = ScannerBackendCities,
                        data = {
                            kind = "city",
                            ownerId = playerId,
                            cityId = cityId,
                        },
                        category = "cities",
                        subcategory = citySubcategory(city, playerId, player, activePlayer, activeTeam),
                        itemName = civName or cityName,
                        itemKey = civItemKey,
                        instanceName = civName and cityName or nil,
                        key = "cities:city:" .. playerId .. ":" .. cityId,
                        sortKey = 0,
                    }
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

-- instanceName is the per-city spoken name of a civ-grouped entry;
-- ungrouped entries (toggle off, city-states, camps) speak itemName.
-- Both are captured at Scan time, which is fresh enough: every scanner
-- keystroke rebuilds the snapshot from a new Scan.
function ScannerBackendCities.FormatName(entry)
    return entry.instanceName or entry.itemName
end

ScannerCore.registerBackend(ScannerBackendCities)
