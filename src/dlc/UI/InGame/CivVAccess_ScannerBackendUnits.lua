-- Scanner backend: units. Partitioned into My / Neutral / Enemy by the
-- scanning player's team stance, plus the Barbarians subcategory under
-- Enemy. Role subcategory is derived from Domain + UnitCombat per the
-- table in docs/scanner-design.md section 2.

ScannerBackendUnits = {
    name = "units",
}

-- Upper bound for the player-slot loop. The barbarian player sits at
-- GameDefines.BARBARIAN_PLAYER, one slot above MAX_CIV_PLAYERS (majors
-- + minors), so iterating up to MAX_CIV_PLAYERS inclusive (== the barb
-- index) picks up barb units for the Barbarians subcategory. Cities
-- backend uses a tighter bound because barbs don't own cities.
local MAX_PLAYER_INDEX = (GameDefines and GameDefines.MAX_CIV_PLAYERS) or 63

-- Land UnitCombat buckets. The design folds RECON into Melee for v1
-- (scouts are frontline skirmishers; splitting out inflates the sub
-- list). MOUNTED and HELICOPTER share the Mounted sub because the
-- Helicopter Gunship is DOMAIN_LAND with fast-attack behaviour.
local MELEE_COMBATS = {
    UNITCOMBAT_MELEE = true,
    UNITCOMBAT_GUN = true,
    UNITCOMBAT_ARMOR = true,
    UNITCOMBAT_RECON = true,
}
local MOUNTED_COMBATS = {
    UNITCOMBAT_MOUNTED = true,
    UNITCOMBAT_HELICOPTER = true,
}

-- Resolve the Domain / UnitCombat pair into one of the fixed role
-- subcategory keys in ScannerCore.CATEGORIES. Great People MUST be
-- checked before Civilian -- both match on IsCombatUnit == false, and
-- Great People is the more specific bucket. Returns nil only if a
-- category doesn't apply (e.g. trade units without a UnitCombat row);
-- callers drop such entries rather than misbucketing them.
local function roleSubcategory(unit)
    local specialId = unit:GetSpecialUnitType()
    if specialId ~= nil and specialId >= 0 and GameInfoTypes ~= nil then
        local greatId = GameInfoTypes.SPECIALUNIT_PEOPLE
        if greatId ~= nil and specialId == greatId then
            return "great_people"
        end
    end
    if not unit:IsCombatUnit() then
        return "civilian"
    end
    local domain = unit:GetDomainType()
    if domain == DomainTypes.DOMAIN_AIR then
        return "air"
    end
    if domain == DomainTypes.DOMAIN_SEA then
        return "naval"
    end
    local combatId = unit:GetUnitCombatType()
    if combatId == nil or combatId < 0 then
        return nil
    end
    local combatRow = GameInfo.UnitCombatInfos and GameInfo.UnitCombatInfos[combatId]
    local combatType = combatRow and combatRow.Type
    if combatType == nil then
        return nil
    end
    if combatType == "UNITCOMBAT_ARCHER" then
        return "ranged"
    end
    if combatType == "UNITCOMBAT_SIEGE" then
        return "siege"
    end
    if MOUNTED_COMBATS[combatType] then
        return "mounted"
    end
    if MELEE_COMBATS[combatType] then
        return "melee"
    end
    return nil
end

-- From the active team's perspective, which top-level Units category
-- does this unit's owner belong to? Barbarians route into units_enemy
-- via the separate `barbarians` subcategory; caller checks that first.
local function ownerCategory(ownerId, activePlayerId, activeTeam)
    if ownerId == activePlayerId then
        return "units_my"
    end
    local owner = Players[ownerId]
    if owner == nil then
        return nil
    end
    if owner:IsBarbarian() then
        return "units_enemy"
    end
    local ownerTeamId = owner:GetTeam()
    if ownerTeamId == activeTeam then
        return "units_my"
    end
    if Teams[activeTeam]:IsAtWar(ownerTeamId) then
        return "units_enemy"
    end
    return "units_neutral"
