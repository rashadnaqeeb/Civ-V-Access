-- Scanner backend: improvements (My / Neutral / Enemy by owner team
-- stance). Reads plot:GetRevealedImprovementType(activeTeam) so the
-- scanner matches the engine's own rendering under fog. Skips the
-- barb-camp and goody-hut improvements (handled by the Cities and
-- Special backends respectively) and the road / railroad improvements
-- if they exist (base game treats them as routes, not improvements;
-- the skip is belt-and-braces in case a mod promotes them).
--
-- Ownership buckets via plot:GetRevealedOwner because Civ V does not
-- expose a GetRevealedImprovementOwner; the tile owner IS the
-- improvement owner in every base-game case (forts in no-man's-land
-- end up with RevealedOwner == -1, which buckets to Neutral per the
-- design's explicit "unowned improvements fall under Neutral" rule).

ScannerBackendImprovements = {
    name = "improvements",
}

local SKIP_TYPES = {
    "IMPROVEMENT_BARBARIAN_CAMP",
    "IMPROVEMENT_GOODY_HUT",
    "IMPROVEMENT_ROAD",
    "IMPROVEMENT_RAILROAD",
}

local function ownerSubcategory(ownerId, activePlayerId, activeTeam)
    if ownerId < 0 then
        return "neutral"
    end
    if ownerId == activePlayerId then
        return "my"
    end
    local owner = Players[ownerId]
    if owner == nil then
        return "neutral"
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

function ScannerBackendImprovements.Scan(activePlayer, activeTeam)
    local out = {}
    local isDebug = Game.IsDebugMode()
    local skipIds = {}
    if GameInfoTypes ~= nil then
        for _, typeName in ipairs(SKIP_TYPES) do
            local id = GameInfoTypes[typeName]
            if id ~= nil and id >= 0 then
                skipIds[id] = true
            end
        end
    end
    for i = 0, Map.GetNumPlots() - 1 do
        local plot = Map.GetPlotByIndex(i)
        if plot ~= nil then
            local impId = plot:GetRevealedImprovementType(activeTeam, isDebug)
            if impId ~= nil and impId >= 0 and not skipIds[impId] then
                local row = GameInfo.Improvements[impId]
                if row ~= nil and row.Description ~= nil then
                    local ownerId = plot:GetRevealedOwner(activeTeam, isDebug)
                    local sub = ownerSubcategory(ownerId, activePlayer, activeTeam)
                    out[#out + 1] = {
                        plotIndex = i,
                        backend = ScannerBackendImprovements,
                        data = {
                            improvementId = impId,
                            ownerId = ownerId,
                        },
                        category = "improvements",
                        subcategory = sub,
                        itemName = Text.key(row.Description),
                        key = "improvements:" .. i,
                        sortKey = 0,
                    }
                end
            end
        end
    end
    return out
end

function ScannerBackendImprovements.ValidateEntry(entry, _cursorPlotIndex)
    local plot = Map.GetPlotByIndex(entry.plotIndex)
    if plot == nil then
        return false
    end
    local activeTeam = Game.GetActiveTeam()
    local isDebug = Game.IsDebugMode()
    if plot:GetRevealedImprovementType(activeTeam, isDebug) ~= entry.data.improvementId then
        return false
    end
    -- Owner classification drift (conquest, eviction) flips the entry
    -- between subs; the snapshot rebuild on turn start or Ctrl+PageUp
    -- re-emits it under the new sub. Between rebuilds we keep it where
    -- it is -- a re-bucket mid-snapshot would reorder unexpectedly.
    return true
end

function ScannerBackendImprovements.FormatName(entry)
    return entry.itemName
end

ScannerCore.registerBackend(ScannerBackendImprovements)
