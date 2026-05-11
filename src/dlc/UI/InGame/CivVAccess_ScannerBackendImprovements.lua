-- Scanner backend: improvements (My / My Pillaged / Teammate / Neutral
-- / Enemy by owner team stance). Reads plot:GetRevealedImprovementType
-- (activeTeam) so the scanner matches the engine's own rendering under
-- fog. Skips the barb-camp and goody-hut improvements (handled by the
-- Cities and Special backends respectively) and the road / railroad
-- improvements if they exist (base game treats them as routes, not
-- improvements; the skip is belt-and-braces in case a mod promotes them).
--
-- Ownership buckets via plot:GetRevealedOwner because Civ V does not
-- expose a GetRevealedImprovementOwner; the tile owner IS the
-- improvement owner in every base-game case (forts in no-man's-land
-- end up with RevealedOwner == -1, which buckets to Neutral per the
-- design's explicit "unowned improvements fall under Neutral" rule).
--
-- The pillaged carve-out is exclusive AND player-only: a pillaged
-- improvement on a tile the active player owns moves out of `my` into
-- `my_pillaged`, so `my` reads as productive improvements and
-- `my_pillaged` reads as a repair list. Teammate-owned tiles bucket
-- into `teammate` regardless of pillage state because workers can only
-- repair on tiles you own outright, so a teammate's pillaged tile
-- isn't repair-list material -- there's no parallel `teammate_pillaged`
-- bucket. Enemy / neutral pillaged improvements stay in their owner sub.
--
-- Pillage state is gated on current visibility (plot:IsVisible). The
-- engine-side IsImprovementPillaged() is a raw m_bImprovementPillaged
-- read with no fog filter, so an unguarded call would leak pillage
-- updates on tiles that have gone under fog since the player last saw
-- them. The engine itself only renders the pillaged appearance when
-- FOGOFWARMODE_OFF; we mirror that. When the tile is fogged, the entry
-- routes by last-seen state -- a healthy improvement stays in `my`.

ScannerBackendImprovements = {
    name = "improvements",
}

local SKIP_TYPES = {
    "IMPROVEMENT_BARBARIAN_CAMP",
    "IMPROVEMENT_GOODY_HUT",
    "IMPROVEMENT_ROAD",
    "IMPROVEMENT_RAILROAD",
}

local function ownerSubcategory(ownerId, activePlayerId, activeTeam, isPillaged)
    if ownerId < 0 then
        return "neutral"
    end
    if ownerId == activePlayerId then
        return isPillaged and "my_pillaged" or "my"
    end
    local owner = Players[ownerId]
    if owner == nil then
        return "neutral"
    end
    local ownerTeamId = owner:GetTeam()
    if ownerTeamId == activeTeam then
        -- Teammate-owned: routes to `teammate` regardless of pillage
        -- state. Workers cannot repair improvements on a teammate's
        -- tile, so a `teammate_pillaged` bucket would surface entries
        -- the player can't act on.
        return "teammate"
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
                    -- IsImprovementPillaged reads server truth; gate on
                    -- IsVisible so a fogged tile that was last seen
                    -- healthy doesn't leak its current pillage state.
                    local isPillaged = plot:IsVisible(activeTeam, isDebug) and plot:IsImprovementPillaged()
                    local sub = ownerSubcategory(ownerId, activePlayer, activeTeam, isPillaged)
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
    -- Owner classification drift (conquest, eviction) and pillage /
    -- repair flips the entry between subs; the snapshot rebuild on
    -- turn start or Ctrl+PageUp re-emits it under the new sub. Between
    -- rebuilds we keep it where it is -- a re-bucket mid-snapshot would
    -- reorder unexpectedly.
    return true
end

function ScannerBackendImprovements.FormatName(entry)
    return entry.itemName
end

ScannerCore.registerBackend(ScannerBackendImprovements)