end

-- itemName is also the collapse-by-name key in ScannerSnap, so the civ
-- adjective on non-own units does double duty: the user hears whose
-- units they're scanning, and Roman Warriors stay separate from
-- Babylonian Warriors in the collapsed item list. Own units keep the
-- bare description because the category (units_my) already disambiguates.
local function unitItemName(unit, category)
    local unitType = unit:GetUnitType()
    local row = GameInfo.Units[unitType]
    if row == nil or row.Description == nil then
        return nil
    end
    if category == "units_my" then
        return Text.key(row.Description)
    end
    local owner = Players[unit:GetOwner()]
    if owner == nil then
        return Text.key(row.Description)
    end
    return Text.unitWithCiv(owner:GetCivilizationAdjectiveKey(), row.Description)
end

-- Own-team trade units sit on plots the engine considers fogged because
-- CvUnit::canChangeVisibility returns false on non-default map layers, so
-- setXY skips changeAdjacentSight when the unit moves. Sighted players
-- still see the caravan / cargo ship via the trade visuals system, so the
-- scanner mirrors that by accepting an own-team trade unit even when its
-- plot fails IsVisible. Enemy / neutral trade units stay gated by fog --
-- the engine deliberately withholds those from the active team.
local function unitVisibleToScanner(plot, unit, category, activeTeam, isDebug)
    if plot:IsVisible(activeTeam, isDebug) then
        return not unit:IsInvisible(activeTeam, isDebug)
    end
    if category == "units_my" and unit:IsTrade() then
        return not unit:IsInvisible(activeTeam, isDebug)
    end
    return false
end

function ScannerBackendUnits.Scan(activePlayer, activeTeam)
    local out = {}
    local isDebug = Game.IsDebugMode()
    for playerId = 0, MAX_PLAYER_INDEX do
        local player = Players[playerId]
        if player ~= nil and player:IsAlive() then
            local isBarb = player:IsBarbarian()
            local category = ownerCategory(playerId, activePlayer, activeTeam)
            if category ~= nil then
                for unit in player:Units() do
                    local plot = unit:GetPlot()
                    if plot ~= nil and unitVisibleToScanner(plot, unit, category, activeTeam, isDebug) then
                        local subcategory
                        if isBarb then
                            subcategory = "barbarians"
                        else
                            subcategory = roleSubcategory(unit)
                        end
                        local name = unitItemName(unit, category)
                        if subcategory ~= nil and name ~= nil then
                            local unitId = unit:GetID()
                            out[#out + 1] = {
                                plotIndex = plot:GetPlotIndex(),
                                backend = ScannerBackendUnits,
                                data = {
                                    ownerId = playerId,
                                    unitId = unitId,
                                },
                                category = category,
                                subcategory = subcategory,
                                itemName = name,
                                key = "units:" .. playerId .. ":" .. unitId,
                                sortKey = 0,
                            }
                        end
                    end
                end
            end
        end
    end
    return out
end

function ScannerBackendUnits.ValidateEntry(entry, _cursorPlotIndex)
    local player = Players[entry.data.ownerId]
    if player == nil then
        return false
    end
    local unit = player:GetUnitByID(entry.data.unitId)
    if unit == nil or unit:IsDead() then
        return false
    end
    local plot = unit:GetPlot()
    if plot == nil then
        return false
    end
    local activeTeam = Game.GetActiveTeam()
    local isDebug = Game.IsDebugMode()
    if not unitVisibleToScanner(plot, unit, entry.category, activeTeam, isDebug) then
        return false
    end
    -- Stale plotIndex from a unit that moved is still a valid entry for
    -- announcement; the snapshot's sort is just out of date. Nav uses
    -- the entry's stored plotIndex for distance, which matches what
    -- the snapshot was sorted against.
    return true
end

function ScannerBackendUnits.FormatName(entry)
    return entry.itemName
end

ScannerCore.registerBackend(ScannerBackendUnits)
