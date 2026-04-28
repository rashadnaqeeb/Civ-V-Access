-- Ctrl+I on the hex cursor. Enumerates everything on the plot that has
-- a Civilopedia article (units, world wonders in the city, improvement,
-- resource, feature, terrain, route), dedupes by pedia name so a carrier
-- with four fighters collapses to a single Fighter entry, and either
-- opens the pedia directly on a single result or pops a BaseMenu picker.
-- Unrevealed plots short-circuit: the user's own fog-of-war knowledge is
-- the gate, not arbitrary dedup rules.
--
-- Foreign units count: if the tile reveals a rival Warrior you still want
-- to know what a Warrior is. Invisible units (stealth, fog) are filtered
-- via IsInvisible, matching CursorActivate / Cursor.unitAtTile.

CursorPedia = {}

local function addEntry(entries, seen, name)
    if name == nil or name == "" then
        return
    end
    if seen[name] then
        return
    end
    seen[name] = true
    entries[#entries + 1] = { label = name, pediaName = name }
end

local function collectUnits(plot, entries, seen)
    local team = Game.GetActiveTeam()
    local isDebug = Game.IsDebugMode()
    local n = plot:GetNumLayerUnits(-1)
    for i = 0, n - 1 do
        local u = plot:GetLayerUnit(i, -1)
        if u ~= nil and not u:IsInvisible(team, isDebug) then
            local info = GameInfo.Units[u:GetUnitType()]
            if info ~= nil then
                addEntry(entries, seen, Text.key(info.Description))
            end
        end
    end
end

local function isWorldWonder(building)
    local bclass = GameInfo.BuildingClasses[building.BuildingClass]
    if bclass == nil then
        return false
    end
    return (bclass.MaxGlobalInstances or 0) > 0
end

local function collectCityWonders(plot, entries, seen)
    if not plot:IsCity() then
        return
    end
    local city = plot:GetPlotCity()
    if city == nil then
        return
    end
    for building in GameInfo.Buildings() do
        if isWorldWonder(building) and city:IsHasBuilding(building.ID) then
            addEntry(entries, seen, Text.key(building.Description))
        end
    end
end

local function collectImprovement(plot, entries, seen)
    local id = plot:GetRevealedImprovementType(Game.GetActiveTeam(), Game.IsDebugMode())
    if id < 0 then
        return
    end
    local info = GameInfo.Improvements[id]
    if info == nil then
        return
    end
    addEntry(entries, seen, Text.key(info.Description))
end

local function collectResource(plot, entries, seen)
    local id = plot:GetResourceType(Game.GetActiveTeam())
    if id < 0 then
        return
    end
    local info = GameInfo.Resources[id]
    if info == nil then
        return
    end
    addEntry(entries, seen, Text.key(info.Description))
end

local function collectFeature(plot, entries, seen)
    local id = plot:GetFeatureType()
    if id < 0 then
        return
    end
    local info = GameInfo.Features[id]
    if info == nil then
        return
    end
    addEntry(entries, seen, Text.key(info.Description))
end

-- Rivers and lakes are FakeFeatures in the engine (not returned by
-- GetFeatureType), but they have regular pedia articles reachable via
-- the FakeFeatures Description TXT_KEYs. String-key access on
-- GameInfo.FakeFeatures is unverified in base code (which only accesses
-- by numeric ID), so a nil result logs rather than silently dropping
-- the entry -- per the no-silent-failures rule, an invisible miss in
-- the accessibility pipeline is the worst outcome for the user.
local function collectRiverLake(plot, entries, seen)
    if plot:IsRiver() then
        local info = GameInfo.FakeFeatures["FEATURE_RIVER"]
        if info == nil then
            Log.warn("CursorPedia: GameInfo.FakeFeatures['FEATURE_RIVER'] returned nil; river entry skipped")
        else
            addEntry(entries, seen, Text.key(info.Description))
        end
    end
    if plot:IsLake() then
        local info = GameInfo.FakeFeatures["FEATURE_LAKE"]
        if info == nil then
            Log.warn("CursorPedia: GameInfo.FakeFeatures['FEATURE_LAKE'] returned nil; lake entry skipped")
        else
            addEntry(entries, seen, Text.key(info.Description))
        end
    end
end

local function collectTerrain(plot, entries, seen)
    local id = plot:GetTerrainType()
    if id < 0 then
        return
    end
    local info = GameInfo.Terrains[id]
    if info == nil then
        return
    end
    addEntry(entries, seen, Text.key(info.Description))
end

local function collectRoute(plot, entries, seen)
    local id = plot:GetRevealedRouteType(Game.GetActiveTeam(), Game.IsDebugMode())
    if id < 0 then
        return
    end
    local info = GameInfo.Routes[id]
    if info == nil then
        return
    end
    addEntry(entries, seen, Text.key(info.Description))
end

-- Hills and Mountain are plot types, not terrain values returned by
-- GetTerrainType -- a Plains Hills tile has terrain=Plains. Both have
-- pedia entries under GameInfo.Terrains (TERRAIN_HILL / TERRAIN_MOUNTAIN)
-- reachable the same way the base pedia indexes them. Dedup handles the
-- mountain case where both GetTerrainType (TERRAIN_MOUNTAIN) and
-- IsMountain resolve to the same pedia entry.
local function collectPlotType(plot, entries, seen)
    if plot:IsHills() then
        local info = GameInfo.Terrains["TERRAIN_HILL"]
        if info ~= nil then
            addEntry(entries, seen, Text.key(info.Description))
        end
    end
    if plot:IsMountain() then
        local info = GameInfo.Terrains["TERRAIN_MOUNTAIN"]
        if info ~= nil then
            addEntry(entries, seen, Text.key(info.Description))
        end
    end
end

-- Order: dynamic content first (units, city wonders, improvement,
-- resource), then static landform (features, rivers / lakes, terrain,
-- hills / mountain), then route. Terrain is always present on a revealed
-- plot, so the single-entry auto-open still answers "what is this tile"
-- on a bare plot. Unrevealed plots short-circuit to zero entries: pedia
-- articles aren't secrets, but surfacing them on an unexplored tile leaks
-- "there is something here" information the player hasn't earned.
local function buildEntries(plot)
    if not plot:IsRevealed(Game.GetActiveTeam(), Game.IsDebugMode()) then
        return {}
    end
    local entries, seen = {}, {}
    collectUnits(plot, entries, seen)
    collectCityWonders(plot, entries, seen)
    collectImprovement(plot, entries, seen)
    collectResource(plot, entries, seen)
    collectFeature(plot, entries, seen)
    collectRiverLake(plot, entries, seen)
    collectTerrain(plot, entries, seen)
    collectPlotType(plot, entries, seen)
    collectRoute(plot, entries, seen)
    return entries
end

function CursorPedia.run(plot)
    if plot == nil then
        return
    end
    local entries = buildEntries(plot)
    if #entries == 0 then
        return
    end
    if #entries == 1 then
        Events.SearchForPediaEntry(entries[1].pediaName)
        return
    end
    local items = {}
    for _, entry in ipairs(entries) do
        local pediaName = entry.pediaName
        items[#items + 1] = BaseMenuItems.Choice({
            labelText = entry.label,
            pediaName = pediaName,
            activate = function()
                HandlerStack.removeByName("CursorPedia", false)
                Events.SearchForPediaEntry(pediaName)
            end,
        })
    end
    HandlerStack.removeByName("CursorPedia", false)
    local handler = BaseMenu.create({
        name = "CursorPedia",
        displayName = Text.key("TXT_KEY_CIVVACCESS_CURSOR_PEDIA_MENU_NAME"),
        items = items,
        capturesAllInput = true,
        escapePops = true,
        escapeAnnounce = Text.key("TXT_KEY_CIVVACCESS_CANCELED"),
        -- The user already knows they asked for pedia articles; reading
        -- "Articles at tile" before the first entry is redundant. F1
        -- still re-reads displayName on demand. Mirrors CursorActivate.
        silentDisplayName = true,
    })
    HandlerStack.push(handler)
end

-- Test seam. Production callers go through run().
CursorPedia._buildEntries = buildEntries
