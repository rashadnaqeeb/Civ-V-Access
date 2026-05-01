-- Shared helpers for walking visible-to-active-team foreign units into a
-- keyed metadata snapshot. Used by both ForeignUnitWatch (turn-start
-- speech of foreign units that entered or left view during the AI turn)
-- and RevealAnnounce (post-move speech of newly visible / hidden units).
-- The two callers share the visibility filter (IsVisible AND not
-- IsInvisible, mirroring ScannerBackendUnits) and the {count} {civ adj}
-- {unit name} list rendering, but each owns its own per-unit bucket
-- vocabulary ("hostile" / "neutral" vs "enemy" / "other") because their
-- downstream consumers key on different strings.

ForeignUnitSnapshot = {}

-- Stable key for snapshot membership. Keying by "<ownerId>:<unitId>" lets
-- a hide-direction diff drop captures cleanly: the captured unit appears
-- under a different ownerId in the new snapshot, so the original key
-- fails to match and the still-alive guard catches the rest.
function ForeignUnitSnapshot.unitKey(ownerId, unitId)
    return tostring(ownerId) .. ":" .. tostring(unitId)
end

-- Build a metadata record for a single unit. Used by the plot-walk
-- direction in RevealAnnounce, which discovers units one plot at a time
-- rather than via a global slot walk. civAdjKey or unitDescKey may be
-- nil (mod content with bad rows); callers drop the unit on either nil.
function ForeignUnitSnapshot.metadata(unit, ownerId, bucket)
    local civAdjKey = Players[ownerId]:GetCivilizationAdjectiveKey()
    local row = GameInfo.Units[unit:GetUnitType()]
    local unitDescKey = row and row.Description or nil
    return {
        ownerId = ownerId,
        unitId = unit:GetID(),
        civAdjKey = civAdjKey,
        unitDescKey = unitDescKey,
        bucket = bucket,
    }
end

-- Walk every foreign player slot and collect visible-to-active-team
-- units into a keyed metadata table. bucketFn(ownerId, activePlayerId,
-- activeTeam) returns the per-unit bucket label or nil to drop the
-- unit. Result shape:
--   { ["<ownerId>:<unitId>"] = { ownerId, unitId, civAdjKey,
--                                unitDescKey, bucket }, ... }
-- Units missing a civ adjective key or unit Description (mod content
-- with bad rows) are dropped.
function ForeignUnitSnapshot.collect(bucketFn)
    local set = {}
    local activePlayerId = Game.GetActivePlayer()
    local activeTeam = Game.GetActiveTeam()
    local maxIndex = (GameDefines and GameDefines.MAX_CIV_PLAYERS) or 63
    for i = 0, maxIndex do
        if i ~= activePlayerId then
            local player = Players[i]
            if player ~= nil and player:IsAlive() then
                local bucket = bucketFn(i, activePlayerId, activeTeam)
                if bucket ~= nil then
                    for unit in player:Units() do
                        if not unit:IsInvisible(activeTeam, false) then
                            local plot = unit:GetPlot()
                            if plot ~= nil and plot:IsVisible(activeTeam, false) then
                                local meta = ForeignUnitSnapshot.metadata(unit, i, bucket)
                                if meta.civAdjKey ~= nil and meta.unitDescKey ~= nil then
                                    set[ForeignUnitSnapshot.unitKey(i, meta.unitId)] = meta
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return set
end

-- "{count} <civ adj> <unit name>" rendering, comma-joined, sorted
-- alphabetically by (civAdjKey, unitDescKey). Sorting matters: pairs()
-- on the counts table is non-deterministic, and unsorted output reorders
-- the list across flushes even when the content is identical, which
-- sounds wrong to a screen-reader user tracking a familiar list. No
-- plural form -- Civ V text data has no TXT_KEY_UNIT_*_PLURAL keys, and
-- screen readers parse "3 Warrior" as plural from context.
function ForeignUnitSnapshot.formatList(entries)
    local counts = {}
    local order = {}
    for _, e in ipairs(entries) do
        local key = e.civAdjKey .. "|" .. e.unitDescKey
        local bucket = counts[key]
        if bucket == nil then
            counts[key] = {
                count = 1,
                civ = Text.key(e.civAdjKey),
                unit = Text.key(e.unitDescKey),
            }
            order[#order + 1] = key
        else
            bucket.count = bucket.count + 1
        end
    end
    table.sort(order)
    local pieces = {}
    for _, k in ipairs(order) do
        local b = counts[k]
        if b.count > 1 then
            pieces[#pieces + 1] = tostring(b.count) .. " " .. b.civ .. " " .. b.unit
        else
            pieces[#pieces + 1] = b.civ .. " " .. b.unit
        end
    end
    return table.concat(pieces, ", ")
end
